import(Module_Players)
import(Module_Defines)
import(Module_DataTypes)
import(Module_Globals)
import(Module_System)

gs = gsi()

for i=0,MAX_NUM_REAL_PLAYERS-1 do
  gs.Players[i].PlayerType = HUMAN_PLAYER
end

log("All players became human controlled")
exit()