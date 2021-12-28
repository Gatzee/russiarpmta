Extend( "CPlayer" )
Extend( "CInterior" )
Extend( "ShUtils" )
Extend( "ib" )

iprint( "Loaded businesses:", #BUSINESSES )

COLSHAPES = { }

function RequestOpenBusiness( _, _, business_id )
    if ibIsAnyWindowActive( ) or localPlayer.vehicle then return end
	triggerServerEvent( "onBusinessWindowOpenRequest", resourceRoot, business_id )
end

function RemoveBinds( )
    if IS_KEY_BOUND then
        unbindKey( "h", "down", RequestOpenBusiness )
        triggerEvent( "HideBusinessInfo", root )
        IS_KEY_BOUND = nil
    end
end

function RecheckAllBusinesses( )
    if getElementData( localPlayer, "in_clan_event_lobby" ) then return end

    local business_found = false

    if not localPlayer.vehicle and localPlayer.dimension == 0 and localPlayer.interior == 0 then
        for i, v in pairs( COLSHAPES ) do
            if isElementWithinColShape( localPlayer, i ) then
                if IS_KEY_BOUND then return end
                triggerEvent( "ShowBusinessInfo", root, v )
                bindKey( "h", "down", RequestOpenBusiness, v.business_id )
                IS_KEY_BOUND = true
                business_found = true
                break
            end
        end
    end

    if not business_found then
        RemoveBinds( )
    end
end
CHECK_BUSINESSES_TIMER = setTimer( RecheckAllBusinesses, 500, 0 )

for i, v in pairs( BUSINESSES ) do
    local colshape = ColShape.Sphere( v.x, v.y, v.z, v.radius )
    COLSHAPES[ colshape ] = { business_id = v.id, icon = v.icon }

    addEventHandler( "onClientColShapeLeave", colshape, function( source )
        if source ~= localPlayer then return end
        ShowBusinessPurchaseUI_handler( false )
        ShowBusinessUI_handler( false )
    end )
end