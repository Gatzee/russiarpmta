loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )

SLOT_MACHINE_GAME_POSITION  = Vector3( -52.953, -491.180, 913.988 )
SLOT_MACHINE_LEAVE_POSITION = Vector3( -52.953, -491.180, 913.988 )

BETS = {
	[ CASINO_THREE_AXE ] =
	{
		100,
		500,
		1000,
		2000,
		4000,
		5000,
		10000,
		20000,
		25000,

	},
	[ CASINO_MOSCOW ] =
	{
		500,
		2500,
		5000,
		10000,
		20000,
		25000,
	},
}

enum "eSlotMachineItems" {
	"SLOT_MACHNIE_ITEM_1",
	"SLOT_MACHNIE_ITEM_2",
	"SLOT_MACHNIE_ITEM_3",
	"SLOT_MACHNIE_ITEM_4",
	"SLOT_MACHNIE_ITEM_5",
	"SLOT_MACHNIE_ITEM_6",
	"SLOT_MACHNIE_ITEM_7",
	"SLOT_MACHNIE_ITEM_8",
}

REGISTERED_ITEMS = {
	{ id = SLOT_MACHNIE_ITEM_1 },
	{ id = SLOT_MACHNIE_ITEM_2 },
	{ id = SLOT_MACHNIE_ITEM_3 },
	{ id = SLOT_MACHNIE_ITEM_4 },
	{ id = SLOT_MACHNIE_ITEM_5 },
	{ id = SLOT_MACHNIE_ITEM_6 },
	{ id = SLOT_MACHNIE_ITEM_7 },
	{ id = SLOT_MACHNIE_ITEM_8 },
}

COMBINATIONS = 
{
	[ CASINO_GAME_SLOT_MACHINE_GOLD_SKULL ] =
	{
		[ SLOT_MACHNIE_ITEM_1 ] = { [ 2 ] = 5, [ 3 ] = 25, [ 4 ] = 200, [ 5 ] = 2000 },
		[ SLOT_MACHNIE_ITEM_2 ] = { [ 2 ] = 3, [ 3 ] = 20, [ 4 ] = 100, [ 5 ] = 1000 },
		[ SLOT_MACHNIE_ITEM_3 ] = { [ 2 ] = 2, [ 3 ] = 15, [ 4 ] = 50,  [ 5 ] = 500  },
		[ SLOT_MACHNIE_ITEM_4 ] = { [ 2 ] = 2, [ 3 ] = 10, [ 4 ] = 25,  [ 5 ] = 250  },
		[ SLOT_MACHNIE_ITEM_5 ] = { [ 2 ] = 2, [ 3 ] = 10, [ 4 ] = 20,  [ 5 ] = 150  },
		[ SLOT_MACHNIE_ITEM_6 ] = { 		   [ 3 ] = 5,  [ 4 ] = 15,  [ 5 ] = 100  },
		[ SLOT_MACHNIE_ITEM_7 ] = { 		   [ 3 ] = 5,  [ 4 ] = 10,  [ 5 ] = 75   },
		[ SLOT_MACHNIE_ITEM_8 ] = { 		   [ 3 ] = 5,  [ 4 ] = 10,  [ 5 ] = 50   },
	},
}

COMBINATIONS[ CASINO_GAME_SLOT_MACHINE_VALHALLA ] = COMBINATIONS[ CASINO_GAME_SLOT_MACHINE_GOLD_SKULL ]
COMBINATIONS[ CASINO_GAME_SLOT_MACHINE_CHICAGO ] = COMBINATIONS[ CASINO_GAME_SLOT_MACHINE_GOLD_SKULL ]

function CalculateCombinationsCoefficient( game_id, combinations )
	local combos = {  }
	local counter = 1
	for i, v in pairs( combinations ) do 
		if i + 1 <= #combinations and combinations[ i + 1 ].id == v.id then
			counter = counter + 1
		else 
			if counter ~= 1 then
				table.insert( combos, { id = v.id, count = counter } )
				counter = 1
			end
		end
	end
	
	table.sort( combos, function( a, b )
		return a.count > b.count or ( a.count == b.count and a.id < b.id )
	end )
	
	local combination = combos[ 1 ] or { id = SLOT_MACHNIE_ITEM_1, count = 0 }
	local win_combination = COMBINATIONS[ game_id ][ combination.id ][ combination.count ] or false

	return win_combination, combination
end

