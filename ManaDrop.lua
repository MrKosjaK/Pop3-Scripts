--[[
  Author: MrKosjaK
  Version: 1.1a
  Description: Modifies vanilla mana gain/loss whenever your shaman dies.
  And as an additional feature it's being dropped as a loot!
]]

import(Module_Game)
import(Module_Globals)
import(Module_DataTypes)
import(Module_Objects)
import(Module_Defines)
import(Module_Players)
import(Module_Math)
import(Module_Map)
import(Module_Level)
import(Module_PopScript)

local const = constants()
local gs = gsi()
const.ShamenDeadManaPer256Gained = 0
const.ShamenDeadManaPer256Lost = 128

local function calcMana(pn)
  local mana_return = 0
  if (gs.Players[pn].PlayerType == HUMAN_PLAYER) then
    for i=0,NUM_SPELL_TYPES do
      if (gs.Players[pn].SpellsMana[i] > 0) then
        local increment = gs.Players[pn].SpellsMana[i] / 2
        mana_return = mana_return + increment
      end
    end
  else
    local increment = gs.Players[pn].Mana / 2
    mana_return = mana_return + increment
  end

  return math.ceil(mana_return)
end

local function dropMana(amount,coord)
  local coord_to_spawn = Coord3D.new()
  coord_to_spawn.Xpos = coord.Xpos
  coord_to_spawn.Zpos = coord.Zpos
  SearchMapCells(CIRCULAR, 0, 0, 16, world_coord3d_to_map_idx(coord), function(me)
    if (is_map_elem_all_land(me) == 1) then
      local c2d = Coord2D.new()
      map_ptr_to_world_coord2d(me, c2d)
      randomize_coord_on_block(c2d)
      coord2D_to_coord3D(c2d,coord_to_spawn)
      return false
    end
    return true
  end)
  local mana_drop = createThing(T_GENERAL,M_GENERAL_DISCOVERY,TRIBE_HOSTBOT,coord_to_spawn,false,false)
  mana_drop.u.Discovery.DiscoveryType = 6
  mana_drop.u.Discovery.DiscoveryModel = 5
  mana_drop.u.Discovery.AvailabilityType = 3
  mana_drop.u.Discovery.TriggerType = 0
  mana_drop.u.Discovery.ManaAmt = amount
end

local function calcTotalSpells(pn)
  local amount = 0
  for i=0,NUM_SPELL_TYPES do
    local count = GET_NUM_ONE_OFF_SPELLS(pn,i)
    if (count > 0) then
      amount = amount+count
    end
  end

  return amount
end

local function dropSpell(pn,coord)
  local rolls = 128
  local coord_to_spawn = Coord3D.new()
  coord_to_spawn.Xpos = coord.Xpos
  coord_to_spawn.Zpos = coord.Zpos
  local return_model = 0
  while (rolls > 0) do
    rolls=rolls-1
    local r_num = G_RANDOM(20)+2
    local amount = GET_NUM_ONE_OFF_SPELLS(pn, r_num)
    if (amount > 0) then
      gs.ThisLevelInfo.PlayerThings[pn].SpellsAvailableOnce[r_num] = gs.ThisLevelInfo.PlayerThings[pn].SpellsAvailableOnce[r_num]-1
      return_model = r_num
      break
    else
      r_num = G_RANDOM(20)+2
    end
  end
  if (return_model ~= 0) then
    SearchMapCells(CIRCULAR, 0, 0, 16, world_coord3d_to_map_idx(coord), function(me)
      if (is_map_elem_all_land(me) == 1) then
        local c2d = Coord2D.new()
        map_ptr_to_world_coord2d(me, c2d)
        centre_coord_on_block(c2d)
        coord2D_to_coord3D(c2d,coord_to_spawn)
        return false
      end
      return true
    end)
    local spell_drop = createThing(T_GENERAL,M_GENERAL_DISCOVERY,TRIBE_HOSTBOT,coord_to_spawn,false,false)
    spell_drop.u.Discovery.DiscoveryType = 11
    spell_drop.u.Discovery.DiscoveryModel = return_model
    spell_drop.u.Discovery.AvailabilityType = 1
    spell_drop.u.Discovery.TriggerType = 1
  end
end

function OnCreateThing(t)
  if (t.Type == T_INTERNAL) then
    if (t.Model == 12) then
      if (t.u.SoulConvert.CurrModel == M_PERSON_MEDICINE_MAN) then
        local mana = calcMana(t.Owner)
        if (calcTotalSpells(t.Owner) > 0) then
          dropSpell(t.Owner,t.Pos.D3)
        end
        dropMana(mana,t.Pos.D3)
      end
    end
  end
end
