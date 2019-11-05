import(Module_Draw)
import(Module_Defines)
import(Module_DataTypes)
import(Module_Objects)
import(Module_Globals)
import(Module_Players)
import(Module_Math)

_gsi = gsi()

announceTicks = 0
announceTicksDelay = 180
announceDelay = 240
announceInterval = _gsi.Counts.GameTurn + (12*announceDelay)
playerPeople = {0,0,0,0,0,0,0,0}
playerNames = {"BLUE","RED","YELLOW","GREEN","CYAN","MAGENTA","BLACK","ORANGE"}

function OnTurn()
  if (_gsi.Counts.GameTurn > announceInterval) then
    announceTicks = announceTicksDelay
    announceInterval = _gsi.Counts.GameTurn + (12*announceDelay)
    
    for i = 0,MAX_NUM_REAL_PLAYERS-1 do
      playerPeople[i+1] = _gsi.Players[i].NumPeople
    end
  end
  
  if (announceTicks > 0) then
    announceTicks = announceTicks-1
  end
end

function OnFrame()
  if (announceTicks > 0) then
    for i = 0,MAX_NUM_REAL_PLAYERS-1 do
      if (playerPeople[i+1] ~= 0) then
        LbDraw_PropText(math.floor(ScreenWidth()/6),math.floor((ScreenHeight()/5))+i*16, "" .. playerNames[i+1], COLOUR(CLR_RED))
        LbDraw_PropText(math.floor(ScreenWidth()/6+48),(math.floor(ScreenHeight()/5))+i*16, "" .. playerPeople[i+1], COLOUR(CLR_PINK))
      else
        LbDraw_PropText(math.floor(ScreenWidth()/6),(math.floor(ScreenHeight()/5))+i*16, "PLAYER IS DEAD!", COLOUR(CLR_RED))
      end
    end
  end
end