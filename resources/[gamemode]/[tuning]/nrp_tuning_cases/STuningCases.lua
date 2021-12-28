Extend("SPlayer")
Extend("SVehicle")
Extend("ShVehicleConfig")
Extend("SDB")

local tuning_cases = { }

addEventHandler( "onResourceStart", resourceRoot, function ( )
	CommonDB:createTable( "nrp_tuning_internal_cases", {
		{ Field = "id",                 Type = "int(11) unsigned",  Null = "NO",	Key = "PRI",    Default = NULL,     Extra = "auto_increment"   					};
		{ Field = "name",		        Type = "char(128)",		    Null = "NO",	Key = "",       Default = ""                                   					};
		{ Field = "en_name",		    Type = "char(128)",		    Null = "NO",	Key = "",       Default = ""                                   					};
		{ Field = "description",		Type = "text",				Null = "NO",	Key = "",                                  					};
		{ Field = "prices",		        Type = "text",				Null = "NO",    Key = "",	    options = { json = true, autofix = true }  	};
		{ Field = "items",		        Type = "text",				Null = "NO",	Key = "", 		options = { json = true, autofix = true } 	};
	} )

	local function callback( query )
		if not query then return end

		local data = dbPoll( query, 0 )
		dbFree( query )

		data = data or { }

		for _, case in pairs( data ) do
			case.prices = fromJSON( case.prices ) or { }
			case.items = fromJSON( case.items ) or { }
		end

		tuning_cases = data
	end

	CommonDB:queryAsync( callback, { }, "SELECT * FROM nrp_tuning_internal_cases" )
end )

addEvent( "onPlayerReadyToPlay", true )
addEventHandler( "onPlayerReadyToPlay", root, function ( )
	local tuning_cases = { }
	local old_tuning_cases = source:GetPermanentData( "cases_tuning" ) or { }

	table.insert( tuning_cases, { { [ INTERNAL_PART_TYPE_R ] = 0 } } ) -- 1 case id -> class A -> type R = 0

	for case_id, data in pairs( old_tuning_cases ) do
		if type( data ) == "number" and type( case_id ) == "number" then -- convert old cases to new
			tuning_cases[ 1 ][ 1 ][ INTERNAL_PART_TYPE_R ] = tuning_cases[ 1 ][ 1 ][ INTERNAL_PART_TYPE_R ] + data

		elseif type( data ) == "table" then -- fix table
			tuning_cases[ case_id ] = { }

			for class, data2 in pairs( data ) do
				-- fix class id
				class = tonumber( class ) or class
				tuning_cases[ case_id ][ class ] = { }

				for subtype, value in pairs( data2 ) do
					-- fix subtype id
					subtype = tonumber( subtype ) or subtype
					tuning_cases[ case_id ][ class ][ subtype ] = value
				end
			end
		end
	end

	if next( tuning_cases ) > 0 then
		source:SetPermanentData( "cases_tuning", tuning_cases )
		source:SetPrivateData( "cases_tuning", tuning_cases )
	end
end )

function PlayerRequestRegisteredTuningCases_handler(  )
	if not client or not client.vehicle then return end
	local tier = client.vehicle:GetTier( )

	triggerClientEvent( client, "ReceiveRegisteredTuningCases", resourceRoot, tuning_cases, tier )

	-- АНАЛИТИКА / Показ окна с кейсами / Для просмотра конверсии в покупку
	triggerEvent( "onTuningCasesWindowShow", client )
end
addEvent( "PlayerRequestRegisteredTuningCases", true )
addEventHandler( "PlayerRequestRegisteredTuningCases", root, PlayerRequestRegisteredTuningCases_handler )

function PlayerWantBuyTuningCase_handler( case_id, count, subtype )
	if not isElement( client ) or not client.vehicle or not tonumber( count ) then return end

	local tier = client.vehicle:GetTier( )
	local case_cost, is_soft = getCaseCost( case_id, tier )
	if case_cost then
		case_cost = exports.nrp_tuning_shop:ApplyDiscount( case_cost, client )

		if ( is_soft and client:TakeMoney( case_cost * count, "tuning", "tuning_case" ) )
		or ( not is_soft and client:TakeDonate( case_cost * count, "tuning", "tuning_case" ) ) then
			client:GiveTuningCase( case_id, tier, subtype, count )

			-- log
			WriteLog( "cases_tuning", "[BUY] %s / CASE_ID[ %s ]:COUNT[ %s ]:COST[ %s / %s ]", client, case_id, count, case_cost, case_cost * count )

			-- analytics / buy tuning case
			triggerEvent( "onTuningCasesPurchaseCase",
				client, case_id, tuning_cases[ case_id ].en_name,
				VEHICLE_CLASSES_NAMES[ tier ], INTERNAL_PARTS_NAMES_TYPES[ subtype ],
				client.vehicle, case_cost, count, is_soft )
		else
			client:EnoughMoneyOffer( "Tuning cases purchase", case_cost * count, "PlayerWantBuyTuningCase", client, case_id, count )
		end
	end
end
addEvent( "PlayerWantBuyTuningCase", true )
addEventHandler( "PlayerWantBuyTuningCase", root, PlayerWantBuyTuningCase_handler )

function PlayerWantOpenTuningCase_handler( case_id, subtype )
	if not client or not client.vehicle then return end

	local tier = client.vehicle:GetTier( )
	local id = getRandomPartIDFromCase( case_id, subtype, tier )
	local part = getTuningPartByID( id, tier )

	if id and part and client:TakeTuningCase( case_id, tier, subtype ) then
		client:GiveTuningPart( tier, id )

		triggerClientEvent( client, "ShowTuningCasesReward", resourceRoot, part, "tuning" )
		triggerEvent( "onPlayerAddTuningPartInInventory", client, id, tier ) -- for update inventory in tuning shop

		-- log
		WriteLog( "cases_tuning", "[TAKE_ITEM] %s / ITEM[ %s ]", client, case_id )

		-- analytics / open tuning case & take item
		triggerEvent( "onTuningCasesOpenCase", client, case_id, tuning_cases[ case_id ].en_name,
			VEHICLE_CLASSES_NAMES[ tier ], INTERNAL_PARTS_NAMES_TYPES[ subtype ] )

		triggerEvent( "onTuningCasesTakeItem", client, id, part.name, INTERNAL_PARTS_NAMES_TYPES[ subtype ], part.category,
			tuning_cases[ case_id ].en_name, VEHICLE_CLASSES_NAMES[ tier ], INTERNAL_PARTS_NAMES_TYPES[ subtype ] )
	end
end
addEvent( "PlayerWantOpenTuningCase", true )
addEventHandler( "PlayerWantOpenTuningCase", resourceRoot, PlayerWantOpenTuningCase_handler )

function getCaseCost( case_id, tier )
	if tuning_cases[ case_id ] then
		local tCost =  tuning_cases[ case_id ].prices[ VEHICLE_CLASSES_NAMES[ tier ] ]
		local cost = tCost.cost
		local is_soft = tCost.currency == "soft" and true or false

		return cost, is_soft
	end
end

function getRandomPartIDFromCase( case_id, subtype, tier )
	local case = tuning_cases[ case_id ] or { }
	local items = case.items or { }
	local itemsForClass = items[ VEHICLE_CLASSES_NAMES[ tier ] ]
	local total_chance_sum = 0

	if not itemsForClass then return end

	for _, item in pairs( itemsForClass ) do
		total_chance_sum = total_chance_sum + item.chance
	end

	if total_chance_sum <= 0 then return end

	local dot = math.random( ) * total_chance_sum
	local current_sum = 0

	for _, item in pairs( itemsForClass ) do
		local id = item[ INTERNAL_PARTS_NAMES_TYPES[ subtype ] ]

		if current_sum <= dot and dot < ( current_sum + item.chance ) and id then
			return id
		end

		current_sum = current_sum + item.chance
	end
end