--[[
%% autostart
%% properties
2 Location
52 Location
155 Location
156 Location
%% globals
--]]

local UserID_admin = 2;
local UserID_mech = 52;
local UserID_Lena = 155;
local UserID_Lera = 156;

local HomeBLocation = "60.0264360221513;30.37832379341126";
					 --60.0263985012170;30.37820577621460
					 --60.0263663403822;30.37827014923096

local Distance = 300;

local admin_Distance = math.floor(fibaro:calculateDistance(fibaro:getValue(
      	UserID_admin, "Location"), HomeBLocation));
local mech_Distance = math.floor(fibaro:calculateDistance(fibaro:getValue(
      	UserID_mech, "Location"), HomeBLocation));
local Lena_Distance = math.floor(fibaro:calculateDistance(fibaro:getValue(
      	UserID_Lena, "Location"), HomeBLocation));
local Lera_Distance = math.floor(fibaro:calculateDistance(fibaro:getValue(
      	UserID_Lera, "Location"), HomeBLocation));

--[[
local admin_PrevDistance = math.floor(fibaro:calculateDistance(fibaro:getValue(UserID_admin, "PreviousLocation"), HomeBLocation));
local mech_PrevDistance = math.floor(fibaro:calculateDistance(fibaro:getValue(UserID_mech, "PreviousLocation"), HomeBLocation));
local Lena_PrevDistance = math.floor(fibaro:calculateDistance(fibaro:getValue(UserID_Lena, "PreviousLocation"), HomeBLocation));
local Lera_PrevDistance = math.floor(fibaro:calculateDistance(fibaro:getValue(UserID_Lera, "PreviousLocation"), HomeBLocation));
--]]

--[[
fibaro:debug("admin distance = " .. admin_Distance);
fibaro:debug("admin prev distance = " .. admin_PrevDistance);
fibaro:debug("mech distance = " .. mech_Distance);
fibaro:debug("mech prev distance = " .. mech_PrevDistance);
fibaro:debug("Lena distance = " .. Lena_Distance);
fibaro:debug("Lena prev distance = " .. Lena_PrevDistance);
fibaro:debug("Lera distance = " .. Lera_Distance);
fibaro:debug("Lera prev distance = " .. Lera_PrevDistance);
--]]

if (admin_Distance <= Distance) or (mech_Distance <= Distance)
then
  local mechInHomeB = fibaro:getGlobalValue("mechInHomeB");
  fibaro:setGlobal("mechInHomeB", "1");
  
  if ( mechInHomeB == "0" )
  then
    fibaro:debug("mech APPEARING IN HomeB (admin_dist = " .. tostring(admin_Distance)
  		.. ", mech_dist = " .. tostring(mech_Distance) .. ")");
    
    fibaro:call(184, "sendDefinedPushNotification", "187");
  end
elseif (admin_Distance > Distance) and (mech_Distance > Distance)
then
  local mechInHomeB = fibaro:getGlobalValue("mechInHomeB");
  fibaro:setGlobal("mechInHomeB", "0");
  
  if ( mechInHomeB == "1" )
  then
    fibaro:debug("mech LEAVING OUT HomeB (admin_dist = " .. tostring(admin_Distance)
  		.. ", mech_dist = " .. tostring(mech_Distance) .. ")");
    
    fibaro:call(184, "sendDefinedPushNotification", "190");
  end
end

if (admin_Distance < mech_Distance)
then
  fibaro:setGlobal("mech_distance", admin_Distance);
else
  fibaro:setGlobal("mech_distance", mech_Distance);
end

-----

if (Lena_Distance <= Distance)
then
  local LenaInHomeB = fibaro:getGlobalValue("LenaInHomeB");
  
  if LenaInHomeB == "0"
  then
    fibaro:debug("Lena APPEARING IN HomeB (dist = " .. tostring(Lena_Distance) .. ")");
    
    fibaro:setGlobal("LenaInHomeB", "1");
    fibaro:call(184, "sendDefinedPushNotification", "188");
  end
else
  local LenaInHomeB = fibaro:getGlobalValue("LenaInHomeB");
  fibaro:setGlobal("LenaInHomeB", "0");
  
  if LenaInHomeB == "1"
  then
    fibaro:debug("Lena LEAVING OUT HomeB (dist = " .. tostring(Lena_Distance) .. ")");
    
    fibaro:call(184, "sendDefinedPushNotification", "191");
  end
end

fibaro:setGlobal("Lena_distance", Lena_Distance);

-----

if (Lera_Distance <= Distance)
then
  local LeraInHomeB = fibaro:getGlobalValue("LeraInHomeB");
  fibaro:setGlobal("LeraInHomeB", "1");
  if ( LeraInHomeB == "0" )
  then
    fibaro:debug("Lera APPEARING IN HomeB (dist = " .. tostring(Lera_Distance) .. ")");
    
    fibaro:call(184, "sendDefinedPushNotification", "189");
  end
else
  local LeraInHomeB = fibaro:getGlobalValue("LeraInHomeB");
  fibaro:setGlobal("LeraInHomeB", "0");
  
  if ( LeraInHomeB == "1" )
  then
    fibaro:debug("Lera LEAVING OUT HomeB (dist = " .. tostring(Lera_Distance) .. ")");
    
    fibaro:call(184, "sendDefinedPushNotification", "192");
  end
end

fibaro:setGlobal("Lera_distance", Lera_Distance);

--[[
if (admin_Distance <= Distance) or (mech_Distance <= Distance)
then
  fibaro:setGlobal("mechInHomeB", "1");
  
  if (admin_Distance < mech_Distance)
  then
  	fibaro:setGlobal("mech_distance", admin_Distance);
  else
  	fibaro:setGlobal("mech_distance", mech_Distance);
  end
  
  fibaro:debug("mech IN HomeB (admin_dist = " .. tostring(admin_Distance)
  	.. ", mech_dist = " .. tostring(mech_Distance) .. ")");
  
  if (admin_PrevDistance > Distance) or (mech_PrevDistance > Distance)
  then
    -- appear
    fibaro:debug("mech APPEARING IN HomeB (admin_prev.dist = " .. tostring(admin_PrevDistance)
      .. ", mech_prev.dist = " .. tostring(mech_PrevDistance) .. ")");
    
    fibaro:call(184, "sendDefinedPushNotification", "187");
  end
end

if (admin_Distance > Distance) and (mech_Distance > Distance)
then
  fibaro:setGlobal("mechInHomeB", "0");
  
  if (admin_Distance < mech_Distance)
  then
  	fibaro:setGlobal("mech_distance", admin_Distance);
  else
  	fibaro:setGlobal("mech_distance", mech_Distance);
  end
  
  fibaro:debug("mech NOT IN HomeB (admin_dist = " .. tostring(admin_Distance)
  	.. ", mech_dist = " .. tostring(mech_Distance) .. ")");
  
  if (admin_PrevDistance <= Distance) or (mech_PrevDistance <= Distance)
  then
    -- leave
    fibaro:debug("mech LEAVING OUT HomeB (admin_prev.dist = " .. tostring(admin_PrevDistance)
      .. ", mech_prev.dist = " .. tostring(mech_PrevDistance) .. ")");
    
    fibaro:call(184, "sendDefinedPushNotification", "190");
  end
end

if (Lena_Distance <= Distance)
then
  fibaro:setGlobal("LenaInHomeB", "1");
  fibaro:setGlobal("Lena_distance", Lena_Distance);
  
  fibaro:debug("Lena IN HomeB (dist = " .. tostring(Lena_Distance) .. ")");
  
  if (Lena_PrevDistance > Distance)
  then
    -- appear
    fibaro:debug("Lena APPEARING IN HomeB (prev.dist = " .. Lena_PrevDistance .. ")");
    
    fibaro:call(184, "sendDefinedPushNotification", "188");
  end
end

if (Lena_Distance > Distance)
then
  fibaro:setGlobal("LenaInHomeB", "0");
  fibaro:setGlobal("Lena_distance", Lena_Distance);
  
  fibaro:debug("Lena NOT IN HomeB (dist = " .. tostring(Lena_Distance) .. ")");
  
  if (Lena_PrevDistance <= Distance)
  then
    -- leave
    fibaro:debug("Lena LEAVING OUT HomeB (prev.dist = " .. tostring(Lena_PrevDistance) .. ")");
    
    fibaro:call(184, "sendDefinedPushNotification", "191");
  end
end

if (Lera_Distance <= Distance)
then
  fibaro:setGlobal("LeraInHomeB", "1");
  fibaro:setGlobal("Lera_distance", Lera_Distance);
  
  fibaro:debug("Lera IN HomeB (dist = " .. tostring(Lera_Distance) .. ")");
  
  if (Lera_PrevDistance > Distance)
  then
    -- appear
    fibaro:debug("Lera APPEARING IN HomeB (prev.dist = " .. tostring(Lera_PrevDistance) .. ")");
    
    fibaro:call(184, "sendDefinedPushNotification", "189");
  end
end

if (Lera_Distance > Distance)
then
  fibaro:setGlobal("LeraInHomeB", "0");
  fibaro:setGlobal("Lera_distance", Lera_Distance);
  
  fibaro:debug("Lera NOT IN HomeB (dist = " .. tostring(Lera_Distance) .. ")");
  
  if (Lera_PrevDistance <= Distance)
  then
    -- leave
    fibaro:debug("Lera LEAVING OUT HomeB (prev.dist = " .. tostring(Lera_PrevDistance) .. ")");
    
    fibaro:call(184, "sendDefinedPushNotification", "192");
  end
end
--]]
