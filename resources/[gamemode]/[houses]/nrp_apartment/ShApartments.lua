function GetApartmentPlayerIsInside( player )
    local interior = player.interior
    local dimension = player.dimension

    if interior == 0 or dimension < 5000 then
        return false
    end

	dimension = dimension - 5000
	local id = math.floor( dimension / 100 )
	local number = dimension % 100

    local info = APARTMENTS_LIST[ id ]
	if not info or info.max_count < number or APARTMENTS_CLASSES[ info.class ].interior ~= interior then
        return false
    end

    return id, number
end