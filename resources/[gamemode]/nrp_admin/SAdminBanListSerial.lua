BAN_PLAYER_DATA = {}

function onResourceStart( )
    CommonDB:createTable( "serial_ban_list",
        {
            { Field = "id",		           Type = "int(11) unsigned",	        Null = "NO",    Key = "PRI",	Extra = "auto_increment"	};
            { Field = "serial",		       Type = "varchar(32)",		        Null = "NO",	Key = "", 	    Default = ""	};
            { Field = "admin_nickname",	   Type = "varchar(32)",	            Null = "NO",    Key = "",	    Default = ""	};
            { Field = "reason",	           Type = "varchar(128)",               Null = "NO",    Key = "",	    Default = ""	};
            { Field = "server_create_ban", Type = "smallint(3)",	            Null = "NO",    Key = ""	};
            { Field = "server",		       Type = "smallint(3)",	            Null = "NO",    Key = ""	};
            { Field = "admin_id",		   Type = "int(11) unsigned",	        Null = "NO",    Key = ""	};
            { Field = "date",			   Type = "int(11) unsigned",	        Null = "NO",	Key = ""	};
        }
    )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart )

function GetPlayerBanDataBySerial( serial )
    if BAN_PLAYER_DATA[ serial ] then
        return BAN_PLAYER_DATA[ serial ]
    end
    return false
end

function UpdateBanListSerial_handler( )
    if not isElement( client ) or not client:IsAdmin( ) then return end

    CommonDB:queryAsync( function( query, player )
        if not isElement( player ) then iprint( "RETURN UPDATE" ) return end

        local ban_list_serial = query:poll( -1 )
        if not ban_list_serial then player:ShowError( "Список пуст" ) return end
 
        triggerClientEvent( player, "ReceiveBanListSerial", resourceRoot, ban_list_serial )
    end, { client }, "SELECT * FROM serial_ban_list" )
end
addEvent( "UpdateBanListSerial", true )
addEventHandler( "UpdateBanListSerial", resourceRoot, UpdateBanListSerial_handler )

function SearchBanListSerial_handler( serial )
    if not isElement( client ) or not client:IsAdmin( ) or not serial then return end

    CommonDB:queryAsync( function( query, player )
        if not isElement( player ) then return end

        local ban_list_serial = query:poll( -1 )
        if not ban_list_serial or #ban_list_serial == 0 then player:ShowError( "Нет совпадений" ) return end

        triggerClientEvent( player, "ReceiveBanListSerial", resourceRoot, ban_list_serial )
    end, { client }, "SELECT * FROM serial_ban_list WHERE serial=?", serial )
end
addEvent( "SearchBanListSerial", true )
addEventHandler( "SearchBanListSerial", resourceRoot, SearchBanListSerial_handler )

function SetBanSerial( serial, server, reason, client )
    CommonDB:queryAsync( function( query, serial, server, reason, player )
        if player and not isElement( player ) then return end

        local ban_list_serial = query:poll( -1 )
		if not ban_list_serial or #ban_list_serial == 0 then
			if player then
				player:ShowInfo( "Серийный номер забанен" )
			end

            local player_ban = nil
            for k, v in ipairs( getElementsByType( "player" ) ) do
                if serial == getPlayerSerial( v ) then
                    player_ban = v
                    break
                end
            end

            if isElement( player_ban ) then player_ban:kick( "Вы забанены" ) end

            CommonDB:exec( [[
                INSERT INTO serial_ban_list ( serial, server, server_create_ban, admin_id, admin_nickname, reason, date ) VALUES ( ?, ?, ?, ?, ?, ?, ? )
            ]], serial, server, SERVER_NUMBER, player and player:GetID( ) or 0, player and player:GetNickName( ) or "SERVER", reason, getRealTimestamp( ) )

			RefreshBanList()

        elseif player then
            player:ShowError( "Серийный номер уже забанен" )
        end
    end, { serial, server, reason, client }, "SELECT * FROM serial_ban_list WHERE serial = ? AND server = ?", serial, server )
end

function SetBanSerial_handler( serial, server, reason )
	if not isElement( client ) or not client:IsAdmin( ) or not serial or not server or not reason then return end

	SetBanSerial( serial, server, reason, client )
end
addEvent( "SetBanSerial", true )
addEventHandler( "SetBanSerial", resourceRoot, SetBanSerial_handler )

function SetBanSerialByServer_handler( serial, server, reason )
	SetBanSerial( serial, server, reason )
end
addEvent( "SetBanSerialByServer" )
addEventHandler( "SetBanSerialByServer", root, SetBanSerialByServer_handler )

function SetUnBanSerial_handler( serial )
    if not isElement( client ) or not client:IsAdmin( ) or not serial then return end
    client:ShowInfo( "Серийный номер разбанен" )
    CommonDB:exec("DELETE FROM serial_ban_list WHERE serial = ?", serial )
    
    RefreshBanList()
end
addEvent( "SetUnBanSerial", true )
addEventHandler( "SetUnBanSerial", resourceRoot, SetUnBanSerial_handler )

function RefreshBanList()    
    CommonDB:queryAsync( function( query )
        BAN_PLAYER_DATA = {}

        local ban_players_data = query:poll( -1 )
        if ban_players_data and #ban_players_data > 0 then
            for k, v in pairs( ban_players_data ) do
                BAN_PLAYER_DATA[ v.serial ] = v
            end
        end
    end, { }, "SELECT serial, server, server_create_ban, admin_id, admin_nickname, reason, date FROM serial_ban_list" )
end
REFRESH_BAN_LIST_TMR = setTimer( RefreshBanList, 60000 * 5, 0 )