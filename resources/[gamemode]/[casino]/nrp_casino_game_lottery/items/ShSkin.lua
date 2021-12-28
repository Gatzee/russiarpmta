Extend( "ShSkin" )

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

	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		local content_img = ibCreateContentImage( 28, 36, 90, 90, "skin", params.model, bg ):center(0, -2)
		return content_img
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 14, -38, 300, 280, "skin", params.model, bg )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Скин " .. SKINS_NAMES[ params.model ];
			description = "Комплект одежды.\nСтановится доступен\nв гардеробе",
			img = "img/items/skins/".. params.model ..".png",
		}
	end;
}