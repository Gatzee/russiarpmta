Extend( "ShFood" )

PLAYER_BUFFS = { }

function IsBuffActive( id )
    local remaining_time = PLAYER_BUFFS[ id ] and ( PLAYER_BUFFS[ id ] - getRealTime( ).timestamp ) or 0
    return remaining_time > 0, remaining_time
end

function ApplyFoodBuffs( food_id )
    local buffs = FOOD_DISHES[ food_id ].buffs
    local current_time = getRealTime( ).timestamp
    for id, buff in pairs( buffs ) do
        local buff_end_time = PLAYER_BUFFS[ id ] or 0
        local remaining_time = math.min( 0, buff_end_time - current_time )
        local new_duration = math.max( remaining_time + buff.duration, FOOD_BUFFS_INFO[ id ].max_duration )
        PLAYER_BUFFS[ id ] = current_time + new_duration
    end
end

addEvent( "onClientPlayerGetFoodBuffs", true )
addEventHandler( "onClientPlayerGetFoodBuffs", root, function( data )
    if type( data ) == "number" then
        ApplyFoodBuffs( data )
    else
        local current_time = getRealTime( ).timestamp
        for id, remaining_time in pairs( data ) do
            data[ id ] = current_time + remaining_time
        end
        PLAYER_BUFFS = data
    end

    -- if PLAYER_BUFFS[ BUFF_HUNGER ] then
    --     HUNGER_BUFF_END_TIME = PLAYER_BUFFS[ BUFF_HUNGER ]
    -- end
    
    UpdateHealthBuff( )
    UpdateStaminaBuff( )
end )

local health_buff_timer = false
function UpdateHealthBuff( )
    if isTimer( health_buff_timer ) then
        killTimer( health_buff_timer )
    end

    local duration = ( PLAYER_BUFFS[ BUFF_HEALTH ] or 0 ) - getRealTime( ).timestamp
    if duration <= 0 then return end

    local buff = FOOD_BUFFS_INFO[ BUFF_HEALTH ]
    health_buff_timer = setTimer( 
        function ()
            if localPlayer.dead then return end
            localPlayer:SetHP( localPlayer.health + buff.add_value )
        end, 
        buff.interval * 1000, 
        math.floor( duration / buff.interval ) 
    )
end

function UpdateStaminaBuff( )
    local duration = ( PLAYER_BUFFS[ BUFF_STAMINA ] or 0 ) - getRealTime( ).timestamp
    if duration <= 0 then return end
    
    local buff = FOOD_BUFFS_INFO[ BUFF_STAMINA ]
    triggerEvent( "SetStaminaBuff", localPlayer, duration, buff.interval, buff.add_value )
end