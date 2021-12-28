local selection = 1
local vehicle_selection = 1
local pData = {}
local iShowCooldown = 0
local bControlsDisabled = 0
local timer = nil

DUMMY_VEHICLE = nil

local sections = 
{
	{
        id = "vehicle",
		title = "Транспорт",
        color = 0xFF6988A8,
        on_left = function()
			SwitchVehicle( -1 )
		end,
		on_right = function()
			SwitchVehicle( 1 )
		end,
	},
	{
        id = "accept",
		title = "Подтвердить",
		color = 0xAA65B971,
		on_enter = function( )
			if pData.vehicles[ UI_elements.vehicle_selection ].element:getData( 'tow_evac_added' ) then
				localPlayer:ShowInfo( 'Это авто ожидает эвакуации' )
				return
            end
            
			bControlsDisabled = getTickCount() + 5000
			if pData.host then
				triggerServerEvent("RC:OnPlayerRequestCreateLobby", resourceRoot, localPlayer, { vehicle = pData.vehicles[ UI_elements.vehicle_selection ].element, track = pData.track.name })
			else
				triggerServerEvent("RC:OnPlayerRequestJoinLobby", resourceRoot, localPlayer, pData.lobby_id, pData.vehicles[ UI_elements.vehicle_selection ].element )
			end
		end,
	},
	{
        id = "exit",
		title = "Выйти",
		color = 0xAAB96571,
		on_enter = function()
			if isElement( DUMMY_VEHICLE ) then
				destroyElement( DUMMY_VEHICLE )
			end
			localPlayer.position = localPlayer.position + Vector3( 0, 0, 1 )
			ShowUI_Selector( false, nil, true, true )
			OnRacePostFinished()
        end,
        offset = 22,
	},
}

local stats = 
{
	{
		title = "Скорость",
		icon = "icon_speed.png",
		ix = 24, iy = 24
	},
	{
		title = "Ускорение",
		icon = "icon_acceleration.png",
		ix = 25, iy = 14
	},
	{
		title = "Управление",
		icon = "icon_handlings.png",
		ix = 22, iy = 22
	},
}

-- Переключение тачки
local function SwitchSection( value, is_click )
    local new_section = is_click and value or selection + value
    if not sections[ new_section ] then return end 
    
    UI_elements[ "section_" .. sections[ selection ].id ]:ibData("color", 0x00FFFFFF)
	UI_elements[ "section_" .. sections[ new_section ].id ]:ibData("color", sections[ new_section ].color )
	selection = new_section
end

-- Перехват нажатий
local function KeyHandler( key, state )
	cancelEvent()
	if not state or getTickCount() < bControlsDisabled then return end
    
    if key == "arrow_r" then
		if sections[ selection ].on_right then
			sections[ selection ].on_right()
		end
	elseif key == "arrow_l" then
		if sections[ selection ].on_left then
			sections[ selection ].on_left()
		end
	elseif key == "enter" then
		if sections[ selection ].on_enter then
			sections[ selection ].on_enter()
		end
	elseif key == "arrow_u" then
		SwitchSection( -1 )
	elseif key == "arrow_d" then
		SwitchSection( 1 )
	end
end

function OnTryLeftSelector()
	if isElement( DUMMY_VEHICLE ) then
		destroyElement( DUMMY_VEHICLE )
	end
	localPlayer.position = localPlayer.position + Vector3( 0, 0, 1 )
	ShowUI_Selector(false, nil, true, true)
	OnRacePostFinished()
end

function ShowUI_Selector( state, data, fade_camera, is_exit )
    if state then
        if iShowCooldown > getTickCount() or isElement( UI_elements.bg ) then return end
		
		ShowUI_Selector( false )
        
        localPlayer.frozen = true
        localPlayer.dimension = localPlayer:GetUniqueDimension( RACING_DIMENSION )
        
        pData = data
        pLastVehicleData = nil
        UI_elements.section, UI_elements.vehicle_selection = 1, 1

		UI_elements.black_bg = ibCreateBackground( 0x00000000, OnTryLeftSelector, true, true )
        UI_elements.content_area = ibCreateArea( 60, 95, 360, 395, UI_elements.black_bg ):ibData( "alpha", 0 )
        UI_elements.bg = ibCreateImage( 0, 0, 360, 191, nil, UI_elements.content_area,  0xEE475d75 )
        UI_elements.header = ibCreateImage( 0, 0, 360, 50, nil, UI_elements.bg, 0xFF59738f )
        ibCreateLabel( 0, 0, 360, 50, "Настройки", UI_elements.header, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_16 )
		
        local py = 50
        for k, v in pairs( sections ) do
			UI_elements[ "section_" .. v.id ] = ibCreateImage( 0, py, 360, 47, nil, UI_elements.bg, 0x00FFFFFF )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                ibClick()

                if selection == k and sections[ k ].on_enter then
					sections[ k ].on_enter()
				else
					SwitchSection( k, true )
				end
            end )

            UI_elements[ "label" .. k ] = ibCreateLabel( 25 + (v.offset or 0), 0, 360, 47, v.title, UI_elements[ "section_" .. v.id ], 0xFFDDDDDD, 1, 1, "left", "center", ibFonts.semibold_14 ):ibData( "disabled", true )
            if k ~= #sections then
                ibCreateImage( 0, py + 47, 360, 1, nil, UI_elements.bg, 0x22FFFFFF )
            end
			py = py + 47
		end

        UI_elements.icon_exit = ibCreateImage( 25, 13, 18, 20, "files/img/lobby/icon_leave.png", UI_elements[ "section_exit" ] )

        local vehicle_name = GetVehicleNameFromModel( data.vehicles[ UI_elements.vehicle_selection ].element.model )
        UI_elements.label_vehicle = ibCreateLabel( 270, 0, 0, 47, vehicle_name, UI_elements["section_vehicle"], 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.semibold_14 ):ibData( "disabled", true )

        UI_elements.arrow_left = ibCreateImage( UI_elements.label_vehicle:ibGetBeforeX() - 12, 19, 6, 10, "files/img/lobby/arrow.png", UI_elements["section_vehicle"] )
        :ibBatchData({ rotation = 180, color = 0xAA111111 })
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            ibClick()
            SwitchVehicle( -1 )
        end )

		UI_elements.arrow_right = ibCreateImage( UI_elements.label_vehicle:ibGetAfterX() + 6, 19, 6, 10, "files/img/lobby/arrow.png", UI_elements["section_vehicle"] )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            ibClick()
            SwitchVehicle( 1 )
        end )

        UI_elements.stats_block = ibCreateImage( 0, 211, 360, 150, nil, UI_elements.content_area, 0xEE475D75 )
		local py = 0
		for k, v in pairs( stats ) do
			UI_elements[ "s_label" ..k ] = ibCreateLabel( 25, py, 360, 50, v.title, UI_elements.stats_block, 0xFFDDDDDD, 1, 1, "left", "center", ibFonts.semibold_14 )
			UI_elements[ "s_icon" ..k ]  = ibCreateImage( 290 - v.ix / 2, py + 25 - v.iy / 2, v.ix, v.iy, "files/img/lobby/" .. v.icon, UI_elements.stats_block )
            UI_elements[ "s_value" ..k ] = ibCreateLabel( 330, py, 0, 50, data.vehicles[ UI_elements.vehicle_selection ].stats[ k ] or "-", UI_elements.stats_block, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_16 )
            if k ~= #stats then
                ibCreateImage( 25, py + 50, 310, 1, _, UI_elements.stats_block, 0x22FFFFFF )
            end
			py = py + 50
		end

		UI_elements.controls = ibCreateImage( 60, scY - 54, 580, 54, "files/img/lobby/controls.png" ):ibData("alpha", 0)
			:ibTimer( function( )
				SwitchVehicle( 0 )
			end, 2000, 1 )

		SwitchSection( 0 )
		SwitchVehicle( 0 )

		fadeCamera( false, 0.2 )
		setTimer(function()
			if not isElement( UI_elements.bg ) then return end
            
            setCameraMatrix( 2413.3811, -2432.0672, 19.5, 2421.2385, -2431.5416, 20.2 )
            fadeCamera( true, 1 )
            UI_elements.content_area
            :ibAlphaTo( 255, 200 )
            
            UI_elements.controls
            :ibAlphaTo( 255, 200 )
            
            SwitchMusic( true )
            showCursor( true )
            addEventHandler( "onClientKey", root, KeyHandler )
		end, 1500, 1)

		triggerEvent( "ShowPhoneUI", localPlayer, false )
        triggerEvent( "ShowUIInventory", root, false )
		
		addEventHandler( "onClientPlayerWasted", localPlayer, onClientPlayerWasted_handler )
		addEventHandler( "onClientKey", root, RaceKeyHandler )
		DisableHUD( true )
		
    else
        DestroyTableElements( UI_elements )
        UI_elements = {}

        DisableHUD( false )
        showCursor( false )

		triggerEvent( "ShowPhoneUI", localPlayer, false )
		removeEventHandler( "onClientPlayerWasted", localPlayer, onClientPlayerWasted_handler )
		removeEventHandler( "onClientKey", root, RaceKeyHandler )
        removeEventHandler( "onClientKey", root, KeyHandler )
        iShowCooldown = getTickCount() + 3000

        if is_exit then
            localPlayer.dimension = 0
			if isElement( DUMMY_VEHICLE ) then
				destroyElement( DUMMY_VEHICLE )
			end
			SwitchMusic()
		end

		if fade_camera then
			fadeCamera( false, 0.2 )
            setTimer( setCameraTarget, 1200, 1, localPlayer )

			setTimer(function()
				fadeCamera( true, 1 )
				localPlayer.frozen = false
			end, 1700, 1)

			triggerServerEvent( "RC:OnPlayerStopVehiclePreview", resourceRoot, localPlayer )
		end
	end
	
	localPlayer:setData( "in_race_lobby", state, false )
end
addEvent("RC:ShowUI_Selector", true)
addEventHandler("RC:ShowUI_Selector", root, ShowUI_Selector)

function SwitchVehicle( value )
	local pNewVehicle = pData.vehicles[ UI_elements.vehicle_selection + value ]
	if not pNewVehicle then return end

	UI_elements.vehicle_selection = UI_elements.vehicle_selection + value

	if not isElement( DUMMY_VEHICLE ) then
		DUMMY_VEHICLE = createVehicle( pNewVehicle.element.model, 2421.2385, -2432.5416, -10, 0, 0, 45 )
	else
		DUMMY_VEHICLE:ResetVinyls( )
	end

	DUMMY_VEHICLE.model = pNewVehicle.element.model
	DUMMY_VEHICLE.velocity = Vector3( 0, 0, 0 )
	DUMMY_VEHICLE.rotation = Vector3( 0, 0, 45 )
	DUMMY_VEHICLE.dimension = localPlayer.dimension
	DUMMY_VEHICLE.interior = 0
	DUMMY_VEHICLE.frozen = true

	local pos_updated = false

	if isTimer( timer ) then killTimer( timer ) end
	timer = setTimer( function ( )
		if not isElement( DUMMY_VEHICLE ) then
			killTimer( timer )
			return
		end

		local x0, y0, z0 = getElementBoundingBox( DUMMY_VEHICLE )
		z0 = ( not z0 and 0.5 or z0 ) * -1
		z0 = z0 < 0.1 and 0.5 or z0

		local individual_z = getGroundPosition( 2421.2385, -2432.5416, 21 ) + z0

		if not isElementOnScreen( DUMMY_VEHICLE ) or not pos_updated then
			DUMMY_VEHICLE.position = Vector3( 2421.2385, -2432.5416, individual_z )
			pos_updated = true
		end
	end, 50, 10 )

	setVehicleColor( DUMMY_VEHICLE, unpack(pNewVehicle.client_data.color) )
	setVehicleHeadLightColor( DUMMY_VEHICLE, unpack(pNewVehicle.client_data.headlight_color) )
	setVehicleOverrideLights( DUMMY_VEHICLE, 2 )
	DUMMY_VEHICLE:SetWindowsColor( unpack(pNewVehicle.client_data.windows_color) )
	DUMMY_VEHICLE:SetExternalTuning( pNewVehicle.client_data.external_tuning )
	DUMMY_VEHICLE:SetNumberPlate( pNewVehicle.client_data.number_plate )

	if pNewVehicle.client_data.vinyls then
		DUMMY_VEHICLE:ApplyVinyls( pNewVehicle.client_data.vinyls, pNewVehicle.client_data.color )
	end

	for k,v in pairs( pNewVehicle.client_data.upgrades ) do
		addVehicleUpgrade( DUMMY_VEHICLE, v )
	end
	triggerEvent( "onVehicleRequestTuningRefresh", DUMMY_VEHICLE )


	UI_elements.label_vehicle:ibData( "text", GetVehicleNameFromModel(pData.vehicles[ UI_elements.vehicle_selection ].element.model) )
	for k,v in pairs(stats) do
		UI_elements["s_value"..k]:ibData("text", pData.vehicles[ UI_elements.vehicle_selection ].stats[k] or "-")
	end

	UI_elements.arrow_right:ibData("color", 0xFFFFFFFF)
	UI_elements.arrow_left:ibData("color", 0xFFFFFFFF)

	UI_elements.label_vehicle:ibData("px", math.floor(336 - UI_elements.label_vehicle:width() / 2 ) )
	UI_elements.arrow_left:ibData("px", UI_elements.label_vehicle:ibGetBeforeX() - 12 )
	UI_elements.arrow_right:ibData("px", UI_elements.label_vehicle:ibGetAfterX() + 6 )

	if not pData.vehicles[ UI_elements.vehicle_selection + 1 ] then
		UI_elements.arrow_right:ibData("color", 0xAA111111)
	end

	if not pData.vehicles[ UI_elements.vehicle_selection - 1 ] then
		UI_elements.arrow_left:ibData("color", 0xAA111111)
	end
end

function onClientPlayerWasted_handler()
	localPlayer.position = localPlayer.position + Vector3( 0, 0, 1 )
	ShowUI_Selector( false, nil, true, true )
	OnRacePostFinished()
	removeEventHandler( "onClientPlayerWasted", localPlayer, onClientPlayerWasted_handler )
end