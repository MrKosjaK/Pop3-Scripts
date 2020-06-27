--[[
  Author: MrKosjaK
  Version: 1.0
  Description: Weather outside is quite wild, isn't it?
]]

import(Module_Objects)
import(Module_Globals)
import(Module_DataTypes)
import(Module_Game)
import(Module_Map)
import(Module_Defines)

local count = 250
local gs = gsi()
function OnTurn()
  if (gs.Counts.GameTurn % 4 == 0) then
    if (count > 0) then
      count = count-1
      for i=0,G_RANDOM(30)+1 do
        local c3d = Coord3D.new()
        c3d.Xpos = G_RANDOM(65536)
        c3d.Zpos = G_RANDOM(65536)
        local wild = createThing(T_PERSON,M_PERSON_WILD,TRIBE_HOSTBOT,c3d,false,false)
        wild.Pos.D3.Ypos = wild.Pos.D3.Ypos + 1024
        wild.u.Pers.Life = 1000
        wild.Flags = wild.Flags ~ TF_LOST_CONTROL
        wild.Flags2 = wild.Flags2 ~ TF2_THING_IN_AIR
      end
    else
      exit()
    end
  end
end
