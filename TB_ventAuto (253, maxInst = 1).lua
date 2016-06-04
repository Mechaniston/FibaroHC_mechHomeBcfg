--[[
%% autostart
%% properties

%% globals
--]]


local ventID = 12;

local debugMode = true;
local ventValue = "0";
local curTime = 0;

if ( debugMode ) then fibaro:debug("Vent sequence ON!"); end

while true do
  
  ventValue = fibaro:getValue(ventID, "value");
  
  if ( (ventValue == "0") and (fibaro:getGlobalValue("B_vent") == "0") ) then
    
    if ( debugMode ) then fibaro:debug("Vent turn ON"); end
    
    fibaro:call(ventID, "setValue", "50");
    
    curTime = os.time();
    while ( ((os.time() - curTime) < (10 * 60))
      and (fibaro:getGlobalValue("B_vent") == "0") ) do
      fibaro:sleep(5000);
    end
    
    if ( fibaro:getGlobalValue("B_vent") == "0" ) then
      if ( debugMode ) then fibaro:debug("Vent turn OFF"); end
      fibaro:call(ventID, "setValue", "0");
    else
      if ( debugMode ) then fibaro:debug("B_vent mode detected!"); end
    end
    
  end
  
  fibaro:sleep(50 * 60 * 1000);
  
end

if ( debugMode ) then fibaro:debug("Vent sequence OFF!"); end
