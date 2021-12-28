Import( "ShVinyls" )

REGISTERED_ITEMS.vinyl = {
	Give = function( player, params, data )
		player:GiveVinyl( { 
			[ P_PRICE_TYPE ] = "hard",
			[ P_IMAGE ]      = params.id,
			[ P_CLASS ]      = data and data.vehicle and data.vehicle:GetTier( ) or 1,
			[ P_NAME ]       = VINYL_NAMES[ params.id ],
			[ P_PRICE ]      = params.cost,
		} )
        player:ShowInfo( "Винил успешно получен!\nТы можешь применить его в тюнинг-ателье" )
	end;
	
	uiCreateItem = function( id, params, bg, fonts )
		return ibCreateContentImage( 0, 0, 90, 90, id, params.id, bg ):center( )
	end;

	uiCreateBigItem = function( id, params, bg, fonts )
		return ibCreateContentImage( 0, 0, 300, 300, id, params.id, bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Винил " .. VINYL_NAMES[ params.id ] .. "";
			-- description = "Позволяет бесплатно\nэвакуировать транспорт"
		}
	end;
}