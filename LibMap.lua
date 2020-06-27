import(Module_Map)

function me_to_c3d(me)
  local c2d = Coord2D.new()
  local c3d = Coord3D.new()
  map_ptr_to_world_coord2d(me,c2d)
  coord2D_to_coord3D(c2d,c3d)
  return c3d
end

function me_to_c2d(me)
  local c2d = Coord2D.new()
  map_ptr_to_world_coord2d(me,c2d)
  return c2d
end

function xz_to_me(x,z)
  local c3d = Coord3D.new()
  c3d = MAP_XZ_2_WORLD_XYZ(x,z)
  return world_coord3d_to_map_ptr(c3d)
end