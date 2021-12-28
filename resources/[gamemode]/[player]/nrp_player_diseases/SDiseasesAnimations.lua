DISEASE_ANIMATION_INTERVALS_BY_STAGE = {
    180 * 1000,
    150 * 1000, 
    120 * 1000,
}

PLAYERS_ANIMATION_TIMERS = { }

Player.SetDiseaseAnimationTimer = function( self, next_timer )
    if not next_timer and isTimer( PLAYERS_ANIMATION_TIMERS[ self ] ) then return end

    local player_diseases = PLAYERS_DISEASES[ self ]
    local diseases_list = { }
    for disease_id, disease in pairs( player_diseases ) do
        if disease.stage > 0 and DISEASES_ANIMATIONS[ disease_id ] then
            table.insert( diseases_list, disease_id )
        end
    end
    if #diseases_list == 0 then return end

    local random_disease = diseases_list[ math.random( #diseases_list ) ]
    local interval = DISEASE_ANIMATION_INTERVALS_BY_STAGE[ player_diseases[ random_disease ].stage ]
    if isTimer( PLAYERS_ANIMATION_TIMERS[ self ] ) then
        killTimer( PLAYERS_ANIMATION_TIMERS[ self ] )
    end
    PLAYERS_ANIMATION_TIMERS[ self ] = setTimer( SetDiseaseAnimation, interval, 1, self, random_disease, true )

    --первое проигрывание анимации без таймера
    SetDiseaseAnimation( self, random_disease  )
end

Player.StopDiseaseAnimationTimer = function( self, next_timer )
    if isTimer( PLAYERS_ANIMATION_TIMERS[ self ] ) then 
        killTimer( PLAYERS_ANIMATION_TIMERS[ self ] )
    end
end

function SetDiseaseAnimation( player, disease_id, next_timer )
    if PLAYERS_DISEASES[ player ][ disease_id ] and not player.dead and not player:getData( "current_quest" ) and not player.vehicle and not player:getData( "in_casino" ) then
        local sync_to = getElementsWithinRange( player.position, 75, "player" )
        local dimension = player.dimension

        for k, v in pairs( sync_to ) do
            if v.dimension ~= dimension then
                sync_to[ k ] = nil
            end
        end

        triggerClientEvent( sync_to, "onClientPlayerDiseaseAnimation", player, disease_id )
    end

    player:SetDiseaseAnimationTimer( next_timer )
end

function onPlayerPreLogout_animsHandler( player )
    local player = isElement( player ) and player or source

    if PLAYERS_ANIMATION_TIMERS[ player ] then
        if isTimer( PLAYERS_ANIMATION_TIMERS[ player ] ) then
            killTimer( PLAYERS_ANIMATION_TIMERS[ player ] )
        end
        PLAYERS_ANIMATION_TIMERS[ player ] = nil
    end
end
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_animsHandler )