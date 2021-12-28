loadstring(exports.interfacer:extend("Interfacer"))()
Extend("ShApartments")
Extend("SVehicle")
Extend("SPlayer")
Extend("SInterior")

SDB_SEND_CONNECTIONS_STATS = true
Extend("SDB")

Extend("ShVehicleConfig")
Extend("SPlayerOffline")
Extend("ShHouseSale")

APARTMENTS_ID_BY_MARKER = { }
APARTMENTS_LIST_OWNERS = { }

-- текущие коэффициенты на счетчики, предпологается менять через окно мэрии
REAL_METERING_DEVICE_FACTOR = {
    [ CONST_METERING_DEVICE_TYPE.NOT_METER ] = DEFAULT_METERING_DEVICE_FACTOR[ CONST_METERING_DEVICE_TYPE.NOT_METER ],
    [ CONST_METERING_DEVICE_TYPE.LOW       ] = DEFAULT_METERING_DEVICE_FACTOR[ CONST_METERING_DEVICE_TYPE.LOW ],
    [ CONST_METERING_DEVICE_TYPE.MEDIUM    ] = DEFAULT_METERING_DEVICE_FACTOR[ CONST_METERING_DEVICE_TYPE.MEDIUM ],
    [ CONST_METERING_DEVICE_TYPE.HIGH      ] = DEFAULT_METERING_DEVICE_FACTOR[ CONST_METERING_DEVICE_TYPE.HIGH ],
}

function CreateApartmentsMarkersAndLoadFromDatabase( )
	for id, data in ipairs( APARTMENTS_LIST ) do
		APARTMENTS_LIST_OWNERS[ id ] = { }
	end

	DB:createTable( "nrp_apartments", {
		{ Field = "id",						Type = "int(11) unsigned",		Null = "NO",	Key = "" 				},
		{ Field = "number",					Type = "int(11) unsigned",		Null = "NO",	Key = "" 				},
		{ Field = "meter_type",				Type = "smallint(3)",			Null = "NO",	Key = "",	Default = 0	},
		{ Field = "sale_state",				Type = "smallint(3)",			Null = "NO",	Key = "",	Default = 0	},
		{ Field = "user_id",				Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0 },
		{ Field = "paid_days",				Type = "int(11)",				Null = "NO",	Key = "",	Default = 1 },
		{ Field = "time_to_pay",			Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0 },
		{ Field = "paid_upgrade",			Type = "int(3) unsigned",		Null = "NO",	Key = "",	Default = 0 },
		{ Field = "owner_change_time",		Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0 },
		{ Field = "inventory_data",			Type = "text",					Null = "YES",	Key = "", 				},
		{ Field = "inventory_expand",		Type = "smallint(11) unsigned", Null = "YES",	Key = "", 	Default = 0 },
	} )
	DB:exec( "ALTER TABLE nrp_apartments ADD PRIMARY KEY( id, number )" )

	local function callback( query )
		if not query then return end
		local result = dbPoll( query, 0 )
		dbFree( query )
		if type( result ) ~= "table" then return end

		for _, data in ipairs( result ) do
			data.inventory_data = data.inventory_data and fromJSON( data.inventory_data ) or {}
			APARTMENTS_LIST_OWNERS[ data.id ][ data.number ] = data

			local class_data = APARTMENTS_CLASSES[ APARTMENTS_LIST[ data.id ].class ]
			triggerEvent( "onHouseUpdate", resourceRoot, data.id, data.number, data, class_data.inventory_max_weight )
		end

		for idx, player in ipairs( GetPlayersInGame( ) ) do
			player:SetPrivateData( "apartments", nil )
			onPlayerCompleteLogin_handler( player )
		end

		setTimer( ApartmentsProcessing, 60 * 1000, 0 )
	end

	DB:queryAsync( callback, { }, "SELECT * FROM nrp_apartments" )
end
addEventHandler( "onResourceStart", resourceRoot, CreateApartmentsMarkersAndLoadFromDatabase )

function SaveApartmentData( id, number, insert )
	local data = APARTMENTS_LIST_OWNERS[ id ][ number ]
	if not data then return end

	local query
	if insert then
		query = [[REPLACE INTO nrp_apartments( id, number, meter_type, sale_state, user_id, paid_days, 
				time_to_pay, paid_upgrade, owner_change_time, inventory_data, inventory_expand )
			VALUES( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )]]
	else
		query = [[UPDATE nrp_apartments SET id = ?, number = ?, meter_type = ?, sale_state = ?, user_id = ?, paid_days = ?, 
				time_to_pay = ?, paid_upgrade = ?, owner_change_time = ?, inventory_data = ?, inventory_expand = ?
			WHERE `id` = ? and `number` = ? LIMIT 1]]
	end
	DB:exec( query, data.id, data.number, data.meter_type or 0, data.sale_state, data.user_id, data.paid_days, 
		data.time_to_pay, data.paid_upgrade, data.owner_change_time, toJSON( data.inventory_data or {}, true ), data.inventory_expand, 
		data.id, data.number )	
end

function onApartmentOwnerChange( id, number, insert )
	local data = APARTMENTS_LIST_OWNERS[ id ][ number ]
	if not data then return end

	if not data.inventory_data then
		data.inventory_data = {}
		data.inventory_expand = 0
	end

	local class_data = APARTMENTS_CLASSES[ APARTMENTS_LIST[ id ].class ]
	triggerEvent( "onHouseUpdate", resourceRoot, id, number, data, class_data.inventory_max_weight )
end

local current_proc_ap_id = 0

function ApartmentsProcessing( )
	current_proc_ap_id = current_proc_ap_id % #APARTMENTS_LIST + 1
	local id = current_proc_ap_id
	local timestamp = getRealTime().timestamp

	for number, info in pairs( APARTMENTS_LIST_OWNERS[ id ] ) do
		local user_id = info.user_id
		if user_id ~= 0 and timestamp > info.time_to_pay then
			local owner_player = GetPlayerFromUserID(user_id)
			info.time_to_pay = timestamp + 24 * 60 * 60

			info.paid_days = info.paid_days - 1

			if info.paid_days < -14 then
				
				WriteLog("apartments", "[Server.Apartments.Sell] Апартаменты [ID:%s/%s] были проданы за долги. Бывший владелец: [ID:%s]", id, number, info.user_id)

				local timestamp = getRealTime().timestamp
				local is_first_owner = info.owner_change_time == 0
				local owned_time = is_first_owner and 0 or ( timestamp - info.owner_change_time )	

				local class = APARTMENTS_LIST[ id ].class
				local class_data = APARTMENTS_CLASSES[ class ]

				local metering_factor = REAL_METERING_DEVICE_FACTOR[ info.meter_type or 0 ] or 1
				local cost_day = class_data.cost_day * metering_factor
				for i = 1, info.paid_upgrade do
					cost_day = cost_day - class_data.upgrades[ i ].profit
				end

				local debt = -info.paid_days * cost_day

				info.user_id = 0
				info.time_to_pay = 0
				info.paid_days = 1
				info.paid_upgrade = 0
				info.sale_state = CONST_SALE_STATE.NOT_SALE
				info.owner_change_time = timestamp
				info.inventory_data = nil

				onApartmentOwnerChange( id, number )
				SaveApartmentData( id, number )

				local price = class_data.cost * 0.4

				-- обнуляем продажу на бирже недвижимости
                local resource = getResourceFromName( "nrp_house_sale" )
                if resource and getResourceState( resource ) == "running" then
                    local hid = id.."_"..number
                    local pData = {
                        hid                      = hid,
                        house_type               = CONST_HOUSE_TYPE.APARTMENT,
                        possible_buyer_id        = 0,
                        seller_id                = 0,
                        sale_state               = CONST_SALE_STATE.NOT_SALE,
                        total_rental_fee         = 0,
                        sale_publish_date        = 0,
                        sale_cost                = 0,
                        location_id              = GetLocationIDFromHID( hid, CONST_HOUSE_TYPE.APARTMENT ),
                    }

                    triggerEvent( "onChangeHouseSaleData", resourceRoot, hid, pData )
                end

				if owner_player then
					-- обновляем apartments
					onPlayerCompleteLogin_handler( owner_player )
					owner_player:ShowInfo( string.format("Твоя квартира #%s в доме %s была продана за долги", number, id ) )

					owner_player:GiveMoney( price, "apartments_debt_sell", "flat" )

					CheckPlayerVehiclesSlots(owner_player)
				else
					local query = DB:exec( "UPDATE nrp_players SET money=`money`+? WHERE id=?", price, user_id)
					if not query then
						outputDebugString("Error pay player", 1)
					end
				end

				triggerEvent( "onPlayerHouseLoss", owner_player or resourceRoot, 
					{
						mortage_type = "flat",
						mortage_group = class,
						mortage_id = id * 100 + number,
						loss_reason = "service_debt",
						sum = debt,
						owned_days = math.floor( owned_time / ( 24 * 60 * 60 ) )  
					},
					not owner_player and user_id
				)

			else
				WriteLog("apartments", "[Server.Apartments.PayDay] Ежедневный платеж у апартаментов [ID:%s.%s]. Оплачено дней: [%s]. Следующее списание: [%s]", id, number, info.paid_days, info.time_to_pay)

				SaveApartmentData( id, number )

				-- обновляем инфу об арендной плате на бирже
				if info.sale_state > CONST_SALE_STATE.NOT_SALE then
					local hid = id .."_" .. number
					local total_rental_fee = CalculateTotalRentalFee( id, number )
					triggerEvent( "onUpdateTotalRentalFee", resourceRoot, hid, total_rental_fee )
				end
			end

			if owner_player then
				triggerClientEvent( owner_player, "HideUIControl", resourceRoot )
			end
		end
	end
end

function PlayerWantShowListApartments( id )
	local player = client or source

	id = tonumber( id )

	if id < 1 or id > #APARTMENTS_LIST then return end
	if not APARTMENTS_LIST[id] then return end

	local info = APARTMENTS_LIST[ id ]
	triggerClientEvent( player, "ShowUIList", resourceRoot, id, info.max_count, APARTMENTS_LIST_OWNERS[ id ], player:GetPermanentData( "wedding_at_id" ) )
end
addEvent("PlayerWantShowListApartments", true)
addEventHandler("PlayerWantShowListApartments", resourceRoot, PlayerWantShowListApartments)

function PlayerWantEnterApartment( id, number )
	local player = client or source
	
    if player:getData( "in_clan_event_lobby" ) or player:getData( "current_event" ) then return end

	id = tonumber( id )
	number = tonumber( number )

	if id < 1 or id > #APARTMENTS_LIST then return end
	if not APARTMENTS_LIST[id] then return end

	local info = APARTMENTS_LIST[ id ]
	local class_info = APARTMENTS_CLASSES[ info.class ]
	local pos = player.position

	removePedFromVehicle( player )
	player:Teleport( class_info.exit_position, 5000 + id * 100 + number, class_info.interior, 1000 )
	player:SetInApartments( id, number, true )
end
addEvent("PlayerWantEnterApartment", true)
addEventHandler("PlayerWantEnterApartment", root, PlayerWantEnterApartment)

function PlayerWantCallApartment( id, number )
	local player = client or source

	id = tonumber( id )
	number = tonumber( number )

	if not APARTMENTS_LIST[id] then return end
	if not APARTMENTS_LIST_OWNERS[ id ][ number ] then return end

	local owner = GetPlayer( APARTMENTS_LIST_OWNERS[ id ][ number ].user_id )
	if not owner then
		player:InfoWindow( "Хозяина жилья нет дома" )
		return
	end

	local dimension = owner.dimension - 5000
	local owner_id = math.floor( dimension / 100 )
	local owner_number = dimension % 100

	local is_owner_in_apartment = owner_id == id and owner_number == number
	if not is_owner_in_apartment then
		player:InfoWindow( "Хозяина жилья нет дома" )
		return
	end

	owner:triggerEvent( "onClientPlayerCallHouse", resourceRoot, player, id, number )
end
addEvent("PlayerWantCallApartment", true)
addEventHandler("PlayerWantCallApartment", root, PlayerWantCallApartment)

function PlayerWantShowApartmentsInfo(id, number)
	if not client then return end

	local info = APARTMENTS_LIST[id]

	local data = {
		id = id;
		number = number;
		class = info.class;
		cost = APARTMENTS_CLASSES[ info.class ].cost;
		discount_cost = APARTMENTS_CLASSES[ info.class ].discount_cost;
		owner = APARTMENTS_LIST_OWNERS[ id ][ number ] and APARTMENTS_LIST_OWNERS[ id ][ number ].user_id;
	}

	if WEDDING_USE_BOTH_APART then
		local player_partner_id = client:GetPermanentData( "wedding_at_id" )
		if player_partner_id then
			if data.owner ~= client:GetUserID() and player_partner_id == data.owner then
				data.wedding_use = true
			end
		end
	end

	triggerClientEvent( client, "ShowUIInfo", resourceRoot, data )
end
addEvent("PlayerWantShowApartmentsInfo", true)
addEventHandler("PlayerWantShowApartmentsInfo", resourceRoot, PlayerWantShowApartmentsInfo)

function CreateApartmentMarkersOnPlayerSpawn( _, _, _, _, _, _, interior, dimension )
	if interior == 0 or dimension == 0 then return end

	local dimension = dimension - 5000
	local id = math.floor( dimension / 100 )
	local number = dimension % 100

	if not APARTMENTS_LIST[ id ] or APARTMENTS_LIST[ id ].max_count < number then return end
	if APARTMENTS_CLASSES[ APARTMENTS_LIST[ id ].class ].interior ~= interior then return end

	source:SetInApartments( id, number, true )
end
addEventHandler("onPlayerSpawn", root, CreateApartmentMarkersOnPlayerSpawn)

function PlayerExitFromApartments( id )
	local player = client or source

	player.position = APARTMENTS_LIST[ id ].enter_position
	player.interior = 0
	player.dimension = 0
	
	player:SetInApartments( id, number, false )
end
addEvent( "PlayerExitFromApartments", true )
addEventHandler("PlayerExitFromApartments", root, PlayerExitFromApartments)

function onGovChangeMeteringFactor_handler( meter_type, new_factor )
	if not isnumber( meter_type ) then return end
	if not isnumber( new_factor ) then return end
	if not DEFAULT_METERING_DEVICE_FACTOR[ meter_type ] then return end

	REAL_METERING_DEVICE_FACTOR[ meter_type ] = new_factor
end
addEvent( "onGovChangeMeteringFactor", true )
addEventHandler("onGovChangeMeteringFactor", root, onGovChangeMeteringFactor_handler)

addEventHandler( "onResourceStop", resourceRoot, function()
	local players = getElementsByType( "player" )
	for _, player in ipairs( players ) do
		if player:IsInGame() then
			if player.interior ~= 0 and player.dimension ~= 0 then
				local dimension = player.dimension - 5000
				local id = math.floor( dimension / 100 )
				local number = dimension % 100

				if APARTMENTS_LIST[ id ] and APARTMENTS_LIST[ id ].max_count >= number and APARTMENTS_CLASSES[ APARTMENTS_LIST[ id ].class ].interior == player.interior then
					player.position = APARTMENTS_LIST[ id ].enter_position
					player.interior = 0
					player.dimension = 0
				end
			end
		end
	end
end )

function GetPlayerApartmentsData( player )
	local player = isElement( player ) and player or source
	local user_id = player:GetUserID( )

	local apartments_data = {}
	for id, info in ipairs( APARTMENTS_LIST ) do
		for number, data in pairs( APARTMENTS_LIST_OWNERS[ id ] ) do
			if data.user_id == user_id then
				table.insert( apartments_data, { id, number, info, data } )
			end
		end
	end

	return apartments_data
end

function GetApartmentListByUserId( user_id )
	if not tonumber( user_id ) then return end

	local apartment_list = {}
	for id, info in ipairs( APARTMENTS_LIST ) do
		for number, data in pairs( APARTMENTS_LIST_OWNERS[ id ] ) do
			if data.user_id == user_id then
				local class_data = APARTMENTS_CLASSES[ APARTMENTS_LIST[ id ].class ]

				local pay_minus = 0
				for i = 1, data.paid_upgrade do
					pay_minus = pay_minus + class_data.upgrades[i].profit
				end

				local metering_factor = REAL_METERING_DEVICE_FACTOR[ data.meter_type or 0 ] or 1
				local cost_day = class_data.cost_day
				cost_day = cost_day * metering_factor - pay_minus

				table.insert( apartment_list, {
					id            			= id,
					hid           			= id .. "_" .. number,
					number        			= number,
					paid_days     			= data.paid_days,
					cost_day      			= cost_day,
					sale_state    			= data.sale_state,
					user_id       			= user_id,
					inventory_max_weight	= class_data.inventory_max_weight + data.inventory_expand,
				})

			end
		end
	end

	return apartment_list
end

function GetPlayerApartmentList( player )
	if not isElement( player ) then return end
	local user_id = player:GetUserID( )

	return GetApartmentListByUserId( user_id )
end

function HasPlayer_AnyApartmentWithId_EqualTo( player, apart_id )
	if not isElement( player ) then return end

	local apartments = player:getData( "apartments" ) or {}
	for i, apart in ipairs( apartments ) do
		if apart.id == apart_id then
			return true
		end
	end

	return false
end

function GetPlayerAllApartmentCarSlotInfo( pPlayer )
	local total_slot_count = 0
	local user_id = pPlayer:GetUserID( )
	local apartments = GetPlayerApartmentList( pPlayer ) or {}

	for k, apart in pairs( apartments ) do
		local info = APARTMENTS_LIST_OWNERS[ apart.id ][ apart.number ]
		if info and info.user_id == user_id and info.paid_days > 0 then
			local conf = APARTMENTS_CLASSES[ APARTMENTS_LIST[ apart.id ].class ]
			total_slot_count = total_slot_count + ( conf.count_vehicles or 0 )
		end
	end

	return total_slot_count
end

function GetApartmentsData( id, number, key )
	local apartment = APARTMENTS_LIST_OWNERS[ id ][ number ]
	if not apartment then return end

	return apartment[ key ]
end

function SetApartmentsData( id, number, key, value )
	local apartment = APARTMENTS_LIST_OWNERS[ id ][ number ]
	if not apartment then return end

	apartment[ key ] = value
	value = type( value ) == "table" and toJSON( value, true ) or value
	DB:exec( "UPDATE nrp_apartments SET `??` = ? WHERE `id` = ? and `number` = ?;", key, value, id, number )
end

function ResetApartments( id, number )
	DB:exec( "DELETE FROM nrp_apartments WHERE id=? AND number=?", id, number )
	APARTMENTS_LIST_OWNERS[ id ][ number ] = nil
end

function onPlayerCompleteLogin_handler( player )
	player = isElement( player ) and player or source
	local user_id = player:GetUserID( )

	local apartments = {}
	for id, info in ipairs( APARTMENTS_LIST ) do
		for number, data in pairs( APARTMENTS_LIST_OWNERS[ id ] ) do
			if data.user_id == user_id then
				table.insert( apartments, { id = id, number = number } )
				if data.paid_days < 1 then
					player:ShowInfo( string.format( "Скоро твоя квартира #%s в доме %s будет продана за долги!", number, id ) )
				end
			end
		end
	end

	player:SetPrivateData( "apartments", apartments )

	triggerClientEvent( player, "onUpdateApartmentsMarkersData", resourceRoot )
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )


Player.SetInApartments = function( self, id, number, is_in_apartments )
	self:SetPrivateData( "in_apartments", is_in_apartments )

	if is_in_apartments then
        local friendly_apart = false
        local dimension = 5000 + id * 100 + number
		self:triggerEvent( "CreateApartmentMarkers", resourceRoot, id, number, dimension )

		triggerEvent( "onPlayerEnterApartments", self, id, number )

		self:CompleteDailyQuest( "np_visit_apartament" )

		--Проверка, возможен ли будет спавн в квартире после захода в игру ( женаты )
		if APARTMENTS_LIST_OWNERS[ id ][ number ] then
			local owner_id = APARTMENTS_LIST_OWNERS[ id ][ number ].user_id
			local current_player_id = self:GetUserID()
			local wedding_at_id = self:GetPermanentData( "wedding_at_id" )

			if current_player_id ~= owner_id and wedding_at_id and wedding_at_id == owner_id then
				friendly_apart = true
				self:SetPermanentData( "last_visited_viphouse", false )
			end

			if current_player_id == owner_id then
				self:SetPermanentData( "last_visited_viphouse", false )
			end
		end
		self:SetPermanentData( "last_visited_apart", { number = number, id = id, friendly = friendly_apart } )
	end
end

function CheckPlayerWeddingAtApartOwner( player, id, number )
	if not isElement( player ) then return end
	if not APARTMENTS_LIST_OWNERS[ id ] then return false end

	local player_id = player:GetUserID( )
	local partner_id = player:GetPermanentData( "wedding_at_id" )

	if number then
		if APARTMENTS_LIST_OWNERS[ id ][ number ] then
			local owner_id = APARTMENTS_LIST_OWNERS[ id ][ number ].user_id
			return owner_id == player_id or owner_id == partner_id
		end
	else
		for k, data in pairs( APARTMENTS_LIST_OWNERS[ id ] ) do
			if data.user_id == player_id or data.user_id == partner_id then
				return true
			end
		end
	end

	return false
end


-- есть ли задолженность по арендной плате
function HasApartmentRentalDebt( id, number )
	return APARTMENTS_LIST_OWNERS[ id ][ number ].paid_days < 0
end

function HasPlayerAnyApartmentRentalDebt( player )
	local user_id = player:GetUserID( )
	local apartments = player:getData( "apartments" ) or {}
	for i, apart in ipairs( apartments ) do
        local info = APARTMENTS_LIST_OWNERS[ apart.id ] and APARTMENTS_LIST_OWNERS[ apart.id ][apart.number]
        if info and info.user_id == user_id and info.paid_days < 0 then
            return true
		end
	end

	return false
end


------------------------------------------------------------------------------------------------------------------------
----- Для теста
if SERVER_NUMBER > 100 then
	addCommandHandler( "setapartpaiddays", function( player, cmd, id, number, paid_days )
		local is_valid = tonumber( id ) and tonumber( id ) > 0 and tonumber( number ) and tonumber( number ) > 0 and tonumber( paid_days )
		if not is_valid then
			outputConsole( "ОШИБКА! Неправильные аргументы. Введите 'setapartpaiddays i n s' , где i - номер дома, n-номер квартиры, s - колво дней", player )
			return
		end

		id	= tonumber( id )
		number = tonumber( number )
		paid_days = tonumber( paid_days )

		local info = APARTMENTS_LIST_OWNERS[ id ] and APARTMENTS_LIST_OWNERS[ id ][number]
		if not info then
			outputConsole( "ОШИБКА! Квартира не найдена. Проверьте параметры", player )
			return
		end

		info.paid_days = paid_days
		info.time_to_pay = getRealTime().timestamp - 24 * 60 * 60
		SaveApartmentData( id, number )
	end )

	addCommandHandler( "apartsaleblock", function( player, cmd, day )
		day = tonumber( day )
		if not day then
			outputConsole( "ОШИБКА! Неправильные аргументы. Введите 'apartsaleblock i' , где i - кол-во дней", player )
			return
		end

		BLOCK_SALE_TIMESTAMP = day * 24 * 60 * 60

		outputConsole( "Установлен запрет на продажу квартиры в " .. day .. " д.", player )
	end )
end