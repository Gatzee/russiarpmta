local CASES_NAMES =
{
	"Тюнинг кейс \"Базовый\"",
	"Тюнинг кейс \"Счастливчик\"",
	"Тюнинг кейс \"Фартовый\"",
	"Тюнинг кейс \"Скоростной\" удар",
	"Тюнинг кейс \"Максимальный\"",
}

local VEHICLE_CLASS_TO_TIER = { }
for tier, class in pairs( VEHICLE_CLASSES_NAMES ) do
	VEHICLE_CLASS_TO_TIER[ class ] = tier
end

REGISTERED_ITEMS.tuning_case = {
    rewardPlayer_func = function( player, params, cost, data )
		data = data or { }

		local tier = VEHICLE_CLASS_TO_TIER[ params.class ] or params.tier or ( data and isElement( data.vehicle ) and data.vehicle:GetTier( ) ) or 1
		if tier == 6 then data.subtype = nil end
		player:GiveTuningCase( params.id, tier, params.subtype or data.subtype or INTERNAL_PART_TYPE_R, params.count or 1 )

		player:ShowInfo( "Тюнинг кейс успешно получен!\nТы можешь применить его в тюнинг-ателье" )
	end;

	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		local content_img = ibCreateContentImage( 0, 35, 130, 90, "case", "tuning_" .. params.id, bg )
		content_img:ibBatchData( { sx = 91, sy = 63 } ):center_x()
		return content_img
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( -18, -25, 360, 280, "case", "tuning_" .. params.id, bg )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = CASES_NAMES[ params.id ] or "Тюнинг кейс";
			description = "Кейс с деталями для тюнинга машины";
		}
	end;
}