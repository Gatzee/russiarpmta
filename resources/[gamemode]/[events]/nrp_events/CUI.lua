Extend("ib")
Extend("ShUtils")
Extend("ShVehicleConfig")
Extend("CUI")

ibUseRealFonts( true )

UIe = { }
ui_warning_way = { }

function CreateUIStartTimer( text, time_in_ms, font )
	local time_to_anim = time_in_ms + 500

	UIe.start_timer_bg = ibCreateArea( 0, 0, 0, 0 ):center( 0, -150 )

	local function CreateLabel( self, index )
		if not text[ index ] then return end

		ibCreateLabel( 300, 0, 0, 0, text[ index ], UIe.start_timer_bg, COLOR_WHITE, _, _, "center", "center", font or ibFonts.bold_20 )
			:ibData( "outline", 1 )
			:ibData( "alpha", 0 )
			:ibAlphaTo( 255, time_to_anim, "SineCurve" )
			:ibMoveTo( -300, 0, time_to_anim, "OutInQuad" )
			:ibTimer( CreateLabel, time_in_ms, 1, index + 1 )
			:ibTimer( destroyElement, time_to_anim, 1 )
	end

	CreateLabel( _, 1 )
end

function ShowWarningWay( state )
	if state and not ui_warning_way.wrong_way then
		ui_warning_way.wrong_way = true

		ui_warning_way.last_update = ui_warning_way.last_update or 0
		local fMul = ( getTickCount( ) - ui_warning_way.last_update ) / 1000
		if fMul >= 1 then
			ui_warning_way.last_update = getTickCount( )
			fMul = 1
		end

		ui_warning_way.wrong_side_text = ibCreateImage( 0, 0, 0, 0, "img/wrong_side.png", nil, 0xFFD42D2D )
		ui_warning_way.wrong_way_img = ibCreateImage( 0, 120, 75, 75, "img/wrong_way.png", nil, 0xFFD42D2D )

		ui_warning_way.wrong_side_text
		:ibInterpolate( 
			function( self )
				if self.progress < 1 then
					self.element:ibBatchData({
						px = _SCREEN_Y / 2 - 563 - 50 * self.easing_value,
						py = 100 - 4 * self.easing_value,
						sx = 1127 + 100 * self.easing_value,
						sy = 30 + 4 * self.easing_value,
					}):center_x( )
					local size_icon = 75 + 10 * self.easing_value
					ui_warning_way.wrong_way_img :ibBatchData({
						px = _SCREEN_Y / 2 - size_icon / 2,
						py = 120 + size_icon / 2,
						sx = size_icon,
						sy = size_icon,
					}):center_x( )
					if self.progress >= 0.95 then
						self.progress = 0
						self.tick_start = getTickCount()
					end
				end
            end, 1000, "SineCurve" )

	elseif not state and ui_warning_way.wrong_way then
		ui_warning_way.wrong_way = false
		destroyElement( ui_warning_way.wrong_side_text )
		destroyElement( ui_warning_way.wrong_way_img )
	end
end

function CreateScoreboard( text_point, players, count_markers )
	if isElement( UIe.scoreboard ) then
		destroyElement( UIe.scoreboard )
	end

	local players_data = { }
	for player in pairs( players ) do
		table.insert( players_data, {
			player = player;
			points = 0;
			points_all = count_markers;
		} )
	end

	UIe.scoreboard = ibCreateArea( 20, 97, 0, 0 ):ibData( "players_data", players_data ):ibData( "text_point", text_point or "" )
	UIe.scoreboard_items = { }

	for i, info in ipairs( players_data ) do
		CreateScoreboardItem( i, info, text_point )
	end
end

function CreateScoreboardItem( i, info, text_point, pos_y )
	if isElement( UIe.scoreboard_items[ info.player ] ) then
		destroyElement( UIe.scoreboard_items[ info.player ] )
	end

	UIe.scoreboard_items[ info.player ] = ibCreateImage( 0, pos_y or 51 * ( i - 1 ), 248, 50, "img/scoreboard_item_bg.png", UIe.scoreboard )
	local bg = UIe.scoreboard_items[ info.player ]

	ibCreateLabel( 20, 0, 0, 0, i, bg, 0xFFff965d, 1, 1, "center", "center" )
		:ibData( "font", ibFonts.bold_24 )
		:center_y( )

	local lbl_name = ibCreateLabel( 81, 16, 0, 0, info.player:GetNickName( ), bg, COLOR_WHITE, 1, 1, "left", "center" )
		:ibData( "font", ibFonts.regular_12 )

	if info.player == localPlayer then
		ibCreateImage( lbl_name:ibGetAfterX( 8 ), 9, 13, 13, "img/user_icon.png", bg )
	end

	if UIe.scoreboard:ibData( "text_point" ) == "" then return end
	local lbl = ibCreateLabel( 49, 34, 0, 0, text_point, bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center" )
		:ibData( "font", ibFonts.regular_12 )

	ibCreateLabel( lbl:ibGetAfterX( 8 ), 34, 0, 0, info.points .. ( info.points_all and "/" .. info.points_all or "" ), bg, COLOR_WHITE, 1, 1, "left", "center" )
		:ibData( "font", ibFonts.bold_14 )
end

function UpdateScoreboard( player, points, place )
	if not isElement( UIe.scoreboard ) then
		return
	end

	local players_data = UIe.scoreboard:ibData( "players_data" )
	local player_data

	for i, info in ipairs( players_data ) do
		if info.player == player then
			if place or not points then
				player_data = info
				table.remove( players_data, i )
			end

			if points then
				info.points = points
			else				
				if isElement( UIe.scoreboard_items[ player ] ) then
					destroyElement( UIe.scoreboard_items[ player ] )
				end
			end

			break
		end
	end

	if place then
		table.insert( players_data, place, player_data )
	else
		table.sort( players_data, function( a, b )
			return a.points > b.points
		end )
	end

	UIe.scoreboard:ibData( "players_data", players_data )

	for i, info in ipairs( players_data ) do
		CreateScoreboardItem( i, info, UIe.scoreboard:ibData( "text_point" ), UIe.scoreboard_items[ info.player ]:ibData( "py" ) )
		UIe.scoreboard_items[ info.player ]:ibMoveTo( 0, 51 * ( i - 1 ), 500 )
	end
end


function CreateUITimeout( time, drift_special )
	DestroyUITimeout( )

	local function formatStr( time )
		local s = math.abs( time )
		local m = math.floor( s / 60 )
		local s = math.floor( s - m * 60 )

		return ( m > 0 and ( m .. " " .. plural( m, "минута", "минуты", "минут" ) .. " " ) or "" ) .. ( s > 0 and ( s .. " " .. plural( s, "секунда", "секунды", "секунд" ) ) or "" )
	end


	UIe.timeout = ibCreateArea( 0, 30, 0, 0 )

	local lbl_name = ibCreateLabel( 0, 0, 0, 0, "До конца состязания:", UIe.timeout, ibApplyAlpha( COLOR_WHITE, 80 ), _, _, "left", "center", ibFonts.bold_14 )
		:ibData( "outline", 1 )

	local lbl_time = ibCreateLabel( lbl_name:ibGetAfterX( 8 ), 0, 0, 0, formatStr( time ), UIe.timeout, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
		:ibData( "timestamp", getRealTime( ).timestamp + time )
		:ibData( "outline", 1 )
		:ibTimer( function( self )
			local timestamp = self:ibData( "timestamp" )
			if timestamp then
				local diff = timestamp - getRealTime( ).timestamp
				if diff <= 10 then
					if isElement( lbl_name ) then
						destroyElement( lbl_name )
						destroyElement( self )

						DeleteUIRespawnTimer( )

						UIe.timeout:ibData( "sx", 0 )
						UIe.timeout:ibData( "10_sec_end_timer", true )
						UIe.timeout:center( 0, -100 )

						if drift_special then
							ibCreateLabel( 0, -15, 0, 0, "Быстрее!", UIe.timeout, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_24 )
								:ibData( "outline", 1 )

							ibCreateLabel( 0, 20, 0, 0, "10.00", UIe.timeout, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_36 )
								:ibData( "alpha", 150 )
								:ibData( "time_tick", time * 1000 )
								:ibData( "outline", 1 )
								:ibTimer( function( self )
									local sheeet, time_tick_count, tick_interval = getTimerDetails( sourceTimer )
									if time_tick_count then
										if time_tick_count <= 1 then
											DestroyUITimeout( )
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
						else
							ibCreateLabel( 0, -10, 0, 0, "До конца состязания", UIe.timeout, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_24 )
								:ibData( "outline", 1 )

							local func_interpolate = function( self )
								self:ibInterpolate( function( self )
									if not isElement( self.element ) then return end
									self.easing_value = 1 + 0.2 * self.easing_value
									self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
								end, 350, "SineCurve" )
							end

							time = 10
							ibCreateLabel( 0, 20, 0, 0, time, UIe.timeout, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_36 )
								:ibData( "timestamp", getRealTime( ).timestamp + time )
								:ibData( "outline", 1 )
								:ibTimer( func_interpolate, 100, 1 )
								:ibTimer( function( self )
									func_interpolate( self )
									local timestamp = self:ibData( "timestamp" )
									if timestamp then
										local diff = timestamp - getRealTime( ).timestamp
										if diff <= 0 then
											DestroyUITimeout( )
										else
											self:ibData( "text", diff )
										end
									end
								end, 1000, 0 )
						end
					end
				else
					self:ibData( "text", formatStr( diff ) )
					UIe.timeout:ibData( "sx", self:ibGetAfterX( ) ):center_x( )
				end
			end
		end, 1000, 0 )

	UIe.timeout:ibData( "sx", lbl_time:ibGetAfterX( ) ):center_x( )
end

function DestroyUITimeout( )
	if isElement( UIe.timeout ) then
		destroyElement( UIe.timeout )
	end
end


function CreateUIZoneExit( time )
	DeleteUIZoneExit( )

	UIe.zone_exit = ibCreateArea( 0, 0, 0, 0 ):center( 0, -110 )

	ibCreateLabel( 0, -40, 0, 0, "Вы будете исключены из состязания через:", UIe.zone_exit, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_24 )
		:ibData( "outline", 1 )

	local func_interpolate = function( self )
		self:ibInterpolate( function( self )
			if not isElement( self.element ) then return end
			self.easing_value = 1 + 0.2 * self.easing_value
			self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
		end, 350, "SineCurve" )
	end

	ibCreateLabel( 0, 0, 0, 0, time, UIe.zone_exit, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_36 )
		:ibData( "timestamp", getRealTime( ).timestamp + time )
		:ibData( "outline", 1 )
		:ibTimer( func_interpolate, 100, 1 )
		:ibTimer( function( self )
			func_interpolate( self )
			local timestamp = self:ibData( "timestamp" )
			if timestamp then
				self:ibData( "text", timestamp - getRealTime( ).timestamp )
			end
		end, 1000, 0 )
end

function DeleteUIZoneExit( )
	if isElement( UIe.zone_exit ) then
		destroyElement( UIe.zone_exit )
	end
end


function CreateUIRespawnTimer( time )
	if isElement( UIe.timeout ) and UIe.timeout:ibData( "10_sec_end_timer" ) then return end

	DeleteUIRespawnTimer( )

	UIe.respawn_timer = ibCreateArea( 0, 0, 0, 0 ):center( 0, -110 )

	ibCreateLabel( 0, -40, 0, 0, "Возрождение через:", UIe.respawn_timer, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_24 )
		:ibData( "outline", 1 )

	local func_interpolate = function( self )
		self:ibInterpolate( function( self )
			if not isElement( self.element ) then return end
			self.easing_value = 1 + 0.2 * self.easing_value
			self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
		end, 350, "SineCurve" )
	end

	ibCreateLabel( 0, 0, 0, 0, time, UIe.respawn_timer, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_36 )
		:ibData( "timestamp", getRealTime( ).timestamp + time )
		:ibData( "outline", 1 )
		:ibTimer( func_interpolate, 100, 1 )
		:ibTimer( function( self )
			func_interpolate( self )
			local timestamp = self:ibData( "timestamp" )
			if timestamp then
				self:ibData( "text", timestamp - getRealTime( ).timestamp )
			end
		end, 1000, 0 )
end

function DeleteUIRespawnTimer( )
	if isElement( UIe.respawn_timer ) then
		destroyElement( UIe.respawn_timer )
	end
end


function CreateUIWeapon( minigun_ammo, rocket_ammo )
	DeleteUIWeapon( )

	UIe.weapon_bg = ibCreateArea( _SCREEN_X - 197, _SCREEN_Y - 363, 167, 70 )

	UIe.minigun_bg = ibCreateImage( 0, 0, 82, 70, "img/minigun_bg.png", UIe.weapon_bg )
	UIe.minigun_ammo = ibCreateLabel( 70, 9, 0, 0, minigun_ammo, UIe.minigun_bg, COLOR_WHITE, 1, 1, "center", "center" )
		:ibData( "font", ibFonts.bold_14 )
		:ibData( "outline", true )

	UIe.rocket_bg = ibCreateImage( 85, 0, 77, 70, "img/rocket_bg.png", UIe.weapon_bg )
	UIe.rocket_ammo = ibCreateLabel( 65, 9, 0, 0, rocket_ammo, UIe.rocket_bg, COLOR_WHITE, 1, 1, "center", "center" )
			:ibData( "font", ibFonts.bold_14 )
			:ibData( "outline", true )
end

function UpdateUIWeapon( minigun_ammo, rocket_ammo, minigun_timeout, rocket_timeout )
	if not isElement( UIe.weapon_bg ) then return end

	if minigun_ammo then
		UIe.minigun_ammo:ibData( "text", minigun_ammo )
	end

	if rocket_ammo then
		UIe.rocket_ammo:ibData( "text", rocket_ammo )
	end

	if minigun_timeout then
		if isElement( UIe.minigun_timeout ) then
			destroyElement( UIe.minigun_timeout )
		end

		UIe.minigun_bg:ibData( "color", ibApplyAlpha( COLOR_WHITE, 40 ) )
		UIe.minigun_ammo:ibData( "color", ibApplyAlpha( COLOR_WHITE, 40 ) )
		UIe.minigun_timeout = ibCreateLabel( 0, 0, 0, 0, minigun_timeout, UIe.minigun_bg, COLOR_WHITE, 1, 1, "center", "center" )
			:center( )
			:ibData( "font", ibFonts.bold_18 )
			:ibData( "outline", true )
			:ibTimer( function( self )
				local count = tonumber( self:ibData( "text" ) ) - 1
				if count > 0 then
					self:ibData( "text", count )
				else
					destroyElement( self )
					UIe.minigun_bg:ibData( "color", COLOR_WHITE )
					UIe.minigun_ammo:ibData( "color", COLOR_WHITE )
				end
			end, 1000, 0 )
	end

	if rocket_timeout then
		if isElement( UIe.rocket_timeout ) then
			destroyElement( UIe.rocket_timeout )
		end

		UIe.rocket_bg:ibData( "color", ibApplyAlpha( COLOR_WHITE, 40 ) )
		UIe.rocket_ammo:ibData( "color", ibApplyAlpha( COLOR_WHITE, 40 ) )
		UIe.rocket_timeout = ibCreateLabel( 0, 0, 0, 0, rocket_timeout, UIe.rocket_bg, COLOR_WHITE, 1, 1, "center", "center" )
			:center( )
			:ibData( "font", ibFonts.bold_18 )
			:ibData( "outline", true )
			:ibTimer( function( self )
				local count = tonumber( self:ibData( "text" ) ) - 1
				if count > 0 then
					self:ibData( "text", count )
				else
					destroyElement( self )
					UIe.rocket_bg:ibData( "color", COLOR_WHITE )
					UIe.rocket_ammo:ibData( "color", COLOR_WHITE )
				end
			end, 1000, 0 )
	end
end

function DeleteUIWeapon( )
	if isElement( UIe.weapon_bg ) then
		destroyElement( UIe.weapon_bg )
	end
end



local damage_ui_index = 1

local function CreateUIDamage_impl( angle )
	if isElement( UIe.damage[ damage_ui_index ] ) then
		destroyElement( UIe.damage[ damage_ui_index ] )
	end

	UIe.damage[ damage_ui_index ] = ibCreateImage( 0, 0, 212, 212, "img/damage.png" )
		:center( )
		:ibData( "rotation", angle )
		:ibAlphaTo( 0, 1000 )
		:ibTimer( destroyElement, 1000, 1 )

	damage_ui_index = damage_ui_index % 10 + 1
end

function CreateUIDamage( center_pos, from_pos, rot )
	if not UIe.damage then
		UIe.damage = { }
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
	if not UIe.damage then return end

	for _, element in pairs( UIe.damage ) do
		if isElement( element ) then
			destroyElement( element )
		end
	end
end


local rainbowSteps = {
	{1,	0,		0},
	{1,	1,	0},
	{0,		1,	0},
	{0,		1,	1},
	{0,		0,		1},
	{1,	0,		1},
}
local currentStep = 1
local start, tick = getTickCount(), false
local timeStep = 1000

function calculateRGB()
	tick = getTickCount()

	if (tick - start) >= timeStep then
		currentStep = currentStep + 1
		if currentStep > #rainbowSteps then
			currentStep = 1
		end
		start = tick
		return calculateRGB()
	else
		local lastStep = currentStep - 1
		if currentStep == 1 then
			lastStep = #rainbowSteps
		end
		local progress = (tick - start) / timeStep
		progress = math.max(0, math.min(1, progress))
		return interpolateBetween(rainbowSteps[lastStep][1], rainbowSteps[lastStep][2], rainbowSteps[lastStep][3], rainbowSteps[currentStep][1], rainbowSteps[currentStep][2], rainbowSteps[currentStep][3], progress, 'Linear')
	end
end


function CreateUIDrift( max_mul )
	if isElement( UIe.weapon_bg ) then
		destroyElement( UIe.weapon_bg )
	end

	UIe.drift_bg = ibCreateArea( 0, 100, 0, 0 ):center_x( )

	UIe.drift_points_mul_bg = ibCreateImage( 0, 0, 72, 72, "img/drift_bg.png", UIe.drift_bg ):center( )

	UIe.drift_points_mul = { }
	for i = 1, max_mul do
		UIe.drift_points_mul[ i ] = ibCreateImage( 0, 0, 72, 72, "img/drift_mul.png", UIe.drift_points_mul_bg, ibApplyAlpha( 0xffff965d, 50 ) ):ibData( "rotation", ( i - 1 ) * 30 )
	end
	UIe.drift_points_mul[ 1 ]:ibData( "color", ibApplyAlpha( 0xffff965d, 100 ) )

	UIe.drift_points_mul_lbl = ibCreateLabel( 0, 0, 0, 0, "x1", UIe.drift_bg, COLOR_WHITE, 1, 1, "center", "center" )
		:center_y( )
		:ibData( "font", ibFonts.bold_24 )
		:ibData( "outline", true )

	UIe.drift_total_points = ibCreateLabel( UIe.drift_points_mul_bg:ibGetBeforeX( -20 ), 0, 0, 0, "0", UIe.drift_bg, COLOR_WHITE, 1, 1, "right", "center" )
		:center_y( -10 )
		:ibData( "font", ibFonts.bold_15 )
		:ibData( "outline", true )

	UIe.drift_total_points_info = ibCreateLabel( UIe.drift_total_points:ibGetBeforeX( -5 ), 0, 0, 0, "TOTAL:", UIe.drift_bg, COLOR_WHITE, 1, 1, "right", "center" )
		:center_y( -10 )
		:ibData( "font", ibFonts.regular_12 )
		:ibData( "outline", true )

	UIe.drift_current_points = ibCreateLabel( UIe.drift_points_mul_bg:ibGetBeforeX( -20 ), 0, 0, 0, "+0", UIe.drift_bg, COLOR_WHITE, 1, 1, "right", "center" )
		:center_y( 10 )
		:ibData( "font", ibFonts.bold_26 )
		:ibData( "outline", true )
end

function UpdateUIDrift_total( drift_total_points )
	UIe.drift_total_points:ibData( "text", format_price( drift_total_points ) )
		:ibInterpolate( function( self )
			if not isElement( self.element ) then return end
			self.easing_value = 1 + 0.2 * self.easing_value
			self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
		end, 350, "SineCurve" )
	
	UIe.drift_total_points_info:ibData( "px", UIe.drift_total_points:ibGetBeforeX( -5 ) )
end

function UpdateUIDrift_current( drift_current_points )
	UIe.drift_current_points:ibData( "text", "+".. format_price( drift_current_points ) )
end

function UpdateUIDrift_mul( drift_points_mul )
	UIe.drift_points_mul_lbl:ibData( "text", "x".. drift_points_mul )
		:ibInterpolate( function( self )
			if not isElement( self.element ) then return end
			self.easing_value = 1 + 0.2 * self.easing_value
			self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
		end, 350, "SineCurve" )

	for i, mul_img in pairs( UIe.drift_points_mul ) do
		mul_img:ibData( "color", ibApplyAlpha( 0xffff965d, i > drift_points_mul and 50 or 100 ) )
	end
end

function UpdateUIDrift_state( state )
	if isElement( UIe.drift_state_lbl ) then
		destroyElement( UIe.drift_state_lbl )
	end

	UIe.drift_state_lbl = ibCreateLabel( UIe.drift_points_mul_bg:ibGetAfterX( 20 ), 0, 0, 0, ( state and "ВЫПОЛНЕНО" or "НЕУДАЧА" ), UIe.drift_bg, ( state and COLOR_WHITE or 0xffff4e4e ), 1, 1, "left", "center" )
		:center_y( )
		:ibData( "font", ibFonts.bold_14 )
		:ibData( "outline", true )
		:ibData( "alpha", 0 )
		:ibAlphaTo( 255, 250 )
		:ibTimer( ibAlphaTo, 1000, 1, 0, 250 )
		:ibTimer( destroyElement, 1500, 1 )
end


function CreateUIWrongWay( )
	DestroyUIWrongWay( )

	local func_interpolate = function( self )
		self:ibInterpolate( function( self )
			if not isElement( self.element ) then return end
			self.easing_value = 1 + 0.2 * self.easing_value
			self.element:ibBatchData( { sx = ( 75 * self.easing_value ), sy = ( 75 * self.easing_value ) } ):center_x( )
		end, 350, "SineCurve" )
	end

	UIe.wrong_way = ibCreateImage( 0, 150, 75, 75, "img/wrong_way.png" )
		:center_x( )
		:ibTimer( func_interpolate, 500, 0 )
end

function DestroyUIWrongWay( )
	if isElement( UIe.wrong_way ) then
		destroyElement( UIe.wrong_way )
	end
end



function ShowUIEventReward( number, coins, booster_coins, data )
	DestroyShowUIEventReward( )

	if data and data.is_drag then
		ShowDragEventResult( true, number, coins, booster_coins, data )
		return
	end

	showCursor( true )

	UIe.reward_bg = ibCreateBackground( 0xbf000000, _, true )
		:ibData( "alpha", 0 )
		:ibAlphaTo( 255, 1500 )

	local success_bg = ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, "img/success_bg.png", UIe.reward_bg )

	local coeff_x, coeff_y = _SCREEN_X / 1280, _SCREEN_Y / 720
	local text_effect = ibCreateImage( 0, 119 * coeff_y, _SCREEN_X, 26 * coeff_y, "img/text_success_effect.png", success_bg )
	ibCreateLabel( 0, -1, 0, 26 * coeff_y, "МИССИЯ ВЫПОЛНЕНА", text_effect, 0xFF54FF68, 1, 1, "center", "center", ibFonts[ "bold_" .. math.floor( 36 * coeff_y ) ] )
		:center_x( )
		:ibData( "outline", 1 )

	if number then
		ibCreateLabel( 0, 119 * coeff_y + 120, 0, 0, "Вы заняли ".. number .." место", success_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts[ "regular_" .. math.floor( 30 * coeff_y ) ] )
			:center_x( )
			:ibData( "outline", 1 )
	end

	local offset_y = booster_coins and -70 or 0

	local reward_tittle_bg = ibCreateImage( 0, _SCREEN_Y - 380 + offset_y, 588, 213, "img/reward_tittle_bg.png", UIe.reward_bg ):center_x( )
	ibCreateLabel( 0, 0, 0, 0, "ПОЗДРАВЛЯЕМ! ВЫ ПОЛУЧИЛИ НАГРАДУ:", reward_tittle_bg, 0xFFFFD339, 1, 1, "center", "center", ibFonts.bold_19 ):center( 0, -8 )

	local rewards_bg = ibCreateArea( 0, _SCREEN_Y - 230 + offset_y, 100, 100, UIe.reward_bg ):center_x( )

	local reward_bg = ibCreateImage( 0, 0, 100, 100, "img/reward_item_bg.png", rewards_bg )
	if booster_coins then
		ibCreateImage( 0, 0, 28, 28, "img/reward_coins_icon.png", reward_bg ):center( 0, -14 )
		ibCreateLabel( 0, 74, 0, 0, coins, reward_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_25 ):center_x( )
	else
		ibCreateImage( 0, 0, 38, 34, "img/reward_booster_icon.png", reward_bg ):center( 0, -17 )
		ibCreateLabel( 0, 74, 0, 0, coins, reward_bg, 0xFFFFD339, 1, 1, "center", "center", ibFonts.bold_25 ):center_x( )
	end

	if booster_coins then
		local func_interpolate = function( self )
			self:ibInterpolate( function( self )
				if not isElement( self.element ) then return end
				self.easing_value = 1 + 0.1 * self.easing_value
				self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
			end, 350, "SineCurve" )
		end

		local reward_bg = ibCreateImage( 120, 0, 100, 100, "img/reward_item_bg.png", rewards_bg )
		ibCreateImage( 0, 0, 38, 34, "img/reward_booster_icon.png", reward_bg ):center( 0, -17 )
		ibCreateLabel( 0, 74, 0, 0, booster_coins, reward_bg, 0xFFFFD339, 1, 1, "center", "center", ibFonts.bold_25 ):center_x( )
			:ibTimer( func_interpolate, 100, 1 )
			:ibTimer( func_interpolate, 1000, 0 )
		ibCreateLabel( 0, 120, 0, 0, "С подарками в 2 раза\nбольше пуль", reward_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.semibold_11 ):center_x( )
			:ibTimer( func_interpolate, 100, 1 )
			:ibTimer( func_interpolate, 1000, 0 )


		rewards_bg:ibData( "sx", 220 ):center_x( )

		ibCreateButton( 0, _SCREEN_Y - 150, 180, 44, UIe.reward_bg, "img/btn_more_coins", true ):center_x( )
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "up" then return end
				ibClick( )

				DestroyShowUIEventReward( )
				triggerEvent( "ShowUIEventBoosters", root )
			end )
	end

	local btn_ok = ibCreateButton( 0, _SCREEN_Y - 90, 100, 54, UIe.reward_bg, "img/btn_ok", true ):center_x( )
		:ibData( "disabled", true )
		:ibData( "alpha", 128 )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "up" then return end
			ibClick( )

			DestroyShowUIEventReward( )
		end )

	ibCreateLabel( 0, 0, 0, 0, "5 секунд", btn_ok, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "center", "center", ibFonts.regular_12 ):center( 0, 10 )
		:ibData( "count_tick", 5 )
		:ibTimer( function( self )
			local count_tick = tonumber( self:ibData( "count_tick" ) ) - 1
			self:ibData( "count_tick", count_tick )
			if count_tick > 0 then
				self:ibData( "text", count_tick .. " " .. plural( count_tick, "секунда", "секунды", "секунд" ) )
			else
				bindKey( "space", "up", DestroyShowUIEventReward )
				self:ibData( "text", "[ПРОБЕЛ]" )
				btn_ok:ibData( "disabled", false )
				btn_ok:ibAlphaTo( 255, 250 )
			end
		end, 1000, 5 )
end
addEvent( "ShowUIEventReward", true )
addEventHandler( "ShowUIEventReward", resourceRoot, ShowUIEventReward )

function DestroyShowUIEventReward( )
	unbindKey( "space", "up", DestroyShowUIEventReward )

	if isElement( UIe.reward_bg ) then
		destroyElement( UIe.reward_bg )
		showCursor( false )
	end
end

function DetectPlayerActions()
	if getKeyState( "f" ) and not UIe.last_f_push then
		UIe.last_f_push = getTickCount()
		
		if isElement( UIe.leave_img ) then
			destroyElement( UIe.leave_img )
		end
		
		UIe.leave_img = ibCreateImage( _SCREEN_X / 2 - 151, _SCREEN_Y - 201, 302, 42, _, _, 0x99000000 )
		UIe.leave_progress = ibCreateImage( 1, 1, 0, 40, _, UIe.leave_img, 0xFFDD2222 )
		ibCreateLabel( 0, 0, 302, 42, "Выход из эвента", UIe.leave_img, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_12 )

		UIe.leave_progress
		:ibInterpolate( 
			function( self )
				if self.progress >= 0.495 then
					if isElement( UIe.leave_img ) then
						destroyElement( UIe.leave_img )
					end

					triggerServerEvent( "PlayerQuitAfk", resourceRoot, "Вы покинули состязание" )

					UIe.last_f_push = nil
					bLeaving = true
					return
				elseif not bLeaving then
					UIe.leave_progress:ibBatchData({
						sx = 300 * self.easing_value,
					})
				end
			end, 5000, "SineCurve"
		)

	elseif (not getKeyState( "f" ) or bFinished) and UIe.last_f_push then
		UIe.last_f_push = nil
		if isElement( UIe.leave_img ) then
			destroyElement( UIe.leave_img )
			UIe.last_f_push = nil
		end
	end
end