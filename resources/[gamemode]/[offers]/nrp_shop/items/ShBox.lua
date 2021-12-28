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

	uiCreateItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, "other", "box" .. params.number, bg ):center( )
	end;

	uiCreateRewardItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 20, 300, 240, "other", "box" .. params.number, bg ):center_x( )

		local area_bg = ibCreateArea( 0, 260, 96, 96, bg )
		local counter = 0
		for id, param in pairs( params.items ) do
			local min_bg = ibCreateArea( counter * 96, 0, 96, 96, area_bg )
			REGISTERED_ITEMS[ id ].uiCreateItem_func( id, param, min_bg, fonts )

			local description_data = REGISTERED_ITEMS[ id ].uiGetDescriptionData_func( id, param )
			if description_data then
				min_bg:ibDeepSet( "disabled", true ):ibData( "disabled", false )
				min_bg:ibAttachTooltip( description_data.title )
			end

			counter = counter + 1
		end

		area_bg:ibData( "sx", counter * 96 ):center_x( )
	end;

	uiGetDescriptionData_func = function( id, params )
		return {
			title = params.name or CONST_BOX_NAMES[ params.number ] or "Набор";
		}
	end;

	uiCreateTextureRolling = function( id, params )
		return dxCreateTexture( "img/cases/items/big/box_".. params.number ..".png" )
	end;

	uiDrawItemInRolling = function( pos_x, pos_y, texture, size_x, size_y, alpha, id, params )
		size_x, size_y = size_x * 0.8, size_y * 0.8
		dxDrawImage( pos_x - math.floor( size_x / 2 ), pos_y + 5 - math.floor( size_y / 2 ), size_x, size_y, texture, 0, 0, 0, tocolor( 255, 255, 255, alpha ), true )
	end;
}