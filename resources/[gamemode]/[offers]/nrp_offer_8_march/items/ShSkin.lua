Import( "ShSkin" )

REGISTERED_ITEMS.skin = {
	Give = function( player, params )
		player:GiveSkin( params.id )
	end;

	-- checkHasItem = function( player, params )
	-- 	return player:HasSkin( params.model )
	-- end;

	-- isExchangeAvailable = function( player, params )
	-- 	return player:HasSkin( params.model ) or SKINS_GENDERS[ params.model ] ~= player:GetGender( )
	-- end;

	uiCreateItem = function( id, params, bg, fonts )
		return ibCreateContentImage( 0, 0, 90, 90, id, params.id, bg ):center( )
	end;
	
	uiCreateBigItem = function( id, params, bg, fonts )
		return ibCreateContentImage( 0, 20, 300, 280, id, params.id, bg ):center_x( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Скин " .. SKINS_NAMES[ params.id ];
			description = "Комплект одежды.\nСтановится доступен\nв гардеробе"
		}
	end;
}