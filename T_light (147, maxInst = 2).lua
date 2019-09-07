--[[
%% properties
375 value
35 value
%% globals
--]]

--[[

WARNING!
In "ArmedMode" you need to exclude DOOR device from Alarm System!
In "VarMode" (armedMode == false) you need have the global var!

--]]


-- CONSTS

local debugMode = false;

-- Devices ID's
local doorID = 375;
local lightID = 35;
local buttonID = 57;

-- Time to enter (in sec), longer time will detect as another situation,
-- like cleaning
local timeToEnter = 15;

local nightModeLevel = "1";

-- spec. code, only for my installation
-- Attention! This MODE must be SYNCHRONIZED with scene.HK_button24_T!
local armedMode = false;


-- GETENV

local door = fibaro:getValue(doorID, "value");

local isFlag = "0";
local isFlagMT = 0;

if ( armedMode ) then
  isFlag, isFlagMT = fibaro:get(doorID, "armed");
else
  isFlag, isFlagMT = fibaro:getGlobal("toiletIsBusy");
end

if ( debugMode ) then
  fibaro:debug("Flag in <" .. isFlag .. "> (MT = " .. isFlagMT .. ")");
end

local trigger = fibaro:getSourceTrigger();
local light = fibaro:getValue(lightID, "value");

if ( debugMode ) then
  fibaro:debug("Current Light value = <" .. light .. ">");
end

local btn, btnMT = fibaro:get(buttonID, "value");

if ( os.time() - btnMT <= 5 ) then
  if ( debugMode ) then
    fibaro:debug("Manual button was pressed, exit");
  end
  
  return
end


-- SUBFUNCS
-- Must be SYNCHRONIZED with scene.HK_button24_T!

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
      
      fibaro:debug("Set <armed> status for toilet door sensor in <"
        .. flag .. "> (value = " .. isArmed .. ", MT = " .. isArmedMT .. ")");
    end
    
  else
    
    if ( isFlag == flag ) then -- check for need to resetting
      
      if ( flag == "1" ) then
        fibaro:setGlobal("toiletIsBusy", "0");
      else 
        fibaro:setGlobal("toiletIsBusy", "1");
      end
      
    end
    
    fibaro:setGlobal("toiletIsBusy", flag);
    
    if ( debugMode ) then
      local isBusy, isBusyMT = fibaro:getGlobal("toiletIsBusy");
      
      fibaro:debug("Set global var <toiletIsBusy> in <" .. flag
        .. "> (value = " .. isBusy .. ", MT = " .. isBusyMT .. ")");
    end
    
  end
  
end


-- PROCESS

if ( fibaro:countScenes() > 1 ) then
  
  if ( debugMode ) then fibaro:debug("Second scene! Skip.."); end
  --fibaro:abort();
  
elseif ( trigger['type'] == "property" ) then
  
  -- door trigger
  if ( tonumber(trigger['deviceID']) == doorID ) then
    
    if ( door == "1" ) then
      
      if ( debugMode ) then fibaro:debug("The door was opened.."); end
      
      if ( isFlag == "0" ) then
        	    
        local val = "99"; --"100";
        if ( fibaro:getGlobalValue("nightMode") == "1" ) then
          val = nightModeLevel;
          
          if ( debugMode ) then fibaro:debug("nightMode is active!"); end
        end
          
        -- Special code! Only for my installation!
        local val1 = fibaro:getValue(149, "value"); -- HKL_Rgbw_K
        local val2 = fibaro:getValue(150, "value"); -- HKL_rGbw_Hent
        
        if ( (fibaro:getGlobalValue("twilightMode") == "1")
            and (val == "99") and (val2 == "0") ) then
          val = "25";
        end
        
        if ( val2 ~= "0" ) then
          -- return max value more then zero
          if ( tonumber(val1) > 0 ) then
            val = val1;
            if ( tonumber(val2) > tonumber(val1) ) then
              val = val2;
            end
          elseif ( tonumber(val2) > 0 ) then
            val = val2;
            if ( tonumber(val1) > tonumber(val2) ) then
              val = val1;
            end
          end
        end
        --
        
        fibaro:call(lightID, "setValue", val);
        --[[local val_ = "";
        if ( tonumber(val) < 10 ) then
          val_ = "0" .. val;
        elseif ( tonumber(val) > 99 ) then
          val_ = "99";
        else
          val_ = val;
        end
          
        fibaro:setGlobal("lightsDimming", "0+" .. val_ .. "50" .. "0350"
          .. "0" .. tostring(lightID));
        fibaro:startScene(261);
        --]]
        setFlag("0");
        	
        if ( debugMode ) then fibaro:debug("Light ON (" .. val .. ")!"); end
        
      end
      
    elseif ( door == "0" ) then
      
      if ( debugMode ) then
        
        fibaro:debug("Door closed..");
        
        fibaro:debug("Flag = " .. isFlag .. "; os.t() = " .. os.time()
          .. "; isFlagMT = " .. isFlagMT
          .. "; diff = " .. os.time() - isFlagMT);
        
      end
      
      if ( (isFlag == "1") or ((os.time() - isFlagMT) >= timeToEnter) ) then
        
        fibaro:call(lightID, "turnOff");
        
        setFlag("0");
        
        if ( debugMode ) then
          fibaro:debug("The light turn off - the room is empty");
        end
        
      else
            
        setFlag("1");
        
        if ( debugMode ) then fibaro:debug('Someone inside!'); end
        
      end
      
    end
    
  -- light manual
  elseif ( (tonumber(trigger['deviceID']) == lightID)
    and (os.time() - isFlagMT > 4) ) then -- to prevent the action on
      -- self-call event
    
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
