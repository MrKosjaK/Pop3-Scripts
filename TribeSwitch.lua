import(Module_DataTypes)
import(Module_Defines)
import(Module_Game)
import(Module_Globals)
import(Module_ImGui)
import(Module_Players)
import(Module_System)
import(Module_Table)

local gs = gsi()
local gns = gnsi()
local player_types = {"Computer","Player"}
local tribe_names = {"Blue","Red","Yellow","Green","Cyan","Purple","Black","Orange"}
local available_tribes = {}
local curr_tribe = 0

local function check_for_tribes()
  for i=0,MAX_NUM_REAL_PLAYERS-1 do
    if (gs.Players[i].DeadCount == 0) then
      table.insert(available_tribes,i)
    end
  end
end

local function switch_tribe(curr_pn,new_pn)
  gns.PlayerNum = new_pn
end

local function switch_type(pn)
  if (pn ~= 0) then
    if (gs.Players[pn].PlayerType == COMPUTER_PLAYER) then
      gs.Players[pn].PlayerType = HUMAN_PLAYER
    else
      gs.Players[pn].PlayerType = COMPUTER_PLAYER
      computer_init_player(gs.Players[pn])
    end
  else
    log_msg(TRIBE_HOSTBOT,"Can't switch Blue's tribe type.")
  end
end

check_for_tribes()

function OnImGuiFrame()
  imgui.Begin('Tribe Switcher',nil,ImGuiWindowFlags_AlwaysAutoResize)
  imgui.TextUnformatted('Pick the tribe you want to view.')
  for i,k in ipairs(available_tribes) do
    if (imgui.RadioButton(tostring(tribe_names[k+1]),curr_tribe == k)) then switch_tribe(curr_tribe,k) curr_tribe = k end imgui.SameLine()
  end
  imgui.NewLine()
  if (imgui.Button('Switch Type')) then
    switch_type(curr_tribe)
  end
  imgui.SameLine()
  if (gs.Players[curr_tribe].PlayerType ~= 0) then
    imgui.TextUnformatted('Type: ' .. player_types[gs.Players[curr_tribe].PlayerType])
  end
  imgui.End()
end

log("Switcher is loaded!")