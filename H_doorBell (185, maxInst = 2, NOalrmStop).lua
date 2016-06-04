--[[
%% properties
188 value
%% globals
--]]

fibaro:sleep(50); -- to prevent kill all instances
if ( fibaro:countScenes() > 1 )
  then
  if ( debugMode ) then fibaro:debug("Double start.. Abort dup!"); end
  fibaro:abort();
end

local tempDeviceState0, deviceLastModification0 = fibaro:get(188, "value");

fibaro:debug(tempDeviceState0);

if (tonumber(tempDeviceState0) > 0) then
  --and (os.time() - deviceLastModification0) >= 7) then
  
  fibaro:call(184, "sendDefinedPushNotification", "184");
  
  --if (tonumber(fibaro:getGlobalValue("LenaInHomeB")) == tonumber("1")) then
  --    fibaro:call(154, "sendDefinedPushNotification", "184");
  --end
  
  --if (tonumber(fibaro:getGlobalValue("LeraInHomeB")) == tonumber("1")) then
  --   fibaro:call(157, "sendDefinedPushNotification", "184");
  --end
  
end
  
if ( fibaro:getGlobalValue("nightMode") == "0" ) then
  
  fibaro:call(219, "pressButton", 5); -- SONOS play bell sound file
  fibaro:call(288, "turnOn"); -- Bell
  
end

fibaro:call(286, "turnOn"); -- Door light
fibaro:sleep(1000);
fibaro:call(286, "turnOff");
fibaro:sleep(1000);
fibaro:call(286, "turnOn");
fibaro:sleep(1000);
fibaro:call(286, "turnOff");
fibaro:sleep(1000);
fibaro:call(286, "turnOn");
fibaro:sleep(1000);
fibaro:call(286, "turnOff");
  
if ( fibaro:getGlobalValue("nightMode") == "0" ) then
  
  fibaro:call(288, "turnOff"); -- Bell
  
end
