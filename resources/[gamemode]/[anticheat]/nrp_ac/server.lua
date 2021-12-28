loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "SPlayer" )

local WEAPONS = {
	[ 0 ] = true,
	[ 1 ] = true,
	[ 2 ] = true,
	[ 3 ] = true,
	[ 4 ] = true,
	[ 5 ] = true,
	[ 6 ] = true,
	[ 7 ] = true,
	[ 8 ] = true,
	[ 9 ] = true,
	[ 22 ] = true,
	[ 23 ] = true,
	[ 24 ] = true,
	[ 25 ] = true,
	[ 26 ] = true,
	[ 27 ] = true,
	[ 28 ] = true,
	[ 29 ] = true,
	[ 32 ] = true,
	[ 30 ] = true,
	[ 31 ] = true,
	[ 33 ] = true,
	[ 34 ] = true,
	[ 35 ] = true,
	[ 36 ] = true,
	[ 37 ] = true,
	[ 38 ] = true,
	[ 16 ] = true,
	[ 17 ] = true,
	[ 18 ] = true,
	[ 39 ] = true,
	[ 41 ] = true,
	[ 42 ] = true,
	[ 43 ] = true,
	[ 10 ] = true,
	[ 11 ] = true,
	[ 12 ] = true,
	[ 14 ] = true,
	[ 15 ] = true,
	[ 44 ] = true,
	[ 45 ] = true,
	[ 46 ] = true,
	[ 40 ] = true,
}

function onPlayerWeaponFire_handler( weapon, endX, endY, endZ, hitElement, startX, startY, startZ )
	if source.dimension == 0 and source:GetLevel() < 3 then
		WriteLog( "ac_detect", "[LOW_LEVEL_WEAPON_FIRE] Игрок %s / weapon: %s / currentWeapon: %s / ammo: %s", source, weapon, getPedWeapon( source ), getPedTotalAmmo( source ) )
		source:kick( "[AC #18]")
		return
	end

	if not WEAPONS[ weapon ] or weapon == 26 or ( startX == 0 and startY == 0 and startZ == 0 ) then
		WriteLog( "ac_detect", "[WEAPON_FIRE] Игрок %s / weapon: %s / currentWeapon: %s / ammo: %s", source, weapon, getPedWeapon( source ), getPedTotalAmmo( source ) )
		WriteLog( "ac_detect", "[WEAPON_FIRE_MORE] Игрок %s / weapon: %s / hitElement: %s / startX: %s / startY: %s / startZ: %s / endX: %s / endY: %s / endZ: %s", source, weapon, hitElement, startX, startY, startZ, endX, endY, endZ )
		--addBan( _, _, source.serial, "[AC #17]" )
		source:kick( "[AC #17]")
	end
end
addEventHandler( "onPlayerWeaponFire", root, onPlayerWeaponFire_handler )

function DetectPlayerAC( ac_number, no_ban )
	local reason = "[AC #".. ac_number .."]"
	WriteLog( "ac_detect", reason .." Игрок %s", source )

	if not no_ban then
		triggerEvent( "SetBanSerialByServer", root, source.serial, 0, reason )
	end

	source:kick( reason )
end
addEvent( "DetectPlayerAC" )
addEventHandler( "DetectPlayerAC", root, DetectPlayerAC )