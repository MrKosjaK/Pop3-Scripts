import(Module_Game)
import(Module_DataTypes)
import(Module_Table)
import(Module_Globals)
import(Module_Defines)
import(Module_Math)
import(Module_Draw)
import(Module_Players)
import(Module_Objects)

_gsi = gsi()
players = {}

IPlayer = {}
IPlayer.register = function(pn)

    local plr = {}
    
    plr.mynum = pn
    plr.level = 1
    plr.exp = 0
    plr.mult = 1.00
    plr.expN = math.floor((100*plr.mult) * plr.level)
    
    function plr:check_if_enough_exp()
      if (plr.exp > plr.expN) then
        plr.exp = 0
        plr.mult = plr.mult + 0.05
        plr.level = plr.level+1
        plr.expN = math.floor((100*plr.mult) * plr.level)
        log_msg(TRIBE_NEUTRAL, "Player " .. plr.mynum .. " has just achieved " .. plr.level .. " level!")
      end
    end
    
    function plr:get_mult()
      return plr.mult
    end
    
    function plr:get_exp()
      return plr.exp
    end
    
    function plr:get_exp_next()
      return plr.expN
    end
    
    function plr:get_left_exp()
      return plr.expN - plr.exp
    end
    
    function plr:increment_exp(num)
      plr.exp = plr.exp + num
    end
    
    return plr;
end

for i = 0,MAX_NUM_REAL_PLAYERS-1 do
  if (_gsi.Players[i].NumPeople ~= 0) then
    local this_player = IPlayer.register(i)
    table.insert(players, this_player)
  end
end

function OnTurn()
  if (EVERY_2POW_TURNS(2)) then
    players[G_RANDOM(4)+1]:increment_exp(G_RANDOM(50)+1)
    players[G_RANDOM(4)+1]:check_if_enough_exp()
  end
end

function OnCreateThing(t)
  if (t.Type == T_PERSON) then
    if (t.Model ~= M_PERSON_WILD and t.Model ~= M_PERSON_ANGEL) then
      t.u.Pers.MaxLife = math.floor(t.u.Pers.MaxLife * players[t.Owner+1]:get_mult())
      t.u.Pers.Life = t.u.Pers.MaxLife
    end
  end
end

function OnFrame()
  for i = 0,MAX_NUM_REAL_PLAYERS-1 do
    if (_gsi.Players[i].NumPeople ~= 0) then
      LbDraw_PropText(math.floor(ScreenWidth()/6),math.floor((ScreenHeight()/5))+i*16, "" .. players[i+1]:get_exp(), COLOUR(CLR_RED))
      LbDraw_PropText(math.floor(ScreenWidth()/6+48),(math.floor(ScreenHeight()/5))+i*16, "" .. players[i+1]:get_left_exp(), COLOUR(CLR_GREEN))
    end
  end
end
