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
    plr.totalkills = 0
    plr.mult = 1.00
    plr.expN = math.floor((100*plr.mult) * plr.level)
    
    function plr:check_if_enough_exp()
      if (plr.exp > plr.expN) then
        plr.mult = plr.mult + 0.02
        plr.exp = 0
        plr.level = plr.level+1
        plr.expN = math.ceil((100^plr.mult))
        log_msg(TRIBE_NEUTRAL, "Player " .. plr.mynum .. " has just achieved " .. plr.level .. " level!")
      end
    end
    
    function plr:calc_exp_from_kills()
      local kills = 0
      
      for i = 0,MAX_NUM_REAL_PLAYERS-1 do
        if (i ~= plr.mynum) then
          kills = kills + _gsi.Players[plr.mynum].PeopleKilled[i]
        end
      end
      
      if (kills > plr.totalkills) then
        local to_add = kills - plr.totalkills
        plr:increment_exp(to_add*2)
        plr.totalkills = plr.totalkills + to_add
      end
    end
    
    function plr:boost_me()
      mana_to_give = math.ceil(plr.mult*5)
      _gsi.Players[plr.mynum].Mana = _gsi.Players[plr.mynum].Mana + mana_to_give
    end
    
    function plr:get_pn()
      return plr.mynum
    end
    
    function plr:get_mult()
      return plr.mult
    end
    
    function plr:get_mana_boost()
      return math.ceil(plr.mult*5)
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
    local this_player = IPlayer.register(i)
    table.insert(players, this_player)
end

function OnTurn()
  if (EVERY_2POW_TURNS(1)) then
    for i in ipairs (players) do
      players[i]:check_if_enough_exp()
      players[i]:calc_exp_from_kills()
      players[i]:boost_me()
    end
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
  for i in ipairs (players) do
    if (_gsi.Players[players[i]:get_pn()].NumPeople ~= 0) then
      LbDraw_PropText(math.floor(ScreenWidth()/6),math.floor((ScreenHeight()/5))+i*16, "" .. players[i]:get_exp(), COLOUR(CLR_RED))
      LbDraw_PropText(math.floor(ScreenWidth()/6+48),(math.floor(ScreenHeight()/5))+i*16, "" .. players[i]:get_exp_next(), COLOUR(CLR_GREEN))
      LbDraw_PropText(math.floor(ScreenWidth()/6+30),(math.floor(ScreenHeight()/5))+i*16, "" .. players[i]:get_mana_boost(), COLOUR(CLR_GREEN))
    end
  end
end