function onResourceStart_handler( )
    CommonDB:createTable( "special_offers_sold_count", 
        {
            { Field = "class"       , Type = "varchar(128)"     , Null = "NO", Key = "PRI" ,               };
            { Field = "model"       , Type = "varchar(128)"     , Null = "NO", Key = "PRI" ,               };
            { Field = "start_date"  , Type = "int(11) unsigned" , Null = "NO", Key = "PRI" ,               };
            { Field = "finish_date" , Type = "int(11) unsigned" , Null = "NO", Key = ""    ,               };
            { Field = "count"       , Type = "int(11) unsigned" , Null = "NO", Key = ""    , Default = "1" };
        } 
	)
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function ClearExpiredSpecialOffers( )
	CommonDB:exec( "DELETE FROM special_offers_sold_count WHERE finish_date > 0 AND finish_date <= UNIX_TIMESTAMP( NOW() )" )
end
ClearExpiredSpecialOffers( )
setTimer( ClearExpiredSpecialOffers, MS24H, 1 )

function onPlayerPurchaseSpecialOfferRequest_handler( offer_id, offer_name, segment, ... )
	local player = client
	if not player then return end

	local params = OFFERS_TABS.special.array[ offer_id ]
	if not params or params.name ~= offer_name then
		player:ErrorWindow( "Данное предложение больше недоступно" )
		return
	end

	local conf = OFFERS_TABS.special[ params.class ]
	if not conf then
		player:ErrorWindow( "Не найден тип элемента" )
		return
	end

	local args = { ... }
	local id = params.model

	local sendAnalytics = function ( analytics_data )
		analytics_data = analytics_data or { }

		for i, v in pairs( conf.analytics_conf or { } ) do
			analytics_data[ i ] = v
		end

		analytics_data.model = analytics_data.model or id
		analytics_data.is_limited = not not params.limit_count
		analytics_data.segment = segment or GetAmountSegment( params.cost or 0 )

		triggerEvent( "onSpecialOfferPurchase", player, analytics_data )
	end

	if params.limit_count then
		CommonDB:queryAsync( function( query, pl )
			if not isElement( pl ) then
				dbFree( query )
				return
			end

			local query_result = query:poll( 0 )
			local data = ( query_result or { } )[ 1 ] or { }
			local count = data.count or 0

			if count < params.limit_count then
				local result, analytics_data = conf:fn_call( id, params, pl, unpack( args ) )
				if result then
					sendAnalytics( analytics_data )

					count = count + 1

					CommonDB:exec( [[
						INSERT INTO special_offers_sold_count ( class, model, start_date, finish_date ) VALUES ( ?, ?, ?, ? )
							ON DUPLICATE KEY UPDATE count = count + 1;
					]], params.class, id, params.start_date, params.finish_date or 0 )
				end
			else
				pl:ErrorWindow( "Данное предложение больше недоступно" )
			end

			triggerClientEvent( pl, "onClientUpdateSpecialOfferCount", resourceRoot, offer_id, count )

		end, { player }, "SELECT count FROM special_offers_sold_count WHERE class = ? AND model = ? AND start_date = ? AND finish_date = ? LIMIT 1", params.class, id, params.start_date, params.finish_date or 0 )
	else
		-- try buy and send analytics if it was bought
		local result, analytics_data = conf:fn_call( id, params, player, unpack( args ) )
		if result then
			sendAnalytics( analytics_data )
		end
	end
end
addEvent( "onPlayerPurchaseSpecialOfferRequest", true )
addEventHandler( "onPlayerPurchaseSpecialOfferRequest", root, onPlayerPurchaseSpecialOfferRequest_handler )

function onOfferedVehiclePurchaseCallback_handler( vehicle, data )
	if isElement( vehicle ) and isElement( data.player ) then
		if IsSpecialVehicle( vehicle.model ) then
			triggerEvent( "OnSpecialVehicleBought", vehicle )
		else
			vehicle.locked = true
			vehicle.engineState = true
			vehicle.position = data.player.position

			data.player:GiveFreeEvacuation( vehicle:GetID() )
			
			removePedFromVehicle( data.player )
			warpPedIntoVehicle( data.player, vehicle )
		end

		triggerEvent( "onPlayerBuyVehicle", data.player, vehicle, data.cost or 0, false )
	end
end
addEvent( "onOfferedVehiclePurchaseCallback", true)
addEventHandler( "onOfferedVehiclePurchaseCallback", resourceRoot, onOfferedVehiclePurchaseCallback_handler )