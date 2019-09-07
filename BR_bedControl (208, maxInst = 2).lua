--[[
%% properties
205 value
%% globals
--]]


-- CONST --

local bedID = 205;

local lightDecorID = 18;
local lightDecorPPBRID = 169; -- PPBR -> Play/Pause | BigRoom
local lightBRgenID = 40;
local lightBRbedID = 44;

local vdLightBRID = 195;
local vdLightBRbtnBedLight = "16";

local plugBedID = 15;
local plugAddBRID = 228; -- УпрРозетка

local switchAddLightBRID = 230; -- Бра

local debug = false;


-- GET ENVS --

local switchDecorLight, switchDecorLightModTime =
  fibaro:get(lightDecorID, "value");
local switchBRDecorLight, switchBRDecorLightModTime =
  fibaro:get(lightDecorPPBRID, "value");
local valuePlugAddBR = fibaro:getValue(plugAddBRID, "value");
local valueSwitchAddLightBR = fibaro:getValue(switchAddLightBRID, "value");


-- PROCESS --

if ( tonumber(fibaro:getValue(bedID, "value")) > 0 ) then
  -- bed is opened
  
  if ( debug ) then fibaro:debug("Bed is opened"); end
  
  if (
  	(
  		(
          (tonumber(switchDecorLight) > 0)
  			and (switchBRDecorLightModTime > switchDecorLightModTime)
		)
		or
    	(
          (fibaro:getGlobalValue("twilightMode") == "1")
      		and (fibaro:getValue(lightBRgenID, "value") == "0")
    	)
    ) and (fibaro:getValue(lightBRbedID, "value") == "0")
      and (valuePlugAddBR == "0")
      and (valueSwitchAddLightBR == "0")
  ) then
    if ( debug ) then fibaro:debug("Turn on illumination"); end
    
    fibaro:sleep(5 * 1000);
	--fibaro:call(vdLightBRID, "pressButton", vdLightBRbtnBedLight);
  end
  
  fibaro:call(plugBedID, "turnOn");
  
else
  -- bed is closed
  
  if ( debug ) then fibaro:debug("Bed is closed"); end
  
  if (tonumber(fibaro:getValue(lightBRbedID, "value")) > 0) then
    if ( debug ) then fibaro:debug("Turn off illumination"); end
    
	--fibaro:call(vdLightBRID, "pressButton", vdLightBRbtnBedLight);
  end
  
  fibaro:call(plugBedID, "turnOff");
  
end
