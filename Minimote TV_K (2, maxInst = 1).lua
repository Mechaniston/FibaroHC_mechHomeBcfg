--[[
%% properties
291 sceneActivation
%% globals
--]]
--291 value


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

local HDMIswitch_RT2Kbtn 	= HDMIswitch22Btn;
local HDMIswitch_RT2Kroute = "2";

local HDMIswitchStateID = 292;
local HDMIswitchStateOnBtn  = "2";
local HDMIswitchStateOffBtn = "3";
local HDMIswitchStatePiPOnBtn = "4";
local HDMIswitchStatePiPOffBtn = "5";
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

local RTtvStateID = 292;
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
    
    fibaro:debug("getStrGlobalVal `" .. valName .. "` = " .. val );
    
  end
  
  return val;
  
end

local buttonPressed = fibaro:getValue(291, "sceneActivation");

local TVkitchenMode = getStrGlobalVal("TVkitchenMode");
 -- TV, HDMI, HDMI_Other, HDMI_RT, TVMenu, Ext
local TVkitchenLastMode = getStrGlobalVal("TVkitchenLastMode");

local HDMIswitchMode = getStrGlobalVal("HDMIswitchMode");
 -- 4 num code: [1stCh_1-6][2ndCh_1-6][PiPMode_0-1][OnOff_0-1]

local RTtvMode = getStrGlobalVal("RTtvMode");
 -- 2 num code: [MenuMode_0-2 : 1 - normal, 2 - ch.sel.][OnOff_0-1]

if ( debugMode ) then
  fibaro:debug("Key pressed: " .. buttonPressed);
end


-- FUNCS

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
    fibaro:debug("turnTVon() - TVkM: " .. TVkitchenMode
      .. ", TVkLM: " .. TVkitchenLastMode);
  end
  
  if ( TVkitchenMode == "" ) then
    
    if ( debugMode ) then fibaro:debug("> TV Pwr (on)"); end
    fibaro:call(TVID, "pressButton", TVPwrBtn);
    
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
    fibaro:debug("turnHDMIon() - TVkM: " .. TVkitchenMode
      .. ", HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  if ( TVkitchenMode == "" ) then
    turnTVon();
  end
  
  if ( string.sub(TVkitchenMode, 1, 4) ~= "HDMI" ) then
    
    if ( debugMode ) then fibaro:debug("> TV HDMI"); end
    fibaro:call(TVID, "pressButton", TVHDMIBtn);
    
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

function turnHDMI_RTon()
  
  if ( debugMode ) then
    fibaro:debug("turnHDMIon() - TVkM: " .. TVkitchenMode
      .. ", HDMIswM: '" .. HDMIswitchMode .. "'"
      .. ", RTtvM: '" .. RTtvMode .. "'");
  end
  
  turnHDMIon();
  
  if ( string.sub(RTtvMode, 2, 2) ~= "1" ) then
    -- RT.TV turn ON
    
    if ( debugMode ) then fibaro:debug("> RT.TV Pwr (on)"); end
    fibaro:call(RTtvID, "pressButton", RTtvPwrBtn);
    fibaro:call(RTtvStateID, "pressButton", RTtvStateOnBtn);
    
    RTtvMode = fibaro:getGlobalValue("RTtvMode"); -- reload
    
  end
    
  if ( string.sub(HDMIswitchMode, 2, 2) ~= HDMIswitch_RT2Kroute ) then
    -- HDMI switching
    
    if ( debugMode ) then fibaro:debug("> HDMIsw RT2K"); end
    fibaro:call(HDMIswitchID, "pressButton", HDMIswitch_RT2Kbtn);
    
    local btnStrIdx = tostring(
      tonumber(HDMIswitch_RT2Kbtn)
      + HDMIswitchStateChannelBtnOffset);
      
    fibaro:call(HDMIswitchStateID, "pressButton", btnStrIdx);
    
    if ( debugMode ) then 
      fibaro:debug("HDMIswStateVDcallBtnIdx = " .. btnStrIdx);
    end
    
    HDMIswitchMode = fibaro:getGlobalValue("HDMIswitchMode"); -- reload
    
    return true
    
  end
  
  return false
  
end

function forceHDMIon()
  
  if ( string.sub(HDMIswitchMode, 2, 2) == HDMIswitch_RT2Kroute ) then
    
    HDMI_RTon();
    setTVkModes("HDMI_RT", false);
    
  else
    
    turnHDMIon();
    setTVkModes("HDMI_Other", false);
    
  end
  
end

function turnHDMI_PiPon()
  
  if ( debugMode ) then
    fibaro:debug("turnHDMI_PiPon() - TVkM: " .. TVkitchenMode
      .. ", HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  turnHDMIon();
  
  if ( string.sub(HDMIswitchMode, 3, 3) ~= "1" ) then
      -- HDMI switch PiP mode ON
    
    if ( debugMode ) then fibaro:debug("> HDMIsw PiP (on)"); end
    fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPiPBtn);
    fibaro:call(HDMIswitchStateID, "pressButton",
      HDMIswitchStatePiPOnBtn);
    
    HDMIswitchMode = fibaro:getGlobalValue("HDMIswitchMode"); -- reload
    
    return true
    
  end
  
  return false
  
end

function HDMI_NextSecRoute()
  
  if ( debugMode ) then
    fibaro:debug("HDMI_NextSecRoute() - HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  local curRoute = tonumber(string.sub(HDMIswitchMode, 2, 2));
  if ( (curRoute < 1) or (curRoute > 5) ) then
    curRoute = 0;
  end
  
  local btnIdx = tonumber(HDMIswitch21Btn) + curRoute;
  if ( debugMode ) then fibaro:debug("> HDMIsw 2ndRoute+"); end
  fibaro:call(HDMIswitchID, "pressButton", tostring(btnIdx));
  
  local btnStrIdx = tostring(btnIdx + HDMIswitchStateChannelBtnOffset);
  fibaro:call(HDMIswitchStateID, "pressButton", btnStrIdx);
  
  if ( debugMode ) then 
    fibaro:debug("HDMIswStateVDcallBtnIdx = " .. btnStrIdx);
  end
  
  if ( tostring(curRoute + 1) == HDMIswitch_RT2Kroute ) then -- switched to RT
    return turnHDMI_RTon();
  elseif ( tostring(curRoute) == HDMIswitch_RT2Kroute ) then -- switched from RT
    return turnHDMI_RToff();
  end
  
end

function turnTVOff()
  
  if ( debugMode ) then fibaro:debug("turnTVOff()"); end
  
  if ( TVkitchenMode ~= "" ) then
    
    if ( debugMode ) then fibaro:debug("> TV Pwr (off)"); end
    fibaro:call(TVID, "pressButton", TVPwrBtn);
    
    if ( string.sub(HDMIswitchMode, 4, 4) == "1" ) then
      
      if ( (string.sub(RTtvMode, 2, 2) == "1")
        and (string.sub(HDMIswitchMode, 2, 2) == HDMIswitch_RT2Kroute) ) then
        
        turnHDMI_RToff();
        
        if ( debugMode ) then fibaro:debug("* Set TVkLM to HDMI_RT"); end
        fibaro:setGlobal("TVkitchenLastMode", "HDMI_RT");
        
      else
        
        if ( debugMode ) then fibaro:debug("* Set TVkLM to HDMI_Other"); end
        fibaro:setGlobal("TVkitchenLastMode", "HDMI_Other");
        
      end
      
      turnHDMIoff();
      
    else
      
      if ( debugMode ) then fibaro:debug("* Set TVkLM to TV"); end
      fibaro:setGlobal("TVkitchenLastMode", "TV");
      
    end
    
    setTVkModes("", true);
    
    return true
    
  else
    
    if ( debugMode ) then fibaro:debug("* SET TVkM to ''"); end
    fibaro:setGlobal("TVkitchenMode", "");
    
    return false
    
  end
  
end

function turnHDMIOff()
  
  if ( debugMode ) then
    fibaro:debug("turnHDMIOff() - TVkM: " .. TVkitchenMode
      .. ", HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  if ( string.sub(TVkitchenMode, 1, 4) == "HDMI" ) then
    
    if ( debugMode ) then fibaro:debug("> TV TV"); end
    fibaro:call(TVID, "pressButton", TVTVBtn);
    
    setTVkModes("TV", false);
    
  end
  
  if ( string.sub(HDMIswitchMode, 4, 4) == "1" ) then
    -- HDMI switch turn OFF
    
    turnHDMI_RToff();
    
    if ( debugMode ) then fibaro:debug("> HDMIsw Pwr (off)"); end
    fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPwrBtn);
    fibaro:call(HDMIswitchStateID, "pressButton", HDMIswitchStateOffBtn);
    fibaro:call(HDMIswitchStateID, "pressButton",
      HDMIswitchStatePiPOffBtn);
    
    HDMIswitchMode = fibaro:getGlobalValue("HDMIswitchMode"); -- reload
    
    return true
    
  end
  
  return false
  
end

function turnHDMI_RToff()
  
  if ( debugMode ) then
    fibaro:debug("turnHDMI_RToff() - TVkM: " .. TVkitchenMode
      .. ", HDMIswM: '" .. HDMIswitchMode .. "'"
      .. ", RTtvM: '" .. RTtvMode .. "'");
  end
  
  if ( (string.sub(RTtvMode, 2, 2) == "1")
    and (string.sub(HDMIswitchMode, 2, 2) == HDMIswitch_RT2Kroute) ) then
    -- RT.TV turn OFF
    
    if ( debugMode ) then fibaro:debug("> RT.TV Pwr (off)"); end
    fibaro:call(RTtvID, "pressButton", RTtvPwrBtn);
    fibaro:call(RTtvStateID, "pressButton", RTtvOffBtn);
    
    RTtvMode = fibaro:getGlobalValue("RTtvMode"); -- reload
    
    return true
    
  end
  
  return false
  
end

function turnHDMI_PiPoff()
  
  if ( debugMode ) then
    fibaro:debug("turnHDMI_PiPoff() - TVkM: " .. TVkitchenMode
      .. ", HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  if ( string.sub(HDMIswitchMode, 3, 3) == "1" ) then
    -- HDMI switch PiP mode OFF
    
    if ( debugMode ) then fibaro:debug("> HDMIsw PiP (off)"); end
    fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPiPBtn);
    fibaro:call(HDMIswitchStateID, "pressButton",
      HDMIswitchStatePiPOffBtn);
    
    HDMIswitchMode = fibaro:getGlobalValue("HDMIswitchMode"); -- reload
    
    return true
    
  end
  
  return false
  
end

function turnHDMI_PiPent()
  
  if ( debugMode ) then
    fibaro:debug("turnHDMI_PiPent() - TVkM: " .. TVkitchenMode
      .. ", HDMIswM: '" .. HDMIswitchMode .. "'");
  end
  
  if ( string.sub(HDMIswitchMode, 3, 3) == "1" ) then
    -- HDMI switch PiP ENTER
    
    if ( debugMode ) then fibaro:debug("> HDMIsw PiP ent"); end
    fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPiPEntBtn);
    fibaro:call(HDMIswitchStateID, "pressButton",
      HDMIswitchStatePiPOffBtn); -- auto-off
    
    HDMIswitchMode = fibaro:getGlobalValue("HDMIswitchMode"); -- reload
    
    return true
    
  end
  
  return false
  
end


-- PROCESS

-- General turn on for the any action
if ( turnTVon() ) then
  
  if ( string.sub(TVkitchenMode, 1, 4) == "HDMI" ) then
    
    if ( TVkitchenMode == "HDMI_RT" ) then
      
      turnHDMI_RTon()
      
    else
      
      turnHDMIon();
      
    end
    
  end
  
end

-- Key pressing
if ( tonumber(buttonPressed) == 1) then ---------------------------------------
  
  if ( (string.sub(TVkitchenMode, 1, 4) == "HDMI")
    and (string.sub(HDMIswitchMode, 4, 4) == "1") ) then -- HDMI on
    
    if ( string.sub(HDMIswitchMode, 3, 3) == "1" ) then -- PiP on
      
      if ( debugMode ) then fibaro:debug("> HDMIsw PiP sel"); end
      fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPiPSelBtn);
      
    else
      
      if ( TVkitchenMode == "HDMI" ) then
        
        HDMI_NextSecRoute();
        
      elseif ( TVkitchenMode == "HDMI_RT" ) then
        
        if ( string.sub(RTtvMode, 1, 1) == "1" ) then -- RT.Menu normal
        
          if ( debugMode ) then
            fibaro:debug("> RT.TV OK (norm. menu enter)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvOKBtn);
          
        elseif ( string.sub(RTtvMode, 1, 1) == "2" ) then -- RT.Menu OK
          
          if ( debugMode ) then
            fibaro:debug("> RT.TV up (OK menu up)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvUpBtn);
          
        else
          
          if ( debugMode ) then
            fibaro:debug("> RT.TV ChUp (OK menu top)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvChUpBtn);
        
        end
    
      elseif ( TVkitchenMode == "HDMI_Other" ) then
        
        HDMI_NextSecRoute();
        
      else
        
        
        
      end
      
    end
    
  else
    
    if ( TVkitchenMode == "TVMenu" ) then
      
      if ( debugMode ) then fibaro:debug("> TV OK (TV menu)"); end
      fibaro:call(TVID, "pressButton", TVOKBtn);
      
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
  
  if ( (string.sub(TVkitchenMode, 1, 4) == "HDMI")
    and (string.sub(HDMIswitchMode, 4, 4) == "1") ) then -- HDMI on
    
    if ( string.sub(HDMIswitchMode, 3, 3) == "1" ) then -- PiP on
      
      if ( debugMode ) then fibaro:debug("> HDMIsw PiP sel"); end
      fibaro:call(HDMIswitchID, "pressButton", HDMIswitchPiPSelBtn);
      
    else
      
      if ( TVkitchenMode == "HDMI_RT" ) then
        
        if ( string.sub(RTtvMode, 1, 1) == "1" ) then -- RT.Menu normal
          
          if ( debugMode ) then fibaro:debug("> RT.TV ChUp"); end
          fibaro:call(RTtvID, "pressButton", RTtvChUpBtn); -- ???
          
        elseif ( string.sub(RTtvMode, 1, 1) == "2" ) then -- RT.Menu OK
          
          if ( debugMode ) then fibaro:debug("> RT.TV ChUp"); end
          fibaro:call(RTtvID, "pressButton", RTtvChUpBtn); -- begin of list
          
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
  
  if ( (string.sub(TVkitchenMode, 1, 4) == "HDMI")
    and (string.sub(HDMIswitchMode, 4, 4) == "1") ) then -- HDMI on
    
    if ( string.sub(HDMIswitchMode, 3, 3) == "1" ) then -- PiP on
      
      turnHDMI_PiPent();
      
    else
      
      if ( TVkitchenMode == "HDMI" ) then
        -- HDMI -> TV
        
        if ( string.sub(RTtvMode, 2, 2) == "1" ) then
          
          turnHDMI_RToff();
          
        else
          
          turnHDMIoff();
          
        end
        
      elseif ( TVkitchenMode == "HDMI_RT" ) then
        
        if ( string.sub(RTtvMode, 1, 1) == "1" ) then -- RT.Menu normal
          
          if ( debugMode ) then fibaro:debug("> RT.TV Back"); end
          fibaro:call(RTtvID, "pressButton", RTtvBackBtn);
          
        elseif ( string.sub(RTtvMode, 1, 1) == "2" ) then -- RT.Menu OK
          
          if ( debugMode ) then
            fibaro:debug("> RT.TV Menu (OK mode end and select)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvOKBtn);
          fibaro:call(RTtvStateID, "pressButton", RTtvStateMenuOffBtn);
          
        else
          
          if ( debugMode ) then fibaro:debug("> TV VolUp"); end
          fibaro:call(TVID, "pressButton", TVVolUpBtn);
          
        end
        
      elseif ( TVkitchenMode == "HDMI_Other" ) then
        
        
        
      else
        
        
        
      end
      
    end
    
  else
    
    if ( TVkitchenMode == "HDMI" ) then
      
      forceHDMIon();
      
    elseif ( TVkitchenMode == "TVMenu" ) then
      
      if ( debugMode ) then fibaro:debug("> TV Back"); end
      fibaro:call(TVID, "pressButton", TVBackBtn);
      
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
  
  if ( (string.sub(TVkitchenMode, 1, 4) == "HDMI")
    and (string.sub(HDMIswitchMode, 4, 4) == "1") ) then -- HDMI on
    
    if ( string.sub(HDMIswitchMode, 3, 3) == "1" ) then -- PiP on
      
      turnHDMI_PiPent();
      
    else
      
      --if ( TVkitchenMode == "HDMI" ) then
      --elseif ( TVkitchenMode == "HDMI_RT" ) then
      --elseif ( TVkitchenMode == "HDMI_Other" ) then
      --end
      
      -- exit from HDMI mode
      
      setTVkModes(TVkitchenLastMode, false);
      
    end
    
  else
    
    if ( TVkitchenMode == "TVMenu" ) then
      -- force set HDMI mode
      
      setTVkModes("*HDMI", false);
      
      forceHDMIon();
      
    elseif ( TVkitchenMode == "Ext" ) then
      -- force set HDMI mode
      
      setTVkModes("*HDMI", false);
      
      forceHDMIon();
      
    elseif ( TVkitchenMode == "ProgNum" ) then
      -- force set HDMI mode
      
      setTVkModes("*HDMI", false);
      
      forceHDMIon();
      
    else -- TV
      -- set HDMI mode
      
      setTVkModes("HDMI", true);
      
      forceHDMIon();
      
    end
    
  end
  
elseif ( tonumber(buttonPressed) == 5) then -----------------------------------
  
  if ( (string.sub(TVkitchenMode, 1, 4) == "HDMI")
    and (string.sub(HDMIswitchMode, 4, 4) == "1") ) then -- HDMI on
    
    if ( string.sub(HDMIswitchMode, 3, 3) == "1" ) then -- PiP on
      
      turnHDMI_PiPoff();
      
    else
      
      if ( TVkitchenMode == "HDMI" ) then
        
        turnHDMI_PiPon();
        
      elseif ( TVkitchenMode == "HDMI_RT" ) then
        
        if ( string.sub(RTtvMode, 1, 1) == "1" ) then -- RT.Menu normal
          
          if ( debugMode ) then fibaro:debug("> RT.TV Left"); end
          fibaro:call(RTtvID, "pressButton", RTtvLeftBtn);
          
        elseif ( string.sub(RTtvMode, 1, 1) == "2" ) then -- RT.Menu OK
          
          if ( debugMode ) then fibaro:debug("> RT.TV Down"); end
          fibaro:call(RTtvID, "pressButton", RTtvDownBtn);
          
        elseif ( TVkitchenMode == "TVMenu" ) then
          -- set RT TVMenu normal mode
          
          if ( debugMode ) then
            fibaro:debug("> RT.TV Menu (OK mode begin)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvOKBtn);
          fibaro:call(RTtvStateID, "pressButton", RTtvStateMenuOKBtn);
          
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
  
  if ( (string.sub(TVkitchenMode, 1, 4) == "HDMI")
    and (string.sub(HDMIswitchMode, 4, 4) == "1") ) then -- HDMI on
    
    if ( string.sub(HDMIswitchMode, 3, 3) == "1" ) then -- PiP on
      
      turnHDMI_PiPoff();
      
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
  
  if ( (string.sub(TVkitchenMode, 1, 4) == "HDMI")
    and (string.sub(HDMIswitchMode, 4, 4) == "1") ) then -- HDMI on
    
    if ( string.sub(HDMIswitchMode, 3, 3) == "1" ) then -- PiP on
      
      turnHDMI_PiPoff();
      
    else
      
      if ( TVkitchenMode == "HDMI" ) then
        
        
        
      elseif ( TVkitchenMode == "HDMI_RT" ) then
        
        if ( string.sub(RTtvMode, 1, 1) == "1" ) then -- RT.Menu normal
          
          if ( debugMode ) then fibaro:debug("> RT.TV Right"); end
          fibaro:call(RTtvID, "pressButton", RTtvRightBtn);
          
        elseif ( string.sub(RTtvMode, 1, 1) == "2" ) then -- RT.Menu OK
          
          if ( debugMode ) then fibaro:debug("> RT.TV OK"); end
          fibaro:call(RTtvID, "pressButton", RTtvOKBtn);
          
        else
          
          if ( debugMode ) then fibaro:debug("> TV VolDn"); end
          fibaro:call(TVID, "pressButton", TVVolDnBtn);
          
        end
        
      elseif ( TVkitchenMode == "HDMI_Other" ) then
        
      elseif ( TVkitchenMode == "TVMenu" ) then
        
        if ( string.sub(RTtvMode, 1, 1) == "1" ) then -- RT.Menu normal
          -- set RT TVMenu normal mode
          
          if ( debugMode ) then
            fibaro:debug("> RT.TV Menu (exit from normal)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvMenuBtn);
          fibaro:call(RTtvStateID, "pressButton", RTtvStateMenuOffBtn);
          
        else
          -- set RT TVMenu normal mode
          
          if ( debugMode ) then
            fibaro:debug("> RT.TV Menu (enter to normal)");
          end
          fibaro:call(RTtvID, "pressButton", RTtvMenuBtn);
          fibaro:call(RTtvStateID, "pressButton", RTtvStateMenuNormBtn);
          
        end
        
      else
        
        if ( debugMode ) then fibaro:debug("> TV VolDn"); end
        fibaro:call(TVID, "pressButton", TVVolDnBtn);

      end
      
    end
    
  else
    
    if ( TVkitchenMode == "TVMenu" ) then
      
      if ( debugMode ) then fibaro:debug("> TV Right"); end
      fibaro:call(TVID, "pressButton", TVRightBtn);
      
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
  
  if ( (string.sub(TVkitchenMode, 1, 4) == "HDMI")
    and (string.sub(HDMIswitchMode, 4, 4) == "1") ) then -- HDMI on
    
    if ( string.sub(HDMIswitchMode, 3, 3) == "1" ) then -- PiP on
      
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
          
          
          
        end
        
      else
        
        
        
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
