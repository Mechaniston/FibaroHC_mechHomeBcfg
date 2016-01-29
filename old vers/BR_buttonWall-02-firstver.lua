--[[
%% properties
201 sceneActivation
206 sceneActivation
%% globals
--]]

--[[
if use "%% properties 201 value" and "norm. open"
- just start scene
[DEBUG] 00:32:56: sceneAct = 20
[DEBUG] 00:32:56: value = 0
- any click
[DEBUG] 00:33:15: sceneAct = 10
[DEBUG] 00:33:15: value = 1
[DEBUG] 00:33:15: sceneAct = 11
[DEBUG] 00:33:15: value = 0

if use "%% properties 201 value" and "norm. open"
- just start scene
[DEBUG] 00:32:56: sceneAct = 15
[DEBUG] 00:32:56: value = 1
- single click(dbl & triple - ignore)
[DEBUG] 00:33:15: sceneAct = 10
[DEBUG] 00:33:15: value = 1

if use "201 sceneActivation"
- just start scene
[DEBUG] 00:52:03: triggerSceneActID = 15
[DEBUG] 00:52:03: value = 1
--
[DEBUG] 00:52:32: triggerSceneActID = 11
[DEBUG] 00:52:32: value = 0
[DEBUG] 00:52:38: triggerSceneActID = 14
[DEBUG] 00:52:38: value = 0
[DEBUG] 00:52:43: triggerSceneActID = 15
[DEBUG] 00:52:43: value = 0
--]]

local trigger = fibaro:getSourceTrigger();

if ( trigger["type"] == "property" )
then
  local triggerDeviceID = trigger['deviceId'];
  local triggerSceneActID = tonumber(fibaro:getValue(triggerDeviceID, "sceneActivation"));
  
  fibaro:debug("triggerDeviceID = " .. triggerDeviceID);
  fibaro:debug("triggerSceneActID = " .. triggerSceneActID);
  fibaro:debug("value = " .. fibaro:getValue(triggerDeviceID, "value"));
  
  if ( (triggerSceneActID == 16)
      or (triggerSceneActID == 10)
      or (triggerSceneActID == 11) ) 				-- > single click
  then
    
    fibaro:call(195, "pressButton", "6"); 			-- БК_осн.свет SWITCH
    
  elseif ( triggerSceneActID == 14 ) 				-- > dbl. click
  then
    
    local val1, DT1 = fibaro:get(40, "value");  -- БК общ
    local val2, DT2 = fibaro:get(148, "value"); -- К_Х общ
    
    fibaro:debug("#40 val = ".. val1 .. ", #148 val = " .. val2);
    
    local curTime = os.time();
    local value1 = tonumber(val1);
    local value2 = tonumber(val2);
    
    if ( (DT2 > DT1) and (curTime - DT2 < 6) )	-- К_Х light was last turn during 5 sec
    then
      
      if ( tonumber(fibaro:getValue(149, "value")) > 0 )
      then
        if ( tonumber(fibaro:getValue(150, "value")) > 0 )
        then
          if ( tonumber(fibaro:getValue(151, "value")) > 0 )
          then
            fibaro:call(150, "turnOff");
            fibaro:call(151, "turnOff");
          else
            fibaro:call(150, "turnOff");
          end
        else
          fibaro:call(207, "pressButton", "1");		-- vd.Свет:Коридор light ON
        end
      else
        if ( tonumber(fibaro:getValue(150, "value")) > 0 )
        then
          if ( tonumber(fibaro:getValue(151, "value")) > 0 )
          then
            fibaro:call(149, "setValue", fibaro:getValue(150, "value"));
          else
            fibaro:call(151, "setValue", fibaro:getValue(150, "value"));
          end
        else
          fibaro:call(196, "pressButton", "1");		-- vd.Свет:Кухня light ON
        end
      end
      
    else
      
      local bedLight = tonumber(fibaro:getValue(44, "value"));
      local bedIsDown = tonumber(fibaro:getValue(205, "value"));
      
      if ( (bedLight == 0) and bedIsDown )
      then
        
        fibaro:call(195, "pressButton", "8");		-- БК_Кровать light ON
        
      elseif ( (value1 == 0) and (bedLight ~= 0) )
      then
        
        fibaro:call(195, "pressButton", "10");		-- БК_Кровать light OFF
        fibaro:call(195, "pressButton", "2");		-- БК light ON
        
      elseif ( (value1 ~= 0) and (bedLight ~= 0) )
      then
        
        fibaro:call(195, "pressButton", "4");		-- БК light OFF
        
      else
        
        fibaro:call(195, "pressButton", "2");		-- БК light ON
        fibaro:call(195, "pressButton", "8");		-- БК_Кровать light ON
        
      end
    end 
    
  elseif ( triggerSceneActID == 15 ) 				-- > triple click
  then
    
    fibaro:call(196, "pressButton", "5"); 			-- К_Х_Кухня light SWITCH
    fibaro:call(207, "pressButton", "5"); 			-- К_Х_Коридор light SWITCH
    
  end
  
end
