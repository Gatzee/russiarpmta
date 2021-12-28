local CONST_PHONE_IMG_NAMES = { }

for i, wallpaper in pairs( CONST_WALLPAPER ) do
	CONST_PHONE_IMG_NAMES[ wallpaper.img ] = wallpaper.name
end

REGISTERED_CASE_ITEMS.phone_img = {
	rewardPlayer_func = function( player, params )
		player:GivePhoneWallpaper( params.id )
	end;

	checkHasItem_func = function( player, params )
		return player:HasPhoneWallpaper( params.id )
	end;

	isExchangeAvailable_func = function( player, params )
		return player:HasPhoneWallpaper( params.id )
	end;

	uiCreateItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, id, params.id, bg ):center( )
	end;
	
	uiCreateRewardItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 110, 300, 180, id, params.id, bg ):center_x( )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = CONST_PHONE_IMG_NAMES[ params.id ];
			reward_title = "Обои на телефон - " .. CONST_PHONE_IMG_NAMES[ params.id ];
			description = "Обои на телефон.\nСтановится доступен\nв магазине телефона"
		}
	end;

	uiGetContentTextureRolling = function( id, params )
		return id, params.id, 300, 180
	end;

	uiDrawItemInRolling = function( pos_x, pos_y, texture, size_x, size_y, alpha, id, params )
		dxDrawImage( pos_x - math.floor( size_x / 2 ), pos_y - math.floor( size_y / 2 ), size_x, size_y, texture, 0, 0, 0, tocolor( 255, 255, 255, alpha ), true )
	end;
}