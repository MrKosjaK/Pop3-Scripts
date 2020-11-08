import(Module_ImGui)
import(Module_Globals)
import(Module_Defines)
import(Module_Objects)
import(Module_DataTypes)
import(Module_Players)
import(Module_String)
import(Module_Game)
import(Module_Level)
import(Module_System)

local gs = gsi()
local gns = gnsi()
local pNames = {
  "Blue",
  "Red",
  "Yellow",
  "Green",
  "Cyan",
  "Magenta",
  "Black",
  "Orange"
}

players = {
  total_mana = {0,0,0,0,0,0,0,0},
  spells_used = {0,0,0,0,0,0,0,0}
}

local function players_get_training_state(_player)

end

local function players_get_mana_gen(_player)
  return gs.Players[_player].LastManaIncr
end

local function players_get_Mps(_player)
  return gs.Players[_player].LastManaIncr*3
end

local function short_number(n)
    if n >= 10^6 then
        return string.format("%.2fM", n / 10^6)
    elseif n >= 10^3 then
        return string.format("%.2fK", n / 10^3)
    else
        return tostring(n)
    end
end

function OnTurn()
  if (gs.Counts.GameTurn % 4 == 0) then
    for i=0,7 do
      if (gs.Players[i].DeadCount == 0) then
        players.total_mana[i+1] = players.total_mana[i+1]+players_get_mana_gen(i)
      end
    end
  end
end

function OnCreateThing(t)
  if (t.Type == T_SPELL) then
    players.spells_used[t.Owner+1] = players.spells_used[t.Owner+1]+1
  end
end

function OnImGuiFrame()
  imgui.Begin('Mana Stats', nil, ImGuiWindowFlags_AlwaysAutoResize)
  imgui.Columns(6, "Stats")
  imgui.TextUnformatted("Player")
	imgui.NextColumn()
  imgui.TextUnformatted("Total Mana")
	imgui.NextColumn()
  imgui.TextUnformatted("M/ps")
	imgui.NextColumn()
  imgui.TextUnformatted("Spells Used")
	imgui.NextColumn()
  imgui.TextUnformatted("OptimalManaIncome")
	imgui.NextColumn()
	imgui.TextUnformatted("LastManaIncr")
	imgui.Separator()
	imgui.NextColumn()
  
  for i=0,7 do
    if (gs.Players[i].DeadCount == 0) then
      imgui.TextUnformatted(pNames[i+1])
      imgui.NextColumn()
      imgui.TextUnformatted(short_number(players.total_mana[i+1]))
      imgui.NextColumn()
      imgui.TextUnformatted(short_number(players_get_Mps(i)))
      imgui.NextColumn()
      imgui.TextUnformatted(players.spells_used[i+1])
      imgui.NextColumn()
      imgui.TextUnformatted(gs.Players[i].OptimalManaIncome)
      imgui.NextColumn()
      imgui.TextUnformatted(gs.Players[i].LastManaIncr)
      imgui.NextColumn()
    end
  end
  
  imgui.End()
end