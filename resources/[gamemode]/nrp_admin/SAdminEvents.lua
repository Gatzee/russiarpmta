MAX_EVENT_VEHICLES_COUNT = 200

ADMIN_EVENTS = { }
PLAYER_EVENTS = { }
EVENTS = { }

function StartAdminEvent( name, max_player_count, teleport_enabled_duration )
	if source ~= client or not isElement( client ) or not source:IsAdmin( ) then return end

	local event_id = source:GetUserID( )
	if ADMIN_EVENTS[ event_id ] then
		source:ShowError( "Вы уже запустили ивент" )
		return
	end

	if source.dimension ~= 0 or source.dimension ~= 0 then
		source:ShowError( "Вы должны быть в основном игровом мире" )
		return
	end

	ADMIN_EVENTS[ event_id ] = {
		name = name,
		max_player_count = max_player_count,
		teleport_stop_date = os.time( ) + teleport_enabled_duration,

		id = event_id,
		creator = source,
		dimension = source:GetUniqueDimension( );

		players_list = { },
		players_data = { },
		vehicles = { },
		given_rewards_sum = 0,
		players_rewards_sum = { },

		Destroy = function( self )
			ADMIN_EVENTS[ self.id ] = nil
			for player in pairs( self.players_data ) do
				RemovePlayerFromEvent( player )
			end
			Async:foreach( self.vehicles, function( v, k )
				if isElement( k ) then
					k:DestroyTemporary( )
				end
			end )
		end
	}
	triggerEvent( "onPlayerJoinToAdminEvent", source, event_id )
	triggerClientEvent( source, "AP:onEventStart", source )

	-- 2) Отправка приглашения игрокам
	local notification_data =
	{
		title = name,
		special = "admin_event",
		args = { event_id = event_id },
	}
	triggerClientEvent( "OnClientReceivePhoneNotification", resourceRoot, notification_data )

	SendElasticGameEvent( source:GetClientID( ), "admins_event_activate", {
		admin_name = source:GetNickName( ),
		admin_event_name = name,
		max_count = max_player_count,
	} )
end
addEvent( "AP:StartAdminEvent", true )
addEventHandler( "AP:StartAdminEvent", root, StartAdminEvent )

function StopAdminEvent( )
	if source ~= client or not isElement( client ) or not source:IsAdmin( ) then return end

	local event = ADMIN_EVENTS[ source:GetUserID( ) ]
	if not event then
		source:ShowError( "Это можно сделать только после запуска ивента!" )
		return
	end

	event:Destroy( )
end
addEvent( "AP:StopAdminEvent", true )
addEventHandler( "AP:StopAdminEvent", root, StopAdminEvent )

-- 3) Принятие приглашения игроком, тп его к админу
function onPlayerJoinToAdminEvent_handler( event_id )
	if not isElement( source ) then return end

	local event = ADMIN_EVENTS[ event_id ]
	if not event then return end
	if event.players_data[ source ] then return end

	if event.max_player_count <= #event.players_list - 1 then
		source:ShowError( "Необходимое количество игроков уже набрано" )
		return
	end

	if os.time( ) >= event.teleport_stop_date then
		source:ShowError( "Телепорт больше недоступен" )
		return
	end

	local state, reason = source:CanJoinToEvent({ event_type = "custom_event_admin" })
	if source ~= event.creator and not state then
		source:ShowError( reason )
		return
	end

	table.insert( event.players_list, source )

	local current_event = {
		interior = source.interior;
		dimension = source.dimension;
		position = {
			x = source.position.x,
			y = source.position.y,
			z = source.position.z,
		};

		skin = source.model;
		weapons = source:GetPermanentWeapons( );
		armor = source.armor;
		health = source.health;
		calories = source:GetCalories( );
	}
	event.players_data[ source ] = current_event
	PLAYER_EVENTS[ source ] = event
	source:SetPrivateData( "is_on_event", event_id )

	source:SetBlockInteriorInteraction( true )
	removePedFromVehicle( source )

	source:TakeAllWeapons( )

	source.interior = 0
	source.dimension = event.dimension

	source.health = 100
	source.armor = 0
	source:SetCalories( 100, true )

	triggerEvent( "OnPlayerForceSwitchTeam", source, source, false )

	addEventHandler( "onPlayerPreWasted", source, onPlayerPreWasted_eventHandler )
	addEventHandler( "onPlayerPreLogout", source, onPlayerPreLogout_eventHandler )

	if source ~= event.creator then
		local r = math.random( ) * 20
		local a = math.random( ) * math.pi
		source.position = event.creator.position + Vector3( math.cos( a ) * r, math.sin( a ) * r, 0 )

		triggerClientEvent( event.creator, "AP:onPlayerJoinEvent", source )

		SendElasticGameEvent( source:GetClientID( ), "admins_event_join", {
			player_name = source:GetNickName( ),
			admin_event_name = event.name,
		} )
	end

	triggerEvent( "onPlayerJoinToEvent", source )
	triggerEvent( "onPlayerSomeDo", source, "admin_event_join" ) -- achievements
	triggerEvent( "onTaxiPrivateFailWaiting", source, "Пассажир отменил заказ", "Ты принял участие в ивенте, заказ в Такси отменен" )
end
addEvent( "onPlayerJoinToAdminEvent", true )
addEventHandler( "onPlayerJoinToAdminEvent", root, onPlayerJoinToAdminEvent_handler )

-- 4) Отображение тпшнувшихся на ивент игроков в списке игроков в интерфейсе админа

-- 5) Возможность выдачи временного оружия и предметов инвентаря на время ивента
function GiveItemToPlayers( players, item_type, item_data )
	if source ~= client or not isElement( client ) or not source:IsAdmin( ) then return end

	local event = ADMIN_EVENTS[ source:GetUserID( ) ]
	if not event then
		source:ShowError( "Это можно сделать только после запуска ивента!" )
		return
	end

	for i, player in pairs( players ) do
		local player_data = event.players_data[ player ]
		if isElement( player ) and player_data then
			if item_type == "skin" then
				player.model = item_data
			elseif item_type == "weapon" then
				player:GiveWeapon( item_data[ 1 ], item_data[ 2 ], false, true )
			end
		end
	end
	source:ShowInfo( "Успешно выдано!" )
end
addEvent( "AP:GiveItemToPlayers", true )
addEventHandler( "AP:GiveItemToPlayers", root, GiveItemToPlayers )

-- 6) Возможность создания машин вокруг админа
function CreateEventVehicles( vehicle_ids, count, r, g, b )
	if source ~= client or not isElement( client ) or not source:IsAdmin( ) then return end

	local event = ADMIN_EVENTS[ source:GetUserID( ) ]
	if not event then
		source:ShowError( "Это можно сделать только после запуска ивента!" )
		return
	end

	local available_count = MAX_EVENT_VEHICLES_COUNT - table.size( event.vehicles )
	if available_count == 0 then
		source:ShowError( "Вы уже создали макс. кол-во ТС" )
		return
	elseif #vehicle_ids * count > available_count then
		source:ShowError( "Слишком много ТС, вы можете ещё создать " .. available_count .. " шт." )
		return
	end

	local new_vehicles = { }
	local position = source.position
	for i, id in pairs( vehicle_ids ) do
		for i = 1, count do
			local position = position:AddRandomRange( 20 )
			local vehicle = Vehicle.CreateTemporary( id, position.x, position.y, position.z )
			vehicle.dimension = event.dimension
			vehicle:setColor( r, g, b )
			event.vehicles[ vehicle ] = true
			table.insert( new_vehicles, vehicle )
		end
	end
	triggerClientEvent( source, "AP:onEventVehiclesChange", source, new_vehicles )

	source:ShowInfo( "Транспорт успешно создан!" )
end
addEvent( "AP:CreateEventVehicles", true )
addEventHandler( "AP:CreateEventVehicles", root, CreateEventVehicles )

-- 6.1) Возможность удалить созданные машины
function DestroyEventVehicles( vehicles )
	if source ~= client or not isElement( client ) or not source:IsAdmin( ) then return end

	local event = ADMIN_EVENTS[ source:GetUserID( ) ]
	if not event then return end

	for i, vehicle in pairs( vehicles ) do
		if isElement( vehicle ) then
			event.vehicles[ vehicle ] = nil
			vehicle:DestroyTemporary( )
		end
	end
	triggerClientEvent( source, "AP:onEventVehiclesChange", source )

	source:ShowInfo( "Транспорт успешно удален!" )
end
addEvent( "AP:DestroyEventVehicles", true )
addEventHandler( "AP:DestroyEventVehicles", root, DestroyEventVehicles )

-- 7) Возможность выдачи награды игрокам
function RewardPlayers( players_rewards )
	if source ~= client or not isElement( client ) or not source:IsAdmin( ) then return end

	local admin_id = source:GetUserID( )
	local event = ADMIN_EVENTS[ admin_id ]
	if not event then
		source:ShowError( "Это можно сделать только после запуска ивента!" )
		return
	end

	local rewards_sum = 0
	local players_rewards_sum = event.players_rewards_sum
	for player, data in pairs( players_rewards ) do
		if isElement( player ) then
			local player_rewards_sum = players_rewards_sum[ player ] or 0
			if player_rewards_sum + data.reward > CONST_MAX_PLAYER_REWARD then
				source:ShowError( 
					"Вы уже выдали игроку " .. player:GetNickName( ) .. " награду в размере " 
					.. player_rewards_sum .. " (макс. " .. CONST_MAX_PLAYER_REWARD .. ")" 
				)
				return
			end
			rewards_sum = rewards_sum + data.reward
		else
			players_rewards[ player ] = nil
		end
	end
	
	if event.given_rewards_sum + rewards_sum > CONST_MAX_REWARDS_SUM then
		source:ShowError( 
			"Макс. сумма всех наград " .. CONST_MAX_REWARDS_SUM 
			.. " (вы уже выдали " .. event.given_rewards_sum .. ")" 
		)
		return
	end
	event.given_rewards_sum = event.given_rewards_sum + rewards_sum

	local admin_name = source:GetNickName( )
	local admin_client_id = source:GetClientID( )
	for player, data in pairs( players_rewards ) do
		player:GiveMoney( data.reward, "admins_event_reward" )
		players_rewards_sum[ player ] = ( players_rewards_sum[ player ] or 0 ) + data.reward

		local player_client_id = player:GetClientID( )
		local player_name = player:GetNickName( )
		SendElasticGameEvent( player_client_id, "admin_event_reward_take", {
			player_name = player_name,
			sum = data.reward,
			currency = "soft",
		} )

		SendElasticGameEvent( admin_client_id, "admins_event_reward_give", {
			admin_name = admin_name,
			target_player_client_id = player_client_id,
			sum = data.reward,
			currency = "soft",
		} )

		SendToLogserver( "[ADMIN_EVENT] Админ " .. admin_name .. " выдал награду игроку " .. player_name, { 
			logtype = "admin_event/rewards", 
			reward = data.reward, 
		} )
	end

	source:ShowInfo( "Вы успешно выдали награду!" )
end
addEvent( "AP:RewardPlayers", true )
addEventHandler( "AP:RewardPlayers", root, RewardPlayers )

-- 8) Возможность убрать игроков из ивента
function RemovePlayersFromEvent_handler( players )
	if source ~= client or not isElement( client ) or not source:IsAdmin( ) then return end

	local event = ADMIN_EVENTS[ source:GetUserID( ) ]
	if not event then return end

	if players then
		for i, player in pairs( players ) do
			if event.players_data[ player ] then
				RemovePlayerFromEvent( player )
			end
		end
	else
		for player in pairs( event.players_data ) do
			if player ~= source then
				RemovePlayerFromEvent( player )
			end
		end
	end

	source:ShowInfo( "Вы успешно убрали игроков из ивента!" )
end
addEvent( "AP:RemovePlayersFromEvent", true )
addEventHandler( "AP:RemovePlayersFromEvent", root, RemovePlayersFromEvent_handler )


function SetEventPlayerHealth_handler( players, value )
	if source ~= client or not isElement( client ) or not source:IsAdmin( ) then return end

	local event = ADMIN_EVENTS[ source:GetUserID( ) ]
	if not event or not players or not next( players ) then return end

	for i, player in pairs( players ) do
		if event.players_data[ player ] then
			player:SetHP( value or 100 )
		end
	end
end
addEvent( "AP:SetEventPlayerHealth", true )
addEventHandler( "AP:SetEventPlayerHealth", root, SetEventPlayerHealth_handler )

function SetEventPlayerArmour_handler( players, value )
	if source ~= client or not isElement( client ) or not source:IsAdmin( ) then return end

	local event = ADMIN_EVENTS[ source:GetUserID( ) ]
	if not event or not players or not next( players ) then return end

	for i, player in pairs( players ) do
		if event.players_data[ player ] then
			player:setArmor( value or 100 )
		end
	end
end
addEvent( "AP:SetEventPlayerArmour", true )
addEventHandler( "AP:SetEventPlayerArmour", root, SetEventPlayerArmour_handler )

function SetEventPlayerCalories_handler( players, value )
	if source ~= client or not isElement( client ) or not source:IsAdmin( ) then return end

	local event = ADMIN_EVENTS[ source:GetUserID( ) ]
	if not event or not players or not next( players ) then return end

	for i, player in pairs( players ) do
		if event.players_data[ player ] then
			player:SetCalories( value or 100, true )
		end
	end
end
addEvent( "AP:SetEventPlayerCalories", true )
addEventHandler( "AP:SetEventPlayerCalories", root, SetEventPlayerCalories_handler )

function SetEventPlayerFrozen_handler( players, value )
	if source ~= client or not isElement( client ) or not source:IsAdmin( ) then return end

	local event = ADMIN_EVENTS[ source:GetUserID( ) ]
	if not event or not players or not next( players ) then return end

	value = value and true or false -- fix: if has got bad data

	for i, player in pairs( players ) do
		if event.players_data[ player ] then
			player.frozen = value
			player:SetPrivateData( "is_frozen_by_admin", value )
		end
	end
end
addEvent( "AP:SetEventPlayerFrozen", true )
addEventHandler( "AP:SetEventPlayerFrozen", root, SetEventPlayerFrozen_handler )

function RemovePlayerFromEvent( player, on_wasted )
	local current_event = PLAYER_EVENTS[ player ]
	if not current_event then return end

	PLAYER_EVENTS[ player ] = nil
	removeEventHandler( "onPlayerPreWasted", player, onPlayerPreWasted_eventHandler )
	removeEventHandler( "onPlayerPreLogout", player, onPlayerPreLogout_eventHandler )

	local player_data = current_event.players_data[ player ]
	if not player_data then return end

	player:SetBlockInteriorInteraction( false )
	spawnPlayer( player, player_data.position.x, player_data.position.y, player_data.position.z, 0, player_data.skin or player.model, player_data.interior or 0, player_data.dimension or 0 )
	setCameraTarget( player )

	player:setArmor( player_data.armor or 0 )
	player:SetHP( player_data.health or 100 )
	player:SetCalories( player_data.calories or 50 )

	if on_wasted then
		-- Выдаем в таймере, т.к. в nrp_handler_weapons\SWeapons.lua в OnPlayerWasted_handler всё оружие удаляется
		setTimer( RestorePlayerWeapons, 50, 1, player, player_data.weapons )
	else
		RestorePlayerWeapons( player, player_data.weapons )
	end

	triggerEvent( "OnPlayerForceSwitchTeam", player, player, true )

	player:SetPrivateData( "is_on_event", false )

	current_event.players_data[ player ] = nil

	for k, v in pairs( current_event.players_list ) do
		if v == player then
			table.remove( current_event.players_list, k )
			break
		end
	end

	return true
end

function RestorePlayerWeapons( player, weapons )
	if not isElement( player ) or not weapons then return end

	player:TakeAllWeapons( )
	GiveWeaponsFromTable( player, weapons )
end

function onPlayerPreWasted_eventHandler( )
	local event = PLAYER_EVENTS[ source ]
	if not event then
		local event_id = source:getData( "is_on_event" )
		if ADMIN_EVENTS[ event_id ] then
			local event = ADMIN_EVENTS[ event_id ]
			for player in pairs( event.players_data ) do
				if player == source then
					RemovePlayerFromEvent( player, true )
					break
				end
			end
		end
		return false
	end

	if source == event.creator then
		spawnPlayer( source, source.position, 0, source.model, 0, event.dimension )
		setCameraTarget( source )
		cancelEvent( )
		
	elseif RemovePlayerFromEvent( source, true ) then
		source:ShowInfo( "Вы погибли" )
		cancelEvent( )
	end
end

-- 9) Выход игрока из ивента (из игры)
-- 10) Выход админа из игры
function onPlayerPreLogout_eventHandler( )
	local event = ADMIN_EVENTS[ source:GetUserID( ) ]

	if event then
		event:Destroy( )
	else
		RemovePlayerFromEvent( source )
	end
end
addEvent( "onPlayerPreLogout" )

-- 2.1) Отправка приглашения игрокам, зашедшим после создания
function onPlayerReadyToPlay_eventHandler( )
	for event_id, event in pairs( ADMIN_EVENTS ) do
		if event.teleport_stop_date > os.time( ) and event.max_player_count <= #event.players_list - 1 then
			source:PhoneNotification( {
				title = event.name,
				msg = "Начат набор на ивент - \"" .. event.name .. "\"",
				special = "admin_event",
				args = { event_id = event_id },
			} )
		end
	end
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_eventHandler )

function onResourceStop_eventHandler()
	for event_id, event in pairs( ADMIN_EVENTS ) do
		event:Destroy( )
    end
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_eventHandler )

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
	for k,v in pairs( pWeapons ) do
		if v[1] and v[2] > 0 then
			pPlayer:GiveWeapon( v[1], v[2], false )
		end
	end
end

function OnPlayerAdminEventUnjail(  )
	local pEvent = ADMIN_EVENTS[ source:getData( "is_on_event" ) ]
	if not pEvent then return end

	source.dimension = pEvent.dimension
end
addEvent( "OnPlayerAdminEventUnjail", false )
addEventHandler( "OnPlayerAdminEventUnjail", root, OnPlayerAdminEventUnjail )