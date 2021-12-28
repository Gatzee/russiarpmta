Import( "ShPhone" )

local CONST_PHONE_IMG_NAMES = { }

for i, wallpaper in pairs( CONST_WALLPAPER ) do
	CONST_PHONE_IMG_NAMES[ wallpaper.img ] = wallpaper.name
end

REGISTERED_ITEMS.phone_img = {
	available_params = 
	{
		id = { required = true, desc = "ID" },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 300, 180 },
	},

	IsValid = function( self, item )
		local params = item.params or item

		if not CONST_PHONE_IMG_NAMES[ params.id ] then
			return false, "Обои с указанным ID не найдены"
		end

		return true
	end,

	Give = function( player, params )
		player:GivePhoneWallpaper( params.id )
	end;

	checkHasItem = function( player, params )
		return player:HasPhoneWallpaper( params.id )
	end;

	isExchangeAvailable = function( player, params )
		return player:HasPhoneWallpaper( params.id )
	end;

	uiCreateItem = function( id, params, bg, sx, sy )
		local csx, csy = GetBetterRewardContentSize( id, sx, sy )
		return ibCreateContentImage( 0, 0, csx, csy, id, params.id, bg ):center( )
	end;
	
	uiCreateRewardItem = function( id, params, bg )
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