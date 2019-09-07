--[[
%% properties
188 value
%% globals
--]]


-- CONSTS

local debugMode = false;


-- GET ENVS

local startSource = fibaro:getSourceTrigger();
local currentTime = os.date("*t");
local doorBellSensVal, doorBellSensDT = fibaro:get(188, "value");

local dayMode = (
  (fibaro:getGlobalValue("nightMode") == "0")
  and (currentTime.hour >= 8)
  and (currentTime.hour <= 21) ); -- currentTime.min;);


-- PROCESS

fibaro:sleep(50); -- to prevent kill all instances
if ( fibaro:countScenes() > 1 )
  then
  if ( debugMode ) then fibaro:debug("Double start.. Abort dup!"); end
  fibaro:abort();
end

if ( debugMode ) then fibaro:debug("doorBellSens!"); end

if ( (tonumber(doorBellSensVal) > 0)
  or (startSource["type"] == "other") ) then
  --and (os.time() - deviceLastModification0) >= 7) then
  
  if ( debugMode ) then fibaro:debug("Send notif. to phone"); end
  fibaro:call(184, "sendDefinedPushNotification", "184");
  
  --if (tonumber(fibaro:getGlobalValue("LenaInHomeB")) == tonumber("1")) then
  --    fibaro:call(154, "sendDefinedPushNotification", "184");
  --end
  
  --if (tonumber(fibaro:getGlobalValue("LeraInHomeB")) == tonumber("1")) then
  --   fibaro:call(157, "sendDefinedPushNotification", "184");
  --end
  
end

for i = 1, 2, 1 do
  
  if ( dayMode ) then
    
    if ( debugMode ) then fibaro:debug("BELL!!"); end
    
    fibaro:call(219, "pressButton", 5); -- SONOS play bell sound file
    fibaro:call(288, "turnOn"); -- Bell
    
  end
  
  if ( debugMode ) then fibaro:debug("Start Door(Bell)Light blinking"); end
  
  for i = 1, 2, 1 do
    fibaro:call(286, "turnOn");
    fibaro:sleep(1000);
    fibaro:call(286, "turnOff");
    fibaro:sleep(1000);
  end
  
  if ( debugMode ) then fibaro:debug("Finish Bell blinking"); end
    
  if ( dayMode ) then
    
    fibaro:call(288, "turnOff"); -- Bell
    
  end
  
end
