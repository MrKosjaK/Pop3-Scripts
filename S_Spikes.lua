import(Module_MapWho)
import(Module_Defines)
import(Module_Map)
import(Module_Objects)
import(Module_System)
import(Module_Table)
import(Module_Game)
import(Module_Sound)
import(Module_Draw)

local erodeBuffer = {}
local BetterErosion = {}
BetterErosion.new = function(arg1,arg2)
  local data = {}
  data.Size = arg1
  data.Coord = arg2
  data.LifeSpan = 12*6
  data.ptrsBuffer = {}
  data.SoundThing = nil
  
  function data:reg_ptrs()
    data.SoundThing = createThing(T_GENERAL,M_GENERAL_MAPWHO_THING,TRIBE_HOSTBOT,data.Coord,false,false)
    data.SoundThing.DrawInfo.Flags = data.SoundThing.DrawInfo.Flags ~ DF_THING_NO_DRAW
    play_sound_event(data.SoundThing,SND_EVENT_SP_ERODE,0)
    log("Erode size is: " .. data.Size)
    SearchMapCells(CIRCULAR,0,0,data.Size,world_coord3d_to_map_idx(data.Coord),function(me)
      table.insert(data.ptrsBuffer,me)
      return true
    end)
  end
  
  function data:i_am_relatable()
    return data.LifeSpan
  end
  
  function data:free()
    DestroyThing(data.SoundThing)
  end
  
  function data:process_ptrs()
    if (data.LifeSpan > 0) then
      local amt = 16 + G_RANDOM(12)
      if (data.LifeSpan % 18 == 0) then
        play_sound_event(data.SoundThing,SND_EVENT_SP_ERODE,0)
      end
      for i=0,8 do
        local idx = G_RANDOM(#data.ptrsBuffer)+1
        local c3d = Coord3D.new()
        local c2d = Coord2D.new()
        map_ptr_to_world_coord2d(data.ptrsBuffer[idx],c2d)
        coord2D_to_coord3D(c2d,c3d)
        if (data.ptrsBuffer[idx].Alt < 1024) then
          --createThing(T_EFFECT,M_EFFECT_LOWER_LAND,TRIBE_HOSTBOT,c3d,false,false)
          data.ptrsBuffer[idx].Alt = data.ptrsBuffer[idx].Alt + (64 + G_RANDOM(128) * randSign())
          if (data.ptrsBuffer[idx].Alt < 1) then
            data.ptrsBuffer[idx].Alt = 1
          end
          data.ptrsBuffer[idx].Flags = data.ptrsBuffer[idx].Flags ~ (1<<0)
        elseif (data.ptrsBuffer[idx].Alt > 1024) then
          data.ptrsBuffer[idx].Alt = data.ptrsBuffer[idx].Alt - (64 + G_RANDOM(512))
          data.ptrsBuffer[idx].Flags = data.ptrsBuffer[idx].Flags ~ (1<<0)
        end
        set_square_map_params(world_coord3d_to_map_idx(c3d), 2, TRUE)
        affect_mapwho_area(AFFECT_ALTITUDE,world_coord3d_to_map_idx(c3d), 2)
      end
      data.LifeSpan = data.LifeSpan - 1
    end
  end
     
  data:reg_ptrs()
     
  return data
end

function OnTurn()
  if EVERY_2POW_TURNS(4) then
    log("Erodes ongoing: " .. #erodeBuffer)
  end
  if (#erodeBuffer > 0) then
    for index,erode in ipairs(erodeBuffer) do
      if (erodeBuffer[index]:i_am_relatable() > 0) then
        erodeBuffer[index]:process_ptrs()
      else
        erodeBuffer[index]:free()
        table.remove(erodeBuffer,index)
      end
    end
  end
end

function OnCreateThing(t)
  if (t.Type == T_EFFECT) then
    if (t.Model == M_EFFECT_EROSION) then
      if (t.Owner ~= TRIBE_HOSTBOT or t.Owner ~= TRIBE_NEUTRAL) then
        local c3d = t.Pos.D3
        local erode = BetterErosion.new(5,t.Pos.D3)
        c3d.Xpos = c3d.Xpos+512*2
        c3d.Zpos = c3d.Zpos+512*2
        move_thing_within_mapwho(t,c3d)
        DestroyThing(t)
        table.insert(erodeBuffer,erode)
      end
    end
  end
end

function randSign()
  local s = 1
  if (G_RANDOM(2) == 0) then
    s = -1
  end
  return s
end