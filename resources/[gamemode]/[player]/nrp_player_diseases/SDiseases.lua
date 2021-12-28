Extend( "SPlayer" )

DISEASE_STAGE_UP_INTERVAL = 24 * 60 * 60

PLAYERS_DISEASES = {
    -- [ player ] = {
    --     [ disease_id ] = { 
    --         stage = 1, 
    --         stage_up_date = getRealTimestamp( ), 
    --         last_treat_date = getRealTimestamp( ), 
    --     }
    -- }
}
PLAYERS_DISEASE_STAGE_TIMERS = { }

Player.SetDisease = function( self, disease_id, ignore_sync )
    if self:GetAccessLevel( ) > 0 then return end
    if self:GetLevel( ) <= DISEASE_START_LEVEL then return end
    if self:IsInEventLobby( ) then return end

    local player_diseases = PLAYERS_DISEASES[ self ]
    if not player_diseases then return end

    -- Заглушка (мб временная), чтобы игрок мог иметь не больше 1 болезни
    for disease_id, disease in pairs( player_diseases ) do
        if disease.stage > 0 then
            return
        end
    end

    if player_diseases[ disease_id ] and player_diseases[ disease_id ].stage > 0 then return end

    if not player_diseases[ disease_id ] then
        player_diseases[ disease_id ] = { }
    end
    player_diseases[ disease_id ].stage = 1
    player_diseases[ disease_id ].stage_up_date = getRealTimestamp( )
    
    self:SetPermanentData( "diseases", player_diseases )
    self:UpdateDiseaseDebuffs( player_diseases )
    self:SetDiseaseAnimationTimer( true )

    if not ignore_sync then
        triggerClientEvent( self, "onClientPlayerUpdateDiseases", self, disease_id, 1 )
    end
    
    SendElasticGameEvent( self:GetClientID( ), "ill_get", { 
        ill_id = disease_id, 
        ill_name = DISEASES_INFO[ disease_id ].name,
    } )

    return true
end

Player.UpdateDiseaseDebuffs = function( self, player_diseases )
    local max_health = 100
    local max_calories = 100
    for disease_id, disease in pairs( player_diseases ) do
        if disease.stage > 0 then
            local debuffs_by_stage = DISEASES_INFO[ disease_id ].debuffs
            local debuffs = debuffs_by_stage and debuffs_by_stage[ disease.stage ]
            if debuffs then
                if debuffs.max_health then
                    max_health = math.min( debuffs.max_health, max_health )
                end
                if debuffs.max_calories then
                    max_calories = math.min( debuffs.max_calories, max_calories )
                end
            end
        end
    end
    self:SetBuff( "max_health", max_health - 100, "disease" )
    self:SetBuff( "max_calories", max_calories - 100, "disease" )
end

addEvent( "onPlayerDiseaseGot", true )
addEventHandler( "onPlayerDiseaseGot", root, function( disease_id )
    if not disease_id then return end
    client:SetDisease( disease_id, true )
end )

function onPlayerCompleteLogin_handler( player )
    local player = isElement( player ) and player or source

    PLAYERS_DISEASES[ player ] = FixTableKeys( player:GetPermanentData( "diseases" ) ) or { }
    PLAYERS_DISEASE_STAGE_TIMERS[ player ] = { }

    local player_diseases = PLAYERS_DISEASES[ player ]
    if not next( player_diseases ) then return end

    local diseases_stages = { }
    local current_date = getRealTimestamp( )
    local min_time_left_to_treating = false
    for disease_id, disease in pairs( player_diseases ) do
        if disease.stage > 0 then
            local time_passed = current_date - disease.stage_up_date
            local days_passed = math.floor( time_passed / DISEASE_STAGE_UP_INTERVAL )
            if time_passed >= DISEASE_STAGE_UP_INTERVAL then
                local old_stage = disease.stage
                disease.stage = math.min( 3, old_stage + days_passed )
                disease.stage_up_date = disease.stage_up_date + days_passed * DISEASE_STAGE_UP_INTERVAL

                if old_stage ~= disease.stage then
                    SendElasticGameEvent( player:GetClientID( ), "ill_stage_up", { 
                        ill_id = disease_id, 
                        ill_name = DISEASES_INFO[ disease_id ].name,
                        ill_stage = disease.stage,
                    } )
                end
            end

            if disease.last_treat_date then
                local time_left_to_treating = disease.last_treat_date + TREATING_COOLDOWN - current_date
                min_time_left_to_treating = math.min( min_time_left_to_treating or math.huge, time_left_to_treating )
            end

            PLAYERS_DISEASE_STAGE_TIMERS[ player ][ disease_id ] = setTimer( 
                function( )
                    local old_stage = disease.stage
                    disease.stage = math.min( 3, old_stage + 1 )
                    disease.stage_up_date = disease.stage_up_date + DISEASE_STAGE_UP_INTERVAL
                    player:SetPermanentData( "diseases", player_diseases )
                    player:UpdateDiseaseDebuffs( player_diseases )

                    if old_stage ~= disease.stage then
                        triggerClientEvent( player, "onClientPlayerUpdateDiseases", player, disease_id, disease.stage )
                        player:SetDiseaseAnimationTimer( true )

                        SendElasticGameEvent( player:GetClientID( ), "ill_stage_up", { 
                            ill_id = disease_id, 
                            ill_name = DISEASES_INFO[ disease_id ].name,
                            ill_stage = disease.stage,
                        } )
                    end
                end, 
                ( disease.stage_up_date + DISEASE_STAGE_UP_INTERVAL - current_date ) * 1000, 1 
            )

            diseases_stages[ disease_id ] = disease.stage
        end
    end
    player:SetPermanentData( "diseases", player_diseases )
    player:UpdateDiseaseDebuffs( player_diseases )
    player:SetDiseaseAnimationTimer( )

    if min_time_left_to_treating and min_time_left_to_treating > 0 then
        triggerClientEvent( player, "onClientSetTreatingTimer", player, min_time_left_to_treating )
    end

    if next( diseases_stages ) then
        triggerClientEvent( player, "onClientPlayerUpdateDiseases", player, diseases_stages )
    end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler, true, "high" )

addEventHandler( "onResourceStart", resourceRoot, function( )
    Timer( function( )
        for i, v in pairs( GetPlayersInGame( ) ) do
            onPlayerCompleteLogin_handler( v )
        end
    end, 1000, 1 )
end )

function onPlayerPreLogout_handler( player )
    local player = isElement( player ) and player or source

    if PLAYERS_DISEASES[ player ] then
        for disease_id, timer in pairs( PLAYERS_DISEASE_STAGE_TIMERS[ player ] ) do
            if isTimer( timer ) then
                killTimer( timer )
            end
        end
        PLAYERS_DISEASES[ player ] = nil
        PLAYERS_DISEASE_STAGE_TIMERS[ player ] = nil
    end
end
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_handler )

function onPlayerTreatComplete_handler( target, disease_id )
	if not isElement( target ) then return end

	local player_diseases = PLAYERS_DISEASES[ target ]
	if not player_diseases then return end

	local disease = player_diseases[ disease_id ]
	if not disease or disease.stage == 0 then return end

    disease.stage = disease.stage - 1
	disease.last_treat_date = getRealTimestamp( )
    target:SetPermanentData( "diseases", player_diseases )
    target:UpdateDiseaseDebuffs( player_diseases )
    if disease.stage == 0 then
        target:StopDiseaseAnimationTimer( )
        target:ShowInfo( "Врач вылечил вас." )
    else
        target:ShowInfo( string.format( "Врач вылечил %s стадию болезни." , disease.stage ) )
    end

    target:SetPermanentData( "last_treat_date", disease.last_treat_date )

    triggerEvent( "onPlayerSomeDo", target, "delightful_treatment" ) -- achievements
    
    local disease_stage_timer = PLAYERS_DISEASE_STAGE_TIMERS[ target ][ disease_id ]
    if isTimer( disease_stage_timer ) then
        killTimer( disease_stage_timer )
    end
	
    triggerClientEvent( target, "onClientPlayerUpdateDiseases", target, disease_id, disease.stage )

    SendElasticGameEvent( target:GetClientID( ), "ill_stage_down", { 
        ill_id = disease_id, 
        ill_name = DISEASES_INFO[ disease_id ].name,
        ill_stage = disease.stage,
    } )
end
addEvent( "onPlayerTreatComplete", true )
addEventHandler( "onPlayerTreatComplete", root, onPlayerTreatComplete_handler, true, "high" )

function onPlayerTreatCompleteViaService_handler( )
    source:SetPermanentData( "diseases", { } )
    source:UpdateDiseaseDebuffs( { } )
    source:StopDiseaseAnimationTimer( )

    triggerClientEvent( source, "onClientPlayerUpdateDiseases", source, { } )

    triggerEvent( "onPlayerSomeDo", source, "delightful_treatment" ) -- achievements
end
addEvent( "onPlayerTreatCompleteViaService", false )
addEventHandler( "onPlayerTreatCompleteViaService", root, onPlayerTreatCompleteViaService_handler )

---------------------------------------------------------------------------------------------
-- Для теста

if SERVER_NUMBER > 100 then
    local players_text_items = { }

    function showTextDisplay( player, command )
        if isElement( player:getData( "debug_text_item" ) ) then return end
        local serverDisplay = textCreateDisplay()                             -- create a text display
        textDisplayAddObserver ( serverDisplay, player )                      -- make it visible to a player
        local serverText = textCreateTextItem ( inspect( PLAYERS_DISEASES[ player ] ), 0.1, 0.1, _, _, _, _, _, 1, _, _, 255 )    -- create a text item for the display
        textDisplayAddText ( serverDisplay, serverText )                      -- add it to the display so it is displayed
        players_text_items[ player ] = serverText
    end
    addCommandHandler( "show_diseases_debug", showTextDisplay )

    local _SetPermanentData = Player.SetPermanentData
    Player.SetPermanentData = function( self, k, v )
        _SetPermanentData( self, k, v )
        if k == "diseases" and players_text_items[ self ] then
            textItemSetText( players_text_items[ self ], inspect( v ) )
        end
    end

    addCommandHandler( "random_infect", function( player )
        InfectRandomPlayers( getRealTimestamp( ) )
        outputConsole( "Рандомное заражение прошло успешно" )
    end )

    addCommandHandler( "set_disease", function( player, cmd, selected_disease_id )
        selected_disease_id = tonumber( selected_disease_id )
        player:SetDisease( selected_disease_id )
        outputConsole( "Болезнь успешно установлена" )
    end )

    addCommandHandler( "set_disease_stage", function( player, cmd, selected_disease_id, stage )
        selected_disease_id = tonumber( selected_disease_id )
        stage = tonumber( stage ) or 0
        local player_diseases = PLAYERS_DISEASES[ player ]
        local disease = player_diseases and player_diseases[ selected_disease_id ]
        if not disease then return end
        disease.stage = stage
        player:SetPermanentData( "diseases", player_diseases )
        player:UpdateDiseaseDebuffs( player_diseases )
        triggerClientEvent( player, "onClientPlayerUpdateDiseases", player, selected_disease_id, disease.stage )
        player:SetDiseaseAnimationTimer( true )
        outputConsole( "Стадия болезни успешно изменена на " .. stage )
    end )

    addCommandHandler( "clear_last_treat_date", function( player, cmd, selected_disease_id )
        selected_disease_id = tonumber( selected_disease_id )
        local player_diseases = PLAYERS_DISEASES[ player ]
        local disease = player_diseases and player_diseases[ selected_disease_id ]
        if not disease then return end
        disease.last_treat_date = nil
        player:SetPermanentData( "diseases", player_diseases )
        player:UpdateDiseaseDebuffs( player_diseases )
        outputConsole( "Дата последнего лечения успешно очищена" )
    end )
end