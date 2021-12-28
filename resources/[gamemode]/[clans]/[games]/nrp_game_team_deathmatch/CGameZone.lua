local GAME_ZONE = 
{
	position = Vector3{ x = -875.980, y = -1441, z = 13.529 },
	size = Vector3{ x = 183.386, y = 345, z = 27.210 },
}

ELEMENTS = { }

function CreateGameZone( )
	ELEMENTS.game_zone_col = ColShape.Cuboid( GAME_ZONE.position, GAME_ZONE.size )
	addEventHandler("onClientColShapeLeave", ELEMENTS.game_zone_col, OnGameZoneLeave_handler)
	addEventHandler("onClientColShapeHit", ELEMENTS.game_zone_col, OnGameZoneEnter_handler)
end

function DestroyGameZone( )
	DestroyTableElements( ELEMENTS )
end

function OnGameZoneLeave_handler( element, dim )
    if element ~= localPlayer then return end

    localPlayer:ShowError( "Вы покинули территорию боя!" )

    ELEMENTS.hp_timer = setTimer( function( )
        if localPlayer.health == 0 or localPlayer:isDead( ) then
            sourceTimer:destroy( )
            return
        end
        localPlayer.health = localPlayer.health - 10
        if localPlayer.health == 0 then
            triggerServerEvent( "onPlayerWastedOutGameZone", localPlayer )
        end
        localPlayer:ShowError( "Вернитесь на территорию боя!" )
    end, 1000, 0 )
end

function OnGameZoneEnter_handler( element, dim )
    if element ~= localPlayer then return end

    if isTimer( ELEMENTS.hp_timer ) then
        ELEMENTS.hp_timer:destroy( )
    end
end

function CreateLobbyZones( )
	ELEMENTS.lobbyzones = {
		cols = { },
		markers = { },
	}
	for i, positions in pairs( SPAWN_POSITIONS ) do
		local position = Vector3( positions[ 1 ] )
		ELEMENTS.lobbyzones.cols[ i ] = createColSphere( position, 16 )

		addEventHandler( "onClientColShapeLeave", ELEMENTS.lobbyzones.cols[ i ], OnLobbyZoneLeave_handler )
	end
	addEventHandler( "onClientRender", root, RenderLobbyZones )
end

function DestroyLobbyZones( )
	DestroyTableElements( ELEMENTS.lobbyzones )
	removeEventHandler( "onClientRender", root, RenderLobbyZones )
end

function OnLobbyZoneLeave_handler( element, dim )
	if element == localPlayer then
		localPlayer:Teleport( source.position:AddRandomRange( 5 ) )
	end
end

function RenderLobbyZones( )
	for i, positions in pairs( SPAWN_POSITIONS ) do
		local position = Vector3( positions[ 1 ] )
		-- dxDrawCircle3D( cnf.x, cnf.y, cnf.z, 4.5, 64, tocolor(255,0,0,150), 3 )
		-- dxDrawCircle3D( cnf.x, cnf.y, cnf.z - 0.95, 4.5, 64, COLOR_WHITE, 6 )
		for i = 1, 3 do
			dxDrawCircle3D( position.x, position.y, position.z - 0.5 + (i - 2) * 0.2, 16, 64, 0x96FF0000, 3 )
		end
    end
end

function dxDrawCircle3D( x, y, z, radius, segments, color, width )
	local segAngle = 360 / segments
	local fX, fY, tX, tY
	for i = 1, segments do 
		fX = x + math.cos( math.rad( segAngle * i ) ) * radius; 
		fY = y + math.sin( math.rad( segAngle * i ) ) * radius; 
		tX = x + math.cos( math.rad( segAngle * ( i + 1 ) ) ) * radius; 
		tY = y + math.sin( math.rad( segAngle * ( i + 1 ) ) ) * radius;
		dxDrawLine3D( fX, fY, z, tX, tY, z, color, width )
	end 
end