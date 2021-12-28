addEvent( "BP:ShowBoostersDiscount", true )
addEventHandler( "BP:ShowBoostersDiscount", root, function( offer_data )
	offer_data.finish_ts = offer_data.start_ts + offer_data.duration
	offer_data.discount = offer_data.boosters[ 3 ].discount
	localPlayer:setData( "bp_boosters_discount", offer_data, false )
end )

addEvent( "BP:UpdateUI", true )
addEventHandler( "BP:UpdateUI", resourceRoot, function( data )
	if data.booster_end_ts then
		local offer_data = localPlayer:getData( "bp_boosters_discount" )
		if offer_data then
			localPlayer:setData( "bp_boosters_discount", false, false )
		end
	end
end, false, "high" )