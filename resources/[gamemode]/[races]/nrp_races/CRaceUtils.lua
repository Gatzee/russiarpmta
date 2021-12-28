
------------------------------------------------------
-- Отключение заданных клавиш
------------------------------------------------------

local disabled_keys = 
{ 
	p = true, 
	q = true, 
	tab = true,
	t = true,
}

local count_press_accelerate = 0
local last_accelerate_ticks = getTickCount()
local accelerate_keys = getBoundKeys( "forwards" )

function RaceKeyHandler( key, state )
	if disabled_keys[ key ] then
		cancelEvent()
	end

	local ticks = getTickCount()
	if CLIENT_is_drift_start and ticks < last_accelerate_ticks + 150 then
		for k, v in pairs( accelerate_keys ) do
			if k == key then
				last_accelerate_ticks = ticks
				count_press_accelerate = count_press_accelerate + 1
				if count_press_accelerate >= 5 then
					count_press_accelerate = 0
					CLIENT_EndDrift()
				end
				break
			end
		end
	else
		last_accelerate_ticks = ticks
		count_press_accelerate = 0
	end
end

------------------------------------------------------
-- Проверка корректности пути
------------------------------------------------------

local last_check_time = nil
function DetectWrongDirection()
	if isElementInWater( localPlayer.vehicle ) then
		triggerServerEvent( "RC:OnPlayerRequestLeaveLobby", resourceRoot, localPlayer, true, RACE_STATE_LOSE, "Машина уничтожена" )
		if isTimer( DETECT_WRONG_DIRECTION_TMR ) then killTimer( DETECT_WRONG_DIRECTION_TMR ) end
		return false
	end
	
	if pNextMarker and pNextMarker.temp then
		local inZone = true
		if RACE_DATA.race_type == RACE_TYPE_DRIFT then
			inZone = isElementWithinColShape( localPlayer, RACE_ZONE_COL )
		end

		local vec1 = pNextMarker.temp.position - localPlayer.vehicle.position
		local vec2 = localPlayer.vehicle.velocity.length ~= 0 and localPlayer.vehicle.velocity or localPlayer.vehicle.matrix.forward
		
		local divisor = ( vec1.length * vec2.length )
		local cosine = vec1:dot( vec2 ) / ( divisor ~= 0 and divisor or 1 )

		local angle = math.deg( math.acos( cosine ) )
		if angle >= 100 or not inZone then
			local timestamp = getRealTimestamp( )
			if not last_check_time then
				last_check_time = timestamp
			elseif last_check_time + 10 <= timestamp then
				triggerServerEvent( "RC:OnPlayerRequestLeaveLobby", resourceRoot, localPlayer, true, RACE_STATE_LOSE, "Нарушение правил гонки" )
				if isTimer( DETECT_WRONG_DIRECTION_TMR ) then killTimer( DETECT_WRONG_DIRECTION_TMR ) end
			elseif last_check_time + 1 <= timestamp then
				UpdateWrongSide( true )
			end
		elseif last_check_time then
			last_check_time = nil
			UpdateWrongSide( false )
		end
	end
end

function UpdateWrongSide( state )
	if state and not UI_elements.wrong_way then
		UI_elements.wrong_way = true

		UI_elements.last_update = UI_elements.last_update or 0
		local fMul = (getTickCount() - UI_elements.last_update) / 1000
		if fMul >= 1 then
			UI_elements.last_update = getTickCount()
			fMul = 1
		end

		UI_elements.wrong_side_text = ibCreateImage( 0, 0, 0, 0, "files/img/hud/wrong_side.png", nil, 0xFFD42D2D )
		UI_elements.wrong_way_img = ibCreateImage( 0, 120, 75, 75, "files/img/hud/wrong_way_icon.png", nil, 0xFFD42D2D )

		UI_elements.wrong_side_text
		:ibInterpolate( 
			function( self )
				if self.progress < 1 then
					self.element:ibBatchData({
						px = scX / 2 - 563 - 50 * self.easing_value,
						py = 100 - 4 * self.easing_value,
						sx = 1127 + 100 * self.easing_value,
						sy = 30 + 4 * self.easing_value,
					})
					local size_icon = 75 + 10 * self.easing_value
					UI_elements.wrong_way_img :ibBatchData({
						px = scX / 2 - size_icon / 2,
						py = 120 + size_icon / 2,
						sx = size_icon,
						sy = size_icon,
					})
					if self.progress >= 0.95 then
						self.progress = 0
						self.tick_start = getTickCount()
					end
				end
            end, 1000, "SineCurve" )

	elseif not state and UI_elements.wrong_way then
		UI_elements.wrong_way = false
		destroyElement( UI_elements.wrong_side_text )
		destroyElement( UI_elements.wrong_way_img )
	end
end

------------------------------------------------------
-- Отображение урона при столкновении
------------------------------------------------------

local damage_ui_index = 1
function CreateUIDamage_impl( angle )
	if isElement( UI_elements.damage[ damage_ui_index ] ) then
		destroyElement( UI_elements.damage[ damage_ui_index ] )
	end

	UI_elements.damage[ damage_ui_index ] = ibCreateImage( 0, 0, 212, 212, "files/img/hud/damage.png" )
	:center( )
	:ibData( "rotation", angle )
	:ibAlphaTo( 0, 1000 )
	:ibTimer( destroyElement, 1000, 1 )

	damage_ui_index = damage_ui_index % 10 + 1
end

function CreateUIDamage( center_pos, from_pos, rot )
	if not UI_elements.damage then
		UI_elements.damage = { }
	end

	local vec1 = Vector2( 0, 1 )
	local vec2 = ( Vector2( from_pos.x, from_pos.y ) - Vector2( center_pos.x, center_pos.y ) )
	if vec2.length == 0 then
		for i = 0, 4 do
			CreateUIDamage_impl( i * 90 )
		end
	else
		local angle = math.deg( math.acos( vec1:dot( vec2 ) / vec2.length ) )
		if vec2.x < 0 then angle = -angle end
		angle = angle - ( 360 - rot )

		CreateUIDamage_impl( angle )
	end
end

function DeleteUIDamage( )
	if not UI_elements.damage then return end
	for _, element in pairs( UI_elements.damage ) do
		if isElement( element ) then
			destroyElement( element )
		end
	end
end

function onClientVehicleDamage_handler( attacker, weapon_id, loss, dmgX, dmgY, dmgZ )
	CreateUIDamage( source.position,  Vector3( dmgX, dmgY, dmgZ ), source.rotation.z )
	if source.health < 400 then
		triggerServerEvent( "RC:OnPlayerRequestLeaveLobby", resourceRoot, localPlayer, true, RACE_STATE_LOSE, "Транспортное средство разбито" )
	end
end

------------------------------------------------------
-- Выход из зоны состязания
------------------------------------------------------
function CreateUIZoneExit( time )
	DeleteUIZoneExit( )

	UI_elements.zone_exit = ibCreateArea( 0, 0, 0, 0 ):center( 0, -110 )

	ibCreateLabel( 0, -40, 0, 0, "Вы будете исключены из состязания через:", UI_elements.zone_exit, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_24 )
		:ibData( "outline", 1 )

	local func_interpolate = function( self )
		self:ibInterpolate( function( self )
			if not isElement( self.element ) then return end
			self.easing_value = 1 + 0.2 * self.easing_value
			self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
		end, 350, "SineCurve" )
	end

	ibCreateLabel( 0, 0, 0, 0, time, UI_elements.zone_exit, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_36 )
	:ibData( "timestamp", getRealTimestamp() + time )
	:ibData( "outline", 1 )
	:ibTimer( func_interpolate, 100, 1 )
	:ibTimer( function( self )
		func_interpolate( self )
		local timestamp = self:ibData( "timestamp" )
		if timestamp then
			self:ibData( "text", timestamp - getRealTimestamp() )
		end
	end, 1000, 0 )
end

function DeleteUIZoneExit( )
	if isElement( UI_elements.zone_exit ) then
		destroyElement( UI_elements.zone_exit )
	end
end


------------------------------------------------------
-- Обратный отсчет, лимит времени гонки
------------------------------------------------------

function AddLimitTimeRace( time, callback )
	DestroyLimitTimeRace( )

	local function formatStr( time )
		local s = math.abs( time )
		local m = math.floor( s / 60 )
		local s = math.floor( s - m * 60 )

		return ( m > 0 and ( m .. " " .. plural( m, "минута", "минуты", "минут" ) .. " " ) or "" ) .. ( s > 0 and ( s .. " " .. plural( s, "секунда", "секунды", "секунд" ) ) or "" )
	end

	UI_elements.timeout = ibCreateArea( 0, 30, 0, 0 )

	local lbl_name = ibCreateLabel( 0, 0, 0, 0, "До конца состязания:", UI_elements.timeout, ibApplyAlpha( COLOR_WHITE, 80 ), _, _, "left", "center", ibFonts.bold_14 )
	:ibData( "outline", 1 )

	local lbl_time = ibCreateLabel( lbl_name:ibGetAfterX( 8 ), 0, 0, 0, formatStr( time ), UI_elements.timeout, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
	:ibData( "timestamp", getRealTimestamp() + time )
	:ibData( "outline", 1 )
	:ibTimer( function( self )
		local timestamp = self:ibData( "timestamp" )
		if timestamp then
			local diff = timestamp - getRealTimestamp()
			if diff <= 10 then
				if isElement( lbl_name ) then
					destroyElement( lbl_name )
					destroyElement( self )
					UI_elements.timeout:ibData( "sx", 0 )
					UI_elements.timeout:ibData( "10_sec_end_timer", true )
					UI_elements.timeout:center( 0, -100 )
					
					if RACE_DATA.race_type == RACE_TYPE_DRIFT then
						ibCreateLabel( 0, -15, 0, 0, "Быстрее!", UI_elements.timeout, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_24 )
						:ibData( "outline", 1 )
						
						ibCreateLabel( 0, 20, 0, 0, "10.00", UI_elements.timeout, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_36 )
						:ibData( "alpha", 150 )
						:ibData( "time_tick", time * 1000 )
						:ibData( "outline", 1 )
						:ibTimer( function( self )
							local sheeet, time_tick_count, tick_interval = getTimerDetails( sourceTimer )
							if time_tick_count then
								if time_tick_count <= 1 then
									callback()
									DestroyLimitTimeRace( )
								else
									local tick = time_tick_count * tick_interval
									local seconds = math.floor( tick / 1000 )
									local ms = math.floor( ( tick - seconds * 1000 ) / 10 )
									if ms < 10 then
										ms = "0"..ms
									end
									self:ibData( "text", seconds ..".".. ms )
								end
							end
						end, 50, 200 )
					end
				end
			else
				self:ibData( "text", formatStr( diff ) )
				UI_elements.timeout:ibData( "sx", self:ibGetAfterX( ) ):center_x( )
			end
		end
	end, 1000, 0 )
	UI_elements.timeout:ibData( "sx", lbl_time:ibGetAfterX( ) ):center_x( )
end

function DestroyLimitTimeRace( )
	if isElement( UI_elements.timeout ) then
		destroyElement( UI_elements.timeout )
	end
end

function CreateUIStartTimer( text, time_in_ms )
	local time_to_anim = time_in_ms + 500

	UI_elements.start_timer_bg = ibCreateArea( 0, 0, 0, 0 ):center( 0, -150 )

	local function CreateLabel( self, index )
		if not text[ index ] then return end

		ibCreateLabel( 300, 0, 0, 0, text[ index ], UI_elements.start_timer_bg, COLOR_WHITE, _, _, "center", "center", ibFonts.bold_20 )
		:ibData( "outline", 1 )
		:ibData( "alpha", 0 )
		:ibAlphaTo( 255, time_to_anim, "SineCurve" )
		:ibMoveTo( -300, 0, time_to_anim, "OutInQuad" )
		:ibTimer( CreateLabel, time_in_ms, 1, index + 1 )
		:ibTimer( destroyElement, time_to_anim, 1 )
	end

	CreateLabel( _, 1 )
end

------------------------------------------------------
-- Обратный отсчет при старте
------------------------------------------------------

-- Для квестов
MODES[ 256 ] = {
	countdown_text = { "3", "2", "1", "GO" },
}

local CONST_TIME_IN_MS_TO_TEXT_START = 1000
SEQUENCE_ACTIVE = false
function ShowStartSequence( race_type, callback )
	local text = MODES[ race_type ].countdown_text
	local time_to_anim = 500 + CONST_TIME_IN_MS_TO_TEXT_START

	UI_elements.start_timer_bg = ibCreateArea( 0, 0, 0, 0 ):center( 0, -280 )
	local function StartSequence( self, index )
		local sound
		if index < #text then
			sound = playSound( "files/sfx/timer_tick.wav" )
		elseif text[ index ] and index == #text then
			sound = playSound( "files/sfx/start.wav" )
			SEQUENCE_ACTIVE = false

			if RACE_DATA and next( RACE_DATA ) then
				toggleAllControls( true )
				toggleControl( "enter_exit", false )
				toggleControl( "change_camera", false )

				if RACE_DATA.race_type ~= RACE_TYPE_DRAG then
					setElementFrozen( localPlayer.vehicle, false )
				end	
				setElementFrozen( localPlayer, false )
				CreateNextMarker()
				if callback then
					callback()
				end
			end
		end
		if not text[ index ] then return end
		sound.volume = 0.35

		ibCreateLabel( 300, 0, 0, 0, text[ index ], UI_elements.start_timer_bg, COLOR_WHITE, _, _, "center", "center", ibFonts.bold_60 )
		:ibData( "outline", 1 )
		:ibData( "alpha", 0 )
		:ibAlphaTo( 255, time_to_anim, "SineCurve" )
		:ibMoveTo( -300, 0, time_to_anim, "OutInQuad" )
		:ibTimer( StartSequence, CONST_TIME_IN_MS_TO_TEXT_START, 1, index + 1 )
		:ibTimer( destroyElement, time_to_anim, 1 )
	end

	StartSequence( _, 1 )
end
addEvent( "ShowStartSequence", true )
addEventHandler( "ShowStartSequence", root, ShowStartSequence )