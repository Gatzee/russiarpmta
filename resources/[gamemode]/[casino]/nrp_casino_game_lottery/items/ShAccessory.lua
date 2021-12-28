Extend( "ShAccessories" )

REGISTERED_ITEMS.accessory = {
	rewardPlayer_func = function( player, params )
		player:AddOwnedAccessory( params.id )
	end;

	checkHasItem_func = function( player, params )
		return player:GetOwnedAccessories( )[ params.id ]
	end;

	isExchangeAvailable_func = function( player, params )
		return player:GetOwnedAccessories( )[ params.id ]
	end;

	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		local content_img = ibCreateContentImage( 25, 25, 90, 90, id, params.id, bg )
		content_img:ibBatchData( { sx = 80, sy = 80 } )
		return content_img
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 11, 36, 300, 140, id, params.id, bg )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Аксессуар " .. CONST_ACCESSORIES_INFO[ params.id ].name;
			description = "Аксессуар.\nСтановится доступен\nв гардеробе"
		}
	end;
}