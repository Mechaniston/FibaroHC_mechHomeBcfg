--[[
%% properties
%% globals
--]]


fibaro:call(15, "turnOff"); -- БК:РозеткиКровати
--fibaro:call(17, "turnOff");
fibaro:call(40, "turnOff"); -- БК:Свет_общ
fibaro:call(169, "turnOff"); -- БК:СветДек_п.п
--fibaro:call(177, "turnOff"); -- БК:Лоджия
fibaro:call(179, "turnOff"); -- БК:Вентиляция
fibaro:call(210, "turnOff"); -- БК:СветДоп
fibaro:call(228, "turnOff"); -- БК:УпрРозетка
fibaro:call(230, "turnOff"); -- БК:Бра

fibaro:call(260, "turnOff"); -- МК:Свет
fibaro:call(265, "turnOff"); -- МК:Свет_доп

fibaro:call(60, "turnOff"); -- Х:Приборы(Т)

fibaro:call(34, "turnOff"); -- Т_В:Свет_общ
fibaro:call(148, "turnOff"); -- К_Х:Свет_общ
fibaro:call(171, "turnOff"); -- Х:СветДек_п.п
fibaro:call(173, "turnOff"); -- К_Х:ТёплыйПол
fibaro:call(175, "turnOff"); -- Т_В:ТёплыйПол

fibaro:call(18, "turnOff"); -- Общее:СветДек(БК)
fibaro:call(4, "turnOff"); -- Общее:ПитаниеСвета(Т)
fibaro:call(6, "turnOff"); -- Общее:ПитаниеСвета_2(Т)
