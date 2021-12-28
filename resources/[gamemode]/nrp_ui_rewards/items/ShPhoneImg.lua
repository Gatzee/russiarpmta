Extend( "ShPhone" )

local CONST_PHONE_IMG_NAMES = { }

for i, wallpaper in pairs( CONST_WALLPAPER ) do
	CONST_PHONE_IMG_NAMES[ wallpaper.img ] = wallpaper.name
end

REGISTERED_ITEMS.phone_img = {
	Give = function( player, params )
		player:GivePhoneWallpaper( params.id )
	end;

	checkHasItem = function( player, params )
		return player:HasPhoneWallpaper( params.id )
	end;

	isExchangeAvailable = function( player, params )
		return player:HasPhoneWallpaper( params.id )
	end;

	uiCreateItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, id, params.id, bg ):center( )
	end;
	
	uiCreateRewardItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 110, 300, 180, id, params.id, bg ):center_x( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = CONST_PHONE_IMG_NAMES[ params.id ];
			reward_title = "Обои на телефон - " .. CONST_PHONE_IMG_NAMES[ params.id ];
			description = "Обои на телефон.\nСтановится доступен\nв магазине телефона"
		}
	end;
}