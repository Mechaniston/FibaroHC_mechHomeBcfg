--[[
%% properties
318 sceneActivation
%% globals
--]]


-- CONSTS --

local debugMode = false;

local buttonID = 318;

local vdLightHllID        = 207;
local vdLightHllOnBtn     = "1";
local vdLightHllMinOnBtn  = "2";
local vdLightHllOffBtn    = "3";
local vdLightHllSwitchBtn = "5";

local lightHallEntID = 150;
local lightHallDeepID = 151;

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

fibaro:sleep(50); -- to prevent to kill all instances
if ( fibaro:countScenes() > 1 ) then
  if ( debugMode ) then fibaro:debug("Double start"
    .. "(" .. tostring(fibaro:countScenes()) .. ").. Abort dup!"); end
  fibaro:abort();
end

local scrTrigger = fibaro:getSourceTrigger();

if ( scrTrigger["type"] ~= "property" ) then
  if ( debugMode ) then fibaro:debug("Incorrect call.. Abort!"); end
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
    fibaro:call(vdLightHllID, "pressButton", vdLightHllOnBtn);
  else
    fibaro:call(vdLightHllID, "pressButton", vdLightHllSwitchBtn);
  end
  
elseif ( sceneActID == btnScnActDblClick + btnKind_OneTwo ) then  -------------
  
  if ( fibaro:getGlobalValue(btnMode_HK) == "1" ) then
    fibaro:call(vdLightHllID, "pressButton", vdLightHllOffBtn);
  else
    fibaro:setGlobal("btnMode_HK", "1");
  end
  
elseif ( sceneActID == btnScnActTrplClick + btnKind_OneTwo ) then -------------
  
  if ( fibaro:getGlobalValue(btnMode_HK) == "1" ) then
    fibaro:startScene(217); -- everybodyLeftHome
  else
    fibaro:call(vdLightHllID, "pressButton", vdLightHllMinOnBtn);
  end
  
elseif ( sceneActID == btnScnActHold + btnKind_OneTwo ) then ------------------
  
  --if ( fibaro:getGlobalValue(btnMode_HK) == "1" ) then
    
    if ( (fibaro:getValue(lightHallEntID, "dead") ~= "0")
      or (fibaro:getValue(lightHallDeepID, "dead") ~= "0")
      or (fibaro:getValue(powerID, "value") == "0") ) then
      
      fibaro:call(vdLightHllID, "pressButton", vdLightHllSwitchBtn);
      
    else
      
      if ( string.sub(fibaro:getGlobalValue("lightsDimming"),
          -string.len(lightHallEntID .. lightHallDeepID) - 3)
          ~= "1" .. lightHallEntID .. ";" .. lightHallDeepID .. ";" ) then
        fibaro:setGlobal("lightsDimming", "1+99050150"
          .. "1" .. lightHallEntID .. ";" .. lightHallDeepID .. ";");
      end
      
      fibaro:startScene(scDimmingID);
      
    end
    
  --end
  
elseif ( sceneActID == btnScnActRelease + btnKind_OneTwo ) then ---------------
  
  fibaro:killScenes(scDimmingID);
  
end
