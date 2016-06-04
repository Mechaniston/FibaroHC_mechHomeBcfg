--[[
%% properties
201 sceneActivation
%% globals
--]]


-- CONSTS --

local buttonID = 201;

local lightBigRoomGenDevID = 40;
local lightHall_KitchenGenDevID = 148;

local lightBRLeftID    = 41;
local lightBRCenterID  = 42;
local lightBRRightID   = 43;
local lightBRBedID     = 44;
local lightKitchenID   = 149;
local lightHall_entID  = 150;
local lightHall_deepID = 151;

local bedIsDownID     = 205;

local vdLightBRID         = 195;
local vdLightBRSwitchBtn  = "6";
local vdLightKtnID        = 196;
local vdLightKtnSwitchBtn = "5";
local vdLightHllID        = 207;
local vdLightHllSwitchBtn = "5";

local lightValFullOn = "100"; -- set 100 val
local lightValFOrNOn = "200"; -- turn on or night val
local lightValHOrNOn = "150"; -- set half or night val - used for Hall

-- button/BinSens scnActs codes
local btnScnActOn        = 10; -- toggle switch only
local btnScnActOff       = 11; -- toggle switch only
local btnScnActClick     = 16; -- momentary switch only
local btnScnActDblClick  = 14;
local btnScnActTrplClick = 15;
local btnScnActHold      = 12; -- momentary switch only
local btnScnActRelease   = 13; -- momentary switch only

local btnKind_OneTwo     =  0; -- use 0 for FIRST channel or 10 for SECOND channel

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

if ( scrTrigger["type"] ~= "property" ) then
  
  if ( debugMode ) then fibaro:debug("Incorrect call.. Abort!"); end
  fibaro:abort();
  
end

local sceneActID = tonumber(fibaro:getValue(buttonID, "sceneActivation"));

if ( ((btnKind_OneTwo == 0) and (sceneActID >= 20))
  or ((btnKind_OneTwo == 10) and (sceneActID < 20)) ) then
  
  if ( debugMode ) then fibaro:debug("Another button.. Abort!"); end
  fibaro:abort();
  
end

local lightLeft    = tonumber(fibaro:getValue(lightBRLeftID, "value"));
local lightCenter  = tonumber(fibaro:getValue(lightBRCenterID, "value"));
local lightRight   = tonumber(fibaro:getValue(lightBRRightID, "value"));
local lightBed     = tonumber(fibaro:getValue(lightBRBedID, "value"));
local lightKitchen = tonumber(fibaro:getValue(lightKitchenID, "value"));
local lightHallE   = tonumber(fibaro:getValue(lightHall_entID, "value"));
local lightHallD   = tonumber(fibaro:getValue(lightHall_deepID, "value"));

local bedIsDown    = tonumber(fibaro:getValue(bedIsDownID, "value"));
local btnMode, btnModeMT = fibaro:getGlobal("BRbtnWallMode");

if ( debugMode ) then
  
  fibaro:debug(
  	"lL = " .. tostring(lightLeft) .. ", "
  	.. "lC = " .. tostring(lightCenter) .. ", "
  	.. "lR = " .. tostring(lightRight) .. ", "
  	.. "lB = " .. tostring(lightBed) .. ", "
  	.. "lK = " .. tostring(lightKitchen) .. ", "
  	.. "lHe = " .. tostring(lightHallE) .. ", "
  	.. "lHd = " .. tostring(lightHallD)
  );
  
  fibaro:debug(
  	"bedIsDown = " .. tostring(bedIsDown) .. ", "
  	.. "btmMode = " .. btnMode .. ", "
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
  or (sceneActID == btnScnActOff + btnKind_OneTwo) ) then     ------------------------------------------------------------
  
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
    fibaro:call(vdLightBRID, "pressButton", vdLightBRSwitchBtn);
  end
  
elseif ( sceneActID == btnScnActDblClick + btnKind_OneTwo ) then ------------------------------------------------------------
  
  -- v.2 - with btnMode
  if ( (btnMode == "HK") and (os.time() - btnModeMT <= 10) ) then
  -- v.1 - with timeout changeing mode
  --[[local val1, DT1 = fibaro:get(lightBigRoomGenDevID, "value");
  local val2, DT2 = fibaro:get(lightHall_KitchenGenDevID, "value");
  
  if ( debugMode ) then
    fibaro:debug("val1 = ".. val1 .. ", val2 = " .. val2);
  end
  
  if ( (DT2 > DT1) and (os.time() - DT2 < 6) ) then -- К_Х light was switched during last 5 sec
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
    
  else -- change БК lights
    
    if ( (lightBed == 0) and bedIsDown ) then
      
      lightsActions = lightBRBedID .. "," .. lightValFOrNOn .. ";";
      
    else
      
      if ( lightBed > 0 ) then
        lightsActions = lightBRBedID .. ",0;";
      end
      
      if ( (lightLeft > 0) and (lightCenter > 0) and (lightRight > 0) ) then
        
        lightsActions = lightsActions .. tostring(lightBRCenterID).. ",0;";
        
      elseif ( (lightLeft > 0) and (lightCenter == 0) and (lightRight > 0) ) then

        lightsActions = lightsActions
          .. lightBRCenterID .. "," .. tostring(lightLeft) .. ";"
          .. lightBRLeftID .. ",0;" .. lightBRRightID .. ",0;";
        
      elseif ( (lightLeft == 0) and (lightCenter > 0) and (lightRight == 0) ) then

        lightsActions = lightsActions
          .. lightBRLeftID .. "," .. tostring(lightCenter) .. ";"
          .. lightBRLeftID .. ",0";
        
      elseif ( (lightLeft > 0) and (lightCenter == 0) and (lightRight == 0) ) then
      
        lightsActions = lightsActions
          .. lightBRRightID .. "," .. tostring(lightLeft) .. ";"
          .. lightBRLeftID .. ",0";
        
      elseif ( (lightLeft == 0) and (lightCenter == 0) and (lightRight > 0) ) then
      
        if ( lightBed == 0 ) then
          
          lightsActions = lightsActions
            .. lightBRBedID .. "," .. lightValFOrNOn .. ";"
            .. lightBRRightID .. ",0";
          
        else
          
          lightsActions = lightsActions
          	.. lightBRLeftID .. "," .. tostring(lightRight) .. ";"
            .. lightBRCenterID .. "," .. tostring(lightRight) .. ";";
        end
        
      else
        
        lightsActions = lightsActions
          .. lightBRLeftID .. "," .. lightValFOrNOn .. ";"
          .. lightBRCenterID .. "," .. lightValFOrNOn .. ";"
          .. lightBRRightID .. "," .. lightValFOrNOn .. ";";
      end
      
    end
    
  end
  
  if ( debugMode ) then fibaro:debug("lightsActions = <" .. lightsActions .. ">"); end
  
elseif ( sceneActID == btnScnActTrplClick + btnKind_OneTwo ) then  ------------------------------------------------------------
  
  fibaro:setGlobal("BRbtnWallMode", "HK");
  
  --[[if ( lightKitchen == 0 ) then
    
    if ( lightHall == 0 ) then
      
      lightsActions = lightKitchenID .. "," .. lightValFOrNOn .. ";"
        .. lightHallID .. "," .. lightValHOrNOn .. ";";
      
    else
      
      lightsActions = lightKitchenID .. "," .. lightValFOrNOn .. ";";
    
    end
    
  else
    
    if ( lightHall == 0 ) then
      lightsActions = lightHallID .. "," .. lightValHOrNOn .. ";";
    else
      lightsActions = lightKitchenID .. ",0;" .. lightHallID .. ",0;";
    end
    
  end--]]
  
end

if ( lightsActions ~= "" ) then
  
  fibaro:setGlobal("lightsQueue", fibaro:getGlobalValue("lightsQueue")
    .. lightsActions);
  
end
