loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShVehicleConfig" )
Extend( "ShPhone" )
Extend( "ShPlayer" )
Extend( "ShVehicle" )
Extend( "rewards/_ShItems" )

CONST_CASES_LIST = 
{ 
	["bronze"] = true,
	["silver"] = true,
}

REGISTERED_CASE_ITEMS = { }

local AMOUNT_TO_INDEX = { [3] = 1, [6] = 2, [9] = 3, [12] = 4 }
local DISCOUNT_BY_AMOUNT = { [3] = 0.85, [6] = 0.8, [9] = 0.7, [12] = 0.65 }

local CONST_CASE_COST_BY_AMOUNT = 
{
	[99] = { 252, 474, 626, 772 },
    [149] = { 373, 717, 939, 1162 },
    [159] = { 404, 767, 1001, 1240 },
    [179] = { 454, 858, 1127, 1396 },
    [199] = { 507, 955, 1253, 1552 },
    [249] = { 636, 1194, 1568, 1942 },
    [299] = { 762, 1435, 1883, 2332 },
    [349] = { 889, 1675, 2198, 2722 },
    [499] = { 1272, 2395, 3143, 3892 },
    [599] = { 1525, 2875, 3773, 4672 },
    [649] = { 1654, 3115, 4088, 5062 },
    [699] = { 1782, 3355, 4404, 5452 },
    [999] = { 2547, 4795, 6294, 7792 },
    [1499] = { 3823, 7197, 9444, 11692 },
}

function GetCaseDiscountCostForAmount( base_cost, amount )
	if CONST_CASE_COST_BY_AMOUNT[ base_cost ] then
		return CONST_CASE_COST_BY_AMOUNT[ base_cost ][ AMOUNT_TO_INDEX[ amount ] ]
	else
		return math.floor( base_cost * amount * DISCOUNT_BY_AMOUNT[ amount ] )
	end
end