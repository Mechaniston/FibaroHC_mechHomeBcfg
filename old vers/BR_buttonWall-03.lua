--[[
%% properties
201 sceneActivation
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

if ( fibaro:countScenes() > 1 )
then
  fibaro:debug("Double start.. Abort dup!");
  fibaro:abort();
end

local trigger = fibaro:getSourceTrigger();

if ( trigger["type"] == "property" )
then
  local lightLeft   = tonumber(fibaro:getValue(41, "value"));
  local lightCenter = tonumber(fibaro:getValue(42, "value"));
  local lightRight  = tonumber(fibaro:getValue(43, "value"));
  local lightBed    = tonumber(fibaro:getValue(44, "value"));
  local bedIsDown = tonumber(fibaro:getValue(205, "value"));
  local lightKitchen = tonumber(fibaro:getValue(149, "value"));
  local lightHall    = tonumber(fibaro:getValue(150, "value"));
  
  fibaro:debug(
  	"lightLeft = " .. tostring(lightLeft) .. ", "
  	.. "lightCenter = " .. tostring(lightCenter) .. ", "
  	.. "lightRight = " .. tostring(lightRight) .. ", "
  	.. "lightBed = " .. tostring(lightBed) .. ", "
  	.. "bedIsDown = " .. tostring(bedIsDown) .. ", "
  	.. "lightKitchen = " .. tostring(lightKitchen) .. ", "
  	.. "lightHall = " .. tostring(lightHall) .. ", "
  );
  
  local triggerDeviceID = 201; --trigger['deviceId']; --!!!!! 
  local triggerSceneActID = tonumber(fibaro:getValue(triggerDeviceID, "sceneActivation"));
  
  fibaro:debug("triggerDeviceID = " .. triggerDeviceID);
  fibaro:debug("triggerSceneActID = " .. triggerSceneActID);
  fibaro:debug("value = " .. fibaro:getValue(triggerDeviceID, "value"));
  
  if ( (triggerSceneActID == 16)
      or (triggerSceneActID == 10)
      or (triggerSceneActID == 11) ) 				-- > single click
  then
    
    fibaro:call(195, "pressButton", "6"); 			-- vd.Свет:БК-осн SWITCH
    
  elseif ( triggerSceneActID == 14 ) 				-- > dbl. click
  then
    
    local val1, DT1 = fibaro:get(40, "value");  -- БК общ
    local val2, DT2 = fibaro:get(148, "value"); -- К_Х общ
    
    fibaro:debug("#40 val = ".. val1 .. ", #148 val = " .. val2);
    
    --local curTime = os.time();
    local value1 = tonumber(val1);
    local value2 = tonumber(val2);
    
    local lightsActions = "";
    
    if ( (DT2 > DT1) and (curTime - DT2 < 6) )	-- К_Х light was switched during last 5 sec
    then -- change К_Х lights
      
      if ( lightKitchen > 0 )
      then
        if ( lightHall > 0 )
        then
          lightsActions = lightsActions .. "151,0;150,0;";
        else
          lightsActions = lightsActions .. "150," .. tostring(lightKitchen)
          	.. ";151," .. tostring(lightKitchen)
          	.. ";149,0";
        end
      else
        if ( lightHall > 0 )
        then
          lightsActions = lightsActions .. "149," .. tostring(lightHall) .. ";";
        else
          lightsActions = lightsActions .. "151,101;150,101;149,101;";
        end
      end
      --[[
        else
          fibaro:call(207, "pressButton", "1");		-- vd.Свет:Коридор ON
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
      --]]
    else -- change БК lights
      
      if ( (lightBed == 0) and (bedIsDown == true) )
      then
        lightsActions = lightsActions .. "44,101;";	-- Свет:БК_Кровать on
      else
        
        if ( lightBed > 0 )
        then
          lightsActions = lightsActions .. "44,0;";	-- Свет:БК_Кровать off
        end
        
        if ( (lightLeft > 0) and (lightCenter > 0) and (lightRight > 0) )
        then
          lightsActions = lightsActions .. "42,0;";
        elseif ( (lightLeft > 0) and (lightCenter == 0) and (lightRight > 0) )
        then
--[[          lightsActions = lightsActions .. "42," .. tostring(lightLeft) .. ";43,0;";
        elseif ( (lightLeft > 0) and (lightCenter > 0) and (lightRight == 0) )
        then
          lightsActions = lightsActions .. "43," .. tostring(lightCenter) .. ";41,0;";
        elseif ( (lightLeft == 0) and (lightCenter > 0) and (lightRight > 0) )
        then
          lightsActions = lightsActions .. "41," .. tostring(lightCenter) .. ";43,0;";
--]]
          lightsActions = lightsActions .. "42," .. tostring(lightLeft) .. ";41,0;43,0;";
        elseif ( (lightLeft == 0) and (lightCenter > 0) and (lightRight == 0) )
        then
          lightsActions = lightsActions .. "41," .. tostring(lightCenter) .. ";41,0";
        elseif ( (lightLeft > 0) and (lightCenter == 0) and (lightRight == 0) )
        then
          lightsActions = lightsActions .. "43," .. tostring(lightLeft) .. ";41,0";
        elseif ( (lightLeft == 0) and (lightCenter == 0) and (lightRight > 0) )
        then
          if ( lightBed == 0 )
          then
            lightsActions = lightsActions .. "44,101;43,0";
          else
            lightsActions = lightsActions .. "41," .. tostring(lightRight) .. ";42," .. tostring(lightRight) .. ";";
          end
        else
          lightsActions = lightsActions .. "41,101;42,101;43,101;";
        end
        
      end
      
    end
    
    fibaro:setGlobal("lightsQueue", fibaro:getGlobalValue("lightsQueue")
      .. lightsActions);
    
  elseif ( triggerSceneActID == 15 ) 				-- > triple click
  then
    fibaro:call(196, "pressButton", "5"); 			-- vd.Свет:Кухня SWITCH
    
    local startTime = os.time();
    
    while ( (os.time() < startTime + 7)
    	and (fibaro:getGlobalValue("lightsQueue") ~= "") ) do
      fibaro:sleep(500);
    end
    
    if ( fibaro:getGlobalValue("lightsQueue") == "" )
    then
      fibaro:call(207, "pressButton", "5"); 		-- vd.Свет:Коридор SWITCH
    end
    --[[
    local lightsActions = "";
    
    if ( ((lightKitchen == 0) and (lightHall == 0))
    	or (fibaro:getValue(149, "dead") >= "1")
    	or (fibaro:getValue(150, "dead") >= "1")
    	or (fibaro:getValue(151, "dead") >= "1")
    	or (fibaro:getValue(4, "value") == "0")
      )
    then
      lightsActions = "151,50;150,101;149,101;"; --!!! need half+night
    else
      lightsActions = "149,0;150,0;151,0;";
    end
    
    --]]
  end
  
end
