Extend( "ShVehicleConfig" )
Extend( "ShHouseSale" )
Extend( "SPlayer" )
Extend( "ShDances" )

Player.UpAchievement = function ( self, achieve_id, result, level )
    if not result then
        return
    end

    local achievement_list = self:GetPermanentData( "achievements_list" ) or { }
    local current_level = achievement_list[ achieve_id ] or 0

    level = level or 1
    if level <= current_level then
        return
    end

    achievement_list[ achieve_id ] = level

    triggerClientEvent( self, "onClientGotAchievements", resourceRoot, achieve_id )

    self:SetPermanentData( "achievements_list", achievement_list )
    self:SetPrivateData( "achievements_list", achievement_list )

    -- analytics
    SendElasticGameEvent( self:GetClientID( ), "achievement_complete", {
        achieve_id = achieve_id,
        achieve_name = ACHIEVEMENTS[ achieve_id ].en_name,
        achieve_lvl = level,
        reward_id = nil, -- TODO: add reward
        reward_cost = 0,
        currency = "",
    } )
end

Player.GetAchievementsProgress = function ( self, achieve_id )
    local counters = self:GetPermanentData( "achievements_counter" ) or { }

    return counters[ achieve_id ] or 0
end

Player.SetAchievementProgress = function ( self, achieve_id, progress )
    local counters = self:GetPermanentData( "achievements_counter" ) or { }

    counters[ achieve_id ] = progress

    self:SetPermanentData( "achievements_counter", counters )
    self:SetPrivateData( "achievements_counter", counters )
end

Player.AddAchievementProgress = function ( self, achieve_id, progress )
    local counters = self:GetPermanentData( "achievements_counter" ) or { }

    counters[ achieve_id ] = ( counters[ achieve_id ] or 0 ) + progress

    self:SetPermanentData( "achievements_counter", counters )
    self:SetPrivateData( "achievements_counter", counters )
end

Player.HasAchievementCompleted = function ( self, achieve_id )
    local achievement_list = self:GetPermanentData( "achievements_list" ) or { }

    if achievement_list[ achieve_id ] and not ACHIEVEMENTS[ achieve_id ].targets then -- TODO: add level's check
        return true
    end
end

Player.SomeDo = function ( self, doing_id, need_check, from_client_side )
    if not DOING_LIST[ doing_id ] then return end

    for idx, achieve_id in pairs( DOING_LIST[ doing_id ] ) do
        local achievement = ACHIEVEMENTS[ achieve_id ]

        -- achievement was found & not completed & triggered not from client / allow from client
        if achievement and not self:HasAchievementCompleted( achieve_id ) and ( not from_client_side or achievement.client_side ) then
            if need_check and achievement.check_func then
                self:UpAchievement( achieve_id, achievement:check_func( self ) )
            elseif achievement.func then
                self:UpAchievement( achieve_id, achievement:func( self ) )
            else
                self:UpAchievement( achieve_id, true )
            end
        elseif not achievement then
            iprint( "ACHIEVEMENTS: Can't find '" .. achieve_id .. "' in the achievements list" )
        end
    end
end

-- triggerEvent( "onPlayerSomeDo", client, "bounty_order" ) -- achievements