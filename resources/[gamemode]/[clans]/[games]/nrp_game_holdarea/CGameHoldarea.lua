loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "ShUtils" )
Extend( "ib" )

TEAM_ID_BY_CLAN_ID = { }
LAST_RESPAWN = 0
ELEMENTS = { }

function CheckLeaveColshape( player, dimension_matches )
    if player ~= localPlayer then return end

    localPlayer:ShowError( "Вы покинули территорию захвата!" )

    ELEMENTS.hp_timer = setTimer( function( )
        if localPlayer.health == 0 or localPlayer:isDead( ) then
            sourceTimer:destroy( )
            return
        end
        localPlayer.health = localPlayer.health - 10
        if localPlayer.health == 0 then
            triggerServerEvent( "onPlayerWastedOutGameZone", localPlayer )
        end
        localPlayer:ShowError( "Вернитесь на территорию захвата!" )
    end, 1000, 0 )
end

function CheckEnterColshape( player, dimension_matches )
    if player ~= localPlayer then return end

    if isTimer( ELEMENTS.hp_timer ) then
        ELEMENTS.hp_timer:destroy( )
    end
end

function DestroyColshapes( )
    DestroyTableElements( ELEMENTS )
end

function CreateColshapes( )
    DestroyColshapes( )
    local gamezone = HOLDAREA_CONFIG[ 1 ].gamezone
    ELEMENTS.colshape = ColShape.Cuboid( gamezone.position, gamezone.size )
    addEventHandler( "onClientColShapeLeave", ELEMENTS.colshape, CheckLeaveColshape )
    addEventHandler( "onClientColShapeHit", ELEMENTS.colshape, CheckEnterColshape )
end

-- Подготовка к захвату и сам захват
function onHoldareaGamePreparationStart_handler( )
    onHoldareaGameEnd_handler( )

    addEventHandler( "onClientPlayerWasted", localPlayer, OnClientPlayerWasted_handler )
	addEventHandler( "onClientPlayerDamage", localPlayer, OnClientPlayerDamage_handler )
	addEventHandler( "onClientPlayerSpawn", localPlayer, OnClientPlayerSpawn_handler )
end
addEvent( "CEV:OnClientPlayerLobbyJoin", true )
addEventHandler( "CEV:OnClientPlayerLobbyJoin", resourceRoot, onHoldareaGamePreparationStart_handler )

function onHoldareaGameStart_handler( data )
	TEAM_ID_BY_CLAN_ID = data.teams
    CreateColshapes( )

    addEventHandler( "onClientRender", root, RenderHoldAreaBorder )
end
addEvent( "CEV:OnClientGameStarted", true )
addEventHandler( "CEV:OnClientGameStarted", resourceRoot, onHoldareaGameStart_handler )

-- Любое окончание захвата
function onHoldareaGameEnd_handler( )
    DestroyColshapes( )

	removeEventHandler( "onClientPlayerWasted", localPlayer, OnClientPlayerWasted_handler )
	removeEventHandler( "onClientPlayerDamage", localPlayer, OnClientPlayerDamage_handler )
	removeEventHandler( "onClientPlayerSpawn", localPlayer, OnClientPlayerSpawn_handler )
    removeEventHandler( "onClientRender", root, RenderHoldAreaBorder )
    
    ShowHoldareaDeathCountdown_handler( false )
end
addEvent( "CEV:OnClientPlayerLobbyLeave", true )
addEventHandler( "CEV:OnClientPlayerLobbyLeave", root, onHoldareaGameEnd_handler )

function OnClientPlayerSpawn_handler()
	LAST_RESPAWN = getTickCount()
end

function OnClientPlayerDamage_handler()
	if getTickCount() - LAST_RESPAWN <= 5000 then
		cancelEvent()
		return 
	end
end

function OnClientPlayerWasted_handler()
	ShowHoldareaDeathCountdown_handler( 20 )
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

function RenderHoldAreaBorder( )
    local cnf = HOLDAREA_CONFIG[ 1 ]
    -- dxDrawCircle3D( cnf.x, cnf.y, cnf.z, 4.5, 64, tocolor(255,0,0,150), 3 )
    dxDrawCircle3D( cnf.x, cnf.y, cnf.z - 0.95, 4.5, 64, COLOR_WHITE, 6 )
    for i = 1, 3 do
        dxDrawCircle3D( cnf.x, cnf.y, cnf.z - 0.5 + (i - 2) * 0.2, 4.5, 64, 0x96FF0000, 3 )
    end
end