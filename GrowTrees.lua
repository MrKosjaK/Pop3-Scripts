import(Module_Objects)
import(Module_DataTypes)
import(Module_Defines)
import(Module_Map)
import(Module_Game)

max_searches = 256
chance = 10

function find_me_suitable_spot()
  local x = G_RANDOM(256)
  local z = G_RANDOM(256)
  local c2d = Coord2D.new()
  local c3d = Coord3D.new()
  local n = 0

  while (n < max_searches) do
    map_xz_to_world_coord2d(x,z,c2d)
    if (is_map_point_land(c2d) ~= 0) then
      break
    else
      x = G_RANDOM(256)
      z = G_RANDOM(256)
    end
  end

  coord2D_to_coord3D(c2d,c3d)
  return c3d
end

function OnTurn()
  if (EVERY_2POW_TURNS(2)) then
    if (G_RANDOM(1000) > 1000-chance) then
      CREATE_THING_WITH_PARAMS4(T_SCENERY,M_SCENERY_DORMANT_TREE,TRIBE_HOSTBOT,find_me_suitable_spot(),T_SCENERY,G_RANDOM(6)+1,0,0)
    end
  end
end