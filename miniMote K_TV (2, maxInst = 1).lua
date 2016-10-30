--[[
%% properties
291 sceneActivation
%% globals
--]]
--291 value


-- CONSTS

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
local HDMIswitchStateChannelBtnOffset = -1;

local RTtvID = 274;
local RTtvPwrBtn 	  = "1";
local RTtvMenuBtn 	= "2";
local RTtvBackBtn 	= "6";
local RTtvUpBtn 	  = "3";
local RTtvDownBtn 	= "13";
local RTtvLeftBtn 	= "7";
local RTtvRightBtn 	= "9";
local RTtvOKBtn 	  = "8";
local RTtvChUpBtn 	= "5";
local RTtvChDownBtn = "10";
local RTtvRevBtn 	  = "4"; -- UNUSED yet!!!
local RTtvPiPBtn 	  = "15"; -- UNUSED yet!!!

local RTtvStateID = 293;
local RTtvStateOnBtn  		  = "2";
local RTtvStateOffBtn 		  = "3";
local RTtvStateMenuOffBtn 	= "4";
local RTtvStateMenuNormBtn 	= "5";
local RTtvStateMenuOKBtn 		= "6";


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

local buttonPressed = fibaro:getValue(291, "sceneActivation");

local TVkitchenMode = getStrGlobalVal("TVkitchenMode");
 -- TV, HDMI, HDMI_Other, HDMI_RT, TVMenu, Ext
local TVkitchenLastMode = getStrGlobalVal("TVkitchenLastMode");

local HDMIswitchMode = getStrGlobalVal("HDMIswitchMode");
 -- 5 num code: [1stCh_1-6][2ndCh_1-6][PiPMode_0-1][PiPCh_1-6][OnOff_0-1]

local RTtvMode = getStrGlobalVal("RTtvMode");
 -- 2 num code: [MenuMode_0-2 : 1 - normal, 2 - ch.sel.][OnOff_0-1]

if ( debugMode ) then
  fibaro:debug("Key pressed: " .. buttonPressed);
end


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
  
  if ( isHMDI_PiPon() ) then
    
    local curPiPch = getHDMI_PiPch();
    
    if ( debugMode ) then fibaro:debug("> HDMIsw PiP ent"); end
    fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPiPEntBtn);
    fibaro:sleep(4000);
    
    -- restore route
    local route1 = getHMDI_1stR();
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


-- PROCESS

-- General turn on for the any action
if ( turnTVon() ) then
  
  if ( isTVkHDMI() ) then
    
    if ( TVkitchenMode == "HDMI_RT" ) then
      
      turnHDMI_RTon()
      
    else
      
      turnHDMIon();
      
    end
    
  end
  
  return
  
else
  
  if ( isTVkHDMI() ) then
    
    if ( TVkitchenMode == "HDMI_RT" ) then
      
      turnHDMI_RTon()
      
    else
      
      turnHDMIon();
      
    end
    
  end
  
end

-- Key pressing
if ( tonumber(buttonPressed) == 1) then ---------------------------------------
  
  if ( isTVkHDMI() and isHDMIon() ) then
    
    if ( isHMDI_PiPon() ) then
      
      if ( debugMode ) then fibaro:debug("> HDMIsw PiP sel"); end
      fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPiPSelBtn);
      
      calcNextPiPch();
      
    else
      
      if ( TVkitchenMode == "HDMI" ) then
        
        HDMI_NextSecRoute();
        
      elseif ( TVkitchenMode == "HDMI_RT" ) then
        
        if ( string.sub(RTtvMode, 1, 1) == "1" ) then -- RT.Menu normal
        
          if ( debugMode ) then
            fibaro:debug("> RT.TV OK (norm. menu)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvOKBtn);
          
        elseif ( string.sub(RTtvMode, 1, 1) == "2" ) then -- RT.Menu OK
          
          if ( debugMode ) then
            fibaro:debug("> RT.TV up (OK menu)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvUpBtn);
          
        else
          
          if ( debugMode ) then fibaro:debug("> RT.TV ChUp"); end
          fibaro:call(RTtvID, "pressButton", RTtvChUpBtn);
          
        end
    
      elseif ( TVkitchenMode == "HDMI_Other" ) then
        
        HDMI_NextSecRoute();
        
      else
        
        
        
      end
      
    end
    
  else
    
    if ( TVkitchenMode == "TVMenu" ) then
      
      if ( (TVkitchenLastMode == "HDMI_RT")
        and (isHDMIinRT2K()) and (isHDMIon()) ) then
        
        if ( string.sub(RTtvMode, 1, 1) ~= "1" ) then -- RT.Menu normal
          -- exit from RT.TV Menu normal mode
          
          if ( debugMode ) then
            fibaro:debug("> RT.TV Menu (exit from normal)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvRevBtn);
          fibaro:call(RTtvStateID, "pressButton", RTtvStateMenuOffBtn);
          
        else
          -- set RT.TV Menu normal mode
          
          if ( debugMode ) then
            fibaro:debug("> RT.TV Menu (enter to normal)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvMenuBtn);
          fibaro:call(RTtvStateID, "pressButton", RTtvStateMenuNormBtn);
          
          setTVkModes(TVkitchenLastMode, false);
          
        end
        
      else
      
        if ( debugMode ) then fibaro:debug("> TV OK (TV menu)"); end
        fibaro:call(TVID, "pressButton", TVOKBtn);
        
      end
      
    elseif ( TVkitchenMode == "Ext" ) then
      
      -- TODO: Pref.Prog+
      
    elseif ( TVkitchenMode == "ProgNum" ) then
      
      -- TODO: 1-3 channel num
      
    else -- TV
      
      -- set default mode
      if ( TVkitchenMode ~= "TV" ) then
        setTVkModes("TV", false);
      end
      
      if ( debugMode ) then fibaro:debug("> TV PgUp"); end
      fibaro:call(TVID, "pressButton", TVPgUpBtn);
      
    end
      
  end
  
elseif ( tonumber(buttonPressed) == 2) then -----------------------------------
  
  if ( isTVkHDMI() and isHDMIon() ) then
    
    if ( isHMDI_PiPon() ) then
      
      if ( debugMode ) then fibaro:debug("> HDMIsw PiP sel"); end
      fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPiPSelBtn);
      
      calcNextPiPch();
      
    else
      
      if ( TVkitchenMode == "HDMI_RT" ) then
        
        if ( string.sub(RTtvMode, 1, 1) == "1" ) then -- RT.Menu normal
          
          
          
        elseif ( string.sub(RTtvMode, 1, 1) == "2" ) then -- RT.Menu OK
          
          if ( debugMode ) then
            fibaro:debug("> RT.TV ChUp (OK menu page up)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvChUpBtn);
          
        else
          -- force set Ext mode
          
          setTVkModes("*Ext", false);
          
        end
        
      else
        -- force set Ext mode
        
        setTVkModes("*Ext", false);
        
      end
      
    end
    
  else
    
    if ( TVkitchenMode == "TVMenu" ) then
      -- force set Ext mode
      
      setTVkModes("*Ext", false);
      
    elseif ( TVkitchenMode == "Ext" ) then
      -- exit from Ext mode
      
      setTVkModes(TVkitchenLastMode, false);
      
    elseif ( TVkitchenMode == "ProgNum" ) then
      -- force set Ext mode
      
      setTVkModes("*Ext", false);
      
    else -- TV
      -- set Ext mode
      
      setTVkModes("Ext", true);
      
    end
    
  end
  
elseif ( tonumber(buttonPressed) == 3) then -----------------------------------
  
  if ( isTVkHDMI() and isHDMIon() ) then
    
    if ( isHMDI_PiPon() ) then
      
      turnHDMI_PiPoff();
      
    else
      
      if ( TVkitchenMode == "HDMI" ) then
        -- HDMI -> TV
        
        turnHDMIoff();
        
      elseif ( TVkitchenMode == "HDMI_RT" ) then
        
        if ( string.sub(RTtvMode, 1, 1) == "1" ) then -- RT.Menu normal
          
          if ( debugMode ) then
            fibaro:debug("> RT.TV Back (norm. menu)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvBackBtn);
          
        elseif ( string.sub(RTtvMode, 1, 1) == "2" ) then -- RT.Menu OK
          -- exit from RT.TV Menu OK mode
          
          if ( debugMode ) then
            fibaro:debug("> RT.TV OK (OK menu mode end with select)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvOKBtn);
          fibaro:call(RTtvStateID, "pressButton", RTtvStateMenuOffBtn);
          
        else
          
          if ( debugMode ) then fibaro:debug("> TV VolUp"); end
          fibaro:call(TVID, "pressButton", TVVolUpBtn);
          
        end
        
      elseif ( TVkitchenMode == "HDMI_Other" ) then
        
        if ( debugMode ) then fibaro:debug("> TV VolUp"); end
        fibaro:call(TVID, "pressButton", TVVolUpBtn);
        
      else
        
        if ( debugMode ) then fibaro:debug("> TV VolUp"); end
        fibaro:call(TVID, "pressButton", TVVolUpBtn);
        
      end
      
    end
    
  else
    
    if ( TVkitchenMode == "HDMI" ) then
      
      forceHDMIon();
      
    elseif ( TVkitchenMode == "TVMenu" ) then
      
      if ( (TVkitchenLastMode == "HDMI_RT")
        and (isHDMIinRT2K())
        and (isHDMIon()) ) then -- HDMI on
        
        if ( string.sub(RTtvMode, 1, 1) ~= "2" ) then -- RT.Menu OK
          -- start RT.TV Menu OK mode
          
          if ( debugMode ) then
            fibaro:debug("> RT.TV OK (OK menu mode begin)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvOKBtn);
          fibaro:call(RTtvStateID, "pressButton", RTtvStateMenuOKBtn);
          
          setTVkModes(TVkitchenLastMode, false);
          
        end
        
      else
      
        if ( debugMode ) then fibaro:debug("> TV Back"); end
        fibaro:call(TVID, "pressButton", TVBackBtn);
        
      end
      
    elseif ( TVkitchenMode == "Ext" ) then
      -- turn TV and other Off
      
      turnTVOff();
      
    elseif ( TVkitchenMode == "ProgNum" ) then
      
      -- TODO: 4-6 channel num
      
    else -- TV
      
      -- set default mode
      if ( TVkitchenMode ~= "TV" ) then
        setTVkModes("TV", false);
      end
      
      if ( debugMode ) then fibaro:debug("> TV VolUp"); end
      fibaro:call(TVID, "pressButton", TVVolUpBtn);
      
    end
    
  end
  
elseif ( tonumber(buttonPressed) == 4) then -----------------------------------
  
  if ( isTVkHDMI() and isHDMIon() ) then
    
    if ( isHMDI_PiPon() ) then
      
      turnHDMI_PiPoff();
      
    else
      
      if ( TVkitchenMode == "HDMI" ) then
        -- exit from HDMI mode
        
        setTVkModes(TVkitchenLastMode, false);
        
      elseif ( TVkitchenMode == "HDMI_RT" ) then
        
        setTVkModes("*HDMI", false);
        
      elseif ( TVkitchenMode == "HDMI_Other" ) then
        
        setTVkModes("*HDMI", false);
        
      end
      
    end
    
  else
    
    if ( TVkitchenMode == "TVMenu" ) then
      -- force set HDMI mode
      
      forceHDMIon();
      setTVkModes("*HDMI", false);
      
    elseif ( TVkitchenMode == "Ext" ) then
      -- force set HDMI mode
      
      forceHDMIon();
      setTVkModes("*HDMI", false);
      
    elseif ( TVkitchenMode == "ProgNum" ) then
      -- force set HDMI mode
      
      forceHDMIon();
      setTVkModes("*HDMI", false);
      
    else -- TV
      -- set HDMI mode
      
      forceHDMIon();
      setTVkModes("HDMI", true);
      
    end
    
  end
  
elseif ( tonumber(buttonPressed) == 5) then -----------------------------------
  
  if ( isTVkHDMI() and isHDMIon() ) then
    
    if ( isHMDI_PiPon() ) then
      
      turnHDMI_PiPent();
      
    else
      
      if ( TVkitchenMode == "HDMI" ) then
        
        turnHDMI_PiPon();
        
      elseif ( TVkitchenMode == "HDMI_RT" ) then
        
        if ( string.sub(RTtvMode, 1, 1) == "1" ) then -- RT.Menu normal
          
          if ( debugMode ) then
            fibaro:debug("> RT.TV Left (norm. menu)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvLeftBtn);
          
        elseif ( string.sub(RTtvMode, 1, 1) == "2" ) then -- RT.Menu OK
          
          if ( debugMode ) then
            fibaro:debug("> RT.TV Down (OK menu)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvDownBtn);
          
        else
          
          if ( debugMode ) then fibaro:debug("> RT.TV ChDown"); end
          fibaro:call(RTtvID, "pressButton", RTtvChDownBtn);
          
        end
        
      elseif ( TVkitchenMode == "HDMI_Other" ) then
        
        
        
      else
        
        
        
      end
      
    end
    
  else
    
    if ( TVkitchenMode == "TVMenu" ) then
      
      if ( debugMode ) then fibaro:debug("> TV Left"); end
      fibaro:call(TVID, "pressButton", TVLeftBtn);
      
    elseif ( TVkitchenMode == "Ext" ) then
      
      -- TODO: Pref.Prog-
      
    elseif ( TVkitchenMode == "ProgNum" ) then
      
      -- TODO: 7-9 channel num
      
    else -- TV
      
      -- set default mode
      if ( TVkitchenMode ~= "TV" ) then
        setTVkModes("TV", false);
      end
      
      if ( debugMode ) then fibaro:debug("> TV PgDn"); end
      fibaro:call(TVID, "pressButton", TVPgDnBtn);
      
    end
    
  end
  
elseif ( tonumber(buttonPressed) == 6) then -----------------------------------
  
  if ( isTVkHDMI() and isHDMIon() ) then
    
    if ( isHMDI_PiPon() ) then
      
      turnHDMI_PiPent();
      
    else
      
      if ( TVkitchenMode == "HDMI" ) then
        
        
        
      elseif ( TVkitchenMode == "HDMI_RT" ) then
        
        
        
      elseif ( TVkitchenMode == "HDMI_Other" ) then
        
        
        
      end
      
    end
    
  else
    
    if ( TVkitchenMode == "TVMenu" ) then
      -- force set ProgNum mode
      
      setTVkModes("*ProgNum", false);
      
    elseif ( TVkitchenMode == "Ext" ) then
      -- force set ProgNum mode
      
      setTVkModes("*ProgNum", false);
      
    elseif ( TVkitchenMode == "ProgNum" ) then
      -- exit from ProgNum mode
      
      setTVkModes(TVkitchenLastMode, false);
      
    else -- TV
      -- set ProgNum mode
      
      setTVkModes("ProgNum", true);
      
    end
    
  end
  
elseif ( tonumber(buttonPressed) == 7) then -----------------------------------
  
  if ( isTVkHDMI() and isHDMIon() ) then
    
    if ( isHMDI_PiPon() ) then
      
      turnHDMI_PiPoff();
      
    else
      
      if ( TVkitchenMode == "HDMI" ) then
        
        
        
      elseif ( TVkitchenMode == "HDMI_RT" ) then
        
        if ( string.sub(RTtvMode, 1, 1) == "1" ) then -- RT.Menu normal
          
          if ( debugMode ) then
            fibaro:debug("> RT.TV Right (norm. menu)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvRightBtn);
          
        elseif ( string.sub(RTtvMode, 1, 1) == "2" ) then -- RT.Menu OK
          -- exit from RT.TV Menu OK mode
          
          if ( debugMode ) then
            fibaro:debug("> RT.TV OK (OK menu mode end with select)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvOKBtn);
          fibaro:call(RTtvStateID, "pressButton", RTtvStateMenuOffBtn);
          
        else
          
          if ( debugMode ) then fibaro:debug("> TV VolDn"); end
          fibaro:call(TVID, "pressButton", TVVolDnBtn);
          
        end
        
      elseif ( TVkitchenMode == "HDMI_Other" ) then
        
        if ( debugMode ) then fibaro:debug("> TV VolDn"); end
        fibaro:call(TVID, "pressButton", TVVolDnBtn);
        
      else
        
        if ( debugMode ) then fibaro:debug("> TV VolDn"); end
        fibaro:call(TVID, "pressButton", TVVolDnBtn);
        
      end
      
    end
    
  else
    
    if ( TVkitchenMode == "TVMenu" ) then
      
      if ( TVkitchenMode == "TVMenu" ) then
        
        if ( debugMode ) then fibaro:debug("> TV Right"); end
        fibaro:call(TVID, "pressButton", TVRightBtn);
        
      end
      
    elseif ( TVkitchenMode == "Ext" ) then
      
      if ( debugMode ) then fibaro:debug("> TV Mute"); end
      fibaro:call(TVID, "pressButton", TVMuteBtn);
      
    elseif ( TVkitchenMode == "ProgNum" ) then
      
      -- 0/enter channel num
      
    else -- TV
      
      -- set default mode
      if ( TVkitchenMode ~= "TV" ) then
        setTVkModes("TV", false);
      end
      
      if ( debugMode ) then fibaro:debug("> TV VolDn"); end
      fibaro:call(TVID, "pressButton", TVVolDnBtn);
      
    end
    
  end
  
elseif ( tonumber(buttonPressed) == 8) then -----------------------------------
  
  if ( isTVkHDMI() and isHDMIon() ) then
    
    if ( isHMDI_PiPon() ) then
      
      turnHDMI_PiPoff();
      
    else
      
      if ( TVkitchenMode == "HDMI_RT" ) then
        
        if ( string.sub(RTtvMode, 1, 1) == "1" ) then -- RT.Menu normal
          
          if ( debugMode ) then fibaro:debug("> RT.TV ChDown"); end
          fibaro:call(RTtvID, "pressButton", RTtvChDownBtn); -- ???
          
        elseif ( string.sub(RTtvMode, 1, 1) == "2" ) then -- RT.Menu OK
          
          if ( debugMode ) then fibaro:debug("> RT.TV ChDown"); end
          fibaro:call(RTtvID, "pressButton", RTtvChDownBtn); -- end of list
          
        else
          
          setTVkModes("*TVMenu", false);
          
        end
        
      else
        
        setTVkModes("*TVMenu", false);
        
      end
      
    end
    
  else
    
    if ( TVkitchenMode == "TVMenu" ) then
      -- exit from TVMenu mode
      
      setTVkModes(TVkitchenLastMode, false);

      if ( debugMode ) then fibaro:debug("> TV Menu (exit)"); end
      fibaro:call(TVID, "pressButton", TVMenuBtn);
      
    elseif ( TVkitchenMode == "Ext" ) then
      -- force set TVMenu mode
      
      setTVkModes("*TVMenu", false);
      
      if ( debugMode ) then fibaro:debug("> TV Menu (enter)"); end
      fibaro:call(TVID, "pressButton", TVMenuBtn);
      
    elseif ( TVkitchenMode == "ProgNum" ) then
      -- force set TVMenu mode
      
      setTVkModes("*TVMenu", false);
      
      if ( debugMode ) then fibaro:debug("> TV Menu (enter)"); end
      fibaro:call(TVID, "pressButton", TVMenuBtn);
      
    else -- TV
      -- set TVMenu mode
      
      setTVkModes("TVMenu", true);
      
      if ( debugMode ) then fibaro:debug("> TV Menu (enter)"); end
      fibaro:call(TVID, "pressButton", TVMenuBtn);
      
    end
    
  end
  
else
  
  if ( debugMode ) then fibaro:debug("! INCORRECT COMMAND"); end
  
end
