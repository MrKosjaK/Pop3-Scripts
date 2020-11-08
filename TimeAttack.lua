import(Module_Globals)
import(Module_Game)
import(Module_DataTypes)

local gs = gsi()
local gns = gnsi()

--Close if used in multiplayer
if (gns.Flags & (1<<3) ~= 0) then
  exit()
end

local record = 0
local has_player_got_other_state = false

local get_turn = function() return gs.Counts.ProcessThings end

function OnTurn()
  local turn = get_turn()

  if (not has_player_got_other_state) then
    if (gns.Flags & (1<<25) == 0 and gns.Flags & (1<<26) == 0) then
      record = turn
    else
      has_player_got_other_state = true
      log_msg(8,"Your record is: " .. record .. " Turns. Congratulations!")
    end
  end
end
