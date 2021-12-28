loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "ShClans" )

local SAVE_FREQ = 15000 -- синхронизировать с сервером
local CHECK_FREQ = 1000

local FULL_LOSS_TIME = 4 * 60 * 60 * 1000 -- время в мс, за которое будет потрачено 100% калорий
local LOSS_PER_FREQ = 100 / FULL_LOSS_TIME * CHECK_FREQ

LAST_CALORIES = localPlayer:GetCalories()
LOST_CALS_TO_SYNC = 0

function CheckPlayer()
    if not localPlayer:IsInGame() then return end
    if localPlayer.dead then return end
    if localPlayer:GetLevel() <= 1 then return end
    if localPlayer:getData( "_healing" ) then return end
    if localPlayer:IsAdmin() then return end
    if localPlayer:getData( "jailed" ) then return end
    return true
end

function PulsePlayerHunger( )
    if not CheckPlayer() then return end

    local calories = localPlayer:GetCalories()
    local move_state = getPedMoveState( localPlayer )

    local target_loss = LOSS_PER_FREQ

    if move_state == "sprint" or PROFESSION_SHIFT_STATE then
        target_loss = target_loss * 1.5
    elseif move_state == "stand" then
        target_loss = target_loss * 0.75
    elseif move_state == "jump" or move_state == "climb" then
        target_loss = target_loss * 2
    end

    local is_buff_active, remaining_time = IsBuffActive( BUFF_HUNGER )
    if is_buff_active then
        target_loss = target_loss * 0.5
    end
    
    target_loss = target_loss * ( 1 - localPlayer:GetClanBuffValue( CLAN_UPGRADE_SLOW_HUNGER ) / 100 )

    local calories_new = math.max( 0, calories - target_loss )

    if calories > 20 and calories_new <= 20 then
        localPlayer:ShowWarning( "Персонаж голоден" )
    end
    if calories > 0 and calories_new <= 0 then
        localPlayer:ShowWarning( "Персонаж очень голоден" )
    end

    LOST_CALS_TO_SYNC = LOST_CALS_TO_SYNC + ( calories - calories_new )
    LAST_CALORIES = calories_new
    localPlayer:setData( "calories", calories_new, false )
    triggerEvent( "onClientPlayerCaloriesChange", localPlayer, calories, calories_new )
end
Timer( PulsePlayerHunger, CHECK_FREQ, 0 )

function PulseSavePlayerHunger( )
    if not CheckPlayer() then return end
    if LOST_CALS_TO_SYNC ~= 0 then
        triggerServerEvent( "onCaloriesUpdate", resourceRoot, LOST_CALS_TO_SYNC )
        LOST_CALS_TO_SYNC = 0
    end
end
Timer( PulseSavePlayerHunger, SAVE_FREQ, 0 )

addEventHandler( "onClientElementDataChange", localPlayer, function( key, old_value, new_value )
    if key == "calories" and new_value ~= LAST_CALORIES then
        local old_calories = LAST_CALORIES
        LAST_CALORIES = new_value - LOST_CALS_TO_SYNC
        localPlayer:setData( "calories", LAST_CALORIES, false )
        triggerEvent( "onClientPlayerCaloriesChange", localPlayer, old_calories, LAST_CALORIES )
    end
end )

--setPedAnimation( localPlayer, "food", "eat_vomit_p", -1, false, false, true, false )