--[[
%% properties

%% globals
--]]

-- CONSTS

local moveTime  = 20 * 1000;
local knockTime = 300;
local relaxTime = 5 * 1000;

local blindsMidID = 181;
local blindsSidesID = 183;

local debugMode = true;


-- GET ENVS

---

local posMid = tonumber(fibaro:getValue(189, "ui.Slider2.value"));
if debugMode then fibaro:debug("sliderMid = " .. tostring(posMid)); end

if posMid > 5 and posMid < 50
then
  posMid = 25;
elseif posMid >= 50
then
  posMid = 100;
else
  posMid = 0;
end;

if debugMode then fibaro:debug("sliderMid aligned = " .. tostring(posMid)); end

local blindsMidPos = tonumber(fibaro:getGlobalValue("blindsMidPos"));
if debugMode then fibaro:debug("blindsMidPos = " .. tostring(blindsMidPos)); end

---

local posSides = tonumber(fibaro:getValue(189, "ui.Slider3.value"));
if debugMode then fibaro:debug("sliderSides = " .. tostring(posSides)); end

if posSides > 5 and posSides < 50
then
  posSides = 25;
elseif posSides >= 50
then
  posSides = 100;
else
  posSides = 0;
end;

if debugMode then fibaro:debug("sliderSides aligned = " .. tostring(posSides)); end

local blindsSidesPos = tonumber(fibaro:getGlobalValue("blindsSidesPos"));
if debugMode then fibaro:debug("blindsSidesPos = " .. tostring(blindsSidesPos)); end

---

local pos = ???;


-- PROCESS

if pos == 0 or pos == 100 then
  
  if blindsMidPos == 25 or blindsMidPos == 100 then
    if debugMode then fibaro:debug("BlindsMid MOVE!"); end
    fibaro:call(blindsMidID, "turnOn");
  end
  
  if blindsSidesPos == 25 or blindsSidesPos == 100 then
    fibaro:call(blindsSidesID, "turnOn");
    if debugMode then fibaro:debug("BlindsSides MOVE!"); end
  end
  
  if debugMode then fibaro:debug("- move time"); end
  fibaro:sleep(moveTime);
  
  if blindsMidPos == 25 or blindsMidPos == 100 then
    if debugMode then fibaro:debug("BlindsMid STOP!"); end
    fibaro:call(blindsMidID, "turnOff");
  end
  
  if blindsSidesPos == 25 or blindsSidesPos == 100 then
    if debugMode then fibaro:debug("BlindsSides STOP!"); end
    fibaro:call(blindsSidesID, "turnOff");
  end
  
  if pos == 0 then
    if blindsMidPos == 25 or blindsSidesPos == 25 then
      if debugMode then fibaro:debug("- relax time"); end
      fibaro:sleep(relaxTime);
      
      if blindsMidPos == 25 then
        if debugMode then fibaro:debug("BlindsMid MOVE!"); end
        fibaro:call(blindsMidID, "turnOn");
      end;
      
      if blindesSidesPos == 25 then
        if debugMode then fibaro:debug("BlindsSides MOVE!"); end
        fibaro:call(blindsSidesID, "turnOn");
      end
      
      if debugMode then fibaro:debug("- move time"); end
      fibaro:sleep(moveTime);
      
      if blindsMidPos == 25 then
        if debugMode then fibaro:debug("BlindsMid STOP!"); end
        fibaro:call(blindsMidID, "turnOff");
      end
      
      if blindesSidesPos == 25 then
        if debugMode then fibaro:debug("BlindsSides STOP!"); end
        fibaro:call(blindsSidesID, "turnOff");
      end
      
    end
    
  end
  
elseif pos == 25 then
  
  if blindsMidPos == 0 or blindsMidPos == 100 then
    if debugMode then fibaro:debug("BlindsMid MOVE!"); end
    fibaro:call(blindsMidID, "turnOn");
  end
  
  if blindsSidesPos == 0 or blindsSidesPos == 100 then
    if debugMode then fibaro:debug("BlindsSides MOVE!"); end
    fibaro:call(blindsSidesID, "turnOn");
  end
  
  if blindsMidPos == 0 or blindsSidesPos == 0 then
    if debugMode then fibaro:debug("- knock time"); end
    fibaro:sleep(knockTime);
  else
    if debugMode then fibaro:debug("- move time"); end
    fibaro:sleep(moveTime);
  end
  
  if blindsMidPos == 0 then
    fibaro:call(blindsMidID, "turnOff");
  elseif blindsSidesPos == 0 then
    if debugMode then fibaro:debug("BlindsSides STOP!"); end
    fibaro:call(blindsSidesID, "turnOff");
  end
  
  if blindsMidPos == 100 or blindsSidesPos == 100 then
    if debugMode then fibaro:debug("- move minus knock time"); end
    fibaro:sleep(moveTime - knockTime);
  end
  
  if blindsMidPos == 100 then
    if debugMode then fibaro:debug("BlindsMid STOP!"); end
    fibaro:call(blindsMidID, "turnOff");
  end
  
  if blindsSidesPos == 100 then
    if debugMode then fibaro:debug("BlindsSides STOP!"); end
    fibaro:call(blindsSidesID, "turnOff");
  end
  
end

if debugMode then fibaro:debug("Set overall postion = " .. tostring(pos)); end

fibaro:setGlobal("blindsMidPos", pos);
fibaro:setGlobal("blindsSidesPos", pos);

fibaro:call(189, "setProperty", "ui.Slider2.value", tostring(pos));
fibaro:call(189, "setProperty", "ui.Slider3.value", tostring(pos));
