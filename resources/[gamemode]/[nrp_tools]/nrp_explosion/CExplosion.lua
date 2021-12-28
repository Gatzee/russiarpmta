loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CPlayer" )
Extend( "Globals" )

ALLOWED_QUESTS = {
    shmatko_2 = true,
}

addEventHandler( "onClientExplosion", root, function( x, y, z )
	if localPlayer.dimension > 0 then return end
	cancelEvent( )
	
	local distance = (localPlayer.position - Vector3(x, y, z)).length
	if source == localPlayer and distance > 20 then
		triggerServerEvent( "DetectCreateExplosion", resourceRoot, distance )
	end
end )

addEventHandler( "onClientProjectileCreation", root, function( creator )
	if localPlayer.dimension > 0 then return end
	local projectile_type = getProjectileType( source )
	setElementPosition( source, 0, 0, 500 )
	destroyElement( source )

	if creator == localPlayer then
		triggerServerEvent( "DetectCreateProjectile", resourceRoot, projectile_type )
	end
end )