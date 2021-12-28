local CONST_BOX_NAMES = {
	[1] = "Пакет игрока начинающий";
	[2] = "Пакет игрока стартовый";
	[3] = "Аптечка + канистра";
	[4] = "Рем. комплект + канистра + аптечка";
}

REGISTERED_ITEMS.box = {
	uiCreateItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, "other", "box" .. params.number, bg ):center( )
	end;

	uiCreateRewardItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 20, 300, 240, "other", "box" .. params.number, bg ):center_x( )

		local area_bg = ibCreateArea( 0, 260, 96, 96, bg )
		local counter = 0
		for id, param in pairs( params.items ) do
			local min_bg = ibCreateArea( counter * 96, 0, 96, 96, area_bg )
			REGISTERED_ITEMS[ id ].uiCreateItem( id, param, min_bg, fonts )

			local description_data = REGISTERED_ITEMS[ id ].uiGetDescriptionData( id, param )
			if description_data then
				min_bg:ibDeepSet( "disabled", true ):ibData( "disabled", false )
				min_bg:ibAttachTooltip( description_data.title )
			end

			counter = counter + 1
		end

		area_bg:ibData( "sx", counter * 96 ):center_x( )
	end;

	uiGetDescriptionData = function( id, params )
		return {
			title = params.name or CONST_BOX_NAMES[ params.number ] or "Набор";
		}
	end;
}