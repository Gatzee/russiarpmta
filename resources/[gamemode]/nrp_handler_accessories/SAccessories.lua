loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SPlayer")
Extend( "ShAccessories" )
Extend( "ShVehicleConfig" ) -- TODO: remove after "double Extend cheker"

function removeSubscriptionAccessories( player )
	local need_update = false
	local accessories = player:GetAccessories( )

	for _, list in pairs( accessories ) do
		for slot, data in pairs( list ) do
			local info = CONST_ACCESSORIES_INFO[data.id]
			if not info or info.premium then
				list[ slot ] = nil
				need_update = true
			end
		end
	end

	if need_update then
		player:SetAccessories( accessories )
	end
end

addEventHandler( "onPlayerCompleteLogin", root, function( )
	local accessories = source:GetPermanentData( "accessories" )
	
	if accessories and next( accessories ) then
		source:setData( "accessories", accessories )

		if not source:IsPremiumActive() then
			removeSubscriptionAccessories( source )
			return
		end
	end
end )