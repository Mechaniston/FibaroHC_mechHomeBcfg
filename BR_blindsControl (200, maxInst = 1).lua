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


-- PROCESS

if ((posMid ~= blindsMidPos)
    	and not((posMid == 0) and (blindsMidPos == 26)))
  	or ((posSides ~= blindsSidesPos)
    	and not((posSides == 0) and (blindsSidesPos == 26)))
then
  if (posMid ~= blindsMidPos) and not((posMid == 0) and (blindsMidPos == 26))
  then
    if debugMode then fibaro:debug("BlindsMid MOVE!"); end
    fibaro:call(blindsMidID, "turnOn");
  end
  
  if (posSides ~= blindsSidesPos) and not((posSides == 0) and (blindsSidesPos == 26))
  then
    if debugMode then fibaro:debug("BlindsSides MOVE!"); end
    fibaro:call(blindsSidesID, "turnOn");
  end
  
  if (blindsMidPos == 25 and posMid == 0)
  	or (blindsMidPos == 0 and posMid == 25)
 	or (blindsSidesPos == 25 and posSides == 0)
  	or (blindsSidesPos == 0 and posSides == 25)
  then
    if debugMode then fibaro:debug("- knock time"); end
    fibaro:sleep(knockTime);
  elseif not((posMid == 0) and (blindsMidPos == 26))
    	and not((posSides == 0) and (blindsSidesPos == 26))
  then
    if debugMode then fibaro:debug("- move time"); end
    fibaro:sleep(moveTime);
  end
  
  if (blindsMidPos ~= posMid)
    	and not((blindsMidPos == 26) and (posMid == 0))
  then
    if debugMode then fibaro:debug("BlindsMid STOP!"); end
    fibaro:call(blindsMidID, "turnOff");
  end
  
  if (blindsSidesPos ~= posSides)
    	and not((blindsSidesPos == 26) and (posSides == 0))
  then
    if debugMode then fibaro:debug("BlindsSides STOP!"); end
    fibaro:call(blindsSidesID, "turnOff");
  end
  
  if (
      ((blindsMidPos == 26) or (blindsMidPos == 100)) and (posMid == 25)
    )
 	or (
      ((blindsSidesPos == 26) or (blindsSidesPos == 100)) and (posSides == 25)
    )
  then
    if debugMode then fibaro:debug("- relax time"); end
    fibaro:sleep(relaxTime);
    
    if ((blindsMidPos == 26) or (blindsMidPos == 100)) and (posMid == 25)
    then
      if debugMode then fibaro:debug("BlindsMid MOVE!"); end
      fibaro:call(blindsMidID, "turnOn");
    end
        
    if ((blindsSidesPos == 26) or (blindsSidesPos == 100)) and (posSides == 25)
    then
      if debugMode then fibaro:debug("BlindsSides MOVE!"); end
      fibaro:call(blindsSidesID, "turnOn");
    end
  
    if (blindsMidPos == 100) or (blindsSidesPos == 100) then
      if debugMode then fibaro:debug("- knock time"); end
      fibaro:sleep(knockTime);
    else
      if debugMode then fibaro:debug("- move time"); end
      fibaro:sleep(moveTime);
    end;
        
    if ((blindsMidPos == 26) or (blindsMidPos == 100)) and (posMid == 25)
    then
      if debugMode then fibaro:debug("BlindsMid STOP!"); end
      fibaro:call(blindsMidID, "turnOff");
    end
        
    if ((blindsSidesPos == 26) or (blindsSidesPos == 100)) and (posSides == 25)
    then
      if debugMode then fibaro:debug("BlindsSides STOP!"); end
      fibaro:call(blindsSidesID, "turnOff");
    end
    
    if (blindsMidPos == 26) or (blindsSidesPos == 26) then
      if debugMode then fibaro:debug("- relax time"); end
      fibaro:sleep(relaxTime);
    
      if blindsMidPos == 26
      then
        if debugMode then fibaro:debug("BlindsMid MOVE!"); end
        fibaro:call(blindsMidID, "turnOn");
      end
          
      if blindsSidesPos == 26
      then
        if debugMode then fibaro:debug("BlindsSides MOVE!"); end
        fibaro:call(blindsSidesID, "turnOn");
      end
    
      if debugMode then fibaro:debug("- knock time"); end
      fibaro:sleep(knockTime);
        
      if blindsMidPos == 26
      then
        if debugMode then fibaro:debug("BlindsMid STOP!"); end
        fibaro:call(blindsMidID, "turnOff");
      end
          
      if (blindsSidesPos == 26)
      then
        if debugMode then fibaro:debug("BlindsSides STOP!"); end
        fibaro:call(blindsSidesID, "turnOff");
      end
    end
  else
    if blindsMidPos == 25 and posMid == 0
    then
      if debugMode then fibaro:debug("SliderMid in 26!"); end
      posMid = 26;
    end
    if blindsSidesPos == 25 and posSides == 0
    then
      if debugMode then fibaro:debug("SliderSides in 26!"); end
      posSides = 26;
    end
  end
end

fibaro:setGlobal("blindsMidPos", posMid);
fibaro:call(189, "setProperty", "ui.Slider2.value", tostring(posMid));

fibaro:setGlobal("blindsSidesPos", posSides);
fibaro:call(189, "setProperty", "ui.Slider3.value", tostring(posSides));

local pos = math.floor((posMid + posSides) / 2);
fibaro:call(189, "setProperty", "ui.Slider1.value", tostring(pos));
