REGISTERED_ITEMS.case = {
	Give = function( player, params )
		player:GiveCase( params.id, params.count or 1 )
	end;

	uiCreateItem = function( id, params, bg, fonts )
		local img = ibCreateContentImage( 0, 0, 130, 90, "case", params.id, bg ):center( 0, -10 )

		if ( params.count or 1 ) > 1 then
			ibCreateLabel( 0, 0, 0, 0, "X".. params.count, bg )
				:ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" } )
				:center( 0, 45 )
		end
		
		return img
	end;

	uiCreateRewardItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 372, 252, "case", params.id, bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = params.name or "Кейс";
			-- description = "Позволяет бесплатно\nэвакуировать транспорт"
		}
	end;
}