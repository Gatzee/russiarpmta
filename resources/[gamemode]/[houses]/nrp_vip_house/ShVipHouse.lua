function GetVipHousePlayerIsInside( player )
    local interior = player.interior
    local dimension = player.dimension

    if interior == 0 or dimension < 5000 then
        return false
    end

	dimension = dimension - 5000
	local id = math.floor( dimension / 110 )
	local number = dimension % 110

    local info = VIP_HOUSES_LIST[ number ]
    if id ~= 0 or not info or not info.apartments_class 
    or APARTMENTS_CLASSES[ info.apartments_class ].interior ~= interior then
        return false
    end

    return number
end

function IsPlayerInsideVilla( player, villa_hid )
	if not isElement( player ) then return end

	if villa_hid and VIP_HOUSES_REVERSE[ villa_hid ] then
		local config = VIP_HOUSES_REVERSE[ villa_hid ]
		local villa_pos = config.control_marker_position
		local distance = getDistanceBetweenPoints3D ( player.position.x, player.position.y, player.position.z, villa_pos.x, villa_pos.y, villa_pos.z )
		outputDebugString( "Distance is " .. distance )
		return distance < 40
	else
		return false
	end
end

DISCOUNT_COST_CONVERT = {
	[ 2500000 ] = 1990000,
	[ 4500000 ] = 3490000,
	[ 6000000 ] = 4490000,
	[ 7500000 ] = 5990000,
	[ 9000000 ] = 7490000,
	[ 11500000 ] = 9990000,
	[ 15000000 ] = 11990000,
	[ 20000000 ] = 14000000,
	[ 50000000 ] = 35000000,
}
