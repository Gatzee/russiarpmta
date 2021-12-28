Extend( "CActionTasksUtils" )

QUEST_RECOLOR = false

function onTuningRecolorPreviewStart_handler( vehicle )
    CreateInitialData( )

    local vehicle = localPlayer.vehicle
    vehicle.frozen = true

    local available_vinyl = {
        [ P_CLASS ]      = 3,
        [ P_NAME ]       = "girl_3",
        [ P_PRICE ]      = 500,
        [ P_PRICE_TYPE ] = "hard",
        [ P_IMAGE ]      = "girl_3",
        [ P_LAYER ]      = 2,
        [ P_LAYER_DATA ] = {
            y = 287,
            x = 486,
            rotation = 175.67693,
            mirror = true,
            size = 0.75326926
        }
    }

    DATA = {
        vehicle                 = vehicle,
        color                   = { 0, 0, 0 },
        parts                   = { },
        default_stats           = { vehicle:GetStats( ) },
        now_stats               = { vehicle:GetStats( ) },
        installed_vinyls        = { },
        available_vinyls        = { available_vinyl },
        wheels                  = false,
        hydraulics              = false,
        headlights_color        = { 255, 255, 255 },
        height_level            = 0,
        subscription            = false,
        is_subscription_vehicle = false,
        installed_parts         = { },
        position                = localPlayer.position + Vector3( 0, 0, 100 )
    }

    setElementData( localPlayer, "isWithinTuning", true, false )
    DisableHUD( true )

    UI_elements.music = playSound( "sfx/music_tuning.ogg", true )
    UI_elements.music.volume = 0.2

    CreateMap( )
    CreatePreview( )
    StartPreview( )

    -- Кнопка кейсов с винилами
    HideVinylCases( true )
    ShowVinylCases( )

    -- Продажа винилов
    CreateVinylsSell( )
    HideVinylsSell( true )
    ShowVinylsSell( )

    -- Левая панель с слоями
    CreateVinylsMenu( )
    HideVinylsMenu( true )
    ShowVinylsMenu( )

    --Панель с стилеями, инвентарём
    CreateVinylInventory( )
    HideVinylInventory( true )
    ShowVinylInventory( )

    CreateBackButton( )
    SetBackButtonGoHome( )

    local bg = ibCreateBackground( 0, _, true )
    bg:ibData( "priority", 100 )
    showCursor( true )

    setTimer( function( )
        local r, g, b = 0, 130, 180
        
        DATA.color = { r, g, b }
        UI_elements.vehicle:SetColor( r, g, b )
        RefreshDefaultColor( DATA.color )
        RefreshVehicleVinyl( DATA.installed_vinyls )

        setSoundVolume( playSound( ":nrp_tuning_shop/sfx/spray.mp3" ), 1.0 )
    end, 4000, 1 )

    setTimer( function( )
        DATA.installed_vinyls = {
            [ 12 ] = available_vinyl,
        }
        UpdateVinylsMenu( )

        DATA.available_vinyls = { }
        RefreshVinylTabContent( DATA.available_vinyls )
        RefreshVehicleVinyl( DATA.installed_vinyls )
        RefreshDefaultColor( DATA.color )

        RefreshDefaultColor( DATA.color )
        RefreshVehicleVinyl( DATA.installed_vinyls )

        setSoundVolume( playSound( ":nrp_tuning_shop/sfx/spray.mp3" ), 1.0 )
    end, 8000, 1 )

    setTimer( function( )
        bg:destroy( )

        ResetActiveButton( )
        QUEST_RECOLOR = true

        local ticks = getTickCount()
        QUEST_HINT = CreateSutiationalHint( {
			text = "Здесь можно изменять оттенок винила",
			condition = function( )
				return getTickCount() - ticks < 10000
			end
		} )
        
        CreateVinylsSettingMenu( { current_vinyl_id = 12, back_button_callback = function( )
            onTuningPreviewEnd( )
        end } )

        HideVinylsSettingMenu( true )
        ShowVinylsSettingMenu( )
    end, 12000, 1 )

    --setTimer( onTuningPreviewEnd, 30000, 1 )
end
addEvent( "onTuningRecolorPreviewStart", true )
addEventHandler( "onTuningRecolorPreviewStart", root, onTuningRecolorPreviewStart_handler )

function onTuningPreviewEnd( )
    QUEST_RECOLOR = false
    if QUEST_HINT then QUEST_HINT:destroy() end

    triggerServerEvent( "alexander_debt_step_8", localPlayer )
    --onTuningRecolorPreviewStop_handler( )
end

function onTuningRecolorPreviewStop_handler( )
    QUEST_RECOLOR = false
    if QUEST_HINT then QUEST_HINT:destroy() end

    local vinyls = nil
    local vehicle = localPlayer.vehicle
    if vehicle then
        vinyls = table.copy( DATA.installed_vinyls )
        ShowTuningShopUI( false )
        vehicle.frozen = false
    end

    setCameraTarget( localPlayer )
    localPlayer:Teleport( nil, localPlayer:GetUniqueDimension( ) )
    
    if vehicle and vinyls then
        triggerServerEvent( "onServerCompleteApplyVinyls", resourceRoot, vinyls )
    end
end
addEvent( "onTuningRecolorPreviewStop", true )
addEventHandler( "onTuningRecolorPreviewStop", root, onTuningRecolorPreviewStop_handler )