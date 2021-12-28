if localPlayer then
    
    -- Client
    CLAN_BUFF_CONTROLLERS[ CLAN_UPGRADE_GROUP_MAX_HP ] = {
        check_timer = nil,
        
        Enable = function( self, player, conf )
            if not isTimer( self.check_timer ) then
                self.check_timer = setTimer( self.Check, 500, 0, conf.buff_value )
            end
        end,

        Disable = function( self )
            if isTimer( self.check_timer ) then
                self.check_timer:destroy( )
            end
            localPlayer:SetBuff( "max_health", nil, "clan_buff" .. CLAN_UPGRADE_GROUP_MAX_HP )
        end,

        Check = function( buff_value )
            local position = localPlayer.position
            local dimension = localPlayer.dimension
            local members_nearby_count = 0
            for i, member in pairs( localPlayer:GetClanTeam( ).players ) do
                if member.dimension == dimension and member.position:distance( position ) < 100 then
                    members_nearby_count = members_nearby_count + 1
                end
            end

            local value = nil
            if members_nearby_count >= 3 then
                value = buff_value, "clan_buff"
            end
            localPlayer:SetBuff( "max_health", value, "clan_buff" .. CLAN_UPGRADE_GROUP_MAX_HP )
            triggerServerEvent( "CB:SetGroupHealthBuff", resourceRoot, value )
        end,
    }

else

    -- Server
    CLAN_BUFF_CONTROLLERS[ CLAN_UPGRADE_GROUP_MAX_HP ] = {
        Enable = function( self )
            
        end,

        Disable = function( self, player )
            player:SetBuff( "max_health", nil, "clan_buff" .. CLAN_UPGRADE_GROUP_MAX_HP )
        end,
    }

    addEvent( "CB:SetGroupHealthBuff", true )
    addEventHandler( "CB:SetGroupHealthBuff", resourceRoot, function( buff_value )
        client:SetBuff( "max_health", buff_value, "clan_buff" .. CLAN_UPGRADE_GROUP_MAX_HP )
    end )
end