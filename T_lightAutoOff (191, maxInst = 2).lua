--[[
%% properties
35 value
58 value
%% globals
--]]


-- CONSTS

-- Devices ID's
local doorID = 58;
local lightID = 35;

local debugMode = true;


-- GETENV

local door, doorMT = fibaro:get(doorID, "value");
local light, lightMT = fibaro:get(lightID, "value");
local srcTrigger = fibaro:getSourceTrigger();
local srcDevice = srcTrigger['deviceID'];

if ( debugMode ) then
  fibaro:debug("srcDevice = " .. srcDevice
    .. ", diff.time = " .. lightMT - doorMT);
end


-- PROCESS

if ( fibaro:countScenes() > 1 ) then
  
  if ( debugMode ) then fibaro:debug("Second scene!"); end
  --fibaro:abort();
  
elseif ( (tonumber(door) > 0) and (tonumber(light) > 0)
  and (
    (srcDevice ~= tostring(lightID)) -- to prevent action
      and (lightMT - doorMT <= 4) -- on manual changing light value
    ) ) then
  
  if ( debugMode ) then
    fibaro:debug("The door opened and the light turned on");
  end
  
  local startTime = os.time();
  
  while ( (tonumber(fibaro:getValue(doorID, "value")) > 0)
    and (tonumber(fibaro:getValue(lightID, "value")) > 0)
    and (os.time() - startTime <= 5 * 60) ) do
    
    fibaro:sleep(1500);
    
  end
  
  --setTimeout(function()
    if ( debugMode ) then
      fibaro:debug("Timeout or the door was closed or the light was turned off");
    end
    
    if ( (tonumber(fibaro:getValue(doorID, "value")) > 0)
      and (tonumber(fibaro:getValue(lightID, "value")) > 0) ) then
      
      if ( debugMode ) then
        fibaro:debug("The door still opened and the light turned on yet. TURN OFF!");
      end
      
      fibaro:call(lightID, "turnOff");
      
    end
  --end, 5 * 60 * 1000);
  
end
