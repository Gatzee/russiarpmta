loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "Globals" )
Extend( "ShVehicle" )

CASE_CONVERSIONS = {
	[ "vinyl" ] = {
		[ VINYL_CASE_1_A ] = 1,
		[ VINYL_CASE_2_A ] = 2,
		[ VINYL_CASE_3_A ] = 3,
	
		[ VINYL_CASE_1_B ] = 1,
		[ VINYL_CASE_2_B ] = 2,
		[ VINYL_CASE_3_B ] = 3,
	
		[ VINYL_CASE_1_C ] = 1,
		[ VINYL_CASE_2_C ] = 2,
		[ VINYL_CASE_3_C ] = 3,
	
		[ VINYL_CASE_1_D ] = 1,
		[ VINYL_CASE_2_D ] = 2,
		[ VINYL_CASE_3_D ] = 3,
	
		[ VINYL_CASE_1_S ] = 1,
		[ VINYL_CASE_2_S ] = 2,
		[ VINYL_CASE_3_S ] = 3,

		[ VINYL_CASE_1_M ] = 1,
		[ VINYL_CASE_2_M ] = 2,
		[ VINYL_CASE_3_M ] = 3,
	},
}

CASE_CLASSES = {
	[ VINYL_CASE_1_A ] = 1,
	[ VINYL_CASE_2_A ] = 1,
	[ VINYL_CASE_3_A ] = 1,

	[ VINYL_CASE_1_B ] = 2,
	[ VINYL_CASE_2_B ] = 2,
	[ VINYL_CASE_3_B ] = 2,

	[ VINYL_CASE_1_C ] = 3,
	[ VINYL_CASE_2_C ] = 3,
	[ VINYL_CASE_3_C ] = 3,

	[ VINYL_CASE_1_D ] = 4,
	[ VINYL_CASE_2_D ] = 4,
	[ VINYL_CASE_3_D ] = 4,

	[ VINYL_CASE_1_S ] = 5,
	[ VINYL_CASE_2_S ] = 5,
	[ VINYL_CASE_3_S ] = 5,

	[ VINYL_CASE_1_M ] = 6,
	[ VINYL_CASE_2_M ] = 6,
	[ VINYL_CASE_3_M ] = 6,
}

CASE_TEXTS = {
	[ "vinyl" ] = {
		[ 1 ] = "Содержатся стильные винилы. Покажи свой вкус стиля!",
		[ 2 ] = "Содержатся легендарные винилы. Выдели свою легендарность!",
		[ 3 ] = "Содержатся королевские винилы. Ощути их все!",
	}
}

CASES = {
	[ "vinyl" ] = {
		[ 1 ] = "Стильный",
		[ 2 ] = "Легендарный",
		[ 3 ] = "Королевский",
	}
}

function FixTableData( part )
	local part_new = { }
	for i, v in pairs( part ) do
		part_new[ tonumber( i ) or i ] = tonumber( v ) or v
	end
	return part_new
end