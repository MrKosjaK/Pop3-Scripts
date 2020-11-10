import(Module_Objects)
import(Module_System)
import(Module_MapWho)
import(Module_Map)
import(Module_Defines)
import(Module_Person)
import(Module_Globals)
import(Module_DataTypes)
import(Module_Math)
import(Module_Table)
import(Module_Draw)
import(Module_Players)

local swampBuffer = {}
local gs = gsi()

local SWAMP_SIZE = 2
local SWAMP_DURATION = 60
local SWAMP_DURATION_RANDOM = 20

function TileSwamp(_c3d,_pn,_duration)
  local this = {
    ticks = _duration,
    decayed = false
  }

  local _Coord = _c3d
  local _Owner = _pn
  local _mePtr = world_coord3d_to_map_ptr(_c3d).MapWhoList
  local _Mist = createThing(T_EFFECT,M_EFFECT_SWAMP_MIST,_Owner,_Coord,false,false)
  local _Grass = createThing(T_EFFECT,M_EFFECT_REEDY_GRASS,_Owner,_Coord,false,false)

  function this.Process()
    if (this.ticks > 0) then
      this.ticks = this.ticks - 1
      _mePtr:processList(function(t)
        if (t.Type == T_PERSON) then
          if (t.Model > 1 and t.Model < 8) then
            if (t.Owner ~= _Owner) then
              if (is_thing_on_ground(t) == 1 and is_person_in_airship(t) == 0
              and is_person_in_drum_tower(t) == 0 and is_person_on_a_building(t) == 0
              and are_players_allied(t.Owner,_Owner) == 0) then
                if (not this.decayed) then
                  if (t.u.Pers.Life > 0) then
                    local dmg = 65535
                    if (t.u.Pers.u.Owned.ShieldCount > 0) then
                      dmg = 450
                    end
                    damage_person(t,_Owner,dmg,1)
                    this.decayed = true
                    this.ticks = 0
                    DestroyThing(_Mist)
                    DestroyThing(_Grass)
                    return false
                  end
                end
              end
            end
          end
        end
        return true
      end)
    else
      if (not this.decayed) then
        this.decayed = true
        DestroyThing(_Mist)
        DestroyThing(_Grass)
      end
    end
  end

  function this.isDecayed()
    return this.decayed
  end

  return this
end

local function RegisterSwamp(_owner,_c3d,r)
  local mapXZ = MapPosXZ.new()
  mapXZ.Pos = world_coord3d_to_map_idx(_c3d)
  mapXZ.XZ.X = mapXZ.XZ.X-r+1
  mapXZ.XZ.Z = mapXZ.XZ.Z-r+1
  local x = 0
  local z = 0
  local count = 0
  for i=0,r do
    x = mapXZ.XZ.X + i*2
    for i=0,r do
      z = mapXZ.XZ.Z + i*2
      local c3d = Coord3D.new()
      c3d = MAP_XZ_2_WORLD_XYZ(x,z)
      centre_coord3d_on_block(c3d)
      local me = world_coord3d_to_map_ptr(c3d)
      if (is_map_elem_all_land(me) == 1) then
        local tile = TileSwamp(c3d,_owner,SWAMP_DURATION+math.random(0,SWAMP_DURATION_RANDOM))
        table.insert(swampBuffer,tile)
      end
    end
  end
end

function OnTurn()
  if (gs.Counts.ProcessThings % 4 == 0) then
    if (#swampBuffer > 0) then
      for i,tile in ipairs(swampBuffer) do
        if (not tile.isDecayed()) then
          tile.Process()
        else
          table.remove(swampBuffer,i)
        end
      end
    end
  end
end

function OnCreateThing(t)
  if (t.Type == T_EFFECT) then
    if (t.Model == M_EFFECT_SWAMP) then
      RegisterSwamp(t.Owner,t.Pos.D3,SWAMP_SIZE)
      DestroyThing(t)
    end
  end
end
