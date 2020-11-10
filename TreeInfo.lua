import(Module_System)
import(Module_Globals)
import(Module_Objects)
import(Module_DataTypes)
import(Module_ImGui)
import(Module_Helpers)
import(Module_Defines)
import(Module_Map)
import(Module_Math)

local gns = gnsi()
local gs = gsi()
local tree_for_inspect = ObjectProxy.new()
local ticks_left = 0
local secs_left = 0
local cache_res_rem = 0
local timer = 12

if (isFlagEnabled(gns.Flags, GNS_NETWORK)) then
  log("Network game detected! Unloading...")
  exit()
end

log("Script loaded!")

local function calculate_full_growth_time(res_rem)
  local a = 400-res_rem
  local b = (a*16)/2
  return b
end

local function calculate_full_growth_time_in_secs(res_rem)
  local a = 400-res_rem
  local b = (a*16)/2
  local c = b/12
  return math.floor(c)
end

local function mapwho_find_tree(t)
  if (t.Type == T_SCENERY) then
    if (t.Model <= 6) then
      log("Found tree!")
      tree_for_inspect:set(t.ThingNum)
      cache_res_rem = t.u.Scenery.ResourceRemaining
      ticks_left = calculate_full_growth_time(t.u.Scenery.ResourceRemaining)
      secs_left = calculate_full_growth_time_in_secs(t.u.Scenery.ResourceRemaining)
      return false
    end
  end

  return true
end

function OnTurn()
  if (not tree_for_inspect:isNull()) then
    if (ticks_left > 0 and tree_for_inspect:get().u.Scenery.ResourceRemaining >= cache_res_rem) then
      ticks_left = ticks_left-1
      if (timer > 1) then
        timer = timer-1
      elseif(timer <= 1) then
        timer = 12
        secs_left = secs_left-1
      end
    else
      cache_res_rem = tree_for_inspect:get().u.Scenery.ResourceRemaining
      ticks_left = calculate_full_growth_time(tree_for_inspect:get().u.Scenery.ResourceRemaining)
      secs_left = calculate_full_growth_time_in_secs(tree_for_inspect:get().u.Scenery.ResourceRemaining)
    end
  end
end

function OnCreateThing(t)
  if (t.Type == T_EFFECT) then
    if (t.Model == M_EFFECT_SMALL_SPARKLE) then
      if (isFlagEnabled(t.Flags3, TF3_LOCAL)) then
        tree_for_inspect:set(0)
        local me = world_coord2d_to_map_ptr(t.Pos.D2)
        me.MapWhoList:processList(mapwho_find_tree)
      end
    end
  end
end

function OnImGuiFrame()
  imgui.Begin('Tree Inspection', nil, ImGuiWindowFlags_AlwaysAutoResize)
  if (tree_for_inspect:isNull()) then
    imgui.TextUnformatted("No tree selected!")
  else
    imgui.TextUnformatted("Current Time: " .. gs.Counts.ProcessThings)
    imgui.TextUnformatted("Tree Wood: " .. tree_for_inspect:get().u.Scenery.ResourceRemaining)
    imgui.TextUnformatted("Grow In GameTurns: " .. ticks_left)
    imgui.TextUnformatted("Grow In Seconds: " .. secs_left)
    imgui.TextUnformatted("ThingNum: " .. tree_for_inspect:getThingNum())
    imgui.TextUnformatted("Tree Type: " .. tree_for_inspect:get().Model)
  end
  imgui.End()
end
