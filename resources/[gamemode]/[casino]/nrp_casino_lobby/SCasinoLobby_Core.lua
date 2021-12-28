

local SESSIONS_IS_CRASH = 
{
    [ "Timed out" ] = true,
    [ "Bad Connection" ] = true,
}

local CASINO_LEAVE_POSITION =
{
    [ CASINO_THREE_AXE ] =
    {
        position = Vector3( -52.953, -491.180, 913.988 ),
        dimension = 1,
        interior = 1,
    },
    [ CASINO_MOSCOW ] =
    {
        position = Vector3( 2399.2739, -1312.6672, 2800.0183 ),
        dimension = 1,
        interior = 4,
    }
}

LOBBY_LIST = { }
PLAYERS_LOBBY = { }

function LobbyCreate( self )
    if type( self ) ~= "table" then iprint( "No conf for lobby", conf ) return end

    local id = nil
    for i = 1, math.huge do if not LOBBY_LIST[ i ] then id = i break end end

    self.id = id
    self.unic_game_id = GenerateUniqId()
    self.casino_id    = self.casino_id or CASINO_THREE_AXE
    self.casino_name  = CASIONO_STRING_ID[ self.casino_id ] or "three_axe"
    self.players_list = { }

    self.state = self.state or CASINO_STATE_WAITING

    self.join = function( self, player )
        if self:find( player ) then self:leave( player ) end

        if not player:CanPlayInCasino( self.game ) then return end

        local s_last_serial, s_reg_serial = player:GetPermanentData( "last_serial" ), player:GetPermanentData( "reg_serial" )
        for k, v in pairs( self.players_list ) do
            local t_last_serial, t_reg_serial = v:GetPermanentData( "last_serial" ), v:GetPermanentData( "reg_serial" )
            if s_last_serial == t_last_serial or s_last_serial == t_reg_serial then
                player:ShowError( "Тебе нельзя играть за этим столом" )
                return
            end
        end

        if not self.owner and #self.players_list == 0 then
            self.unic_game_id = GenerateUniqId()
        end

        table.insert( self.players_list, player )
        PLAYERS_LOBBY[ player ] = self.id
        
        triggerEvent( "onCasinoLobbyJoin", player, self.id, self )

        return true
    end

    self.leave = function( self, player, from_destroy, ignore_refund, cancel_join, leave_reason )
        local position = self:find( player )
        if position then
            table.remove( self.players_list, position )
            PLAYERS_LOBBY[ player ] = nil
        end
        
        if cancel_join then return end
        
        if getElementData( player, "in_strip_club" ) then
            local leave_position = Vector3( -42.1276, -102.02158, 1372.7 )
            player:Teleport( leave_position + Vector3( 0, 0, 1 ), 1, 1 )
            
            setTimer( function()
                if isElement( player ) then
                    player.position  = leave_position:AddRandomRange( 3 )
                end
            end, 250, 1 )
        elseif self.state ~= CASINO_STATE_WAITING then
            local casino_data = CASINO_LEAVE_POSITION[ self.casino_id ]

            local leave_position = casino_data.position
            local leave_dimension, leave_interior = casino_data.dimension, casino_data.interior

            player:Teleport( leave_position:AddRandomRange( 3 ), leave_dimension, leave_interior )
        end

        if position then 
            triggerEvent( "onCasinoLobbyLeave", player, self.id, self, from_destroy, ignore_refund, leave_reason ) 
        end

        return true
    end

    self.find = function( self, player )
        for position, v in pairs( self.players_list ) do if v == player then return position end end
    end

    self.destroy = function( self )
        triggerEvent( "onCasinoLobbyPreDestroy", root, self.id, self )
        self.state = nil
        
        local players = table.copy( self.players_list )
        for k, v in pairs( players ) do self:leave( v, true ) end
        
        triggerEvent( "onCasinoLobbyPostDestroy", root, self.id, self )
        setmetatable( self, nil )
        
        return true
    end

    LOBBY_LIST[ id ] = self

    return self
end


--------------------------------------------------------------------------------------------------------------------
-- Запрос данных с клиента
--------------------------------------------------------------------------------------------------------------------

function onServerPlayerRequestLobbyList_handler( casino_id, game_id, player )
    local player = client or player
    if not isElement( player ) then return end
    triggerClientEvent( player, "onPlayerRequestLobbyList_callback", resourceRoot, { lobby_data = GetAvailableLobbyByGameId( casino_id, game_id ), current_lobby = GetPlayerLobbyID( player ) } )
end
addEvent( "onServerPlayerRequestLobbyList", true )
addEventHandler( "onServerPlayerRequestLobbyList", resourceRoot, onServerPlayerRequestLobbyList_handler )

--------------------------------------------------------------------------------------------------------------------
-- Вспомогательный функционал
--------------------------------------------------------------------------------------------------------------------

function LobbyDestroy( lobby_id ) 
    local result = LOBBY_LIST[ lobby_id ]:destroy()
    LOBBY_LIST[ lobby_id ] = nil
    return result
end

function LobbyGet( lobby_id, var )
    return LOBBY_LIST[ lobby_id ] and LOBBY_LIST[ lobby_id ][ var ]
end

function LobbySet( lobby_id, var, value )
    LOBBY_LIST[ lobby_id ][ var ] = value
end

function LobbyCall( lobby_id, fn, ... )
    local lobby = LOBBY_LIST[ lobby_id ]
    if not lobby then return false end 
    
    return lobby[ fn ]( lobby, ... )
end

function LobbyGetAll( lobby_id )
    return LOBBY_LIST[ lobby_id ]
end

function GetAvailableLobbyByGameId( casino_id, game_id ) 
    local lobby_list = { }
    
    for k, v in pairs( LOBBY_LIST ) do
        if v.casino_id == casino_id and v.game == game_id and not v.invisible  then
            table.insert( lobby_list, 
            {
                id          = v.id,
                name        = v.name,
                owner       = v.owner,
                players     = #v.players_list,
                max_players = v.players_count_required,
                game        = v.game,
                bet         = v.bet,
                bet_hard    = v.bet_hard,
                voice_off   = v.voice_off or false,
            } )
        end
    end

    return lobby_list
end

function GetPlayerLobbyID( player )
    return PLAYERS_LOBBY[ player ]
end


Player.CanPlayInCasino = function( self, game_id )
    if self.dead then return false end

    local iAccessLevel = self:GetAccessLevel()
    if not self:getData( "ignore_admin_check" ) and iAccessLevel >= 1 then
        local maria_result = MariaGet("admin_casino_allowed")
        local pData = maria_result and fromJSON( maria_result ) or {}
        local bAllowed = false

        if pData[tostring(iAccessLevel)] == 1 or pData[self:GetClientID()] == 1 then
            bAllowed = true
        end

        --[[if not bAllowed then
            self:ShowError( "Тебе запрещено играть в казино!" )
            return false
        end]]
    end

    local lobby_id = GetPlayerLobbyID( self )
    if lobby_id and LOBBY_LIST[ lobby_id ].game ~= game_id then
        self:ShowError( "Ты уже находишься в лобби другой игры!" )
        return false
    end

    if self:GetCoopJobLobbyId() then
        self:ShowInfo( "Вы не можете принять участие во время смены" )
        return false
    end

    if self:IsInEventLobby( ) then
        self:ShowError( "Нельзя принять участие отсюда!" )
        return false
    end

    if self:getData( "registered_in_clan_event" ) then
        self:ShowError( "Отмени участие в войне кланов!" )
        return false
    end

    local ts = getRealTimestamp()
    local block_ts = self:GetPermanentData( "casino_blocked_ts" ) or 0
    if block_ts >= ts then
        self:ErrorWindow( "Ты был внесен в черный список казино из-за выхода со стола.\nОставшееся время: " .. math.ceil( ( block_ts - ts ) / 60 ) .. " мин." )
        return false
    end

    return true
end

--------------------------------------------------------------------------------------------------------------------
-- Игрок покинул игру досрочно
--------------------------------------------------------------------------------------------------------------------

function onPlayerPreLogout_handler( reason )
    local player = isElement( player ) and player or source
    
    local lobby_id = GetPlayerLobbyID( player )
    if not lobby_id then return end

    triggerEvent( "onCasinoPlayerBlockLobbyJoin", player )
    LobbyCall( lobby_id, "leave", player, false, false, false, SESSIONS_IS_CRASH[ reason ] and "crash" or "other" )
end
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_handler )

function onCasinoPlayerBlockLobbyJoin_handler( )
    local lobby_id = GetPlayerLobbyID( source )
    if lobby_id then
        LobbySet( lobby_id, "players_drop", ( LobbyGet( lobby_id, "players_drop" ) or 0 ) + 1 )
    end

    local ts = getRealTimestamp()
    source:SetBatchPermanentData( {
        casino_blocked_ts     = ts + 10 * 60,
        casino_drop_count     = ( source:GetPermanentData( "casino_drop_count" ) or 0 ) + 1,
        casino_last_drop      = ts,
        casino_last_game_drop = true,
    } )
    
    source:InfoWindow( "Ты вышел из лобби самостоятельно и был заблокирован во всех играх на 10 минут" )
end
addEvent( "onCasinoPlayerBlockLobbyJoin" )
addEventHandler( "onCasinoPlayerBlockLobbyJoin", root, onCasinoPlayerBlockLobbyJoin_handler )

function CleanDatabase( )
    DB:exec( "UPDATE nrp_players SET casino_drop_count=NULL" )
    DATABASE_CLEAN_TIMER = setTimer( CleanDatabase, 24 * 60 * 60 * 1000, 1 )
end
ExecAtTime( "00:00", CleanDatabase )

function GetCasinoLeavePosition( casino_id )
    return CASINO_LEAVE_POSITION[ casino_id ]
end