--[[
%% properties
%% globals
mechInHomeB
LenaInHomeB
LeraInHomeB
--]]

local startSource = fibaro:getSourceTrigger();
if (
 ( tonumber(fibaro:getGlobalValue("mechInHomeB")) == tonumber("0") )
and
 ( tonumber(fibaro:getGlobalValue("LenaInHomeB")) == tonumber("0") )
and
 ( tonumber(fibaro:getGlobalValue("LeraInHomeB")) == tonumber("0") )
and
 ( tonumber(fibaro:getGlobalValue("somebodyInHomeB")) == tonumber("0") )
) or ( startSource["type"] == "other" )
then
  
  fibaro:startScene("7"); -- allOff
  
end
