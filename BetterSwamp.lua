import(Module_Game)
import(Module_Defines)
import(Module_Table)
import(Module_DataTypes)
import(Module_Person)
import(Module_Map)
import(Module_MapWho)
import(Module_Objects)

include("UtilRefs.lua")

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

    SearchMapCells(CIRCULAR,0,0,data.sSize,world_coord3d_to_map_idx(data.sCoord3D),function(me)
      local c2d = Coord2D.new()
      local c3d = Coord3D.new()
      map_ptr_to_world_coord2d(me,c2d)
      if (is_map_point_land(c2d) ~= 0) then
        table.insert(data.sArr_MWL,me.MapWhoList)
        coord2D_to_coord3D(c2d,c3d)
        centre_coord3d_on_block(c3d)
        local mist = createThing(T_EFFECT,M_EFFECT_SWAMP_MIST,data.sOwner,c3d,false,false)
        table.insert(data.sArr_Mist,mist)
        if (G_RANDOM(5) > 0) then
          local grass = createThing(T_EFFECT,M_EFFECT_REEDY_GRASS,data.sOwner,c3d,false,false)
          table.insert(data.sArr_Grass,grass)
        end
      end
      return true
    end)
  end

  function data:IsDecayed()
    return data.sDecayed
  end

  function data:sProcess()
    if (GetTurn() < data.sLifeSpan) then
      for i,objlist in ipairs(data.sArr_MWL) do
        local count = 0
        objlist:processList(function(t)
          if (count < 256) then
            count=count+1
            if (t.Type == T_PERSON) then
              if (t.Owner ~= data.sOwner and is_thing_on_ground(t) == 1
              and is_person_in_airship(t) == 0 and is_person_in_drum_tower(t) == 0
              and is_person_on_a_building(t) == 0) then
                damage_person(t,data.sOwner,data.sDamage,1)
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
    for i in ipairs(swamps) do
      if not (swamps[i].IsDecayed()) then
        swamps[i]:sProcess()
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
        if (is_map_point_land(t.Pos.D2) ~= 0) then
          local swamp = DOTSwamp.new(t.Owner,t.Pos.D3,1,720*3,64)
          table.insert(swamps, swamp)
        end
        DestroyThing(t)
      end
    end
  end
end
