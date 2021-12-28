Extend( "ib" )
Extend( "ib/tabPanel" )
Extend( "CPlayer" )
Extend( "CInterior" )
Extend( "rewards/Client" )

local LAST_QUEST_START_LOCATION = 1

ibUseRealFonts( true )

function CreateQuestStarterPed( config, location_id )
	config.radius = 2.5
    config.keypress = "lalt"

    local npc = TeleportPoint( config )
    npc.elements = { }
    npc.marker:setColor( 255, 255, 255, 0 )
    npc.PostJoin = onNPCAction
    npc.PostLeave = onNPCLeave
    npc.location_id = location_id
    npc.ped = createPed( 296, config.x, config.y, config.z, config.rz or 0 )  -- Оригинальный скин(ID: 6723)
    addEventHandler( "onClientPedDamage", npc.ped, cancelEvent )

    npc.ped.frozen = true
    npc.ped.dimension = config.dimension or 0
    npc.ped.interior = config.interior or 0
    npc.ped.rotation = Vector3( 0, 0, config.rz or 0 )

    npc.elements.search_zone = createColSphere( config.x, config.y, config.z, 30 )
    npc.elements.blip = createBlipAttachedTo( npc.marker, 3, 2, 255, 0, 0, 255, 0, 300 )

	return ped
end

function onNPCAction( data )
    if localPlayer:GetLevel( ) < REQUIRED_PLAYER_LEVEL then
        localPlayer:ShowError( "Получи "..REQUIRED_PLAYER_LEVEL.." уровень, чтобы приступить к опасным заданиям" )
        return
    end

    LAST_QUEST_START_LOCATION = data.location_id
    ShowUI_Quests( true, { zone = data.elements.search_zone } )
end

function onNPCLeave( )
    HideQuestsUI( true )
end

function GetLastQuestStartLocation( )
    return LAST_QUEST_START_LOCATION
end

addEventHandler("onClientResourceStart", resourceRoot, function( )
	for k,v in pairs( QUEST_START_LOCATIONS ) do
		CreateQuestStarterPed( v.ped_conf, k )
	end
end)

-- CLIENT QUEST HANDLER

local COOP_QUEST_DATA = { }
local COOP_QUEST_PLAYERS = { }
local COOP_QUEST_TEAM_DATA = { { }, { } }
local COOP_QUEST_ELEMENTS = { }
local COOP_QUEST_CONFIG
local PLAYER_BLIPS = { }
COOP_QUEST_CLIENT_ELEMENTS = { }
COOP_QUEST_STAGE_ELEMENTS = { }

function GetCoopQuestConfig( )
    return COOP_QUEST_CONFIG
end

function GetCoopQuestData( key )
    return COOP_QUEST_DATA[ key ]
end

function GetCoopQuestTeamData( key )
    return COOP_QUEST_TEAM_DATA[ team ][ key ]
end

function GetCoopQuestElement( key )
    return COOP_QUEST_ELEMENTS[ key ]
end

function GetCoopQuestTeamID( )
    return GetCoopQuestData( "team_id" ) or 1
end

function SetTeamData( key, value )
    triggerServerEvent( "OnPlayerRequestChangeTeamData", resourceRoot, key, value )
end

function SetCoopQuestData( key, value )
    triggerServerEvent( "OnPlayerRequestChangeCoopQuestData", resourceRoot, key, value )
end

function ToggleCoopQuestTeamBlips( state )
    for k,v in pairs( PLAYER_BLIPS[ GetCoopQuestTeamID() ] ) do
        v:setData( "is_hide", not state, false )
    end
end

function ToggleCoopQuestOpponentBlips( state )
    for k,v in pairs( PLAYER_BLIPS[ GetCoopQuestTeamID() == 1 and 2 or 1 ] ) do
        v:setData( "is_hide", not state, false )
    end
end

function OnCoopQuestStarted( data )
    if data then
        ShowUI_Quests( false )

        for k,v in pairs( data.quest_data or { } ) do
            COOP_QUEST_DATA[ k ] = v
        end

        for team, data in pairs( data.team_data or { } ) do
            for k,v in pairs( data or { } ) do
                COOP_QUEST_TEAM_DATA[ team ][ k ] = v
            end
        end

        for k,v in pairs( data.elements or { } ) do
            COOP_QUEST_ELEMENTS[ k ] = v
        end

        COOP_QUEST_CONFIG = COOP_QUESTS_CONFIG[ data.quest_data.quest_type ]

        local hud_data = 
        {
            title = COOP_QUEST_CONFIG.name,
            task_name = COOP_QUEST_CONFIG.name,
        }

        localPlayer:setData( "current_daily_coop_quest", hud_data, false )

        addEventHandler( "onClientPlayerWasted", localPlayer, OnClientPlayerWasted )


        local my_team_id = GetCoopQuestTeamID( )
        for team_id, team in pairs( data.teams ) do
            for k, player in pairs( team ) do
                if player ~= localPlayer then
                    local blip = createBlipAttachedTo( player, 0, 1, 50, 200, 50 )

                    if team_id ~= my_team_id then
                        setBlipColor( blip, 200, 50, 50, 255 )
                    end

                    blip:setData( "is_hide", true, false )

                    table.insert( PLAYER_BLIPS[ team_id ], blip )
                    table.insert( COOP_QUEST_CLIENT_ELEMENTS, blip )
                end
            end
        end

        ToggleCoopQuestTeamBlips( true )
    end
end
addEvent( "OnCoopQuestStarted", true )
addEventHandler( "OnCoopQuestStarted", resourceRoot, OnCoopQuestStarted )

function OnCoopQuestFinished( )
    localPlayer:setData( "current_daily_coop_quest", false, false )

    removeEventHandler( "onClientPlayerWasted", localPlayer, OnClientPlayerWasted )

    for k,v in pairs( COOP_QUEST_CLIENT_ELEMENTS ) do
        if isElement( v ) then
            destroyElement( v )
        elseif v and v.destroy then
            v:destroy( )
        end
    end

    COOP_QUEST_CLIENT_ELEMENTS = { }

    if COOP_QUEST_CONFIG.OnFinished_Client then
        COOP_QUEST_CONFIG:OnFinished_Client( )
    end

    triggerEvent( "onClientTryDestroyGPSPath", root )
end
addEvent( "OnCoopQuestFinished", true )
addEventHandler( "OnCoopQuestFinished", resourceRoot, OnCoopQuestFinished )

function OnCoopQuestStageStarted( stage_id )
    COOP_QUEST_DATA.stage = stage_id

    local team_id = GetCoopQuestTeamID( )
    local stage_conf = COOP_QUEST_CONFIG.stages[ stage_id ]
    local is_mirrored = stage_conf.is_mirrored

    if stage_conf.global.OnStarted_Client then
        stage_conf.global:OnStarted_Client( )
    end

    if stage_conf.teams[ is_mirrored and 1 or team_id ].OnStarted_Client then
        stage_conf.teams[ is_mirrored and 1 or team_id ]:OnStarted_Client( )
    end
end
addEvent( "OnCoopQuestStageStarted", true )
addEventHandler( "OnCoopQuestStageStarted", resourceRoot, OnCoopQuestStageStarted )

function OnCoopQuestStageFinished( stage_id )
    local team_id = GetCoopQuestTeamID( )
    local stage_conf = COOP_QUEST_CONFIG.stages[ stage_id ]
    local is_mirrored = stage_conf.is_mirrored

    if stage_conf.global.OnFinished_Client then
        stage_conf.global:OnFinished_Client( )
    end

    if stage_conf.teams[ is_mirrored and 1 or team_id ].OnFinished_Client then
        stage_conf.teams[ is_mirrored and 1 or team_id ]:OnFinished_Client( )
    end

    for k,v in pairs( COOP_QUEST_STAGE_ELEMENTS ) do
        if isElement( v ) then
            destroyElement( v )
        elseif v and v.destroy then
            v:destroy( )
        end
    end

    COOP_QUEST_STAGE_ELEMENTS = { }
end
addEvent( "OnCoopQuestStageFinished", true )
addEventHandler( "OnCoopQuestStageFinished", resourceRoot, OnCoopQuestStageFinished )

function OnCoopQuestSyncedDataChanged( key, value )
    COOP_QUEST_DATA[ key ] = value
end
addEvent( "OnCoopQuestSyncedDataChanged", true )
addEventHandler( "OnCoopQuestSyncedDataChanged", resourceRoot, OnCoopQuestSyncedDataChanged )

function OnCoopQuestElementSynced( key, element )
    COOP_QUEST_ELEMENTS[ key ] = element
end
addEvent( "OnCoopQuestElementSynced", true )
addEventHandler( "OnCoopQuestElementSynced", resourceRoot, OnCoopQuestElementSynced )

function OnClientJoinedCoopQuest( data )
    COOP_QUEST_DATA = { }
    COOP_QUEST_ELEMENTS = { }
    COOP_QUEST_TEAM_DATA = { { }, { } }
    COOP_QUEST_CLIENT_ELEMENTS = { }
    COOP_QUEST_STAGE_ELEMENTS = { }
    PLAYER_BLIPS = { { }, { } }

    COOP_QUEST_DATA.team_id = data.team_id
end
addEvent( "OnClientJoinedCoopQuest", true )
addEventHandler( "OnClientJoinedCoopQuest", resourceRoot, OnClientJoinedCoopQuest )

function OnCoopQuestTaskUpdated( title, task_name )
    local data = localPlayer:getData( "current_daily_coop_quest" ) or { }
    data.title = title or data.title
    data.task_name = task_name or data.task_name

    localPlayer:setData( "current_daily_coop_quest", data, false )
end
addEvent( "OnCoopQuestTaskUpdated", true )
addEventHandler( "OnCoopQuestTaskUpdated", resourceRoot, OnCoopQuestTaskUpdated )

function OnCoopQuestTaskTimerUpdated( time_left )
    local data = localPlayer:getData( "current_daily_coop_quest" ) or { }
    data.timer = { getRealTimestamp(), time_left }

    localPlayer:setData( "current_daily_coop_quest", data, false )
end
addEvent( "OnCoopQuestTaskTimerUpdated", true )
addEventHandler( "OnCoopQuestTaskTimerUpdated", resourceRoot, OnCoopQuestTaskTimerUpdated )

Player.GetCoopQuestKeys = function( self )
    return self:getData( "coop_quest_keys" ) or 0
end

Player.GetCoopQuestAttempts = function( self )
    return self:getData( "coop_quest_attempts" ) or 0
end