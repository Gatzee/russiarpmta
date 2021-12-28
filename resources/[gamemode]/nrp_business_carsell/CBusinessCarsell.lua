loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "CVehicle" )
Extend( "ShClans" )
Extend( "ShInventoryConfig" )

UIElements = { }
VEHICLES_LIST = { }

function InitCarsell( )
	if not _CARSELL_INITIALIZED then
		Extend( "ShVehicleConfig" )
		Extend( "ShUtils" )
		Extend( "CPlayer" )
		Extend( "CSound" )
		Extend( "CUI" )
		Extend( "ib" )

		ibUseRealFonts( true )

		_CARSELL_INITIALIZED = true
	end
end

function Carsell_ShowTutorialUI_handler( )
	Carsell_ShowUI( true, {
		veh_spawn     = { 1801.811, -623.897 + 860, 60.216 },
		assortment_id = 0,
		all_vehicles  = true,
		veh_spot      = { 1781.807, -637.083 + 860, 60.852 },
		free_slots    = 999,
		have_slots    = 999,
		custom_prices = {
			[ 517 ] = 0,
		}
	} )
end
addEvent( "Carsell_ShowTutorialUI" )
addEventHandler( "Carsell_ShowTutorialUI", root, Carsell_ShowTutorialUI_handler )

function Carsell_ShowUI( state,data )
	if isElement( UI.black_bg ) and state then return end
	InitCarsell( )

	if state then
		Carsell_ShowUI( false )

		DATA = data

		VEH = 1
		VARIANT = 1
		COLOR = 1

		Carsell_GenerateVehiclesList( data.all_vehicles )

		VEHICLE = Vehicle( VEHICLES_LIST[ 1 ].vmodel, DATA.veh_spot[1],DATA.veh_spot[2] + 860,DATA.veh_spot[3],0,0,DATA.veh_spot[4] )
		VEHICLE.dimension = 1
		VEHICLE.frozen = true
		VEHICLE:SetID( "8800555353" )
		VEHICLE:SetColor( 255, 255, 255, 0, 0, 0 )
		VEHICLE:SetNumberPlate( "01:о777оо99" ) -- "01:99:е777кх"
		
		-- Автомобиль создан, обрабатываем его данные
		DisableHUD( true )
		ShowCarsellUI( true )
		Carsell_ParseCurrentVehicle( true )

		bindKey( "enter", "down", OpenConfirmationUI )
		bindKey( "arrow_l", "down", Carsell_ChangeVehicle, -1 )
		bindKey( "arrow_r", "down", Carsell_ChangeVehicle, 1 )

		if DATA.assortment_id == 8 then
			triggerEvent( "showWindowOfSafetyUseHelmets", localPlayer )
		end

		addEventHandler( "onClientRender", root, InteractiveCamMove )
		showCursor( true )

		local radio_url = "sounds/music_car_showroom.ogg"
		SOUND = SoundCreateSource( SOUND_TYPE_2D, radio_url, true )
		--setSoundEffectEnabled( SOUND, "reverb", true )
		SoundSetVolume( SOUND, 0.15 )
		SoundSetBand( SOUND, "radio" )

		for _, v in pairs( PREVIEW_VEHICLES ) do
			v.position = v.position + Vector3( 0, 0, 300 )
		end

		localPlayer.dimension = 1
		localPlayer.frozen = true
		localPlayer:setData( "in_business_carsell", true, false )

		STATE = true
	else
		DisableHUD( false )
		ShowCarsellUI( false )
		ShowConfirmationUI( false )
		ShowNotEnoughSlotsWindow( false )
		showCursor( false )
		
		unbindKey( "enter", "down", OpenConfirmationUI )
		unbindKey( "arrow_l", "down", Carsell_ChangeVehicle, -1 )
		unbindKey( "arrow_r", "down", Carsell_ChangeVehicle, 1 )

		DestroyTableElements( UIElements )
		if isElement( VEHICLE ) then destroyElement( VEHICLE ) end
		if isElement( SOUND ) then SoundDestroySource( SOUND ) end

		if STATE then
			setCameraTarget( localPlayer )
			localPlayer.dimension = 0
			localPlayer.frozen = false
			STATE = false
			for i, v in pairs( PREVIEW_VEHICLES ) do
				v.position = v.position - Vector3( 0, 0, 300 )
			end
		end

		removeEventHandler( "onClientRender", root, InteractiveCamMove )
		localPlayer:setData( "in_business_carsell", nil, false )
	end
end
addEvent( "Carsell_ShowUI",true )
addEventHandler( "Carsell_ShowUI",root,Carsell_ShowUI )

function GetVehicleBlockedReason( vehicle_data, variant_data )
	vehicle_data = vehicle_data or VEHICLE_DATA
	variant_data = variant_data or VARIANT_DATA
	if vehicle_data.blocked and not vehicle_data.blocked.fClientCheck( ) then
		return vehicle_data.blocked.sReason or "Заблокировано"
	end

	if vehicle_data.premium and not localPlayer:IsPremiumActive() then
		return "Доступно с премиумом"
	end
end

function GetVehicleDiscountCost( )
	local cost = VARIANT_DATA.cost
	local model = VEHICLE_DATA.vmodel

	local discounted_f4_price = exports.nrp_shop:GetOfferDiscountPriceForModel( "discounts", model, VARIANT_DATA.id )
	if discounted_f4_price then
		cost = discounted_f4_price
	end

	local discount = DATA and DATA.discount
	if discount and ( discount.timestamp or 0 ) > getRealTimestamp( ) then
		cost = cost * ( 100 - discount.percentage ) / 100
	end

	local pSale = DATA.sales and DATA.sales[ model ]
	if pSale and pSale.timestamp > getRealTimestamp( ) then
		cost = cost * ( 1 - pSale.percent )
	end

	local pTempDiscount = DATA.temp_discount
	if pTempDiscount and pTempDiscount.timestamp > getRealTimestamp( ) then
		if model == pTempDiscount.model then
			cost = cost * ( 1 - pTempDiscount.percent / 100 ) 
		end
	end

	if VEHICLE_DATA.is_moto then 
		cost = cost * ( 1 - localPlayer:GetClanBuffValue( CLAN_UPGRADE_MOTO_DISCOUNT ) / 100 )
	end

	return VARIANT_DATA.cost ~= cost and math.ceil( cost - 0.5 )
end

function Carsell_ParseCurrentVehicle( force_relocate )
	if not VEH or not VARIANT then return end
	local veh = VEHICLES_LIST[VEH]
	-- local variant = veh.variants[VARIANT]

	VEHICLE_DATA = veh
	VARIANT_DATA = table.copy( veh.variant_data )

	VARIANT_DATA.cost = DATA.custom_prices and DATA.custom_prices[ VEHICLE_DATA.vmodel ] or VARIANT_DATA.cost
	VARIANT_DATA.discount_cost = GetVehicleDiscountCost( )

	VEHICLE.model = VEHICLE_DATA.vmodel
	VEHICLE:SetVariant( VARIANT_DATA.id )

	VEHICLE:FixPositionZ( )
	exports.nrp_vehicle_wheels:UpdateVehicleWheelsStuff( )
	triggerEvent( "onVehicleRequestTuningRefresh", VEHICLE )

	-- Чёрная молния
	if VEHICLE.model == 438 then
		OLDCOLOR = COLOR
		COLOR = 3
		Carsell_ParseVehicleColor( )
	else
		if OLDCOLOR then
			COLOR = OLDCOLOR
			Carsell_ParseVehicleColor( )
			OLDCOLOR = nil
		end
	end
	UI.UpdateSelectedColor( )

	UI.UpdateInfo( )
	UI.UpdateStats( )
	UI.UpdateCost( )
	UI.UpdateBlockedReason( )
	UI.UpdateTrunkSize( )
end

function Carsell_ParseVehicleColor( )
	if not isElement( VEHICLE ) or not COLORS then return end
	local color = COLORS[COLOR]
	local r, g, b = hex2rgb( color )
	setVehicleColor( VEHICLE, r, g, b )
end

function Carsell_ChangeVehicle( key, state, inc )
	if IS_VEHICLE_SELECTOR_DISABLED then return end

	local inc = inc or 1
	VEH = ( VEH + inc ) % ( #VEHICLES_LIST )
	if VEH == 0 then VEH = #VEHICLES_LIST end
	VARIANT = 1
	Carsell_ParseCurrentVehicle( )
	UI.UpdateSelectedVehicle( )
	ibClick( )
end

function Carsell_ChangeColor( inc )
	local inc = inc or 1
	COLOR = ( COLOR + inc ) % ( #COLORS )
	if COLOR == 0 then COLOR = #COLORS end
	Carsell_ParseVehicleColor( )
end

function Carsell_GenerateVehiclesList( all_vehicles )
	VEHICLES_LIST = {}

	local function IsNormalMarketlist( marketlist )
		if not marketlist then return end

		local available = false
		for i = 1, 4 do
			available = available or string.find( marketlist, tostring( i ) )
		end
		return available
	end

	local ts = getRealTimestamp( )

	for i, data in pairs( VEHICLE_CONFIG ) do
		if i < 612 then 
		if type( data.sale_start_time ) == "string" then
			data.sale_start_time = getTimestampFromString( data.sale_start_time, true )
		end
		if data.sell and ( not data.sale_start_time or ts >= data.sale_start_time ) then
			if all_vehicles and IsNormalMarketlist( data.marketlist ) or DATA.assortment_id and data.marketlist and ( string.find( data.marketlist, DATA.assortment_id ) or ( DATA.assortment_id ~= 5 and data.marketlist == "all" and DATA.assortment_id ~= 8 ) or ( not DATA.assortment_id and not data.marketlist ) ) then
				data.vmodel = i
				-- for i, variant_data in pairs( data.variants ) do
				-- 	if not variant_data.not_sell then
				-- 		local data = table.copy( data )
				-- 		variant_data.id = i
				-- 		data.time_new = variant_data.time_new or data.time_new
						if data.time_new == true and data.sale_start_time then
							data.time_new = data.sale_start_time + 14 * 24 * 60 * 60
						end
						if data.time_new and data.time_new <= ts then
							data.time_new = nil 
						end
				-- 		data.variant_data = variant_data
						table.insert( VEHICLES_LIST, data )
				-- 	end
				-- end
			end
		end
	end
	end

	table.sort( VEHICLES_LIST, function( a, b )
		local a_new = a.time_new and 1 or 0
		local b_new = b.time_new and 1 or 0
		
		if a_new == b_new then
			if a.time_new and b.time_new then
				return a.time_new > b.time_new
			else
				if a.premium or b.premium then
					local a_premium = a.premium and 1 or 0
					local b_premium = b.premium and 1 or 0
					
					return a_premium < b_premium
				end

				return a.variants[ 1 ].cost < b.variants[ 1 ].cost
			end
		else
			return a_new > b_new
		end
	end )

	local vehicle_list_with_variants = { }
	for i, data in pairs( VEHICLES_LIST ) do
		for variant, variant_data in pairs( data.variants ) do
			if not variant_data.not_sell then
				local veh_data = table.copy( data )
				variant_data.id = variant
				veh_data.time_new = variant_data.time_new or veh_data.time_new
				if veh_data.time_new and veh_data.time_new <= ts then
					veh_data.time_new = nil 
				end
				veh_data.variant_data = variant_data
				table.insert( vehicle_list_with_variants, veh_data )
			end
		end
	end
	VEHICLES_LIST = vehicle_list_with_variants

	local forced_priority_list = { }
	local found_forced = false

	repeat
		found_forced = false

		for k,v in pairs( VEHICLES_LIST ) do
			if v.forced_priority then
				table.insert( forced_priority_list, v )
				table.remove( VEHICLES_LIST, k )
				found_forced = true
				break
			end
		end
	until
		not found_forced

	table.sort( forced_priority_list, function( a, b ) return a.forced_priority > b.forced_priority end )

	local insert_bias = -1
	for k,v in pairs( forced_priority_list ) do
		table.insert( VEHICLES_LIST, v.forced_priority + insert_bias, v )
		insert_bias = insert_bias + 1
	end
end

local camera_offset = { -3.125, 5.775, 0.625, 2.1451, 0.6322, -0.5151 }

local window
addCommandHandler( "editsettings", function( )

	if isElement( window ) then
		local b = guiGetVisible( window )
		guiSetVisible( window, not b )
		showCursor( not b )
		return
	end

	local settings = {
		{ name = "x", min = -2, max = 2, default = 0 },
		{ name = "y", min = -2, max = 2, default = 0 },
		{ name = "z", min = -2, max = 2, default = 0 },
		{ name = "tx", min = -2, max = 2, default = 0 },
		{ name = "ty", min = -2, max = 2, default = 0 },
		{ name = "tz", min = -2, max = 2, default = 0 },
	}

	window = guiCreateWindow( 100, 100, 1100, 400, "", false )

	local scrollpane = guiCreateScrollPane( 0, 20, 1100, 400, false, window )

	local scrollbars = {}
	for i, setting in pairs( settings ) do
		setting.max = math.max( setting.max, setting.default )
		setting.min = math.min( setting.min, setting.default )
		local y = 0 + ( i - 1 ) * 40
		guiCreateLabel( 10, y + 5, 200, 80, setting.name, false, scrollpane )
		local edit_min = guiCreateEdit( 105, y, 70, 25, setting.min, false, scrollpane )
		local scrollbar = guiCreateScrollPane( 180, y - 4, 700, 30, false, scrollpane )
		guiScrollPaneSetScrollBars( scrollbar, true, false )
		guiCreateLabel( 0, 0, 2000, 20, "", false, scrollbar )
		guiScrollPaneSetHorizontalScrollPosition( scrollbar, 100 * ( setting.default - setting.min ) / ( setting.max - setting.min ) )
		local edit_max = guiCreateEdit( 885, y, 70, 25, setting.max, false, scrollpane )
		local edit_value = guiCreateEdit( 960, y, 70, 25, setting.default, false, scrollpane )
		scrollbars[ i ] = { edit_min = edit_min, scroll = scrollbar, edit_max = edit_max, edit_value = edit_value }
	end
	
	addEventHandler( "onClientRender", root, function( )
		local sx, sy = guiGetSize( window, false )
		guiSetSize( scrollpane, sx, sy, false )
		guiSetPosition( copyButton, sx - 110, sy - 40, false )
		for i, setting in pairs( settings ) do
			local min = tonumber( guiGetText( scrollbars[i].edit_min ) )
			local max = tonumber( guiGetText( scrollbars[i].edit_max ) )
			if min and max then
				local sp = guiScrollPaneGetHorizontalScrollPosition( scrollbars[i].scroll )
				setting.value = min + sp *( max - min ) * 0.01
				_G[ setting.name ] = setting.value
				guiSetText( scrollbars[i].edit_value, tostring( setting.value ) )
			end
		end
	end )

	local copyButton = guiCreateButton (965, 20, 100, 30, "Copy", false, window)
	addEventHandler ( "onClientGUIClick", copyButton, function ()
		local ots = "{"
		for i, setting in pairs( settings ) do
			local min = tonumber( guiGetText( scrollbars[i].edit_min ) )
			local max = tonumber( guiGetText( scrollbars[i].edit_max ) )
			if min and max then
				local sp = guiScrollPaneGetHorizontalScrollPosition( scrollbars[i].scroll )
				setting.value = min + sp *( max - min ) * 0.01
				ots = ots.. string.format( "%.4f", setting.value )..", "
			end
		end
		ots = ots.."}"
		setClipboard (ots)
	end, false )
	
	bindKey( "4", "down", function( )
		local b = guiGetVisible( window )
		guiSetVisible( window, not b )
		showCursor( not b )
	end )

end )

function InteractiveCamMove( )
	local pos_x, pos_y = getCursorPosition( )
	pos_x, pos_y = getEasingValue( pos_x, "InOutQuad" ), getEasingValue( pos_y, "OutInQuad" )
	setCameraMatrix( 
		DATA.veh_spot[1] - 0.25 * pos_x + camera_offset[ 1 ], 
		(DATA.veh_spot[2] - 0.25 * pos_x + camera_offset[ 2 ]) +860, 
		DATA.veh_spot[3] - 0.25 * pos_y + camera_offset[ 3 ], 
		DATA.veh_spot[1] + camera_offset[ 4 ], 
		(DATA.veh_spot[2] + camera_offset[ 5 ]) +860, 
		DATA.veh_spot[3] + camera_offset[ 6 ]
	)
end

function Carsell_Quit( )
	if isElement( UI.bg ) then
		Carsell_ShowUI( false )
	end
end
addEventHandler( "onClientPlayerWasted", localPlayer, Carsell_Quit )
addEventHandler( "onClientResourceStop", resourceRoot, Carsell_Quit )

addEvent( "onClientPlayerBuySlot", true )
addEventHandler( "onClientPlayerBuySlot", root, function( )
	if isElement( UI.bg ) then
		DATA.have_slots = DATA.have_slots + 1
		DATA.free_slots = DATA.free_slots + 1
		UI.UpdateSlots( )
	end
end )

PREVIEW_VEHICLES = { }
addEventHandler( "onClientResourceStart", resourceRoot, function( )
	local static_cars = {
		{
			model = 602,
			position = Vector3( { x = 1773.593, y = -620.75, z = 60.55 } ),
			rotation = Vector3( 0.61495971679688, 0, 250 ),
			color = { 255, 200, 0 },
			ex_tuning = {
				[ TUNING_FRONT_BUMP ] = 1,
				[ TUNING_REAR_BUMP ]  = 1,
				[ TUNING_SKIRT ]      = 1,

				[ TUNING_SPOILER ] = 5,

				[ TUNING_FRONT_LIP ] = 3,
				[ TUNING_REAR_LIP ]  = 1,

				[ TUNING_ROOF ]   = 1,
				[ TUNING_BONNET ] = 1,

				[ TUNING_FRONT_FENDS ] = 2,
				[ TUNING_REAR_FENDS ]  = 2,
			}
		},
	}

	for idx, data in pairs( static_cars ) do
		local vehicle = createVehicle( data.model, data.position )
		vehicle.rotation = data.rotation
		vehicle.frozen = true
		vehicle.dimension = 0
		vehicle:SetColor( unpack( data.color ) )
		vehicle:SetNumberPlate( "1:о000оо99" )

		if data.ex_tuning then
			vehicle:SetExternalTuning( data.ex_tuning )
			triggerEvent( "onVehicleRequestTuningRefresh", vehicle )
		end
	end

	table.insert( PREVIEW_VEHICLES, vehicle )
end )