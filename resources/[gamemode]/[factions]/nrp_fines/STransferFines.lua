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
    local saved = { }

    local fines = player:GetFines( )
    if next( fines ) then
        table.insert( saved, { text = "Штрафы (" .. #fines .. " шт.)" } )
    end

    return currency, logdata, info, saved
end

addEvent( "onTransferPrepareData" )
addEventHandler( "onTransferPrepareData", root, function( )
    local player = source

	triggerEvent( "onTransferPrepareData_callback", player, {
        transfer_fines = player:GetFines( ),
    } )
end )

addEvent( "onTransferFinish", false )
addEventHandler( "onTransferFinish", root, function ( user_id, client_id, transfered_data )
    local fines = transfered_data.transfer_fines
    if fines and next( fines ) then
        local keys = {
            "fine_id",
            "reason",
            "cost",
            "creation_date",
            "target_uid",
            "source_uid",
            "target_name",
            "source_name",
        }

        local all_values = { }
        for i, fine in ipairs( fines ) do
            fine.target_uid = user_id
            fine.source_uid = 0
            fine.source_name = "-"
            
            local values = { }
            for i, k in pairs( keys ) do
                local v = fine[ k ]
                table.insert( values, not v and "NULL" or dbPrepareString( DB, "?", v ) )
            end
            table.insert( all_values, table.concat( values, ", " ) )
        end
    
        DB:exec( "INSERT INTO nrp_fines ( ".. table.concat( keys, ", ") .." ) VALUES (".. table.concat( all_values, "), (" ) .. ")" )
    end
end )