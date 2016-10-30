--[[
%% properties
36 value
307 value
%% globals
--]]

--[[

WARNING!
In "ArmedMode" you need to exclude DOOR device from Alarm System!
In "VarMode" (armedMode == false) you need have the global var!

--]]


-- CONSTS

-- Devices ID's
local doorID = 307;
local lightID = 36;

-- Time to enter (in sec), longer time will detect as another situation, like cleaning
local timeToEnter = 10;

local nightModeLevel = "1";

local armedMode = false;

local debugMode = false;


-- GETENV

local door = fibaro:getValue(doorID, "value");

local isFlag = "0";
local isFlagMT = 0;

if ( armedMode ) then
  isFlag, isFlagMT = fibaro:get(doorID, "armed");
else
  isFlag, isFlagMT = fibaro:getGlobal("bathroomIsBusy");
end

if ( debugMode ) then fibaro:debug("Flag in <" .. isFlag .. "> (MT = " .. isFlagMT .. ")"); end

local trigger = fibaro:getSourceTrigger();
local light = fibaro:getValue(lightID, "value");

if ( debugMode ) then fibaro:debug("Current Light value = <" .. light .. ">"); end


-- SUBFUNCS

function setFlag(flag)
  
  if ( armedMode ) then
    
    if ( isFlag == flag ) then -- check for need to resetting
      
      if ( flag == "1" ) then
        fibaro:call(doorID, "setArmed", "0");
      else 
        fibaro:call(doorID, "setArmed", "1");
      end
      
    end
    
    fibaro:call(doorID, "setArmed", flag);
    
    if ( debugMode ) then
      local isArmed, isArmedMT = fibaro:get(doorID, "armed");
      fibaro:debug("Set <armed> status for bathroom door sensor in <" .. flag .. "> (value = " .. isArmed .. ", MT = " .. isArmedMT .. ")");
    end
    
  else
    
    if ( isFlag == flag ) then -- check for need to resetting
      
      if ( flag == "1" ) then
        fibaro:setGlobal("bathroomIsBusy", "0");
      else 
        fibaro:setGlobal("bathroomIsBusy", "1");
      end
      
    end
    
    fibaro:setGlobal("bathroomIsBusy", flag);
    
    if ( debugMode ) then
      local isBusy, isBusyMT = fibaro:getGlobal("bathroomIsBusy");
      fibaro:debug("Set global var <bathroomIsBusy> in <" .. flag .. "> (value = " .. isBusy .. ", MT = " .. isBusyMT .. ")");
    end
    
  end
  
end


-- PROCESS

if ( fibaro:countScenes() > 1 ) then
  
  if ( debugMode ) then fibaro:debug("Second scene!"); end
  --fibaro:abort();
  
elseif ( trigger['type'] == "property" ) then
  
  -- door trigger
  if ( tonumber(trigger['deviceID']) == doorID ) then
    
    if ( door == "1" ) then
      
      if ( debugMode ) then fibaro:debug("The door was opened.."); end
      
      if ( isFlag == "0" ) then
	      
        local val = "100";
        if ( fibaro:getGlobalValue("nightMode") == "1" ) then
          -- Special code! Only for my installation!
          val = fibaro:getValue(148, "value"); -- HKL_all
          if ( val == "0" ) then
          --
            val = nightModeLevel;
          end
        end
        
        fibaro:call(lightID, "setValue", val);
        
        setFlag("0");
        	
        if ( debugMode ) then fibaro:debug("Light ON (" .. val .. ")!"); end
        
      end
      
    elseif ( door == "0" ) then
      
      if ( debugMode ) then
        
        fibaro:debug("Door closed..");
        
        fibaro:debug("Flag = " .. isFlag .. "; os.t() = " .. os.time()
          .. "; isFlagMT = " .. isFlagMT .. "; diff = " .. os.time() - isFlagMT);
        
      end
      
      if ( (isFlag == "1") or ((os.time() - isFlagMT) >= timeToEnter) ) then
        
        fibaro:call(lightID, "turnOff");
        
        setFlag("0");
        
        if ( debugMode ) then fibaro:debug("The light turn off - the room is empty"); end
        
      else
            
        setFlag("1");
        
        if ( debugMode ) then fibaro:debug('Someone inside!'); end
        
      end
      
    end
    
  -- light manual
  elseif ( (tonumber(trigger['deviceID']) == lightID)
    and (os.time() - isFlagMT > 4) ) then -- to prevent the action on self-call event
    
    if ( light == "0" ) then
      
      if ( door == "1" ) then
        
        setFlag("1");
        
      else
        
        setFlag("0");
        
      end
      
      if ( debugMode ) then fibaro:debug('Light manual off!'); end
        
    elseif ( light == "1" ) then
      
      setFlag("1");
      
      if ( debugMode ) then fibaro:debug('Light manual on, arming...'); end
      
    end
    
  end
  
end
