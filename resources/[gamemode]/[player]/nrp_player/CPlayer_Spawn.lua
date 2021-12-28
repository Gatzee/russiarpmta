local DEATH_TIMER
local DEATH_COUNTER

local x, y = guiGetScreenSize()
local TEXT_SCALE = x / 1600 * 2
local TEXT_FONT = "default-bold"
local TEXT_COLOR = 0xffffffff

function ShowDeathCountdown_handler( time )
    -- Очистка
    if isTimer( DEATH_TIMER ) then killTimer( DEATH_TIMER ) end
    removeEventHandler( "onClientRender", root, RenderDeathText )

    if not time then return end
    DEATH_COUNTER = time
    -- Таймер
    DEATH_TIMER = Timer( 
        function() 
            DEATH_COUNTER = DEATH_COUNTER - 1
            if DEATH_COUNTER <= 0 then
                killTimer( DEATH_TIMER )
                triggerServerEvent( "OnPlayerHospitalRespawnRequest", localPlayer )
            end
        end,
        1000, 0
    )
    addEventHandler( "onClientRender", root, RenderDeathText, false, "low-100" )
end
addEvent( "ShowDeathCountdown", true )
addEventHandler( "ShowDeathCountdown", root, ShowDeathCountdown_handler )

function RenderDeathText( )
    local text = DEATH_COUNTER > 0 and "Возрождение через: " .. DEATH_COUNTER .. " сек." or  "Возрождение..."

    -- dxDrawRectangle( 0, 0, x, y, 0x99000000 )
    dxDrawText( text, x / 2, 50, x / 2, 50, TEXT_COLOR, TEXT_SCALE, TEXT_FONT, "center", "center", false, false, false, true )
end

HUD_COMPONENTS_DISABLED = {
	"ammo",
	"armour",
	"breath",
	"clock",
	"health",
	"money",
	"vehicle_name",
	"weapon",
	"radio",
    "wanted",
    "area_name",
}
HUD_COMPONENTS_ENABLED =
{
	"crosshair",
	--"radar",
}
function onClientPlayerSpawn_handler()
    ShowDeathCountdown_handler( )
end
addEventHandler( "onClientPlayerSpawn", localPlayer, onClientPlayerSpawn_handler )

function onPlayerVerifyReadyToSpawn_handler( )
    setTimer( triggerServerEvent, 1000, 1, "onPlayerVerifyReadyToSpawn_Callback", resourceRoot )
end
addEvent( "onPlayerVerifyReadyToSpawn", true )
addEventHandler( "onPlayerVerifyReadyToSpawn", root, onPlayerVerifyReadyToSpawn_handler )

local SPAWN_POSITION, SPAWN_TICK
function CheckGroundPosition( )
	local groundZ = getGroundPosition( SPAWN_POSITION.x, SPAWN_POSITION.y, SPAWN_POSITION.z + 1 )
    if groundZ ~= 0 or getTickCount( ) - SPAWN_TICK >= 10000 then
		removeEventHandler( "onClientRender", root, CheckGroundPosition )
        groundZ = groundZ ~= 0 and groundZ or getGroundPosition( SPAWN_POSITION.x, SPAWN_POSITION.y, SPAWN_POSITION.z + 2 )
        if groundZ ~= 0 and localPlayer.interior == 0 then
            SPAWN_POSITION.z = groundZ + 1
        end

        setTimer( function( )
            local zero = Vector3( 0, 0, 0 )
            if getDistanceBetweenPoints3D( SPAWN_POSITION, zero ) > 50 and getDistanceBetweenPoints3D( localPlayer.position, zero ) < 30 then
                local spawn_pos = { SPAWN_POSITION.x, SPAWN_POSITION.y, SPAWN_POSITION.z }
                local pos = { localPlayer.position.x, localPlayer.position.y, localPlayer.position.z, localPlayer.interior, localPlayer.dimension }
                triggerServerEvent( "onPlayerSpawnFailed", resourceRoot, spawn_pos, pos, localPlayer.frozen )
            end
        end, 3000, 1 )
    end
    localPlayer.position = SPAWN_POSITION
end

function onClientPlayerNRPSpawn_handler( spawn_mode, position )
    SPAWN_TICK = getTickCount( )
    SPAWN_POSITION = position and Vector3( position ) or localPlayer.position
    addEventHandler( "onClientRender", root, CheckGroundPosition )

    if position and getDistanceBetweenPoints2D( localPlayer.position, SPAWN_POSITION ) > 10 then
        local spawn_pos = { SPAWN_POSITION.x, SPAWN_POSITION.y, SPAWN_POSITION.z }
        local pos = { localPlayer.position.x, localPlayer.position.y, localPlayer.position.z, localPlayer.interior, localPlayer.dimension }
        triggerServerEvent( "onPlayerSpawnFailed", resourceRoot, spawn_pos, pos, localPlayer.frozen, true )
    end

    -- Скрытие и показ элементов интерфейса
	for i, v in pairs( HUD_COMPONENTS_DISABLED ) do
		setPlayerHudComponentVisible( v, false )
	end
	for i, v in pairs( HUD_COMPONENTS_ENABLED ) do
		setPlayerHudComponentVisible( v, true )
    end
end
addEvent( "onClientPlayerNRPSpawn", true )
addEventHandler( "onClientPlayerNRPSpawn", root, onClientPlayerNRPSpawn_handler )

function onSettingsChange_handler( changed, values )
	if changed.init_spawn_in_home then
		triggerServerEvent( "onPlayerChangeInitSpawn", localPlayer, values.init_spawn_in_home )
    end
end
addEvent( "onSettingsChange", true )
addEventHandler( "onSettingsChange", root, onSettingsChange_handler )

-- Костылефикс бага с невидимыми трупами

local PLAYERS_PEDS = { }
local PLAYERS_TO_HANDLE = { }

function CreateDeadPlayerPed( )
    if source == localPlayer then return end

    if eventName == "onClientPlayerWasted" and source:isStreamedIn( ) then
        addEventHandler( "onClientElementStreamOut", source, CreateDeadPlayerPed )
        PLAYERS_TO_HANDLE[ source ] = true
    else
        if PLAYERS_TO_HANDLE[ source ] then
            removeEventHandler( "onClientElementStreamOut", source, CreateDeadPlayerPed )
            PLAYERS_TO_HANDLE[ source ] = nil
        end

        source.alpha = 0
        if PLAYERS_PEDS[ source ] then
            PLAYERS_PEDS[ source ]:destroy( )
        end
        local ped = createPed( source.model, source.position, source.rotation.z )
        ped:kill( )
        ped.interior = source.interior
        ped.dimension = source.dimension
        ped.frozen = true
        ped:setCollidableWith( source, false )
        addEventHandler( "onClientElementStreamIn", ped, FixPedPositionZ )

        PLAYERS_PEDS[ source ] = ped
    end
end
addEventHandler( "onClientPlayerWasted", root, CreateDeadPlayerPed )

function FixPedPositionZ( )
    local x, y, z = getElementPosition( source )
    z = getGroundPosition( x, y, z + 0.5 )
    if z and z > 0 then
        source.position = Vector3( x, y, z + 1 )
    end
end

function RemoveDeadPlayerPed( )
    if PLAYERS_TO_HANDLE[ source ] then
        removeEventHandler( "onClientElementStreamOut", source, CreateDeadPlayerPed )
        PLAYERS_TO_HANDLE[ source ] = nil

    elseif PLAYERS_PEDS[ source ] then
        source.alpha = 255
        PLAYERS_PEDS[ source ]:destroy( )
        PLAYERS_PEDS[ source ] = nil
    end
end
addEventHandler( "onClientPlayerSpawn", root, RemoveDeadPlayerPed )
addEventHandler( "onClientPlayerQuit", root, RemoveDeadPlayerPed )