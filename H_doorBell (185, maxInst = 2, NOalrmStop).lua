--[[
%% properties
188 value
%% globals
--]]


-- CONSTS

local TVID = 54;
local TVPgUpBtn 	= "1";
local TVPgDnBtn 	= "2";
local TVVolUpBtn 	= "3";
local TVMuteBtn 	= "4";
local TVVolDnBtn 	= "5";
local TVHDMIBtn 	= "6";
local TVTVBtn 		= "7";
local TVPwrBtn  	= "8";
local TVMenuBtn   = ""; -- !!!

local HDMIswitchID = 289;
local HDMIswitchPwrBtn 		= "1";
local HDMIswitchPiPBtn 		= "4";
local HDMIswitchPiPSelBtn = "5";
local HDMIswitchPiPEntBtn = "6";
local HDMIswitch11Btn 		= "7";
local HDMIswitch12Btn 		= "8";
local HDMIswitch13Btn 		= "9";
local HDMIswitch14Btn 		= "10";
local HDMIswitch15Btn 		= "11";
local HDMIswitch16Btn 		= "12";
local HDMIswitch21Btn 		= "13";
local HDMIswitch22Btn 		= "14";
local HDMIswitch23Btn 		= "15";
local HDMIswitch24Btn 		= "16";
local HDMIswitch25Btn 		= "17";
local HDMIswitch26Btn 		= "18";

local HDMIswitchStateID = 292;
local HDMIswitchStateOnBtn  = "2";
local HDMIswitchStateOffBtn = "3";
local HDMIswitchStateChannelBtnOffset = -3;


local debugMode = true;


-- GET ENVS

function getStrGlobalVal( valName )
  
  local val = fibaro:getGlobalValue(valName);
  
  if ( val == "NaN" ) then
    val = "";
  end
  
  if ( debugMode ) then
    
    fibaro:debug("getStrGlobalVal() `" .. valName .. "` = " .. val );
    
  end
  
  return val;
  
end


local TVkitchenMode = getStrGlobalVal("TVkitchenMode");
local HDMIswitchMode = getStrGlobalVal("HDMIswitchMode");


local startSource = fibaro:getSourceTrigger();
local currentTime = os.date("*t");
local doorBellSensVal, doorBellSensDT = fibaro:get(188, "value");

local dayMode = (
  (fibaro:getGlobalValue("nightMode") == "0")
  and (currentTime.hour >= 8)
  and (currentTime.hour <= 21) ); -- currentTime.min;);


-- FUNCS

function turnHDMIon()
  
  if ( debugMode ) then
    fibaro:debug("turnHDMIon() - TVkM: " .. TVkitchenMode
      .. ", HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  if ( TVkitchenMode == "" ) then
    turnTVon();
  end
  
  if ( string.sub(TVkitchenMode, 1, 4) ~= "HDMI" ) then
    
    if ( debugMode ) then fibaro:debug("> TV HDMI"); end
    fibaro:call(TVID, "pressButton", TVHDMIBtn);
    fibaro:sleep(2000);
    
  end
  
  if ( string.sub(HDMIswitchMode, 4, 4) ~= "1" ) then
      
    if ( debugMode ) then fibaro:debug("> HDMIsw Pwr (on)"); end
    fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPwrBtn);
    fibaro:call(HDMIswitchStateID, "pressButton", HDMIswitchStateOnBtn);
    
    HDMIswitchMode = fibaro:getGlobalValue("HDMIswitchMode"); -- reload
    
    return true
    
  else
    
    return false
    
  end
  
end

function turnHDMIoff()
  
  if ( debugMode ) then
    fibaro:debug("turnHDMIoff() - TVkM: " .. TVkitchenMode
      .. ", HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  if ( string.sub(TVkitchenMode, 1, 4) == "HDMI" ) then
    
    if ( debugMode ) then fibaro:debug("> TV TV"); end
    fibaro:call(TVID, "pressButton", TVTVBtn);
    
    setTVkModes("TV", false);
    
  end
  
  if ( string.sub(HDMIswitchMode, 4, 4) == "1" ) then
    -- HDMI switch turn OFF
    
    --turnHDMI_RToff();
    
    if ( debugMode ) then fibaro:debug("> HDMIsw Pwr (off)"); end
    fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPwrBtn);
    fibaro:call(HDMIswitchStateID, "pressButton", HDMIswitchStateOffBtn);
    
    HDMIswitchMode = fibaro:getGlobalValue("HDMIswitchMode"); -- reload
    
    return true
    
  end
  
  return false
  
end

function calcNextPiProute()
  
  if ( debugMode ) then
    fibaro:debug("calcNextPiProute() - HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  local route1 = string.sub(HDMIswitchMode, 1, 1);
  local route2 = string.sub(HDMIswitchMode, 2, 2);
  local newPiProute = 0;
  
  if ( tonumber(string.sub(HDMIswitchMode, 3, 3)) == 0 ) then
    
    newPiProute = tonumber(route1) + 1;
    
  else
    
    newPiProute = tonumber(string.sub(HDMIswitchMode, 3, 3)) + 1;
    
  end
  
  -- !!! HARDCODE !!!
  if ( newPiProute == 4 ) then newPiProute = newPiProute + 1; end -- skip BDpl
  
  -- skip cur route
  if ( newPiProute == route2) then newPiProute = newPiProute + 1; end
  
  -- !!! HARDCODE !!! skip unsed route
  if ( newPiProute > 5 ) then newPiProute = 1; end -- > 6
  
  HDMIswitchMode = route1 .. route2 .. tostring(newPiProute) .. "1";
  fibaro:setGlobal("HDMIswitchMode", HDMIswitchMode);
  
  if ( debugMode ) then
    fibaro:debug("calcNextPiProute() - newHDMIswM: '"
      .. HDMIswitchMode .. "'");
  end
  
  return newPiProute;
  
end

function turnHDMI_PiPon()
  
  if ( debugMode ) then
    fibaro:debug("turnHDMI_PiPon() - HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  --turnHDMIon();
  
  if ( tonumber(string.sub(HDMIswitchMode, 3, 3)) == 0 ) then
    -- HDMI switch PiP mode ON
    
    -- WARNING! The turning on the PiP mode setted 2nd ch. equal 1st
    -- Solution: 1. save (don't correct 2nd route in HDMIswMode)
    -- 2. set 1st route as 2nd in PiP on (current select)
    --   and restore in PiPoff
    -- TODO: autoselect depending TVsets on
    --  (note: in current (PiPon) moment => need to save)
    
    -- 2nd solution (partially code copied from HDMI_NextSecRoute())
    local curHDMIswitchMode = HDMIswitchMode;
    local route1 = string.sub(HDMIswitchMode, 1, 1);
    local route2 = string.sub(HDMIswitchMode, 2, 2);
    local btnIdx = tonumber(HDMIswitch11Btn) + tonumber(route2) - 1;
    
    if ( debugMode ) then
      fibaro:debug("> HDMIsw 1stRoute = " .. route2);
    end
    fibaro:call(HDMIswitchID, "pressButton", tostring(btnIdx));
    fibaro:sleep(4000);
    
    local btnStrIdx = tostring(btnIdx + HDMIswitchStateChannelBtnOffset);
    HDMIswitchMode = route2 .. route2 .. route2 .. "1";
    
    if ( debugMode ) then fibaro:debug("> HDMIsw PiP (on)"); end
    fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPiPBtn);
    
    local newPiProute = calcNextPiProute();
    
    -- 2nd solution - save 1st route
    HDMIswitchMode = route1 .. route2 .. newPiProute .. "1";
    fibaro:setGlobal("HDMIswitchMode", HDMIswitchMode);
    
    if ( debugMode ) then
      fibaro:debug("turnHDMI_PiPon() - newHDMIswM: '"
        .. HDMIswitchMode .. "'");
    end
    
    return true
    
  end
  
  return false
  
end

function turnHDMI_PiPoff()
  
  if ( debugMode ) then
    fibaro:debug("turnHDMI_PiPoff() - HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  if ( tonumber(string.sub(HDMIswitchMode, 3, 3)) > 0 ) then
    -- HDMI switch PiP mode OFF
    
    -- restore route
    local route1 = string.sub(HDMIswitchMode, 1, 1);
    local route2 = string.sub(HDMIswitchMode, 2, 2);
    -- 1st solution (see to turnHDMI_PiPon()) - restore 2nd route
    --[[if ( debugMode ) then
      fibaro:debug("> HDMIsw 2stRoute = " .. route2);
    end
    
    fibaro:call(HDMIswitchID, "pressButton",
      tostring(tonumber(HDMIswitch21Btn) + tonumber(route2) - 1)
      );
    --]]
    -- 2nd solution - restore 1st route
    if ( debugMode ) then
      fibaro:debug("> HDMIsw 1stRoute = " .. route1);
    end
    fibaro:call(HDMIswitchID, "pressButton",
      tostring(tonumber(HDMIswitch11Btn) + tonumber(route1) - 1)
      );
    
    if ( debugMode ) then fibaro:debug("> HDMIsw PiP (off)"); end
    --auto because routes changed
    --fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPiPBtn);
    
    HDMIswitchMode = route1 .. route2 .. "01";
    fibaro:setGlobal("HDMIswitchMode", HDMIswitchMode);
    
    if ( debugMode ) then
      fibaro:debug("turnHDMI_PiPoff() - newHDMIswM: '"
        .. HDMIswitchMode .. "'");
    end
    
    return true
    
  end
  
  return false
  
end

function turnHDMI_PiPent()
  
  if ( debugMode ) then
    fibaro:debug("turnHDMI_PiPent() - HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  local curPiProute = string.sub(HDMIswitchMode, 3, 3);
  
  if ( tonumber(curPiProute) > 0 ) then
    -- HDMI switch PiP ENTER
    
    if ( debugMode ) then fibaro:debug("> HDMIsw PiP ent"); end
    fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPiPEntBtn);
    fibaro:sleep(4000);
    
    -- restore route
    local route1 = string.sub(HDMIswitchMode, 1, 1);
    -- 1st solution (see to turnHDMI_PiPon()) - no need action
    -- 2nd solution
    if ( debugMode ) then
      fibaro:debug("> HDMIsw 1stRoute = " .. route1);
    end
    fibaro:call(HDMIswitchID, "pressButton",
      tostring(tonumber(HDMIswitch11Btn) + tonumber(route1) - 1)
      );
    
    HDMIswitchMode = route1 .. curPiProute .. "01";
    fibaro:setGlobal("HDMIswitchMode", HDMIswitchMode);
    
    if ( debugMode ) then
      fibaro:debug("turnHDMI_PiPent() - newHDMIswM: '"
        .. HDMIswitchMode .. "'");
    end
    
    return true
    
  end
  
  return false
  
end


-- PROCESS


fibaro:sleep(50); -- to prevent kill all instances
if ( fibaro:countScenes() > 1 )
  then
  if ( debugMode ) then fibaro:debug("Double start.. Abort dup!"); end
  fibaro:abort();
end

if ( debugMode ) then fibaro:debug("doorBellSens!"); end

if ( (tonumber(doorBellSensVal) > 0)
  or (startSource["type"] == "other") ) then
  --and (os.time() - deviceLastModification0) >= 7) then
  
  if ( debugMode ) then fibaro:debug("Send notif. to phone"); end
  fibaro:call(184, "sendDefinedPushNotification", "184");
  
  --if (tonumber(fibaro:getGlobalValue("LenaInHomeB")) == tonumber("1")) then
  --    fibaro:call(154, "sendDefinedPushNotification", "184");
  --end
  
  --if (tonumber(fibaro:getGlobalValue("LeraInHomeB")) == tonumber("1")) then
  --   fibaro:call(157, "sendDefinedPushNotification", "184");
  --end
  
  -- Kitchen TV PiP {
  if ( (TVkitchenMode ~= "")
    and ((TVkitchenMode ~= "HDMI_Other")
      or (string.sub(HDMIswitchMode, 2, 2) ~= "5")) ) then
    
    if ( debugMode ) then fibaro:debug("Show door cam as PiP!"); end
    
    setTimeout(function()
      
      local oldTVkitchenMode = TVkitchenMode;
      local oldHDMIswitchMode = HDMIswitchMode;
      
      turnHDMIon();
      
      if ( string.sub(HDMIswitchMode, 2, 2) ~= "5" ) then
        
        turnHDMI_PiPon();
        
        while ( string.sub(HDMIswitchMode, 3, 3) ~= "5" ) do
          
          calcNextPiProute();
          
          if ( debugMode ) then fibaro:debug("> HDMIsw PiP sel"); end
          fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPiPSelBtn);
          
          fibaro:sleep(1000);
          
        end
        
        if ( debugMode ) then fibaro:debug("Showing in PiP done. Wait.."); end
          
        local curTime = os.time();
        
        while ( (os.time() - curTime <= 60)
          and (fibaro:getValue(248, "value") == 0)
          and (fibaro:getValue(187, "value") == 0)
          and (string.sub(HDMIswitchMode, 2, 2) ~= "5") ) do
          fibaro:sleep(1000);
        end
        
        if ( debugMode ) then
          fibaro:debug("Waiting is left (sM = " .. HDMIswitchMode
            .. ", oldKM = " .. oldTVkitchenMode .. ")");
        end
        
        if ( string.sub(HDMIswitchMode, 2, 2) ~= "5" ) then
          turnHDMI_PiPoff();
        end
        
      end
      
      if ( (string.sub(oldTVkitchenMode, 1, 4) ~= "HDMI")
        or (string.sub(HDMIswitchMode, 2, 2) ~= "5") ) then
        
        turnHDMIoff();
        
      end
      
    end, 0);
    
  end
  -- Kitchen TV PiP }
  
end

for i = 1, 3, 1 do
  if ( dayMode ) then
    
    if ( debugMode ) then fibaro:debug("BELL!!"); end
    
    fibaro:call(219, "pressButton", 5); -- SONOS play bell sound file
    fibaro:call(288, "turnOn"); -- Bell
    
  end
  
  if ( debugMode ) then fibaro:debug("Start Door(Bell)Light blinking"); end
  for i = 1, 3, 1 do
    fibaro:call(286, "turnOn");
    fibaro:sleep(1000);
    fibaro:call(286, "turnOff");
    fibaro:sleep(1000);
  end
  if ( debugMode ) then fibaro:debug("Finish Bell blinking"); end
    
  if ( dayMode ) then
    
    fibaro:call(288, "turnOff"); -- Bell
    
  end
  
end
