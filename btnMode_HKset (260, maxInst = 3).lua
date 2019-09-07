--[[
%% properties
%% weather
%% events
%% globals
btnMode_HK
--]]


local startSource = fibaro:getSourceTrigger();

if ( startSource["type"] == "other" ) then
  
  fibaro:debug("Try to manual toggle btnMode_HK in..");
  
  if ( fibaro:getGlobalValue("btnMode_HK") == "0" ) then
    fibaro:debug(".. <1>");
    
    fibaro:setGlobal("btnMode_HK", "1");
  else
    fibaro:debug(".. <0>");
    
    fibaro:setGlobal("btnMode_HK", "0");
  end
  
  fibaro:abort();
  
end

if ( fibaro:getGlobalValue("btnMode_HK") == "0" ) then
  
  fibaro:debug("btnMode_HK is <0>");
  
  fibaro:call(37, "setValue", "0");
  fibaro:call(38, "setValue", "0");
  fibaro:sleep(500);
  fibaro:call(37, "setValue", "99");
  fibaro:call(38, "setValue", "99");
  
elseif ( fibaro:getGlobalValue("btnMode_HK") == "1" ) then
  
  fibaro:debug("btnMode_HK is <1>");
  
  fibaro:call(37, "setValue", "0");
  fibaro:call(38, "setValue", "0");
  fibaro:sleep(500);
  fibaro:call(37, "setValue", "99");
  fibaro:call(38, "setValue", "99");
  fibaro:sleep(10000);
  
  fibaro:debug("Try to set btnMode_HK in <0>");
  
  fibaro:setGlobal("btnMode_HK", "0");
  
end
