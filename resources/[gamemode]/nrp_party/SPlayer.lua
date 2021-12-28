Player.GetPartyID = function ( self )
    return self:GetPermanentData( "party_id" ) or 0
end

Player.SetPartyID = function ( self, id )
    self:SetPermanentData( "party_id", id )
end

Player.GetPartyRole = function ( self )
    return self:GetPermanentData( "party_role" ) or 0
end

Player.SetPartyRole = function ( self, role_id )
    self:SetPermanentData( "party_role", role_id )
end

Player.SetPartyLockedTime = function ( self, time )
    self:SetPermanentData( "party_locked_time", time )
end

Player.GetPartyLockedTime = function ( self )
    return self:GetPermanentData( "party_locked_time" ) or 0
end

Player.IsChangePartyAvailable = function ( self )
    if self:GetPartyLockedTime( ) < getRealTimestamp( ) then
        return true
    else
        return false
    end
end

Player.MoveToParty = function ( self, is_youtuber, ignore_check )
    if not ignore_check then
        local can_start, reason = self:CanJoinToEvent( )
        if not can_start then
            self:ShowError( reason )
            return
        end
    end

    local party = PARTY_LIST[ self:GetPartyID( ) ]

    if party and ( party.is_started or is_youtuber ) then
        if not is_youtuber and party.owner_is_leave then
            self:ShowError( "Организатор вышел из игры" )
            return
        end

        if self.vehicle then
            removePedFromVehicle( self )
        end

        self:GetCommonData( { "party_got" }, { self }, function( result, self )
            if not isElement( self ) then return end

            if not result.party_got then
                party.counter_unique_players = ( party.counter_unique_players or 0 ) + 1
                self:SetCommonData( { party_got = party.id } ) -- first party
            end
        end )

        local last_win = self:GetPermanentData( "party_last_win" )
        if last_win and last_win[ 1 ] + ONE_DAY_SECONDS < getRealTimestamp( ) then -- fix 'reconnect hack'

            last_win[ 2 ] = last_win[ 2 ] - 1
            if last_win[ 2 ] <= 0 then
                last_win = nil
            end

            self:SetPermanentData( "party_last_win", last_win )
        end

        party.players_on_party[ self ] = {
            player      = self,
            position    = self.position,
            interior    = self.interior,
            dimension   = self.dimension,
        }

        local x, y = PARTY_POS_START.x + math.random( - 25, 25 ), PARTY_POS_START.y + math.random( - 25, 25 )
        self:Teleport( Vector3( x, y, PARTY_POS_START.z ), 1000 + party.id, 0, 2000 )

        self:ShowSuccess( "Добро пожаловать на тусовку" )

        -- analytics
        if not is_youtuber then
            triggerEvent( "onPlayerJoinToParty", self, party.youtuber_id, party.name, party.counter )
        end

        self:SetPrivateData( "in_party", true )

        return true
    end
end

Player.RemoveFromParty = function ( self )
    local party = PARTY_LIST[ self:GetPartyID( ) ]

    if party and party.players_on_party[ self ] then
        local data = party.players_on_party[ self ]
        self:Teleport( data.position, data.dimension, data.interior )
        party.players_on_party[ self ] = nil

        self:SetPrivateData( "in_party", nil )
    end
end