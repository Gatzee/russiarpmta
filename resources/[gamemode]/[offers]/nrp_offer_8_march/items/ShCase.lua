REGISTERED_ITEMS.case = {
	Give = function( player, params )
		player:GiveCase( params.id, params.count or 1 )
	end;

	uiCreateItem = function( id, params, bg, fonts )
		local img = ibCreateContentImage( 0, 0, 130, 90, "case", params.id, bg ):center( -2, -10 )

		if ( params.count or 1 ) > 1 then
			ibCreateLabel( 0, 0, 0, 0, "X".. params.count, bg )
				:ibBatchData( { font = ibFonts.oxaniumbold_14, align_x = "center", align_y = "center" } )
				:center( 0, 35 )
		end
		
		return img
	end;

	uiCreateBigItem = function( id, params, bg, fonts )
		local img = ibCreateContentImage( 0, 0, 372, 252, "case", params.id, bg ):center( )

		if ( params.count or 1 ) > 1 then
			img:center( 0, -10 )
			ibCreateLabel( 0, 210, 0, 0, "X".. params.count, bg )
				:ibBatchData( { font = ibFonts.oxaniumbold_30, align_x = "center", align_y = "top" })
				:center_x( )
		end

		return img
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Кейс " .. ( params.name or "" );
			-- description = "Позволяет бесплатно\nэвакуировать транспорт"
		}
	end;
}