import(Module_Globals)
import(Module_Helpers)
import(Module_Defines)
import(Module_DataTypes)
import(Module_System)

_gnsi = gnsi()

function enable_flag(_f1,_f2)
    if (_f1 & _f2 == 0) then
        _f1 = _f1 | _f2
    end
    
    return _f1
end

function disable_flag(_f1,_f2)
    if (_f1 & _f2 == _f2) then
        _f1 = _f1 ~ _f2
    end
    
    return _f1
end

_gnsi.GameParams.Flags2 = enable_flag(_gnsi.GameParams.Flags2,GPF2_GAME_NO_WIN)
_gnsi.Flags = disable_flag(_gnsi.Flags,GNS_LEVEL_COMPLETE)
_gnsi.Flags = disable_flag(_gnsi.Flags,GNS_LEVEL_FAILED)

log("Disabled win/loss states!")
exit()