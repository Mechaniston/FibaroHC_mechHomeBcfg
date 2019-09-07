--[[
%% properties
187 value
%% globals
--]]


-- CONSTS

local debugMode = false;


local vdLightHllID        = 207;
local vdLightHllSwitchBtn = "5";

local doorHallID = 383;
local doorExtID = 187;


-- GET ENVS

local startSource = fibaro:getSourceTrigger();

local intDoorVal, intDoorMT = fibaro:get(doorHallID, "value");
local extDoorVal, extDoorMT = fibaro:get(doorExtID, "value");


-- PROCESS


if (
  (
    (extDoorVal == "1")
    and (
      (intDoorVal == "0") or (os.time() - intDoorMT > 60)
    )
    and (fibaro:getGlobalValue("twilightMode") == "1")
    and (
      (fibaro:getValue(150, "value") == "0")
      or (fibaro:getValue(150, "dead") >= "1")
    )
  )
  or
  (startSource["type"] == "other")
) then
  
  --[[
  local isLightInRoom = -- simple sleep detection
    ( tonumber(fibaro:getValue(40, "value")) > 0 ) -- ctrlBigRoom:—ветќснќбщ
  --  or ( tonumber(fibaro:getValue(228, "value")) > 0 ) -- Ѕ :”пр–озетка (- бра напол.)
    or ( tonumber(fibaro:getValue(230, "value")) > 0 ) -- Ѕ :Ѕра(настен.)
  
  if not isLightInRoom then
    fibaro:setGlobal("lightsQueue", fibaro:getGlobalValue("lightsQueue")
      .. "150,110;");
  else  
    fibaro:setGlobal("lightsQueue", fibaro:getGlobalValue("lightsQueue")
      .. "150,200;");
  end
  --]]
  
  fibaro:call(vdLightHllID, "pressButton", vdLightHllSwitchBtn);
  
  fibaro:debug("Hall illumination ON");
  
end
