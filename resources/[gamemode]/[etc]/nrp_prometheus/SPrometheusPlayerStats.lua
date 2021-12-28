function PlayerWatcher( )
    local self = {
        current_players = 0,
        joined_players = 0,
        left_players = 0,
    }

    function self.update_player_count( )
        self.current_players = #getElementsByType( "player" )
    end
    self.update_player_count( )

    function self.on_player_join( )
        self.joined_players = self.joined_players + 1 
        self.update_player_count( )
    end
    addEventHandler( "onPlayerJoin", root, self.on_player_join )

    function self.on_player_quit( )
        self.left_players = self.left_players + 1
        self.update_player_count( )
    end
    addEventHandler( "onPlayerQuit", root, self.on_player_quit )

    function self.get_players_gauge( )
        local category = {
            name = "players",
            type = "gauge",
            help = "Gauge for players",
            metrics = {
                {
                    value = self.current_players,
                    params = { value_type = "current" },
                },
                
            },
        }

        return category
    end

    function self.get_players_counter( )
        local category = {
            name = "players",
            type = "counter",
            help = "Counter for players",
            metrics = {
                {
                    value = self.joined_players,
                    params = { value_type = "joined" },
                },
                {
                    value = self.left_players,
                    params = { value_type = "left" },
                },
            },
        }

        return category
    end

    function self.get_metrics( )
        return table.imerge_all( {
            self.get_players_gauge( ), self.get_players_counter( ),
        } )
    end

    function self.destroy( )
        DestroyTableElements( self )
        self = nil
    end

    return self
end