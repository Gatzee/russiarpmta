REGISTERED_ITEMS.case = {
	rewardPlayer_func = function( player, params )
		player:GiveCase( params.id, params.count or 1 )
	end;
	
	uiCreateItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 130, 90, "case", params.id, bg ):ibData( "disabled", true ):center( 0, -10 )
	end;

	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( -18, -25, 360, 280, "case", params.id, bg )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = params.name or "Кейс";
		}
	end;
}