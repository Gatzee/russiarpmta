Extend("SDB")
Extend("ShVehicleConfig")
Extend("SVehicle")
Extend("SPlayer")
Extend("rewards/Server")

local CURRENT_AUCTION 
local AUCTIONS_LIST
local notify_timer

function OnResourceStart()
	DB:createTable("nrp_vehicle_auction", 
	{
		{ Field = "id",			Type = "int(11) unsigned",	Null = "NO",	Key = "PRI",	Default = NULL };
		{ Field = "items",		Type = "text",				Null = "NO",	Key = "",		Default = NULL };
		{ Field = "finish_ts",	Type = "int(11) unsigned",	Null = "NO",	Key = "",		Default = NULL };
		{ Field = "last_bets",	Type = "text",				Null = "NO",	Key = "",		Default = NULL };
	})

	DB:createTable("nrp_vehicle_auction_bets", 
	{
		{ Field = "player_id",		Type = "int(11) unsigned",	Null = "NO",	Key = "",		Default = NULL };
		{ Field = "player_name",	Type = "text",				Null = "NO",	Key = "",		Default = NULL };
		{ Field = "skin_id",		Type = "int(11) unsigned",	Null = "NO",	Key = "",		Default = NULL };
		{ Field = "auction_id",		Type = "int(11) unsigned",	Null = "NO",	Key = "",		Default = NULL };
		{ Field = "item_id",		Type = "int(11) unsigned",	Null = "NO",	Key = "",		Default = NULL };
		{ Field = "value",			Type = "int(11) unsigned",	Null = "NO",	Key = "",		Default = NULL };
		{ Field = "timestamp",		Type = "int(11) unsigned",	Null = "NO",	Key = "",		Default = NULL };
		{ Field = "returned",		Type = "enum('yes','no')",	Null = "NO",	Key = "",		Default = "no" };
	})

	LoadAuctionsData( )

	triggerEvent( "onSpecialDataRequest", root, "vehicle_auction" )
end
addEventHandler("onResourceStart", resourceRoot, OnResourceStart)

function OnResourceStop()
	if CURRENT_AUCTION then
	    for i, player in pairs( GetPlayersInGame() ) do
	        if player:getData( "vehicle_auction" ) then
	            player:SetPrivateData( "vehicle_auction", false )
	        end
	    end
	end
end
addEventHandler("onResourceStop", resourceRoot, OnResourceStop)


function LoadAuctionsData( )
	DB:queryAsync( function( qh )
		AUCTIONS_LIST = { }

        local result = qh:poll( -1 )
        if not result or #result == 0 then
        	return 
        end

        for k,v in pairs( result ) do
        	v.items = fromJSON( v.items )
        	v.last_bets = fromJSON( v.last_bets )
        	AUCTIONS_LIST[ v.id ] = v

        	if getRealTimestamp() > v.finish_ts then
        		v.finished = true
        	end
        end

    end, {}, "SELECT * FROM nrp_vehicle_auction" )
end

function UpdateAuction( data )
    if not data or #data <= 0 then
        OnAuctionFinish( )
        return 
    end

    local auction_data = data[1]

    auction_data.start_ts = getTimestampFromString( auction_data.start_ts )
    auction_data.finish_ts = getTimestampFromString( auction_data.finish_ts )
    auction_data.bets = { }

    for k,v in pairs( auction_data.items ) do
    	auction_data.bets[ k ] = { }
    end

    DB:queryAsync( function( qh, auction_data )
        local result = qh:poll( -1 )
        if not result or #result == 0 then
        	local empty_items_table = { }

        	for k,v in pairs( auction_data.items ) do
        		empty_items_table[k] = v
        	end

        	DB:exec( "INSERT INTO nrp_vehicle_auction ( id, items, finish_ts, last_bets ) VALUES( ?, ?, ?, ? )", 
        		auction_data.start_ts, toJSON( empty_items_table ), auction_data.finish_ts, toJSON( { 0, 0, 0 } ) )

        	LoadAuctionsData( )

        	OnAuctionStart( auction_data )
        	return 
        end

        local items = result[1] and fromJSON( result[1].items )

        OnAuctionStart( auction_data )
    end, { auction_data }, "SELECT * FROM nrp_vehicle_auction WHERE id = ?", auction_data.start_ts )
end

function OnAuctionStart( data )
    if CURRENT_AUCTION then return end
	CURRENT_AUCTION = data

	local iDiff = CURRENT_AUCTION.finish_ts - getRealTimestamp()
	setTimer(OnAuctionFinish, iDiff*1000, 1)

	DB:queryAsync( function( qh, auction_data )
        local result = qh:poll( -1 )
        if not result or #result == 0 then
        	for i, player in pairs( GetPlayersInGame() ) do
		        OnPlayerReadyToPlay( player )
		    end
        	return
        end

        local bets = result

        local highest_bets = { 0, 0, 0 }

        for k,v in pairs( bets ) do
        	CURRENT_AUCTION.bets[ v.item_id ][ v.player_id ] = v

        	if v.value >= highest_bets[ v.item_id ] then
        		highest_bets[ v.item_id ] = v.value
        		CURRENT_AUCTION.items[ v.item_id ].last_bet = v
        	end
        end

        for i, player in pairs( GetPlayersInGame() ) do
	        OnPlayerReadyToPlay( player )
	    end

	    notify_timer = setTimer( NotifyLosingBets, 60*60*1000, 0 )

    end, { }, "SELECT * FROM nrp_vehicle_auction_bets WHERE auction_id = ?", data.start_ts )
end

function OnAuctionFinish()
	CURRENT_AUCTION = nil

    for i, player in pairs( GetPlayersInGame() ) do
        OnPlayerReadyToPlay( player )
    end

    if isTimer( notify_timer ) then killTimer( notify_timer ) end
end

function onSpecialDataUpdate_handler( key, data )
    if not key or key ~= "vehicle_auction" then return end
    UpdateAuction( data )
end
addEventHandler( "onSpecialDataUpdate", root, onSpecialDataUpdate_handler )

function SyncAuctionData( player, open_ui )
    local client_data = false

    if CURRENT_AUCTION then
    	local client_items = {}

    	for k,v in pairs( CURRENT_AUCTION.items ) do
    		local player_bet = GetPlayerBet( player, k )

    		client_items[ k ] = table.copy( v )
    		client_items[ k ].my_bet = player_bet
    	end

        client_data = 
        {
            start_ts = CURRENT_AUCTION.start_ts,
            finish_ts = CURRENT_AUCTION.finish_ts,
            items = client_items,
        }

        if not player:getData( "vehicle_auction" ) then
        	player:SetPrivateData( "vehicle_auction", client_data )
        end

        client_data = toJSON( client_data )
    end

    triggerClientEvent( player, "OnClientAuctionDataReceived", resourceRoot, client_data, open_ui )
end

function SyncAuctionUIData( player, item_id )
	if CURRENT_AUCTION then
		local item_data = CURRENT_AUCTION.items[ item_id ]
		local player_bet = GetPlayerBet( player, item_id )

		local data = 
		{
			last_bet = item_data.last_bet,
			my_bet = player_bet
		}

		triggerClientEvent( player, "OnClientAuctionItemDataReceived", resourceRoot, item_id, data )
	end
end

function OnPlayerReadyToPlay( player )
    local player = isElement( player ) and player or source
    if not player:HasFinishedTutorial( ) then return end
    if player:GetPermanentData( "donate_total" ) < 35000 then return end

    if CURRENT_AUCTION then
        SyncAuctionData( player, true )

        local last_auction_shown = player:GetPermanentData( "last_vehicle_auction_shown" ) or 0
        if last_auction_shown ~= CURRENT_AUCTION.start_ts then
            player:SetPermanentData( "last_vehicle_auction_shown", CURRENT_AUCTION.start_ts )
            SendElasticGameEvent( player:GetClientID( ), "unique_cars_auction_showfirst" )
        end
    else
    	local last_auction = player:GetPermanentData( "participated_vehicle_auction" )
    	if last_auction then
    		local auction_data = GetAuctionData( last_auction )
    		if auction_data and auction_data.finished then
    			ReturnPlayerBets( player )
    		end
    	end

    	if player:getData( "vehicle_auction" ) then
    		player:SetPrivateData( "vehicle_auction", false )
    	end
    end
end
addEventHandler( "onPlayerReadyToPlay", root, OnPlayerReadyToPlay, _, "low" )

function OnClientRequestAuctionData( )
    SyncAuctionData( client, true )
end
addEvent( "OnClientRequestAuctionData", true)
addEventHandler( "OnClientRequestAuctionData", resourceRoot, OnClientRequestAuctionData )

function OnPlayerTryPlaceBet( item_id, value, old_bet_pid )
	if not CURRENT_AUCTION then return end
	if CURRENT_AUCTION.items[ item_id ].start_bet > value then
		client:ShowError( "Нельзя сделать ставку ниже минимальной" )
		return 
	end

	if client:HasVehicle( CURRENT_AUCTION.items[ item_id ].id ) then
		client:ShowError( "Даннный автомобиль уже нахожится у вас в гараже." )
		return
	end

	if CURRENT_AUCTION.items[ item_id ].last_bet then
		if old_bet_pid and CURRENT_AUCTION.items[ item_id ].last_bet.player_id ~= old_bet_pid then
			local item_data = CURRENT_AUCTION.items[ item_id ]
			local player_bet = GetPlayerBet( client, item_id )

			local data = 
			{
				last_bet = item_data.last_bet,
				my_bet = player_bet
			}

			client:ShowNotification( "Информация по ставкам обновлена" )

			triggerClientEvent( client, "OnClientAuctionItemDataReceived", resourceRoot, item_id, data )
			return
		end

		if CURRENT_AUCTION.items[ item_id ].last_bet.value >= value then
			client:ShowError( "Нельзя сделать ставку ниже текущей" )
			return 
		end

		local item_bet_step = math.ceil( CURRENT_AUCTION.items[ item_id ].start_bet * BET_STEP_PERCHANT )
		if value < CURRENT_AUCTION.items[ item_id ].last_bet.value + item_bet_step then
			client:ShowError( "Минимальный шаг ставки для этого лота: "..item_bet_step )
			return 
		end
	end

	local last_player_bet = GetPlayerBet( client, item_id )

	local is_skipping = false
	if last_player_bet then
		local diff = getRealTimestamp() - last_player_bet.timestamp
		if diff < 60 * 60 then
			is_skipping = true
		end
	end

	local skip_cost = math.ceil( CURRENT_AUCTION.items[ item_id ].start_bet * BET_SKIP_PERCHANT )
	local value_diff = value - ( last_player_bet and last_player_bet.value or 0 )
	if client:GetDonate() < value_diff + ( is_skipping and skip_cost or 0 ) then
		client:ShowError( "Недостаточно средств" )
		return 
	end

	if is_skipping then
		client:TakeDonate( skip_cost, "sale", "unique_cars_auction_skiptime" )
	end

	client:TakeDonate( value_diff, "sale", "unique_cars_auction_bets" )

	local bet_data = 
	{
		player_id = client:GetID(),
		player_name = client:GetNickName( ),
		skin_id = client.model,
		value = value,
		timestamp = getRealTimestamp(),
	}

	if CURRENT_AUCTION.items[ item_id ].last_bet then
		local prev_player = GetPlayer( CURRENT_AUCTION.items[ item_id ].last_bet.player_id )

		if prev_player then
			prev_player:PhoneNotification( {
				title = "Аукцион";
				msg = "Твою ставку на \""..CURRENT_AUCTION.items[item_id].name.."\" перебили!";
			} )
		end
	end

	CURRENT_AUCTION.items[ item_id ].last_bet = bet_data
	CURRENT_AUCTION.bets[ item_id ][ client:GetID() ] = bet_data

	if last_player_bet then
		DB:exec( "UPDATE nrp_vehicle_auction_bets SET value = ? WHERE auction_id = ? AND player_id = ? AND item_id = ?", 
			value, CURRENT_AUCTION.start_ts, client:GetID(), item_id )
	else
		DB:exec( "INSERT INTO nrp_vehicle_auction_bets ( auction_id, item_id, player_id, player_name, skin_id, value, timestamp ) VALUES( ?, ?, ?, ?, ?, ?, ? )", 
		CURRENT_AUCTION.start_ts, item_id, client:GetID(), client:GetNickName(), client.model, value, getRealTimestamp() )
	end

	local auction_data = GetAuctionData( CURRENT_AUCTION.start_ts )
	local last_bets = auction_data and auction_data.last_bets
	last_bets[ item_id ] = value

	DB:exec( "UPDATE nrp_vehicle_auction SET last_bets = ? WHERE id = ?", toJSON( last_bets ), CURRENT_AUCTION.start_ts )

	SyncAuctionUIData( client, item_id )

	if not client:GetPermanentData( "participated_vehicle_auction" ) then
		client:SetPermanentData( "participated_vehicle_auction", CURRENT_AUCTION.start_ts )
	end

	client:SetPermanentData( "vehicle_auction_bets_count", ( client:GetPermanentData( "vehicle_auction_bets_count" ) or 0 ) + 1 )

	SendElasticGameEvent( client:GetClientID( ), "unique_cars_auction_bet", {
        lot_id = tostring( item_id ),
        bet_sum = value,
        bet_paid = is_skipping and skip_cost or 0,
        bet_num = client:GetPermanentData( "vehicle_auction_bets_count" ),
        currency = "hard",
    } )
end
addEvent( "OnPlayerTryPlaceBet", true)
addEventHandler( "OnPlayerTryPlaceBet", resourceRoot, OnPlayerTryPlaceBet )

function GetPlayerBet( player, item_id )
	if not CURRENT_AUCTION then return end
	local bet = CURRENT_AUCTION.bets[ item_id ][ player:GetID() ]

	if bet and ( not bet.returned or bet.returned == "no" ) then
		return bet
	end
end

function ReturnPlayerBets( player )
	local last_auction_id = player:GetPermanentData( "participated_vehicle_auction" )
	if not last_auction_id then return end

	local auction_data = GetAuctionData( last_auction_id )
	local player_id = player:GetID()

	DB:queryAsync( function( qh, auction_data, player )
        local result = qh:poll( -1 )
        if not result or #result == 0 then
        	player:SetPermanentData( "participated_vehicle_auction", false )
        	return 
        end

        for i, bet in pairs( result ) do
        	if bet.value == auction_data.last_bets[bet.item_id] then
				player:Reward( { type = "vehicle", id = auction_data.items[bet.item_id].id, event_name = "OnAuctionVehicleAdded" } )

				player:PhoneNotification( {
					title = "Аукцион";
					msg = "Твоя ставка выиграла аукцион по ".. GetVehicleNameFromModel( auction_data.items[bet.item_id].id ) .."! Автомобиль уже доставили тебе в гараж";
				} )
			else
				player:GiveMoney( bet.value * 1000, "sale", "unique_cars_auction" )

				player:PhoneNotification( {
					title = "Аукцион";
					msg = "Твоя ставка проиграла аукцион по ".. GetVehicleNameFromModel( auction_data.items[bet.item_id].id ) ..". Компенсация ставки в размере ".. format_price( bet.value * 1000 ) .." р. начислена на твой баланс";
				} )
			end

			iprint( "BET RETURNED", player, bet.value )

			DB:exec( "UPDATE nrp_vehicle_auction_bets SET returned = ? WHERE auction_id = ? AND player_id = ? AND item_id = ?", 
				"yes", auction_data.id, player:GetID(), bet.item_id )

			SendElasticGameEvent( player:GetClientID( ), "unique_cars_auction_finish", {
		        lot_id = tostring( bet.item_id ),
		        bet_sum = bet.value,
		        is_bet_won = bet.value == auction_data.last_bets[bet.item_id] and "true" or "false",
		        currency = "hard",
		    } )
        end

        player:SetPermanentData( "participated_vehicle_auction", false )

    end, { auction_data, player }, "SELECT * FROM nrp_vehicle_auction_bets WHERE player_id = ? AND auction_id = ? AND returned != ?", player:GetID(), last_auction_id, "yes" )
end

function GetAuctionData( auction_id )
	return AUCTIONS_LIST[ auction_id ]
end

function OnAuctionVehicleAdded( vehicle, data )
	if isElement(vehicle) and isElement(data.player) then
		local sOwnerPID = "p:" .. data.player:GetUserID()

		vehicle:SetOwnerPID( sOwnerPID )
		vehicle:SetFuel( "full" )
		vehicle:SetParked( true )
		
		vehicle:SetPermanentData( "showroom_cost", data.cost )
		vehicle:SetPermanentData( "showroom_date", getRealTime().timestamp )
		vehicle:SetPermanentData( "first_owner", sOwnerPID )
		vehicle:SetPermanentData( "temp_timeout", data.temp_timeout )

		vehicle:SetPermanentData( "untradable", true )

		triggerEvent( "CheckTemporaryVehicle", vehicle )
		triggerEvent( "CheckPlayerVehiclesSlots", data.player )
	end
end
addEvent( "OnAuctionVehicleAdded", false )
addEventHandler( "OnAuctionVehicleAdded", root, OnAuctionVehicleAdded ) 

function NotifyLosingBets( )
	if not CURRENT_AUCTION then return end

	local seconds = CURRENT_AUCTION.finish_ts - getRealTimestamp()
    local hours = math.floor( seconds / 60 / 60 )
    local minutes = math.floor( ( seconds - hours*60*60  ) / 60 )
	local time_left = hours..":"..minutes

	for item_id, bets in pairs( CURRENT_AUCTION.bets ) do
		local last_bet = CURRENT_AUCTION.items[ item_id ].last_bet
		local vehicle_name = GetVehicleNameFromModel( CURRENT_AUCTION.items[item_id].id )

		if last_bet then
			for pid, bet in pairs( bets ) do
				if bet.value < last_bet.value then
					local player = GetPlayer( pid )

					if player then
						player:PhoneNotification( {
							title = "Аукцион";
							msg = "До окончания аукциона на "..vehicle_name.." осталось "..time_left..". Успей сделать свою ставку и забрать выигрыш!";
						} )
					end
				end
			end
		end
	end
end

-- TESTS
if SERVER_NUMBER > 100 then
    addCommandHandler( "reset_vehicle_auction", function( ply )
        if not ply:IsAdmin( ) then return end

        DB:exec( "DELETE FROM nrp_vehicle_auction" )
        DB:exec( "DELETE FROM nrp_vehicle_auction_bets" )

        CURRENT_AUCTION = nil
        AUCTIONS_LIST = nil

        OnResourceStart( )
    end)

    addCommandHandler( "finish_vehicle_auction", function( ply )
        if not ply:IsAdmin( ) then return end

        for k,v in pairs( AUCTIONS_LIST ) do
        	v.finished = true
        end

        OnAuctionFinish( )
    end)

    addCommandHandler( "notify_vehicle_auction", function( ply )
        if not ply:IsAdmin( ) then return end

        NotifyLosingBets( )
    end)
end