Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "SInterior" )

ACTIVE_EVENTS = { }

function StartEvent( event_id, lobby_id, players )
	if not REGISTERED_EVENTS[ event_id ] then return end

	local self = {
		event_id = event_id;
		lobby_id = lobby_id;
		lobby_id_uniq = GenerateUniqId( );

		interior = REGISTERED_EVENTS[ event_id ].interior or 0;
		dimension = REGISTERED_EVENTS[ event_id ].dimension or next( players ):GetUniqueDimension( );

		no_ready_clients = { };

		count_players = REGISTERED_EVENTS[ event_id ].count_players;
		players = players;

		events = { };
	}

	for player in pairs( players ) do
		self.no_ready_clients[ player ] = true
	end

	local event_uid = getTickCount( )
	ACTIVE_EVENTS[ event_uid ] = self

	local players = { }
	self.players_point = { }
	for player in pairs( self.players ) do
		table.insert( self.players_point, { player, REGISTERED_EVENTS[ event_id ].start_count_point or 0 } )
		removePedFromVehicle( player )

		local current_event = {
			interior = player.interior;
			dimension = player.dimension;
			position = {
				x = player.position.x,
				y = player.position.y,
				z = player.position.z,
			};

			event_id = event_id;
			event_uid = event_uid;

			weapons = player:GetPermanentWeapons( );
			health = player.health;
			armor = player.armor;
			calories = player:GetCalories( );
		}

		player:setData( "current_event", current_event, false )
		player:TakeAllWeapons( )
		player:Teleport( Vector3( -1099.379, -58.988, 7.453 ), self.dimension, self.interior )
		player.health = 100
		player:SetCalories( 100, true );

		table.insert( players, player )

		addEventHandler( "onPlayerQuit", player, onPlayerQuit_OnEvent_handler )

		player:setData( "event_start_timestamp", getRealTimestamp( ), false )

		local join_num = player:GetPermanentData( "events_join_num" ) or { }
		join_num[ event_id ] = ( join_num[ event_id ] or 0 ) + 1
		player:SetPermanentData( "events_join_num", join_num )
	end

	triggerEvent( "SDEV2DEV_event_start", root, REGISTERED_EVENTS[ event_id ].group, self.lobby_id_uniq, event_id )

	REGISTERED_EVENTS[ event_id ].Setup_S_handler( self )

	triggerClientEvent( players, "OnPlayerStartEvent", resourceRoot, event_id, lobby_id, self.players, self.vehicles )

	self.timer_client_not_ready_fail = Timer( function( )
		local self = ACTIVE_EVENTS[ event_uid ]
		if not self then return end

		for player in pairs( self.no_ready_clients ) do
			if isElement( player ) then
				PlayerEndEvent( player, "Слишком долгая инициализация клиента", true )
			end
		end

		local players = { }
		for player in pairs( self.players ) do
			table.insert( players, player )
		end

		REGISTERED_EVENTS[ event_id ].Setup_S_delay_handler( self, players )
	end, 3000, 1 )
end

function PlayerClientEventReady_handler( )
	if not client then return end

	local current_event = client:getData( "current_event" )
	if not current_event then return end

	local self = ACTIVE_EVENTS[ current_event.event_uid ]
	if not self then return end

	self.no_ready_clients[ client ] = nil

	if not next( self.no_ready_clients ) and isTimer( self.timer_client_not_ready_fail ) then
		killTimer( self.timer_client_not_ready_fail )

		local players = { }
		for player in pairs( self.players ) do
			table.insert( players, player )
		end

		REGISTERED_EVENTS[ self.event_id ].Setup_S_delay_handler( self, players )
	end
end
addEvent( "PlayerClientEventReady", true )
addEventHandler( "PlayerClientEventReady", resourceRoot, PlayerClientEventReady_handler )

function PlayerEndEvent( player, reason_str, is_quit, number, no_check_next, data )
	local current_event = player:getData( "current_event" )
	if not current_event then return end

	spawnPlayer( player, current_event.position.x, current_event.position.y, current_event.position.z, 0, player.model, current_event.interior or 0, current_event.dimension or 0 )
	setCameraTarget( player )

	player:SetHP( current_event.health or 100 )
	player:setArmor( current_event.armor or 0 )
	player:SetCalories( current_event.calories or 50 )

	player:TakeAllWeapons( )
	-- Выдаем в таймере, т.к. в nrp_handler_weapons\SWeapons.lua в OnPlayerWasted_handler всё оружие удаляется
	if reason_str == "Выход из игры" then
		GiveWeaponsFromTable( player, current_event.weapons or {} )
	else
		setTimer( GiveWeaponsFromTable, 50, 1, player, current_event.weapons or {} )
	end

	local event_id = current_event.event_id
	local event_uid = current_event.event_uid

	removeEventHandler( "onPlayerQuit", player, onPlayerQuit_OnEvent_handler )
	
	triggerEvent( "BP:NYE:onPlayerEventAnyFinish", player, event_id )

	local self = ACTIVE_EVENTS[ event_uid ]
	if self then
		REGISTERED_EVENTS[ event_id ].CleanupPlayer_S_handler( self, player )
		for player_in_event in pairs( self.players ) do
			triggerClientEvent( player_in_event, "OnPlayerExitEvent", resourceRoot, player, current_event.event_id )
		end

		self.players[ player ] = nil
		for k, v in ipairs( self.players_point ) do
			if v[ 1 ] == player then
				table.remove( self.players_point, k )
				break
			end
		end

		if isElement( player ) then
			local events_timeout = player:GetPermanentData( "events_timeout" ) or { }
			events_timeout[ event_id ] = getRealTimestamp( ) + 10 * 60
			player:SetPermanentData( "events_timeout", events_timeout )
		end

		if not is_quit then
			if not number then
				number = 1
				for player in pairs( self.players ) do
					number = number + 1
				end

				number = number == 1 and #REGISTERED_EVENTS[ event_id ].coins_reward or number
			end

			local number = number
			-- Тестирование
			if SERVER_NUMBER > 100 then
				local test_number = player:getData( "new_year_place" )
				if test_number and test_number <= #REGISTERED_EVENTS[ event_id ].coins_reward then
					number = test_number
				end
			end			

			local coins_reward = REGISTERED_EVENTS[ event_id ].coins_reward[ number ] or 0
			local coins, booster_coins = player:GiveCoins( coins_reward )
			triggerClientEvent( player, "ShowUIEventReward", resourceRoot, ( number == 10 and "последнее" or number ), coins, booster_coins, data )

			triggerEvent( "onPlayerEventFinish", player, event_id, number, no_check_next, not booster_coins )

			local event_start_timestamp = player:getData( "event_start_timestamp" )
			player:setData( "event_start_timestamp", false, false )

			triggerEvent( "SDEV2DEV_event_end", player, REGISTERED_EVENTS[ event_id ].group, self.lobby_id_uniq, event_id, ( number == 1 and "true" or "false" ), 
						 ( booster_coins and "false" or "true" ), ( reason_str == "Вы погибли" and "false" or "true" ), event_start_timestamp, getRealTimestamp( ), coins )
		elseif isElement( player ) then
			triggerClientEvent( player, "ShowPlayerUIQuestFailed", root, reason_str )
		end

		player:setData( "current_event", false, false )

		local next_last_player = next( self.players )
		if next_last_player then
			if not no_check_next then
				local last_player = next( self.players, next_last_player )
				if not last_player then
					PlayerEndEvent( next_last_player, _, _, 1, nil, (self.rounds_data and { is_drag = true, rounds_data = self.rounds_data }) )
					return true
				end
			end
		else
			REGISTERED_EVENTS[ event_id ].Cleanup_S_handler( self )

			ACTIVE_EVENTS[ event_uid ] = nil
			return true
		end
	end
end

function PlayerQuitAfk_handler( reason_str )
	PlayerEndEvent( client, reason_str or "Вы были AFK", true, _, false )
end
addEvent( "PlayerQuitAfk", true )
addEventHandler( "PlayerQuitAfk", resourceRoot, PlayerQuitAfk_handler )

function onPlayerQuit_OnEvent_handler( )
	PlayerEndEvent( source, "Выход из игры", true )
end

addEventHandler( "onResourceStop", resourceRoot, function( )
	for event_uid, info in pairs( ACTIVE_EVENTS ) do
		for player in pairs( info.players ) do
			PlayerEndEvent( player, "Выход из игры", true )
		end
	end
end )




Player.GiveCoins = function( self, count, without_booster )
	local booster_timeout = self:GetPermanentData( EVENT_BOOSTER_VALUE_NAME ) or 0
	local coef = 1

	if not without_booster and booster_timeout > getRealTimestamp( ) then
		coef = 2
	end

	local reward_coins = math.ceil( count * coef )
	local new_year_coins = ( self:GetPermanentData( EVENT_COINS_VALUE_NAME ) or 0 ) + reward_coins
	self:SetPermanentData( EVENT_COINS_VALUE_NAME, new_year_coins )
	self:SetPrivateData( EVENT_COINS_VALUE_NAME, new_year_coins )

	return reward_coins, ( coef == 1 and math.ceil( reward_coins * 2 ) )
end

function GetWeaponsTable( pPlayer )
	local pWeapons = {}

	for slot = 0, 12 do
		local iWeaponID = getPedWeapon( pPlayer, slot )
		local iAmmo = getPedTotalAmmo( pPlayer, slot )

		pWeapons[slot] = { iWeaponID, iAmmo }
	end

	return pWeapons
end

function GiveWeaponsFromTable( pPlayer, pWeapons )
	if not isElement( pPlayer ) then return end
	for k,v in pairs( pWeapons ) do
		if v[1] and v[2] > 0 then
			pPlayer:GiveWeapon( v[1], v[2], false )
		end
	end
end

addEventHandler( "onPlayerReadyToPlay", root, function ( )
	if getRealTimestamp( ) < EVENTS_TIMES[ CURRENT_EVENT ].to then return end
	if source:GetPermanentData( EVENT_COINS_VALUE_NAME .. "_passed" ) then return end

	local coins = source:GetPermanentData( EVENT_COINS_VALUE_NAME )
	if coins and coins > 0 then
		source:GiveMoney( coins * 10, CURRENT_EVENT, "event_" .. CURRENT_EVENT )
	end

	source:SetPermanentData( EVENT_COINS_VALUE_NAME, nil )
	source:SetPermanentData( EVENT_COINS_VALUE_NAME .. "_passed", true )
	source:SetPrivateData( EVENT_COINS_VALUE_NAME, nil )
end, true, "high+9999999" )

function SyncEventScoreboard( self, event_name, points, player )
	local players = { }
	local place

	for k, v in ipairs( self.players_point ) do
		table.insert( players, v[ 1 ] )
		if v[ 1 ] == player then
			v[ 2 ] = points
		end
	end
	table.sort( self.players_point, function( a, b )
		return a[ 2 ] > b[ 2 ]
	end )

	for k, v in ipairs( self.players_point ) do
		if v[ 1 ] == player then
			place = k
			break
		end
	end

	triggerClientEvent( players, event_name, resourceRoot, player, points, place )
end

-- Тестирование
if SERVER_NUMBER > 100 then
    addCommandHandler( CURRENT_EVENT .. "_coin", function( player )
		player:GiveCoins( 1000 )
		player:SetPermanentData( EVENT_COINS_VALUE_NAME .. "_passed", nil )
		player:ShowInfo( "Выдано 1000 коинов" )
	end )
	
	addCommandHandler( CURRENT_EVENT .. "_end_data", function( player )
		EVENTS_TIMES[ CURRENT_EVENT ].to = getRealTimestamp( )
		player:ShowInfo( "Дата кончания = текущее время" )
	end )
	
	addCommandHandler( CURRENT_EVENT .. "_end_data_reset", function( player )
		EVENTS_TIMES[ CURRENT_EVENT ].to = 1578430799
		player:ShowInfo( "Дата кончания 7.01" )
	end )

	addCommandHandler( CURRENT_EVENT .. "_reset_timeout", function( player )
		player:SetPermanentData( "events_timeout", nil )
		player:ShowInfo( "Сброшено кд очереди" )
	end )
end