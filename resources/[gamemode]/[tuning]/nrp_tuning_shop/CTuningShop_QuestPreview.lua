function onTuningPreviewStart_handler( vehicle )
    CreateInitialData( )

    local vehicle = localPlayer.vehicle
    vehicle.frozen = true

    local parts = exports.nrp_tuning_internal_parts:getTuningPartsIDByParams( { category = 4, subtype = 1 } )

    DATA = {
        vehicle                     = vehicle,
        color                       = { getVehicleColor( vehicle, true ) },
        parts                       = { },
        default_stats               = { vehicle:GetStats( ) },
        now_stats                   = { vehicle:GetStats( ) },
        wheels                      = false,
        hydraulics                  = false,
        headlights_color            = { 255, 255, 255 },
        height_level                = 0,

        subscription                = false,
        is_subscription_vehicle     = false,
        installed_parts             = { },
        position                    = localPlayer.position + Vector3( 0, 0, 100 )
    }

    setElementData( localPlayer, "isWithinTuning", true, false )
    DisableHUD( true )

    UI_elements.music = playSound( "sfx/music_tuning.ogg", true )
    UI_elements.music.volume = 0.2

    CreateMap( )
    CreatePreview( )
    StartPreview( )

    -- Стата машины
    CreateBottombar( )
    HideBottombar( true )
    ShowBottombar( )

    -- Левая панель с деталями
    CreatePartsMenu( )
    HidePartsMenu( true )
    ShowPartsMenu( )

    function addPart( id )
        local part = getTuningPartByID( id )

        DATA.installed_parts[ part.type ] = { id = id }
        DATA.new_stats = { DATA.vehicle:GetStats( DATA.installed_parts ) }
        UpdatePartsMenu( )
        RefreshBottomBar( )
        setSoundVolume( playSound( ":nrp_tuning_shop/sfx/install1.mp3" ), 0.5 )
    end

    setTimer( function( )
        DATA.vehicle:SetColor( 100, 0, 0 )
        setSoundVolume( playSound( ":nrp_tuning_shop/sfx/spray.mp3" ), 1.0 )
    end, 2250, 1 )

    for i, v in pairs( parts ) do
        setTimer( addPart, 2000 + i * 1500, 1, v )
    end

    setTimer( triggerServerEvent, 2000 + ( #parts + 1 ) * 1500 , 1, "jeka_testdrive_step_6", localPlayer )
end
addEvent( "onTuningPreviewStart", true )
addEventHandler( "onTuningPreviewStart", root, onTuningPreviewStart_handler )

function onTuningPreviewStop_handler( )
    local vehicle = localPlayer.vehicle

    if vehicle then
        ShowTuningShopUI( false )
        vehicle.frozen = false
    end

    setCameraTarget( localPlayer )

end
addEvent( "onTuningPreviewStop", true )
addEventHandler( "onTuningPreviewStop", root, onTuningPreviewStop_handler )