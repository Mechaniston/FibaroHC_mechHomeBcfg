--[[
%% properties
%% events
%% globals
--]]


--[[
Global var <lightsDimming> format:

pwrChecking [1 symb, num, 0|1]
StepSign [1 symb, +|-]
MaxValue [2 symb, num, 00(=99)-99]
StepValue [2 symb, num, 01-99]
dimStepPause [4 symb, num, 0000-9999 msec]
Endless [1 symb, num, 0|1]
{devID;..}

]]--

-- CONST

local debugMode = true;
local debugDetailMode = false;

local powerID = 4;


-- RGBW DEVICE SUPPORT

function getTheColor(devID, clrIndex)
  
  local colors = fibaro:getValue(devID, "color");
  --local RGBWTable = {};
  local i = 1;
  
  for value in string.gmatch(colors, "(%d+)") do
    if ( i == clrIndex ) then
      return tonumber(value);
    end
    --RGBWTable[i] = value;
    i = i + 1;
  end
  
  --return RGBWTable[clrIndex];
  return 0;
  
end

function setTheColor(devID, clrIndex, oldValue, newValue)
  
  --[[ -- disable the check because fails sometimes
  if ( (newValue == 0) and (oldValue == 0) ) 
      or ( (newValue > 0) and (oldValue > 0) ) then
    return;
  end
  --]]
  
  newValue = math.ceil(newValue / 100 * 255);
  
  if ( clrIndex == 1 ) then
    fibaro:call(devID, "setR", newValue);
  elseif ( clrIndex == 2 ) then
    fibaro:call(devID, "setG", newValue);
  elseif ( clrIndex == 3 ) then
    fibaro:call(devID, "setB", newValue);
  elseif ( clrIndex == 4 ) then
    fibaro:call(devID, "setW", newValue);
  end
  
  if ( debugMode ) then
    fibaro:debug("Recalculated value for channel = " .. newValue);
  end
  
end


-- GET ENVS

fibaro:sleep(50); -- to prevent to kill all instances
if ( fibaro:countScenes() > 1 )
  then
  if ( debugMode )
    then
    fibaro:debug("Double start (" ..
  	  tostring(fibaro:countScenes()) .. ").. Abort dup!");
    end
  fibaro:abort();
end
--local trigger = fibaro:getSourceTrigger();

local powerValue = fibaro:getValue(powerID, "value");


-- READ data

local lightsDimming = fibaro:getGlobalValue("lightsDimming");

if ( lightsDimming == "" ) then
  if ( debugMode ) then fibaro:debug("lightsDimming is EMPTY!"); end
  
  fibaro:abort();
else
  if ( debugMode ) then
    fibaro:debug("READ lightsDimming = '" .. lightsDimming .. "'");
  end
end


-- PARSE SETTINGS

local pwrChecking = string.sub(lightsDimming, 1, 1);

if ( string.len(pwrChecking) ~= 1 ) then
  if ( debugMode ) then
    fibaro:debug("Incorrect PARSE pwrChecking flag!");
  end
  
  fibaro:abort();
else
  pwrChecking = tonumber(pwrChecking);
end

if ( (pwrChecking == 1 and powerValue == "0")
    or (pwrChecking ~= 0 and pwrChecking ~= 1) ) then
  if ( debugMode ) then
    fibaro:debug("Incorrect PARSE pwrChecking flag or PowerSource is OFF!");
  end
  
  fibaro:abort();
end

local dimStepSign = string.sub(lightsDimming, 2, 2);
local dimMaxValue = string.sub(lightsDimming, 3, 4);
local dimStepValue = string.sub(lightsDimming, 5, 6);
local dimStepPause = string.sub(lightsDimming, 7, 10);
local dimEndless = string.sub(lightsDimming, 11, 11);

if ( string.len(dimEndless) ~= 1
    or (dimStepSign ~= "-" and dimStepSign ~= "+")
    or string.len(dimMaxValue) ~= 2
    or string.len(dimStepValue) ~= 2
    or string.len(dimStepPause) ~= 4 ) then
  if ( debugMode ) then
    fibaro:debug("Incorrect PARSE setting flags!");
  end
  
  fibaro:abort();
else
  if ( debugMode ) then
    fibaro:debug("READ setting flags: "
      .. "EL = " .. dimEndless .. ", "
      .. "SS = " .. dimStepSign .. ", "
      .. "MV = " .. dimMaxValue .. ", "
      .. "SV = " .. dimStepValue .. ", "
      .. "SP = " .. dimStepPause);
  end
  
  dimEndless = tonumber(dimEndless);
  
  dimStepValue = tonumber(dimStepValue);
  if ( dimStepValue == 0 ) then
    dimStepValue = 1;
  elseif ( dimStepValue > 99 ) then
    dimStepValue = 99;
  end
  
  dimStepPause = tonumber(dimStepPause);
  
  if ( dimStepSign == "+" ) then
    -- ? add the calc night mode max value and other?
    dimMaxValue = tonumber(dimMaxValue);
    
    if ( (dimMaxValue == 0) or (dimMaxValue > 99) ) then
      dimMaxValue = 99;
    end
  else
    dimMaxValue = 99;
  end
  
  if ( debugMode ) then
    fibaro:debug("Corrected setting flags: "
      .. "EL = " .. dimEndless .. ", "
      .. "SS = " .. dimStepSign .. ", "
      .. "MV = " .. dimMaxValue .. ", "
      .. "SV = " .. dimStepValue .. ", "
      .. "SP = " .. dimStepPause);
  end
end


-- GET DEV ARRAY

local lightsDimQueue = string.sub(lightsDimming, 12);

if ( debugMode ) then
  fibaro:debug("lightsDimQueue = <" .. lightsDimQueue .. ">");
end

local devTable = {};

for nodeID in string.gmatch(lightsDimQueue, "(%d+)") do -- "(%d+);"
  
  local devID = 0;
  
  -- RGBW device support {
  local subNodeClrIndex = 0;
  local subCurNodeValue = 0;
  
  local lastSymbInNodeID = string.sub(nodeID, -1);
  if (lastSymbInNodeID  == "R" ) then
    subNodeClrIndex = 1;
  elseif ( lastSymbInNodeID == "G" ) then
    subNodeClrIndex = 2;
  elseif ( lastSymbInNodeID == "B" ) then
    subNodeClrIndex = 3;
  elseif ( lastSymbInNodeID == "W" ) then
    subNodeClrIndex = 4;
  end
  
  if ( subNodeClrIndex ~= 0 ) then
    devID = tonumber(string.sub(nodeID, 1, string.len(nodeID) - 1));
    subCurNodeValue = getTheColor(lightDimNode, subNodeClrIndex);
  else
  -- RGBW device support }
    devID = tonumber(nodeID);
  end
  
  local curNodeValue = tonumber(fibaro:getValue(devID, "value"));
  
  local nodeName = "<" .. fibaro:getRoomNameByDeviceID(devID) .. ":"
    .. fibaro:getName(devID);
  
  if ( subNodeClrIndex ~= 0 ) then
    nodeName = nodeName .. " #ch." .. subNodeClrIndex
      .. "-" .. lastSymbInNodeID;
  end
  
  nodeName = nodeName .. ">";
  
  if ( subNodeClrIndex ~= 0 ) then
    if ( debugMode ) then
      fibaro:debug("ADD dimmed RGBWDev: #" .. devID .. " " .. nodeName
        .. " = " .. subCurNodeValue .. " (" .. curNodeValue .. ")");
    end
    
    table.insert(devTable, {devID, subNodeClrIndex, subCurNodeValue});
  else
    if ( debugMode ) then
      fibaro:debug("ADD dimmed Dev: #" .. devID .. " " .. nodeName
        .. " = " .. curNodeValue);
    end
    
    table.insert(devTable, {devID, 0, curNodeValue});
  end
  
end  


-- PROCESS

local valInLimits = true;

while ( (dimEndless == 1) or valInLimits ) do
  
  valInLimits = false;
    
  for i, devItem in ipairs(devTable) do
    
    -- GET DIM.DEV INFO
    
    local devID = devItem[1];
    local subNodeClrIndex = devItem[2];
    local curNodeValue = devItem[3];
    
    -- CALC NEW DIM VAL
    
    local newNodeValue = curNodeValue
      + tonumber(dimStepSign .. "1") * dimStepValue;
      
    if ( newNodeValue > dimMaxValue ) then
      newNodeValue = dimMaxValue;
    elseif ( newNodeValue < 0 ) then
      newNodeValue = 0;
    else
      valInLimits = true;
    end
    
    -- SET NEW DIM VALUE
      
    if ( debugDetailMode ) then
      fibaro:debug("Dimming #" .. devID
        .. ": " .. curNodeValue .. " -> " .. newNodeValue);
    end
    
    devTable[i] = {devID, subNodeClrIndex, newNodeValue};
    
    --fibaro:abort(); -- 4test
    
    if ( subNodeClrIndex ~= 0 ) then
      setTheColor(devID, subNodeClrIndex, 0, newNodeValue);
    else
      fibaro:call(devID, "setValue", newNodeValue);
    end
    
  end
  
  if ( not valInLimits ) then --and (dimEndless == 1) ) then
    if ( debugMode ) then
      fibaro:debug("Dimmed to limits - CHANGE dimSign..");
    end
    
    if ( dimStepSign == "-" ) then
      dimStepSign = "+";
    else
      dimStepSign = "-";
    end
    
    fibaro:setGlobal("lightsDimming",
      tostring(pwr24Checking)
      .. tostring(dimEndless)
      .. tostring(dimStepSign)
      .. string.sub(fibaro:getGlobalValue("lightsDimming"), 4));
    
    if ( dimEndless == 1 ) then
      fibaro:sleep(2000); -- possibility to break dimming in min/max values
    end
  end
  
  if ( debugDetailMode ) then fibaro:debug("Dim. step PAUSE.."); end
  fibaro:sleep(dimStepPause);
  
end

if ( debugMode ) then fibaro:debug("Dimming done"); end
