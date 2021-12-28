local CASES_NAMES =
{
	"Базовый кейс",
	"Кейс Счастливчик",
	"Фартовый кейс",
}

REGISTERED_CASE_ITEMS.tuning_case = {
	-- takeReward_client_func = function( item, params )
	-- 	CasesGoBack( )
	-- 	onOverlayNotificationRequest_handler( OVERLAY_APPLY_VINYL, { cost = item.cost, received_from_case = true } )
	-- end;

	-- rewardPlayer_func = function( player, params, args )
	-- 	player:GiveVinyl( { 
	-- 		[ P_PRICE_TYPE ] = "hard",
	-- 		[ P_IMAGE ]      = params.id,
	-- 		[ P_CLASS ]      = args.tier,
	-- 		[ P_NAME ]       = VINYL_NAMES[ params.id ],
	-- 		[ P_PRICE ]      = args.cost,
	-- 	} )
    --     player:ShowInfo( "Винил успешно получен!\nТы можешь применить его в тюнинг-ателье" )
	-- end;

	-- uiCreateItem_func = function( id, params, bg, fonts )
	-- 	ibCreateContentImage( 0, 0, 90, 90, id, params.id, bg ):center( )
	-- end;
	
	-- uiCreateRewardItem_func = function( id, params, bg, fonts )
	-- 	ibCreateContentImage( 0, 0, 300, 300, id, params.id, bg ):center( )
	-- end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = CASES_NAMES[ params.id ] .. " (класс " .. params.class .. ")" ;
			description = "Кейс с деталями для тюнинга машины";
		}
	end;

	-- uiGetContentTextureRolling = function( id, params )
	-- 	return id, params.id, 300, 160
	-- end;

	-- uiDrawItemInRolling = function( pos_x, pos_y, texture, size_x, size_y, alpha, id, params )
	-- 	dxDrawImage( pos_x - math.floor( size_x / 2 ), pos_y - math.floor( size_y / 2 ), size_x, size_y, texture, 0, 0, 0, tocolor( 255, 255, 255, alpha ), true )
	-- end;
}