--[[
  Author: MrKosjaK
  Version: 1.0
  Description: Prevents lightning spell from following shamans
]]

import(Module_Objects)
import(Module_DataTypes)
import(Module_Defines)

function OnCreateThing(t)
  if (t.Type == T_SPELL) then
    if (t.Model == M_SPELL_LIGHTNING_BOLT) then
      if (not t.u.Spell.TargetThingIdx:isNull()) then
        if (t.u.Spell.TargetThingIdx:get().Model == M_PERSON_MEDICINE_MAN) then
          t.u.Spell.TargetThingIdx:set(0)
        end
      end
    end
  end
end
