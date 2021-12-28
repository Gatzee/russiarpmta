loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

BUFFS = {
    max_health = {
        default = 100,
        Apply = function( player, new_value )
            if player.health > new_value then
                player.health = new_value
            end
            if new_value > 100 then
                if player:getStat( 24 ) ~= 1000 then
                    player:setStat( 24, 1000 ) -- Ставим сразу макс. значение, чтобы меньше вызывать изменений и отправлять трафик
                end
            -- else -- Мб лучше не сбрасывать, чтобы меньше трафика, всё равно будет чекаться через player:getData( "max_health" )
            --     if player:getStat( 24 ) ~= 569 then
            --         player:setStat( 24, 569 )
            --     end
            end
        end,
    },
    max_stamina = {
        default = 100,
        -- Apply = function( player, new_value )
        --     -- if self:GetCalories( ) > max_calories then
        --     --     self:SetCalories( max_calories )
        --     -- end
        -- end,
    },
    max_calories = {
        default = 100,
        Apply = function( player, new_value )
            if player:GetCalories( ) > new_value then
                player:SetCalories( new_value )
            end
        end,
    },
    calories_speed = {
        default = 100,
    },
}

PLAYERS_BUFFS = { }

function SetBuff( player, buff_id, value, buff_source )
    if not PLAYERS_BUFFS[ player ] then PLAYERS_BUFFS[ player ] = { } end

    local player_buffs = PLAYERS_BUFFS[ player ]
    if not player_buffs[ buff_id ] then
        player_buffs[ buff_id ] = setmetatable( { values = { } }, { __index = BUFFS[ buff_id ] } )
    end

    local buff = player_buffs[ buff_id ]
    buff.values[ buff_source ] = value ~= 0 and value or nil

    -- Update stat
    local new_value = buff.default
    for k, v in pairs( buff.values ) do
        new_value = new_value + v
    end

    if buff.Apply then
        buff.Apply( player, new_value )
    end
    player:setData( buff_id, new_value, false )
    -- triggerEvent( "onPlayerBuffChange", player, buff_id, new_value )
end

addEvent( "onPlayerPreLogout" )
addEventHandler( "onPlayerPreLogout", root, function( )
    local player = source
    PLAYERS_BUFFS[ player ] = nil
end )