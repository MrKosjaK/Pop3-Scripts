import(Module_Draw);
import(Module_Math);
import(Module_String);
import(Module_DataTypes);
import(Module_Table);
import(Module_System);

Timer = {};
Timer.__index = Timer;

TIMER_JUST_LEFT = 0;
TIMER_JUST_CENTER = 1;
TIMER_JUST_RIGHT = 2;

function Timer:create(_a)
  local self = setmetatable({}, Timer);

  self.Ticks = _a or 720;
  self.BaseTicks = _a or 720;
  self.XPad = 0;
  self.YPad = 0;
  self.XPos = 0;
  self.YPos = 0;
  self.TextJustification = 0;
  self.Display = true;
  self.Looped = false;
  self.LoopAmount = 0;
  self.FuncTrigger = nil;
  self.Font = 4;

  return self;
end

function Timer:setPosition(_x, _y)
  assert(type(_x) == "number", "Input value isn't a number ");
  assert(type(_y) == "number", "Input value isn't a number ");
  self.XPos = _x or 0;
  self.YPos = _y or 0;
end

function Timer:setPadding(_x, _y)
  assert(type(_x) == "number", "Input value isn't a number ");
  assert(type(_y) == "number", "Input value isn't a number ");
  self.XPad = _x or 0;
  self.YPad = _y or 0;
end

function Timer:setTrigger(_a)
  assert(type(_a) == "function", "Input argument isn't a function ");
  self.FuncTrigger = _a;
end

function Timer:setSmallFont()
  self.Font = 4;
end

function Timer:setMediumFont()
  self.Font = 3;
end

function Timer:setLargeFont()
  self.Font = 9;
end

function Timer:setLoop(_a)
  assert(type(_a) == "boolean", "Input value isn't a boolean ");
  self.Looped = _a or false;
end

function Timer:setLoopAmount(_a)
  assert(type(_a) == "number", "Input value isn't a number ");
  self.LoopAmount = _a or -1;
end

function Timer:hasReachedZero()
  return (self.Ticks == 0);
end

function Timer:hide()
  self.Display = false;
end

function Timer:show()
  self.Display = true;
end

function Timer:setJustification(_a)
  assert(type(_a) == "number", "Input valut isn't a number, please use 0, 1 or 2 ");
  self.TextJustification = _a;
end

function Timer:tick()
  if (self.Ticks > 0) then
    self.Ticks = self.Ticks - 1;
  elseif (self.FuncTrigger ~= nil) then

    if (not self.Looped) then
      self.FuncTrigger();
      self.FuncTrigger = nil;
    else
      if (self.LoopAmount == -1) then
        self.Ticks = self.BaseTicks - 1;
        self.FuncTrigger();
      elseif (self.LoopAmount > 0) then
        self.Ticks = self.BaseTicks - 1;
        self.FuncTrigger();
        self.LoopAmount = self.LoopAmount - 1;
      end
    end
  end
end

function Timer:render()
  if (self.Display) then
    PopSetFont(self.Font);
    local seconds = self.Ticks/12;
    local hours = math.floor(seconds/3600);
    local mins = math.floor(seconds/60 - (hours*60));
    local secs = math.floor(seconds - hours*3600 - mins *60);
    local justification = 0;
    local str = string.format("%.02i:%.02i:%.02i", hours, mins, secs);
    if (self.TextJustification == 1) then
      justification = math.floor(string_width(str) / 2);
    elseif (self.TextJustification == 2) then
      justification = string_width(str);
    end
    LbDraw_Text((self.XPos) - self.XPad - justification, (self.YPos) - self.YPad, str, 0);
  end
end
