import(Module_Map)

--[[
Name: Map Data Type Conversion

Description: Provides a few various functiions to help user with converting between map data types.

Usage: Drop into "Scripts" folder inside your populous installation.
  include("LibMDTC.lua")

Functions:
  @return @function(params)
  ------------------------------
  Coord3D MapCoord_to_WorldCoord3D(x,z,centre)
  Coord2D MapCoord_to_WorldCoord2D(x,z,centre)
  MapElement MapCoord_to_MapElement(x,z)
  X, Z WorldCoord2D_to_MapCoord(c3d)
  X, Z WorldCoord3D_to_MapCoord(c2d)
  X, Z MapElement_to_MapCoord(me)
  Coord3D MapElement_to_WorldCoord3D(me,centre)
  Coord2D MapElement_to_WorldCoord3D(me,centre)
  ------------------------------
]]

function MapCoord_to_WorldCoord3D(x,z,centre)
  local _centre = centre or false
  local c3d = MAP_XZ_2_WORLD_XYZ(x,z)
  if (_centre) then
    centre_coord3d_on_block(c3d)
  end
  return c3d
end

function MapCoord_to_WorldCoord2D(x,z,centre)
  local _centre = centre or false
  local c3d = MAP_XZ_2_WORLD_XYZ(x,z)
  local c2d = Coord2D.new()
  coord3D_to_coord2D(c3d,c2d)
  if (_centre) then
    centre_coord_on_block(c2d)
  end
  return c2d
end

function MapCoord_to_MapElement(x,z)
  local c3d = MAP_XZ_2_WORLD_XYZ(x,z)
  local me = world_coord3d_to_map_ptr(c3d)
  return me
end

function WorldCoord2D_to_MapCoord(c3d)
  local mp = MapPosXZ.new()
  mp.Pos = world_coord3d_to_map_idx(c3d)
  return mp.XZ.X, mp.XZ.Z
end

function WorldCoord3D_to_MapCoord(c2d)
  local mp = MapPosXZ.new()
  mp.Pos = world_coord2d_to_map_idx(c2d)
  return mp.XZ.X, mp.XZ.Z
end

function MapElement_to_MapCoord(me)
  local mp = MapPosXZ.new()
  mp.Pos = MAP_ELEM_PTR_2_IDX(me)
  return mp.XZ.X, mp.XZ.Z
end

function MapElement_to_WorldCoord3D(me,centre)
  local c2d = Coord2D.new()
  map_ptr_to_world_coord2d(me,c2d)
  local c3d = Coord3D.new()
  coord2D_to_coord3D(c2d,c3d)
  local _centre = centre or false
  if (_centre) then
    centre_coord3d_on_block(c3d)
  end
  return c3d
end

function MapElement_to_WorldCoord2D(me,centre)
  local c2d = Coord2D.new()
  map_ptr_to_world_coord2d(me,c2d)
  local _centre = centre or false
  if (_centre) then
    centre_coord_on_block(c2d)
  end
  return c2d
end
