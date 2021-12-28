function CapturePoint_Create( config )
    local self = table.copy( config )

    self.color = { 0, 0, 0, 0 }
    self.radius = 5
    self.keypress = false
    self.text = "Контрольная точка"
    self.marker_text = "Точка "..config.name
    self.state = POINT_STATE_NEUTRAL
    self.progress = 0

    self.PreJoin = function( self, player )
        return true
    end

    self.PostJoin = function( self, player )
        if not self.current_band or self.state == POINT_STATE_NEUTRAL then
            local sBandID = player:GetBandID()
            local pMembers, iTotal = self:GetBandMembersInZone( sBandID )

            if #pMembers == iTotal then
                self:SetState( POINT_STATE_CAPTURING )
            else
                self:SetState( POINT_STATE_CONFLICT )
            end
        end

        return true
    end

    self = TeleportPoint( self )

    self:SetImage( ":nrp_clans/img/flag.dds" )
    local r, g, b, a = 255, 255, 255, 255
    self:SetDropImage( { ":nrp_clans/img/dropimage1.dds", r, g, b, a } )
    self.element:setData( "material", true )

    self.points = { }

    self.elements = { }
    self.elements.gameshape = createColSphere( self.x, self.y, self.z, CAPTURE_ZONE_RADIUS )
    self.elements.gameshape.dimension = self.dimension
    self.elements.blip = Blip( self.x, self.y, self.z, 0, 4, 255, 0, 0, 255, 999, 3000 )
    self.elements.blip.dimension = self.dimension

    self.SetState = function( self, new_state )
        if self.state == new_state then return end

        if new_state == POINT_STATE_CAPTURING then
            local sBandID = #self:GetBandMembersInZone( "green" ) > 0 and "green" or "purple"
            local bSaveProgress = self.state == POINT_STATE_NEUTRAL or self.state == POINT_STATE_CONFLICT
            self.progress = ( bSaveProgress and self.current_band == sBandID ) and self.progress or 0
            self.current_band = sBandID
        elseif new_state == POINT_STATE_CAPTURED then
            local color = BANDS_COLORS[ self.current_band ]
            local r, g, b, a = unpack( color )
            self:SetImage( { ":nrp_clans/img/flag.dds", r, g, b, a } )
            self:SetDropImage( { ":nrp_clans/img/dropimage1.dds", r, g, b, a } )
        elseif new_state == POINT_STATE_NEUTRAL then
            local r, g, b, a = 255, 255, 255, 255
            self:SetImage( { ":nrp_clans/img/flag.dds", r, g, b, a } )
            self:SetDropImage( { ":nrp_clans/img/dropimage1.dds", r, g, b, a } )
        elseif new_state == POINT_STATE_CONFLICT then
            local r, g, b, a = 255, 255, 255, 255
            self:SetImage( { ":nrp_clans/img/flag.dds", r, g, b, a } )
            self:SetDropImage( { ":nrp_clans/img/dropimage1.dds", r, g, b, a } )
        end

        self.state = new_state
        
        self:UpdateClientsGameUI()
    end

    self.UpdateClientsGameUI = function( self )
        local pDataToSend = 
        {
            points = 
            { 
                [ self.point_id ] = { 
                    band = self.current_band,
                    state = self.state,
                    progress = self.progress,
                },
            },
        }

        triggerClientEvent( GAME_DATA.participants, "CEV:UpdateGameUI", resourceRoot, pDataToSend )
    end

    self.GetBandMembersInZone = function( self, band_id )
        local gameshape_elements = getElementsWithinColShape( self.elements.gameshape, "player" )
        local pMembers, iTotal = {}, 0
        for i, v in pairs( gameshape_elements ) do
            if not isPedDead( v ) and v.health > 0 and v.dimension == self.dimension then
                local band = v:GetBandID()
                if band then
                    if band == band_id then
                        table.insert(pMembers, v)
                    end

                    iTotal = iTotal + 1
                end
            end
        end

        return pMembers, iTotal
    end
    
    self.GiveScores = function( self, pMembers )
        local scores = POINTS_PER_SECOND * ZONE_STATUS_UPDATE_INTERVAL
        UpdateScore( self.current_band, scores )

        Async:foreach( pMembers, function( v )
            if isElement(v) and not isPedDead( v ) and v.health > 0 then
                v:GiveClanEXP( math.floor( scores ) )

                if v:IsClanMember() then
                    GiveClanEXP( v:GetClanID(), math.floor( scores ) )
                end
            end
        end )
    end

    self.UpdateZoneStatus = function( )
        if self.current_band then
            local pMembers, iTotal = self:GetBandMembersInZone( self.current_band )

            if #pMembers ~= iTotal then
                self:SetState( POINT_STATE_CONFLICT )
            end

            if self.state == POINT_STATE_CAPTURED then
                self:GiveScores( pMembers )
            elseif self.state == POINT_STATE_CAPTURING then
                if #pMembers >= 1 then
                    local fProgressSpeed = 1 + #pMembers * CAPTURE_SPEED_PER_PLAYER
                    local fProgressDelta = ZONE_STATUS_UPDATE_INTERVAL / CAPTURE_DURATION
                    self.progress = self.progress + fProgressSpeed * fProgressDelta

                    if self.progress >= 1 then
                        self:SetState(POINT_STATE_CAPTURED)
                    else
                        self:UpdateClientsGameUI()
                    end
                else
                    self:SetState(POINT_STATE_NEUTRAL)
                end
            elseif self.state == POINT_STATE_CONFLICT then
                if iTotal == 0 then
                    self:SetState(POINT_STATE_NEUTRAL)
                elseif #pMembers >= 1 and #pMembers == iTotal then
                    if self.progress >= 1 then
                        self:SetState( POINT_STATE_CAPTURED )
                    else
                        self:SetState( POINT_STATE_CAPTURING )
                    end
                elseif #pMembers == 0 and iTotal > 0 then
                    self:SetState( POINT_STATE_CAPTURING )
                elseif self.progress >= 1 then
                    self:GiveScores( pMembers )
                end
            elseif self.state == POINT_STATE_NEUTRAL then
                if (#pMembers >= 1 and #pMembers == iTotal) or (#pMembers == 0 and iTotal > 0) then
                    self:SetState( POINT_STATE_CAPTURING )
                end
            end
        end
    end
    self.elements.timer = Timer( self.UpdateZoneStatus, ZONE_STATUS_UPDATE_INTERVAL * 1000, 0 )

    return self
end