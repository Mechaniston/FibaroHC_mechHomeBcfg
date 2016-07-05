--[[
%% properties
187 value
248 value
%% globals
--]]


-- CONSTS --

local doorIntID = 248;
local doorExtID = 187;

local IntDoorNotClosedNotif = "Закройте внутренюю входную дверь, пожалуйста!";
local ExtDoorNotClosedNotif = "Закройте внешнюю входную дверь, пожалуйста!";

local debugMode = true;


-- GET ENVS --

--[[fibaro:sleep(50); -- to prevent to kill all instances
if ( fibaro:countScenes() > 1 ) then
  if ( debugMode ) then fibaro:debug("Double start"
    .. "(" .. tostring(fibaro:countScenes()) .. ").. Abort dup!"); end
  fibaro:abort();
end--]]

local doorIntState, doorIntStateMT = fibaro:get(doorIntID, "value");
local doorExtState, doorExtStateMT = fibaro:get(doorExtID, "value");


-- PROCESS --

if ( (doorIntState == "0") and (doorExtState == "0") ) then -- all closed
  
  if ( debugMode ) then fibaro:debug("All doors were closed"); end
  
  fibaro:call(286, "turnOff");
  
  if ( doorExtStateMT - doorIntStateMT  <= 2 * 60 ) then
    -- somebody settled in the home (incoming 4/4 !!!-> or welcoming 4/4)
    fibaro:call(2, "sendEmail", "MechFHC - doors control",
      "Somebody settled in the home");
    
    --fibaro:call(59, "sendPhotoToUser", "52");
    fibaro:call(59, "sendPhotoToEmail", "v.pavlov@at.com.ru");
    
  elseif ( doorIntStateMT - doorExtStateMT  <= 10 ) then
    -- somebody left the home (outgoing 4/4)
    fibaro:call(2, "sendEmail", "MechFHC - doors control",
      "Somebody left the home");
    
  else
    
    if ( debugMode ) then fibaro:debug("! Cannot determine event type"); end
    
  end
    
elseif ( (doorIntState == "0") and (doorExtState == "1") ) then
  -- outgoing 3/4 or incoming 1/4
  
  if ( debugMode ) then fibaro:debug("ExtDoor are opened and IntDoor are closed"); end
  
  fibaro:call(286, "turnOn");
  
elseif ( (doorIntState == "1") and (doorExtState == "0") ) then
  -- outgoing 1/4 or welcoming 1/4, 3/4 or incoming 3/4
  
  if ( debugMode ) then fibaro:debug("IntDoor are opened and ExtDoor are closed"); end
  
  fibaro:call(286, "turnOn");
  
  --fibaro:call(59, "sendPhotoToUser", "52");
  fibaro:call(59, "sendPhotoToEmail", "mechanist@at.com.ru");
  
elseif ( (doorIntState == "1") and (doorExtState == "1") ) then
  
  if ( debugMode ) then fibaro:debug("All doors were opened"); end
  
  fibaro:call(286, "turnOff");
  
  if ( doorIntStateMT - doorExtStateMT <= 5 ) then
    -- somebody exited from the home (outgoing 2/4 or welcoming 2/4)
    fibaro:call(2, "sendEmail", "MechFHC - doors control",
      "Somebody exited from the home");
    
  elseif ( doorExtStateMT - doorIntStateMT <= 10 ) then
    -- sombody entered in the home (incoming 2/4)
    fibaro:call(2, "sendEmail", "MechFHC - doors control",
      "Somebody entered in the home");
    
  else
    
    if ( debugMode ) then fibaro:debug("! Cannot determine event type"); end
    
  end
  
  --fibaro:call(59, "sendPhotoToUser", "52");
  fibaro:call(59, "sendPhotoToEmail", "mechanist@cla.su");
  
end

-----

if ( (doorIntState == "1") or (doorExtState == "1") ) then
  if ( fibaro:countScenes() > 1 ) then
    
    if ( debugMode ) then fibaro:debug("Double checking detected.. Abort dup!"); end
    
    fibaro:abort();
    
  else
    
    if ( debugMode ) then
      fibaro:debug("Some of doors are OPENED! Wait for close..");
    end
    
  end
  
  -- silent wait until doors closed
  local curTime = os.time();
  while ( (os.time() - curTime) < (2 * 60) ) do -- 2 min
    
    if ( (fibaro:getValue(doorIntID, "value") == "0")
      and (fibaro:getValue(doorExtID, "value") == "0") ) then
      
      if ( debugMode ) then
        fibaro:debug("All doors were CLOSED, security is restored! :)");
      end
      
      fibaro:abort();
      
    end
    
    fibaro:sleep(2000);
    
  end
  
  -- wait and notifs.
  
  --local mechInHome = fibaro:getGlobalValue("mechInHomeB");
  local LenaInHome = fibaro:getGlobalValue("LenaInHomeB");
  local LeraInHome = fibaro:getGlobalValue("LeraInHomeB");
  
  local isDoorsOpened = false;
      
  curTime = os.time();
  while ( (os.time() - curTime) < (0.5 * 60 * 60) ) do -- 0.5 hour
    
    isDoorsOpened = false;
    
    if ( fibaro:getValue(doorIntID, "value") == "1" ) then
      
      if ( debugMode ) then fibaro:debug("DoorInt is still OPENED!"); end
      
      if ( LenaInHome == "1" ) then
        --fibaro:call(154, "sendPush", IntDoorNotClosedNotif);
      end
      if ( LeraInHome == "1" ) then
        fibaro:call(157, "sendPush", IntDoorNotClosedNotif);
      end
      --fibaro:call(184, "sendPush", "Int. door isn't closed!");
      
    else
      isDoorsOpened = true;
    end
        
    if ( fibaro:getValue(doorExtID, "value") == "1" ) then
      
      if ( debugMode ) then fibaro:debug("DoorExt is still OPENED!"); end
      
      if ( LenaInHome == "1" ) then
        --fibaro:call(154, "sendPush", ExtDoorNotClosedNotif);
      end
      if ( LeraInHome == "1" ) then
        fibaro:call(157, "sendPush", ExtDoorNotClosedNotif);
      end
      --fibaro:call(184, "sendPush", "Ext. door isn't closed");
      
    else
      isDoorsOpened = true;
    end
        
    if ( not isDoorsOpened ) then
      if ( debugMode ) then
        fibaro:debug("All doors were CLOSED, security is restored! :)");
      end
      
      fibaro:abort();
    end
    
    fibaro:sleep(5 * 60 * 1000); -- 5 min delay between notifs.
  end
  
  if ( (fibaro:getValue(doorIntID, "value") == "1")
    or (fibaro:getValue(doorExtID, "value") == "1") ) then
    
    if ( debugMode ) then
      fibaro:debug("The one of doors is still OPENED! But notification cycle is done");
    end
    
  end
  
end
