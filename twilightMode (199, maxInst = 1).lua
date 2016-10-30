--[[
%% autostart
%% properties
%% globals
--]]

local debugMode = true;
local debugModeDetail = false;

-----

if ( fibaro:getSourceTrigger()["type"] == "other" ) then
  if ( tonumber(fibaro:getGlobalValue("twilightMode")) == 1 ) then
    fibaro:setGlobal("twilightMode", "0");
  else
	fibaro:setGlobal("twilightMode", "1");
  end
end

fibaro:sleep(50); -- to prevent to kill all instances
if ( fibaro:countScenes() > 1 ) then
  if ( debugMode ) then fibaro:debug("Double start"
    .. "(" .. tostring(fibaro:countScenes()) .. ").. Abort dup!"); end
  fibaro:abort();
end

while true do
  --if (math.floor(os.time() / 60) - math.floor(1438635600 / 60)) % 5 == 0
  -- every 5 minute
  
  local offsetHour = 1;
  
  if ( fibaro:getValue(3, "WeatherConditionConverted") == "cloudy" ) then
    offsetHour = offsetHour + 1;
    
    if debugModeDetail then fibaro:debug("WeatherConditions is cloudy"); end
  elseif (
      ( fibaro:getValue(3, "WeatherConditionConverted") == "rain" )
      or
      ( fibaro:getValue(3, "WeatherConditionConverted") == "snow" )
      or
      ( fibaro:getValue(3, "WeatherConditionConverted") == "storm" )
    ) then
    offsetHour = offsetHour + 2;
    
    if debugModeDetail then fibaro:debug("WeatherConditions is poor"); end
  end
  
  local currentTime = os.date("*t");
  local currentMinutes = (currentTime.hour) * 60 + currentTime.min;
  
  if debugModeDetail then
    fibaro:debug("curtime = "
  	.. string.format("%02d", currentTime.hour) .. ":"
  	.. string.format("%02d", currentTime.min)
    .. " (" .. currentMinutes .. " mins)");
  end
  
  local sunriseTime = fibaro:getValue(1, "sunriseHour");
  local sunriseMinutes = (tonumber(string.sub(sunriseTime, 1, 2))
    + (offsetHour - 1) / 4) * 60 + tonumber(string.sub(sunriseTime, 4));
  
  if debugModeDetail then
    fibaro:debug("sunrise = " .. sunriseTime .. " (" .. sunriseMinutes
      .. " mins with offset)");
  end
  
  local sunsetTime = fibaro:getValue(1, "sunsetHour");
  local sunsetMinutes = (tonumber(string.sub(sunsetTime, 1, 2))
    - offsetHour / 4) * 60 + tonumber(string.sub(sunsetTime, 4));
  
  if debugModeDetail then
    fibaro:debug("sunset = " .. sunsetTime .. " (" .. sunsetMinutes
      .. " mins with offset)");
  end
  
  if ( (currentMinutes <= sunriseMinutes)
    or (currentMinutes >= sunsetMinutes) ) then
    
    if ( fibaro:getGlobalValue("twilightMode") == "0" ) then
      fibaro:setGlobal("twilightMode", "1");
      
      if ( debugMode ) then fibaro:debug("twilightMode is ON!"); end
      
      --fibaro:call(2, "sendDefinedEmailNotification", "3");
      fibaro:call(52, "sendDefinedEmailNotification", "3");
    end
    
  elseif ( (currentMinutes > sunriseMinutes)
    and (currentMinutes < sunsetMinutes) ) then
    
    if ( fibaro:getGlobalValue("twilightMode") == "1" ) then
      fibaro:setGlobal("twilightMode", "0");
      
      if ( debugMode ) then fibaro:debug("twilightMode OFF!"); end
      
      --fibaro:call(2, "sendDefinedEmailNotification", "3");
      fibaro:call(52, "sendDefinedEmailNotification", "3");
    end
    
  end
        
  if ( currentMinutes <= sunriseMinutes ) then
    
    if ( (fibaro:getGlobalValue("twilightMode") == "1")
      and (currentMinutes >= 0 * 60 + 30) ) then -- HARDCODED 23:30 (UTC +4 instead 3)
      
      if ( fibaro:getGlobalValue("nightMode") == "0" ) then
        fibaro:setGlobal("nightMode", "1");
        
        if ( debugMode ) then fibaro:debug("nightMode ON!"); end
      end
      
    elseif ( (fibaro:getGlobalValue("twilightMode") == "0")
      or (currentMinutes >= 7 * 60) ) then -- HARDCODED 6:00 (UTC +4 instead 3)
      
      if ( fibaro:getGlobalValue("nightMode") == "1" ) then
        fibaro:setGlobal("nightMode", "0");
        
        if ( debugMode ) then fibaro:debug("nightMode OFF!"); end
      end
      
    end
    
  end
  
  fibaro:sleep(5 * 60 * 1000); -- 5 minutes
  
end
