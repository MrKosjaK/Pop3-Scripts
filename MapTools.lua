import(Module_DataTypes)
import(Module_Defines)
import(Module_Game)
import(Module_Globals)
import(Module_Helpers)
import(Module_ImGui)
import(Module_Level)
import(Module_Map)
import(Module_Objects)
import(Module_Person)
import(Module_Players)
import(Module_String)
import(Module_System)
import(Module_Table)

local gs = gsi()
local pl_str = {"Blue","Red","Yellow","Green","Cyan","Purple","Black","Orange"}
local show_maptools_window = false
local show_mapinfo_window = false
world_mass = {
  water = 0,
  coast = 0,
  land = 0
}
world_ptrs = {
  water_ptrs = {},
  coast_ptrs = {},
  land_ptrs = {}
}
check_boxes = {
  checkCliff = {false,false},
  checkObstacles = {false,true},
  checkRandomWild = {false,false},
  checkOverlap = {false,true}
}
radios = {
  wildMethodGen = {false,0}
}
sliders = {
  heightMin = {false,0},
  heightMax = {false,256},
  treePercent = {false,5},
  treeDensity = {false,0},
  wildChance = {false,5},
  wildAmount = {false,4}
}
states = {
  checkCliff = false,
  checkObstacles = true,
  checkRandomWild = false,
  checkOverlap = true
}
variables = {
  heightMin = 0,
  heightMax = 256,
  treePercent = 5,
  treeDensity = 0,
  wildChance = 5,
  wildAmount = 4
}
mapinfo_vars = {
  wildCount = 0,
  treesCount = 0,
  triggerCount = 0,
  headsCount = 0,
  vaultsCount = 0,
  totalPop = 0
}

local function me_to_c3d(me)
  local c2d = Coord2D.new()
  local c3d = Coord3D.new()
  map_ptr_to_world_coord2d(me,c2d)
  coord2D_to_coord3D(c2d,c3d)
  return c3d
end

local function me_to_c2d(me)
  local c2d = Coord2D.new()
  map_ptr_to_world_coord2d(me,c2d)
  return c2d
end

local function xz_to_me(x,z)
  local c3d = Coord3D.new()
  c3d = MAP_XZ_2_WORLD_XYZ(x,z)
  return world_coord3d_to_map_ptr(c3d)
end

local function calc_objects_of_model(ty,m)
  local count = 0
  ProcessGlobalTypeList(ty, function(t)
  if (t.Model == m) then
    count=count+1
  end
  return true
  end)

  return count
end

local function calc_total_pop()
  local count = 0
  ProcessGlobalSpecialListAll(PEOPLELIST,function(t)
    if (t.Model ~= 1 and t.Model ~= 8) then
      count=count+1
    end
  return true
  end)

  return count
end

local function calc_trees()
  local count = 0
  ProcessGlobalTypeList(T_SCENERY, function(t)
  if (t.Model <= 6) then
    count=count+1
  end
  return true
  end)

  return count
end

local function calc_coast_part()
  local count = 0
  for i=0,(128*128)-1 do
    if (is_map_elem_coast(gs.Level.MapElements[i]) ~= 0) then
      count=count+1
      table.insert(world_ptrs.coast_ptrs, gs.Level.MapElements[i])
      --createThing(T_EFFECT,M_EFFECT_SMOKE,TRIBE_HOSTBOT,me_to_c3d(gs.Level.MapElements[i]),false,false)
    end
  end
  return count
end

local function calc_land_part()
  local count = 0
  for i=0,(128*128)-1 do
    if (is_map_elem_all_land(gs.Level.MapElements[i]) == 1) then
      count=count+1
      table.insert(world_ptrs.land_ptrs, gs.Level.MapElements[i])
      --createThing(T_EFFECT,M_EFFECT_LIGHTNING_ELEM,TRIBE_HOSTBOT,me_to_c3d(gs.Level.MapElements[i]),false,false)
    end
  end
  return count
end

local function calc_water_part()
  local count = 0
  for i=0,(128*128)-1 do
    if (is_map_elem_all_sea(gs.Level.MapElements[i]) == 2) then
      count=count+1
      --createThing(T_EFFECT,M_EFFECT_SPRITE_CIRCLES,TRIBE_HOSTBOT,me_to_c3d(gs.Level.MapElements[i]),false,false)
    end
  end
  return count
end

local function area_check_for_obstacles(elem,r)
  local mapXZ = MapPosXZ.new()
  mapXZ.Pos = MAP_ELEM_PTR_2_IDX(elem)
  mapXZ.XZ.X = mapXZ.XZ.X-r+1
  mapXZ.XZ.Z = mapXZ.XZ.Z-r+1
  local x = 0
  local z = 0
  local count = 0
  for i=0,r do
    x = mapXZ.XZ.X + i*2
    for i=0,r do
      z = mapXZ.XZ.Z + i*2
      local me = xz_to_me(x,z)
      --is spot walkable?
      if (states.checkCliff) then
        if (is_point_steeper_than(me_to_c2d(me),350) ~= 0) then
          do return end
        end
      end
      me.MapWhoList:processList(function(t)
        if (t.Type == T_SCENERY) then
          if (t.Model > 6) then
            count=count+1
          end
        end
        if (t.Type == T_BUILDING) then
          count=count+1
        end
        if (t.Type == T_SHAPE) then
          count=count+1
        end
        return true
      end)
    end
  end

  return count
end

local function tree_density_spawn(me,r)
  local mapXZ = MapPosXZ.new()
  mapXZ.Pos = MAP_ELEM_PTR_2_IDX(me)
  mapXZ.XZ.X = mapXZ.XZ.X-(r+1)
  mapXZ.XZ.Z = mapXZ.XZ.Z-(r+1)
  local x = 0
  local z = 0
  for i=0,r do
    x = mapXZ.XZ.X + i*2
    for i=0,r do
      z = mapXZ.XZ.Z + i*2
      local me = xz_to_me(x,z)
      if (me.MapWhoList:isEmpty() and (not me.ShapeOrBldgIdx:isNull())) then
        if (variables.treeDensity > G_RANDOM(100)) then
          if (states.checkCliff) then
            if (is_point_steeper_than(me_to_c2d(me),350) ~= 0) then
              do return end
            end
          end

          if (states.checkObstacles) then
            if (area_check_for_obstacles(me,4) ~= 0) then
              do return end
            end
          end
          createThing(T_SCENERY,G_RANDOM(6)+1,TRIBE_HOSTBOT,me_to_c3d(me),false,false)
        end
      end
    end
  end
end

local function spawn_wild_in_devils_style(c3d)
  local r = G_RANDOM(4)
  local new_c3d = Coord3D.new()
  new_c3d.Xpos = c3d.Xpos
  new_c3d.Zpos = c3d.Zpos
  if (r==0) then
    new_c3d.Xpos = new_c3d.Xpos-512
    new_c3d.Zpos = new_c3d.Zpos-512
  elseif(r==1) then
    new_c3d.Xpos = new_c3d.Xpos+512
    new_c3d.Zpos = new_c3d.Zpos-512
  elseif(r==2) then
    new_c3d.Xpos = new_c3d.Xpos-512
    new_c3d.Zpos = new_c3d.Zpos+512
  elseif(r==3) then
    new_c3d.Xpos = new_c3d.Xpos+512
    new_c3d.Zpos = new_c3d.Zpos+512
  end

  centre_coord3d_on_block(new_c3d)
  local wild = createThing(T_PERSON,M_PERSON_WILD,TRIBE_HOSTBOT,new_c3d,false,false)
  set_person_new_state(wild,S_PERSON_STAND_FOR_TIME)
end

local function check_for_wild_spawn_coast(me,r,amount)
  local limit = amount
  if (states.checkRandomWild) then
    limit = G_RANDOM(limit)+1
  end
  local buffer = {}
  local mapXZ = MapPosXZ.new()
  mapXZ.Pos = MAP_ELEM_PTR_2_IDX(me)
  mapXZ.XZ.X = mapXZ.XZ.X-(r+1)
  mapXZ.XZ.Z = mapXZ.XZ.Z-(r+1)
  local x = 0
  local z = 0
  for i=0,r+1 do
    x = mapXZ.XZ.X + i*2
    for i=0,r+1 do
      z = mapXZ.XZ.Z + i*2
      local me = xz_to_me(x,z)
      if (is_map_elem_all_land(me) == 1) then
        table.insert(buffer,me)
      end
    end
  end

  for i=0,limit do
    local me = buffer[G_RANDOM(#buffer)+1]
    if (me.MapWhoList:isEmpty()) then
      if (limit > 0) then
        limit=limit-1
        local c3d = me_to_c3d(me)
        centre_coord3d_on_block(c3d)
        local wild = createThing(T_PERSON,M_PERSON_WILD,TRIBE_HOSTBOT,c3d,false,false)
        set_person_new_state(wild,S_PERSON_STAND_FOR_TIME)
      end
    end
  end
end

local function check_for_wild_spawn_land(me)
  if (me.MapWhoList:isEmpty()) then
    if (me.Alt > variables.heightMin and me.Alt < variables.heightMax) then
      local c3d = me_to_c3d(me)
      centre_coord3d_on_block(c3d)
      local wild = createThing(T_PERSON,M_PERSON_WILD,TRIBE_HOSTBOT,c3d,false,false)
      set_person_new_state(wild,S_PERSON_STAND_FOR_TIME)
    end
  end
end

local function area_check_for_spawn_req(elem,r)
  local mapXZ = MapPosXZ.new()
  mapXZ.Pos = MAP_ELEM_PTR_2_IDX(elem)
  mapXZ.XZ.X = mapXZ.XZ.X-(r+1)
  mapXZ.XZ.Z = mapXZ.XZ.Z-(r+1)
  local x = 0
  local z = 0
  local count = 0
  for i=0,r+1 do
    x = mapXZ.XZ.X + i*2
    for i=0,r+1 do
      z = mapXZ.XZ.Z + i*2
      local me = xz_to_me(x,z)

      if (not me.MapWhoList:isEmpty()) then
        me.MapWhoList:processList(function(t)
          if (t.Type == T_SCENERY) then
            if (t.Model > 6) then
              count=count+1
            end
          end
          if (t.Type == T_SHAPE or t.Type == T_BUILDING) then
            count=count+1
          end
          return true
        end)
      end

      if (not me.ShapeOrBldgIdx:isNull()) then
        count=count+1
      end
    end
  end

  return count
end

local function check_for_spawn_tree(me)
  --run through checks before actually spawning
  --is spot free?
  if (states.checkOverlap) then
    if (not me.MapWhoList:isEmpty()) then
      do return end
    end
  end
  --is spot walkable?
  if (states.checkCliff) then
    if (is_point_steeper_than(me_to_c2d(me),384) ~= 0) then
      do return end
    end
  end
  --is spot obstacle free around?
  if (states.checkObstacles) then
    if (area_check_for_spawn_req(me,2) ~= 0) then
      do return end
    end
  end
  --spawn tree
  createThing(T_SCENERY,G_RANDOM(6)+1,TRIBE_HOSTBOT,me_to_c3d(me),false,false)
  tree_density_spawn(me,3)
end

function OnKeyDown(k)
  if (k == LB_KEY_O) then
    show_maptools_window = not show_maptools_window
  end
  if (k == LB_KEY_I) then
    show_mapinfo_window = not show_mapinfo_window
  end
end

function OnImGuiFrame()
  if (show_mapinfo_window) then
    imgui.Begin('Map Info',nil,ImGuiWindowFlags_AlwaysAutoResize)
    if (imgui.TreeNode("Player Info")) then
      for i=0,7 do
        imgui.TextUnformatted(pl_str[i+1] .. ": " .. gs.Players[i].NumPeople)
      end

      imgui.TreePop()
    end

    if (imgui.TreeNode("Object Info")) then
      imgui.TextUnformatted("Wilds: " .. mapinfo_vars.wildCount)
      imgui.TextUnformatted("Trees: " .. mapinfo_vars.treesCount)
      imgui.TextUnformatted("Triggers: " .. mapinfo_vars.triggerCount)
      imgui.TextUnformatted("Stone Heads: " .. mapinfo_vars.headsCount)
      imgui.TextUnformatted("Vaults: " .. mapinfo_vars.vaultsCount)

      imgui.TreePop()
    end

    if (imgui.TreeNode("World Mass")) then
      imgui.TextUnformatted(string.format("Water: %.2f",(world_mass.water*100)/16384) .. "%")
      imgui.TextUnformatted(string.format("Coast: %.2f",(world_mass.coast*100)/16384) .. "%")
      imgui.TextUnformatted(string.format("Land: %.2f",(world_mass.land*100)/16384) .. "%")

      imgui.TreePop()
    end
    imgui.End()
  end
  if (show_maptools_window) then
    imgui.Begin('Map Tools',nil,ImGuiWindowFlags_AlwaysAutoResize)
    --Calculate ME
    if (imgui.Button('Recalculate Mass')) then
      log("Calculating mass of the world")
      log("Coast count: " .. calc_coast_part())
      log("Water count: " .. calc_water_part())
      log("Land count: " .. calc_land_part())
    end
    imgui.SameLine()
    --Generate Trees
    if (imgui.Button('Generate Trees')) then
      log("Generating trees...")
      local count = 0
      for i,me in ipairs(world_ptrs.land_ptrs) do
        if (is_map_elem_all_land(me) == 1) then
          if (G_RANDOM(200) < variables.treePercent) then
            if (me.Alt > variables.heightMin and me.Alt < variables.heightMax) then
              check_for_spawn_tree(me)
              count=count+1
            end
          end
        end
      end

      log("Generated: " .. count .. " trees!")
    end
    imgui.SameLine()
    --Purge Trees
    if (imgui.Button('Purge Trees')) then
      log("Wiping out trees from existence...")
      ProcessGlobalSpecialList(TRIBE_HOSTBOT, WOODLIST, function(t)
        if (t.Model <= 6) then
          DestroyThing(t)
        end

        return true
      end)
    end
    imgui.PushItemWidth(125)
    --Height Min
    sliders.heightMin[1], sliders.heightMin[2] = imgui.SliderInt("Height Min",sliders.heightMin[2],1,1152,tostring(sliders.heightMin[2]))
    if (sliders.heightMin[1]) then
      variables.heightMin = tonumber(string.format("%.0f",sliders.heightMin[2]))
    end
    imgui.SameLine()
    --Height Max
    sliders.heightMax[1], sliders.heightMax[2] = imgui.SliderInt("Height Max",sliders.heightMax[2],1,1152,tostring(sliders.heightMax[2]))
    if (sliders.heightMax[1]) then
      variables.heightMax = tonumber(string.format("%.0f",sliders.heightMax[2]))
    end
    imgui.PopItemWidth()
    imgui.PushItemWidth(250)
    --Trees Percent
    sliders.treePercent[1], sliders.treePercent[2] = imgui.SliderInt("Tree Percent",sliders.treePercent[2],1,100,tostring(sliders.treePercent[2]))
    if (sliders.treePercent[1]) then
      variables.treePercent = tonumber(string.format("%.0f",sliders.treePercent[2]))
    end
    --Trees Density
    sliders.treeDensity[1], sliders.treeDensity[2] = imgui.SliderInt("Tree Density",sliders.treeDensity[2],0,50,tostring(sliders.treeDensity[2]))
    if (sliders.treeDensity[1]) then
      variables.treeDensity = tonumber(string.format("%.0f",sliders.treeDensity[2]))
    end
    imgui.PopItemWidth()
    --Generate Wilds
    if (imgui.Button('Generate Wilds')) then
      log("Generating Wilds, ooh")
      if (radios.wildMethodGen[2] == 0) then
        for i,k in ipairs(world_ptrs.coast_ptrs) do
          if (variables.wildChance > G_RANDOM(200)) then
            check_for_wild_spawn_coast(k,5,variables.wildAmount)
          end
        end
      elseif (radios.wildMethodGen[2] == 1) then
        for i,k in ipairs(world_ptrs.land_ptrs) do
          if (variables.wildChance > G_RANDOM(200)) then
            check_for_wild_spawn_land(k)
          end
        end
      elseif (radios.wildMethodGen[2] == 2) then
        ProcessGlobalSpecialList(TRIBE_HOSTBOT, WOODLIST, function(t)
          if (t.Model <= 6) then
            if (variables.wildChance > G_RANDOM(100)) then
              check_for_wild_spawn_coast(world_coord3d_to_map_ptr(t.Pos.D3),5,variables.wildAmount)
            end
          end

          return true
        end)
      elseif (radios.wildMethodGen[2] == 3) then
        ProcessGlobalSpecialList(TRIBE_HOSTBOT, WOODLIST, function(t)
          if (t.Model <= 6) then
            spawn_wild_in_devils_style(t.Pos.D3)
          end

          return true
        end)
      end
    end
    imgui.SameLine()
    --Purge Wilds
    if (imgui.Button('Purge Wilds')) then
      ProcessGlobalSpecialList(TRIBE_HOSTBOT, WILDLIST, function(t)
        DestroyThing(t)
        return true
      end)

      log("You cruel...")
    end
    imgui.PushItemWidth(125)
    --Wild Chance
    sliders.wildChance[1], sliders.wildChance[2] = imgui.SliderInt("Wild Chance",sliders.wildChance[2],1,100,tostring(sliders.wildChance[2]))
    if (sliders.wildChance[1]) then
      variables.wildChance = tonumber(string.format("%.0f",sliders.wildChance[2]))
    end
    imgui.SameLine()
    --Wild Amount
    sliders.wildAmount[1], sliders.wildAmount[2] = imgui.SliderInt("Wild Amount",sliders.wildAmount[2],1,10,tostring(sliders.wildAmount[2]))
    if (sliders.wildAmount[1]) then
      variables.wildAmount = tonumber(string.format("%.0f",sliders.wildAmount[2]))
    end
    imgui.PopItemWidth()
    --Wilds Gen Methods
    imgui.TextUnformatted('Wildmen generating method')
    if (imgui.RadioButton("Coast",radios.wildMethodGen[2] == 0)) then radios.wildMethodGen[2] = 0 end imgui.SameLine()
    if (imgui.RadioButton("Ground",radios.wildMethodGen[2] == 1)) then radios.wildMethodGen[2] = 1 end imgui.SameLine()
    if (imgui.RadioButton("Trees",radios.wildMethodGen[2] == 2)) then radios.wildMethodGen[2] = 2 end imgui.SameLine()
    if (imgui.RadioButton("Devil's",radios.wildMethodGen[2] == 3)) then radios.wildMethodGen[2] = 3 end
    --Flags Section
    imgui.TextUnformatted("Generator Flags")
    --Check Random Wild Amount
    check_boxes.checkRandomWild[1], check_boxes.checkRandomWild[2] = imgui.Checkbox("Randomize Wilds", check_boxes.checkRandomWild[2])
    if (check_boxes.checkRandomWild[1]) then
      states.checkRandomWild = check_boxes.checkRandomWild[2]
      log("Check box state changed!" .. tostring(states.checkRandomWild))
    end
    imgui.SameLine()
    --Check Cliff
    check_boxes.checkCliff[1], check_boxes.checkCliff[2] = imgui.Checkbox("Check Cliff", check_boxes.checkCliff[2])
    if (check_boxes.checkCliff[1]) then
      states.checkCliff = check_boxes.checkCliff[2]
      log("Check box state changed!" .. tostring(states.checkCliff))
    end
    imgui.SameLine()
    --Check Obstacles
    check_boxes.checkObstacles[1], check_boxes.checkObstacles[2] = imgui.Checkbox("Check Obstacles", check_boxes.checkObstacles[2])
    if (check_boxes.checkObstacles[1]) then
      states.checkObstacles = check_boxes.checkObstacles[2]
      log("Check box state changed!" .. tostring(states.checkObstacles))
    end
    --Check Overlap
    check_boxes.checkOverlap[1], check_boxes.checkOverlap[2] = imgui.Checkbox("Check Overlap", check_boxes.checkOverlap[2])
    if (check_boxes.checkOverlap[1]) then
      states.checkOverlap = check_boxes.checkOverlap[2]
      log("Check box state changed!" .. tostring(states.checkOverlap))
    end
    imgui.End()
  end
end

--pre calc percentages
world_mass.water = calc_water_part()
world_mass.coast = calc_coast_part()
world_mass.land = calc_land_part()

function OnTurn()
  if (show_mapinfo_window) then --save cpu
    if (gs.Counts.GameTurn % 12 == 0) then
      mapinfo_vars.totalPop = calc_total_pop()
      mapinfo_vars.vaultsCount = calc_objects_of_model(T_BUILDING,M_BUILDING_LIBRARY)
      mapinfo_vars.headsCount = calc_objects_of_model(T_SCENERY,M_SCENERY_HEAD)
      mapinfo_vars.triggerCount = calc_objects_of_model(T_GENERAL,M_GENERAL_TRIGGER)
      mapinfo_vars.wildCount = calc_objects_of_model(T_PERSON,M_PERSON_WILD)
      mapinfo_vars.treesCount = calc_trees()
    end
  end
end

--output percentages
log("Percentages: " .. "\n Water: " .. string.format("%.2f",(world_mass.water*100)/16384) .. "\n Coast: " .. string.format("%.2f",(world_mass.coast*100)/16384) .. "\n Land: " .. string.format("%.2f",(world_mass.land*100)/16384))

log_msg(TRIBE_HOSTBOT,"MapTools has been loaded! \n Press O to open tool menu. \n Press I to open info menu.")
