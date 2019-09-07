--[[
%% autostart
%% properties
%% globals
--]]


local debugMode = true;
local debugModeDetail = false;

-----

fibaro:sleep(50); -- to prevent to kill all instances
if ( fibaro:countScenes() > 1 ) then
  if ( debugMode ) then fibaro:debug("Double start"
    .. "(" .. tostring(fibaro:countScenes()) .. ").. Abort dup!"); end
  fibaro:abort();
end

while true do
  --if (math.floor(os.time() / 60) - math.floor(1438635600 / 60)) % 5 == 0
  -- every 5 minute
  
  local offsetHour = 0;
  
  -- in early FHC2 verions the property was "WeatherConditionConverted"
  
  if ( fibaro:getValue(3, "WeatherCondition") == "cloudy" ) then
    offsetHour = offsetHour + 1;
    
    if ( debugModeDetail ) then fibaro:debug("WeatherConditions is cloudy"); end
  elseif (
      ( fibaro:getValue(3, "WeatherCondition") == "rain" )
      or
      ( fibaro:getValue(3, "WeatherCondition") == "snow" )
      or
      ( fibaro:getValue(3, "WeatherCondition") == "storm" )
    ) then
    offsetHour = offsetHour + 2;
    
    if ( debugModeDetail ) then fibaro:debug("WeatherConditions is poor"); end
  end
  
  local currentTime = os.date("*t");
  local currentMinutes = (currentTime.hour) * 60 + currentTime.min;
  
  if ( debugModeDetail ) then
    fibaro:debug("curtime = "
  	.. string.format("%02d", currentTime.hour) .. ":"
  	.. string.format("%02d", currentTime.min)
    .. " (" .. currentMinutes .. " mins)");
  end
  
  local sunriseTime = fibaro:getValue(1, "sunriseHour");
  local sunriseMinutes = (tonumber(string.sub(sunriseTime, 1, 2))
    + offsetHour / 4) * 60 + tonumber(string.sub(sunriseTime, 4));
  
  if ( debugModeDetail ) then
    fibaro:debug("sunrise = " .. sunriseTime .. " (" .. sunriseMinutes
      .. " mins with offset)");
  end
  
  local sunsetTime = fibaro:getValue(1, "sunsetHour");
  local sunsetMinutes = (tonumber(string.sub(sunsetTime, 1, 2))
    - offsetHour / 2) * 60 + tonumber(string.sub(sunsetTime, 4));
  
  if ( debugModeDetail ) then
    fibaro:debug("sunset = " .. sunsetTime .. " (" .. sunsetMinutes
      .. " mins with offset)");
  end
  
  -- twilightMode action
  
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
  
  -- nightMode action
        
  --if ( currentMinutes <= sunriseMinutes ) then
    
    if ( (fibaro:getGlobalValue("twilightMode") == "1")
      and (currentMinutes >= 1 * 60)
      and (currentMinutes <= 1 * 60 + 15) ) then -- HARDCODED 01:00
      
      if ( fibaro:getGlobalValue("nightMode") == "0" ) then
        fibaro:setGlobal("nightMode", "1");
        
        if ( debugMode ) then fibaro:debug("nightMode ON!"); end
      end
      
    elseif ( (fibaro:getGlobalValue("twilightMode") == "0")
      or (currentMinutes >= 7 * 60) ) then -- HARDCODED 7:00
      
      if ( fibaro:getGlobalValue("nightMode") == "1" ) then
        fibaro:setGlobal("nightMode", "0");
        
        if ( debugMode ) then fibaro:debug("nightMode OFF!"); end
      end
      
    end
    
  --end
  
  -- K_hotFloor action
  
  if ( (currentTime.wday > 1) and (currentTime.wday < 7) -- mon-fri
      and (currentMinutes >= 8 * 60) -- HARDCODED 08:00
      and (currentMinutes <= 8 * 60 + 15) )
    or ( ((currentTime.wday == 1) or (currentTime.wday == 7)) -- sat-sun
      and (currentMinutes >= 11 * 60) -- HARDCODED 11:00
      and (currentMinutes <= 11 * 60 + 15) ) then
    
    if ( debugModeDetail ) then
      fibaro:debug("8:00-8:15 Temp = " .. fibaro:getValue(3, "Temperature")
        .. ", k_hotFloor value = " .. fibaro:getValue(173, "value"));
    end
    
    if ( (tonumber(fibaro:getValue(3, "Temperature")) <= -5)
        and (fibaro:getValue(173, "value") == "0") ) then
      fibaro:call(216, "pressButton", 2);
      
      if ( debugMode ) then fibaro:debug("K_hotFloor ON!"); end
    end
    
  elseif ( (currentTime.wday > 1) and (currentTime.wday < 7) -- mon-fri
      and (currentMinutes >= 11 * 60) -- HARDCODED 11:00
      and (currentMinutes <= 11 * 60 + 15) ) then
    
    if ( debugMode ) then
      fibaro:debug("10:00-10:15 K_hotFloor value = "
        .. fibaro:getValue(173, "value"));
    end
    
    if (fibaro:getValue(173, "value") == "1" ) then
      fibaro:call(216, "pressButton", 2);
      
      if ( debugMode ) then fibaro:debug("K_hotFloor OFF!"); end
    end
  
  end
  
  fibaro:sleep(5 * 60 * 1000); -- 5 minutes
  
end
