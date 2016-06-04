--[[
%% autostart
%% properties
42 value
%% globals
twilightMode
--]]

fibaro:debug(fibaro:getGlobalValue("blindsMidPos"));
fibaro:debug(fibaro:getGlobalValue("blindsSidesPos"));
fibaro:debug(fibaro:getGlobalValue("twilightMode"));
fibaro:debug(fibaro:getValue(42, "value"));

local timeToCloseBlinds = false;

if (tonumber(fibaro:getValue(42, "value")) > 1)
  	and (fibaro:getGlobalValue("twilightMode") == "1")
then
  if tonumber(fibaro:getGlobalValue("blindsMidPos")) >= tonumber("50")
  then
    fibaro:call(189, "setSlider", "1", "0");
    fibaro:debug("Time is to close Mid blinds!");
    timeToCloseBlinds = true;
  end;
  if tonumber(fibaro:getGlobalValue("blindsSidesPos")) >= tonumber("50")
  then
    fibaro:call(189, "setSlider", "2", "0");
    fibaro:debug("Time is to close Sides blinds!");
    timeToCloseBlinds = true;
  end;
  
  if timeToCloseBlinds
  then
    fibaro:startScene(200);
    --fibaro:call(189, "pressButton", "3");
  end
end
