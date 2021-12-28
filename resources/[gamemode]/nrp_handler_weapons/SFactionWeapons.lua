-- { WeaponID, Ammo, Level }

FACTION_DUTY_WEAPONS = {
	[F_MEDIC] = {
		{10, 1, 1},
	},

	[F_ARMY] = {
		{30, 500, 1},
		{23, 1, 5},
	},

	[F_POLICE_PPS_NSK] = {
		{23, 999, 1},
		{30, 500, 1},
	},

	[F_GOVERNMENT_NSK] = {
		{22, 90, 3, 5},
		{29, 90, 3, 5},
	},

	[F_FSIN] = {
		{ 22, 90, 1  },
		{ 23, 999, 1 },
		{ 30, 500, 1 },
	};
}
FACTION_DUTY_WEAPONS[ F_POLICE_DPS_NSK ] = FACTION_DUTY_WEAPONS[ F_POLICE_PPS_NSK ]
FACTION_DUTY_WEAPONS[ F_POLICE_PPS_GORKI ] = FACTION_DUTY_WEAPONS[ F_POLICE_PPS_NSK ]
FACTION_DUTY_WEAPONS[ F_POLICE_DPS_GORKI ] = FACTION_DUTY_WEAPONS[ F_POLICE_PPS_NSK ]
FACTION_DUTY_WEAPONS[ F_POLICE_PPS_MSK ] = FACTION_DUTY_WEAPONS[ F_POLICE_PPS_NSK ]
FACTION_DUTY_WEAPONS[ F_POLICE_DPS_MSK ] = FACTION_DUTY_WEAPONS[ F_POLICE_PPS_NSK ]
FACTION_DUTY_WEAPONS[ F_GOVERNMENT_GORKI ] = FACTION_DUTY_WEAPONS[ F_GOVERNMENT_NSK ]
FACTION_DUTY_WEAPONS[ F_GOVERNMENT_MSK ] = FACTION_DUTY_WEAPONS[ F_GOVERNMENT_NSK ]
FACTION_DUTY_WEAPONS[ F_MEDIC_MSK ] = FACTION_DUTY_WEAPONS[ F_MEDIC ]

FACTION_DUTY_ARMOR = {
	[ F_ARMY ] = true;
	[ F_POLICE_PPS_NSK ] = true;
	[ F_POLICE_DPS_NSK ] = true;
	[ F_POLICE_PPS_GORKI ] = true;
	[ F_POLICE_DPS_GORKI ] = true;
	[ F_FSIN ] = true;
	[ F_GOVERNMENT_NSK ] = 3;
	[ F_GOVERNMENT_GORKI ] = 3;
	[ F_GOVERNMENT_MSK ] = 3;
	[ F_POLICE_PPS_MSK ] = true;
	[ F_POLICE_DPS_MSK ] = true;
}

PLAYER_ARMORS = { }

function GiveFactionWeapons()
	local iFaction = source:GetFaction()
	local faction_level = source:GetFactionLevel()
	local pWeapons = FACTION_DUTY_WEAPONS[iFaction]
	if pWeapons then
		for k,v in pairs(pWeapons) do
			if faction_level >= v[3] and ( not v[4] or faction_level <= v[4] ) then
				GiveWeapon( source, v[1], v[2], false, true, "СЛУЖЕБНОЕ" )
			end
		end
	end
	local duty_armor = FACTION_DUTY_ARMOR[ iFaction ]
	if duty_armor and ( type( duty_armor ) ~= "number" or faction_level >= duty_armor ) then
		if not PLAYER_ARMORS[ source ] then
			PLAYER_ARMORS[ source ] = source.armor
			addEventHandler( "onPlayerPreLogout", source, TakeFactionWeapons )
		end
		source.armor = 100
	end
end
addEvent("OnPlayerFactionDutyStart", true)
addEventHandler("OnPlayerFactionDutyStart", root, GiveFactionWeapons)

addEvent("OnPlayerFactionDutyWeaponReturn", true)
addEventHandler("OnPlayerFactionDutyWeaponReturn", root, GiveFactionWeapons )

function TakeFactionWeapons()
	if eventName ~= "onPlayerPreLogout" then
		removeEventHandler( "onPlayerPreLogout", source, TakeFactionWeapons )
		TakeAllWeapons( source, true )
	else
		TakeAllWeapons( source, true )
	end
	source.armor = PLAYER_ARMORS[ source ] or 0
	PLAYER_ARMORS[ source ] = nil
end
addEvent("OnPlayerFactionDutyEnd", true)
addEventHandler("OnPlayerFactionDutyEnd", root, TakeFactionWeapons)