local CONST_BOX_NAMES = {
	[1] = "Пакет игрока начинающий";
	[2] = "Пакет игрока стартовый";
}

REGISTERED_ITEMS.box = {
	rewardPlayer_func = function( player, params )
		for id, param in pairs( params.items ) do
			REGISTERED_ITEMS[ id ].rewardPlayer_func( player, param )
		end
	end;

	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		return ibCreateContentImage( 15, -8, 90, 90, "other", "box" .. params.number, bg ):center()
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 15, -8, 300, 240, "other", "box" .. params.number, bg )
	end;

	uiGetDescriptionData_func = function( id, params )
		return {
			title = params.name or CONST_BOX_NAMES[ params.number ];
		}
	end;
}