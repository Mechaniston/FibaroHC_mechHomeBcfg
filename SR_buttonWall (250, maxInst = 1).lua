--[[
%% properties
257 sceneActivation
%% globals
--]]


-- CONSTS --

local buttonID = 257;

local lightSmlRoomGenDevID = 260;
local lightSmlRoomAuxDevID = 266;

local lightSRLeftID   = 261;
local lightSRCenterID = 262;

local vdLightSRID         = 272;
local vdLightSRSwitchBtn  = "5";

local lightValFOrNOn = "200"; -- full or night val
local lightValHOrNOn = "150"; -- half or night val - used for Hall

-- button/BinSens scnActs codes
local btnScnActOn        = 10; -- toggle switch only
local btnScnActOff       = 11; -- toggle switch only
local btnScnActClick     = 16; -- momentary switch only
local btnScnActDblClick  = 14;
local btnScnActTrplClick = 15;
local btnScnActHold      = 12; -- momentary switch only
local btnScnActRelease   = 13; -- momentary switch only

local btnKind_OneTwo     = 10; -- use 0 for FIRST channel or 10 for SECOND channel

local debugMode = true;


-- GET ENVS --

--[[
fibaro:sleep(50); -- to prevent to kill all instances
if ( fibaro:countScenes() > 1 )
  then
  if ( debugMode ) then fibaro:debug("Double start.. Abort dup!"); end
  fibaro:abort();
end
--]]

local scrTrigger = fibaro:getSourceTrigger();

if ( scrTrigger["type"] ~= "property" )
then
  if ( debugMode ) then fibaro:debug("Incorrect call.. Abort!"); end
  fibaro:abort();
end

local sceneActID = tonumber(fibaro:getValue(buttonID, "sceneActivation"));

if ( ((btnKind_OneTwo == 0) and (sceneActID >= 20))
	or ((btnKind_OneTwo == 10) and (sceneActID < 20)) )
then
  if ( debugMode ) then fibaro:debug("Another button.. Abort!"); end
  fibaro:abort();
end

local lightLeft    = tonumber(fibaro:getValue(lightSRLeftID, "value"));
local lightCenter  = tonumber(fibaro:getValue(lightSRCenterID, "value"));
local lightRight   = tonumber(fibaro:getValue(lightSmlRoomAuxDevID, "value"));

if ( debugMode )
  then
  fibaro:debug(
  	"lightLeft = " .. tostring(lightLeft) .. ", "
  	.. "lightCenter = " .. tostring(lightCenter) .. ", "
  	.. "lightRight = " .. tostring(lightRight)
  );
  fibaro:debug(
  	"sceneActID = " .. tostring(sceneActID) .. ", "
  	.. "btnValue = " .. fibaro:getValue(buttonID, "value")
  );
end


-- PROCESS --
  
local lightsActions = "";

if ( (sceneActID == btnScnActClick + btnKind_OneTwo)
  or (sceneActID == btnScnActOn + btnKind_OneTwo)
  or (sceneActID == btnScnActOff + btnKind_OneTwo) )          ------------------------------------------------------------
then
  
  fibaro:call(vdLightSRID, "pressButton", vdLightSRSwitchBtn);	-- vd.Свет:МК-осн SWITCH
  
elseif ( sceneActID == btnScnActDblClick + btnKind_OneTwo )   ------------------------------------------------------------
then
  --[[
    if ( (lightLeft > 0) and (lightCenter > 0) and (lightRight > 0) )
    then
      lightsActions = lightsActions .. tostring(lightBRCenterID).. ",0;";
    elseif ( (lightLeft > 0) and (lightCenter == 0) and (lightRight > 0) )
      then
        lightsActions = lightsActions
        	.. lightBRCenterID .. "," .. tostring(lightLeft) .. ";"
            .. lightBRLeftID .. ",0;" .. lightBRRightID .. ",0;";
      elseif ( (lightLeft == 0) and (lightCenter > 0) and (lightRight == 0) )
      then
        lightsActions = lightsActions
        	.. lightBRLeftID .. "," .. tostring(lightCenter) .. ";"
        	.. lightBRLeftID .. ",0";
      elseif ( (lightLeft > 0) and (lightCenter == 0) and (lightRight == 0) )
      then
        lightsActions = lightsActions
        	.. lightBRRightID .. "," .. tostring(lightLeft) .. ";"
            .. lightBRLeftID .. ",0";
      elseif ( (lightLeft == 0) and (lightCenter == 0) and (lightRight > 0) )
      then
          lightsActions = lightsActions
          	.. lightBRLeftID .. "," .. tostring(lightRight) .. ";"
            .. lightBRCenterID .. "," .. tostring(lightRight) .. ";";
      else
        lightsActions = lightsActions
        	.. lightBRLeftID .. "," .. lightValFOrNOn .. ";"
        	.. lightBRCenterID .. "," .. lightValFOrNOn .. ";"
        	.. lightBRRightID .. "," .. lightValFOrNOn .. ";";
      end
      
    end
  --]]
  
elseif ( sceneActID == btnScnActTrplClick + btnKind_OneTwo )  ------------------------------------------------------------
then
  
  
  
end

if ( debugMode ) then fibaro:debug("lightsActions = <" .. lightsActions .. ">"); end

if ( lightsActions ~= "" )
then
  fibaro:setGlobal("lightsQueue", fibaro:getGlobalValue("lightsQueue")
    .. lightsActions);
end
