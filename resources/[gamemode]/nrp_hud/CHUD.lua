loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CUI" )
Extend( "ib" )
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "ShVehicleConfig" )
Extend( "ShUtils" )
Extend( "Globals" )
Extend( "ShDailyQuestList" )
Extend( "ShClans" )

HUD = { }
HUD_CONFIGS = { }
x, y = guiGetScreenSize( )

PARENT = ibCreateDummy( ):ibData( "priority", -50 ):ibData( "visible", false )

function AddHUDBlock( id, ... )
    if IsHUDBlockActive( id ) then return end

    local conf = HUD_CONFIGS[ id ]

    if conf.use_real_fonts then
        ibUseRealFonts( true )
    end
    
    local bg = conf:create( ... )

    if isElement( bg ) then
        bg:ibData( "alpha", 0 )
        setElementParent( bg, PARENT )

        bg:ibOnDestroy( function( )
            HUD[ id ] = nil
            if not conf.independent then
                RearrangeHUD( )
            end
        end )

        HUD[ id ] = bg

        if not conf.independent then
            RearrangeHUD( )
        end

        bg:ibAlphaTo( 255, 200 )
    end

    ibUseRealFonts( false )
end

function RemoveHUDBlock( id )
    if not IsHUDBlockActive( id ) then return end

    local conf = HUD_CONFIGS[ id ]
    conf:destroy( )
end

function IsHUDBlockActive( id )
    return next( HUD_CONFIGS[ id ] and HUD_CONFIGS[ id ].elements ) ~= nil
end

function RearrangeHUD( )
    local ordered_list = { }
    for id, element in pairs( HUD ) do
        if not HUD_CONFIGS[ id ].independent and isElement( element ) and not element:ibData( "disabled" ) then
            table.insert( ordered_list, { id = id, element = element, conf = HUD_CONFIGS[ id ] } )
        end
    end
    table.sort( ordered_list, 
        function( a, b ) 
            return ( a.conf.order or 0 ) > ( b.conf.order or 0 )
        end
    )

    local npx, npy, gap = x - 360, 20, 10
    for i, hud_info in pairs( ordered_list ) do
        local element = hud_info.element

        local sy = element:ibData( "sy" )
        element:ibBatchData( { px = npx, py = npy } )

        npy = npy + sy + gap
    end

    return true
end

function CheckHUDDisable( key )
    if not key or key == "hud_disabled_by" then
        local is_disabled = GetDisabledHUDList( )
        PARENT:ibData( "visible", not is_disabled )

        if is_disabled then
            HideRadarMap( )
        end
    end
end

function onClientPlayerNRPSpawn_hudHandler( )
    removeEventHandler( "onClientPlayerNRPSpawn", localPlayer, onClientPlayerNRPSpawn_hudHandler )

    CheckHUDDisable( )
    addEventHandler( "onClientElementDataChange", localPlayer, CheckHUDDisable )
end

function onResourceStart_hudHandler( )
    if localPlayer:IsInGame( ) then
        CheckHUDDisable( )
        addEventHandler( "onClientElementDataChange", localPlayer, CheckHUDDisable )
    else
        addEventHandler( "onClientPlayerNRPSpawn", localPlayer, onClientPlayerNRPSpawn_hudHandler )
    end
end
addEventHandler( "onClientResourceStart", resourceRoot, onResourceStart_hudHandler )

function SetHUDBlockVisible( block_name, visible, data )
    RemoveHUDBlock( block_name )
    if visible then
        AddHUDBlock( block_name, data )
    end
end
addEvent( "onClientSetHUDBlockVisible", true )
addEventHandler( "onClientSetHUDBlockVisible", root, SetHUDBlockVisible )

function SetAllMinorHUDBlocksVisible( visible )
    for id, element in pairs( HUD ) do
        if not HUD_CONFIGS[ id ].independent and isElement( element ) and id ~= "main" then
            -- element:ibData( "visible", visible )
            RemoveHUDBlock( id )
        end
    end
end

function onClientHideHudComponents_handler( components, hide )
    for _, id in pairs( components ) do
        if HUD[ id ] then
            HUD[ id ]:ibData( "visible", not hide )
            HUD[ id ]:ibData( "disabled", hide )
        end
    end
    RearrangeHUD( )
end
addEvent( "onClientHideHudComponents", true )
addEventHandler( "onClientHideHudComponents", root, onClientHideHudComponents_handler )