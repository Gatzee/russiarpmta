Extend( "ShSkin" )

REGISTERED_ITEMS.skin = {
	Give = function( player, params )
		player:GiveSkin( params.model )
	end;

	checkHasItem = function( player, params )
		return player:HasSkin( params.model )
	end;

	isExchangeAvailable = function( player, params )
		return player:HasSkin( params.model ) or SKINS_GENDERS[ params.model ] ~= player:GetGender( )
	end;

	uiCreateItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, id, params.model, bg ):center( )
	end;
	
	uiCreateRewardItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 40, 300, 280, id, params.model, bg ):center_x( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Скин " .. SKINS_NAMES[ params.model ];
			description = "Комплект одежды.\nСтановится доступен\nв гардеробе"
		}
	end;
}