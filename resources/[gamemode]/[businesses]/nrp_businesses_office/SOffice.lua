Extend( "SPlayer" )

local POOL_OF_PLAYERS = { }

function ClientRequestOfficeEnter_handler( office_owner, building_num )
	if not client then return end
	
	if not office_owner then
		office_owner = client
	else
		if not isElement( office_owner ) then
			client:ShowError( "Владелец офиса вышел из игры" )
			return
		end
	end

	local office_data = office_owner:GetPermanentData( "office_data" )

	if not office_data then
		triggerClientEvent( client, "ShowBusinessesShop", root )
		return
	end

	if client:GetBlockInteriorInteraction() then
		client:ShowInfo( "Вы не можете войти во время задания" )
		return false
	end

	if client.vehicle then
		removePedFromVehicle( client )
	end

	client:Teleport( CONST_OFFICE_INTERIOR_EXIT_POSITIONS[ office_data.class ], office_owner:GetUniqueDimension( ), 1, 1000 )
	POOL_OF_PLAYERS[ client ] = { dimension = client.dimension, building_num = building_num }

	triggerClientEvent( client, "onPlayerEnterOffice", resourceRoot, office_owner, office_data )
end
addEvent( "ClientRequestOfficeEnter", true )
addEventHandler( "ClientRequestOfficeEnter", resourceRoot, ClientRequestOfficeEnter_handler )

function RequestOfficeReEnterPlayers_handler( office_owner )
	if not isElement( office_owner ) then return end

	local office_dimenstion = office_owner:GetUniqueDimension( )

	for _, player in pairs( GetPlayersInGame( ) ) do
		if player.dimension == office_dimenstion then
			onPlayerPreLogout_handler( player )
			player:ShowInfo( "Офис был обновлен" )
		end
	end
end
addEvent( "RequestOfficeReEnterPlayers" )
addEventHandler( "RequestOfficeReEnterPlayers", root, RequestOfficeReEnterPlayers_handler )

function ClientRequestOfficeExit_handler( )
	if not client then return end

	onPlayerPreLogout_handler( client )
end
addEvent( "ClientRequestOfficeExit", true )
addEventHandler( "ClientRequestOfficeExit", resourceRoot, ClientRequestOfficeExit_handler )

function onPlayerPreLogout_handler( player )
	if not POOL_OF_PLAYERS[ player ] then return end

	local building_num = POOL_OF_PLAYERS[ player ].building_num
	player:Teleport( CONST_OFFICE_BUILD_ENTER_POSITIONS[ building_num ], 0, 0 )
	POOL_OF_PLAYERS[ player ] = nil

	triggerClientEvent( player, "onPlayerExitOffice", resourceRoot )
end

addEvent( "onPlayerPreLogout", true )
addEventHandler( "onPlayerPreLogout", root, function( )
	onPlayerPreLogout_handler( source )
end )

function onPlayerRequestOfficeControlMenu_handler( )
	if not client then return end

	local office_data = client:GetPermanentData( "office_data" )
	if not office_data then
		client:ShowError( "У вас нет офиса" )
		return
	end

	triggerClientEvent( client, "ShowOfficeControlMenu", resourceRoot, office_data )
end
addEvent( "onPlayerRequestOfficeControlMenu", true )
addEventHandler( "onPlayerRequestOfficeControlMenu", resourceRoot, onPlayerRequestOfficeControlMenu_handler )

function onPlayerRequestOfficeSecretaryMenu_handler( owner_player )
	if not client then return end

	local office_data = client:GetPermanentData( "office_data" )
	if not office_data then
		client:ShowError( "У вас нет офиса" )
		return
	end

	local secretary_data = {
		boss = owner_player;
		coins = client:GetBusinessCoins( );
		businesses = exports.nrp_businesses:GetOwnedBusinessesData( client );
	}

	triggerClientEvent( client, "ShowOfficeSecretaryMenu", resourceRoot, secretary_data )
end
addEvent( "onPlayerRequestOfficeSecretaryMenu", true )
addEventHandler( "onPlayerRequestOfficeSecretaryMenu", resourceRoot, onPlayerRequestOfficeSecretaryMenu_handler )

function onPlayerReadyToPlay_handler( )
	local office_data = source:GetPermanentData( "office_data" )
	if not office_data then return end
	if not CONST_OFFICE_PAY_AMOUNT[ office_data.class ] then return end

	local pay_amount = CONST_OFFICE_PAY_AMOUNT[ office_data.class ]

	if not office_data.last_pay then
		office_data.last_pay = getRealTime( ).timestamp
		source:SetPermanentData( "office_data", office_data )
		return
	end

	local calculate = CalculateCountWeekOfficeFromLastPay( office_data.last_pay )
	if calculate.week_count < 1 then return end

	local new_deposit = office_data.deposit - calculate.week_count * pay_amount

	WriteLog(
		"businesses_office",
		"[Списание оплаты] %s [DEPOSIT:%s] [NEW_DEPOSIT:%s] [WEEK_COUNT:%s] [PAY_AMOUNT:%s]",
		source, office_data.deposit, new_deposit, calculate.week_count, pay_amount
	)

	office_data.deposit = new_deposit

	if office_data.deposit < -pay_amount then
		source:SetPermanentData( "office_data", nil )
		onPlayerPreLogout_handler( source )

		WriteLog(
			"businesses_office",
			"[Удаление офиса] %s",
			source
		)

		triggerEvent( "OnBusinessShopBuyOffice", source, office_data.cost_buy or 42, "office".. office_data.class, true )
	else
		office_data.last_pay = calculate.difference_last_pay
		source:SetPermanentData( "office_data", office_data )
	end
end
addEvent( "onPlayerReadyToPlay", true )
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )

function CalculateCountWeekOfficeFromLastPay( last_pay )
	local timetamps = getRealTime( ).timestamp
	local office = { }

	office.week_count = math.floor( ( timetamps - last_pay ) / ( 7 * 24 * 60 * 60 ) )

	if office.week_count > 0 then
		office.difference_last_pay = timetamps - ( ( timetamps - last_pay ) - ( office.week_count * ( 7 * 24 * 60 * 60 ) ) )
	end

	return office
end

function onPlayerOfficeEnterDeposit_handler( deposit )
	if not client then return end

	local office_data = client:GetPermanentData( "office_data" )
	if not office_data then
		client:ShowError( "У вас нет офиса" )
		return
	end

	if client:TakeMoney( deposit, "business_office_deposit" ) then
		office_data.deposit = office_data.deposit + deposit
		client:SetPermanentData( "office_data", office_data )
		triggerClientEvent( client, "ShowOfficeControlMenu", resourceRoot, office_data )

		WriteLog(
			"businesses_office",
			"[Внесение депозита] %s [SUM:%s] [NEW_DEPOSIT:%s]",
			source, deposit, office_data.deposit
		)
	else
		client:ErrorWindow( "Недостаточно средств!" )
	end
end
addEvent( "onPlayerOfficeEnterDeposit", true )
addEventHandler( "onPlayerOfficeEnterDeposit", resourceRoot, onPlayerOfficeEnterDeposit_handler )

function onPlayerOfficeTakeDeposit_handler( amount )
	if not client then return end

	amount = tonumber( amount )
	if not amount or amount <= 0 then return end

	local office_data = client:GetPermanentData( "office_data" )
	if not office_data then
		client:ShowError( "У вас нет офиса" )
		return
	end

	office_data.deposit = office_data.deposit - amount

	local is_can_take_from_deposit = office_data.deposit >= 0
	if is_can_take_from_deposit then
		client:GiveMoney( amount, "business_balance_take" )
		client:SetPermanentData( "office_data", office_data )
		triggerClientEvent( client, "ShowOfficeControlMenu", resourceRoot, office_data )

		WriteLog(
			"businesses_office",
			"[Снятие с депозита] %s [SUM:%s] [NEW_DEPOSIT:%s]",
			source, amount, office_data.deposit
		)
	else
		client:ErrorWindow( "Недостаточно средств на депозите!" )
	end
end
addEvent( "onPlayerOfficeTakeDeposit", true )
addEventHandler( "onPlayerOfficeTakeDeposit", resourceRoot, onPlayerOfficeTakeDeposit_handler )

function onPlayerRequestInvitePlayerInOffice_handler( nickname )
	if not client or not POOL_OF_PLAYERS[ client ] then return end

	local building_num = POOL_OF_PLAYERS[ client ].building_num
	local position = CONST_OFFICE_BUILD_ENTER_POSITIONS[ building_num ]

	local players = getElementsWithinRange( position, 5, "player" )
	for _, player in pairs( players ) do
		if player:IsInGame( ) and player:GetNickName( ) == nickname then
			client:InfoWindow( "Приглашение выслано!" )
			triggerClientEvent( player, "ShowOfficeInvite", resourceRoot, client, building_num )
			return
		end
	end

	client:ErrorWindow( "Игрок не найден, либо находится\nне рядом с бизнес центром!" )
end
addEvent( "onPlayerRequestInvitePlayerInOffice", true )
addEventHandler( "onPlayerRequestInvitePlayerInOffice", resourceRoot, onPlayerRequestInvitePlayerInOffice_handler )