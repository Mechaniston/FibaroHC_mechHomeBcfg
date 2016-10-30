--[[
%% properties

%% globals
--]]


-- CONSTS

local bFullOpened = 100;
local bGapOpened  = 50; -- the horizontal orientation after full closed
local bGapClosed  = 20; -- the up-closed after gap opened
local bFullClosed = 0;

local moveTime  = 20 * 1000;
local knockTime = 200;
local relaxTime = 5 * 1000;

local blindsMidID = 181;
local blindsSidesID = 183;

local blindsVDID = 189;

local debugMode = true;


-- GET ENVS

fibaro:sleep(50); -- to prevent to kill all instances
if ( fibaro:countScenes() > 1 ) then
  if ( debugMode ) then fibaro:debug("Double start"
    .. "(" .. tostring(fibaro:countScenes()) .. ").. Abort dup!"); end
  fibaro:abort();
end

local alignGOarea_Low = (bGapClosed + bGapOpened) / 2;
local alignGOarea_High = bGapOpened + (bGapOpened - alignGOarea_Low);
if ( debugMode ) then
  fibaro:debug("alignGOarea in ("
    .. tostring(alignGOarea_Low) .. "," .. tostring(alignGOarea_High) .. ")");
end

---

local newMidPos = tonumber(fibaro:getValue(blindsVDID, "ui.Slider2.value"));
if ( debugMode ) then fibaro:debug("sliderMid = " .. tostring(newMidPos)); end

if ( (newMidPos > alignGOarea_Low) and (newMidPos < alignGOarea_High) ) then
  newMidPos = bGapOpened;
elseif ( newMidPos >= alignGOarea_High ) then
  newMidPos = bFullOpened;
else
  newMidPos = bFullClosed;
end

if ( debugMode ) then
  fibaro:debug("sliderMid aligned = " .. tostring(newMidPos));
end

local blindsMidPos = tonumber(fibaro:getGlobalValue("blindsMidPos"));
if ( debugMode ) then
  fibaro:debug("blindsMidPos = " .. tostring(blindsMidPos));
end

---

local newSidPos = tonumber(fibaro:getValue(blindsVDID, "ui.Slider3.value"));
if ( debugMode ) then
  fibaro:debug("sliderSides = " .. tostring(newSidPos));
end

if ( (newSidPos > alignGOarea_Low) and (newSidPos < alignGOarea_High) ) then
  newSidPos = bGapOpened;
elseif ( newSidPos >= alignGOarea_High ) then
  newSidPos = bFullOpened;
else
  newSidPos = bFullClosed;
end

if ( debugMode ) then
  fibaro:debug("sliderSides aligned = " .. tostring(newSidPos));
end

local blindsSidPos = tonumber(fibaro:getGlobalValue("blindsSidPos"));
if ( debugMode ) then
  fibaro:debug("blindsSidPos = " .. tostring(blindsSidPos));
end

---


-- PROCESS

fibaro:setGlobal("blindsMidPos", newMidPos);
fibaro:setGlobal("blindsSidPos", newSidPos);

if ( ((newMidPos ~= blindsMidPos)
    and not((newMidPos == bFullClosed) and (blindsMidPos == bGapClosed)))
  or ((newSidPos ~= blindsSidPos)
    and not((newSidPos == bFullClosed) and (blindsSidPos == bGapClosed))) ) then
  
  -- start to move, if need
  
  if ( (newMidPos ~= blindsMidPos)
    and not((newMidPos == bFullClosed) and (blindsMidPos == bGapClosed)) ) then
    
    if ( debugMode ) then fibaro:debug("BlindsMid MOVE!"); end
    fibaro:call(blindsMidID, "turnOn");
    
  end
  
  if ( (newSidPos ~= blindsSidPos)
    and not((newSidPos == bFullClosed) and (blindsSidPos == bGapClosed)) ) then
    
    if ( debugMode ) then fibaro:debug("BlindsSides MOVE!"); end
    fibaro:call(blindsSidesID, "turnOn");
    
  end
  
  -- wait sometime
  
  if ( (blindsMidPos == bGapOpened and newMidPos == bFullClosed)
  	or (blindsMidPos == bFullClosed and newMidPos == bGapOpened)
 	or (blindsSidPos == bGapOpened and newSidPos == bFullClosed)
  	or (blindsSidPos == bFullClosed and newSidPos == bGapOpened) ) then
    
    if ( debugMode ) then fibaro:debug("- knock time"); end
    fibaro:sleep(knockTime);
    
  elseif ( not((newMidPos == bFullClosed) and (blindsMidPos == bGapClosed))
    and not((newSidPos == bFullClosed) and (blindsSidPos == bGapClosed)) ) then
    
    if ( debugMode ) then fibaro:debug("- move time"); end
    fibaro:sleep(moveTime);
    
  end
  
  -- stop the movement
  
  if ( (blindsMidPos ~= newMidPos)
    and not((blindsMidPos == bGapClosed) and (newMidPos == bFullClosed)) ) then
    
    if ( debugMode ) then fibaro:debug("BlindsMid STOP!"); end
    fibaro:call(blindsMidID, "turnOff");
    
  end
  
  if ( (blindsSidPos ~= newSidPos)
    and not((blindsSidPos == bGapClosed) and (newSidPos == bFullClosed)) ) then
    
    if ( debugMode ) then fibaro:debug("BlindsSides STOP!"); end
    fibaro:call(blindsSidesID, "turnOff");
    
  end
  
  -- reverse move, if need
  
  local midReverse =
    ((blindsMidPos == bGapClosed) or (blindsMidPos == bFullOpened))
    and (newMidPos == bGapOpened);
  
  local sidesReverse =
    ((blindsSidPos == bGapClosed) or (blindsSidPos == bFullOpened))
    and (newSidPos == bGapOpened);
  
  if ( midReverse or sidesReverse ) then
    
    if ( debugMode ) then fibaro:debug("- relax time"); end
    fibaro:sleep(relaxTime);
    
    -- start to move
    
    if ( midReverse ) then
      
      if ( debugMode ) then fibaro:debug("BlindsMid MOVE!"); end
      fibaro:call(blindsMidID, "turnOn");
      
    end
        
    if ( sidesReverse ) then
      if ( debugMode ) then fibaro:debug("BlindsSides MOVE!"); end
      fibaro:call(blindsSidesID, "turnOn");
    end
    
    -- wait some MIN time
    
    if ( (blindsMidPos == bFullOpened) or (blindsSidPos == bFullOpened) ) then
      
      if ( debugMode ) then fibaro:debug("- knock time"); end
      fibaro:sleep(knockTime);
      
    else
      
      if ( debugMode ) then fibaro:debug("- move time"); end
      fibaro:sleep(moveTime);
      
    end
        
    -- stop the movement
    
    if ( midReverse ) then
      if ( debugMode ) then fibaro:debug("BlindsMid STOP!"); end
      fibaro:call(blindsMidID, "turnOff");
    end
        
    if ( sidedReverse ) then
      if ( debugMode ) then fibaro:debug("BlindsSides STOP!"); end
      fibaro:call(blindsSidesID, "turnOff");
    end
    
    -- need to move the rest (only for pos bGapClosed to pos bGapOpened)
    
    if ( (blindsMidPos == bGapClosed) or (blindsSidPos == bGapClosed) ) then
      
      if ( debugMode ) then fibaro:debug("- relax time"); end
      fibaro:sleep(relaxTime);
    
      -- third start to move
      
      if ( blindsMidPos == bGapClosed ) then
        
        if ( debugMode ) then fibaro:debug("BlindsMid MOVE!"); end
        fibaro:call(blindsMidID, "turnOn");
      end
          
      if ( blindsSidPos == bGapClosed ) then
        if ( debugMode ) then fibaro:debug("BlindsSides MOVE!"); end
        fibaro:call(blindsSidesID, "turnOn");
      end
      
      -- wait min time
      
      if ( debugMode ) then fibaro:debug("- knock time"); end
      fibaro:sleep(knockTime);
      
      -- final stopping
      
      if ( blindsMidPos == bGapClosed ) then
        
        if ( debugMode ) then fibaro:debug("BlindsMid STOP!"); end
        fibaro:call(blindsMidID, "turnOff");
        
      end
          
      if ( blindsSidPos == bGapClosed ) then
        
        if ( debugMode ) then fibaro:debug("BlindsSides STOP!"); end
        fibaro:call(blindsSidesID, "turnOff");
        
      end
      
    end
    
  else
    
    if ( (blindsMidPos == bGapOpened) and (newMidPos == bFullClosed) ) then
      
      if ( debugMode ) then fibaro:debug("SliderMid in bGapClosed!"); end
      newMidPos = bGapClosed;
      
    end
    
    if ( (blindsSidPos == bGapOpened) and (newSidPos == bFullClosed) ) then
      
      if debugMode then fibaro:debug("SliderSides in bGapClosed!"); end
      newSidPos = bGapClosed;
      
    end
    
  end
  
end
