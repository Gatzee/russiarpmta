loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SClans" )

OBJECT_MODEL = 2973
MAX_REWARDED_PLAYERS_COUNT = 5

function CreateTruckCrate_handler( self )
    self = table.copy( self )

    if self.position then
        self.x, self.y, self.z = self.position.x, self.position.y, self.position.z
    end

    self.reward_players = function( )
        local players = getElementsWithinColShape( self.elements.gameshape, "player" )

        local players_count = 0
        Async:foreach( players, function( player )
            if players_count > MAX_REWARDED_PLAYERS_COUNT then return end
            if not isElement( player ) or isPedDead( player ) or player.health == 0 then return end

            local clan_id = player:GetClanID( )
            if not clan_id then return end

            player:GiveClanEXP( self.points )
            GiveClanHonor( clan_id, self.points, "truckcrate", player, self.points )
            if self.money then
                player:GiveMoney( self.money, "band_game_truckcrate_reward" )
            end

            player:ShowSuccess( "Ты подобрал часть груза и получил +".. self.points .." XP и 1000 р." )

            players_count = players_count + 1
        end )

    end

    self.destroy = function( )
        for i, v in pairs( self.elements ) do
            if isElement( v ) then destroyElement( v ) end
        end
        for i, v in pairs( self.timers ) do
            if isTimer( v ) then killTimer( v ) end
        end
    end

    self.radius     = self.radius or 6
    self.duration   = self.duration or 30
    self.freq       = self.freq or 2
    self.points     = self.points or 10

    self.elements           = { }
    self.elements.object    = Object( OBJECT_MODEL, self.x, self.y, self.z, self.rx or 0, self.ry or 0, self.rz or 0 )
    self.elements.gameshape = createColSphere( self.x, self.y, self.z, self.radius or 30 )

    setElementFrozen( self.elements.object, true )

    self.timers                 = { }
    self.timers.CheckTimer      = setTimer( self.reward_players, self.freq * 1000, 0 )
    self.timers.DestroyTimer    = setTimer( self.destroy, self.duration * 1000, 1 )
    
    return self
end
addEvent( "CreateTruckCrate", true )
addEventHandler( "CreateTruckCrate", root, CreateTruckCrate_handler )