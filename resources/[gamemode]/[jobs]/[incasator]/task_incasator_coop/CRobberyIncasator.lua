
local ATACKED_INCASATORS = {}
local LOST_BAGS = {}

function createCashOutPoint( position )
	local cash_out_point = TeleportPoint(
    {
        x = position.x, y = position.y, z = position.z + 1,
		radius = 2,
		marker_text = "Обналичивание денег"
	} )
	
    cash_out_point.keypress = "lalt"
    cash_out_point.text = "ALT Взаимодействие"
	
    cash_out_point.marker:setColor( 100, 180, 30, 20 )
	cash_out_point:SetDropImage( { ":nrp_shared/img/dropimage.png", 100, 180, 30, 255, 1.6 } )	
	cash_out_point:SetImage( "img/cash_out_point_marker.png" )

	cash_out_point.PostJoin = function( self, player )
		triggerServerEvent( "onServerTryCashOutMoney", resourceRoot )
    end
end


function onClientShowAtackedIncasators_handler( lobby_id, pps_call_timeout, vehicle )
    onClientHideAtackedIncasators_handler( lobby_id )
    
    ATACKED_INCASATORS[ lobby_id ] = {}
    
    ATACKED_INCASATORS[ lobby_id ].gps_marker = vehicle:SetGPSMarker({
        radius = 25,
        color = { 0, 255, 0, 0 },
        x = vehicle.position.x, y = vehicle.position.y, z = vehicle.position.z, 
        blip = { id = 0, size = 2, color = { 255, 0, 0, 255 } },
        PostJoin = function( )
            onClientHideAtackedIncasators_handler( lobby_id )
            
            if PPS_FACTIONS[ localPlayer:GetFaction() ] and localPlayer:IsOnFactionDuty( ) then
                local timestamp = getRealTimestamp()
                local diff = timestamp - pps_call_timeout
                if diff < 0 then
                    localPlayer:ShowInfo( "Вы прибыли на место нападения инкассаторов" )
                    triggerServerEvent( "onServerPPSArrivedAtPoint", resourceRoot, lobby_id )
                end
            end
        end,
    })

    ATACKED_INCASATORS[ lobby_id ].timer = setTimer( onClientHideAtackedIncasators_handler, PPS_TIME_OFF_MARKERS * 1000, 1, lobby_id )

    localPlayer:ShowInfo( "Откройте карту, чтобы увидеть расположение инкассации" )
end
addEvent( "onClientShowAtackedIncasators", true )
addEventHandler( "onClientShowAtackedIncasators", resourceRoot, onClientShowAtackedIncasators_handler )

function onClientHideAtackedIncasators_handler( lobby_id )
    local incasator_data = ATACKED_INCASATORS[ lobby_id ]
    if not incasator_data then return end

    if incasator_data.gps_marker then
        incasator_data.gps_marker:destroy()
    end

    if isTimer( incasator_data.timer ) then
        killTimer( incasator_data.timer )
    end

    ATACKED_INCASATORS[ lobby_id ] = nil
end
addEvent( "onClientHideAtackedIncasators", true )
addEventHandler( "onClientHideAtackedIncasators", resourceRoot, onClientHideAtackedIncasators_handler )


function onClientPlayerLostBagMoney_handler( player, bag_id )
    DestroyBag( player )

    local lost_bag = {}

    lost_bag.point = TeleportPoint(
    {
        x = player.position.x, y = player.position.y, z = player.position.z - 0.3,
        radius = 3,
        quest_state = false,
    } )

    lost_bag.point.keypress = "lalt"
    lost_bag.point.text = "ALT Взаимодействие"
    
    lost_bag.point.marker:setColor( 0, 0, 0, 0 )

    lost_bag.point.PostJoin = function( self )
        triggerServerEvent( "onServerPlayerTryTakeLostBag", resourceRoot, bag_id )
    end

    lost_bag.timer = setTimer( DestroyLostBag, BAG_MAX_TIME * 1000, 1, bag_id )
    lost_bag.object = createObject( BAG_MODEL_ID, player.position - Vector3( 0, 0, 1), Vector3( -90, 0, 0 ) )
    
    LOST_BAGS[ bag_id ] = lost_bag
end
addEvent( "onClientPlayerLostBagMoney", true )
addEventHandler( "onClientPlayerLostBagMoney", resourceRoot, onClientPlayerLostBagMoney_handler )

function DestroyLostBag( bag_id )
    local lost_bag = LOST_BAGS[ bag_id ]
    if not lost_bag then return end

    if isTimer( lost_bag.timer ) then
        killTimer( lost_bag.timer )
    end

    if lost_bag.point then
        lost_bag.point:destroy()
    end

    if isElement( lost_bag.object ) then
        destroyElement( lost_bag.object )
    end

    LOST_BAGS[ bag_id ] = nil
end
addEvent( "onClientDestroyLostBag", true )
addEventHandler( "onClientDestroyLostBag", resourceRoot, DestroyLostBag )