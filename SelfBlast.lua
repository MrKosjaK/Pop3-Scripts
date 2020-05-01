--[[
  Author: MrKosjaK
  Version: 1.0
  Description: Allows you to blast your own units!
]]

import(Module_Objects)
import(Module_Defines)

function OnCreateThing(t)
  if (t.Type == T_EFFECT) then
    if (t.Owner ~= TRIBE_HOSTBOT) then
      if (t.Model == M_EFFECT_SPELL_BLAST) then
        swapOwner(t,TRIBE_HOSTBOT)
      end
    end
  end
end
