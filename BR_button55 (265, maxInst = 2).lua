--[[
%% properties
167 sceneActivation
%% globals
--]]


-- CONSTS --

local buttonID = 167;

local bedIsDownID     = 205;

local vdLightHllID        = 207;
local vdLightHllSwitchBtn = "5";

local plugBedID = 15;

local lightValFullOn = "1";
local lightValFOrNOn = "101"; -- full or night val
local lightValHOrNOn = "151"; -- half or night val - used for Hall

-- button/BinSens scnActs codes
local btnScnActOn        = 10; -- toggle switch only
local btnScnActOff       = 11; -- toggle switch only
local btnScnActClick     = 16; -- momentary switch only
local btnScnActDblClick  = 14;
local btnScnActTrplClick = 15;
local btnScnActHold      = 12; -- momentary switch only
local btnScnActRelease   = 13; -- momentary switch only

local btnKind_OneTwo     = 10; -- use 0 for FIRST channel or 10 for SECOND channel

local debugMode = false;


-- GET ENVS --

fibaro:sleep(50); -- to prevent kill all instances
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
  	.. "btnValue = " .. fibaro:getValue(buttonID, "value")
  );
end;

if ( fibaro:getValue(205, "value") == "0" ) then
  if ( debugMode ) then fibaro:debug("Bed is closed.. Abort!"); end
  fibaro:abort();
end

if ( ((btnKind_OneTwo == 0) and (sceneActID >= 20))
	or ((btnKind_OneTwo == 10) and (sceneActID < 20)) ) then
  if ( debugMode ) then fibaro:debug("Another button.. Abort!"); end
  fibaro:abort();
end

local bedIsDown    = tonumber(fibaro:getValue(bedIsDownID, "value"));

if ( debugMode ) then
  fibaro:debug(
  	"bedIsDown = " .. tostring(bedIsDown)
  );
end

-- PROCESS --
  
if ( (sceneActID == btnScnActClick + btnKind_OneTwo)
  or (sceneActID == btnScnActOn + btnKind_OneTwo)
  or (sceneActID == btnScnActOff + btnKind_OneTwo) ) then         -------------
  
  fibaro:call(vdLightHllID, "pressButton", vdLightHllSwitchBtn);
  
  if ( fibaro:getValue(plugBedID, "value") == "0" ) then
    fibaro:call(plugBedID, "turnOn");
  else
    fibaro:call(plugBedID, "turnOff");
  end
  
elseif ( sceneActID == btnScnActDblClick + btnKind_OneTwo ) then  -------------
  
  --[[  
  if ( debugMode ) then
    fibaro:debug("lightsActions = <" .. lightsActions .. ">");
  end
  
  fibaro:setGlobal("lightsQueue", fibaro:getGlobalValue("lightsQueue")
    .. lightsActions);
  --]]
  
elseif ( sceneActID == btnScnActTrplClick + btnKind_OneTwo ) then -------------
  
  
  
end
