import(Module_System)
import(Module_DataTypes)
import(Module_Defines)
import(Module_Objects)
import(Module_MapWho)
import(Module_Globals)
import(Module_Map)
import(Module_Game)

local doomsday_on_going = false
local doomsday_count = 0

log("Doomsday spell is injected!")
sti = spells_type_info()
sti[18].EffectModels[0] = 11

local function spawn_fire_ball(c3d)
  c3d.Ypos = point_altitude(c3d.Xpos,c3d.Zpos)+1536
  local fireball = createThing(T_SHOT,M_SHOT_FIREBALL,TRIBE_NEUTRAL,c3d,false,false)
  fireball.Move.SelfPowerSpeed = 750
  fireball.u.Shot.StartCoord = c3d
  c3d.Ypos = point_altitude(c3d.Xpos,c3d.Zpos)-20
  fireball.u.Shot.TargetCoord = c3d
  fireball.u.Shot.EffectType = T_EFFECT
  fireball.u.Shot.EffectModel = M_EFFECT_SPHERE_EXPLODE_AND_FIRE
end

local function spawn_effect(c3d,model)
  createThing(T_EFFECT,model,TRIBE_HOSTBOT,c3d,false,false)
end

function OnTurn()
  if (doomsday_on_going) then
    if (doomsday_count > 0) then
      doomsday_count = doomsday_count-1
      local c3d = Coord3D.new()
      for i=0,24 do
        c3d.Xpos = G_RANDOM(65536)
        c3d.Zpos = G_RANDOM(65536)
        spawn_fire_ball(c3d)
      end
      if (G_RANDOM(5) == 0) then
        spawn_effect(c3d,M_EFFECT_WHIRLWIND)
      end
      if (G_RANDOM(15) == 0) then
        spawn_effect(c3d,M_EFFECT_EROSION)
      end
      if (G_RANDOM(25) == 0) then
        spawn_effect(c3d,M_EFFECT_EARTHQUAKE)
      end
      if (G_RANDOM(200) == 0) then
        spawn_effect(c3d,M_EFFECT_VOLCANO)
      end
    else
      doomsday_count = 0
      doomsday_on_going = false
    end
  end
end

function OnCreateThing(t)
  if (t.Type == T_EFFECT) then
    if (t.Model == M_EFFECT_FIRECLOUD) then
      doomsday_on_going = true
      doomsday_count = 12*60
      log("Doomsday is init'd!")
    end
  end
end