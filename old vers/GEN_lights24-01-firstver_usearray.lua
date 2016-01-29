--[[
%% properties
%% globals
lightsQueue
--]]

-- CONST

local powerID = 4; -- Туалет:БП ACDC 24В

--[[
local lightsMatrix = {
  -- Control VirtDev ID, SliderNum as str, LightID
  { 195, "1", 42 },		-- БольшаяКомната:СветОсн24,центр
  { 195, "2", 44 },		-- БольшаяКомната:СветОсн24,прикроватный
  { 196, "1", 149 }, 	-- КоридорКухня:СветОсн24_R_Кухня
  { 207, "1", 150 },	-- КоридорКухня:СветОсн24_G_Коридор,уВхода
  { 207, "1", 151 },	-- КоридорКухня:СветОсн24_B_Коридор,уКомнат
};
--]]

-- GET ENVS

local powerValue = fibaro:getValue(powerID, "value");

--[[
local trigger = fibaro:getSourceTrigger();
local triggerDeviceID = trigger['deviceId'];
local triggerSceneActID = tonumber(fibaro:getValue(triggerDeviceID, "sceneActivation"));

fibaro:debug("triggerDeviceID = " .. triggerDeviceID);
fibaro:debug("triggerSceneActID = " .. triggerSceneActID);
--]]

if fibaro:countScenes() > 1
then
  fibaro:debug("Double start.. Abort dup!");
  fibaro:abort();
end;

-- PROCESS

--[[
for lightRecNum, lightRecField in pairs(lightsMatrix) do
fibaro:debug(z);
fibaro:debug(lightRecField[1]);
fibaro:debug(lightRecField[2]);
fibaro:debug(lightRecField[3]);
end
fibaro:abort();
--]]

--[[
local startWakeupTime = os.time();
local powerOn = true;

while powerOn and (os.time() < startWakeupTime + 15) do
  
  powerOn = false;
  
  for lightRecNum, lightRecField in pairs(lightsMatrix) do
  
    local sliderValue = fibaro:getValue(lightRecField[1],
        "ui.Slider" .. lightRecField[2] .. ".value");
    
    local nodeID = lightRecField[3];
    local nodeName = "<" .. fibaro:getName(nodeID)
        .. " (" .. fibaro:getRoomNameByDeviceID(nodeID) .. ")>";
    
    fibaro:debug("Slider #" .. lightRecField[2] .. " value for " .. nodeName .. " = " .. sliderValue);
--]]

local nightMode = false;
if ( fibaro:getGlobalValue("nightMode") == "1" )
then
  nightMode = true;
  
  fibaro:debug("_nightMode detected");
end

local lightsQueue = fibaro:getGlobalValue("lightsQueue");
local lightActionPos = string.find(lightsQueue, ";");

fibaro:debug("_lightsQueue = <" .. lightsQueue .. ">");

while lightActionPos ~= nil do
  
  fibaro:debug("FOUND lightAction, end.pos = " .. tostring(lightActionPos));
  
  local lightAction = string.sub(lightsQueue, 1, lightActionPos);
  fibaro:setGlobal("lightsQueue", string.sub(lightsQueue, lightActionPos + 1));
  
  fibaro:debug("GET lightAction = <" .. lightAction .. ">");
  
  local nodeID = tonumber(string.sub(lightAction, 1, string.find(lightAction, ",") - 1));
  lightAction = string.sub(lightAction, string.find(lightAction, ",") + 1);
  local sliderValue = string.sub(lightAction, 1, string.find(lightAction, ";") - 1);
  
--fibaro:debug(tostring(nodeID) .. " / " .. sliderValue); fibaro:abort();
  
  local nodeName = "<" .. fibaro:getName(nodeID)
    	.. " (" .. fibaro:getRoomNameByDeviceID(nodeID) .. ")>";
    
  fibaro:debug("LIGHTACTION: set value for " .. nodeName .. " = " .. sliderValue);
  
    if ( sliderValue == "0" )
    then
      -- TURN OFF --
      
      --if tonumber(fibaro:getValue(nodeID, "value")) > 0
      --  then
      fibaro:debug("TURING OFF " .. nodeName);
      
      fibaro:call(nodeID, "turnOff");
      --end
    
    else
      -- TURN ON --
      
      --- Check Power Source ---
--[[      if ( powerOn == false and powerValue == "0" )
--]]
      if ( powerValue == "0" )
      then
        fibaro:debug("PowerSource is OFF! Turning ON");
        
        fibaro:call(powerID, "turnOn");
        fibaro:sleep(3000);
        
        powerValue = fibaro:getValue(powerID, "value");
--[[        if ( tonumber(powerValue) > 0 )
        then
          powerOn = true;
        end
--]]
        if ( powerValue == "0" )
        then
          fibaro:debug("PowerSource turning on was FAIL!");
          --clear queue? skip cur. lightaction?
        end
      else
        fibaro:debug("PowerSource is on");
      end
      
      --- Wakeup devices ---
      if --powerOn and
        ( fibaro:getValue(nodeID, "dead") >= "1" )
      then
        fibaro:debug("WAKING UP DEAD " .. nodeName);
        
        fibaro:wakeUpDeadDevice(nodeID);
        
        --powerOn = true;
        fibaro:sleep(2 * 1000);
      end
      --else
        
      if ( sliderValue == "101" )
        then -- TURN FULL ON or NIGHT ON
        if ( nightMode == true )
          then
          sliderValue = "1";
        else
          sliderValue = "99";
        end
      elseif ( tonumber(sliderValue) > 101 )
        then
        sliderValue = tostring(tonumber(sliderValue - 100));
      end
      
      if (tonumber(sliderValue) >= 99 )
        then -- FULL ON
        fibaro:debug("Turning ON " .. nodeName);
        
        --fibaro:call(nodeID, "turnOn");
        -- непонятная хрень - RGBW в БК и Т_В не желают включаться
        -- по turnOn (в т.ч. через моб.прил-ие!),
        -- выключаются же при этом - без проблем
        fibaro:call(nodeID, "setValue", 100);
      elseif tonumber(sliderValue) <= 3
        then -- MIN
        fibaro:debug("Setting MIN on " .. nodeName);
        
        fibaro:call(nodeID, "setValue", 1);
      else -- EXACT VALUE
        fibaro:debug("Setting VALUE [" .. sliderValue .. "] on " .. nodeName);
        
        fibaro:call(nodeID, "setValue", sliderValue);
      end
      
      --end
    end

  -- reloadqueue
  lightsQueue = fibaro:getGlobalValue("lightsQueue");
  lightActionPos = string.find(lightsQueue, ";");
  
  fibaro:debug("__lightsQueue = <" .. lightsQueue .. ">");
end

fibaro:setGlobal("lightsQueue", ""); -- clear queue
--[[
  end
  
  if powerOn
  then
    fibaro:sleep(2000);
  end
  
  if powerOn then fibaro:debug("powerOn!") else fibaro:debug("NOT powerOn.."); end

end

--]]