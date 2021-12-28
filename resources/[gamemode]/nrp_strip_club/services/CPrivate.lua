
PRIVATE_DANCE = nil
STORE_PODIUM_DATA = nil
PRIVATE_DATA =
{
    interior = 1,
    dimension = 1,

    marker_position = Vector3( -46.1555, -113.1809, 1372.6601 ),
    marker_radius = 2,
}

function InitPrivate()
    local config = {}
    config.keypress = "lalt"
	config.radius = 2
	config.marker_text = "Приватный танец"
    config.x, config.y, config.z = -46.1555, -113.1809, 1372.6601
    config.dimension = 1
    config.interior = 1
    config.text = "ALT Взаимодействие"

	PRIVATE_DATA.marker_point = TeleportPoint(config)
    PRIVATE_DATA.marker_point.marker:setColor( 245, 128, 245, 50 )

    PRIVATE_DATA.marker_point:SetImage( "files/img/private/marker.png" )
	PRIVATE_DATA.marker_point.element:setData( "material", true, false )
    PRIVATE_DATA.marker_point:SetDropImage( { ":nrp_shared/img/dropimage.png", 245, 128, 245, 255, 1.55 } )

    PRIVATE_DATA.area = createColSphere( PRIVATE_DATA.marker_position, PRIVATE_DATA.marker_radius )
    PRIVATE_DATA.area.dimension = PRIVATE_DATA.dimension
    PRIVATE_DATA.area.interior = PRIVATE_DATA.interior

    PRIVATE_DATA.marker_point.PostLeave = function ( )
        ShowPrivateUI( false )
    end
    
    AddService( PRIVATE_DATA.area, function()
        triggerServerEvent( "onServerPlayerWantOpenPrivateDance", localPlayer )  
    end, "Нажмите “ALT”, чтобы открыть меню\nприватного танца" )
end

function DestroyPrivate()
    if isElement( PRIVATE_DATA.area ) then
        PRIVATE_DATA.marker_point:destroy()
        PRIVATE_DATA.marker_point = nil
        PRIVATE_DATA.area:destroy()
        PRIVATE_DATA.area = nil
    end
    if PRIVATE_DANCE then
        PRIVATE_DANCE:destroy_dance()
    end
    ShowPrivateUI( false )
end

addEvent( "onClientPlayerBuyPrivateDance", true )
addEventHandler( "onClientPlayerBuyPrivateDance", resourceRoot, function( girl_id, dimension )
    PauseAIEvents()
    if PODIUM_DANCE and PODIUM_DANCE.original_data then
        STORE_PODIUM_DATA = table.copy( PODIUM_DANCE.original_data )
        PODIUM_DANCE:destroy_dance()
    end
    if PRIVATE_DANCE then
        PRIVATE_DANCE:destroy_dance()
        PRIVATE_DANCE = nil
    end

    ShowPrivateUI( false )
    onClientStopStartPrivateDacne_handler( true, dimension )
    PRIVATE_DANCE = CreatePrivateDance( girl_id )
    PRIVATE_DANCE:start_dance()
end )

function onClientStopStartPrivateDacne_handler( state, dimension )
    if state then
        localPlayer:Teleport( PRIVATE_DANCE_PLAYER_POSITION, dimension )
    else
        OnAIEvents( )
        localPlayer:Teleport( FINISH_PRIVATE_DANCE_PLAYER_POSITION, 1 )
    end
end
addEvent( "onClientStopStartPrivateDacne", true )
addEventHandler( "onClientStopStartPrivateDacne", resourceRoot, onClientStopStartPrivateDacne_handler ) 

----------------------------------------------
-- Функционал приватного танца
----------------------------------------------

PRIVATE_DANCE_DURATION = 60000

function CreatePrivateDance( girl_id )
    local self  = {}
    
    self.camera = {}
    self.camera.pos = Vector3( 1.547, 1.547, 0.1 )
    self.camera_property = { -52.144901275635, -114.32289886475, 1372.8311767578, -52.14697265625, -113.32289886475, 1372.8311767578, 0, 70, }
    
    self.camera.min_x = -52.5
    self.camera.max_x = -51.8

    self.camera.min_z = 1372.4
    self.camera.max_z = 1373.3
    
    self.cx, self.cy = 0.5, 0.5

    self.start_dance = function( self )
        localPlayer.frozen = true
        localPlayer.rotation = Vector3( 0, 0, 0 )
        setPedCameraRotation( localPlayer, 90 )
        localPlayer:setAnimation( "ped", "seat_idle", -1, true, false, false, false )
        setElementCollisionsEnabled( localPlayer, false )
        for k, v in pairs( OFF_CONTROLS ) do
            toggleControl( v, false )
        end

        showCursor( true )
        setCursorAlpha( 0 )
        setCursorPosition( scX / 2, scY / 2 )
        setCameraMatrix( unpack( self.camera_property ) )
        
        removeEventHandler( "onClientPreRender", root, MoveFirstPersonCamera )
        addEventHandler( "onClientPreRender", root, MoveFirstPersonCamera )

        ChangeBackgroundSound( 1 )

        self.girl = CreateAIPed( GIRL_MODELS[ girl_id ], Vector3( -52.1594, -112.0719, 1372.6600 ), 180 )
        self.girl.interior = localPlayer.interior
        self.girl.dimension = localPlayer.dimension
        self.girl:setAnimation( IFP_STRIP_BLOCK_NAME, "private", -1, true, true, true, true )

        self.timer_fade = setTimer( fadeCamera, 250, 1, true, 1 )
        self.timer_destroy = setTimer( function()
            self:destroy_dance()
        end, PRIVATE_DANCE_DURATION, 1 )
    end
    
    self.destroy_dance = function( self )
        showCursor( false )
        setCursorAlpha( 255 )
        removeEventHandler( "onClientPreRender", root, MoveFirstPersonCamera )
        
        if isTimer( self.timer_fade ) then
            killTimer( self.timer_fade )
        end

        if isTimer( self.timer_destroy ) then
            killTimer( self.timer_destroy )
        end

        if isElement( self.girl ) then
            ResetAIPedPattern( self.girl )
            removePedTask( self.girl )
            destroyElement( self.girl )
        end
        
        setElementCollisionsEnabled( localPlayer, true )
        for k, v in pairs( OFF_CONTROLS ) do
            toggleControl( v, true )
        end
        onCloseUI( localPlayer )
        localPlayer.frozen = false
        
        DestroyTableElements( self )
        ChangeBackgroundSound( 2 )

        triggerServerEvent( "onServerPlayerFinishWatchPrivateDance", localPlayer )
        self = nil
        PRIVATE_DANCE = nil
    end
    
    return self
end

function MoveFirstPersonCamera()
    local cx, cy = getCursorPosition()

    local pCamera = getCamera()

    local rz = interpolateBetween( 30, 0, 0, -30, 0, 0, cx, "Linear" )
	local rx = interpolateBetween( 15, 0, 0, -35, 0, 0, cy, "Linear" )
    
    local vrx, vry, vrz = getElementRotation( localPlayer )
	local crx, cry, crz = vrx + rx, vry, vrz + rz
    
	setElementRotation( pCamera, crx, cry, crz )
end