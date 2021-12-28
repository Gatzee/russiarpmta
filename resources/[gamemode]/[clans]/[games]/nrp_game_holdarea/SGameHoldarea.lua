loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SInterior" )
Extend( "ShTimelib" )
Extend( "SClans" )

function CreateHoldArea( config, match )
    local self = table.copy( config )

    self.dimension = match.dimension
    self.color = { 255, 0, 0, 150 }
    self.radius = 4.5
    self.keypress = false --"lalt"
    -- self.text = "Нажмите Alt чтобы захватить территорию"

    self = TeleportPoint( self )

    self:SetImage( ":nrp_clans/img/flag.dds" )
    local r, g, b, a = 255, 255, 255, 255
    self:SetDropImage( { ":nrp_clans/img/dropimage1.dds", 255, 255, 255, 255 } )
    self.element:setData( "material", true )
    -- self.elements.marker = createMarker( self.x, self.y, self.z - 7, "cylinder", 9, 255, 0, 0, 150 )
    -- self.elements.marker.dimension = self.dimension
    self.marker.size = 9
    self.marker.position = Vector3( self.x, self.y, self.z - 7 )

    self.PreJoin = function( self, player )
        local clan_id = player:GetClanID()
        if not clan_id or clan_id == self.current_clan_id or not match.team_id_by_clan_id[ clan_id ] then return end

        for i, other_player in pairs( getElementsWithinColShape( self.elements.gameshape, "player" ) ) do
            local other_clan_id = other_player:GetClanID()
            if other_clan_id and other_clan_id ~= clan_id and other_player.health > 1 and not isPedDead( other_player ) and other_player.dimension == self.dimension then
                player:ShowError( "На территории есть ЧЛЕНЫ вражеского клана!" )
                return
            end
        end

        return true
    end

    self.PostJoin = function( self, player )
        if getElementHealth( player ) > 1 and not isPedDead( player ) then
            self.current_clan_id = player:GetClanID()
            -- local color = BANDS_COLORS[ self.current_clan_id ]
            -- local r, g, b, a = 255, 255, 255, 255 -- unpack( color )
            -- self:SetImage( { ":nrp_clans/img/flag.dds", r, g, b, a } )
            -- self:SetDropImage( { ":nrp_clans/img/dropimage1.dds", 255, 255, 255, 255 } )
            -- self.elements.radar_area:setColor( r, g, b, 100 )
            player:ShowInfo( "Вы захватили эту территорию!" )
            player:AddClanStats( "points_captured", 1 )
        end
    end

    self.elements = { }
    self.elements.gameshape = self.colshape
    self.elements.blip = Blip( self.x, self.y, self.z, 0, 2, 255, 0, 0, 255, 999, 500 )
    self.elements.blip.dimension = self.dimension

    -- if self.radar_area then
    --     self.elements.radar_area = RadarArea( unpack( self.radar_area ) )
    --     self.elements.radar_area.flashing = true
    --     self.elements.radar_area:setColor( 255, 0, 0, 100 )
    --     self.elements.radar_area.dimension = self.dimension
    -- end
    
    self.CheckPlayersInZone = function( )
        if self.current_clan_id then
            local current_clan_members_inside_col = { }
            local total_clan_members = 0

            for i, v in pairs( getElementsWithinColShape( self.elements.gameshape, "player" ) ) do
                if not isPedDead( v ) and v.health > 0 and v.dimension == self.dimension then
                    local clan_id = v:GetClanID()
                    if match.team_id_by_clan_id[ clan_id ] then
                        -- Если в зоне есть вражеские игроки, то не даём очки
                        if clan_id ~= self.current_clan_id then
                            return
                        else
                            table.insert( current_clan_members_inside_col, v )
                        end
                    end
                end
            end

            if #current_clan_members_inside_col > 0 then
                local add_score = self.scores_per_second * self.check_interval * #current_clan_members_inside_col
                match.scores[ self.current_clan_id ] = math.min( self.need_score, ( match.scores[ self.current_clan_id ] or 0 ) + add_score )
                --self.element:setData( "scores", match.scores )

                triggerClientEvent( match.participants, "CEV:UpdateGameUI", resourceRoot, match.scores )

                if match.scores[ self.current_clan_id ] >= self.need_score then

                    -- Удаляем до выдачи наград чтоб не среагировало несколько раз
                    if isTimer( self.elements.timer ) then killTimer( self.elements.timer ) end

                    match.OnFinish( self )
                    return
                end
            end
        end
    end
    self.elements.timer = Timer( self.CheckPlayersInZone, self.check_interval * 1000, 0 )

    return self
end