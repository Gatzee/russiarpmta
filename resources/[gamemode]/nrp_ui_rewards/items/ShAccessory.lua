Extend( "ShAccessories" )

REGISTERED_ITEMS.accessory = {
	uiCreateItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, id, FixAccessoryID( params.id ), bg ):center( )
	end;
	
	uiCreateRewardItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 300, 180, id, FixAccessoryID( params.id ), bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = CONST_ACCESSORIES_INFO[ FixAccessoryID( params.id ) ].name;
			description = "Аксессуар.\nСтановится доступен\nв гардеробе"
		}
	end;
}

-- Некоторые идентификаторы не совпадают с указанными в доке
local DOC_ID_TO_DEV_ID = {
	[ "m2_asce25" ] = "nightmare",
	[ "m2_asce13" ] = "scarf_deserted_r",
	[ "m2_asce26" ] = "pumpkin",
	[ "m2_asce14" ] = "scarf_deserted_y",
	[ "m2_asce09" ] = "pendant_1",
	[ "m2_acse36" ] = "panam_hat",
	[ "m2_acse39" ] = "wood_black_glasses",
	[ "m2_asce24" ] = "scythe",
	[ "m2_acse34" ] = "deer_mask",
	[ "m2_acse38" ] = "diamond_hope",
	[ "m2_acse35" ] = "new_year_scarf",
	[ "m2_asce23" ] = "scarf_deserted_w",
	[ "m2_acse33" ] = "new_year_hat",
	[ "m2_acse32" ] = "beard_santa",
	[ "m2_asce05" ] = "scarf_deserted_g",
	[ "m2_asce04" ] = "cylinder_hat",
	[ "m2_asce27" ] = "hell_wings",
	[ "m2_asce10" ] = "mask_mick",
	[ "m2_asce15" ] = "mask_scorp",
	[ "m2_acse37" ] = "diamond_bag",
	[ "m3_acse12" ] = "m2_asce12",
	[ "m2_asce16" ] = "helmet_avg",
	[ "m2_asce18" ] = "helmet_black",
}

function FixAccessoryID( id )
	return DOC_ID_TO_DEV_ID[ id ] or id
end