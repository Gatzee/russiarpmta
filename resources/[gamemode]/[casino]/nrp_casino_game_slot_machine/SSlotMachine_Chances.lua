
ITEMS_CHANCES = 
{
	[ CASINO_GAME_SLOT_MACHINE_GOLD_SKULL ] =
	{
		{ id = SLOT_MACHNIE_ITEM_1, chance = 0.07 },
		{ id = SLOT_MACHNIE_ITEM_2, chance = 0.09 },
		{ id = SLOT_MACHNIE_ITEM_3, chance = 0.1  },
		{ id = SLOT_MACHNIE_ITEM_4, chance = 0.12 },
		{ id = SLOT_MACHNIE_ITEM_5, chance = 0.13 },
		{ id = SLOT_MACHNIE_ITEM_6, chance = 0.15 },
		{ id = SLOT_MACHNIE_ITEM_7, chance = 0.16 },
		{ id = SLOT_MACHNIE_ITEM_8, chance = 0.18 },
	},
}

ITEMS_CHANCES[ CASINO_GAME_SLOT_MACHINE_VALHALLA ] = ITEMS_CHANCES[ CASINO_GAME_SLOT_MACHINE_GOLD_SKULL ]
ITEMS_CHANCES[ CASINO_GAME_SLOT_MACHINE_CHICAGO ] = ITEMS_CHANCES[ CASINO_GAME_SLOT_MACHINE_GOLD_SKULL ]

function GenerateSlotMachineItems( game_id )
    local results = {}
	for i = 1, 5 do 
		table.insert( results, GetRandomItem( ITEMS_CHANCES[ game_id ] ) )
	end
	return results
end

function GetRandomItem( items )
	local total_chance_sum = 0
	for _, item in pairs( items ) do
		total_chance_sum = total_chance_sum + item.chance
	end
	
	if total_chance_sum <= 0 then return end

	local dot = math.random( ) * total_chance_sum
	local current_sum = 0
	
	for i, item in pairs( items ) do
		local item_chance = item.chance

		if current_sum <= dot and dot < ( current_sum + item_chance ) then
			return item
		end

		current_sum = current_sum + item_chance
	end
end