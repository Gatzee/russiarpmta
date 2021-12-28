Sun = {}

function Sun:create( )
	if self.created then return self end
	self.created = true

	self.x = 0
	self.y = 0
	self.z = 0
	self.size = 0
	self.lightDirX, self.lightDirY, self.lightDirZ = 0, 0, 0

	addEventHandler( "onClientPreRender", root, onClientPreRender_handler_sun )
	Sun.shineTimer = setTimer( updateSunInfo, 100, 0 )

	onClientRender_calcGameTime( )
	updateSunInfo( )
	updateSunVisibility( 0 )

	return self
end

function Sun:getSunPosition( )
	return self.x, self.y, self.z
end

function Sun:destroy( )
	if not self.created then return end
	self.created = false

	removeEventHandler( "onClientPreRender", root, onClientPreRender_handler_sun )
	killTimer( Sun.shineTimer )
end

function onClientPreRender_handler_sun( deltaTicks )
	updateSunVisibility( deltaTicks )
	onClientRender_calcGameTime( )
end

-----------------------------------------------------------------------------------
-- Light source visiblility detector
-----------------------------------------------------------------------------------
local dectectorPos = 1
local dectectorScore = 0
local detectorList = {
	{ x = -1, y = -1, status = 0 },
	{ x =  0, y = -1, status = 0 },
	{ x =  1, y = -1, status = 0 },

	{ x = -1, y =  0, status = 0 },
	{ x =  0, y =  0, status = 0 },
	{ x =  1, y =  0, status = 0 },

	{ x = -1, y =  1, status = 0 },
	{ x =  0, y =  1, status = 0 },
	{ x =  1, y =  1, status = 0 },
}

local function detectNext( )
	-- Step through detectorList - one item per call
	dectectorPos =( dectectorPos + 1 ) % #detectorList
	dectector = detectorList[dectectorPos+1]

	local lightDirX, lightDirY, lightDirZ
	
	if isDynamicSkyEnabled then
		local vecX, vecY, vecZ = exports.shader_dynamic_sky:getDynamicSunVector( )
		if vecZ < 0 then
			lightDirX, lightDirY, lightDirZ = vecX, vecY, vecZ
		else
			vecX, vecY, vecZ = exports.shader_dynamic_sky:getDynamicMoonVector( )
			if vecZ < 0 then
				lightDirX, lightDirY, lightDirZ = vecX, vecY, vecZ
			else
				lightDirX, lightDirY, lightDirZ = 0, 0, 1
			end
		end
	else
		lightDirX, lightDirY, lightDirZ = Sun.lightDirX, Sun.lightDirY, Sun.lightDirZ
	end
	
	local x, y, z = getCameraMatrix( )

	local endX = x - lightDirX * 500
	local endY = y - lightDirY * 500
	local endZ = z - lightDirZ * 500
	Sun.x, Sun.y, Sun.z = endX, endY, endZ

	endX = endX + dectector.x
	endY = endY + dectector.y

	if dectector.status == 1 then
		dectectorScore = dectectorScore - 1
	end

	dectector.status = isLineOfSightClear( x,y,z, endX, endY, endZ, true, false, false ) and 1 or 0

	if dectector.status == 1 then
		dectectorScore = dectectorScore + 1
	end

	-- Enable this to see the 'line of sight' checks
	-- if true then
	-- 	local color = tocolor( 255,255,0 )
	-- 	if dectector.status == 1 then
	-- 		color = tocolor( 255,0,255 )
	-- 	end
	-- 	dxDrawLine3D( x,y,z, endX, endY, endZ, color )
	-- end
end

local fadeTarget = 0
local fadeCurrent = 0
function updateSunVisibility( deltaTicks )
	detectNext( )

	if dectectorScore > 0 then
		fadeTarget = 1
	else
		fadeTarget = 0
	end

	local dif = fadeTarget - fadeCurrent
	local maxChange = deltaTicks / 1000
	dif = math.clamp( -maxChange,dif,maxChange )

	fadeCurrent = fadeCurrent + dif

	Sun.visible = fadeTarget == 0
	Sun.fadeCurrent = fadeCurrent
end

----------------------------------------------------------------
-- getTimeHMS
--		Returns game time including seconds
----------------------------------------------------------------
local timeHMS = {0,0,0}
local minuteStartTickCount
local minuteEndTickCount

local function getTimeHMS( )
	return unpack( timeHMS )
end

function onClientRender_calcGameTime( )
	local h, m = getTime( )
	local s = 0
	if m ~= timeHMS[2] then
		minuteStartTickCount = getTickCount( )
		local gameSpeed = math.clamp( 0.01, getGameSpeed( ), 10 )
		minuteEndTickCount = minuteStartTickCount + 1000 / gameSpeed
	end
	if minuteStartTickCount then
		local minFraction = math.unlerpclamped( minuteStartTickCount, getTickCount( ), minuteEndTickCount )
		s = math.min( 59, math.floor( minFraction * 60 ) )
	end
	timeHMS = {h, m, s}
end

----------------------------------------------------------------
-- getWeatherInfluence
----------------------------------------------------------------
local weatherInfluenceList = {
	-- id   sun:size   :translucency  :bright      night:bright 
	{  0,       1,			0,			1,			1 },		-- Hot, Sunny, Clear
	{  1,       0.8,		0,			1,			1 },		-- Sunny, Low Clouds
	{  2,       0.8,		0,			1,			1 },		-- Sunny, Clear
	{  3,       0.8,		0,			0.8,		1 },		-- Sunny, Cloudy
	{  4,       1,			0,			0.2,		0 },		-- Dark Clouds
	{  5,      1.5,			0,			0.5,		1 },		-- Sunny, More Low Clouds
	{  6,      1.5,			1,			0.5,		1 },		-- Sunny, Even More Low Clouds
	{  7,       1,			0,			0.01,		0 },		-- Cloudy Skies
	{  8,       1,			0,			0,			0 },		-- Thunderstorm
	{  9,       1,			0,			0,			0 },		-- Foggy
	{  10,      1,			0,			1,			1 },		-- Sunny, Cloudy ( 2 )
	{  11,     1.5,			0,			1,			1 },		-- Hot, Sunny, Clear ( 2 )
	{  12,     1.5,			1,			0.5,		0 },		-- White, Cloudy
	{  13,      1,			0,			0.8,		1 },		-- Sunny, Clear ( 2 )
	{  14,      1,			0,			0.7,		1 },		-- Sunny, Low Clouds ( 2 )
	{  15,      1,			0,			0.1,		0 },		-- Dark Clouds ( 2 )
	{  16,      1,			0,			0,			0 },		-- Thunderstorm ( 2 )
	{  17,     1.5,			1,			0.8,		1 }, 		-- Hot, Cloudy
	{  18,     1.5,			1,			0.8,		1 },		-- Hot, Cloudy ( 2 )
	{  19,      1,			0,			0,			0 },		-- Sandstorm
}

local function applyWeatherInfluence( sharpness, brightness, nightness )

	-- Get info from table
	local id = getWeather( )
	id = math.min( id, #weatherInfluenceList - 1 )
	local item = weatherInfluenceList[ id + 1 ]
	local sunSize  = item[2]
	local sunTranslucency = item[3]
	local sunBright = item[4]
	local nightBright = item[5]
	
	-- Modify depending on nightness
	local useSize		  = math.lerp( sunSize, nightness, 1 )
	local useTranslucency = math.lerp( sunTranslucency, nightness, 0 )
	local useBright		  = math.lerp( sunBright, nightness, nightBright )

	-- Apply
	brightness = brightness * useBright
	sharpness = sharpness / useSize

	-- Return result
	return sharpness, brightness
end

----------------------------------------------------------------
-- updateSunInfo
----------------------------------------------------------------
-- Big list describing light direction at a particular game time
local shineDirectionList = {
	-- H   M    Direction x, y, z,      			sharpness,	brightness,	nightness,	size
	{  5, 50,	-0.914400,	0.377530,	0.056093,	4,			0.5,		1,			0},			-- Sun fade in start
	{  6, 00,	-0.914400,	0.377530,	0.056093,	4,			0.5,		1,			0},			-- Sun fade in start
	{  6, 39,	-0.914400,	0.377530,	-0.126093,	4,			0.0,		0,			1},			-- Sun fade in end
	{  6, 40,	-0.914400,	0.377530,	-0.146093,	16,			0.0,		0,			1},			-- Sun
	{  6, 50,	-0.914400,	0.377530,	-0.146093,	16,			1.0,		0,			1},			-- Sun
	{  7,  0,	-0.891344,	0.377265,	-0.251386,	16,			1.0,		0,			1},			-- Sun
	{ 10,  0,	-0.678627,	0.405156,	-0.612628,	16,			0.5,		0,			1},			-- Sun
	{ 13,  0,	-0.303948,	0.490790,	-0.816542,	16,			0.5,		0,			1},			-- Sun
	{ 16,  0,	 0.169642,	0.707262,	-0.686296,	16,			0.5,		0,			1},			-- Sun
	{ 18,  0,	 0.380167,	0.893543,	-0.238859,	16,			0.5,		0,			1},			-- Sun
	{ 18, 30,	 0.398043,	0.911378,	-0.208859,	4,			1.0,		0,			1},			-- Sun
	{ 18, 53,	 0.360288,	0.932817,	-0.0,		1,			1.5,		0,			1},			-- Sun fade out start
	{ 19, 00,	 0.360288,	0.932817,	0.05,		1,			0.0,		0,			0},			-- Sun fade out end
	{ 19, 10,	 0.360288,	0.932817,	0.1,		1,			0.0,		0,			0},			-- Sun fade out end
}

function updateSunInfo( )
	if isDynamicSkyEnabled then return end
	-- Get game time
	local h, m, s = getTimeHMS( )
	local fhoursNow = h + m / 60 + s / 3600

	-- Find which two lines in the shineDirectionList to blend between
	for idx,v in ipairs( shineDirectionList ) do
		local fhoursTo = v[1] + v[2] / 60
		if fhoursNow <= fhoursTo then

			-- Work out blend from line
			local vFrom = shineDirectionList[ math.max( idx-1, 1 ) ]
			local fhoursFrom = vFrom[1] + vFrom[2] / 60

			-- Calc blend factor
			local f = math.unlerp( fhoursFrom, fhoursNow, fhoursTo )

			-- Calc final direction, sharpness and brightness
			local x = math.lerp( vFrom[3], f, v[3] )
			local y = math.lerp( vFrom[4], f, v[4] )
			local z = math.lerp( vFrom[5], f, v[5] )
			local sharpness  = math.lerp( vFrom[6], f, v[6] ) -- sSpecularPower
			local brightness = math.lerp( vFrom[7], f, v[7] ) -- sSpecularBrightness
			local nightness = math.lerp( vFrom[8], f, v[8] )

			-- Modify depending upon the weather
			Sun.sharpness, Sun.brightness = applyWeatherInfluence( sharpness, brightness, nightness )
			Sun.nightness = nightness

			Sun.lightDirX, Sun.lightDirY, Sun.lightDirZ = x, y, z
			Sun.size = math.lerp( vFrom[9], f, v[9] )

			break
		end
	end
end