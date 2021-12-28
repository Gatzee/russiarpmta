Extend( "CPlayer" )
Extend( "CInterior" )

local bar_points =
{
    {
        id = 304,
        x = 2443.8588, y = -1320.8955, z = 2800.0732, rz = 95,
        dimension = 1,
        interior = 4,

        marker = { x = 2441.3496, y = -1320.7490, z = 2800.0732 },
    },
    {
        id = 304,
        x = 2356.1196, y = -1320.5895, z = 2800.0703, rz = 270,
        dimension = 1,
        interior = 4,

        marker = { x = 2358.3891, y = -1320.5576, z = 2800.0703 },
    },
    {
        id = 304,
        x = 2399.1613, y = -1324.5839, z = 2795.2856, rz = 0,
        dimension = 1,
        interior = 4,

        marker = { x = 2399.0754, y = -1321.0710, z = 2795.2856 },
    },
    {
        id = 305,
        x = 2397.9621, y = -1282.5362, z = 2800.4653, rz = 80,
        dimension = 1,
        interior = 4,

        marker = { x = 2395.8435, y = -1281.6773, z = 2800.4653 },
    },
    {
        id = 305,
        x = 2400.3425, y = -1282.6142, z = 2800.4653, rz = 274,
        dimension = 1,
        interior = 4,

        marker = { x = 2402.7231, y = -1282.8886, z = 2800.4653 },
    },

    -- Rublevo
    {
        id = 304,
        x = -92.2961, y = -490.1893, z = 913.9721, rz = 270,
        dimension = 1,
        interior = 1,

        marker = { x = -90.0636, y = -490.4181, z = 913.9721 },
    },
}

local alcohol_intoxication = nil
local alcohol_intoxication_tmr = nil
local alcohol_intoxication_timer_time = 1000
local alcohol_intoxication_off_controls = { "sprint", "jump", "crouch", "walk" }

local blur_shader = nil
local blur_screen_src = nil
local blur_strength = 0

local reset_alcohol_anim = { [ "F1" ] = true, [ "F2" ] = true, [ "F4" ] = true, [ "F6" ] = true, [ "F9" ] = true, [ "F10" ] = true }

function EnableBar( state )
    if state then
        EnableBar( false )

        alcohol_intoxication = {}
        alcohol_intoxication_tmr = setTimer( SyncAlcoholIntoxication, alcohol_intoxication_timer_time, 0 )
        addEventHandler( "onClientKey", root, OnClientKey_handler )
    else
        ShowBarUI( false )
        
        if isTimer( alcohol_intoxication_tmr ) then killTimer( alcohol_intoxication_tmr ) end
        if isTimer( set_anim_tmr ) then killTimer( set_anim_tmr ) end
        removeEventHandler( "onClientKey", root, OnClientKey_handler )
    
        for k, v in pairs( alcohol_intoxication or {} ) do
            ResetAlcoholIntoxication( k )
        end

        alcohol_intoxication = nil
    end
end


function OnClientKey_handler( key, state )
    if not reset_alcohol_anim[ key ] or not state then return end
    set_anim_tmr = setTimer( CreateAlcoholWalkStyle, 1000, 1, localPlayer )
end

function SyncAlcoholIntoxication()
    for k in pairs( alcohol_intoxication or {} ) do
        if not isElement( k ) or not isElementStreamedIn( k ) then 
            alcohol_intoxication[ k ] = nil 
        
        else
            alcohol_intoxication[ k ] = alcohol_intoxication[ k ] - alcohol_intoxication_timer_time / 1000
            if alcohol_intoxication[ k ] <= 0 then
                ResetAlcoholIntoxication( k )
            elseif alcohol_intoxication[ k ] >= ALCOHOL_INTOXICATION_LEVELS[ ALCOHOL_INTOXICATION_DEATH ] then
                ResetAlcoholIntoxication( k )
                if k == localPlayer then
                    fadeCamera( false, 0 )
                    EnableBar( false )
                    setTimer( triggerServerEvent, 150, 1, "onServerPlayerLostConsciousnessInCasino", resourceRoot )
                end
            elseif k == localPlayer then
                local shake_level = math.ceil( math.min( 120, alcohol_intoxication[ k ] / 4 ) )
                setCameraShakeLevel( shake_level )
                blur_strength = math.max( 0, math.ceil( alcohol_intoxication[ k ] / 16 ) )
            end

            if alcohol_intoxication and alcohol_intoxication[ k ] then
                if alcohol_intoxication[ k ] < ALCOHOL_INTOXICATION_LEVELS[ ALCOHOL_INTOXICATION_STRONG ] then
                    ResetAlcoholWalkStyle( k )
                elseif alcohol_intoxication[ k ] > ALCOHOL_INTOXICATION_LEVELS[ ALCOHOL_INTOXICATION_STRONG ] then
                    CreateAlcoholWalkStyle( k )
                end
            end
        end
    end
end


function AddDegreeIntoxication( player, alcohol_id )
    alcohol_intoxication[ player ] = (alcohol_intoxication[ player ] or 0) + DRINKS[ alcohol_id ].intoxication
    if player == localPlayer then
        SyncAlcoholIntoxication()
        CreateAlcoholShaderIntoxication()
    end
end

function ResetAlcoholIntoxication( player )
    alcohol_intoxication[ player ] = nil
    ResetAlcoholWalkStyle( player )

    if player == localPlayer then
        DestroyAlcoholShaderIntoxication()
        setCameraShakeLevel( 1 )
    end
end


function CreateAlcoholShaderIntoxication()
    if isElement( blur_shader ) then return end
    
    blur_shader = dxCreateShader( ":nrp_strip_club/files/fx/blur.fx" )
    if not isElement( blur_shader ) then return end

    blur_screen_src = dxCreateScreenSource( _SCREEN_X, _SCREEN_Y )
    if not isElement( blur_screen_src ) then return end
    
    dxSetShaderValue( blur_shader, "ScreenSource", blur_screen_src )
    dxSetShaderValue( blur_shader, "UVSize", _SCREEN_X, _SCREEN_Y )
            
    removeEventHandler( "onClientPreRender", root, DrawBlurEffect )
    addEventHandler( "onClientPreRender", root, DrawBlurEffect )
end

function DestroyAlcoholShaderIntoxication()
    if not isElement( blur_shader ) then return end

    removeEventHandler( "onClientPreRender", root, DrawBlurEffect )
    
    destroyElement( blur_screen_src )
    destroyElement( blur_shader )
    
    blur_shader = nil
    blur_screen_src = nil
    blur_strength = 0
end


function DrawBlurEffect()
    dxUpdateScreenSource( blur_screen_src )
    dxSetShaderValue( blur_shader, "BlurStrength", blur_strength )
    dxDrawImage( 0, 0, _SCREEN_X, _SCREEN_Y, blur_shader )
end


function CreateAlcoholWalkStyle( player )
    if not alcohol_intoxication or not alcohol_intoxication[ player ] or alcohol_intoxication[ player ] == 0 then return end 

    setPedWalkingStyle( player, 126 )
    if player == localPlayer then
        for k, v in pairs( alcohol_intoxication_off_controls ) do 
            toggleControl( v, false ) 
        end
        
        setControlState( "walk", true )
        player:setData( "walkstyle", 126, false )
    end
end

function ResetAlcoholWalkStyle( player )
    setPedWalkingStyle( player, 118 )
    if player == localPlayer then
        for k, v in pairs( alcohol_intoxication_off_controls ) do 
            toggleControl( v, true )
        end
        if player:getData( "walkstyle" ) == 126 then
            player:setData( "walkstyle", nil, false )
        end
    end
end

function onStart()
    for k, v in pairs( bar_points ) do
        local ped = createPed( v.id, v.x, v.y, v.z, v.rz )
        ped.frozen = true
        ped.dimension = v.dimension
        ped.interior = v.interior
        addEventHandler( "onClientPedDamage", ped, cancelEvent )

        local radius = 1.5
        local tpoint = TeleportPoint( { 
            x = v.marker.x, y = v.marker.y, z = v.marker.z, 
            interior = v.interior, dimension = v.dimension, 
            radius = radius,
            color = { 50, 50, 255, 20 },
            keypress = "lalt",
            text = "ALT Взаимодействие",
            marker_text = "Бар",
            marker_image = "img/marker.png",
        } )

        tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, radius * 0.75 } )
        tpoint.PostJoin = function( )
            ShowBarUI( true )
        end
        tpoint.PostLeave = function( )
            ShowBarUI( false )
        end
    end
end
addEventHandler( "onClientResourceStart", resourceRoot, onStart )

function onClientPlayerBuyAlcoholInCasino_handler( alcohol_id )
    if source.dimension == localPlayer.dimension and source.interior == localPlayer.interior then
        AddDegreeIntoxication( source, alcohol_id )
    end
end
addEvent( "onClientPlayerBuyAlcoholInCasino", true )
addEventHandler( "onClientPlayerBuyAlcoholInCasino", root, onClientPlayerBuyAlcoholInCasino_handler )


function onClientPlayerWokeUpCasino_handler( casino_id )
    triggerEvent( "onClientPlayerCasinoExit", localPlayer, casino_id )
    localPlayer.frozen = true
    
    localPlayer:setAnimation( "sunbathe", "sbathe_f_lieb2sit", -1, false, false, false, true )
    localPlayer:ShowInfo( "Вы потеряли сознание и охрана вывела Вас из казино!")
    setTimer( function()
		setTimer( function()
            localPlayer:setAnimation( "sunbathe", "sbathe_f_out", -1, false, false, false, false )
            setTimer( function()
                localPlayer.frozen = false
            end, 2100, 1 )
		end, 1450, 1 )
    end, 200, 1 )
    setTimer( fadeCamera, 400, 1, true, 2.0 )
end
addEvent( "onClientPlayerWokeUpCasino", true )
addEventHandler( "onClientPlayerWokeUpCasino", resourceRoot, onClientPlayerWokeUpCasino_handler )

function onClientPlayerCasinoEnter_handler( casino_id )
    EnableBar( true )
end
addEvent( "onClientPlayerCasinoEnter", true )
addEventHandler( "onClientPlayerCasinoEnter", localPlayer, onClientPlayerCasinoEnter_handler )

function onClientPlayerCasinoExit_handler( casino_id )
    EnableBar( false )
end
addEvent( "onClientPlayerCasinoExit", true )
addEventHandler( "onClientPlayerCasinoExit", localPlayer, onClientPlayerCasinoExit_handler )