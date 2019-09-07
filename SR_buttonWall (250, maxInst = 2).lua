--[[
%% properties
257 sceneActivation
%% globals
--]]


-- CONSTS --

local debugMode = true;

local buttonID = 257;

local lightSmlRoomGenDevID = 260;
local lightSmlRoomAuxDevID = 266;
local lightHall_KitchenGenDevID = 148;

local lightSRLeftID   = 261;
local lightSRCenterID = 262;
local lightKitchenID   = 149;
local lightHall_entID  = 150;
local lightHall_deepID = 151;

local vdLightSRID         = 272;
local vdLightSRSwitchBtn  = "5";
local vdLightKtnID        = 196;
local vdLightKtnSwitchBtn = "5";
local vdLightHllID        = 207;
local vdLightHllSwitchBtn = "5";

local lightValFullOn = "100"; -- set 100 val
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

local btnKind_OneTwo     = 10; -- use 0 for 1st channel or 10 for 2nf channel


-- GET ENVS --

local scrTrigger = fibaro:getSourceTrigger();

if ( scrTrigger["type"] ~= "property" )
then
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

if ( ((btnKind_OneTwo == 0) and (sceneActID >= 20))
	or ((btnKind_OneTwo == 10) and (sceneActID < 20)) )
then
  if ( debugMode ) then fibaro:debug("Another button.. Abort!"); end
  fibaro:abort();
end

local lightLeft    = tonumber(fibaro:getValue(lightSRLeftID, "value"));
local lightCenter  = tonumber(fibaro:getValue(lightSRCenterID, "value"));
local lightRight   = tonumber(fibaro:getValue(lightSmlRoomAuxDevID, "value"));
local lightKitchen = tonumber(fibaro:getValue(lightKitchenID, "value"));
local lightHallE   = tonumber(fibaro:getValue(lightHall_entID, "value"));
local lightHallD   = tonumber(fibaro:getValue(lightHall_deepID, "value"));

local btnMode, btnModeMT = fibaro:getGlobal("SRbtnWallMode");

if ( debugMode ) then
  
  fibaro:debug(
  	"lightLeft = " .. tostring(lightLeft) .. ", "
  	.. "lightCenter = " .. tostring(lightCenter) .. ", "
  	.. "lightRight = " .. tostring(lightRight) .. ", "
  	.. "lK = " .. tostring(lightKitchen) .. ", "
  	.. "lHe = " .. tostring(lightHallE) .. ", "
  	.. "lHd = " .. tostring(lightHallD)
  );
  
  fibaro:debug(
  	"btnMode = " .. btnMode .. ", "
  	.. "btnModeMT = " .. btnModeMT .. ", "
  	.. "curtime = " .. os.time()
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
  or (sceneActID == btnScnActOff + btnKind_OneTwo) ) then ---------------------
  
  if ( (btnMode == "HK") and (os.time() - btnModeMT <= 10) ) then
    
    if ( (lightKitchen == 0)
      and (lightHallE == 0) and (lightHallD == 0) ) then
      fibaro:call(vdLightKtnID, "pressButton", vdLightKtnSwitchBtn);
      fibaro:call(vdLightHllID, "pressButton", vdLightHllSwitchBtn);
    else
      fibaro:call(vdLightKtnID, "pressButton", vdLightKtnOffBtn);
      fibaro:call(vdLightHllID, "pressButton", vdLightHllOffBtn);
    end
    
  else
    fibaro:call(vdLightSRID, "pressButton", vdLightSRSwitchBtn);
  end
  
elseif ( sceneActID == btnScnActDblClick + btnKind_OneTwo ) then --------------
  
  -- v.2 - with btnMode
  
  --TODO: change btnMode
  
  if ( (btnMode == "HK") and (os.time() - btnModeMT <= 10) ) then
  -- v.1 - with timeout changeing mode
  --[[local val1, DT1 = fibaro:get(lightSmlRoomGenDevID, "value");
  local val2, DT2 = fibaro:get(lightHall_KitchenGenDevID, "value");
  
  if ( debugMode ) then
    fibaro:debug("val1 = ".. val1 .. ", val2 = " .. val2);
  end
  
  if ( (DT2 > DT1) and (os.time() - DT2 < 6) ) then -- К_Х light was switched
    -- during last 5 sec
  --]]
    -- change К_Х lights
    
    if ( lightKitchen > 0 ) then
      
      if ( (lightHallE > 0) or (lightHallD > 0) ) then
        
        lightsActions = lightHall_entID .. "," .. lightValHOrNOn .. ";"
          .. lightHall_deepID .. ",0" .. lightKitchenID .. ",0";
        
      else
        
        lightsActions = lightHall_entID .. "," .. tostring(lightKitchen) .. ";"
          .. lightKitchenID .. ",0";
        
      end
      
    else
      
      if ( lightHallD > 0 ) then
        
        lightsActions = lightKitchenID .. "," .. tostring(lightHallD) .. ";"
          .. lightHall_entID .. "," .. tostring(lightHallD) .. ";";
        
      elseif ( lightHallE > 0 ) then
        
        lightsActions = lightKitchenID .. "," .. tostring(lightHallE) .. ";"
          .. lightHall_deepID .. "," .. tostring(lightHallE) .. ";";
        
      else
        
        fibaro:call(vdLightKtnID, "pressButton", vdLightKtnSwitchBtn);
        fibaro:call(vdLightHllID, "pressButton", vdLightHllSwitchBtn);
        
      end
      
    end
    
  else -- change SR lights
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
  end
  
elseif ( sceneActID == btnScnActTrplClick + btnKind_OneTwo ) then -------------
  
  fibaro:call(vdLightHllID, "pressButton", vdLightHllSwitchBtn);
  
end

if ( debugMode ) then
  fibaro:debug("lightsActions = <" .. lightsActions .. ">");
end

if ( lightsActions ~= "" ) then
  fibaro:setGlobal("lightsQueue", fibaro:getGlobalValue("lightsQueue")
    .. lightsActions);
end
