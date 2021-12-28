local _iprint = iprint
function iprint( ... )
    local is_server = not localPlayer
    return _iprint( is_server, getTickCount( ), ... )
end

ACTION_ARRAY = {
    id = "alexander_get_bike",

    name = "Тестовый action task",

    -- Условия начала задач
    checkpoints = {
        server = function( self, player )

        end,
        client = function( self )

        end,
    },

    -- Начало (любое)
    entrypoints = {
        server = function( self, player )
            iprint( "Serverside ENTRYPOINT", player )
            self.fns.call_client_function( self, player, "test2", "YAY" )
        end,
        client = function( self )
            iprint( "Clientside ENTRYPOINT" )
            self.fns.call_server_function( self, "test1", "YAY AYAYA" )
        end,
    },

    -- Шаги
    steps = {
        [ 1 ] = {
            setup = {
                server = function( self, player, ... )
                    iprint( "Start serverside step 1", player, ... )
                    setTimer( function( )
                        self.fns.step_next( self, player, { "server arg2", 2 }, { "client arg2", 2 } )
                    end, 2000, 1 )
                end,
                client = function( self, ... )
                    iprint( "Start clientside step 1", player, ... )
                end,
            },
            cleanup = {
                server = function( self, player, ... )
                    iprint( "Cleanup serverside step 1", player, ... )
                end,
                client = function( self, ... )
                    iprint( "Cleanup clientside step 1", ... )
                end,
            }
        },

        [ 2 ] = {
            setup = {
                server = function( self, player, ... )
                    iprint( "Start serverside step 2", player, ... )
                    setTimer( function( )
                        self.fns.step_next( self, player, { "server arg3", 3 }, { "client arg3", 3 } )
                    end, 2000, 1 )
                end,
                client = function( self, ... )
                    iprint( "Start clientside step 2", ... )
                end,
            }
        }
    },

    -- Конец (любой)
    exitpoints = {
        server = function( self, player, success, ... )
            iprint( "Serverside EXITPOINT", player, success, ... )
        end,
        client = function( self, success, ... )
            iprint( "Clientside EXITPOINT", success, ... )
        end,
    },

    remote_fns = {
        server = {
            test1 = function( self, player, arg1 )
                iprint( "CALL SERVER FN SUCCESS", player, arg1 )
            end,
        },
        client = {
            test2 = function( self, arg1 )
                iprint( "CALL CLIENT FN SUCCESS", arg1 )
            end,
        },
    }
}