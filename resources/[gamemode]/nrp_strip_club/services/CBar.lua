BAR_DATA =
{
    skin_id = 304,
    position = Vector3( -41.4737, -93.1494, 1372.6600 ),
    rotation = 180,
    interior = 1,
    dimension = 1,
    action_id = 0,

    bar_area = { -36.6272, -95.5396, -47.6233, -95.5396, -47.6233, -93.8021, -36.6272, -93.5396, -36.6272, -95.5396 },
}

local reset_alcohol_anim =
{
	[ "F1" ] = true,
	[ "F2" ] = true,
	[ "F4" ] = true,
	[ "F6" ] = true,
	[ "F9" ] = true,
	[ "F10" ] = true,
}

function InitBar()
    BAR_DATA.barmen = CreateAIPed( BAR_DATA.skin_id, BAR_DATA.position, BAR_DATA.rotation )
    BAR_DATA.barmen.dimension = BAR_DATA.dimension
    BAR_DATA.barmen.interior = BAR_DATA.interior
    setPedWalkingStyle( BAR_DATA.barmen, 132 )
    SetUndamagable( BAR_DATA.barmen, true )
    MoveBarmen()

    BAR_DATA.area = createColPolygon( unpack( BAR_DATA.bar_area ) )
    BAR_DATA.area.dimension = BAR_DATA.dimension
    BAR_DATA.area.interior = BAR_DATA.interior
    AddService( BAR_DATA.area, ShowBarUI, "Нажмите “ALT”, чтобы открыть бар" )

    if not isTimer( ALCOHOL_INTOXICATION_TIMER ) then
        ALCOHOL_INTOXICATION_TIMER = setTimer( onChangeAlcoholIntoxication, ALCOHOL_INTOXICATION_TIMER_TIME, 0 )
    end

    removeEventHandler("onClientKey", root, OnClientKey_handler)
    addEventHandler("onClientKey", root, OnClientKey_handler)
end

function DestroyBar()
    if isTimer( BAR_DATA.barmen_timer ) then
        killTimer( BAR_DATA.barmen_timer )
        BAR_DATA.barmen_timer = nil
    end
    
    if isElement( BAR_DATA.barmen ) then
        StopMoveBarmen()
        BAR_DATA.barmen:destroy()
        BAR_DATA.barmen = nil
        
        BAR_DATA.area:destroy()
        BAR_DATA.area = nil
    end

    ShowBarUI( false )

    for k, v in ipairs( ALCOHOL_INTOXICATION or {} ) do
        if v.player ~= localPlayer then
            ResetAlcoholIntoxication( v.player )
        else
            localPlayer:setData( "alcohol_effect", true, false )
        end
    end
    if isTimer( ALCOHOL_INTOXICATION_TIMER ) then
        killTimer( ALCOHOL_INTOXICATION_TIMER )
    end
    
    localPlayer:ResetAlcoholWalkStyle()
    setCameraShakeLevel( 0 )
    removeEventHandler("onClientKey", root, OnClientKey_handler)
end


function OnClientKey_handler( key, state )
    if reset_alcohol_anim[ key ] and not state then
        setTimer( function()
            localPlayer:CreateAlcoholWalkStyle()
        end, 1000, 1 )
	end
end

function MoveBarmen()
    if not isElement( BAR_DATA.barmen ) then return end
    
    local action_id = 0
    repeat
        action_id = math.random( 1, 3 )
    until action_id ~= BAR_DATA.action_id

    BAR_DATA.action_id = action_id
    setPedAnimation( BAR_DATA.barmen, nil )
    
    -- Приватный танец
    if localPlayer.dimension ~= BAR_DATA.barmen.dimension or not isElementStreamedIn( BAR_DATA.barmen ) then
        BAR_DATA.barmen_timer = setTimer( MoveBarmen, 10000, 1 )
        return
    end
    
    local animation_list = { "shift", "shldr", "stretch", "strleg", "time" }
    -- Идти к стойке вправо по кругу
    if BAR_DATA.action_id == 1 then
        SetAIPedMoveByRoute( BAR_DATA.barmen, {
            { x = -45.9861, y = -93.1477, z = 1372.6600, distance = 1, move_type = 4 },
        }, false, function( )
            setElementRotation( BAR_DATA.barmen, 0, 0, 180 )
            setPedAnimation( BAR_DATA.barmen, "playidles", animation_list[ math.random(1, #animation_list)] )
            BAR_DATA.barmen_timer = setTimer( MoveBarmen, 10000, 1 )
        end )
    -- Идти к стойке влево
    elseif BAR_DATA.action_id == 2 then
        SetAIPedMoveByRoute( BAR_DATA.barmen, {
            { x = -40.9618, y = -93.1480, z = 1372.6600, distance = 1, move_type = 4 },
        }, false, function( )
            setElementRotation( BAR_DATA.barmen, 0, 0, 180 )
            setPedAnimation( BAR_DATA.barmen, "playidles", animation_list[ math.random(1, #animation_list)] )
            BAR_DATA.barmen_timer = setTimer( MoveBarmen, 10000, 1 )
        end )
    -- Воспроизвести анимку
    elseif BAR_DATA.action_id == 3 then
        SetAIPedMoveByRoute( BAR_DATA.barmen, {
            { x = -38.1996, y = -93.1495, z = 1372.6600, distance = 1, move_type = 4 },
        }, false, function( )
            setElementRotation( BAR_DATA.barmen, 0, 0, 180 )
            setPedAnimation( BAR_DATA.barmen, "playidles", animation_list[ math.random(1, #animation_list)] )
            BAR_DATA.barmen_timer = setTimer( MoveBarmen, 10000, 1 )
        end )
    end
end

function StopMoveBarmen()
    if isElement( BAR_DATA.barmen ) then
        ResetAIPedPattern( BAR_DATA.barmen )
        removePedTask( BAR_DATA.barmen )
    end
end

----------------------------------------------
-- Функционал обработки степени опьянения
----------------------------------------------

ALCOHOL_INTOXICATION = {}
ALCOHOL_INTOXICATION_TIMER = nil
ALCOHOL_INTOXICATION_TIMER_TIME = 5000
ALCOHOL_INTOXICATION_OFF_CONTROLS = { "sprint", "jump", "crouch", "walk" }

BLUR_SHADER = nil
BLUR_SCREEN_SOURCE = nil
BLUR_STRENGTH = 30

function onChangeAlcoholIntoxication()
    for k, v in ipairs( ALCOHOL_INTOXICATION or {} ) do
        v.intexiation = v.intexiation - ALCOHOL_INTOXICATION_TIMER_TIME / 1000
        
        if v.intexiation <= 0 then
            ResetAlcoholIntoxication( v.player )
        elseif v.intexiation >= ALCOHOL_INTOXICATION_LEVELS[ ALCOHOL_INTOXICATION_DEATH ] then
            ResetAlcoholIntoxication( v.player )
            if v.player == localPlayer then
                ResetAlcoholIntoxication( localPlayer )
                DestroyStripClub()
                showCursor( false )

                fadeCamera( false, 0 )
                setTimer( function()
                    triggerServerEvent( "onServerPlayerLostConsciousness", localPlayer )
                end, 150, 1)
            end
        elseif v.player == localPlayer then
            local shake_level = math.ceil( math.min( 120, v.intexiation / 4 ) )
            setCameraShakeLevel( shake_level )
            BLUR_STRENGTH = math.max( 0, math.ceil( shake_level / 16 ) )
            
            if STRIP_DATA and isElement( STRIP_DATA.background_sound ) then
                STRIP_DATA.background_sound.speed = 1 - shake_level / 350
                if PRIVATE_DANCE and isElement( PRIVATE_DANCE.background_sound ) then
                    PRIVATE_DANCE.background_sound.speed = 1 - shake_level / 350
                end
            end
        end

        if v.intexiation < ALCOHOL_INTOXICATION_LEVELS[ ALCOHOL_INTOXICATION_STRONG ] then
            v.player:ResetAlcoholWalkStyle()
        elseif v.intexiation >= ALCOHOL_INTOXICATION_LEVELS[ ALCOHOL_INTOXICATION_STRONG ] then
            v.player:CreateAlcoholWalkStyle()
        end

        if v.player == localPlayer then
            if not v.currentLevelNum then v.currentLevelNum = 0 end -- for triggerServerEvent

            local levelNum = 0
            if v.intexiation > 0 then
                levelNum = 1

                for num, level in ipairs( ALCOHOL_INTOXICATION_LEVELS ) do
                    if v.intexiation >= level then
                        levelNum = num
                    end
                end
            end

            if levelNum ~= v.currentLevelNum then
                v.currentLevelNum = levelNum -- save
                triggerServerEvent( "onPlayerChangeAlcoIntexiation", localPlayer, levelNum, v.intexiation )
            end
        end
    end
end

function AddDegreeIntoxication( player, alcohol_id )
    local add = false
    for k, v in ipairs( ALCOHOL_INTOXICATION ) do
        if v.player == player then
            v.intexiation = (v.intexiation or 0) + DRINKS[ alcohol_id ].intoxication
            add = true
            break
        end
    end
    if not add then
        table.insert( ALCOHOL_INTOXICATION, {
            player = player,
            intexiation = DRINKS[ alcohol_id ].intoxication,
        })
    end

    onChangeAlcoholIntoxication()

    if player == localPlayer and not BLUR_SHADER then
        CreateAlcoholShaderIntoxication()
    end
end

function CreateAlcoholShaderIntoxication()
    if isElement( BLUR_SHADER ) then return end
    BLUR_SHADER = dxCreateShader( "files/fx/blur.fx" )
    if isElement( BLUR_SHADER ) then
        if not isElement( BLUR_SCREEN_SOURCE ) then
            BLUR_SCREEN_SOURCE = dxCreateScreenSource( scX, scY )
            dxSetShaderValue( BLUR_SHADER, "ScreenSource", BLUR_SCREEN_SOURCE )
            dxSetShaderValue( BLUR_SHADER, "UVSize", scX, scY )
            removeEventHandler("onClientPreRender", root, DrawBlurEffect )
            addEventHandler("onClientPreRender", root, DrawBlurEffect )
        end
    end
end

function DrawBlurEffect()
    if isElement( BLUR_SCREEN_SOURCE ) and isElement( BLUR_SHADER ) then
        dxUpdateScreenSource( BLUR_SCREEN_SOURCE )
        dxSetShaderValue( BLUR_SHADER, "BlurStrength", BLUR_STRENGTH )
        dxDrawImage( 0, 0, scX, scY, BLUR_SHADER )
    end
end

function DestroyAlcoholShaderIntoxication()
    removeEventHandler("onClientPreRender", root, DrawBlurEffect )
    if isElement( BLUR_SHADER ) then
        destroyElement( BLUR_SHADER )
        BLUR_SHADER = nil
    end

    if isElement( BLUR_SCREEN_SOURCE ) then
        destroyElement( BLUR_SCREEN_SOURCE )
        BLUR_SCREEN_SOURCE = nil
    end

    BLUR_STRENGTH = 0
end

function ResetAlcoholIntoxication( player, is_quit )
    for k, v in ipairs( ALCOHOL_INTOXICATION ) do
        if v.player == player then
            table.remove( ALCOHOL_INTOXICATION, k )
            break
        end
    end

    if #ALCOHOL_INTOXICATION == 0 and not isElement( BAR_DATA.barmen ) then
        if isTimer( ALCOHOL_INTOXICATION_TIMER ) then
            killTimer( ALCOHOL_INTOXICATION_TIMER )
            ALCOHOL_INTOXICATION_TIMER = nil
        end
        ALCOHOL_INTOXICATION = {}
    end

    if is_quit then return end

    player:ResetAlcoholWalkStyle()
    if player == localPlayer then
        DestroyAlcoholShaderIntoxication()
        if isElement( STRIP_DATA.background_sound ) then
            STRIP_DATA.background_sound.speed = 1
        end
        if localPlayer.dimension ~= 0 then
            setCameraShakeLevel( 1 )
        else
            setCameraShakeLevel( 0 )
        end
        setCameraTarget( localPlayer )
    end
end

addEventHandler( "onClientPlayerQuit", root, function()
    ResetAlcoholIntoxication( source, true )
end )

addEvent( "onClientPlayerBuyAlcohol", true )
addEventHandler( "onClientPlayerBuyAlcohol", root, function( alcohol_id )
    AddDegreeIntoxication( source, alcohol_id )
end )

addEvent( "onClientPlayerWokeUp", true )
addEventHandler( "onClientPlayerWokeUp", resourceRoot, function( )
    localPlayer.frozen = true
    
    localPlayer:setAnimation( "sunbathe", "sbathe_f_lieb2sit", -1, false, false, false, true )
    localPlayer:ShowInfo( "Вы потеряли сознание и охрана вывела Вас из клуба!")
    setTimer( function()
		setTimer( function()
            localPlayer:setAnimation( "sunbathe", "sbathe_f_out", -1, false, false, false, false )
            setTimer( function()
                localPlayer.frozen = false
            end, 2100, 1 )
		end, 1450, 1 )
    end, 200, 1 )
    setTimer( fadeCamera, 400, 1, true, 2.0 )
end )

Player.CreateAlcoholWalkStyle = function( self )
    local is_exist = false
    for k, v in ipairs( ALCOHOL_INTOXICATION ) do
        if v.player == self then
            is_exist = true
            if v.intexiation <= 0 then
                return
            end
            break
        end
    end
    if not is_exist then return end

    setPedWalkingStyle( self, 126 )
    if self == localPlayer then
        for k, v in pairs( ALCOHOL_INTOXICATION_OFF_CONTROLS ) do
            toggleControl( v, false )
        end
        setControlState( "walk", true )
        self:setData( "walkstyle", 126, false )
    end
end

Player.ResetAlcoholWalkStyle = function( self )
    setPedWalkingStyle( self, 118 )
    if self == localPlayer then
        for k, v in pairs( ALCOHOL_INTOXICATION_OFF_CONTROLS ) do
            toggleControl( v, true )
        end
        if self:getData( "walkstyle" ) == 126 then
            self:setData( "walkstyle", nil, false )
        end
    end
end