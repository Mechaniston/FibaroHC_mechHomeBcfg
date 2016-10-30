--[[
%% properties
236 value
%% globals
--]]

local debugMode = true;

local vdLightKtnID        = 196;
local vdLightKtnSwitchBtn = "5";
local vdLightHllID        = 207;
local vdLightHllSwitchBtn = "5";

local startSource = fibaro:getSourceTrigger();

local inDoorState, inDoorDT = fibaro:get(248, "value"); -- К:ДверьВнутр
local hallSensState, hallSensDT = fibaro:get(236, "value"); -- К:Сенсор
local hallLux = fibaro:getValue(296, "value"); -- К:Освещенность

local isLightInRoom = false;
if ( -- simple sleep detection
  (tonumber(fibaro:getValue(40, "value")) > 0) -- ctrlBigRoom:СветОснОбщ
--  or ( tonumber(fibaro:getValue(228, "value")) > 0 ) -- БК:УпрРозетка
--  (- бра напол.)
  or (tonumber(fibaro:getValue(230, "value")) > 0) -- БК:Бра(настен.)
  ) then
  isLightInRoom = true;
end

local currentTime = os.date("*t"); -- CAUTION! UTC+4
local twilightMode = false;
if ( fibaro:getGlobalValue("twilightMode") == "0" ) then
  if ( (currentTime.hour < 10) or (currentTime.hour > 21) ) then
    -- 0..8 + 21..24
    twilightMode = true;
  end
else
  twilightMode = true;
end

if ( debugMode ) then
  fibaro:debug("hallSens = " .. hallSensState
    .. ", hallLux = " .. hallLux
    .. ", twilightMode = " .. tostring(twilightMode)
      .. " (H = " .. tostring(currentTime.hour) .. ")"
    .. ", isLightInRoom = " .. tostring(isLightInRoom));
end

if (
  ( --(tonumber(hallSensState) > 0) and
    (tonumber(hallLux) < 70) )
  -- Warning! The Hall Lux Value (70) must be at least more or equal
  -- lighting in hall after this script the lights on for prevent
  -- duplicate call
  or ( startSource["type"] == "other" )
  ) then
  
  if ( debugMode ) then
    fibaro:debug("We need the light! hallSensDT = " .. hallSensDT
      .. ", inDoor = " .. inDoorState .. ", inDoorDT = " .. inDoorDT);
  end
  
  if ( (tonumber(inDoorState) > 0) and (hallSensDT - inDoorDT < 20) ) then
    
    if ( debugMode ) then fibaro:debug("Somebody coming!"); end
    
    if ( (fibaro:getValue(150, "value") == "0")
        or (fibaro:getValue(150, "dead") >= "1") ) then
      
      if ( debugMode ) then fibaro:debug("No entrance light. Switch HallLight ON!"); end
      
      fibaro:call(vdLightHllID, "pressButton", vdLightHllSwitchBtn);
      
    end
    --[[
    if not isLightInRoom then
      local currentTime = os.date("*t");
      if ( (currentTime.hour >= 22) or (currentTime.hour <= 8) ) then
        fibaro:setGlobal("lightsQueue", fibaro:getGlobalValue("lightsQueue")
          .. "150,10;");
      else
        fibaro:setGlobal("lightsQueue", fibaro:getGlobalValue("lightsQueue")
          .. "150,200;");
      end
    else  
      if ( tonumber(hallLux) > 10 ) then
        fibaro:setGlobal("lightsQueue", fibaro:getGlobalValue("lightsQueue")
          .. "150,150;");
      else
        fibaro:setGlobal("lightsQueue", fibaro:getGlobalValue("lightsQueue")
          .. "150,200;");
      end
    end
    --]]
    --fibaro:call(59, "sendPhotoToUser", "52");
    fibaro:call(59, "sendPhotoToEmail", "m@mech.tel");
    
  else
    
    if ( debugMode ) then fibaro:debug("Movement in hall detected!"); end
    
    if ( tonumber(fibaro:getValue(4, "value")) > 0 ) then -- Общее:ПитаниеСвета
      
      if --( (not twilightMode) or isLightInRoom ) then -- 4 wife pleasure, again :(((
        ( isLightInRoom ) then
        
        if ( debugMode ) then fibaro:debug("[No twilight or] there is a light in the BR "); end
        
        if ( (fibaro:getValue(151, "value") == "0")
          or (fibaro:getValue(151, "dead") >= "1") ) then
          
          if ( debugMode ) then fibaro:debug("Turn HallLight ON"); end
          
          if ( tonumber(hallLux) > 10 ) then
            fibaro:setGlobal("lightsQueue", fibaro:getGlobalValue("lightsQueue")
              .. "151,150;");
          else
            fibaro:setGlobal("lightsQueue", fibaro:getGlobalValue("lightsQueue")
              .. "151,200;");
          end
          
          local startTime = os.time();
          while ( os.time() - startTime < 300 ) do
            if ( tonumber(fibaro:getValue(236, "value")) > 0 ) then -- К:Сенсор
              startTime = os.time();
            end
            fibaro:sleep(1500);
          end
          
          if ( debugMode ) then fibaro:debug("Turn HallLight OFF (timeout)"); end
          
          fibaro:call(151, "turnOff");
          
        end
        
      else -- if no light in BigRoom and twilightMode is active
        
        --[[
        if ( tonumber(fibaro:getValue(148, "value")) == 0 ) then -- К_Х:Свет_общ
          if ( tonumber(hallLux) <= 10 ) then
            fibaro:call(150, "setValue", 10);
          end
          
          local startTime = os.time();
          while ( os.time() - startTime < 10 ) do
            if ( tonumber(fibaro:getValue(236, "value")) > 0 ) then -- К:Сенсор
              startTime = os.time();
            end
            fibaro:sleep(1500);
          end
          fibaro:call(150, "turnOff");
        end
        --]]
        
      end
      
    else -- if ( tonumber(fibaro:getValue(4, "value")) > 0 )
      
      --4 wife pleasure :)
      --[[
      if ( debugMode ) then fibaro:debug("No light power source - may be nightly extreme travel from room to refrig.? ;)"); end
      
      if ( fibaro:getGlobalValue("nightMode") == "1" ) then
        
        if ( debugMode ) then fibaro:debug("Check NightMode..Ok"); end
        
        local BR_MD, BR_MD_MT = fibaro:get(202, "value");
        
        if ( hallSensDT - BR_MD_MT < 3 ) then -- outgoing from BR
          
          if ( debugMode ) then fibaro:debug("Check BR exit (hallSensDT" .. hallSensDT .. "; BR_MD_MT = " .. BR_MD_MT .. ").. Ok"); end
          
          if ( (fibaro:getValue(150, "value") == "0")
            or (fibaro:getValue(150, "dead") >= "1") ) then
            
            if ( debugMode ) then fibaro:debug("Turn min light in Hall"); end
            
            fibaro:call(vdLightHllID, "pressButton", vdLightHllSwitchBtn);
            
          end
          
          if ( (fibaro:getValue(149, "value") == "0")
            or (fibaro:getValue(149, "dead") >= "1") ) then
            
            if ( debugMode ) then fibaro:debug("Turn min light in Kitchen"); end
            
            fibaro:call(vdLightKtnID, "pressButton", vdLightKtnSwitchBtn);
            
          end
          
          sleep(2000);
          
          while ( (fibaro:getValue(202, "value") ~= BR_MD)
            and (fibaro:getValue(150, "value") ~= "0")
            and (fibaro:getValue(150, "value") ~= "0") ) do
            
            fibaro:sleep(1500);
            
          end
          
          if ( debugMode ) then fibaro:debug("Time to turn off nigt light!"); end
          
          if ( fibaro:getValue(150, "value") ~= "0" ) then
            
            if ( debugMode ) then fibaro:debug("Turn off light in Kitchen"); end
            
            fibaro:call(vdLightHllID, "pressButton", vdLightHllSwitchBtn);
            
          end
          
          if ( fibaro:getValue(149, "value") ~= "0" ) then
            
            if ( debugMode ) then fibaro:debug("Turn off light in Kitchen"); end
        
            fibaro:call(vdLightKtnID, "pressButton", vdLightKtnSwitchBtn);
            
          end
          
        end
        
      end
      --]]
    end
  end
end
