--[[ ***** OPTIONS ***** ]]--

-- Devices ID's
local doorID = 29;
local lightID = 33;

-- Light actuator type
local lightIsRGBW = 1;
local lightRGBWChannel = 2; -- RGBW <=> 1234

-- Debug mode
local debug = true;


--[[ ***** ROUTINES ***** ]]--

function split(s, pattern, maxsplit)
  
  local pattern = pattern or ' ';
  local maxsplit = maxsplit or -1;
  local s = s;
  local t = {};
  local patsz = #pattern;
  
  while maxsplit ~= 0 do
    local curpos = 1;
    local found = string.find(s, pattern);
	
    if found ~= nil then
      table.insert(t, string.sub(s, curpos, found - 1));
      curpos = found + patsz;
      s = string.sub(s, curpos);
    else
      table.insert(t, string.sub(s, curpos));
      break;
	
    end
    maxsplit = maxsplit - 1;
	
    if maxsplit == 0 then
      table.insert(t, string.sub(s, curpos - patsz)); -- -1 ?
    end
  end
  
  return t;
  
end

function setRGBW(RGBWChannel, value)
  
  if RGBWChannel == 1 then
    fibaro:call(lightID, "SetR", value);
  elseif RGBWChannel == 2 then
    fibaro:call(lightID, "SetG", value);
  elseif RGBWChannel == 3 then
    fibaro:call(lightID, "SetB", value);
  elseif RGBWChannel == 4 then
    fibaro:call(lightID, "SetW", value);
  end
  
end


--[[ ***** GETTING ENVIROMENT ***** ]]--

if lightIsRGBW == 1 then

	local lightColors = split(fibaro:getValue(id_master, "color"), ','); -- 4th params: ', lightRGBWChannel'
	
	if debug then fibaro:debug("RGBW light colors: "..lightColors[1]..","..lightColors[2]..","..lightColors[3]..","..lightColors[4]); end
	
	if tonumber(lightColors[lightRGBWChannel]) > 0 then
		light = '1';
	else
		light = '0';
	end
	
else
	local light = fibaro:getValue(lightID, 'value');
end

if light == '1' then
  setRGBW(lightRGBWChannel, 0);
else
  setRGBW(lightRGBWChannel, 255);
end
