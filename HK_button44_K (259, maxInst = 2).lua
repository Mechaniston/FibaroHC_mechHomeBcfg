--[[
%% properties
56 sceneActivation
%% globals
--]]


-- CONSTS --

local debugMode = false;

local buttonID = 56;

local vdLightKtnID        = 196;
local vdLightKtnSwitchBtn = "5";
local vdLightKtnOnBtn     = "1";
local vdLightAuxKtnID        = 361;
local vdLightAuxKtnSwitchBtnOne = "3";
local vdLightAuxKtnSwitchBtnFull = "1";

local lightKitchenID = 149;

local scDimmingID = 261;

local powerID = 4;

local btnMode_HK = "btnMode_HK";

-- button/BinSens scnActs codes
local btnScnActOn        = 10; -- toggle switch only
local btnScnActOff       = 11; -- toggle switch only
local btnScnActClick     = 16; -- momentary switch only
local btnScnActDblClick  = 14;
local btnScnActTrplClick = 15;
local btnScnActHold      = 12; -- momentary switch only
local btnScnActRelease   = 13; -- momentary switch only

local btnKind_OneTwo     = 0; -- use 0 for 1st channel or 10 for 2nd channel


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
  
  if ( fibaro:getGlobalValue(btnMode_HK) == "1" ) then
    fibaro:call(vdLightKtnID, "pressButton", vdLightKtnSwitchBtn);
  else
    fibaro:call(vdLightAuxKtnID, "pressButton", vdLightAuxKtnSwitchBtnOne);
  end
  
elseif ( sceneActID == btnScnActDblClick + btnKind_OneTwo ) then  -------------
  
  if ( fibaro:getGlobalValue(btnMode_HK) == "1" ) then
    fibaro:call(vdLightKtnID, "pressButton", vdLightKtnOnBtn);
  else
    fibaro:setGlobal("btnMode_HK", "1");
  end
  
elseif ( sceneActID == btnScnActTrplClick + btnKind_OneTwo ) then -------------
  
  if ( fibaro:getGlobalValue(btnMode_HK) == "1" ) then
    fibaro:call(216, "pressButton", 2); -- K_hotFloor pwr
  else
    fibaro:call(vdLightAuxKtnID, "pressButton", vdLightAuxKtnSwitchBtnFull);
  end
  
elseif ( sceneActID == btnScnActHold + btnKind_OneTwo ) then ------------------
  
  --if ( fibaro:getGlobalValue(btnMode_HK) == "1" ) then
    
    if ( (fibaro:getValue(lightKitchenID, "dead") ~= "0")
      or (fibaro:getValue(powerID, "value") == "0") ) then
      
      fibaro:call(vdLightKtnID, "pressButton", vdLightKtnSwitchBtn);
      
    else
      
      local curDimming = fibaro:getGlobalValue("lightsDimming");
      
      if ( string.sub(curDimming, -string.len(lightKitchenID) - 2)
          ~= "1" .. lightKitchenID .. ";" ) then
        fibaro:setGlobal("lightsDimming", "1+99050150"
          .. "1" .. lightKitchenID .. ";");
      end
      
      fibaro:startScene(scDimmingID);
      
    end
    
  --end
  
elseif ( sceneActID == btnScnActRelease + btnKind_OneTwo ) then ---------------
  
  fibaro:killScenes(scDimmingID);
  
end
