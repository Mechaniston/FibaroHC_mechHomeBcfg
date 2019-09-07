--[[
%% autostart
%% properties
%% globals
--]]


local debugMode = true;

fibaro:sleep(50); -- to prevent to kill all instances
if ( fibaro:countScenes() > 1 ) then
  if ( debugMode ) then fibaro:debug("Double start"
    .. " (" .. tostring(fibaro:countScenes()) .. ").. Abort dup!"); end
  fibaro:abort();
end

if ( debugMode ) then fibaro:debug("START process!"); end

while true do
  
  local currentTime = os.date("*t");
  --local hallSensState, hallSensDT = fibaro:get(236, "value"); -- К:Сенсор
  
  local timeToMoveBlinds = false;
  
  fibaro:debug(currentTime.hour);
  fibaro:debug(currentTime.wday);
  if 
    ( (fibaro:getValue(42, "value") ~= "0")
      and (fibaro:getValue(42, "dead") == "0")
  	  and (fibaro:getGlobalValue("twilightMode") == "1") )
    or
    ( currentTime.hour >= 20 ) then
    
    if ( debugMode ) then
      fibaro:debug(fibaro:getGlobalValue("blindsMidPos"));
      fibaro:debug(fibaro:getGlobalValue("blindsSidPos"));
      fibaro:debug(fibaro:getGlobalValue("twilightMode"));
      fibaro:debug(fibaro:getValue(42, "value"));
    end
    
    if ( tonumber(fibaro:getGlobalValue("blindsMidPos")) >= tonumber("50") )
    then
      --fibaro:call(189, "setSlider", "1", "0"); --cause dont work :((
	  fibaro:call(189, "setProperty", "ui.Slider2.value", "0");
      fibaro:debug("Time is to close Mid blinds!");
      timeToMoveBlinds = true;
    end
    
    if ( tonumber(fibaro:getGlobalValue("blindsSidPos")) >= tonumber("50") )
    then
      --fibaro:call(189, "setSlider", "2", "0"); --cause dont work :((
      fibaro:call(189, "setProperty", "ui.Slider3.value", "0");
      fibaro:debug("Time is to close Sides blinds!");
      timeToMoveBlinds = true;
    end
    
  elseif ( (currentTime.hour >= 9) and (currentTime.hour < 18)
      and (currentTime.wday == 1) and (currentTime.wday == 7) )
    or ( (currentTime.hour >= 13 ) and (currentTime.hour < 18)
      and (currentTime.wday > 1) and ( currentTime.wday < 7) ) then
    
    if ( tonumber(fibaro:getGlobalValue("blindsMidPos")) < tonumber("50") )
    then
      fibaro:call(189, "setSlider", "1", "50");
      fibaro:debug("Time is to open Mid blinds!");
      timeToMoveBlinds = true;
    end
    
    if ( tonumber(fibaro:getGlobalValue("blindsSidPos")) < tonumber("50") )
    then
      fibaro:call(189, "setSlider", "2", "50");
      fibaro:debug("Time is to open Sides blinds!");
      timeToMoveBlinds = true;
    end
    
  end

  if ( timeToMoveBlinds ) then
    fibaro:sleep(1000);
    fibaro:debug("MOVE BLINDS!");
    fibaro:startScene(200);
    --fibaro:call(189, "pressButton", "3");
    
    if ( currentTime.hour >= 20 ) then
      fibaro:debug("Long sleep (12 hrs)..");
      fibaro:sleep(12 * 60 * 60 * 1000);
    elseif ( currentTime.hour <= 13 ) then
      fibaro:debug("Long sleep (7 hrs)..");
      fibaro:sleep(7 * 60 * 60 * 1000);
    end
  end

 -- fibaro:debug("Sleep for 5 min");
  
  fibaro:sleep(5 * 60 * 1000);

end

if ( debugMode ) then fibaro:debug("END process!"); end
