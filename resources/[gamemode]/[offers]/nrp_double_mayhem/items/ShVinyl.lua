loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShVinyls" )
Extend( "ShVehicleConfig" )

REGISTERED_ITEMS.vinyl = {
	rewardPlayer_func = function( player, params, cost, data )
		player:GiveVinyl( { 
			[ P_IMAGE ]      = params.id,
			[ P_CLASS ]      = data and isElement( data.vehicle ) and data.vehicle:GetTier( ) or 1,
			[ P_NAME ]       = VINYL_NAMES[ params.id ],
			[ P_PRICE ]      = math.floor( cost / 1000 ),
			[ P_PRICE_TYPE ] = "hard",
		} )
        player:ShowInfo( "Винил успешно получен!\nТы можешь применить его в тюнинг-ателье" )
	end;

	uiCreateItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, id, params.id, bg ):ibData( "disabled", true ):center( )
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 11, 36, 300, 160, id, params.id, bg )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Винил " .. VINYL_NAMES[ params.id ];
		}
	end;
}