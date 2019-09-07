--[[
%% properties
%% globals
lightsQueue
--]]


-- CONST

local debugMode = true;

local powerID = 6;


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
if ( fibaro:countScenes() > 1 ) then
  if ( debugMode ) then
    fibaro:debug("Double start (" ..
  	  tostring(fibaro:countScenes()) .. ").. Abort dup!");
  end
  
  fibaro:abort();
end
--local trigger = fibaro:getSourceTrigger();

local powerValue = fibaro:getValue(powerID, "value");

local nightMode = false;
if ( fibaro:getGlobalValue("nightMode") == "1" ) then
  if ( debugMode ) then fibaro:debug("_nightMode detected"); end
  
  nightMode = true;
end


-- PREINIT QUEUE

local lightsQueue = string.gsub(fibaro:getGlobalValue("lightsQueue"),
  "NaN", ""); -- removes the empty value string representation of the glob.var
local lightActionPos = string.find(lightsQueue, ";");


-- QUEUE

if ( debugMode ) then
  fibaro:debug("GET lightsQueue = '" .. lightsQueue .. "'");
end

while ( lightActionPos ~= nil ) do
  
  -- GET ACTION INFO
  
  if ( debugMode ) then
    fibaro:debug("FOUND lightAction, end.pos = " .. tostring(lightActionPos));
  end
  
  local lightAction = string.sub(lightsQueue, 1, lightActionPos);
  
  if ( debugMode ) then
    fibaro:debug("READ lightAction = '" .. lightAction .. "'");
  end
  
  fibaro:setGlobal("lightsQueue", string.sub(lightsQueue, lightActionPos + 1));
  
  local nodeID = string.sub(lightAction, 1, string.find(lightAction, ",") - 1);
  
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
    nodeID = tonumber(string.sub(nodeID, 1, string.len(nodeID) - 1));
    subCurNodeValue = getTheColor(nodeID, subNodeClrIndex);
  else
  -- RGBW device support }
    nodeID = tonumber(nodeID);
  end
  
  local curNodeValue = tonumber(fibaro:getValue(nodeID, "value"));
  
  lightAction = string.sub(lightAction, string.find(lightAction, ",") + 1);
  local nodeValue = tonumber(string.sub(lightAction, 1,
    string.find(lightAction, ";") - 1));
  
  local nodeName = "[" .. fibaro:getRoomNameByDeviceID(nodeID) .. ":"
    .. fibaro:getName(nodeID);
  
  if ( subNodeClrIndex ~= 0 ) then
    nodeName = nodeName .. " #ch." .. subNodeClrIndex
    .. "-" .. lastSymbInNodeID;
    
    curNodeValue = subCurNodeValue .. " (" .. curNodeValue .. ")";
  end
  
  nodeName = nodeName .. "]";
    
  if ( debugMode ) then
    fibaro:debug("Node: #" .. nodeID .. " " .. nodeName
      .. " = " .. curNodeValue .. " -> " .. nodeValue);
  end
  
  --fibaro:abort(); -- 4test
  
  -- PROCESS ACTION
    
  if ( nodeValue == -1 ) then
    -- TURN OFF --
    
    --if ( curNodeValue > 0 ) -- disable the check because fails sometimes
    --  then
    if ( debugMode ) then fibaro:debug("Turning OFF " .. nodeName); end
    
    fibaro:call(nodeID, "turnOff");
    --end
    
  elseif ( nodeValue == 0 ) then
    -- TURN OFF BY SET ZERO VALUE --
    
    if ( debugMode ) then fibaro:debug("Setting to ZERO " .. nodeName); end
    
    if ( subNodeClrIndex ~= 0 ) then
      setTheColor(nodeID, subNodeClrIndex, subCurNodeValue, 0);
    else
      --if ( curNodeValue > 0 ) -- disable check because fails sometimes
      --  then
      fibaro:call(nodeID, "setValue", 0);
      --end
    end
    
  else
    -- TURN ON --
    
    --- Check PowerSource ---
    if ( powerValue == "0" ) then
      if ( debugMode ) then
        fibaro:debug("PowerSource is OFF! Turning ON..");
      end
      
      fibaro:call(powerID, "turnOn");
      fibaro:sleep(3 * 1000);
      
      powerValue = fibaro:getValue(powerID, "value");
      if ( powerValue == "0" ) then
        if ( debugMode ) then
          fibaro:debug("PowerSource turning on was FAIL!");
        end
        
        break;
      end
    else
      if ( debugMode ) then fibaro:debug("PowerSource is on"); end
    end
    
    --- Wakeup devices ---
    if ( fibaro:getValue(nodeID, "dead") >= "1" ) then
      if ( debugMode ) then fibaro:debug("Waking UP dead " .. nodeName); end
      
      fibaro:wakeUpDeadDevice(nodeID);
      --new code for HC2 v4+:
      fibaro:call(1, 'wakeUpAllDevices', nodeID);
      
      fibaro:sleep(2 * 1000);
    end
    
    if ( nodeValue > 100 ) then
      if ( nightMode == true ) then
        nodeValue = 1;
      else
        nodeValue = nodeValue - 100;
      end
    end
    
    if ( nodeValue == 100 ) then
      -- TURN ON
      if ( debugMode ) then fibaro:debug("Turning ON " .. nodeName); end
      
      if ( subNodeClrIndex ~= 0 ) then
        setTheColor(nodeID, subNodeClrIndex, subCurNodeValue, 100);
      else
        fibaro:call(nodeID, "turnOn");
      end
      
    elseif ( nodeValue == 99 ) then
      -- FULL ON
      if ( debugMode ) then fibaro:debug("Setting to FULL " .. nodeName); end
      
      if ( subNodeClrIndex ~= 0 ) then
        setTheColor(nodeID, subNodeClrIndex, subCurNodeValue, 100);
      else
        fibaro:call(nodeID, "setValue", 100);
      end
      
    elseif ( nodeValue <= 3 ) then
      -- MIN
      if ( debugMode ) then fibaro:debug("Setting to MIN " .. nodeName); end
      
      if ( subNodeClrIndex ~= 0 ) then
        setTheColor(nodeID, subNodeClrIndex, subCurNodeValue, 1);
      else
        fibaro:call(nodeID, "setValue", 1);
      end
      
    else
      -- EXACT VALUE
      if ( debugMode ) then
        fibaro:debug("Setting to VALUE [" .. nodeValue .. "] " .. nodeName);
      end
      
      if ( subNodeClrIndex ~= 0 ) then
        setTheColor(nodeID, subNodeClrIndex, subCurNodeValue, nodeValue);
      else
        fibaro:call(nodeID, "setValue", nodeValue);
      end
    end
    
  end -- if ( nodeValue ... )

  -- REINIT QUEUE
  
  lightsQueue = string.gsub(fibaro:getGlobalValue("lightsQueue"),
    "NaN", ""); -- removes the empty value string representation of the glob.var
  lightActionPos = string.find(lightsQueue, ";");
  
  if ( debugMode ) then
    fibaro:debug("_lightsQueue = '" .. lightsQueue .. "'");
  end
end

if ( debugMode ) then fibaro:debug("CLEAR lightsQueue and exit"); end

fibaro:setGlobal("lightsQueue", "");
