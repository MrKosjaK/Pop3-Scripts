import(Module_Map)
import(Module_Objects)
import(Module_Defines)
import(Module_Game)
import(Module_Globals)
import(Module_Helpers)

_gnsi = gnsi()

num_rocks = 0
clearState = 0
init = true

function clearRocks(t)
  if (t.Model == M_SCENERY_ROCK) then
    DestroyThing(t)
  end
  
  return true
end

function OnTurn()
  if (init) then
    for i=0,127 do
      if (EVERY_2POW_TURNS(2)) then
        if (num_rocks < 32000) then
          num_rocks = num_rocks+1
          local x = G_RANDOM(256)
          local z = G_RANDOM(256)
          local rock = createThing(T_SCENERY,M_SCENERY_ROCK,TRIBE_HOSTBOT,MAP_XZ_2_WORLD_XYZ(x,z),false,false)
          rock.Pos.D3.Ypos = 3072
        end
      end
    end
  end
end

function OnKeyDown(k)
  if not (isFlagEnabled(_gnsi.Flags, GNS_NETWORK)) then
    if (k == LB_KEY_B and num_rocks > 0) then
      ProcessGlobalTypeList(T_SCENERY, clearRocks)
      num_rocks = 0
    end
    
    if (k == LB_KEY_V) then
      if (init) then
        init = false
      else
        init = true
      end
    end
  end
end