REGISTERED_ITEMS.car_slot = {
	available_params = 
	{
		count = { required = true, desc = "Количество" },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 120, 120 },
	},
	
	Give = function( player, params )
		local bought_slots = player:GetPermanentData( "car_slots" ) or 0
		bought_slots = bought_slots + ( params.count or 1 )
		player:SetPermanentData( "car_slots", bought_slots )
	end;

	GetAnalyticsData = function( player, params )
		local cost = 0
		for i = 1, ( params.count or 1 ) do
			cost = cost + CalculateSlotCost( player:GetPermanentData( "car_slots" ) - i )
		end
		return {
			cost = cost,
		}
	end;

    uiCreateItem = function( id, params, bg, sx, sy )
    	local csx, csy = GetBetterRewardContentSize( id, sx, sy )
        local img = ibCreateContentImage( 0, 0, csx, csy, "other", "slot_vehicle", bg ):center( )
        ibCreateLabel( csx/2, csy*0.8, 0, 0,  params.count .. " шт", img )
			:ibBatchData( { font = ibFonts.bold_18, align_x = "center", align_y = "center" } )
		return img
	end;

    uiCreateRewardItem = function( id, params, bg )
        local img = ibCreateContentImage( 0, 0, 120, 120, "other", "slot_vehicle", bg ):center( )
        ibCreateLabel( 0, 238, 0, 0, params.count .. " шт", bg )
			:ibBatchData( { font = ibFonts.bold_34, align_x = "center", align_y = "top" })
			:center_x( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Слот для транспорта";
			description = "Увеличивает\nвместимость гаража"
		}
	end;
}

function CalculateSlotCost( have_slots )
	local price = 50
	if have_slots >= 4 then
		price = 600
	elseif have_slots > 0 and have_slots < 3 then
		price = ( have_slots + 1 ) * 50
	elseif have_slots == 3 then
		price = 300
	end
	return price
end