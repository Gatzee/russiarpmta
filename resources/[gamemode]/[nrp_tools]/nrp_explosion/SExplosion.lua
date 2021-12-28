loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

function DetectCreateProjectile_handler( projectile_type )
	for i, v in pairs( GetPlayersInGame( ) ) do
		if v:GetAccessLevel() > 0 then
			v:outputChat( string.format( "[Античит] %s (%s) (%s) создал проджектайл (%s)", client:GetNickName(), client:GetID(), getPlayerSerial( client ), projectile_type ), 255, 0, 0, true )
		end
	end

	WriteLog( "projectile_ac", "[Античит] %s создал проджектайл (%s)", client, projectile_type )
	client:kick( "Вы используете модифицированную версию клиента" )
end
addEvent( "DetectCreateProjectile", true )
addEventHandler( "DetectCreateProjectile", resourceRoot, DetectCreateProjectile_handler )

function DetectCreateExplosion_handler( distance )
	for i, v in pairs( GetPlayersInGame( ) ) do
		if v:GetAccessLevel() > 0 then
			v:outputChat( string.format( "[Античит] %s (%s) (%s) создал взрыв на расстоянии (%s) от своей позиции", client:GetNickName(), client:GetID(), getPlayerSerial( client ), distance ), 255, 0, 0, true )
		end
	end

	WriteLog( "explosion_ac", "[Античит] %s создал взрыв на расстоянии (%s) от своей позиции", client, distance )
	client:kick( "Вы используете модифицированную версию клиента" )
end
addEvent( "DetectCreateExplosion", true )
addEventHandler( "DetectCreateExplosion", resourceRoot, DetectCreateExplosion_handler )