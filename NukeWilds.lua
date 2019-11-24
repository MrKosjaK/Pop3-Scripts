import(Module_System)
import(Module_DataTypes)
import(Module_Defines)
import(Module_Globals)
import(Module_Map)
import(Module_MapWho)
import(Module_Objects)
import(Module_Game)
import(Module_Globals)
import(Module_Person)
import(Module_DataTypes)
import(Module_Helpers)
import(Module_System)

function OnTurn()
  local shaman = getShaman(TRIBE_BLUE)
  if (shaman ~= nil) then
    ProcessGlobalTypeList(T_PERSON, function(t)
      if (t.Model == M_PERSON_WILD) then
        person_goto_point(t,false,shaman.Pos.D2)
        if (get_world_dist_xyz(t.Pos.D3, shaman.Pos.D3) < 400) then
          for i=0,63 do
            createThing(T_SHOT,7,TRIBE_NEUTRAL,t.Pos.D3,false,false)
          end
          DestroyThing(t)
        end
      end
      return true
    end)
  end
end