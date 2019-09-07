--[[
%% properties
%% globals
mechInHomeB
LenaInHomeB
LeraInHomeB
somebodyInHomeB
--]]


local startSource = fibaro:getSourceTrigger();
if (
--[[ because bugged detection :(
 (fibaro:getGlobalValue("mechInHomeB") == "0")
and
 (fibaro:getGlobalValue("LenaInHomeB") == "0")
and
 (fibaro:getGlobalValue("LeraInHomeB") == "0")
and--]]
 (fibaro:getGlobalValue("somebodyInHomeB") == "0")
) or (startSource["type"] == "other")
then
  
  if ( fibaro:getGlobalValue("somebodyInHomeB") == "1" ) then
    fibaro:setGlobal("somebodyInHomeB", "0");
    fibaro:abort(); -- because the scene was restarted in revious line
  end
 
  fibaro:debug("Everybody left the home! Start auto-sequence..");
  
  local seqTime = os.time();
  
  for idx = 0, 2 do
    fibaro:call(37, "setValue", "0");
    fibaro:call(38, "setValue", "99");
    fibaro:sleep(500);
    fibaro:call(37, "setValue", "99");
    fibaro:call(38, "setValue", "0");
    fibaro:sleep(500);
  end
  fibaro:call(38, "setValue", "99");

  fibaro:startScene("7"); -- allOff
  
  while ( os.time() - seqTime <= 2 * 60 ) do -- left timeout
    fibaro:call(37, "setValue", "0");
    fibaro:call(38, "setValue", "0");
    fibaro:sleep(5000);
    fibaro:call(37, "setValue", "99");
    fibaro:call(38, "setValue", "99");
    fibaro:sleep(10000);
  end
  
  cycleIndex = 0;
  
  while true do
    
    cycleIndex = cycleIndex + 1;
    
    fibaro:sleep(1000 * 60 * (60 + math.random(60))); -- 1-2 hour
    
    if ( cycleIndex % 2 == 0 ) then
      fibaro:debug("Auto-on BR_vent");
      fibaro:call(179, "turnOn"); -- BR_vent
    end
    
    local curTime = os.date("*t");
    
    if ( (curTime.hour >= 6) and (curTime.hour <= 9)
      or (curTime.hour >= 19) and (curTime.hour <= 23) ) then
      
      local lightRoom = math.random(2);
      
      if ( lightRoom == 0 ) then
        fibaro:debug("Auto-on BR_light");
        fibaro:call(195, "pressButton", "6"); -- BR_vdLight
      elseif ( lightRoom == 1 ) then
        fibaro:debug("Auto-on SR_light");
        fibaro:call(272, "pressButton", "5"); -- SR_vdLight
      elseif ( lightRoom == 2 ) then
        fibaro:debug("Auto-on K_light");
        fibaro:call(196, "pressButton", "5"); -- K_vdLight
      end
      
      fibaro:sleep(1000 * 60 * 10);
      
      if ( cycleIndex % 2 == 0 ) then
        fibaro:debug("Auto-off BR_vent");
        fibaro:call(179, "turnOff");
      end
      
      if ( lightRoom == 0 ) then
        fibaro:debug("Auto-off BR_light");
        fibaro:call(195, "pressButton", "6"); -- BR_vdLight
      elseif ( lightRoom == 1 ) then
        fibaro:debug("Auto-off SR_light");
        fibaro:call(272, "pressButton", "5"); -- SR_vdLight
      elseif ( lightRoom == 2 ) then
        fibaro:debug("Auto-off K_light");
        fibaro:call(196, "pressButton", "5"); -- K_vdLight
      end
      
    end
    
  end
  
end
