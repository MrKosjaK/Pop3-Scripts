import(Module_DataTypes)
import(Module_Defines)
import(Module_Game)
import(Module_MapWho)
import(Module_Math)
import(Module_Objects)
import(Module_Person)
import(Module_Table)

include("UtilRefs.lua")
include("LibMap.lua")

DOTSwamp = {}
DOTSwamp.new = function(...)
  local args = {...}
  local data = {}
  data.sOwner = nil --Swamp's owner
  data.sCoord3D = nil --Swamp's 3D position
  data.sSize = nil --Swamp's size
  data.sLifeSpan = nil --Swamp's amount of ticks to live
  data.sDamage = nil --Swamp's damage per process
  data.sDecayed = false --Swamp's state

  data.sArr_Grass = {} --Swamp's grass stuff
  data.sArr_Mist = {} --Swamp's foggy stuff
  data.sArr_MWL = {} --Swamp's object lists for faster processing

  function data:sInit(arg1,arg2,arg3,arg4,arg5)
    data.sOwner = arg1
    data.sCoord3D = arg2
    data.sSize = arg3
    data.sLifeSpan = GetTurn() + arg4
    data.sDamage = arg5
    
    local mapXZ = MapPosXZ.new()
    mapXZ.Pos = MAP_ELEM_PTR_2_IDX(world_coord3d_to_map_ptr(data.sCoord3D))
    mapXZ.XZ.X = mapXZ.XZ.X-data.sSize+1
    mapXZ.XZ.Z = mapXZ.XZ.Z-data.sSize+1
    local x = 0
    local z = 0
    for i=0,data.sSize do
      x = mapXZ.XZ.X + i*2
      for i=0,data.sSize do
        z = mapXZ.XZ.Z + i*2
        local me = xz_to_me(x,z)
        if (is_map_elem_land_or_coast(me) > 0) then
          table.insert(data.sArr_MWL,me.MapWhoList)
          local c3d = me_to_c3d(me)
          centre_coord3d_on_block(c3d)
          local mist = createThing(T_EFFECT,M_EFFECT_SWAMP_MIST,data.sOwner,c3d,false,false)
          if (mist.Pos.D3.Ypos > 64) then
            mist.Pos.D3.Ypos = mist.Pos.D3.Ypos-64
          end
          table.insert(data.sArr_Mist,mist)
          if (G_RANDOM(5) > 0) then
            local grass = createThing(T_EFFECT,M_EFFECT_REEDY_GRASS,data.sOwner,c3d,false,false)
            table.insert(data.sArr_Grass,grass)
          end
        end
      end
    end
  end

  function data:IsDecayed()
    return data.sDecayed
  end

  function data:sProcess(turn)
    if (turn < data.sLifeSpan) then
      for i,objlist in ipairs(data.sArr_MWL) do
        local count = 0
        objlist:processList(function(t)
          if (count < 256) then
            count=count+1
            if (t.Type == T_PERSON) then
              if (t.Model > 1 and t.Model < 8) then
                if (t.Owner ~= data.sOwner and is_thing_on_ground(t) == 1
                and is_person_in_airship(t) == 0 and is_person_in_drum_tower(t) == 0
                and is_person_on_a_building(t) == 0 and are_players_allied(data.sOwner,t.Owner) == 0) then
                  damage_person(t,data.sOwner,data.sDamage,1)
                end
              end
            end
            if (t.Type == T_BUILDING) then
              if (t.Owner ~= data.sOwner and are_players_allied(data.sOwner,t.Owner) == 0) then
                if (t.u.Bldg.Damaged < 2000) then
                  t.u.Bldg.Damaged = t.u.Bldg.Damaged+(math.floor(data.sDamage/4))
                end
              end
            end
            return true
          else
            return false
          end
        end)
      end
    else
      if not (data.sDecayed) then
        data:sDie()
      end
    end
  end

  function data:sDie()
    data.sDecayed = true
    for i,t in ipairs(data.sArr_Mist) do
      DestroyThing(t)
    end

    for i,t in ipairs(data.sArr_Grass) do
      DestroyThing(t)
    end
  end

  data:sInit(args[1],args[2],args[3],args[4],args[5])

  return data
end

swamps = {}

function OnTurn()
  if (everyPow(3,2)) then
    local turn = GetTurn()
    for i in ipairs(swamps) do
      if not (swamps[i].IsDecayed()) then
        swamps[i]:sProcess(turn)
      else
        table.remove(swamps,i)
      end
    end
  end
end

function OnCreateThing(t)
  if (t.Type == T_EFFECT) then
    if (t.Model == M_EFFECT_SWAMP) then
      if (t.Owner ~= TRIBE_NEUTRAL or TRIBE_HOSTBOT) then
        if (is_map_elem_land_or_coast(world_coord2d_to_map_ptr(t.Pos.D2)) > 0) then
          local size = 1 + G_RANDOM(3)
          local swamp = DOTSwamp.new(t.Owner,t.Pos.D3,size,240*(4-size),512 - size*96)
          table.insert(swamps, swamp)
        end
        DestroyThing(t)
      end
    end
  end
end
