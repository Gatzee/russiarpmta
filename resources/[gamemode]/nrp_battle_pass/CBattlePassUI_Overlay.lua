enum "eUIOverlays" {
    "OVERLAY_TUNING_CASE",
    "OVERLAY_VINYL_CASE",
    "OVERLAY_VINYL",
    "OVERLAY_NUMBERPLATE",
    "OVERLAY_PREMIUM_PURCHASE",
}

EASING_TYPES = {
    -- [ OVERLAY_ERROR ] = "OutBounce",
}

EASING_DURATIONS = {
    -- [ OVERLAY_ERROR ] = 700,
}

function ShowOverlay( overlay_type, data )
    if not isElement( UI and UI.bg ) then return end
	
    local parent = UI.tab_panel.elements.rt
    local oy = 0

    ibOverlaySound()
    
    local overlay_area = ibCreateArea( 0, oy, parent:width( ), parent:height( ) - oy, parent )
		:ibBatchData( { priority = 2, overlay = true } )

    local overlay_bg = ibCreateImage( 0, parent:height( ), parent:width( ), parent:height( ) - oy, _, overlay_area, ibApplyAlpha( 0xff1f2934, 95 ) )
        :ibMoveTo( 0, 0, EASING_DURATIONS[ overlay_type ] or 200, EASING_TYPES[ overlay_type ] )

    if OVERLAYS[ overlay_type ] then
        OVERLAYS[ overlay_type ]( overlay_bg, data )
    end

    if not UI.overlays then UI.overlays = { } end
    UI.overlays[ overlay_bg ] = true
end
addEvent( "BP:ShowOverlay", true )
addEventHandler( "BP:ShowOverlay", root, ShowOverlay )

OVERLAYS = {
    [ OVERLAY_PREMIUM_PURCHASE ] = function( parent, data )
        ibCreateImage( 0, 0, 0, 0, "img/overlay/bg_premium.png", parent ):ibSetRealSize( ):center_x( )

        ibCreateLabel( 563, 486, 0, 0, GetBattlePassPremuimCost( ), parent, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_27 )

        local btn_buy = ibCreateButton( 0, 526, 0, 0, parent, 
                "img/overlay/btn_buy.png", "img/overlay/btn_buy_h.png", "img/overlay/btn_buy_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibSetRealSize( ):center_x( )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                triggerServerEvent( "BP:onPlayerWantBuyPremium", resourceRoot )
                HideOverlay( parent )
            end )

        local btn_hide = ibCreateButton( 0, 605, 0, 0, parent, 
                "img/overlay/btn_hide.png", _, _, ibApplyAlpha( 0xFFFFFFFF, 75 ), 0xFFFFFFFF, 0xFFAAAAAA )
            :ibSetRealSize( ):center_x( )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                HideOverlay( parent )
            end )
    end,

    [ OVERLAY_TUNING_CASE ] = function( parent, data )
        ibCreateLabel( 0, 28, parent:width( ), 0, "Выберите тип тюнинг-кейса \"" .. data.name .. "\"", parent, 0xffffffff, _, _, "center", "top", ibFonts.bold_16 )

        local area_type_btns = ibCreateArea( 0, 68, 0, 0, parent )
        local selected_case_type = 1
        local bg_selected_btn = ibCreateImage( -5, -5, 97, 52, "img/overlay/btn_selected.png" )
        for case_type, name in ipairs( INTERNAL_PARTS_NAMES_TYPES ) do
            local btn = ibCreateButton( ( 87 + 10 ) * ( case_type - 1 ), 0, 87, 42, area_type_btns, 
                    "img/overlay/btn.png", _, _, ibApplyAlpha( 0xFFFFFFFF, 75 ), 0xFFFFFFFF, 0xFFAAAAAA )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    bg_selected_btn.parent = source
                    selected_case_type = case_type
                    UpdateTasksList( ) 
                end )

            if case_type == 1 then
                bg_selected_btn.parent = btn
            end

            ibCreateLabel( 0, 0, 87, 42, "Type " .. name, btn, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
                :ibData( "disabled", true )
        end
        area_type_btns:ibData( "sx", ( 87 + 10 ) * #INTERNAL_PARTS_NAMES_TYPES - 10 ):center_x( )

        ibCreateLabel( 0, 138, parent:width(), 0, "Выберите автомобиль, к классу которого вы хотите привязать этот кейс", parent, COLOR_WHITE, _, _, "center", _, ibFonts.bold_16 )

        CreateVehicleSelector( 186, parent, false, function( selected_vehicle )
            ShowReward( data.level, data.type, selected_vehicle, selected_case_type )
            HideOverlay( parent )
        end )
    end,
    
    [ OVERLAY_VINYL_CASE ] = function( parent, data )
        ibCreateLabel( 0, 28, parent:width(), 0, "Выберите автомобиль, к классу которого вы хотите привязать винил-кейс \"" .. data.name .. "\"", parent, COLOR_WHITE, _, _, "center", _, ibFonts.bold_16 )

        CreateVehicleSelector( 76, parent, false, function( selected_vehicle )
            ShowReward( data.level, data.type, selected_vehicle )
            HideOverlay( parent )
        end )
	end,
    
    [ OVERLAY_VINYL ] = function( parent, data )
        ibCreateLabel( 0, 28, parent:width(), 0, "Выберите транспорт, к классу которого вы хотите привязать винил \"" .. data.name .. "\"", parent, COLOR_WHITE, _, _, "center", _, ibFonts.bold_16 )

        CreateVehicleSelector( 76, parent, true, function( selected_vehicle )
            ShowReward( data.level, data.type, selected_vehicle )
            HideOverlay( parent )
        end )
	end,
    
    [ OVERLAY_NUMBERPLATE ] = function( parent, data )
        ibCreateLabel( 0, 28, parent:width(), 0, "Выберите автомобиль, на который вы хотите установить номер \"" .. data.text .. "\"", parent, COLOR_WHITE, _, _, "center", _, ibFonts.bold_16 )

        CreateVehicleSelector( 76, parent, false, function( selected_vehicle )
            ShowReward( data.level, data.type, selected_vehicle )
            HideOverlay( parent )
        end )
	end,
}

function CreateVehicleSelector( py, parent, with_moto, OnSelect )

    local scrollpane, scrollbar = ibCreateScrollpane( 0, py, parent:width(), parent:height() - py, parent, { scroll_px = -20 } )
    scrollbar:ibSetStyle( "slim_nobg" )

    local sx, sy = parent:width(), 74

    ibCreateImage( 30, py-1, sx-60, 1, nil, parent, 0xff59616a )

    local pVehicles = localPlayer:GetVehicles( true, with_moto, true )

    local px, py = 0, 0
    for i, v in pairs( pVehicles ) do
        local hover = ibCreateImage( px, py, sx, sy, nil, scrollpane, 0x0cffffff ):ibData( "alpha", 0 )
            :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )

        ibCreateImage( px+30, py+sy/2-16, 49, 33, ":nrp_shop/img/icon_vehicle.png", scrollpane ):ibData( "disabled", true )
        ibCreateLabel( px+100, py, 0, sy, VEHICLE_CONFIG[ v.model ].model, scrollpane, 0xffffffff, _, _, "left", "center", ibFonts.regular_16 ):ibData("disabled", true)

        ibCreateButton( sx-152, py+sy/2-19, 126, 38, scrollpane, ":nrp_shop/img/btn_select.png", ":nrp_shop/img/btn_select_hover.png", ":nrp_shop/img/btn_select_hover.png" )
            :ibOnHover( function( ) hover:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) hover:ibAlphaTo( 0, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                
                OnSelect( v )
            end )
        
        ibCreateImage( 30, py+sy-1, sx-60, 1, nil, scrollpane, 0xff59616a )

        py = py + sy
    end

    scrollpane:AdaptHeightToContents( )
    scrollbar:UpdateScrollbarVisibility( scrollpane )
end

function CreateHideButton( parent )
    ibCreateImage( 0, 0, 0, 0, ":nrp_shop/img/btn_notification_hide.png", parent )
        :ibSetRealSize( )
        :center_x( )
        :ibData( "alpha", ibGetAlpha( 75 ) )
        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
        :ibOnLeave( function( ) source:ibAlphaTo( ibGetAlpha( 75 ), 200 ) end )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            HideOverlay( parent )
        end )
end

function HideOverlay( overlay )
    if UI.overlays then
        UI.overlays[ overlay ] = nil
    end

    overlay
        :ibData( "disabled", true )
        :ibMoveTo( _, overlay:height( ), 150 )

    overlay.parent
        :ibTimer( destroyElement, 150, 1 )
end

function IsAnyOverlayVisible( )
    return UI.overlays and next( UI.overlays ) and true
end