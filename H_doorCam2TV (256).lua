--[[
%% properties
%% globals
--]]

--[[ -- check setTimeout

-x-[x[
%% properties
39 value
%% events
%% globals
-x-]x]


local startSource = fibaro:getSourceTrigger();
if (startSource["type"] == "other") then
  
  setTimeout(function()
    
    fibaro:call(259, "turnOn");
    
  end, 20000)
  
else
  
  if ( tonumber(fibaro:getValue(39, "value")) > 0 ) then
    
    setTimeout(function()
      
      local delayedCheck0 = false;
      local tempDeviceState0,
        deviceLastModification0 = fibaro:get(39, "value");
      
      if ( (tonumber(fibaro:getValue(39, "value")) > 0)
        and ((os.time() - deviceLastModification0) >= 50) ) then
        
        delayedCheck0 = true;
        
      end
      
      local startSource = fibaro:getSourceTrigger();
      if ( (delayedCheck0 == true)
        or (startSource["type"] == "other") ) then
        
        setTimeout(function()
          
		  fibaro:call(259, "turnOn");
          
        end, 20000)
      
      end
    
    end, 50000)
    
  end
  
end
--]]


-- CONSTS

-- copied from miniMote K_TV (2) {
local TVID = 54;
local TVPwrBtn  	= "1";
local TVTVBtn 		= "2";
local TVHDMIBtn 	= "3";
local TVVolUpBtn 	= "4";
local TVMuteBtn 	= "5";
local TVVolDnBtn 	= "6";
local TVPgUpBtn 	= "7";
local TVRevBtn 		= "8";
local TVPgDnBtn 	= "9";
local TVMenuBtn   	= "10";
local TVUpBtn 		= "11";
local TVDownBtn 	= "17";
local TVLeftBtn 	= "13";
local TVRightBtn 	= "15";
local TVOKBtn 		= "14";
local TVBackBtn 	= "12";
local TVExitBtn 	= "18";
local TVNum0Btn 	= "16";
local TVNum1Btn 	= "19";
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

local HDMIswitch_RT2Kbtn 	= HDMIswitch22Btn;
local HDMIswitch_RT2Kroute = "2";
local HDMIswitch_DC2Kroute = "5";

local HDMIswitchStateID = 292;
local HDMIswitchStateOnBtn  = "2";
local HDMIswitchStateOffBtn = "3";
local HDMIswitchStateChannelBtnOffset = -3;
-- copied from miniMote K_TV (2) }


local debugMode = true;


-- GET ENVS

-- copied from miniMote K_TV (2) {
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
local RTtvMode = getStrGlobalVal("RTtvMode");
-- copied from miniMote K_TV (2) }


local startSource = fibaro:getSourceTrigger();
local currentTime = os.date("*t");
local doorBellSensVal, doorBellSensDT = fibaro:get(188, "value");

local dayMode = (
  (fibaro:getGlobalValue("nightMode") == "0")
  and (currentTime.hour >= 8)
  and (currentTime.hour <= 21) ); -- currentTime.min;);


-- copied from miniMote K_TV (2) {
-- FUNCS

function getHMDI_1stR()
  
  return string.sub(HDMIswitchMode, 1, 1);
  
end

function getHMDI_2ndR()
  
  return string.sub(HDMIswitchMode, 2, 2);
  
end

function isHMDI_PiPon()
  
  return ( string.sub(HDMIswitchMode, 3, 3) == "1" );
  
end

function getHDMI_PiPch()
  
  return string.sub(HDMIswitchMode, 4, 4);
  
end

function isHDMIon()
  
  return ( string.sub(HDMIswitchMode, 5, 5) == "1" );
  
end

function isHDMIinRT2K()
  
  return ( getHMDI_2ndR() == HDMIswitch_RT2Kroute );
  
end

function isTVkHDMI()
  
  return ( string.sub(TVkitchenMode, 1, 4) == "HDMI" );
  
end

function isRTon()
  
  return ( string.sub(RTtvMode, 2, 2) == "1" );
  
end

function setTVkModes( setMode, saveMode )
  
  if ( debugMode ) then
    fibaro:debug("setTVkModes() - TVkM: " .. TVkitchenMode
      .. ", TVkLM: " .. TVkitchenLastMode
      .. ", setM: " .. setMode);
  end
  
  if ( string.sub(setMode, 1, 1) == "*" ) then
    
    setMode = string.sub(setMode, 2);
    
  else
    
    if ( saveMode ) then
      
      TVkitchenLastMode = TVkitchenMode;
      
    else
      
      TVkitchenLastMode = setMode;
      
    end
    
  end
  
  TVkitchenMode = setMode;
  
  fibaro:setGlobal("TVkitchenMode", TVkitchenMode);
  fibaro:setGlobal("TVkitchenLastMode", TVkitchenLastMode);
  
  if ( debugMode ) then
    fibaro:debug("* SET TVkM: " .. TVkitchenMode
      .. ", TVkLM: " .. TVkitchenLastMode);
  end
  
end

function turnTVon()
  
  if ( debugMode ) then
    fibaro:debug("# turnTVon() - TVkM: " .. TVkitchenMode
      .. ", TVkLM: " .. TVkitchenLastMode);
  end
  
  if ( TVkitchenMode == "" ) then
    
    if ( debugMode ) then fibaro:debug("> TV Pwr (on)"); end
    fibaro:call(TVID, "pressButton", TVPwrBtn);
    fibaro:sleep(12000);
    
    if ( TVkitchenLastMode == "" ) then
    
      setTVkModes("TV", false);
      
    else
    
      TVkitchenMode = TVkitchenLastMode;
      fibaro:setGlobal("TVkitchenMode", TVkitchenMode);
      
      if ( debugMode ) then fibaro:debug("* SET TVkM to TVkLM = "
        .. fibaro:getGlobalValue("TVkitchenMode"));
      end
      
    end
    
    return true
    
  else
    
    return false
    
  end
  
end

function turnHDMIon()
  
  if ( debugMode ) then
    fibaro:debug("# turnHDMIon() - TVkM: " .. TVkitchenMode
      .. ", HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  if ( TVkitchenMode == "" ) then
    turnTVon();
  end
  
  if ( not isTVkHDMI() ) then
    
    if ( debugMode ) then fibaro:debug("> TV HDMI"); end
    fibaro:call(TVID, "pressButton", TVHDMIBtn);
    fibaro:sleep(3000);
    
  end
  
  if ( not isHDMIon() ) then
      
    if ( debugMode ) then fibaro:debug("> HDMIsw Pwr (on)"); end
    fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPwrBtn);
    fibaro:call(HDMIswitchStateID, "pressButton", HDMIswitchStateOnBtn);
    
    HDMIswitchMode = fibaro:getGlobalValue("HDMIswitchMode"); -- reload
    
    if ( debugMode ) then
      fibaro:debug("% turnHDMIon() - newHDMIswM: '" .. HDMIswitchMode .. "'");
    end
    
    return true
    
  else
    
    return false
    
  end
  
end

function turnHDMI_RTon()
  
  if ( debugMode ) then
    fibaro:debug("# turnHDMI_RTon() - TVkM: " .. TVkitchenMode
      .. ", HDMIswM: '" .. HDMIswitchMode .. "'"
      .. ", RTtvM: '" .. RTtvMode .. "'");
  end
  
  turnHDMIon();
  
  if ( not isRTon() ) then
    -- RT.TV turn ON
    
    if ( debugMode ) then fibaro:debug("> RT.TV Pwr (on)"); end
    fibaro:call(RTtvID, "pressButton", RTtvPwrBtn);
    fibaro:call(RTtvStateID, "pressButton", RTtvStateOnBtn);
    fibaro:sleep(300);
    
    RTtvMode = fibaro:getGlobalValue("RTtvMode"); -- reload
    
    if ( debugMode ) then
      fibaro:debug("% turnHDMI_RTon() - newRTtvM: '" .. RTtvM .. "'");
    end
    
    -- TODO: copy to VD.HDMIswASstate
    local HDMIswAvlSrc = fibaro:getGlobalValue("HDMIswAvlSrc");
    if ( (string.len(HDMIswAvlSrc) ~= 7)
      or string.sub(HDMIswAvlSrc, 1, 1) ~= "9" ) then
      
      HDMIswAvlSrc = "9110110"; -- !!! HARDCODE !!!
      
    else
      
      local str1 = string.sub(HDMIswAvlSrc, 1, 2);
      local str2 = string.sub(HDMIswAvlSrc, 4, 7);
      
      HDMIswAvlSrc = str1 .. "1" .. str2;
      
    end
    
    fibaro:setGlobal("HDMIswAvlSrc", HDMIswAvlSrc);
    
  end
  
  if ( not isHDMIinRT2K() ) then
    -- HDMI switching
    
    if ( debugMode ) then fibaro:debug("> HDMIsw RT2K"); end
    fibaro:call(HDMIswitchID, "pressButton", HDMIswitch_RT2Kbtn);
    
    local btnStrIdx = tostring(
      tonumber(HDMIswitch_RT2Kbtn)
      + HDMIswitchStateChannelBtnOffset);
      
    fibaro:call(HDMIswitchStateID, "pressButton", btnStrIdx);
    fibaro:sleep(300);
    
    HDMIswitchMode = fibaro:getGlobalValue("HDMIswitchMode"); -- reload
    
    if ( debugMode ) then
      fibaro:debug("% turnHDMI_RTon() - HDMIsw-RT2K "
       .. "(HDMIswStateVDcallBtnIdx = " .. btnStrIdx .. "), newHDMIswM: '"
       .. HDMIswitchMode .. "'");
    end
    
    return true
    
  end
  
  return false
  
end

function forceHDMIon()
  
  if ( isHDMIinRT2K() ) then
    
    HDMI_RTon();
    setTVkModes("HDMI_RT", false);
    
  else
    
    turnHDMIon();
    setTVkModes("HDMI_Other", false);
    
  end
  
end

function HDMI_NextSecRoute()
  -- partially code copied to turnHDMI_PiPon()
  
  if ( debugMode ) then
    fibaro:debug("# HDMI_NextSecRoute() - HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  local curRoute = tonumber(getHMDI_2ndR());
  
  -- code copied from calcNextPiPch
  local newRoute = curRoute;

  local HDMIswAvlSrc = fibaro:getGlobalValue("HDMIswAvlSrc");
  -- 9(0-1_srcIsActive)x6

  -- code copied from turnHDMI_RTon()
  local str1 = string.sub(HDMIswAvlSrc, 1, 2);
  local str2 = string.sub(HDMIswAvlSrc, 4, 7);
  
  HDMIswAvlSrc = str1 .. "1" .. str2;
  
  local firstRoute = newRoute;
  
  repeat
    
    newRoute = newRoute + 1;
    
    -- cycling (max route count = 6)
    if ( newRoute > 6 ) then newRoute = 1; end
    
  until ( (newRoute == firstRoute)
    or (string.sub(HDMIswAvlSrc, newRoute + 1,
      newRoute + 1) == "1") );
  
  local btnIdx = tonumber(HDMIswitch21Btn) + newRoute - 1;
  if ( debugMode ) then
    fibaro:debug("> HDMIsw 2ndRoute++ (" .. tostring(newRoute) 
      .. ", btn #" .. tostring(btnIdx) .. ")");
  end
  fibaro:call(HDMIswitchID, "pressButton", tostring(btnIdx));
  
  local btnStateStrIdx = tostring(btnIdx + HDMIswitchStateChannelBtnOffset);
  fibaro:call(HDMIswitchStateID, "pressButton", btnStateStrIdx);
  fibaro:sleep(300);
  
  if ( debugMode ) then 
    fibaro:debug("HDMIswStateVDcallBtnIdx = " .. btnStateStrIdx);
  end
  
  HDMIswitchMode = fibaro:getGlobalValue("HDMIswitchMode"); -- reload
  
  if ( debugMode ) then
    fibaro:debug("% HDMI_NextSecRoute() - newHDMIswM: '"
      .. HDMIswitchMode .. "'");
  end
  
  if ( tostring(newRoute) == HDMIswitch_RT2Kroute ) then -- switched to RT
    return turnHDMI_RTon();
  else
    if ( tostring(curRoute) == HDMIswitch_RT2Kroute ) then -- switched from RT
      return turnHDMI_RToff();
    end
  end
  
  return (curRoute ~= newRoute);
  
end

function turnTVOff()
  
  if ( debugMode ) then
    fibaro:debug("# turnTVOff() - TVkM: " .. TVkitchenMode);
  end
  
  if ( TVkitchenMode ~= "" ) then
    
    if ( debugMode ) then fibaro:debug("> TV Pwr (off)"); end
    fibaro:call(TVID, "pressButton", TVPwrBtn);
    
    turnHDMIoff();
    --[[
    if ( isHDMIon() ) then
      
      if ( (isRTon())
        and (isHDMIinRT2K()) ) then
        
        turnHDMI_RToff();
        
      --  if ( debugMode ) then fibaro:debug("* Set TVkLM to HDMI_RT"); end
      --  fibaro:setGlobal("TVkitchenLastMode", "HDMI_RT");
      --  
      --else
      --  
      --  if ( debugMode ) then fibaro:debug("* Set TVkLM to HDMI_Other"); end
      --  fibaro:setGlobal("TVkitchenLastMode", "HDMI_Other");
        
      end
      
      turnHDMIoff();
      
    --else
    --  
    --  if ( debugMode ) then fibaro:debug("* Set TVkLM to TV"); end
    --  fibaro:setGlobal("TVkitchenLastMode", "TV");
      
    end--]]
    
    setTVkModes("*", false);
    
    return true
    
  else
    
    if ( debugMode ) then
      fibaro:debug("% turnTVOff() - SET TVkM to ''");
    end
    
    fibaro:setGlobal("TVkitchenMode", "");
    
    return false
    
  end
  
end

function turnHDMIoff()
  
  if ( debugMode ) then
    fibaro:debug("# turnHDMIoff() - TVkM: " .. TVkitchenMode
      .. ", HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  if ( isTVkHDMI() ) then
    
    if ( debugMode ) then fibaro:debug("> TV TV"); end
    fibaro:call(TVID, "pressButton", TVTVBtn);
    
    setTVkModes("TV", false);
    
  end
  
  if ( isHDMIon() ) then
    -- HDMI switch turn OFF
    
    turnHDMI_RToff();
    
    if ( debugMode ) then fibaro:debug("> HDMIsw Pwr (off)"); end
    fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPwrBtn);
    fibaro:call(HDMIswitchStateID, "pressButton", HDMIswitchStateOffBtn);
    
    HDMIswitchMode = fibaro:getGlobalValue("HDMIswitchMode"); -- reload
    
    if ( debugMode ) then
      fibaro:debug("% turnHDMIoff() - newHDMIswM: '" .. HDMIswitchMode .. "'");
    end
    
    return true
    
  end
  
  return false
  
end

function turnHDMI_RToff()
  
  if ( debugMode ) then
    fibaro:debug("# turnHDMI_RToff() - TVkM: " .. TVkitchenMode
      .. ", HDMIswM: '" .. HDMIswitchMode .. "'"
      .. ", RTtvM: '" .. RTtvMode .. "'");
  end
  
  if ( isRTon() and isHDMIinRT2K() ) then
    -- RT.TV turn OFF
    
    if ( debugMode ) then fibaro:debug("> RT.TV Pwr (off)"); end
    fibaro:call(RTtvID, "pressButton", RTtvPwrBtn);
    fibaro:call(RTtvStateID, "pressButton", RTtvOffBtn);
    fibaro:sleep(300);
    
    RTtvMode = fibaro:getGlobalValue("RTtvMode"); -- reload
    
    -- TODO: copy to VD.HDMIswASstate
    local HDMIswAvlSrc = fibaro:getGlobalValue("HDMIswAvlSrc");
    if ( (string.len(HDMIswAvlSrc) ~= 7)
      or string.sub(HDMIswAvlSrc, 1, 1) ~= "9" ) then
      
      HDMIswAvlSrc = "9100110"; -- !!! HARDCODE !!!
      
    else
      
      local str1 = string.sub(HDMIswAvlSrc, 1, 2);
      local str2 = string.sub(HDMIswAvlSrc, 4, 7);
      
      HDMIswAvlSrc = str1 .. "0" .. str2;
      
    end
    
    fibaro:setGlobal("HDMIswAvlSrc", HDMIswAvlSrc);
    
    if ( debugMode ) then
      fibaro:debug("% turnHDMI_RToff() - newHDMIswM: '"
        .. HDMIswitchMode .. "'");
    end
    
    return true
    
  end
  
  return false

end

function calcNextPiPch()
  
  if ( debugMode ) then
    fibaro:debug("calcNextPiPch() - HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  local route1 = getHMDI_1stR();
  local route2 = getHMDI_2ndR();
  local newPiPch = 0;
  
  if ( isHMDI_PiPon() ) then
    
    newPiPch = tonumber(getHDMI_PiPch());
    
  else
    
    newPiPch = tonumber(route1);
    
  end
  
  local HDMIswAvlSrc = fibaro:getGlobalValue("HDMIswAvlSrc");
  -- 9(0-1_srcIsActive)x6
  
  local firstRoute = newPiPch;
  
  repeat
    
    newPiPch = newPiPch + 1;
    
    -- skip cur route
    if ( (newPiPch < 6) and (newPiPch == tonumber(route2)) ) then
      newPiPch = newPiPch + 1;
    end
    
    -- cycling (max route count = 6)
    if ( newPiPch > 6 ) then newPiPch = 1; end
    
  until ( (newPiPch == firstRoute)
    or (string.sub(HDMIswAvlSrc, newPiPch + 1,
      newPiPch + 1) == "1") );
      
    --if ( debugMode ) then fibaro:debug("> HDMIsw PiP sel"); end
    --fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPiPSelBtn);
  
  HDMIswitchMode = route1 .. route2 .. "1" .. tostring(newPiPch) .. "1";
  fibaro:setGlobal("HDMIswitchMode", HDMIswitchMode);
  
  if ( debugMode ) then
    fibaro:debug("calcNextPiPch() - newHDMIswM: '"
      .. HDMIswitchMode .. "'");
  end
  
  return newPiPch;
  
end

function turnHDMI_PiPon()
  
  if ( debugMode ) then
    fibaro:debug("# turnHDMI_PiPon() - HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  --turnHDMIon();
  
  if ( not isHMDI_PiPon() ) then
    
    local curHDMIswitchMode = HDMIswitchMode;
    local route1 = getHMDI_1stR();
    local route2 = getHMDI_2ndR();
    local newPiPch = calcNextPiPch();
    
    -- WARNING! The turning on the PiP mode setted 2nd ch. equal 1st
    -- Solution: 1. save (don't correct 2nd route in HDMIswMode)
    -- 2. set 1st route as 2nd in PiP on (current select)
    --   and restore in PiPoff
    -- TODO: autoselect depending TVsets on
    --  (note: in current (PiPon) moment => need to save)

    -- 2nd solution (partially code copied from HDMI_NextSecRoute())
    local btnIdx = tonumber(HDMIswitch11Btn) + tonumber(route2) - 1;
    
    if ( debugMode ) then
      fibaro:debug("> HDMIsw 1stRoute = " .. route2);
    end
    fibaro:call(HDMIswitchID, "pressButton", tostring(btnIdx));
    fibaro:sleep(4000);
    
    if ( debugMode ) then fibaro:debug("> HDMIsw PiP (on)"); end
    fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPiPBtn);
    
    -- 1st solution - nothing to do
    HDMIswitchMode = route1 .. route2 .. "1" .. newPiPch .. "1";
    
    fibaro:setGlobal("HDMIswitchMode", HDMIswitchMode);
    
    if ( debugMode ) then
      fibaro:debug("% turnHDMI_PiPon() - newHDMIswM: '"
        .. HDMIswitchMode .. "'");
    end
    
    return true
    
  end
  
  return false
  
end

function turnHDMI_PiPoff()
  
  if ( debugMode ) then
    fibaro:debug("# turnHDMI_PiPoff() - HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  if ( isHMDI_PiPon() ) then
    -- HDMI switch PiP mode OFF
    
    -- restore route
    local route1 = getHMDI_1stR();
    local route2 = getHMDI_2ndR();
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
    fibaro:sleep(4000);
    
    --auto because routes changed
    --if ( debugMode ) then fibaro:debug("> HDMIsw PiP (off)"); end
    --fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPiPBtn);
    
    HDMIswitchMode = route1 .. route2 .. "0" .. getHDMI_PiPch() .. "1";
    
    fibaro:setGlobal("HDMIswitchMode", HDMIswitchMode);
    
    if ( debugMode ) then
      fibaro:debug("% turnHDMI_PiPoff() - newHDMIswM: '"
        .. HDMIswitchMode .. "'");
    end
    
    return true
    
  end
  
  return false
  
end

function turnHDMI_PiPent()
  
  if ( debugMode ) then
    fibaro:debug("# turnHDMI_PiPent() - HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  if ( isHDMI_PiPon() ) then
    
    local curPiPch = getHDMI_PiPch();
    
    if ( debugMode ) then fibaro:debug("> HDMIsw PiP ent"); end
    fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPiPEntBtn);
    fibaro:sleep(4000);
    
    -- restore route
    local route1 = getHDMI_1stR();
    -- 1st solution (see to turnHDMI_PiPon()) - no need action
    -- 2nd solution
    if ( debugMode ) then
      fibaro:debug("> HDMIsw 1stRoute = " .. route1);
    end
    fibaro:call(HDMIswitchID, "pressButton",
      tostring(tonumber(HDMIswitch11Btn) + tonumber(route1) - 1)
      );
    
    if ( tonumber(curPiPch) == 0 ) then
    
      HDMIswitchMode = route1 .. getHMDI_2ndR() .. "001";
      
    else
      
      HDMIswitchMode = route1 .. curPiPch .. "0" .. curPiPch .. "1";
    
    end
    
    fibaro:setGlobal("HDMIswitchMode", HDMIswitchMode);
    
    if ( debugMode ) then
      fibaro:debug("% turnHDMI_PiPent() - newHDMIswM: '"
        .. HDMIswitchMode .. "'");
    end
    
    return true
    
  end
  
  return false
  
end
-- copied from miniMote K_TV (2) }


-- PROCESS


fibaro:sleep(50); -- to prevent to kill all instances
if ( fibaro:countScenes() > 1 ) then
  if ( debugMode ) then fibaro:debug("Double start"
    .. " (" .. tostring(fibaro:countScenes()) .. ").. Abort dup!"); end
  fibaro:abort();
end

if ( debugMode ) then fibaro:debug("doorBellSens!"); end

if ( (tonumber(doorBellSensVal) > 0)
  or (startSource["type"] == "other") ) then
  --and (os.time() - deviceLastModification0) >= 7) then
  
  if ( (TVkitchenMode ~= "")
    and (--(TVkitchenMode ~= "HDMI_Other") or
      (getHDMI_2ndR() ~= HDMIswitch_DC2Kroute)) ) then
    
    if ( debugMode ) then fibaro:debug("Show door cam as PiP!"); end
    
    local oldTVkitchenMode = TVkitchenMode;
    local oldHDMIswitchMode = HDMIswitchMode;
    
    turnHDMIon();
    
    if ( getHDMI_2ndR() ~= HDMIswitch_DC2Kroute ) then
      
      turnHDMI_PiPon();
      fibaro:sleep(3000);
      
      while ( getHDMI_PiPch() ~= HDMIswitch_DC2Kroute ) do
        
        if ( debugMode ) then fibaro:debug("> HDMIsw PiP sel"); end
        fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPiPSelBtn);
        
        calcNextPiPch();
        
        fibaro:sleep(4000);
        
      end
      
      if ( debugMode ) then fibaro:debug("Showing in PiP done. Wait.."); end
      
      local curTime = os.time();
      fibaro:sleep(2000);
      
      while ( (os.time() - curTime <= 60)
        and (fibaro:getValue(248, "value") == "0")
        and (fibaro:getValue(187, "value") == "0")
        and (string.sub(getStrGlobalVal("HDMIswitchMode"), 2, 2) ~= "5")
        and (string.sub(getStrGlobalVal("HDMIswitchMode"), 3, 3) == "1") ) do
        
        fibaro:sleep(2000);
        
      end
      
      if ( debugMode ) then
        fibaro:debug("Waiting is left (DoorState = "
          .. fibaro:getValue(248, "value") .. "/"
          .. fibaro:getValue(187, "value") .. ", "
          .. "HDMIswM = " .. getStrGlobalVal("HDMIswitchMode") .. ", "
          .. "timeDiff = " .. tostring(os.time() - curTime) .. ")");
      end
      
      if ( string.sub(
        getStrGlobalVal("HDMIswitchMode"), 2, 2) ~= HDMIswitch_DC2Kroute ) then
        
        turnHDMI_PiPoff();
        
      end
      
    end
    
    if ( string.sub(oldTVkitchenMode, 1, 4) ~= "HDMI" ) then
      
      turnHDMIoff();
      
    end
    
  end
  
end
