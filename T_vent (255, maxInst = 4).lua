--[[
%% properties
58 value
35 value
%% globals
--]]


-- CONSTS

local debugMode = false;

-- Devices ID's

local doorToilet_ID = 58;
local TBL_Rgbw_T_ID = 35;
local TB_vent_ID = 12;


-- PROCESS

--fibaro:debug(fibaro:getValue(TBL_Rgbw_T_ID, "value"));
--fibaro:debug(fibaro:getValue(doorToilet_ID, "value"));

if ( (fibaro:getGlobalValue("B_vent") == "0")
  and (fibaro:getValue(TB_vent_ID, "value") == "0") ) then
  
  fibaro:sleep(4000); -- 4 second timeout to prevent trigger on the door close
  	-- and light slow dimming off
  
  if ( (fibaro:getValue(doorToilet_ID, "value") == "0")
  	and (tonumber(fibaro:getValue(TBL_Rgbw_T_ID, "value")) > 0) ) then 
    
    if ( debugMode ) then
      fibaro:debug("Somebody in toilet (door is closed and light is on)"
        .." - waiting.."); end
    
    local startTime = os.time();
    
    while ( (fibaro:getValue(doorToilet_ID, "value") == "0")
      and ((os.time() - startTime) <= (3 * 60)) ) do
      
      fibaro:sleep(1500);
      
    end
    
    if ( (fibaro:getValue(doorToilet_ID, "value") == "0")
      and (fibaro:getGlobalValue("B_vent") == "0") ) then
      
      if ( debugMode ) then
        fibaro:debug("It's took 3 min - turn ON vent in MAX!");
      end
      
      fibaro:call(TB_vent_ID, "setValue", "100");
      
      startTime = os.time();
      
      while ( (fibaro:getValue(doorToilet_ID, "value") == "0")
        and (fibaro:getGlobalValue("B_vent") == "0")
        and ((os.time() - startTime) <= (1 * 15 * 60)) ) do
        
        fibaro:sleep(3000);
        
      end
      
      if ( debugMode ) then fibaro:debug("The door is opened,"
        .. " but may be we can wait some more..");
      end
      
      while ( (fibaro:getGlobalValue("B_vent") == "0")
        and ((os.time() - startTime) <= (1 * 15 * 60)) ) do
        
        fibaro:sleep(3000);
        
      end
      
      if ( debugMode ) then fibaro:debug("Turn OFF vent."); end
      
      fibaro:call(TB_vent_ID, "setValue", "0");
      
    else
      
      if ( debugMode ) then
        fibaro:debug("It's took 3 min,"
          .. " but the door not closed - skip process");
      end
      
    end
    
  end
  
end
