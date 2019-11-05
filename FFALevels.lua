import(Module_Game)
import(Module_DataTypes)
import(Module_Table)
import(Module_Math)

IPlayer = {}
IPlayer.register = function()

    local plr = {}
    
    plr.level = 1
    plr.exp = 0
    plr.mult = 1.00
    plr.expN = math.floor(20 + (plr.level*plr.mult))
    
    function plr:get_exp()
      return plr.exp
    end
    
    return plr;
end

local blue = IPlayer.register()
notify_user("" .. blue:get_exp())