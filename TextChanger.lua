import(Module_Level)
import(Module_String)
import(Module_StringTools)
import(Module_Game)

function OnChat(from,msg)
  if (msg:sub(1,1) == "!") then
    local tokens = StringTokenizer(msg, " ", 1)
    if (#tokens > 1) then
      if (tokens[0] == "!texture") then
        if (tonumber(tokens[1]) ~= nil) then
          if (tonumber(tokens[1]) < 9223372036854775807 and tonumber(tokens[1]) > -9223372036854775807) then
            set_level_type(tonumber(tokens[1]))
          else
            log_msg(8, "Incorrect value size, please, use values between 0 and 35")
          end
        else
          log_msg(8, "Incorrect argument, please, use a numeric value")
        end
      end
    end
  end
end