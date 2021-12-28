local nrp_transfer = getResourceFromName( "nrp_transfer" )
if nrp_transfer and nrp_transfer.state == "running" then
	exports.nrp_transfer:AddTransferDataHandler( )
end

addEventHandler( "onResourceStart", root, function( resource )
	if resource.name == "nrp_transfer" then
		exports.nrp_transfer:AddTransferDataHandler( )
	end
end )

function GetTransferData( player )
    return
end

addEvent( "onTransferPrepareData" )
addEventHandler( "onTransferPrepareData", root, function( )
    local player = source

	DB:queryAsync( function( query )
		if not isElement( player ) then
			query:free( )
			return
		end

		local result = query:poll( 0 ) or { }
        triggerEvent( "onTransferPrepareData_callback", player, {
            transfer_faction_history = result,
        } )
	end, { }, "SELECT * FROM nrp_faction_history WHERE player_id = ?", player:GetUserID( ) )
end )

addEvent( "onTransferFinish", false )
addEventHandler( "onTransferFinish", root, function ( user_id, client_id, transfered_data )
    local history = transfered_data.transfer_faction_history
    if history and next( history ) then
        local keys = {
            "player_id", "faction_id", "action", "timestamp", "reason", "rank"
        }

        local all_values = { }
        for i, row in ipairs( history ) do
            row.player_id = user_id
            
            local values = { }
            for i, k in pairs( keys ) do
                local v = row[ k ]
                table.insert( values, not v and "NULL" or dbPrepareString( DB, "?", v ) )
            end
            table.insert( all_values, table.concat( values, ", " ) )
        end
    
        DB:exec( "INSERT INTO nrp_faction_history ( ".. table.concat( keys, ", ") .." ) VALUES (".. table.concat( all_values, "), (" ) .. ")" )
    end
end )