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
	local list_saved = { }

    table.insert( list_saved, { text = "Рейтинг в гонках" } )

    return currency, logdata, info, list_saved
end

addEvent( "onTransferPrepareData" )
addEventHandler( "onTransferPrepareData", root, function( )
    local player = source
    triggerEvent( "onTransferPrepareData_callback", player )
end )

addEvent( "onTransferClearOldData" )
addEventHandler( "onTransferClearOldData", root, function( )
    local player = source
    RemoveRecordsByClientID( player:GetClientID( ) )
end )

addEvent( "onTransferFinish" )
addEventHandler( "onTransferFinish", root, function( user_id, client_id, transfered_data )
    DB:queryAsync( function( qh )
        local result = dbPoll( qh, -1 )
        if type( result ) ~= "table" then return end
        
        for k, v in pairs( result ) do
            table.insert( RECORDS_CACHE, CreateRecordModel( v ) )
        end
        RefreshRecordsData()
    end, {}, 
        [[SELECT V.id, V.model, V.variant, V.race_circle_count, V.race_circle_points, V.race_drift_count, V.race_drift_points, V.race_drag_count, V.race_drag_points, P.client_id,  P.clan_id
        FROM nrp_vehicles AS V
        LEFT JOIN nrp_players AS P
        ON V.owner_pid = CONCAT( "p:",P.id )
        WHERE P.client_id = ? AND (V.race_circle_count > 0 OR V.race_drift_count > 0 OR V.race_drag_count > 0)]], client_id )
end )