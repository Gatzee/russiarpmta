loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "CPlayer" )
Extend( "ShUtils" )

local COLSHAPE, COLSHAPE_OUTSIDE, DECIDER_TIMER, TEXTURE

function UpdateTexture( )
    dxSetRenderTarget( TEXTURE, true )
    dxDrawRectangle( 0, 0, 1, 1, 0xffffffff )
    dxSetRenderTarget( )
end

local ALPHA = 0
local damage_warns = 0

function renderMilitaryBounds()
    ALPHA = math.max( math.min( RENDER_STATE and ALPHA + 0.05 or ALPHA - 0.01, 1 ), 0 )

    for i = 1, #MILITARY_BOUNDS, 2 do
        local x, y = MILITARY_BOUNDS[ i ], MILITARY_BOUNDS[ i + 1 ]

        local i_next = ( i + 2 ) >= #MILITARY_BOUNDS and 1 or ( i + 2 )
        local x_next, y_next = MILITARY_BOUNDS[ i_next ], MILITARY_BOUNDS[ i_next + 1 ]

        local _, _, z = getElementPosition( localPlayer )
        z = z - 10

        dxDrawMaterialLine3D( x, y, z, x_next, y_next, z, TEXTURE, 75, tocolor( 255, 128, 128, math.floor( ALPHA * 128 ) ), x_next + 1, y_next, z )
    end
end

function CancelUrgentMilitaryDamage( attacker )
    if attacker ~= localPlayer then return end
    if localPlayer.dimension ~= URGENT_MILITARY_DIMENSION then return end

    damage_warns = damage_warns + 1

    if damage_warns >= 3 then
        triggerServerEvent( "onUrgentMilitaryDamageWarn", resourceRoot )
        damage_warns = 0
    else
        localPlayer:ShowInfo( "Прекращай, иначе будет атата!" )
    end
end

function decideRenderState( )
    local is_dimension = localPlayer.dimension == URGENT_MILITARY_DIMENSION
    local is_colshape = isElement( COLSHAPE ) and isElementWithinColShape( localPlayer, COLSHAPE ) or false

    if not RENDER_STATE then
        if is_dimension and not is_colshape then
            removeEventHandler( "onClientRender", root, renderMilitaryBounds )
            addEventHandler( "onClientRender", root, renderMilitaryBounds )

            removeEventHandler( "onClientPlayerDamage", root, CancelUrgentMilitaryDamage )
            addEventHandler( "onClientPlayerDamage", root, CancelUrgentMilitaryDamage )
            RENDER_STATE = true
        end

    else
        if not is_dimension or is_colshape then
            RENDER_STATE = nil
            removeEventHandler( "onClientRender", root, renderMilitaryBounds )
            removeEventHandler( "onClientPlayerDamage", root, CancelUrgentMilitaryDamage )
        end
        
    end

end

function onColShapeLeave_handler( player, dimension_match )
    if player ~= localPlayer then return end
    if not dimension_match then return end
    triggerServerEvent( "onMilitaryVacationLeaveCheck", localPlayer )
end

-- in_urgent_military_base
function UpdateState( key, d )
    if key == "in_urgent_military_base" then
        removeEventHandler( "onClientRestore", root, UpdateTexture )

        DestroyTableElements( {
            COLSHAPE, COLSHAPE_OUTSIDE, DECIDER_TIMER, TEXTURE, 
        } )

        local value = getElementData( localPlayer, key )
        if value then
            COLSHAPE = ColShape.Polygon( unpack( MILITARY_REAL_BOUNDS ) )
            TEXTURE = dxCreateRenderTarget( 1, 1 )
            DECIDER_TIMER = Timer( decideRenderState, 1000, 0 )
            COLSHAPE_OUTSIDE = ColShape.Polygon( unpack( MILITARY_BOUNDS ) )

            setElementDimension( COLSHAPE_OUTSIDE, URGENT_MILITARY_DIMENSION )
            addEventHandler( "onClientColShapeLeave", COLSHAPE_OUTSIDE, onColShapeLeave_handler )

            addEventHandler( "onClientRestore", root, UpdateTexture )
            UpdateTexture( )
        end

        decideRenderState( )
    end
end
addEventHandler( "onClientElementDataChange", localPlayer, UpdateState )