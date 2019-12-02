import(Module_DataTypes)
import(Module_Defines)
import(Module_Game)
import(Module_Map)
import(Module_MapWho)
import(Module_System)
import(Module_Objects)

type_names = {"PERSON","BUILDING","CREATURE","VEHICLE","SCENERY"}
person_models = {"WILD","BRAVE","WARRIOR","RELIGIOUS","SPY","FIREWARRIOR","SHAMAN","ANGEL"}
scenery_models = {"TREE","TREE","TREE","TREE","TREE","TREE","PLANT","PLANT","HEAD","FIRE","WOODPILE","RSPILLAR","ROCK","PORTAL","ISLAND","BRIDGE","DORMANTTREE","TOPSCENERY","SUBSCENERY"}

dupes=0

for i=0,127 do
  local x=i*2
  for j=0,127 do
    local z=j*2
    local c3d=MAP_XZ_2_WORLD_XYZ(x,z)
    local me=world_coord3d_to_map_ptr(c3d)
    if not (me.MapWhoList:isEmpty()) then
      local c=0
      me.MapWhoList:processList(function(t)
        if (t.Type == T_PERSON or t.Type == T_SCENERY) then
          c=c+1
          if (c>1) then
            dupes=dupes+1
            local mp = MapPosXZ.new()
            mp.Pos = world_coord3d_to_map_idx(t.Pos.D3)
            createThing(T_EFFECT,M_EFFECT_SPRITE_CIRCLES,TRIBE_HOSTBOT,t.Pos.D3,false,false)
            if (t.Type == T_PERSON) then
              log("Stacked Thing - Type: " .. type_names[t.Type] .. ", Model: " .. person_models[t.Model] .. ", XZ: " .. mp.XZ.X .. " , " .. mp.XZ.Z)
            elseif(t.Type == T_SCENERY) then
              log("Stacked Thing - Type: " .. type_names[t.Type] .. ", Model: " .. scenery_models[t.Model] .. ", XZ: " .. mp.XZ.X .. " , " .. mp.XZ.Z)
            end
          end
        end
        return true
      end)
    end
  end
end

log("Found: " .. dupes .. " stacked things!")
exit()