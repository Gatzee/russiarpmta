loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "SQuest" )
Extend( "SActionTasksUtils" )

addEventHandler( "onResourceStart", resourceRoot, function( )
	SQuest( QUEST_DATA )
end )

function RestoreWeapon( player, quest_weapons )
	local data = player:getData( "save_pre_quest_data" )
	if data then
		player:TakeAllWeapons( true )
		
		for k, v in ipairs( data.weapon_data ) do
			player:GiveWeapon( v.weapon_id, v.weapon_ammo, true, false, "weapon_restore_possible_exposure" )
		end

		player.armor = data.armor
		player:setData( "save_pre_quest_data", false, false )				
	end
end

function GiveQuestWeapon( player, weapon_data )
	local player_permanent_weapons = player:GetPermanentWeapons()
	local player_weapons_by_slot = { }

	for k,v in pairs( player_permanent_weapons ) do
		local weapon_slot_id = getSlotFromWeapon( v[1] )
		player_weapons_by_slot[ weapon_slot_id ] = v
	end

	local player_weapon_data = {}
	for k, v in ipairs( weapon_data ) do
		local target_slot_id = getSlotFromWeapon( v.weapon_id )
		local weapon_id = player_weapons_by_slot[ target_slot_id ] and player_weapons_by_slot[ target_slot_id ][ 1 ]
		if weapon_id and weapon_id ~= 0 then
			local weapon_ammo = player_weapons_by_slot[ target_slot_id ] and player_weapons_by_slot[ target_slot_id ][ 2 ]
			player:TakeWeapon( weapon_id, weapon_ammo )

			table.insert( player_weapon_data, {
				weapon_id = weapon_id,
				weapon_ammo = weapon_ammo,
			} )
		end
		player:GiveWeapon( v.weapon_id, v.ammo, true, true, "quest_possible_exposure" )
	end

	player:setData( "save_pre_quest_data", {
		weapon_data = player_weapon_data,
		armor = player.armor
	}, false )
	player.armor = 100
end