--[[
%% properties
6 value
39 power
40 value
210 value
259 power
260 value
266 value
147 power
148 value
%% globals
--]]


local power24ID = 6;

local startSource = fibaro:getSourceTrigger();

if (
    (tonumber(fibaro:getValue(power24ID, "value")) == 1)
    and ((tonumber(fibaro:getValue(39, "power")) == 0) -- BRL_pwr
    	or (tonumber(fibaro:getValue(40, "value")) == 0)) -- BRL_all
    and (tonumber(fibaro:getValue(210, "value")) == 0) -- BR:lightAux
    and ((tonumber(fibaro:getValue(259, "power")) == 0) -- SRL_pwr
      or (tonumber(fibaro:getValue(260, "value")) == 0)) -- SRL_all
    and (tonumber(fibaro:getValue(266, "value")) == 0) -- SR:lightAux
    and ((tonumber(fibaro:getValue(147, "power")) == 0) -- HKL_pwr
    	or (tonumber(fibaro:getValue(148, "value")) == 0)) -- HKL_all
  ) then
  
  fibaro:debug("All lights off.. Delay..");
  
  if ( startSource["type"] ~= "other" ) then
    
    if ( fibaro:countScenes() > 1 ) then
      fibaro:debug("Abort dup call");
      fibaro:abort();
    end
    
    fibaro:sleep(30 * 1000);
    
  end
  
  if (
      (tonumber(fibaro:getValue(power24ID, "value")) == 1)
      and ((tonumber(fibaro:getValue(39, "power")) == 0) -- BRL_pwr
          or (tonumber(fibaro:getValue(40, "value")) == 0)) -- BRL_all
      and (tonumber(fibaro:getValue(210, "value")) == 0) -- BR:lightAux
      and ((tonumber(fibaro:getValue(259, "power")) == 0) -- SRL_pwr
        or (tonumber(fibaro:getValue(260, "value")) == 0)) -- SRL_all
      and (tonumber(fibaro:getValue(266, "value")) == 0) -- SR:lightAux
      and ((tonumber(fibaro:getValue(147, "power")) == 0) -- HKL_pwr
          or (tonumber(fibaro:getValue(148, "value")) == 0)) -- HKL_all
    ) then
    
    fibaro:debug("All lights off yet.. Turn OFF Power24 source!");
    fibaro:call(power24ID, "turnOff");
    
  else
    
    fibaro:debug("Not all lights off");
    
  end
  
end
