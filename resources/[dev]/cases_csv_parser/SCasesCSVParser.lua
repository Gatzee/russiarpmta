loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "csv" )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "SDB" )
Extend( "ShTimelib" )
Extend( "ShAccessories" )
Extend( "ShSkin" )
Extend( "ShVinyls" )
Extend( "ShPhone" )

function UpdateCasesInfo( callback_fn )
	print( "\n\n\n\n\n\t\tUpdateCasesInfo\n" )

	-- Подгружаем текущие данные для бэкапа напрямую из БД, т.к. MariaGet может вернуть старые данные
	CommonDB:queryAsync( function( query )
		local result = query:poll( -1 )
		if result and #result > 0 then
			local cases_info = { }
			for i, v in pairs( result ) do
				v.items = fromJSON( v.items )
				cases_info[ v.id ] = v
			end

			-- Бэкапим текущие данные
			local file = fileCreate( "cases_info/" .. os.date( "%Y%m%d_%H%M%S" ) .. "_backup.json" )
			fileWrite( file, toJSON( cases_info, true ) )
			fileClose( file )

			-- Если хотим, подгружаем данные из бэкапа
			if LOAD_FROM_BACKUP then
				local file = fileOpen( LOAD_FROM_BACKUP )
				local data = fileRead( file, fileGetSize( file ) )
				fileClose( file )
				cases_info = data and fromJSON( data )
				if not cases_info then
					error( "Не удалось подгрузить данные из бэкапа" )
				end
			end

			ContinueUpdateCasesInfo( cases_info, callback_fn )
		else
			error( "Какая-то залупа с бд" )
		end
	end, { }, "SELECT * FROM f4_cases" )
end

function ContinueUpdateCasesInfo( cases_info, callback_fn )
	--------------------------------------------------------------------
	-- Удаляем нулл-значения
	--------------------------------------------------------------------
	local cases_id_to_data = { }

	for case_id, case_data in pairs( cases_info ) do
		cases_id_to_data[ case_id ] = case_data

		for k, v in pairs( case_data ) do
			if v == false then
				case_data[ k ] = nil
			end
		end

		-- case_data.is_new = false
	end

	--------------------------------------------------------------------
	-- Парсим csv
	--------------------------------------------------------------------

	local CASE_GROUP_TO_POSITION = {
		[ "CaseBattle-1" ] = -12,
		[ "CaseBattle-2" ] = -11,
		[ "Limited-Low" ] = -6,
		[ "Limited-Mid-1" ] = -5,
		[ "Limited-High" ] = -4,
		[ "Limited-Mid-2" ] = -2,
		[ "Low" ] = 2,
		[ "Mid-1" ] = 4,
		[ "High" ] = 5,
		[ "Mid-2" ] = 6,
	}

	function GetCaseGroupByCost( case_data )
		if case_data.cost >= 999 then
			return "High"
		elseif case_data.cost >= 599 then
			return "Mid-2"
		elseif case_data.cost >= 399 then
			return "Mid-1"
		else
			return "Low"
		end
	end

	function GetCaseGroup( case_data )
		if case_data.versus then
			for n, case_ids in pairs( CASE_BATTLES ) do
				for i, case_id in pairs( case_ids ) do
					if case_id == case_data.id then
						return "CaseBattle-" .. i
					end
				end
			end
		elseif case_data.temp_start_count then
			return "Limited-" .. GetCaseGroupByCost( case_data )
		else
			return GetCaseGroupByCost( case_data )
		end
	end

	function GetCasePosition( case_data )
		return CASE_GROUP_TO_POSITION[ GetCaseGroup( case_data ) ]
	end

	TYPE_CONVERSION = {
		[ "car" ] = "vehicle",
		[ "vehicle" ] = "vehicle",
		[ "soft" ] = "soft",
		[ "skin" ] = "skin",
		[ "acces" ] = "accessory",
		[ "accessory" ] = "accessory",
		[ "prem.acc" ] = "premium",
		[ "premium acc." ] = "premium",
		[ "anim" ] = "dance",
		[ "weapon" ] = "weapon",
		[ "ammo" ] = "weapon",
		[ "vinyl" ] = "vinyl",
		[ "vynil" ] = "vinyl",

		[ "box5" ] = "box5", --канистра + 2 ключа от тюрьм
		[ "taxi" ] = "taxi",
		[ "license_vehicle" ] = "license_vehicle",
		[ "license_gun" ] = "license_gun",
		[ "slot_vehicle" ] = "slot_vehicle",
		[ "jailkeys" ] = "jailkeys",

		-- [ "Other" ] = PART_T5, -- и жетон, и прем, и ещё какая-то залупа
		-- [ "wof" ] = PART_T5, -- жетон
	}

	EXCHANGEABLE_ITEMS = {
		skin = true,
		accessory = true,
		dance = true,
		phone_img = true,
	}

	local dances = exports.nrp_dancing_school:GetDancesList()
	local dance_name_to_id = { }
	for k, v in pairs( dances ) do
		dance_name_to_id[ utf8.lower( v.name ) ] = k
	end

	local new_cases_data = cases_info
	local list_of_new_cases_to_add = { }

	function ParseCaseDataFromCSV( case_id, file_name )
		if type( file_name ) ~= "string" then
			file_name = case_id .. ".csv"
		end
		local file = fileOpen( "csv/" .. file_name )
		local data = fileRead( file, fileGetSize( file ) )
		fileClose( file )

		local csv_reader = csv.openstring( data , { separator = ",", header =false } )
		local csv_table = { }
		for fields in csv_reader:lines() do
			table.insert( csv_table, fields )
		end
		
		local raw_case_data = csv_table[ 1 ]
		local case_id = case_id or raw_case_data[ 1 ]:lower( ):gsub( " ", "_" )
		local case_cost = raw_case_data[ 2 ]:gsub( "[\.,]00$", "" ):gsub( "[^%d]+", "" )

		local new_case_info = cases_id_to_data[ case_id ] or { }

		new_case_info.id = new_case_info.id or case_id
		new_case_info.name = new_case_info.name or raw_case_data[ 1 ]
		for i = #csv_table, 1, -1 do
			if utf8.find( csv_table[ i ][ 1 ], "^Название в игре" ) then
				new_case_info.name = csv_table[ i ][ 2 ]
			elseif utf8.find( csv_table[ i ][ 1 ], "^Лимит" ) then
				new_case_info.temp_start_count = csv_table[ i ][ 2 ]
			end
		end
		new_case_info.cost = tonumber( case_cost )
		new_case_info.position = CASES_POSITIONS[ new_case_info.id ] or GetCasePosition( new_case_info )
		
		new_case_info.items = { }

		local is_using_chance_cost = utf8.find( csv_table[ 2 ][ 7 ], "chance.?cost" )

		local vehicle_tuning
		for col = 14, 16 do
			if not csv_table[ 2 ][ col ] then
				break
			end
			for row = 1, 5 do
				if utf8.find( csv_table[ row ][ col ], "тюнинг" ) then
					vehicle_tuning = loadstring( "return " .. csv_table[ row + 1 ][ col ] )( )
					if type( vehicle_tuning ) ~= "table" then
						error( file_name .. ": криво прописан тюнинг" )
					end
					break
				end
			end
			if vehicle_tuning then
				break
			end
		end

		for i = 3, #csv_table do
			local Rareness, number, id, name, Type, cost, chance_cost, Drops_case_cost, chance, Group_chance, Winrate, exchange_soft, exchange_exp
			if is_using_chance_cost then
				Rareness, number, id, name, Type, cost, chance_cost, Drops_case_cost, chance, Group_chance, Winrate, exchange_soft, exchange_exp = unpack( csv_table[ i ] )
			else
				Rareness, number, id, name, Type, cost, Drops_case_cost, chance, Group_chance, Winrate, exchange_soft, exchange_exp = unpack( csv_table[ i ] )
			end

			if not Rareness or Rareness == "" then
				break
			end

			cost = cost:gsub( "[^%d]+", "" )
			chance_cost = chance_cost and chance_cost:gsub( "[^%d]+", "" )
			chance = chance:gsub( "[^%d]+", "" )
			
			exchange_soft = exchange_soft and exchange_soft:gsub( "[^%d]+", "" )
			exchange_exp = exchange_exp and exchange_exp:gsub( "[^%d]+", "" )

			local item_type = TYPE_CONVERSION[ Type and Type:lower( ) ]

			local item_chance = tonumber( string.format( "%.4f", tonumber( case_cost ) / tonumber( chance_cost or cost ) ) )
			local is_fake_chance = CASES_WITH_FAKE_CHANCES[ case_id ]
			local item = {
				ord = i - 2,
				id = item_type,
				cost = tonumber( cost ),
				chance = is_fake_chance and ( chance == "0" and 0 or tonumber( chance ) / 100 ) or item_chance,
				fake_chance = is_fake_chance and item_chance or nil,
				rare = tonumber( Rareness ),
				params = { },
			}
			table.insert( new_case_info.items, item ) 

			if item.id then
				if item.id == "vehicle" then
					item.params.model = tonumber( id:gsub( "[^%d]+", "" ), 10 )

					local veh_config = VEHICLE_CONFIG[ item.params.model ]
					if not veh_config then
						print( case_id, i, "no conf", name, "id", item.params.model )
						return 
					end
					
					if VEHICLE_CONFIG[ item.params.model ].variants[ 2 ] then
						if tonumber( number ) then
							item.params.variant = tonumber( number )
						else
							if utf8.sub( name, -utf8.len( veh_config.model ) ) == veh_config.model then
								item.params.variant = 1
							else
								for variant, variant_conf in pairs( veh_config.variants ) do
									if variant_conf.mod ~= "" and utf8.find( name, variant_conf.mod, 1, true ) then
										item.params.variant = variant
										break
									end
								end
							end
							print( case_id .. ":" .. i .. ": проверить вариант (".. (item.params.variant or 1) ..")", id, name, " == ", veh_config.model .." ".. (veh_config.variants[ item.params.variant or 1 ].mod or "") )
						end
					end
					if vehicle_tuning and #new_case_info.items == 1 then
						item.params.tuning = vehicle_tuning
						-- item.params.color = LOTTERIES_INFO[ lottery_id ].analytics_name
					end
				elseif item.id == "skin" then
					item.params.model = tonumber( id:gsub( "[^%d]+", "" ), 10 )
				elseif item.id == "accessory" then
					-- Некоторые идентификаторы не совпадают с указанными в доке
					local DOC_ID_TO_DEV_ID = {
						[ "m2_asce25" ] = "nightmare",
						[ "m2_asce13" ] = "scarf_deserted_r",
						[ "m2_asce26" ] = "pumpkin",
						[ "m2_asce14" ] = "scarf_deserted_y",
						[ "m2_asce09" ] = "pendant_1",
						[ "m2_acse36" ] = "panam_hat",
						[ "m2_acse39" ] = "wood_black_glasses",
						[ "m2_asce24" ] = "scythe",
						[ "m2_acse34" ] = "deer_mask",
						[ "m2_acse38" ] = "diamond_hope",
						[ "m2_acse35" ] = "new_year_scarf",
						[ "m2_asce23" ] = "scarf_deserted_w",
						[ "m2_acse33" ] = "new_year_hat",
						[ "m2_acse32" ] = "beard_santa",
						[ "m2_asce05" ] = "scarf_deserted_g",
						[ "m2_asce04" ] = "cylinder_hat",
						[ "m2_asce27" ] = "hell_wings",
						[ "m2_asce10" ] = "mask_mick",
						[ "m2_asce15" ] = "mask_scorp",
						[ "m2_acse37" ] = "diamond_bag",
						[ "m3_acse12" ] = "m2_asce12",
						[ "m2_asce16" ] = "helmet_avg",
						[ "m2_asce18" ] = "helmet_black",
					}
					item.params.model = ( CONST_ACCESSORIES_INFO[ DOC_ID_TO_DEV_ID[id] or id ] or {} ).model
				elseif item.id == "soft" then
					item.params.count = tonumber( ({ name:gsub( "[^%d]+", "" ) })[ 1 ] )
				elseif item.id == "premium" then
					item.params.days = tonumber( ({ name:gsub( "[^%d]+", "" ) })[ 1 ] )
				elseif item.id == "dance" then
					item.params.id = tonumber( id )
				elseif item.id == "weapon" then
					item.params.id = tonumber( id )
					item.params.ammo = tonumber( number ) or 30
				elseif item.id == "vinyl" then
					item.params.id = tonumber( id ) and not utf8.find( utf8.lower( name ), "советский" ) and ( "s" .. id ) or id
				elseif item.id == "taxi" then
					item.params.count = tonumber( ({ name:gsub( "[^%d]+", "" ) })[ 1 ] )
				elseif item.id == "car_slot" then
					item.params.count = tonumber( ({ name:gsub( "[^%d]+", "" ) })[ 1 ] )
				elseif item.id == "jailkeys" then
					item.params.count = tonumber( ({ name:gsub( "[^%d]+", "" ) })[ 1 ] )
				elseif item.id == "license_vehicle" then
					item.params.license_type = tonumber( ({ name:gsub( "[^%d]+", "" ) })[ 1 ] )
				elseif item.id == "slot_vehicle" then
					item.params.count = tonumber( ({ name:gsub( "[^%d]+", "" ) })[ 1 ] )
				elseif item.id == "box5" then
					item.id = "box"
					item.params = fromJSON( [[ {
						"number": 5,
						"items": {
							"fuelcan": {
								"count": 1
							},
							"repairbox": {
								"count": 2
							},
						}
					} ]] )
				end
			else

				name = utf8.lower( name )
				if utf8.find( name, "пакет новичка" ) then
					item.id = "box"
					item.params = fromJSON( [[
						{
							"number": 1,
							"items": {
								"repairbox": {
									"count": 2
								},
								"firstaid": {
									"count": 2
								},
								"car_evac": {
									"count": 2
								},
								"jailkeys": {
									"count": 2
								}
							}
						}
					]] )

				elseif utf8.find( name, "пакет стартовый" ) then
					item.id = "box"
					item.params = fromJSON( [[
						{
							"number": 2,
							"items": {
								"premium": {
									"days": 1
								},
								"repairbox": {
									"count": 2
								},
								"firstaid": {
									"count": 2
								},
								"car_evac": {
									"count": 2
								},
								"jailkeys": {
									"count": 3
								}
							}
						}
					]] )

				elseif utf8.find( name, "жетон" ) then
					item.id = "wof_coin"
					item.params.count = tonumber( ({ name:gsub( "[^%d]+", "" ) })[ 1 ] )
					item.params.type = utf8.find( name, "vip" ) and "gold" or "default"

				elseif utf8.find( name, "тема в телефон" ) then
					item.id = "phone_img"
					item.params.id = id

				elseif utf8.find( name, "прем" ) then
					item.id = "premium"
					item.params.days = tonumber( ({ name:gsub( "[^%d]+", "" ) })[ 1 ] )

				elseif utf8.find( id, "assembl_detail" ) then
					item.id = "assembl_detail"
					item.params.id = tonumber( ({ id:gsub( "[^%d]+", "" ) })[ 1 ] or 1 )
				
				else
					print( case_id, "unknown", i, inspect( name ) )
				end
			end

			if item.id then
				local k,v = next( item.params )
				if not v then
					Debug( case_id .. " no params " .. i .." " .. name, 1 )
				else
					if EXCHANGEABLE_ITEMS[ item.id ] then
						if not tonumber( exchange_soft ) then
							Debug( case_id .. " no exchange " .. i .." " .. name, 1 )
						end
						item.params.exchange = {
							soft = tonumber( exchange_soft ),
							exp = tonumber( exchange_exp ),
						}
					end
				end
			end

		end
		
		return new_case_info
	end

	for case_id, file_name in pairs( NEW_CASES_CSV_FILE_NAMES ) do
		local existing_case = table.copy( cases_id_to_data[ case_id ] )
		local case = ParseCaseDataFromCSV( case_id, file_name )
		if not utf8.find( case.name, "кейс") and not utf8.find( case.name, "Кейс") then
			case.name = "Кейс " .. case.name
		end
		
		if existing_case 
		and existing_case.name ~= case.name  
		and existing_case.items[ 1 ].params.model ~= case.items[ 1 ].params.model
		and existing_case.items[ 2 ].params.model ~= case.items[ 2 ].params.model
		then
			error( "Уже имеется другой кейс с id = " .. existing_case.id )
		end
		
		new_cases_data[ case.id ] = case
		table.insert( list_of_new_cases_to_add, case.id )
	end

	function GetCaseIDFromName( name )
		name = utf8.lower( name )
		for case_id, case in pairs( new_cases_data ) do
			if name == utf8.gsub( utf8.gsub( utf8.lower( case.name ), " кейс", "" ), "кейс ", "" ) then
				return case.id
			end
		end
		error( "not found case by name '" .. name .. "'" )
	end

	for i, case_id in pairs( CASES_MARKED_AS_NEW ) do
		if not new_cases_data[ case_id ] then
			case_id = GetCaseIDFromName( case_id )
		end
		new_cases_data[ case_id ].is_new = true
	end

	for i, case_id in pairs( CASES_MARKED_AS_HIT ) do
		if not new_cases_data[ case_id ] then
			case_id = GetCaseIDFromName( case_id )
		end
		new_cases_data[ case_id ].is_hit = true
	end

	-- Проверяет, имеются ли другие кейсы на этой позиции, которые стартуют в такое же время, и перебрасывает их на последующие 2 недели
	local function CheckDuplicateCases( id, position, temp_start )
		for case_id, case_data in pairs( new_cases_data ) do
			if case_id ~= id and case_data.position == position and case_data.temp_start == temp_start and case_data.temp_end then
				case_data.temp_start = os.date( "%Y-%m-%d %H:%M:%S", getTimestampFromDateTimeString( case_data.temp_start ) + 14 * 24 * 60 * 60 )
				case_data.temp_end = os.date( "%Y-%m-%d %H:%M:%S", getTimestampFromDateTimeString( case_data.temp_end ) + 14 * 24 * 60 * 60 )
				CheckDuplicateCases( case_id, position, case_data.temp_start )
			end
		end
	end

	for case_id, date in pairs( NEW_CASES_START_DATE ) do
		if string.find( date, "\t" ) then
			case_id, date = unpack( split( date, "\t" ) )
		end
		if not new_cases_data[ case_id ] then
			case_id = GetCaseIDFromName( case_id )
		end
		date = os.date( "%Y-%m-%d %H:%M:%S", getTimestampFromString( date ) )
		local case_data = new_cases_data[ case_id ]
		if not case_data then
			print( "NEW_CASES_START_DATE: no case ", case_id )
		end
		if case_data.position and case_data.position > 0 then
			CheckDuplicateCases( case_id, case_data.position, date )
		end
		new_cases_data[ case_id ].temp_start = date
	end

	for case_id, date in pairs( NEW_CASES_END_DATE ) do
		if string.find( date, "\t" ) then
			case_id, date = unpack( split( date, "\t" ) )
		end
		if not new_cases_data[ case_id ] then
			case_id = GetCaseIDFromName( case_id )
		end
		local case_data = new_cases_data[ case_id ]
		if not case_data then
			print( "NEW_CASES_END_DATE: no case ", case_id )
		end
		if type( date ) == "number" then
			if date < 1582218140 then
				local duration = date
				date = os.date( "%Y-%m-%d %H:%M:%S", getTimestampFromString( case_data.temp_start ) + duration )
			else
				date = os.date( "%Y-%m-%d %H:%M:%S", date )
			end
		else
			date = os.date( "%Y-%m-%d %H:%M:%S", getTimestampFromString( date ) )
		end
		case_data.temp_end = date
	end

	for n, case_ids in pairs( CASE_BATTLES ) do
		for i, case_id in pairs( case_ids ) do
			if not new_cases_data[ case_id ] then
				case_id = GetCaseIDFromName( case_id )
			end
			local versus_case_id = case_ids[ i == 1 and 2 or 1 ]
			if not new_cases_data[ versus_case_id ] then
				versus_case_id = GetCaseIDFromName( versus_case_id )
			end
			new_cases_data[ case_id ].position = CASE_GROUP_TO_POSITION[ "CaseBattle-" .. i ]
			new_cases_data[ case_id ].versus = versus_case_id
			new_cases_data[ case_id ].temp_start_count = 2500
		end
	end

	-- local new_cases_info = { 
	-- 	active_cases = new_cases_data,
	-- 	cases_menu = NEW_CASES_MENU,
	-- }

	-- new_cases_info = toJSON( new_cases_info, true ):sub( 2, -2 )

	-- local file = fileCreate( "cases_info/" .. os.date( "%Y%m%d_%H%M%S" ) .. ".json" )
	-- fileWrite( file, new_cases_info--[[:sub( 4, -4 )]] )
	-- fileClose( file )
	
	NEW_CASES_LIST = { }
	-- for i, case_id in pairs( NEW_CASES_MENU ) do
	-- 	local case_data = new_cases_data[ case_id ]
	-- 	table.insert( NEW_CASES_LIST, case_data )
	-- end
	for case_id, case_data in pairs( new_cases_data ) do
		table.insert( NEW_CASES_LIST, case_data )
	end

	local file = fileCreate( "cases_info/" .. os.date( "%Y%m%d_%H%M%S" ) .. ".json" )
	fileWrite( file, toJSON( NEW_CASES_LIST, true ) )
	fileClose( file )

	if callback_fn then
		callback_fn( )
	end
end

function UpdateDataInCommonDB( )
	-- TODO: сделать обновление только измененных данных

	CommonDB:exec( "TRUNCATE f4_cases" )

	local COLUMNS = {
		{ Field = "id",					Type = "varchar(128)",			Null = "NO",    Key = "PRI",	},
		{ Field = "name",				Type = "varchar(128)",			Null = "YES",					},
		{ Field = "cost",				Type = "float",					Null = "YES",					},
		{ Field = "position",			Type = "tinyint",				Null = "YES",					},
		{ Field = "temp_start",			Type = "datetime",				Null = "YES",					},
		{ Field = "temp_end",			Type = "datetime",				Null = "YES",					},
		{ Field = "temp_start_count", 	Type = "int(11) unsigned",		Null = "YES",					},
		{ Field = "is_hit", 			Type = "boolean",				Null = "YES",					},--boolean = tinyshort
		{ Field = "is_new", 			Type = "boolean",				Null = "YES",					},--Поэтому у нас будут результаты в виде 1 или 0 
		{ Field = "versus", 		    Type = "varchar(128)",			Null = "YES",					},
        { Field = "items",				Type = "json",					Null = "YES",	Key = "",		},
	}
	
	local COLUMNS_REVERSE = { }
	for i, v in pairs( COLUMNS ) do
		COLUMNS_REVERSE[ v.Field ] = v
	end

	for i, case_info in pairs( NEW_CASES_LIST ) do
		local insert_query_keys_table = { }
		local insert_query_values_table = { }
		for k, v in pairs( case_info ) do
			local col_info = COLUMNS_REVERSE[ k ] or { }
			if col_info.Type == "json" and type( v ) == "table" then
				v = toJSON( v or { }, true ) or "[[]]"
			end
			table.insert( insert_query_keys_table, dbPrepareString( DB, "`??`", k ) )
			table.insert( insert_query_values_table, dbPrepareString( DB, "?", v ) )
		end

		CommonDB:exec(
			"REPLACE INTO f4_cases (" .. table.concat( insert_query_keys_table, "," )  .. ")"
			.. " VALUES (" .. table.concat( insert_query_values_table, "," ) .. ")"
		)
	end

	print( "Cases info succesfully updated" )

	-- На случай, если забыл убрать подгрузку данных из бэкапа (тогда надо заюзать бекап до этого момента)
	if LOAD_FROM_BACKUP then
		local file = fileExists( "last_cases" ) and fileOpen( "last_cases" )
		if file then
			local data = fileRead( file, fileGetSize( file ) )
			fileClose( file )

			if not table.compare( NEW_CASES_START_DATE, fromJSON( data ) ) then
				Debug( "Ты точно хотел подгрузить данные из бэкапа?", 1 )
			end
		end

		local file = fileCreate( "last_cases" )
		fileWrite( file, toJSON( NEW_CASES_START_DATE, true ) )
		fileClose( file )
	end
end