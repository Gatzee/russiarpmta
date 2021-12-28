loadstring(exports.interfacer:extend("Interfacer"))()
Extend("Globals")
Extend("ShUtils")
Extend("SPlayer")
Extend("SDB")

DB:createTable("nrp_faction_history", {
    { Field = "id",					Type = "int(11) unsigned",			Null = "NO",	Key = "PRI",		Default = NULL, Extra = "auto_increment"  };
    { Field = "player_id",			Type = "int(11) unsigned",			Null = "NO",	Key = "",			Default = NULL  };
	{ Field = "faction_id",			Type = "text",						Null = "NO",	Key = "",			Default = NULL	};
	{ Field = "action",				Type = "text",						Null = "NO",	Key = "",			Default = NULL	};
	{ Field = "timestamp",			Type = "int(11) unsigned",			Null = "NO",	Key = "",			Default = NULL	};
	{ Field = "reason",				Type = "text",						Null = "NO",	Key = "",			Default = NULL	};
	{ Field = "rank",				Type = "text",						Null = "NO",	Key = "",			Default = NULL	};
})

function AddRecord( pPlayer, iFaction, sAction, sReason, sRank )
	local iUserID = isElement(pPlayer) and pPlayer:GetUserID() or pPlayer
	if not iUserID or not tonumber(iUserID) then return end
	
	DB:exec("INSERT INTO nrp_faction_history (player_id, faction_id, action, timestamp, reason, rank) VALUES (?, ?, ?, ?, ?, ?)",
		iUserID, iFaction, sAction, getRealTime().timestamp, sReason, sRank)
end
addEvent("AddFactionRecord", true)
addEventHandler("AddFactionRecord", root, AddRecord)

function ClearHistory( iUserID )
	if not iUserID or not tonumber(iUserID) then return end
	DB:exec("DELETE FROM nrp_faction_history WHERE player_id = ?", iUserID)
end

function RemoveRecord( id )
	if not id or not tonumber(id) then return end
    --outputDebugString( "Remove record id: " .. id )
	DB:exec("DELETE FROM nrp_faction_history WHERE id = ?", id)
end

function OnPlayerRequestFactionHistory( pPlayer, iUserID )
	local pPlayer = pPlayer or client
	if pPlayer:getData("is_fishing") then return end
	if pPlayer:getData("in_clan_event_lobby") then return end

	DB:queryAsync( function( query, pPlayer, source )		
		if not isElement( pPlayer ) or not isElement( source ) then
			query:free( )
			return
		end

		local result = query:poll( 0 ) or { }
		triggerClientEvent( pPlayer, "ShowFactionHistoryUI", source, true, result )

	end, { pPlayer, source }, "SELECT * FROM nrp_faction_history WHERE player_id = ?", iUserID)

end
addEvent("OnPlayerRequestFactionHistory", true)
addEventHandler("OnPlayerRequestFactionHistory", root, OnPlayerRequestFactionHistory)

function onAdminRemoveFactionHistoryRecord_handler( iRecordId, iUserID )
    if not tonumber( iRecordId ) then return end
    if not tonumber( iUserID ) then return end
    if not isElement( client ) then return end
    if client:GetAccessLevel( ) < ACCESS_LEVEL_SUPERVISOR then return end

    RemoveRecord( iRecordId )

    triggerEvent( "OnPlayerRequestFactionHistory", client, client, iUserID )
end
addEvent( "onAdminRemoveFactionHistoryRecord", true )
addEventHandler( "onAdminRemoveFactionHistoryRecord", resourceRoot, onAdminRemoveFactionHistoryRecord_handler )
