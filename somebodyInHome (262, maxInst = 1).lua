--[[
%% properties
187 value
%% events
%% globals
somebodyInHomeB
--]]


local scEverybodyLeftID = 217;

local scEverybodyLeftCount = fibaro:countScenes(scEverybodyLeftID);

local smbdInHval, smbdInHMT = fibaro:getGlobal("somebodyInHomeB");

local timeout_Left_Coming = os.time() - smbdInHMT;

local outerDoorVal = fibaro:getValue(187, "value");

fibaro:debug("outerDoorVal = " .. outerDoorVal
  .. "; smbdInHval = " .. smbdInHval
  .. "; timeout_Left_Coming = " .. timeout_Left_Coming
  .. "; scELcount = " .. scEverybodyLeftCount);

if ( (outerDoorVal == "1") and (timeout_Left_Coming > 5 * 60)
  and (scEverybodyLeftCount > 0) ) then
  
  fibaro:debug("Somebody in (near) the Home!");
  
  fibaro:setGlobal("somebodyInHomeB", "1");
  
  fibaro:killScenes(scEverybodyLeftID);
  
  fibaro:call(60, "turnOn"); -- K:Appliences
  fibaro:call(179, "turnOn"); -- BR_vent
  
  if ( (tonumber(fibaro:getValue(3, "Temperature")) <= -5)
      and (fibaro:getValue(173, "value") == "0") ) then
    
    fibaro:call(216, "pressButton", 2);
    
    fibaro:debug("K_hotFloor ON!");
    
  end
  
  --[[if ( fibaro:getValue(4, "value") == "1" ) then
    if ( fibaro:getValue(39, "value") ~= "0" ) then
      fibaro:debug("Trun OFF BR_light");
      fibaro:call(39, "turnOff");
    end
    if ( fibaro:getValue(259, "value") ~= "0" ) then
      fibaro:debug("Trun OFF SR_light");
      fibaro:call(259, "turnOff");
    end
    if ( fibaro:getValue(149, "value") ~= "0" ) then
      fibaro:debug("Trun OFF K_light");
      fibaro:call(149, "turnOff");
    end
  end]]--
  
  fibaro:debug("Welcome!");
  
end
