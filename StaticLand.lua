import(Module_System)
import(Module_String)
import(Module_Table)
import(Module_Globals)
import(Module_DataTypes)
import(Module_Map)

local str = string.format("StaticLand.lua has been successfully loaded!")

local gs = gsi()
local GetTurn = function() return gs.Counts.ProcessThings end
local tiles = {}

local StaticTile = {}
StaticTile.__index = StaticTile
function StaticTile:RegisterTile(_c3d,_healdmgland)
  local self = setmetatable({}, StaticTile)
  self.Coord3D = _c3d
  self.MapElem = world_coord3d_to_map_ptr(_c3d)
  self.Altitude = point_altitude(_c3d.Xpos, _c3d.Zpos) or 1
  self.HealDmgLand = _healdmgland or false
  return self
end

function StaticTile:CheckAlt()
  if (self.Altitude ~= self.MapElem.Alt) then
    self.MapElem.Alt = self.Altitude
    set_square_map_params(world_coord3d_to_map_idx(self.Coord3D),2,1)
  end
end

local _positions = {
  MAP_XZ_2_WORLD_XYZ(252, 4)
}

for i,c3d in ipairs(_positions) do
  SearchMapCells(2,0,0,32,world_coord3d_to_map_idx(c3d),function(me)
    local c2d = Coord2D.new()
    local c3d = Coord3D.new()
    map_ptr_to_world_coord2d(me,c2d)
    coord2D_to_coord3D(c2d,c3d)
    local t_tile = StaticTile:RegisterTile(c3d,false)
    table.insert(tiles,t_tile)
    return true
  end)
end

function OnTurn()
  if (GetTurn() % 3 == 0) then
    if (#tiles > 0) then
      local _tiles_str = string.format("Tiles buffer: %d", #tiles)
      log(_tiles_str)
      for i,Tile in ipairs(tiles) do
        Tile:CheckAlt()
      end
    end
  end
end

log(str)
