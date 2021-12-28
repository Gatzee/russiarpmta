BUFFS = {
    max_health = {
        default = 100,
        Apply = function( player, new_value )
            -- if player.health > new_value then
            --     player.health = new_value
            -- end
        end,
    },
    max_stamina = {
        default = 100,
        Apply = function( player, new_value )
            -- if self:GetCalories( ) > max_calories then
            --     self:SetCalories( max_calories )
            -- end
        end,
    },
    max_calories = {
        default = 100,
        -- Apply = function( player, new_value )
        --     if player:GetCalories( ) > new_value then
        --         player:SetCalories( new_value )
        --     end
        -- end,
    },
    calories_speed = {
        default = 100,
    },
}

IS_BUFF_DISABLED = false

function SetBuff( player, buff_id, value, buff_source )
    local buff = BUFFS[ buff_id ]
    if not buff.values then buff.values = { } end

    buff.values[ buff_source ] = value ~= 0 and value or nil

    -- Update stat
    local new_value = buff.default
    for k, v in pairs( buff.values ) do
        new_value = new_value + v
    end

    if IS_BUFF_DISABLED then return end

    if buff.Apply then
        buff.Apply( localPlayer, new_value )
    end
    localPlayer:setData( buff_id, new_value, false )
    triggerEvent( "onClientPlayerBuffChange", localPlayer, buff_id, new_value )
end