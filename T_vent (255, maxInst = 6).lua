--[[
%% properties
35 value
%% globals
--]]

--58 value


-- CONSTS

local debugMode = false;

-- Devices ID's

local doorToilet_ID = 375;
local TBL_Rgbw_T_ID = 35;
local TB_vent_ID = 12;


-- PROCESS

--fibaro:debug(fibaro:getValue(TBL_Rgbw_T_ID, "value"));
--fibaro:debug(fibaro:getValue(doorToilet_ID, "value"));

if ( (fibaro:getGlobalValue("B_vent") == "0")
  and (fibaro:getValue(TB_vent_ID, "value") == "0") ) then
  
  fibaro:sleep(4000); -- 4 second timeout to prevent trigger on the door close
  	-- and light slow dimming off
  
  if ( --(fibaro:getValue(doorToilet_ID, "value") == "0") and
  	(tonumber(fibaro:getValue(TBL_Rgbw_T_ID, "value")) > 0) ) then
    
    if ( debugMode ) then fibaro:debug("Somebody in toilet - waiting.."); end
    
    local startTime = os.time();
    
    while ( --(fibaro:getValue(doorToilet_ID, "value") == "0")
        (tonumber(fibaro:getValue(TBL_Rgbw_T_ID, "value")) > 0)
      and ((os.time() - startTime) <= (3 * 60)) ) do
      
      fibaro:sleep(1500);
      
    end
    
    if ( --(fibaro:getValue(doorToilet_ID, "value") == "0")
        (tonumber(fibaro:getValue(TBL_Rgbw_T_ID, "value")) > 0)
      and (fibaro:getGlobalValue("B_vent") == "0") ) then
      
      if ( debugMode ) then
        fibaro:debug("It's took 3 min - turn ON vent in MAX!");
      end
      
      fibaro:call(TB_vent_ID, "setValue", "100");
      
      startTime = os.time();
      
      while ( --(fibaro:getValue(doorToilet_ID, "value") == "0")
          (tonumber(fibaro:getValue(TBL_Rgbw_T_ID, "value")) > 0)
        and (fibaro:getGlobalValue("B_vent") == "0")
        and ((os.time() - startTime) <= (1 * 15 * 60)) ) do
        
        fibaro:sleep(3000);
        
      end
      
      if ( debugMode ) then fibaro:debug("Conditions changed,"
        .. " but may be we can wait some more..");
      end
      
      while (
        (fibaro:getGlobalValue("B_vent") == "0")
        and ((os.time() - startTime) <= (1 * 10 * 60)) ) do
        
        fibaro:sleep(3000);
        
      end
      
      if (fibaro:getGlobalValue("B_vent") == "0") then
        
        if ( debugMode ) then fibaro:debug("Turn OFF vent."); end
        
        fibaro:call(TB_vent_ID, "setValue", "0");
        
      else
        
        if ( debugMode ) then
          fibaro:debug("B_vent is active - process done.");
        end
        
      end
      
    else
      
      if ( debugMode ) then
        fibaro:debug("Conditions changed - process skip");
      end
      
    end
    
  end
  
end
