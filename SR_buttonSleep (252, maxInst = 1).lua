--[[
%% properties
256 sceneActivation
%% globals
--]]


-- CONSTS --

local buttonID = 256;

-- button/BinSens scnActs codes
local btnScnActOn        = 10; -- toggle switch only
local btnScnActOff       = 11; -- toggle switch only
local btnScnActClick     = 16; -- momentary switch only
local btnScnActDblClick  = 14;
local btnScnActTrplClick = 15;
local btnScnActHold      = 12; -- momentary switch only
local btnScnActRelease   = 13; -- momentary switch only

local btnKind_OneTwo     = 0; -- use 0 for FIRST channel or 10 for SECOND channel

local debugMode = true;


-- GET ENVS --

local scrTrigger = fibaro:getSourceTrigger();

if ( scrTrigger["type"] ~= "property" ) then
  if ( debugMode ) then fibaro:debug("Incorrect call.. Abort!"); end
  fibaro:abort();
end

local sceneActID = tonumber(fibaro:getValue(buttonID, "sceneActivation"));

local bedIsDown = tonumber(fibaro:getValue(bedIsDownID, "value"));

if ( debugMode ) then
  fibaro:debug(
  	"sceneActID = " .. tostring(sceneActID) .. ", "
    .. "btnID = " .. scrTrigger['deviceID'] .. ", "
  	.. "btnValue = " .. fibaro:getValue(buttonID, "value") .. ", "
    .. "bedIsDown = " .. tostring(bedIsDown)
  );
end

if ( bedIsDown == 0 ) then
  if ( debugMode ) then fibaro:debug("Bed is closed.. Abort!"); end
  fibaro:abort();
end

if ( ((btnKind_OneTwo == 0) and (sceneActID >= 20))
	or ((btnKind_OneTwo == 10) and (sceneActID < 20)) ) then
  if ( debugMode ) then fibaro:debug("Another button.. Abort!"); end
  fibaro:abort();
end


-- PROCESS --
  
if ( (sceneActID == btnScnActClick + btnKind_OneTwo)
  or (sceneActID == btnScnActOn + btnKind_OneTwo)
  or (sceneActID == btnScnActOff + btnKind_OneTwo) ) then         ----------
  
  if ( fibaro:getGlobalValue("nightMode") == "0" ) then
    fibaro:setGlobal("nightMode_skipBR", "1");
    fibaro:setGlobal("nightMode", "1");
  else
    fibaro:setGlobal("nightMode", "0");
  end
  
elseif ( sceneActID == btnScnActDblClick + btnKind_OneTwo ) then  ----------
 
elseif ( sceneActID == btnScnActTrplClick + btnKind_OneTwo ) then ----------
  
end
