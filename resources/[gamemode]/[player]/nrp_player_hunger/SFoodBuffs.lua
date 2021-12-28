PLAYER_BUFFS = { }

function ApplyFoodBuffs( player, food_id )
    local buffs = FOOD_DISHES[ food_id ].buffs
    local player_buffs = PLAYER_BUFFS[ player ]
    local player_buffs_ids = player:GetPermanentData( "food_buff_ids" ) or { }
    local current_time = getRealTimestamp( )

    for id, buff in pairs( buffs ) do
        local buff_end_time = player_buffs[ id ] or 0
        local remaining_time = math.min( 0, buff_end_time - current_time )
        local new_duration = math.max( remaining_time + buff.duration, FOOD_BUFFS_INFO[ id ].max_duration )
        player_buffs[ id ] = current_time + new_duration
        player_buffs_ids[ id ] = food_id
    end

    player:SetPermanentData( "food_buff_ids", player_buffs_ids )
    player:SetPermanentData( "food_buffs", player_buffs )

    player:triggerEvent( "onClientPlayerGetFoodBuffs", player, food_id )
end

function onPlayerCompleteLogin_handler( player )
    local player = isElement( player ) and player or source

    PLAYER_BUFFS[ player ] = FixTableKeys( player:GetPermanentData( "food_buffs" ) ) or { }

    if not next( PLAYER_BUFFS[ player ] ) then return end

    local data = { }
    local current_time = getRealTimestamp( )
    for buff_id, buff_end_time in pairs( PLAYER_BUFFS[ player ] ) do
        local remaining_time = buff_end_time - current_time
        if remaining_time > 0 then
            data[ buff_id ] = remaining_time
        else
            PLAYER_BUFFS[ player ][ buff_id ] = nil
        end
    end
    if next( data ) then
        player:triggerEvent( "onClientPlayerGetFoodBuffs", player, data )
    end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )

addEventHandler( "onResourceStart", resourceRoot, function( )
    Timer( function( )
        for i, v in pairs( GetPlayersInGame( ) ) do
            onPlayerCompleteLogin_handler( v )
        end
    end, 1000, 1 )
end )