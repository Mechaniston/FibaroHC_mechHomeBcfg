--[[
%% properties
%% globals
nightMode
--]]


--[[
--if ( fibaro:getSourceTrigger()["type"] == "other" ) then
  if ( fibaro:getGlobalValue("nightMode") == "1" )
    fibaro:setGlobal("nightMode", "0");
  else
	fibaro:setGlobal("nightMode", "1");
  end
--end
--]]

if ( fibaro:getGlobalValue("nightMode") == "1" ) then
  
  --fibaro:call(195, "pressButton", "4");
  --fibaro:call(196, "pressButton", "3");
  
  --[[fibaro:call(60, "turnOff"); 	-- Кухня:Приборы(туалет), restart
  fibaro:sleep(3000);
  fibaro:call(60, "turnOn");--]]
  
  fibaro:call(173, "turnOff"); 		-- Коридор:ТеплПол-К_Х
  fibaro:call(175, "turnOff"); 		-- Коридор:ТеплПол-Т_В
  
  fibaro:call(177, "turnOff"); 		-- Лоджия

  if ( fibaro:getGlobalValue("nightMode_skipBR") ~= "1" ) then
    
	fibaro:call(210, "turnOff"); -- БК:СветДоп
    --fibaro:call(228, "turnOff"); -- БК:УпрРозетка
    fibaro:call(230, "turnOff"); -- БК:Бра
    
    --fibaro:call(40, "turnOff"); 	-- BRL_all
    fibaro:call(41, "turnOff");
    fibaro:call(42, "turnOff");
    fibaro:call(43, "turnOff");
    fibaro:call(44, "turnOff");
    
    --fibaro:call(189, "pressButton", "4"); 	-- БК:Жалюзи_ЗАКР
    
    local bedPlugValue = fibaro:getValue(15, "value");
    fibaro:call(15, "turnOff"); 	-- БК:РозеткиКровати
    local ventValue = fibaro:getValue(179, "value");
    fibaro:call(179, "turnOff"); 	-- БК:Вентиляция
    
    if ( (ventValue ~= "0") or (bedPlugValue ~= "0") ) then
      
      fibaro:debug("turn OFF BRvent or BRbedPlug");
      
      setTimeout(
        function()
          
          if ( ventValue ~= "0" ) then
            fibaro:call(179, "turnOn"); -- БК:Вентиляция
          end
          
          if ( (bedPlugValue ~= "0")
            and (fibaro:getValue(205, "value") == "1") ) then -- bed is down
            fibaro:call(15, "turnOn"); 	-- БК:РозеткиКровати
          end
          
          fibaro:debug("Turn back vent/BRbedPlug");
          
        end,
        2 * 60 * 60 * 1000); -- 2 hour
      
    end
    
  else
    fibaro:setGlobal("nightMode_skipBR", "0");
  end
  
  if ( fibaro:getGlobalValue("nightMode_skipSR") ~= "1" ) then
    
    --fibaro:call(260, "turnOff"); 	-- SRL_all
    fibaro:call(261, "turnOff");
    fibaro:call(262, "turnOff");
    
    fibaro:call(266, "turnOff"); 	-- МК:СветДоп
    
  else
    fibaro:setGlobal("nightMode_skipSR", "0");
  end
  
  fibaro:call(18, "turnOff"); 		-- БК:СветДекор
  
  --fibaro:call(148, "turnOff"); 		-- HKL_all
  fibaro:call(150, "turnOff");
  fibaro:call(149, "turnOff");
  fibaro:call(151, "turnOff");
  
  --[[
  fibaro:call(4, "turnOff"); -- Общее:ПитаниеСвета(Т)
  fibaro:call(6, "turnOff"); -- Общее:ПитаниеСвета_2(Т)
  fibaro:call(12, "turnOff"); -- Т_В:Вентиляция
  fibaro:call(17, "turnOff"); -- БК:РозеткиКровати_2
  --]]
  
else
  
  --fibaro:call(177, "turnOn");	-- Лоджия
  fibaro:call(60, "turnOn");	-- Кухня:Приборы(туалет)
  
end

fibaro:debug("nightMode = " .. fibaro:getGlobalValue("nightMode"));
