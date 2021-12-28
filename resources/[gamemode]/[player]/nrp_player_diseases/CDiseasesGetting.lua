local SHOT_DAMAGES_COUNT = 0
local ATTACKS_COUNT = 0
local ATTACKS_PLAYERS = { }
local USED_DRUGS_COUNT = 0
local USED_ALCO_COUNT = 0
local OVEREATING_COUNT = 0

Player.SetDisease = function( self, disease_id )
    if not disease_id then return end
    if self:GetAccessLevel( ) > 0 then return end
    if self:GetLevel( ) <= DISEASE_START_LEVEL then return end
    if self:IsInEventLobby( ) then return end

    -- Заглушка (мб временная), чтобы игрок мог иметь не больше 1 болезни
    for disease_id, stage in pairs( PLAYER_DISEASES ) do
        if stage > 0 then
            return
        end
    end
    
    triggerServerEvent( "onPlayerDiseaseGot", self, disease_id )
    onClientPlayerUpdateDiseases_handler( disease_id, 1 )
end

function IsCancelDiseases()
    if localPlayer:getData( "in_clan_event_lobby" ) then
        return true
    end
    return false
end

addEventHandler( "onClientPlayerDamage", root, function( attacker, weapon, bodypart, loss )
    if IsCancelDiseases() then return end
    if source == localPlayer then
        if weapon and weapon >= 22 and weapon <= 34 and localPlayer.armor <= 0 and not PLAYER_DISEASES[ DIS_GUNSHOT ] then
            SHOT_DAMAGES_COUNT = SHOT_DAMAGES_COUNT + 1
            if SHOT_DAMAGES_COUNT >= 3 then
                localPlayer:SetDisease( DIS_GUNSHOT )
                SHOT_DAMAGES_COUNT = 0
            end
        end

        if loss > 25 and not PLAYER_DISEASES[ DIS_FRACTURE ] then
            localPlayer:SetDisease( DIS_FRACTURE )
        end
        
    elseif attacker == localPlayer then
        if ATTACKS_PLAYERS[ source ] then return end

        ATTACKS_PLAYERS[ source ] = setTimer( function( source )
            ATTACKS_COUNT = ATTACKS_COUNT - 1
            ATTACKS_PLAYERS[ source ] = nil
        end, 15 * 60 * 1000, 1, source )

        ATTACKS_COUNT = ATTACKS_COUNT + 1

        if ATTACKS_COUNT >= 10 and not PLAYER_DISEASES[ DIS_PSYCHOSIS ] then
            localPlayer:SetDisease( DIS_PSYCHOSIS )
        end
    end
end )

addEvent( "onClientPlayerUseDrugs", true )
addEventHandler( "onClientPlayerUseDrugs", localPlayer, function( )
    if PLAYER_DISEASES[ DIS_DRUG_ADDICT ] then return end

    USED_DRUGS_COUNT = USED_DRUGS_COUNT + 1
    if USED_DRUGS_COUNT >= 4 + localPlayer:GetClanBuffValue( CLAN_UPGRADE_DISEASE_RESISTANCE ) then
        localPlayer:SetDisease( DIS_DRUG_ADDICT )
        USED_DRUGS_COUNT = 0
    end
end )

addEvent( "onClientPlayerBuyAlcohol", true )
addEventHandler( "onClientPlayerBuyAlcohol", localPlayer, function( )
    if PLAYER_DISEASES[ DIS_ALCOHOLISM ] then return end

    USED_ALCO_COUNT = USED_ALCO_COUNT + 1
    if USED_ALCO_COUNT >= 4 + localPlayer:GetClanBuffValue( CLAN_UPGRADE_DISEASE_RESISTANCE ) then
        localPlayer:SetDisease( DIS_ALCOHOLISM )
        USED_ALCO_COUNT = 0
    end
end )

addEvent( "onClientPlayerCaloriesChange", true )
addEventHandler( "onClientPlayerCaloriesChange", localPlayer, function( old_value, new_value )
    if PLAYER_DISEASES[ DIS_STARVATION ] then return end

    if new_value == 0 and not STARVATION_TIMER then
        STARVATION_TIMER = setTimer( 
            function( )
                if PLAYER_DISEASES[ DIS_STARVATION ] then return end
                localPlayer:SetDisease( DIS_STARVATION )
                STARVATION_TIMER = nil
            end, 
            15 * 60 * 1000, 1 
        )
    elseif new_value > 0 and STARVATION_TIMER then
        killTimer( STARVATION_TIMER )
        STARVATION_TIMER = nil
    end
end )

addEvent( "OnPlayerPuke", true )
addEventHandler( "OnPlayerPuke", localPlayer, function( )
    if PLAYER_DISEASES[ DIS_OVEREATING ] then return end

    OVEREATING_COUNT = OVEREATING_COUNT + 1
    if OVEREATING_COUNT >= 2 then
        localPlayer:SetDisease( DIS_OVEREATING )
        OVEREATING_COUNT = 0
    end
end )