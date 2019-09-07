--[[
%% properties
57 sceneActivation
%% globals
--]]


-- CONSTS --

local debugMode = false;

-- Attention! This MODE must be SYNCHRONIZED with scene.T_light!
local armedMode = false;

local buttonID = 56;

local doorTID  = 58;
local lightTID = 35;

local vdLightHllID    = 207;
local vdLightHllOnBtn = "1";

local scDimmingID = 261;

local btnMode_HK = "btnMode_HK";

-- button/BinSens scnActs codes
local btnScnActOn        = 10; -- toggle switch only
local btnScnActOff       = 11; -- toggle switch only
local btnScnActClick     = 16; -- momentary switch only
local btnScnActDblClick  = 14;
local btnScnActTrplClick = 15;
local btnScnActHold      = 12; -- momentary switch only
local btnScnActRelease   = 13; -- momentary switch only

local btnKind_OneTwo     = 10; -- use 0 for 1st channel or 10 for 2nd channel


-- SUBFUNCS
-- Must be SYNCHRONIZED with scene.T_light!

function setFlag(flag)
  
  if ( armedMode ) then
    
    if ( isFlag == flag ) then -- check for need to resetting
      
      if ( flag == "1" ) then
        fibaro:call(doorTID, "setArmed", "0");
      else 
        fibaro:call(doorTID, "setArmed", "1");
      end
      
    end
    
    fibaro:call(doorTID, "setArmed", flag);
    
    if ( debugMode ) then
      local isArmed, isArmedMT = fibaro:get(doorTID, "armed");
      
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


-- GET ENVS --

local scrTrigger = fibaro:getSourceTrigger();

if ( scrTrigger["type"] ~= "property" ) then
  if ( debugMode ) then fibaro:debug("Incorrect call.. Abort!"); end
  fibaro:abort();
end

fibaro:sleep(50); -- to prevent to kill all instances
if ( fibaro:countScenes() > 1 ) then
  if ( debugMode ) then fibaro:debug("Double start"
    .. "(" .. tostring(fibaro:countScenes()) .. ").. Abort dup!"); end
  fibaro:abort();
end

local sceneActID = tonumber(fibaro:getValue(buttonID, "sceneActivation"));

if ( debugMode ) then
  fibaro:debug(
  	"sceneActID = " .. tostring(sceneActID) .. ", "
    .. "btnID = " .. scrTrigger['deviceID'] .. ", "
  	.. "btnValue = " .. fibaro:getValue(buttonID, "value")
  );
end

if ( ((btnKind_OneTwo == 0) and (sceneActID >= 20))
	or ((btnKind_OneTwo == 10) and (sceneActID < 20)) ) then
  if ( debugMode ) then fibaro:debug("Another button.. Abort!"); end
  fibaro:abort();
end


-- PROCESS --
  
if ( (sceneActID == btnScnActClick + btnKind_OneTwo)
  or (sceneActID == btnScnActOn + btnKind_OneTwo)
  or (sceneActID == btnScnActOff + btnKind_OneTwo) ) then ---------------------
  
  --TLight v.1
  --if ( fibaro:getValue(doorTID, "value") ~= "0" ) then
  --  fibaro:call(lightTID, "setValue", "99");
  --end
  
  if ( fibaro:getGlobalValue(btnMode_HK) == "1" ) then
    if ( fibaro:getValue(vdLightHllID, "ui.Slider3.value") == "0" ) then
      -- does not work :(
      --fibaro:call(vdLightHllID, "setProperty", "ui.Slider3.value", "100");
      fibaro:setGlobal("lightsQueue",
        fibaro:getGlobalValue("lightsQueue") .. "151,99;");
    else
      --fibaro:call(vdLightHllID, "setProperty", "ui.Slider3.value", "0");
      fibaro:setGlobal("lightsQueue",
        fibaro:getGlobalValue("lightsQueue") .. "151,0;");
    end
  --TLightv.2
  else
    if ( fibaro:getValue(lightTID, "value") == "0" ) then
      fibaro:call(lightTID, "setValue", "99");
    else
      fibaro:call(lightTID, "setValue", "0");
    end
    setFlag("0");
  end
  
elseif ( sceneActID == btnScnActDblClick + btnKind_OneTwo ) then  -------------
  
  if ( fibaro:getGlobalValue(btnMode_HK) == "1" ) then
    
    if ( fibaro:getValue(vdLightHllID, "ui.Slider2.value") == "0" ) then
      --fibaro:call(vdLightHllID, "setProperty", "ui.Slider2.value", "100");
      fibaro:setGlobal("lightsQueue",
        fibaro:getGlobalValue("lightsQueue") .. "151,99;");
    else
      --fibaro:call(vdLightHllID, "setProperty", "ui.Slider2.value", "0");
      fibaro:setGlobal("lightsQueue",
        fibaro:getGlobalValue("lightsQueue") .. "151,0;");
    end
    
  end
  
elseif ( sceneActID == btnScnActTrplClick + btnKind_OneTwo ) then -------------
  
  
  
elseif ( sceneActID == btnScnActHold + btnKind_OneTwo ) then ------------------
  
  local curDimming = fibaro:getGlobalValue("lightsDimming");
  
  if ( string.sub(curDimming, -string.len(tostring(lightTID)) - 2)
      ~= "1" .. lightTID .. ";" ) then
    fibaro:setGlobalValue("lightsDimming", "0+99050150"
      .. "1" .. lightTID .. ";");
  end
  
  fibaro:startScene(scDimmingID);
  
elseif ( sceneActID == btnScnActRelease + btnKind_OneTwo ) then ---------------
  
  fibaro:killScene(scDimmingID);
  
end

