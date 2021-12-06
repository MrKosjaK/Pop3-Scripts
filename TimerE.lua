import(Module_Game);

--Include lib
include("LbTimer.lua");

--Create timer
local my_clock = Timer:create(12 * 10);
my_clock:setPosition(ScreenWidth() - 128, 64);
my_clock:setLoop(true);
my_clock:setLoopAmount(5);
my_clock:setMediumFont();
my_clock:setJustification(TIMER_JUST_CENTER);
my_clock:setTrigger(function() log_msg(8, "Timer has triggered!") end); --Custom function callbacks

local my_clock2 = Timer:create(12 * 5);
my_clock2:setPosition(ScreenWidth() - 126, 96);
my_clock2:setLoop(true);
my_clock2:setLoopAmount(-1);
my_clock2:setSmallFont();
my_clock2:setJustification(TIMER_JUST_LEFT);
my_clock2:setTrigger(function() log_msg(8, "Another Timer has triggered!") end); --Custom function callbacks

local my_clock3 = Timer:create(12 * 15);
my_clock3:setPosition(ScreenWidth() - 130, 96);
my_clock3:setLoop(true);
my_clock3:setLoopAmount(-1);
my_clock3:setSmallFont();
my_clock3:setJustification(TIMER_JUST_RIGHT);
my_clock3:setTrigger(function() log_msg(8, "Yet another Timer has triggered!") end); --Custom function callbacks

function OnTurn()
  my_clock:tick(); --This is neccessary to run all your timers in OnTurn.
  my_clock2:tick();
  my_clock3:tick();
end

function OnFrame()
  my_clock:render(); --If you want timer to be displayed on screen, put that in OnFrame.
  my_clock2:render();
  my_clock3:render();
end
