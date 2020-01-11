--[[
  Author: MrKosjaK
  Version: 1.0
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
  local mana_drop = createThing(T_GENERAL,M_GENERAL_DISCOVERY,TRIBE_HOSTBOT,coord,false,false)
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
    local spell_drop = createThing(T_GENERAL,M_GENERAL_DISCOVERY,TRIBE_HOSTBOT,coord,false,false)
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
