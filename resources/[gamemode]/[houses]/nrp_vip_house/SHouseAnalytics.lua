
-- Общее количество квартир каждого класса
COUNT_APARTAMENTS = {}
for k, v in pairs( APARTMENTS_LIST ) do
	COUNT_APARTAMENTS[ v.class ] = (COUNT_APARTAMENTS[ v.class ] or 0) + 1
end

-- Функция для связки с ИД аналитики для квартир: apartament_class[1-3]
function GetHouseClassFromList( field, value )
	return field .. APARTMENTS_CLASSES[ value ].apartament_class
end

-- Функция для связки с ИД аналитики для коттеджей, вилл: cottage_class[1-6], village_class[1-3], country_class[1]
function GetVipHouseClassFromList( field, value )
	for k, v in pairs( VIP_HOUSES_REVERSE ) do
		if v[ field ] == value then
			return field .. v[ field ]
		end
	end
end

-- ИД от аналитиков
ANALYTICS_HOUSE_ID =
{
	[ 1 ]  = { class = GetHouseClassFromList( "apartament_class", 1 ) }, -- Квартира 1
	[ 2 ]  = { class = GetHouseClassFromList( "apartament_class", 2 ) }, -- Квартира 2
	[ 3 ]  = { class = GetHouseClassFromList( "apartament_class", 3 ) }, -- Квартира 3

	[ 4 ]  = { class = GetVipHouseClassFromList( "cottage_class", 1 )  }, -- Коттедж 1
	[ 5 ]  = { class = GetVipHouseClassFromList( "cottage_class", 2 )  }, -- Коттедж 2
	[ 6 ]  = { class = GetVipHouseClassFromList( "cottage_class", 3 )  }, -- Коттедж 3
	[ 7 ]  = { class = GetVipHouseClassFromList( "cottage_class", 4 )  }, -- Коттедж 4
	[ 8 ]  = { class = GetVipHouseClassFromList( "cottage_class", 5 )  }, -- Коттедж 5
	[ 9 ]  = { class = GetVipHouseClassFromList( "cottage_class", 6 )  }, -- Коттедж 6

	[ 10 ] = { class = GetVipHouseClassFromList( "village_class", 1 ) }, -- Вилла 1
	[ 11 ] = { class = GetVipHouseClassFromList( "village_class", 2 ) }, -- Вилла 2
	[ 12 ] = { class = GetVipHouseClassFromList( "village_class", 3 ) }, -- Вилла 3

	[ 13 ] = { class = GetVipHouseClassFromList( "country_class", 1 ) }, -- Деревенский дом 1
}

-- Функция поулчения ИД аналитики по данным дома
function GetHouseIdByHid( house_data )
	if not house_data then
		return false
	end

    local target_field = house_data.village_class and "village_class" or (house_data.cottage_class and "cottage_class" or (house_data.country_class and "country_class" or "apartament_class" ))
	local target_value = target_field .. house_data[ target_field ] -- cottage_class[1-6], village_class[1-3], apartament_class[1-3], country_class[1]
	for k, v in pairs( ANALYTICS_HOUSE_ID ) do
		if target_value == v.class then
			return k
		end
	end

	return false
end

-- Первый запрос на виллы, коттеджи
function CalculateAmountOfRealEstate()
	DB:queryAsync( function( qh )
		local result = qh:poll( -1 )
		if not result or #result == 0 then return end

		-- Пачка данных, которую будем отправлять
		local houses_data = {}

		-- Собираем первичную таблицу для всех ИД
		for house_id in pairs( ANALYTICS_HOUSE_ID ) do
			houses_data[ "mortage_id_" .. house_id .. "_total_count" ] = 0
			houses_data[ "mortage_id_" .. house_id .. "_total_cost" ]  = 0
			houses_data[ "mortage_id_" .. house_id .. "_free_count" ]  = 0
			houses_data[ "mortage_id_" .. house_id .. "_free_cost" ]   = 0
		end

		-- Собираем данные о коттеджах, виллах
		for k, v in pairs( result ) do
			local house_data = VIP_HOUSES_REVERSE[ v.hid ]
			local house_id =  GetHouseIdByHid( house_data )
			if house_id then				
				-- Если owner == 0, то владельца нет
				local t_field = v.owner == 0 and "free"  or "total"
				houses_data[ "mortage_id_" .. house_id .. "_" .. t_field .. "_count" ] = houses_data[ "mortage_id_" .. house_id .. "_" .. t_field .. "_count" ] + 1
				houses_data[ "mortage_id_" .. house_id .. "_" .. t_field .. "_cost" ]  = houses_data[ "mortage_id_" .. house_id .. "_" .. t_field .. "_cost" ] + house_data.cost
			end
		end
		
		-- Передаем данные на 2 запрос
		CalculateAmountApartaments( houses_data )
	end, {}, "SELECT hid, owner FROM nrp_viphouses" )
end

-- Второй запрос на квартиры
function CalculateAmountApartaments( houses_data )
	DB:queryAsync( function( qh, houses_data )
		local result = qh:poll( -1 )
		if not result then return end

		for k, v in pairs( result ) do
			local house_data = APARTMENTS_CLASSES[ APARTMENTS_LIST[ v.id ].class ] 
			local house_id =  GetHouseIdByHid( house_data )
			if house_id then

				-- В бд присутствуют только купленные дома, считаем
				houses_data[ "mortage_id_" .. house_id .. "_total_count" ] = houses_data[ "mortage_id_" .. house_id .. "_total_count" ] + 1
				houses_data[ "mortage_id_" .. house_id .. "_total_cost" ]  = houses_data[ "mortage_id_" .. house_id .. "_total_cost" ] + house_data.cost
			end
		end

		-- Количество свободных квартир
		for i, v in pairs( COUNT_APARTAMENTS ) do
			-- Считаем остатки
			houses_data[ "mortage_id_" .. i .. "_free_count" ] = v - houses_data[ "mortage_id_" .. i .. "_total_count" ]
			houses_data[ "mortage_id_" .. i .. "_total_count" ] = v
			houses_data[ "mortage_id_" .. i .. "_free_cost" ]  = houses_data[ "mortage_id_" .. i .. "_free_count" ] * APARTMENTS_CLASSES[ i ].cost
		end

		-- Данные собраны, отсылаем
        SendElasticGameEvent( nil, "mortage_status", houses_data )
	end, { houses_data }, "SELECT id FROM nrp_apartments" )
end

function SendEstatesData( )
	CalculateAmountOfRealEstate()
    SEND_ESTATE_DATA_TMR = setTimer( SendEstatesData, 24 * 60 * 60 * 1000, 1 )
end
ExecAtTime( "02:00", SendEstatesData )

addCommandHandler( "test_estates", function( player )
	if player:GetAccessLevel( ) < ACCESS_LEVEL_DEVELOPER then return end
    SendEstatesData()
end )