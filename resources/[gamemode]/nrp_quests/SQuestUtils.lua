Player.AddDailyQuestList = function( self, quest_list )
    local current_daily_quests = self:GetPermanentData( "cur_daily_quests" ) or {}
    for k, v in pairs( quest_list ) do
        table.insert( current_daily_quests, v )
    end
    self:SetPermanentData( "cur_daily_quests", current_daily_quests )

    if not isElement( self ) then return end
    self:SetPrivateData( "cur_daily_quests", current_daily_quests )
end

function onServerAddPlayerDailyQuest_handler( quest_id, is_forced )
    if not isElement( source ) or not DAILY_QUEST_LIST[ quest_id ] then return end
    
    local target_quest = nil
    local daily_quest_list = source:GetPermanentData( "daily_quest_list" ) or {}
    for k, v in ipairs( daily_quest_list ) do
        if v.id == quest_id then
            target_quest = v
        end
    end

    if not target_quest then 
        iprint( "ERROR_ADD: QUEST \"" .. quest_id .. "\" NOT_EXIST" )
        return 
    end

    local current_daily_quests = source:GetPermanentData( "cur_daily_quests" ) or {}
    for k, v in pairs( current_daily_quests ) do
        if v.id == quest_id then
            iprint( "ERROR_ADD: QUEST \"" .. quest_id .. "\" EXIST_IN_LIST" )
            return
        end
    end

    local target_time = getCurrentDayTimestamp( RESET_TIME )
    local time_left = getRealTimestamp() > target_time and target_time + SECONDS_24h or target_time
    table.insert( current_daily_quests,
    {
        id = target_quest.id,
        time_left = time_left,
        step = 0,
        steps = DAILY_QUEST_LIST[ target_quest.id ].steps or 1,
        is_new = true,
        first_exec = target_quest.count_exec == 0 and true or false,
        is_forced = is_forced,
    })

    --iprint(target_quest)
    
    source:SetPermanentData( "cur_daily_quests", current_daily_quests )
    source:SetPrivateData( "cur_daily_quests", current_daily_quests )
end
addEvent( "onServerAddPlayerDailyQuest", true )
addEventHandler( "onServerAddPlayerDailyQuest", root, onServerAddPlayerDailyQuest_handler )

function onServerRemovePlayerDailyQuest_handler( quest_id )
    local player = isElement( source ) and source
    if not isElement( player ) then return end

    local current_daily_quests = player:GetPermanentData( "cur_daily_quests" ) or {}
    local daily_quest_list = player:GetPermanentData( "daily_quest_list" ) or {}

    for k,v in pairs( current_daily_quests ) do
        if v.id == quest_id then
            table.remove( current_daily_quests, k )
        end
    end

    player:SetPermanentData( "cur_daily_quests", current_daily_quests )
    player:SetPrivateData( "cur_daily_quests", current_daily_quests )
end
addEvent( "onServerRemovePlayerDailyQuest", false )
addEventHandler( "onServerRemovePlayerDailyQuest", root, onServerRemovePlayerDailyQuest_handler )

function onServerRefreshPlayerDailyQuests_handler( )
    local player = isElement( source ) and source
    if not isElement( player ) then return end

    local current_daily_quests = player:GetPermanentData( "cur_daily_quests" ) or {}
    local daily_quest_list = player:GetPermanentData( "daily_quest_list" ) or {}

    for k,v in pairs( current_daily_quests ) do
        if not v.completed then
            local quest = DAILY_QUEST_LIST[ v.id ]
            if quest.condition and not quest.condition( player ) then
                RemoveDailyQuest( player, v.id )
                RefreshDailyQuests( player )
                break
            end
        end
    end
end
addEvent( "onServerRefreshPlayerDailyQuest", false )
addEventHandler( "onServerRefreshPlayerDailyQuest", root, onServerRefreshPlayerDailyQuest_handler )

------------------------------------------------------
-- Тестирование
------------------------------------------------------

addCommandHandler("rs", function(player)
	if player:GetAccessLevel( ) < ACCESS_LEVEL_DEVELOPER then return end
    
    local last_refresh_data = player:GetPermanentData( "last_refresh_data" )
    last_refresh_data.date = last_refresh_data.date - SECONDS_24h
    last_refresh_data.is_add = false
    last_refresh_data.is_reset_refresh = true

    player:SetPermanentData( "cur_daily_quests", {} )
    player:SetPrivateData( "cur_daily_quests", {} )

    player:SetPermanentData( "last_refresh_data", last_refresh_data )
    player:SetPrivateData( "last_refresh_data", last_refresh_data )
    RefreshDailyTasks( RESET_TIME )

end )

addCommandHandler("ad", function(player)
    if player:GetAccessLevel( ) < ACCESS_LEVEL_DEVELOPER then return end
    
    local last_refresh_data = player:GetPermanentData( "last_refresh_data" )
    last_refresh_data.date = last_refresh_data.date
    last_refresh_data.is_add = false
    last_refresh_data.is_add_refresh = true

    player:SetPermanentData( "last_refresh_data", last_refresh_data )
    player:SetPrivateData( "last_refresh_data", last_refresh_data )

	RefreshDailyTasks( ADD_TIME )
end )
