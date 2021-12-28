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

    if player:GetPermanentData( "wedding_at_id" ) then
        table.insert( list_saved, { text = "Брак (при переезде с партнером вместе)" } )
    end
	if player:GetPermanentData( "engage_item_applyed" ) then
        table.insert( list_saved, { text = "Свадебный набор" } )
	end

    return currency, logdata, info, list_saved
end

addEvent( "onTransferPrepareData" )
addEventHandler( "onTransferPrepareData", root, function( )
    local player = source
	local wedding_at_id = player:GetPermanentData( "wedding_at_id" )
	if not wedding_at_id then
		triggerEvent( "onTransferPrepareData_callback", player )
		return
	end

	local partner = GetPlayer( wedding_at_id )
	if partner then
		partner:SetPermanentData( "transfer_wedding_at_client_id", player:GetClientID() )
		triggerEvent( "onTransferPrepareData_callback", player )
	else
		DB:queryAsync( function( query )
			if not isElement( player ) then
				dbFree( query )
				return
			end

			local result = query:poll( -1 )[ 1 ] or { }
			local partner_client_id = result.client_id
			if partner_client_id and #partner_client_id == 36 then
				-- Партнёр ещё не переехал, сохраняем ему в пермадате наш client_id, т.к. после переноса он будет заменен серийником
				DB:exec( "UPDATE nrp_players SET permanent_data = JSON_SET( permanent_data, '$.transfer_wedding_at_client_id', ? ) WHERE id = ?", player:GetClientID(), wedding_at_id )
			end
			triggerEvent( "onTransferPrepareData_callback", player )
		end, {}, "SELECT client_id FROM nrp_players WHERE id = ? LIMIT 1", wedding_at_id )
	end
end )

addEvent( "onTransferClearOldData" )
addEventHandler( "onTransferClearOldData", root, function( )
    local player = source
    local wedding_at_id = player:GetPermanentData( "wedding_at_id" )
    if wedding_at_id then
        DB:exec( "UPDATE nrp_players SET wedding_at_id = NULL WHERE id = ?", wedding_at_id )
    end
end )

addEvent( "onPlayerJoinAfterTransfer" )
addEventHandler( "onPlayerJoinAfterTransfer", root, function( )
    local player = source
	local wedding_at_client_id = player:GetPermanentData( "transfer_wedding_at_client_id" )
	if wedding_at_client_id then
		player:SetPermanentData( "transfer_wedding_at_client_id", nil )

		local user_id = player:GetUserID()
		DB:queryAsync( function( query )
			local result = query:poll( -1 )[ 1 ]
			if result then
				-- Если партнер уже вступил в брак на новом сервере
				if result.wedding_at_id and result.wedding_at_id > 0 then return end

				DB:exec( "UPDATE nrp_players SET wedding_at_id = ? WHERE id = ?", user_id, result.id )
				DB:exec( "UPDATE nrp_players SET wedding_at_id = ? WHERE id = ?", result.id, user_id )

				local partner = GetPlayer( result.id )
				if partner then
					partner:SetPermanentData( "wedding_at_id", user_id )
					partner:PreparePlayerInfo( )
				end
				if isElement( player ) then
					player:SetPermanentData( "wedding_at_id", result.id )
					player:PreparePlayerInfo( )
				end
			end
		end, {}, "SELECT id, wedding_at_id FROM nrp_players WHERE client_id = ? LIMIT 1", wedding_at_client_id )

	elseif player:GetPermanentData( "engage_item_applyed" ) then
		player:InventoryAddItem( IN_WEDDING_START, nil, 1 )
		player:SetPermanentData( "engage_item_applyed", nil )
	end
end )