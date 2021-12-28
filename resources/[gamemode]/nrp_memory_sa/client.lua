loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "Globals" )
Extend( "CPlayer" )

ibUseRealFonts( true )

CONST_MEMORY_FIRST_CHECK_DELAY = 60 * 1000
CONST_MEMORY_POLL_RATE = 15 * 1000
CONST_MEMORY_DELAY_AFTER_CLEAN = 1 * 1000
CONST_MEMORY_CLEANUP_TIME = 10

CONST_MEMORY_LIMIT = 3.35 * 1024 * 1024 * 1024;
CONST_MEMORY_CRITICAL_LIMIT = 3.45 * 1024 * 1024 * 1024;

CONST_MEMORY_COUNT_SCAMP_CLEANUP_TO_FAILED = 3

MEMORY_START_CLEANUP = false
MEMORY_CLEANUP_FAILED = false
MEMORY_COUNT_SCAMP_CLEANUP = 0

STREAM_DISTANCE_STEP = 0.1
STREAM_DISTANCE_MAX = 1
STREAM_DISTANCE_MIN = 0.5
STREAM_DISTANCE = 1
engineRestreamWorld ( )

draw = false

IGNORED_MODELS = {
	0, 1,

	-- Ворота, двери, гаражи и вилла
	1264,17288,17303, 17297, 17292, 17294, 17298, 17302, 17304, 17301, 17295, 17296, 17293, 17299, 10856, 17291, 6282, 7288, 17289, 17286, 17287, 17285, 
	
	-- Интерьер тюнинга
	17629, 17630, 17631,

	-- Ивенты для банд итд
	2991, 3015, 3134, 2974, 2934, 2935, 2932, 3066, 2973, 2975, 2912,

	-- КБ
	3066, 2973, 3052, 2934, 2935,

	-- Закладки банд
	3052, 2977, 2973,

	-- Колёса автомобилей (работа)
	1079, 1085, 1074, 1076, 1084, 1097, 1075, 1096, 1083, 1098, 1078, 1082, 1077,

	-- Фермерские объекты
	627, 630, 628, 635, 633, 632, 631,
}

UI = nil
UI_TEXT = nil

--setClientDrawDistance( STREAM_DISTANCE )

function RemoveAllLoadedModelsFromMemory( )
	if localPlayer:GetBlockCleanupMemory() then return end

	local loaded_models = getLoadedModelsInMemory( )

	local players_in_range = getElementsWithinRange( localPlayer.position, 50, "player" )
	for _, player in pairs( players_in_range ) do
		loaded_models[ player.model ] = nil
	end

	local vehicles_in_range = getElementsWithinRange( localPlayer.position, 50, "vehicle" )
	for _, vehicle in pairs( vehicles_in_range ) do
		loaded_models[ vehicle.model ] = nil
	end

	for i, v in pairs( IGNORED_MODELS ) do
		loaded_models[ v ] = nil
	end

	for model in pairs( loaded_models ) do
		removeModelFromMemory( model, true )
	end
end

function CheckMemory( )
	if MEMORY_START_CLEANUP then return end

	if MEMORY_CLEANUP_FAILED then
		MEMORY_START_CLEANUP = true
		return
	end

	--[[if MEMORY_CLEANUP_FAILED then
		MEMORY_START_CLEANUP = true
		--setClientDrawDistance( STREAM_DISTANCE_MIN )
		CreateBoxErrorMemory( )
		return
	end]]

	--local mem_usage = getClientMemoryInfo( ) or 0
	local mem_usage = 10100000000
	if mem_usage then
		if CONST_MEMORY_LIMIT >= CONST_MEMORY_LIMIT then
			MEMORY_START_CLEANUP = CONST_MEMORY_CLEANUP_TIME

draw = true
			CreateBoxInfoMemory( )

			setTimer( function( )
				if type( MEMORY_START_CLEANUP ) ~= "number" then return end

				MEMORY_START_CLEANUP = MEMORY_START_CLEANUP - 1

			--	local mem_usage = getClientMemoryInfo( ) or 0
			local mem_usage = 101
				--if MEMORY_START_CLEANUP == 0 or CONST_MEMORY_LIMIT >= CONST_MEMORY_CRITICAL_LIMIT then
				if MEMORY_START_CLEANUP == 0  then
					if isElement( UI ) then
						UI:ibAlphaTo( 0, 500 )
						setTimer( function( )
							if isElement( UI ) then
								destroyElement( UI )
								draw = false
								localPlayer:setData( "memory_cleanup_ui_active", false, false )
								onClientHideMemoryBox_handler()
							end
							MEMORY_START_CLEANUP = false
						end, 600, 1 )
					end

					MEMORY_START_CLEANUP = nil
					engineRestreamWorld ( )

					STREAM_DISTANCE = math.max( STREAM_DISTANCE_MIN, STREAM_DISTANCE - STREAM_DISTANCE_STEP )
					--setClientDrawDistance( STREAM_DISTANCE )

					MEMORY_COUNT_SCAMP_CLEANUP = MEMORY_COUNT_SCAMP_CLEANUP + 1

					if MEMORY_COUNT_SCAMP_CLEANUP == CONST_MEMORY_COUNT_SCAMP_CLEANUP_TO_FAILED then
						MEMORY_CLEANUP_FAILED = true
					end
				else
					if isElement( UI_TEXT ) then
						UI_TEXT:ibData( "text", MEMORY_START_CLEANUP .." секунд..." )
					end
				end
			end, 1000, MEMORY_START_CLEANUP )

			killTimer( sourceTimer )
			setTimer( CheckMemory, CONST_MEMORY_DELAY_AFTER_CLEAN, 0 )
			--setTimer(function()
              --  MEMORY_START_CLEANUP = nil;
           -- end, 10000, 0)
		else
			MEMORY_COUNT_SCAMP_CLEANUP = 0
		end
	end
end

function StartMemoryTimer( )
	--local launcher_data = getLauncherData( )
--	local major_version = launcher_data and launcher_data.major_version or 0
--	local minor_version = launcher_data and launcher_data.minor_version or 0

--	if major_version > 3 or ( major_version == 3 and minor_version >= 2 ) then
		setTimer( CheckMemory, CONST_MEMORY_POLL_RATE, 0 )
	--end
end
setTimer( StartMemoryTimer, CONST_MEMORY_FIRST_CHECK_DELAY, 1 )

addCommandHandler( "cleanup_memory", function( )
	if localPlayer:GetAccessLevel( ) < ACCESS_LEVEL_DEVELOPER then return end
	engineRestreamWorld ( )
end )

function CreateBoxInfoMemory( )
	if draw == false then return end
	if isElement( UI ) then
		destroyElement( UI )
	end
	if localPlayer:getData( "photo_mode" ) then return end

	local x = guiGetScreenSize( )

	local sx, sy = 500, 61
	local px, py = math.floor( ( x - 500 ) / 2 ), 20
	UI = ibCreateImage( px, 0, sx, sy, "images/warning_bg.png" ):ibData( "alpha", 0 ):ibMoveTo( px, py, 200 ):ibAlphaTo( 255, 200 )
	UI_TEXT = ibCreateLabel( 226, 38, 0, 0, CONST_MEMORY_CLEANUP_TIME .." секунд...", UI, 0xFFFFFFFF, 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_16 )

	localPlayer:setData( "memory_cleanup_ui_active", true, false )
end



function onClientHideMemoryBox_handler()
	if isElement( UI ) then
		destroyElement( UI )
	end
end
addEvent( "onClientHideMemoryBox", true )
addEventHandler( "onClientHideMemoryBox", root, onClientHideMemoryBox_handler )