local POINTS_PER_SECOND = 1
local CAPTURE_DURATION = 5

function CreateControlPoint( config, quest_handler )
    local self = table.copy( config )

    self.color = { 0, 0, 0, 0 }
    self.radius = 5
    self.keypress = false
    self.state = POINT_STATE_NEUTRAL
    self.progress = 0
    self.quest = quest_handler
    self.point_id = 1
    self.scores = { 0, 0 }

    self.PreJoin = function( self, player )
        return true
    end

    self.PostJoin = function( self, player )
        if player.dimension ~= self.dimension then return end
        if isPedInVehicle( player ) then return end

        if not self.current_team or self.state == POINT_STATE_NEUTRAL then
            local team_id = self.quest:GetPlayerTeam( player )
            
            if team_id then
                local pMembers, iTotal = self:GetTeamMembersInZone( team_id )

                if #pMembers == iTotal then
                    self:SetState( POINT_STATE_CAPTURING )
                else
                    self:SetState( POINT_STATE_CONFLICT )
                end
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
    self.elements.blip = Blip( self.x, self.y, self.z, 41, 4, 255, 0, 0, 255, 999, 3000 )
    self.elements.blip.dimension = self.dimension
    self.elements.blip:setData( "capture_flag_blip", "A" )

    self.SetState = function( self, new_state )
        if self.state == new_state then return end

        if new_state == POINT_STATE_CAPTURING then
            local team_id = #self:GetTeamMembersInZone( 1 ) > 0 and 1 or 2
            local bSaveProgress = self.state == POINT_STATE_NEUTRAL or self.state == POINT_STATE_CONFLICT
            self.progress = ( bSaveProgress and self.current_team == team_id ) and self.progress or 0
            self.current_team = team_id
            
            self.quest:SetTeamTask( self.current_team == 1 and 2 or 1, _, "Отбейте и захватите точку" )
        elseif new_state == POINT_STATE_CAPTURED then
            local color = TEAM_COLORS[ self.current_team ]
            local r, g, b, a = unpack( color )
            self:SetImage( { ":nrp_clans/img/flag.dds", r, g, b, a } )
            self:SetDropImage( { ":nrp_clans/img/dropimage1.dds", r, g, b, a } )

            self.quest:SetTeamTask( self.current_team, _, "Защищайте точку 5 минут" )
            self.quest:SetTeamTask( self.current_team == 1 and 2 or 1, _, "Отбейте и захватите точку" )
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
            team = self.current_team,
            state = self.state,
            scores = self.scores,
        }

        triggerClientEvent( self.quest.players_list, "CPQ:UpdateGameUI", resourceRoot, pDataToSend )
    end

    self.GetTeamMembersInZone = function( self, team_id )
        local gameshape_elements = getElementsWithinColShape( self.elements.gameshape, "player" )
        local pMembers, iTotal = {}, 0
        for i, v in pairs( gameshape_elements ) do
            if not isPedDead( v ) and v.health > 0 and v.dimension == self.dimension and not isPedInVehicle( v ) then
                local team = self.quest:GetPlayerTeam( v )
                if team then
                    if team == team_id then
                        table.insert(pMembers, v)
                    end

                    iTotal = iTotal + 1
                end
            end
        end

        return pMembers, iTotal
    end
    
    self.GiveScores = function( self )
        local points = ZONE_STATUS_UPDATE_INTERVAL
        self.scores[ self.current_team ] = self.scores[ self.current_team ] + points

        if self.scores[ self.current_team ] >= CAPTURE_TOTAL_DURATION then
            self.quest:OnTeamWon( self.current_team )
        end
    end

    self.UpdateZoneStatus = function( )
        if self.current_team then
            local pMembers, iTotal = self:GetTeamMembersInZone( self.current_team )

            if #pMembers ~= iTotal then
                self:SetState( POINT_STATE_CONFLICT )
            end

            if self.state == POINT_STATE_CAPTURED then
                self:GiveScores( )
            elseif self.state == POINT_STATE_CAPTURING then
                if #pMembers >= 1 then
                    local fProgressSpeed = 1
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
                    --self:GiveScores( )
                end
            elseif self.state == POINT_STATE_NEUTRAL then
                if (#pMembers >= 1 and #pMembers == iTotal) or (#pMembers == 0 and iTotal > 0) then
                    self:SetState( POINT_STATE_CAPTURING )
                end
            end
        end
    end
    self.elements.timer = Timer( self.UpdateZoneStatus, ZONE_STATUS_UPDATE_INTERVAL * 1000, 0 )

    self.OnGlobalTimeExpired = function( self )
        local won_team_id = self.scores[1] > self.scores[2] and 1 or 2

        if self.scores[1] == self.scores[2] then
            won_team_id = -1
        end

        self.quest:OnTeamWon( won_team_id )
    end

    return self
end