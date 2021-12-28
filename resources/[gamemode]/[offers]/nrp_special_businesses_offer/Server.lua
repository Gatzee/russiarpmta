loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "ShVehicleConfig" )
Extend( "SVehicle" )

start_date = 0
finish_date = 0
offer_time = 4 * 24 * 60 * 60

function onPlayerCompleteLogin_handler( )
	local timestamp = getRealTimestamp()
	if timestamp < start_date then return end

	local businesses_offer = source:GetPermanentData( "businesses_offer" )
	if businesses_offer and businesses_offer.end_timestamp > start_date then
		source:SetPrivateData( "businesses_offer", businesses_offer )

		if businesses_offer.end_timestamp > timestamp and businesses_offer.segment > 0 and businesses_offer.count > 0 then
			if source:HasFinishedTutorial( ) then
				triggerClientEvent( source, "ShowBusinessesOffer", resourceRoot, GetOfferBusinessesList( ) )
			end
		end
	else
		if timestamp > finish_date then return end
		if not IsExistFreeBusinesses( ) then return end

		local business = exports.nrp_businesses:GetOwnedBusinesses( source )

		businesses_offer = {
			segment = 0,
			end_timestamp = timestamp + offer_time,
			count = 2 - #business,
		}

		if #business == 1 then
			businesses_offer.segment = 1
		elseif #business == 0 then
			if source:GetMoney( ) >= 10000000 then
				businesses_offer.segment = 2
			
			elseif source:GetDonate( ) >= 1000 then
				businesses_offer.segment = 3
			end
		end

		source:SetPrivateData( "businesses_offer", businesses_offer )
		source:SetPermanentData( "businesses_offer", businesses_offer )

		if businesses_offer.segment > 0 then
			if source:HasFinishedTutorial( ) then
				triggerClientEvent( source, "ShowBusinessesOffer", resourceRoot, GetOfferBusinessesList( ) )
			end
			SendElasticGameEvent( source:GetClientID( ), "businesses_offer", {
				player_group_id = businesses_offer.segment,
			} )
		end
	end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler, true, "high+9999999" )

function IsExistFreeBusinesses( )
	local business_list = exports.nrp_businesses:GetBusinessesList( )
	for i, v in pairs( business_list ) do
        if exports.nrp_businesses:GetBusinessData( v.id, "userid" ) == 0 then
            return true
        end
	end

	return false
end

function GetOfferBusinessesList( )
	local offer_businesses = { }
	local business_list = exports.nrp_businesses:GetBusinessesList( )

	for i, data in pairs( business_list ) do
		if exports.nrp_businesses:GetBusinessData( data.id, "userid" ) == 0 then
			local business_type, business_number = string.match( data.id, "([_%a]+)_(%d+)" )
			local uniq = exports.nrp_businesses:GetBusinessConfig( data.id, "uniq" )
			local ignore_id = false

			if not business_type then
				business_type = data.id
				business_number = 1
				ignore_id = true
			end

			if business_type and not uniq then
				if not offer_businesses[ business_type ] then
					offer_businesses[ business_type ] = {
						name = exports.nrp_businesses:GetBusinessConfig( data.id, "name" );
						cost = exports.nrp_businesses:GetBusinessConfig( data.id, "cost" );
						icon = exports.nrp_businesses:GetBusinessConfig( data.id, "icon" );
						ignore_id = ignore_id,
						list = { };
					}
				end

				offer_businesses[ business_type ].list[ business_number ] = { x = data.x, y = data.y, z = data.z };
			else
				offer_businesses[ data.id ] = {
					name = exports.nrp_businesses:GetBusinessConfig( data.id, "name" );
					cost = exports.nrp_businesses:GetBusinessConfig( data.id, "cost" );
					icon = exports.nrp_businesses:GetBusinessConfig( data.id, "icon" );
					gps_position = { x = data.x, y = data.y, z = data.z };
				}
			end
		end
	end

	return offer_businesses
end

function RequestBusinessesOfferList_handler( )
	if not client then return end

	triggerClientEvent( "OnBusinessesOfferSetList", resourceRoot, GetOfferBusinessesList( ) )
end
addEvent( "RequestBusinessesOfferList", true )
addEventHandler( "RequestBusinessesOfferList", resourceRoot, RequestBusinessesOfferList_handler )

function OnPlayerWantBuyBusinesses_handler( business_id )
	if not client then return end

	local businesses_offer = client:GetPermanentData( "businesses_offer" )
	if not businesses_offer then return end

	if businesses_offer.count <= 0 then return end

	if exports.nrp_businesses:PlayerWantBuyBusiness( client, business_id, 0.25 ) then
		local cost = exports.nrp_businesses:GetBusinessConfig( business_id, "cost" )

		local business_type, business_number = string.match( business_id, "(%a+)_(%d+)" )

		SendElasticGameEvent( client:GetClientID( ), "business_offer_purchase", {
			player_group_id = businesses_offer.segment,
			business_type = business_type or business_id,
			business_id = business_number or business_id,
			cost = math.floor( cost * 0.75 ),
			currency = "soft",
		} )

		businesses_offer.count = businesses_offer.count - 1

		if businesses_offer.count == 0 then
			-- TODO Остановка акции
		end

		-- TODO ? Акция закончилась, а игрок купил только 1 из 2-х возможных бизнесов. Закрываем акцию или нет?

		client:SetPrivateData( "businesses_offer", businesses_offer )
		client:SetPermanentData( "businesses_offer", businesses_offer )
	end
end
addEvent( "OnPlayerWantBuyBusinesses", true )
addEventHandler( "OnPlayerWantBuyBusinesses", resourceRoot, OnPlayerWantBuyBusinesses_handler )

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
	if key ~= "business_discount" then return end

	if not value or next( value ) == nil then 
		start_date = 0
		finish_date = 0
	else
		start_date = getTimestampFromString( value[1].start_date )
		finish_date = getTimestampFromString( value[1].finish_date )
		--переводим сразу час в секунду
		offer_time = value[1].offer_time * 60 * 60
	end
end )
--После запуска ресурса обновляем все даты
triggerEvent( "onSpecialDataRequest", getResourceRootElement( ), "business_discount" )

if SERVER_NUMBER > 100 then
	addCommandHandler( "resetbusinessoffer", function( player ) 
		player:SetPermanentData( "businesses_offer", nil )
		player:SetPrivateData( "businesses_offer", nil )
		player:ShowInfo( "Business offer reset success!" )
	end )

	addCommandHandler( "setbusinessoffer", function( player ) 
		local businesses_offer = {
			segment = 1,
			end_timestamp = getRealTimestamp( ) + 24 * 60 * 60,
			count = 2,
		}

		player:SetPrivateData( "businesses_offer", businesses_offer )
		player:SetPermanentData( "businesses_offer", businesses_offer )
	end )
end