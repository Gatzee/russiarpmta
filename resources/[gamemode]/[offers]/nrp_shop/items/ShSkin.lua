REGISTERED_ITEMS.skin = {
	rewardPlayer_func = function( player, params )
		player:GiveSkin( params.model )
	end;

	checkHasItem_func = function( player, params )
		return player:HasSkin( params.model )
	end;

	isExchangeAvailable_func = function( player, params )
		return player:HasSkin( params.model ) or SKINS_GENDERS[ params.model ] ~= player:GetGender( )
	end;

	uiCreateItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, id, params.model, bg ):center( )
	end;
	
	uiCreateRewardItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 40, 300, 280, id, params.model, bg ):center_x( )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Скин " .. SKINS_NAMES[ params.model ];
			description = "Комплект одежды.\nСтановится доступен\nв гардеробе"
		}
	end;

	uiGetContentTextureRolling = function( id, params )
		return id, params.model, 300, 280
	end;

	uiDrawItemInRolling = function( pos_x, pos_y, texture, size_x, size_y, alpha, id, params )
		dxDrawImage( pos_x - math.floor( size_x / 2 ), pos_y - math.floor( size_y / 2 ), size_x, size_y, texture, 0, 0, 0, tocolor( 255, 255, 255, alpha ), true )
	end;
}