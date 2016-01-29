--[[
%% properties
%% globals
lightsQueue
--]]


-- CONST

local powerID = 4; -- Туалет:БП ACDC 24В

local debugMode = true;


-- GET ENVS

if ( fibaro:countScenes() > 1 )
  then
  if ( debugMode ) then fibaro:debug("Double start.. Abort dup!"); end
  fibaro:abort();
end;
--local trigger = fibaro:getSourceTrigger();

local powerValue = fibaro:getValue(powerID, "value");

local nightMode = false;
if ( fibaro:getGlobalValue("nightMode") == "1" )
  then
  nightMode = true;
  if ( debugMode ) then fibaro:debug("_nightMode detected"); end
end

local lightsQueue = fibaro:getGlobalValue("lightsQueue");
local lightActionPos = string.find(lightsQueue, ";");


-- PROCESS

if ( debugMode ) then fibaro:debug("_lightsQueue = <" .. lightsQueue .. ">"); end

while lightActionPos ~= nil do
  
  if ( debugMode ) then fibaro:debug("FOUND lightAction, end.pos = " .. tostring(lightActionPos)); end
  
  local lightAction = string.sub(lightsQueue, 1, lightActionPos);
  fibaro:setGlobal("lightsQueue", string.sub(lightsQueue, lightActionPos + 1));
  
  if ( debugMode ) then fibaro:debug("GET lightAction = <" .. lightAction .. ">"); end
  
  local nodeID = tonumber(string.sub(lightAction, 1, string.find(lightAction, ",") - 1));
  lightAction = string.sub(lightAction, string.find(lightAction, ",") + 1);
  local nodeValue = string.sub(lightAction, 1, string.find(lightAction, ";") - 1);
  
--fibaro:debug(tostring(nodeID) .. " / " .. nodeValue); fibaro:abort();
  
  local nodeName = "<" .. fibaro:getName(nodeID)
    	.. " (" .. fibaro:getRoomNameByDeviceID(nodeID) .. ")>";
    
  if ( debugMode ) then fibaro:debug("LIGHTACTION: set value for " .. nodeName .. " = " .. nodeValue); end
  
    if ( nodeValue == "0" )
      then
      -- TURN OFF --
      
	  --if tonumber(fibaro:getValue(nodeID, "value")) > 0 -- disable check because fails sometimes
      --  then
      if ( debugMode ) then fibaro:debug("TURING OFF " .. nodeName); end
      
      fibaro:call(nodeID, "turnOff");
      --end
    
    else
      -- TURN ON --
      
      --- Check PowerSource ---
      if ( powerValue == "0" )
        then
        if ( debugMode ) then fibaro:debug("PowerSource is OFF! Turning ON"); end
        
        fibaro:call(powerID, "turnOn");
        fibaro:sleep(3 * 1000);
        
        powerValue = fibaro:getValue(powerID, "value");
        if ( powerValue == "0" )
          then
          if ( debugMode ) then fibaro:debug("PowerSource turning on was FAIL!"); end
          break;
        end
      else
        if ( debugMode ) then fibaro:debug("PowerSource is on");
      end
      
      --- Wakeup devices ---
      if ( fibaro:getValue(nodeID, "dead") >= "1" )
        then
        if ( debugMode ) then fibaro:debug("WAKING UP DEAD " .. nodeName); end
        
        --fibaro:wakeUpDeadDevice(nodeID);
		--new code for HC2 v4+:
		fibaro:call(1, 'wakeUpAllDevices', nodeID);
        
        fibaro:sleep(2 * 1000);
      end
      
      if ( nodeValue == "101" )
        then
        if ( nightMode == true )
          then
          nodeValue = "1";
        else
          nodeValue = "99";
        end
      elseif ( tonumber(nodeValue) > 101 )
        then
        nodeValue = tostring(tonumber(nodeValue - 101));
      end
      
      if (tonumber(nodeValue) >= 99 )
        then -- FULL ON
        if ( debugMode ) then fibaro:debug("Turning ON " .. nodeName); end
        
        --fibaro:call(nodeID, "turnOn");
        -- непонятная хрень - RGBW в БК не желают включаться по
        -- "turnOn" (в т.ч. через моб.прил-ие!),
        -- выключаются же при этом - без проблем
        fibaro:call(nodeID, "setValue", 100);
      elseif tonumber(nodeValue) <= 3
        then -- MIN
        if ( debugMode ) then fibaro:debug("Setting MIN on " .. nodeName); end
        
        fibaro:call(nodeID, "setValue", 1);
      else -- EXACT VALUE
        if ( debugMode ) then fibaro:debug("Setting VALUE [" .. nodeValue .. "] on " .. nodeName); end
        
        fibaro:call(nodeID, "setValue", nodeValue);
      end
      
      --end
    end

  -- reload queue and research lA
  lightsQueue = fibaro:getGlobalValue("lightsQueue");
  lightActionPos = string.find(lightsQueue, ";");
  
  if ( debugMode ) then fibaro:debug("__lightsQueue = <" .. lightsQueue .. ">"); end
end

fibaro:setGlobal("lightsQueue", ""); -- clear queue
