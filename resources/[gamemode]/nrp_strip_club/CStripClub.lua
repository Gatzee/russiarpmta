loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "CInterior" )
Extend( "CPlayer" )
Extend( "ib" )
Extend( "CAI" )
Extend( "ShUtils" )

ibUseRealFonts( true )

UI_elements = {}
scX, scY = guiGetScreenSize()

SERVICES = {}
START_RESOURCE_TIMESTAMP = nil
CURRENT_STRIP_ID = nil

OFF_CONTROLS = { "forwards", "backwards", "left", "right", "walk" }

----------------------------------------------
-- Обработчик старта, входа/выхода из стрипухи
----------------------------------------------

addEventHandler( "onClientResourceStart", resourceRoot, function()
    engineLoadIFP( "files/ifp/strip_dance.ifp", IFP_STRIP_BLOCK_NAME )
    STRIP_CLUB_COLSHAPE = createColCuboid( STRIP_CLUB_ZONE.position, STRIP_CLUB_ZONE.size )    
    createEnterMarkers()
end )

function onTryEnterStripClub( tpoint )
    if isElement( STRIP_DATA.confirmation ) then
        STRIP_DATA.confirmation:destroy()
    end

    if localPlayer:GetBlockInteriorInteraction() then
        localPlayer:ShowInfo( "Вы не можете войти во время задания" )
        return false
    end

    STRIP_DATA.confirmation = ibConfirm(
    {
        title = "СТРИП КЛУБ", 
        text = "Вы хотите войти в стрип клуб за " .. ENTER_PRICE .. "р.?" ,
        fn = function( self )
            if localPlayer:GetMoney() < ENTER_PRICE then
                localPlayer:ShowError( "У вас недостаточно средств для входа" )
            else
                triggerServerEvent( "onServerPlayerWantEnterStripClub", localPlayer, tpoint.strip_id )
            end
            showCursor( false )
            self:destroy()
        end,
        fn_cancel = function( self )
            showCursor( false ) 
        end,
        escape_close = true,
    } )
    
    showCursor( true )
end

function createEnterMarkers()
    local outside_conf = 
    {
        x = -47.72,
        y = -120.08,
        z = 1372.66,
        text = "ALT Взаимодействие",
        marker_text = "Выход",
        keypress = "lalt",
        radius = 2,
    }

    for k, conf in pairs( STRIP_DATA ) do
        local inside_point = TeleportPoint( conf )
        inside_point.PreJoin = conf.inside_check
        inside_point.PostJoin = onTryEnterStripClub
        inside_point.PostLeave = CloseConfirmUi

        inside_point.marker:setColor( 245, 128, 245, 50 )
        inside_point.text = "ALT Взаимодействие"
        inside_point.strip_id = k

        inside_point:SetImage( "files/img/marker.png" )
        inside_point.element:setData( "material", true, false )
        inside_point:SetDropImage( { ":nrp_shared/img/dropimage.png", 245, 128, 245, 255, 1.5 } )
        
        inside_point.elements = { }
        inside_point.elements.blip = createBlipAttachedTo( inside_point.marker, 0, 2, 255, 255, 255, 255, 0, 200 )
        setElementData( inside_point.elements.blip, 'extra_blip', 66, false )

        outside_conf.x = conf.inside_position.x
        outside_conf.y = conf.inside_position.y
        outside_conf.z = conf.inside_position.z
        
        outside_conf.interior = conf.inside_int
        outside_conf.dimension = conf.insdie_dim
        outside_conf.outside = conf.outside_position

        local outside_point = TeleportPoint( outside_conf )
        outside_point.element:setData( "material", true, false )
        outside_point:SetDropImage( { ":nrp_shared/img/dropimage.png", 245, 128, 245, 255, 1.55 } )
        outside_point.marker:setColor( 245, 128, 245, 50 )
        outside_point.strip_id = k
        outside_point.PostJoin  = function( tpoint )
            onPlayerWantLeaveStripClub( tpoint )
        end
        outside_point.PostLeave = CloseConfirmUi
    end
end

function onClientPlayerEnterStripClub_handler( strip_id, pay_leaders, podium_dance_data, start_resource_timestamp )
    InitStripClub( pay_leaders, strip_id, start_resource_timestamp )

    if podium_dance_data then
        onClientStartPodiumDance_handler( podium_dance_data )
    end

    setCameraShakeLevel( 0 )
    setCameraTarget( localPlayer )
end
addEvent( "onClientPlayerEnterStripClub", true )
addEventHandler( "onClientPlayerEnterStripClub", resourceRoot, onClientPlayerEnterStripClub_handler )

function CloseConfirmUi( )
    if STRIP_DATA.confirmation then
        STRIP_DATA.confirmation:destroy()
        showCursor( false ) 
    end
end

function onPlayerWantLeaveStripClub( tpoint )
    if isElement( STRIP_DATA.confirmation ) then
        STRIP_DATA.confirmation:destroy()
    end

    STRIP_DATA.confirmation = ibConfirm(
    {
        title = "СТРИП КЛУБ", 
        text = "Вы действительно хотите выйти?" ,
        fn = function( self )
            DestroyStripClub()
                    
            fadeCamera( false, 0 )
            if isTimer( ALCOHOL_INTOXICATION_TIMER ) then
                killTimer( ALCOHOL_INTOXICATION_TIMER )
            end

            setCameraShakeLevel( 0 )
            setCameraTarget( localPlayer )


            triggerServerEvent( "onServerPlayerWantLeaveStripClub", resourceRoot, tpoint.strip_id )
            setTimer( fadeCamera, 250, 1, true, 1 )
            
            showCursor( false )
            self:destroy()
        end,
        fn_cancel = function( self ) 
	        showCursor( false ) 
        end,
        escape_close = true,
    })

    showCursor( true )
end

----------------------------------------------
-- Обработчик инициализации стрипухи
----------------------------------------------

function InitStripClub( pay_leaders, strip_id, start_resource_timestamp )
    DestroyStripClub()
    CURRENT_STRIP_ID = strip_id
    START_RESOURCE_TIMESTAMP = start_resource_timestamp
    localPlayer:setData( "in_strip_club", true, false )

    InitBar()
    InitPodium()
    InitPrivate()
    DestroyWaitresses()
    CreateTvPayLeaders( pay_leaders )

    setTimer( function()
        InitWaitresses()
    end, 1000, 1 )

    addEventHandler( "onClientElementColShapeHit", localPlayer, onClientElementColshapeHit_handler )
    addEventHandler( "onClientElementColShapeLeave", localPlayer, onClientElementColShapeLeave_handler )
    addEventHandler( "onClientPlayerWasted", localPlayer, onClientPlayerWasted_handler )
end

function DestroyStripClub()
    removeEventHandler( "onClientElementColShapeHit", localPlayer, onClientElementColshapeHit_handler )
    removeEventHandler( "onClientElementColShapeLeave", localPlayer, onClientElementColShapeLeave_handler )
    removeEventHandler( "onClientPlayerWasted", localPlayer, onClientPlayerWasted_handler )
    localPlayer:setData( "in_strip_club", nil, false )

    DestroyBar()
    DestroyPodium()
    DestroyPrivate()
    DestroyWaitresses()
    DestroyTvPayLeaders()
    STORE_PODIUM_DATA = nil
    CURRENT_STRIP_ID = nil

    localPlayer.frozen = false
    localPlayer:setAnimation()
    setElementCollisionsEnabled( localPlayer, true )
    for k, v in pairs( OFF_CONTROLS ) do
        toggleControl( v, true )
    end

    if isElement( STRIP_DATA.background_sound ) then
        destroyElement( STRIP_DATA.background_sound )
    end
    showCursor( false )
    setCursorAlpha( 255 )
    fadeCamera( true, 0 )
end
addEventHandler( "onClientResourceStop", resourceRoot, DestroyStripClub )

function onClientPlayerWasted_handler()
    ResetAlcoholIntoxication( localPlayer )
    DestroyStripClub()
end

----------------------------------------------
-- Обработка сервисов
----------------------------------------------

function ActivateService( _, _, service_area )
    SERVICES[ service_area ].callback( true, STRIP_DATA.data )
    SERVICES[ service_area ].leave_callback()
end

function AddService( service_area, callback, help_text, check_func )
    SERVICES[ service_area ] = {} 
    
    SERVICES[ service_area ].callback = callback
    SERVICES[ service_area ].enter_callback = function()
        if SERVICES[ service_area ].check_func and not SERVICES[ service_area ].check_func() then
            unbindKey( "lalt", "down", ActivateService )
            triggerEvent( "HideStripClubInfo", localPlayer )
            return 
        end
        unbindKey( "lalt", "down", ActivateService )
        bindKey( "lalt", "down", ActivateService, service_area )
        triggerEvent( "ShowStripClubInfo", localPlayer, help_text )
    end
    SERVICES[ service_area ].leave_callback = function()
        unbindKey( "lalt", "down", ActivateService )
        triggerEvent( "HideStripClubInfo", localPlayer )
    end
    SERVICES[ service_area ].check_func = check_func
end

function onClientElementColshapeHit_handler( colshape )
    if not SERVICES[ colshape ] then return end
    SERVICES[ colshape ].enter_callback()
end

function onClientElementColShapeLeave_handler( colshape )
    if not SERVICES[ colshape ] then return end
    SERVICES[ colshape ].leave_callback()
end

function onCloseUI( player )
    if player == localPlayer and ALCOHOL_INTOXICATION[ player ] and ALCOHOL_INTOXICATION[ player ] >= ALCOHOL_INTOXICATION_LEVELS[ ALCOHOL_INTOXICATION_STRONG ] then
        player:CreateAlcoholWalkStyle( player )
    end
end

function PauseAIEvents()
    StopMoveBarmen()
    StopMoveWaitresses()
    if PODIUM_DANCE and PODIUM_DANCE.original_data then
        STORE_PODIUM_DATA = table.copy( PODIUM_DANCE.original_data )
        PODIUM_DANCE:destroy_dance()
    end
end

function OnAIEvents()
    if STORE_PODIUM_DATA then
        onClientStartPodiumDance_handler( STORE_PODIUM_DATA )
        STORE_PODIUM_DATA = nil
    end
end

-----------------------------------
-- Утилиты
-----------------------------------

Player.IsHasMoney = function( self, value, currency )
    if currency == "soft" then
		return self:GetMoney() >= value
	elseif currency == "hard" then
        return self:GetDonate() >= value
	end
end

function ChangeBackgroundSound( sound_id )
    if isElement( STRIP_DATA.background_sound ) then
        destroyElement( STRIP_DATA.background_sound )
    end
    STRIP_DATA.background_sound = playSound( "files/sfx/music_striptease_" .. sound_id .. ".ogg", true )
    STRIP_DATA.background_sound.speed = 1 - getCameraShakeLevel() / 350
    STRIP_DATA.background_sound.volume = 0.5
end

COUNTER = {}
function SetAIPedMoveByDuration( ped, path, in_vehicle, start_timestamp, callback )
    if not isElement( ped ) or (COUNTER[ ped ] and COUNTER[ ped ] > 80) then 
        COUNTER[ ped ] = nil
        return 
    end

    if #path == 0 then return end
    local originial_path = table.copy( path )

    local timestamp = getRealTimestamp()
    local passed_duration = timestamp - start_timestamp

    local target_path = {}
    local prev_duration = 0    
    for k, v in ipairs( path ) do
        if passed_duration < v.duration then
            table.insert( target_path, v )
        else
            prev_duration = v.duration
            ped.position = Vector3( v.x, v.y, v.z )
        end
    end

    if #target_path == 0 then
        local path = originial_path[ #originial_path ]
        ped.position = Vector3( path.x, path.y, path.z )
        callback()
    else
        local end_position = target_path[ 1 ]
        local progress = passed_duration / math.abs( end_position.duration - prev_duration )
        local px, py, pz = interpolateBetween( ped.position.x, ped.position.y, ped.position.z, end_position.x, end_position.y, end_position.z, progress, "Linear" )
        ped.position = Vector3( px, py, pz )
        setTimer( function()
            if isElement( ped ) and isElementStreamedIn( ped ) then
                COUNTER[ ped ] = nil
                SetAIPedMoveByRoute( ped, target_path, in_vehicle, callback )
            end
        end, 1000, 1 )
    end
end

function SetUndamagable( element, state )
    removeEventHandler( "onClientPedDamage", element, cancelEvent )
    if state then
        addEventHandler( "onClientPedDamage", element, cancelEvent )
    end
end

addEvent( "SwitchPosition", true )
addEventHandler( "SwitchPosition", resourceRoot, function( )
    setCameraShakeLevel( 0 )
    setCameraTarget( localPlayer )

    if localPlayer:getData( "alcohol_effect" ) then
        setCameraShakeLevel( 0 )
        localPlayer:setData( "alcohol_effect", nil, false )
        setTimer( onChangeAlcoholIntoxication, 1000, 1 )
        ALCOHOL_INTOXICATION_TIMER = setTimer( onChangeAlcoholIntoxication, ALCOHOL_INTOXICATION_TIMER_TIME, 0 )
    end
end )


addEvent( "onClientClassicRouletteEnterQuit", true )
addEventHandler( "onClientClassicRouletteEnterQuit", root, function( state )
    if state and CURRENT_STRIP_ID then
        PauseAIEvents()
        STRIP_DATA.background_sound.volume = 0
    elseif not state and CURRENT_STRIP_ID then
        OnAIEvents()
        STRIP_DATA.background_sound.volume = 0.5
    end
end )