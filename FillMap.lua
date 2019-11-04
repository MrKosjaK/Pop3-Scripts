import(Module_Map)
import(Module_Objects)
import(Module_Defines)
import(Module_System)

for i=0,127 do
  local x = i*2
  for j=0,127 do
    local z = j*2
    local c3d = MAP_XZ_2_WORLD_XYZ(x,z)
    createThing(T_EFFECT,M_EFFECT_RAISE_LAND,TRIBE_HOSTBOT,c3d,false,false)
  end
end

log("Filled entire map with land!")
exit()