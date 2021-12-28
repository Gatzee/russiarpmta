Extend( "SPlayer" )
Extend( "ShTimelib" )
Extend( "SInterior" )
Extend( "SDB" )

local GAME_MARKERS = 
{
    { x = -63.904, y = -501.591, z = 913.972, interior = 1, dimension = 1, casino_id = CASINO_THREE_AXE, game = CASINO_GAME_BLACK_JACK, text = "ALT Взаимодействие", keypress = "lalt" },

    { x = -65.337, y = -478.775, z = 913.972, interior = 1, dimension = 1, casino_id = CASINO_THREE_AXE, game = CASINO_GAME_DICE, text = "ALT Взаимодействие", keypress = "lalt" },
    { x = -71.275, y = -478.897, z = 913.972, interior = 1, dimension = 1, casino_id = CASINO_THREE_AXE, game = CASINO_GAME_DICE, text = "ALT Взаимодействие", keypress = "lalt" },

    { x = -88.262, y = -478.594, z = 913.972, interior = 1, dimension = 1, casino_id = CASINO_THREE_AXE, game = CASINO_GAME_ROULETTE, text = "ALT Взаимодействие", keypress = "lalt" },
    { x = -82.585, y = -478.767, z = 913.972, interior = 1, dimension = 1, casino_id = CASINO_THREE_AXE, game = CASINO_GAME_ROULETTE, text = "ALT Взаимодействие", keypress = "lalt" },

    { x = -72.7701, y = -501.7962, z = 913.9721,  interior = 1, dimension = 1, casino_id = CASINO_THREE_AXE, game = CASINO_GAME_CLASSIC_ROULETTE, text = "ALT Взаимодействие", keypress = "lalt" },
	{ x = -36.4872, y = -101.6683, z = 1372.6600, interior = 1, dimension = 1, casino_id = CASINO_THREE_AXE, game = CASINO_GAME_CLASSIC_ROULETTE, text = "ALT Взаимодействие", keypress = "lalt" },
	
	{ x = -58.8001, y = -478.7322, z = 913.9721, interior = 1, dimension = 1, is_slot_machine = true, marker_icon = 6, casino_id = CASINO_THREE_AXE, game = CASINO_GAME_SLOT_MACHINE_GOLD_SKULL, text = "ALT Взаимодействие", keypress = "lalt" },
    { x = -45.8087, y = -482.9083, z = 913.9731, interior = 1, dimension = 1, is_slot_machine = true, marker_icon = 6, casino_id = CASINO_THREE_AXE, game = CASINO_GAME_SLOT_MACHINE_VALHALLA,   text = "ALT Взаимодействие", keypress = "lalt" },
    { x = -59.4821, y = -503.5001, z = 913.9731, interior = 1, dimension = 1, is_slot_machine = true, marker_icon = 6, casino_id = CASINO_THREE_AXE, game = CASINO_GAME_SLOT_MACHINE_CHICAGO,    text = "ALT Взаимодействие", keypress = "lalt" },

    -- Москва
    { x = 2399.0246, y = -1302.0091, z = 2794.8012, interior = 4, dimension = 1, casino_id = CASINO_MOSCOW, game = CASINO_GAME_ROULETTE, text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },
    { x = 2399.1169, y = -1282.9083, z = 2794.8012, interior = 4, dimension = 1, casino_id = CASINO_MOSCOW, game = CASINO_GAME_ROULETTE, text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },
    { x = 2406.2873, y = -1294.9858, z = 2794.8012, interior = 4, dimension = 1, casino_id = CASINO_MOSCOW, game = CASINO_GAME_ROULETTE, text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },
    { x = 2392.1542, y = -1295.0473, z = 2794.8012, interior = 4, dimension = 1, casino_id = CASINO_MOSCOW, game = CASINO_GAME_ROULETTE, text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },

    { x = 2370.6013, y = -1325.5246, z = 2800.0703, interior = 4, dimension = 1, casino_id = CASINO_MOSCOW, game = CASINO_GAME_DICE, text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },
    { x = 2364.5361, y = -1325.5246, z = 2800.0703, interior = 4, dimension = 1, casino_id = CASINO_MOSCOW, game = CASINO_GAME_DICE, text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },
    { x = 2364.5361, y = -1315.3166, z = 2800.0703, interior = 4, dimension = 1, casino_id = CASINO_MOSCOW, game = CASINO_GAME_DICE, text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },
    { x = 2370.6013, y = -1315.3166, z = 2800.0703, interior = 4, dimension = 1, casino_id = CASINO_MOSCOW, game = CASINO_GAME_DICE, text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },
    
    { x = 2432.0661, y = -1317.4940, z = 2800.0703, interior = 4, dimension = 1, casino_id = CASINO_MOSCOW, game = CASINO_GAME_BLACK_JACK,       text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },
    { x = 2436.4536, y = -1317.4940, z = 2800.0703, interior = 4, dimension = 1, casino_id = CASINO_MOSCOW, game = CASINO_GAME_BLACK_JACK,       text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },
    { x = 2441.6220, y = -1314.3758, z = 2800.0703, interior = 4, dimension = 1, casino_id = CASINO_MOSCOW, game = CASINO_GAME_BLACK_JACK,       text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },
    { x = 2436.7167, y = -1314.3758, z = 2800.0703, interior = 4, dimension = 1, casino_id = CASINO_MOSCOW, game = CASINO_GAME_BLACK_JACK,       text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },

    { x = 2434.9572, y = -1324.7283, z = 2800.0703, interior = 4, dimension = 1, casino_id = CASINO_MOSCOW, game = CASINO_GAME_CLASSIC_ROULETTE, text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },
    { x = 2437.0630, y = -1326.5828, z = 2800.0703, interior = 4, dimension = 1, casino_id = CASINO_MOSCOW, game = CASINO_GAME_CLASSIC_ROULETTE, text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },    
    { x = 2443.6801, y = -1326.4600, z = 2800.0703, interior = 4, dimension = 1, casino_id = CASINO_MOSCOW, game = CASINO_GAME_CLASSIC_ROULETTE_VIP, text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },

	{ x = 2407.5520, y = -1274.3873, z = 2800.0822, interior = 4, dimension = 1, is_slot_machine = true, marker_icon = 6, casino_id = CASINO_MOSCOW, game = CASINO_GAME_SLOT_MACHINE_GOLD_SKULL, text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },
    { x = 2413.0820, y = -1274.1466, z = 2800.0822, interior = 4, dimension = 1, is_slot_machine = true, marker_icon = 6, casino_id = CASINO_MOSCOW, game = CASINO_GAME_SLOT_MACHINE_GOLD_SKULL, text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },

    { x = 2387.0898, y = -1272.6088, z = 2800.4643, interior = 4, dimension = 1, is_slot_machine = true, marker_icon = 6, casino_id = CASINO_MOSCOW, game = CASINO_GAME_SLOT_MACHINE_VALHALLA,   text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },
    { x = 2387.0583, y = -1268.5279, z = 2800.4643, interior = 4, dimension = 1, is_slot_machine = true, marker_icon = 6, casino_id = CASINO_MOSCOW, game = CASINO_GAME_SLOT_MACHINE_VALHALLA,   text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },
    
    { x = 2390.8637, y = -1291.5424, z = 2800.0822, interior = 4, dimension = 1, is_slot_machine = true, marker_icon = 6, casino_id = CASINO_MOSCOW, game = CASINO_GAME_SLOT_MACHINE_CHICAGO,    text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },
    { x = 2385.5835, y = -1291.5305, z = 2800.0822, interior = 4, dimension = 1, is_slot_machine = true, marker_icon = 6, casino_id = CASINO_MOSCOW, game = CASINO_GAME_SLOT_MACHINE_CHICAGO,    text = "ALT Взаимодействие", keypress = "lalt", radius = 1.5 },
}

function onStart()
    for k, v in pairs( GAME_MARKERS ) do
        v.marker_text = v.marker_text or CASINO_GAMES_NAMES[ v.game ]
        v.color       = { 255, 50, 0, 20 }
        v.keypress    = v.keypress or false
        v.radius      = v.radius or 2.5
        
        local tpoint    = TeleportPoint( v )
        tpoint.PostJoin = nil

        if v.is_slot_machine then
            tpoint.PostJoin = function( self, player )
                if player:getData( "is_menu_open" ) then return false end
                    
                if not player:CanPlayInCasino( self.game ) then return false end
                player:setData( "is_menu_open", true, false )

                local top_data = RequestCasinoGameTopStats( player, self.casino_id, self.game )
                triggerClientEvent( player, "onSlotMachineMarkerTriggered", player, self.casino_id, self.game, top_data ) 
            end
        else
            tpoint.PostJoin = function( self, player )
                if player:getData( "is_menu_open" ) then return false end

                if not player:CanPlayInCasino( self.game ) then return false end                
                player:setData( "is_menu_open", true, false )
                
                local top_data = RequestCasinoGameTopStats( player, self.casino_id, self.game )
                local game_can_create_lobby = {
                    [ CASINO_GAME_DICE ] = true,
                    [ CASINO_GAME_ROULETTE ] = true,
                }

                local data = 
                {
                    casino_id     = self.casino_id,
                    game_id       = self.game,
                    top_data      = top_data,
                    create_lobby  = game_can_create_lobby[ self.game ] or false,
                    lobby_data    = GetAvailableLobbyByGameId( self.casino_id, self.game ),
                    current_lobby = GetPlayerLobbyID( player ),
                }

                triggerClientEvent( player, "onClientShowUICasinoGame", root, true, data ) 
            end
        end
        
        tpoint.PostLeave = function( self, player )
            player:setData( "is_menu_open", false, false )
            triggerClientEvent( player, "onClientShowUICasinoGame", root, false )
        end

        tpoint:SetImage( "img/marker/marker_icon_" .. (v.marker_icon or v.game) .. ".png" )
        tpoint.element:setData( "material", true, false )
        tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, v.radius * 0.75 } )
    end

    CreateStaticLobby()
end
addEventHandler( "onResourceStart", resourceRoot, onStart )


if SERVER_NUMBER > 100 then
    addCommandHandler( "ignore_admin_check", function( player )
        player:setData( "ignore_admin_check", not player:getData( "ignore_admin_check" ), false )
    end )
end