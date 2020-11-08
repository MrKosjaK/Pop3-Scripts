import(Module_Map)
import(Module_Objects)
import(Module_Table)
import(Module_Globals)
import(Module_Game)

local to_grow = {}
local gs = gsi()

function NewDormantTree(_c3d,_delay)
  local self = {
    Coord = _c3d,
    Delay = _delay,
    HasSpawned = false
  }

  function self.Process()
    if (self.Delay > 0) then
      self.Delay = self.Delay-1
    else
      if (not self.HasSpawned) then
        self.HasSpawned = true
        CREATE_THING_WITH_PARAMS4(5,17,8,self.Coord,5,G_RANDOM(6)+1,0,0)
      end
    end
  end

  function self.HasTreeSpawned()
    return self.HasSpawned
  end

  return self
end

function create_delayed_trees(_me,r,chance)
  local mapXZ = MapPosXZ.new()
  mapXZ.Pos = MAP_ELEM_PTR_2_IDX(_me)
  mapXZ.XZ.X = mapXZ.XZ.X-(r+1)
  mapXZ.XZ.Z = mapXZ.XZ.Z-(r+1)
  local x = 0
  local z = 0
  for i=0,r+1 do
    x = mapXZ.XZ.X + i*2
    for i=0,r+1 do
      z = mapXZ.XZ.Z + i*2
      local c3d = Coord3D.new()
      c3d = MAP_XZ_2_WORLD_XYZ(x,z)
      local me = world_coord3d_to_map_ptr(c3d)
      if (is_map_elem_all_sea(me) == 2) then
        if (chance > G_RANDOM(100)) then
          local possible_tree = NewDormantTree(c3d,36+G_RANDOM(120))
          table.insert(to_grow,possible_tree)
        end
      end
    end
  end
end

function OnTurn()
  for i,t in ipairs(to_grow) do
    if (t.HasTreeSpawned()) then
      table.remove(to_grow,i)
    else
      t.Process()
    end
  end
end

function OnCreateThing(t)
  if (t.Type == 11) then
    if (t.Model == 12) then
      local s = getShaman(t.Owner)
      if (s ~= nil) then
        create_delayed_trees(world_coord2d_to_map_ptr(s.Pos.D2),7,4)
      end
      create_delayed_trees(world_coord2d_to_map_ptr(t.Pos.D2),7,4)
    end
  end
end
