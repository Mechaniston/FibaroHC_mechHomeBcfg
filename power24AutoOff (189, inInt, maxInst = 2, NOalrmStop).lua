--[[
%% properties
40 value
210 value
260 value
266 value
148 value
%% globals
--]]


local startSource = fibaro:getSourceTrigger();

if (
    (tonumber(fibaro:getValue(40, "value")) == 0) -- BRL_all
    and (tonumber(fibaro:getValue(210, "value")) == 0) -- ֱÊ:ׁגועהמן
    and (tonumber(fibaro:getValue(260, "value")) == 0) -- SRL_all
    and (tonumber(fibaro:getValue(266, "value")) == 0) -- ּÊ:ׁגוע המן
    and (tonumber(fibaro:getValue(148, "value")) == 0) -- HKL_all
  ) then
  
  fibaro:debug("All lights off.. Delay..");
  
  if ( startSource["type"] ~= "other" ) then
    
    if ( fibaro:countScenes() > 1 ) then
      fibaro:abort();
    end
    
    fibaro:sleep(15 * 1000);
    
  end
  
  if (
      (tonumber(fibaro:getValue(40, "value")) == 0) -- BRL_all
      and (tonumber(fibaro:getValue(210, "value")) == 0) -- ֱÊ:ׁגועהמן
      and (tonumber(fibaro:getValue(260, "value")) == 0) -- SRL_all
      and (tonumber(fibaro:getValue(266, "value")) == 0) -- ּÊ:ׁגוע המן
      and (tonumber(fibaro:getValue(148, "value")) == 0) -- HKL_all
    ) then
    
    fibaro:debug("All lights off yet.. Turn OFF Power24 source!");
    fibaro:call(4, "turnOff");
    
  end
  
end
