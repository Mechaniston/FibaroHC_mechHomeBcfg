--[[
%% properties
206 sceneActivation
%% globals
--]]


-- CONSTS --

local buttonID = 206;

local lightBigRoomGenDevID = 40;

local lightBRLeftID   = 41;
local lightBRCenterID = 42;
local lightBRRightID  = 43;
local lightBRBedID    = 44;

local bedIsDownID     = 205;

local vdLightBRID           = 195;
local vdLightBRSwitchBtn    = "6";
local vdLightBRBedSwitchBtn = "16";

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

local lightLeft    = tonumber(fibaro:getValue(lightBRLeftID, "value"));
local lightCenter  = tonumber(fibaro:getValue(lightBRCenterID, "value"));
local lightRight   = tonumber(fibaro:getValue(lightBRRightID, "value"));
local lightBed     = tonumber(fibaro:getValue(lightBRBedID, "value"));

local bedIsDown    = tonumber(fibaro:getValue(bedIsDownID, "value"));

if ( debugMode ) then
  fibaro:debug(
  	"lightLeft = " .. tostring(lightLeft) .. ", "
  	.. "lightCenter = " .. tostring(lightCenter) .. ", "
  	.. "lightRight = " .. tostring(lightRight) .. ", "
  	.. "lightBed = " .. tostring(lightBed) .. "; "
  	.. "bedIsDown = " .. tostring(bedIsDown)
  );
end

-- PROCESS --
  
if ( (sceneActID == btnScnActClick + btnKind_OneTwo)
  or (sceneActID == btnScnActOn + btnKind_OneTwo)
  or (sceneActID == btnScnActOff + btnKind_OneTwo) ) then         -------------
  
  fibaro:call(vdLightBRID, "pressButton", vdLightBRSwitchBtn);	-- vd.Свет:БК-осн SWITCH
  
elseif ( sceneActID == btnScnActDblClick + btnKind_OneTwo ) then  -------------
  
  local lightsActions = "";
  
  -- change БК lights
    
      if ( (lightLeft > 0) and (lightCenter > 0) and (lightRight > 0) )
      then
        lightsActions = lightsActions .. lightBRCenterID .. ",0;";
      elseif ( (lightLeft > 0) and (lightCenter == 0) and (lightRight > 0) )
      then
        lightsActions = lightsActions .. lightBRCenterID .. "," .. tostring(lightLeft) .. ";" .. lightBRRightID .. ",0;";
      elseif ( (lightLeft > 0) and (lightCenter > 0) and (lightRight == 0) )
      then
        lightsActions = lightsActions .. lightBRRightID .. "," .. tostring(lightCenter) .. ";" .. lightBRLeftID .. ",0;";
      elseif ( (lightLeft == 0) and (lightCenter > 0) and (lightRight > 0) )
      then
        lightsActions = lightsActions .. lightBRCenterID .. "," .. tostring(lightRight) .. ",0;";
      elseif ( (lightLeft == 0) and (lightCenter > 0) and (lightRight == 0) )
      then
        lightsActions = lightsActions .. lightBRLeftID .. "," .. tostring(lightCenter) .. ";" .. lightBRCenterID .. ",0";
      elseif ( (lightLeft > 0) and (lightCenter == 0) and (lightRight == 0) )
      then
        lightsActions = lightsActions .. lightBRRightID .. "," .. tostring(lightLeft) .. ";" .. lightBRLeftID .. ",0";
      elseif ( (lightLeft == 0) and (lightCenter == 0) and (lightRight > 0) )
      then
        if ( lightBed == 0 )
        then
          lightsActions = lightsActions .. lightBRBedID .. "," .. lightValFOrNOn .. ";" .. lightBRRightID .. ",0";
        else
          lightsActions = lightsActions .. lightBRLeftID .. "," .. tostring(lightRight) .. ";" .. lightBRCenterID .. "," .. tostring(lightRight) .. ";";
        end
      else
        lightsActions = lightsActions .. lightBRLeftID .. "," .. lightValFOrNOn .. ";" .. lightBRCenterID .. "," .. lightValFOrNOn .. ";" .. lightBRRightID .. "," .. lightValFOrNOn .. ";";
      end

    --[[
    if ( (bedLight == 0) and bedIsDown )
      then
      
      fibaro:call(195, "pressButton", "8");		-- БК_Кровать light ON
      
    elseif ( (valueLight == 0) and (bedLight ~= 0) )
      then
      
      fibaro:call(195, "pressButton", "10");	-- БК_Кровать light OFF
      fibaro:sleep(3000);
      fibaro:call(195, "pressButton", "2");		-- БК light ON
      
    elseif ( (valueLight ~= 0) and (bedLight ~= 0) )
      then
      
      fibaro:call(195, "pressButton", "4");		-- БК light OFF
      
    else
      
      fibaro:call(195, "pressButton", "2");		-- БК light ON
      fibaro:sleep(3000);
      fibaro:call(195, "pressButton", "8");		-- БК_Кровать light ON
      
    end
    --]]
  
  if ( debugMode ) then
    fibaro:debug("lightsActions = <" .. lightsActions .. ">");
  end
  
  fibaro:setGlobal("lightsQueue", fibaro:getGlobalValue("lightsQueue")
    .. lightsActions);

elseif ( sceneActID == btnScnActTrplClick + btnKind_OneTwo ) then -------------
  
  fibaro:call(vdLightBR, "pressButton", vdLightBRBedSwitchBtn);
  
end
