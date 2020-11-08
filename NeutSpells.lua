--[[
  Author: MrKosjaK
  Version: 1.0
  Description: Spells are harmful even to your tribe.
]]

import(Module_Objects)
import(Module_Defines)

function OnCreateThing(t)
  if (t.Type == T_EFFECT) then
    if (t.Owner ~= TRIBE_HOSTBOT) then
      if (t.Model == M_EFFECT_SPELL_BLAST) then
        swapOwner(t,TRIBE_HOSTBOT)
      end
      if (t.Model == M_EFFECT_FIRESTORM) then
        swapOwner(t,TRIBE_HOSTBOT)
      end
      if (t.Model == M_EFFECT_EARTHQUAKE) then
        swapOwner(t,TRIBE_HOSTBOT)
      end
      if (t.Model == M_EFFECT_INSECT_PLAGUE) then
        swapOwner(t,TRIBE_HOSTBOT)
      end
      if (t.Model == M_EFFECT_VOLCANO) then
        swapOwner(t,TRIBE_HOSTBOT)
      end
      if (t.Model == M_EFFECT_LIGHTNING_BOLT) then
        swapOwner(t,TRIBE_HOSTBOT)
      end
    end
  end
end
