--[[
%% properties
319 sceneActivation
%% globals
--]]


-- CONSTS --

local debugMode = false;

-- Attention! This MODE must be SYNCHRONIZED with scene.B_light!
local armedMode = false;

local buttonID = 319;

local doorBID  = 363;
local lightBID = 36;

local vdLightHllID     = 207;
local vdLightHllOnBtn  = "1";
local vdLightHllOfBtn  = "3";
local vdLightKtnID     = 196;
local vdLightKtnOnBtn  = "1";
local vdLightKtnOffBtn = "3";

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


-- SUBFUNCS
-- Must be SYNCHRONIZED with scene.HK_button24_B!

function setFlag(flag)
  
  if ( armedMode ) then
    
    if ( isFlag == flag ) then -- check for need to resetting
      
      if ( flag == "1" ) then
        fibaro:call(doorBID, "setArmed", "0");
      else 
        fibaro:call(doorBID, "setArmed", "1");
      end
      
    end
    
    fibaro:call(doorBID, "setArmed", flag);
    
    if ( debugMode ) then
      local isArmed, isArmedMT = fibaro:get(doorBID, "armed");
      fibaro:debug("Set <armed> status for bathroom door sensor in <"
        .. flag .. "> (value = " .. isArmed .. ", MT = " .. isArmedMT .. ")");
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
      fibaro:debug("Set global var <bathroomIsBusy> in <"
        .. flag .. "> (value = " .. isBusy .. ", MT = " .. isBusyMT .. ")");
    end
    
  end
  
end


-- PROCESS --
  
if ( (sceneActID == btnScnActClick + btnKind_OneTwo)
  or (sceneActID == btnScnActOn + btnKind_OneTwo)
  or (sceneActID == btnScnActOff + btnKind_OneTwo) ) then ---------------------
  
  --BLight v.1
  --if ( fibaro:getValue(doorBID, "value") ~= "0" ) then
  --  fibaro:call(lightBID, "setValue", "99");
  --  fibaro:call(368, "turnOn");
  --end
  
  if ( fibaro:getGlobalValue(btnMode_HK) == "1" ) then
    fibaro:call(vdLightHllID, "pressButton", vdLightHllOnBtn);
    fibaro:call(vdLightKtnID, "pressButton", vdLightKtnOnBtn);
  --BLight v.2
  else
    if ( fibaro:getValue(lightBID, "value") == "0" ) then
      fibaro:call(lightBID, "setValue", "99");
      fibaro:call(368, "turnOn");
    else
      fibaro:call(lightBID, "setValue", "0");
      fibaro:call(368, "turnOff");
    end
    setFlag("0");
  end
  
elseif ( sceneActID == btnScnActDblClick + btnKind_OneTwo ) then  -------------
  
  if ( fibaro:getGlobalValue(btnMode_HK) == "1" ) then
    fibaro:call(vdLightHllID, "pressButton", vdLightHllOffBtn);
    fibaro:call(vdLightKtnID, "pressButton", vdLightKtnOffBtn);
  end
  
elseif ( sceneActID == btnScnActTrplClick + btnKind_OneTwo ) then -------------
  
  
  
elseif ( sceneActID == btnScnActHold + btnKind_OneTwo ) then ------------------
  
  local curDimming = fibaro:getGlobalValue("lightsDimming");
  
  if ( string.sub(curDimming, -string.len(tostring(lightBID)) - 2)
      ~= "1" .. lightBID .. ";" ) then
    fibaro:setGlobalValue("lightsDimming", "0+99050150"
      .. "1" .. lightBID .. ";");
  end
  
  fibaro:startScene(scDimmingID);
  
elseif ( sceneActID == btnScnActRelease + btnKind_OneTwo ) then ---------------
  
  fibaro:killScenes(scDimmingID);
  
end
