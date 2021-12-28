
-- Подбор мешка с бизнеса
function onServerIncasatorTryTakeBagFromBusiness_handler()
    local player = client
    if not isElement( player ) then return end

    local lobby_data = GetLobbyDataByPlayer( player )
    if not lobby_data or lobby_data.process_bags == MAX_TAKE_BAGS_ON_POINT or player:GetCoopJobRole() ~= JOB_ROLE_GUARD then return end

    lobby_data.process_bags = lobby_data.process_bags + 1
    
    GivePlayerBag( player, lobby_data )
    TryDestroyClientTakePointsLobby( lobby_data )
end
addEvent( "onServerIncasatorTryTakeBagFromBusiness", true )
addEventHandler( "onServerIncasatorTryTakeBagFromBusiness", resourceRoot, onServerIncasatorTryTakeBagFromBusiness_handler )

-- Внесение мешка в машину
function onServerIncasatorTryPlaceBagInVehicle_handler()
    local player = client
    if not isElement( player ) then return end

    local lobby_data = GetLobbyDataByPlayer( player )
    if not lobby_data or lobby_data.count_vehicle_bags == GetMaxBagsOnPoint( lobby_data ) or not GetPlayerBag( player ) or player:GetCoopJobRole() ~= JOB_ROLE_GUARD then return end

    lobby_data.count_vehicle_bags = lobby_data.count_vehicle_bags + 1
    
    TakePlayerBag( player )
    RefreshDriverBagsPercent( lobby_data )

    if (lobby_data.count_vehicle_bags == GetMaxBagsOnPoint( lobby_data )) or (lobby_data.count_vehicle_bags == lobby_data.quest_bags_count) then
        TryDestroyClientTakePointsLobby( lobby_data )
        triggerEvent( lobby_data.end_step, player )
    elseif lobby_data.process_bags ~= MAX_TAKE_BAGS_ON_POINT then
        triggerClientEvent( player, "onClientCreateTakeNextPoint", resourceRoot, lobby_data.bank_point_id, lobby_data.job_vehicle )
    end
end
addEvent( "onServerIncasatorTryPlaceBagInVehicle", true )
addEventHandler( "onServerIncasatorTryPlaceBagInVehicle", resourceRoot, onServerIncasatorTryPlaceBagInVehicle_handler )

function TryDestroyClientTakePointsLobby( lobby_data )
    if lobby_data.process_bags == MAX_TAKE_BAGS_ON_POINT then
        triggerClientEvent( GetLobbyPlayersByRole( lobby_data.lobby_id, JOB_ROLE_GUARD ), "onClientDestroyGuardPoints", resourceRoot )
    end
end

function GetMaxBagsOnPoint( lobby_data )
    return lobby_data.quest_bags_count - ((5 - lobby_data.current_point) * 2)
end

-- Взятие мешка из машины
function onServerIncasatorTryTakeBagFromVehicle_handler()
    local player = client
    if not isElement( player ) then return end

    local lobby_data = GetLobbyDataByPlayer( player )
    if not lobby_data or not lobby_data.process_bags or lobby_data.count_vehicle_bags == 0 or player:GetCoopJobRole() ~= JOB_ROLE_GUARD then return end

    lobby_data.count_vehicle_bags = lobby_data.count_vehicle_bags - 1
    
    GivePlayerBag( player, lobby_data )
    RefreshDriverBagsPercent( lobby_data )
end
addEvent( "onServerIncasatorTryTakeBagFromVehicle", true )
addEventHandler( "onServerIncasatorTryTakeBagFromVehicle", resourceRoot, onServerIncasatorTryTakeBagFromVehicle_handler )

-- Внесение мешка в банк
function onServerIncasatorTryPlaceBagInUnloadPoint_handler()
    local player = client
    if not isElement( player ) then return end

    local lobby_data = GetLobbyDataByPlayer( player )
    if not lobby_data or not lobby_data.process_bags or player:GetCoopJobRole() ~= JOB_ROLE_GUARD then return end

    TakePlayerBag( player )
    lobby_data.count_unload_bags = lobby_data.count_unload_bags + 1
    lobby_data.count_delivered_bags = lobby_data.count_delivered_bags + 1

    if lobby_data.count_unload_bags == lobby_data.quest_bags_count then
        triggerEvent( lobby_data.end_step, player )
    elseif lobby_data.count_vehicle_bags > 0 then
        triggerClientEvent( player, "onClientCreateTakeVehicleNextPoint", resourceRoot, lobby_data.job_vehicle )
    end
end
addEvent( "onServerIncasatorTryPlaceBagInUnloadPoint", true )
addEventHandler( "onServerIncasatorTryPlaceBagInUnloadPoint", resourceRoot, onServerIncasatorTryPlaceBagInUnloadPoint_handler )

-- Охранник покинул смену с мешком
function onGuardLeaveQuestWithBag( player, role, lobby_data )
    if player.dead then
        ResetBagDataTimeOut( player )
    else
        onGuardLostBag( player, lobby_data )
        setElementData( player, "incasator_has_bag", nil, false )
        triggerClientEvent( GetPlayersInGame(), "onClientDestroyBags", resourceRoot, { { player = player, role = role } } )
    end
end

function onGuardLostBag( player, lobby_data )
    lobby_data.quest_bags_count = lobby_data.quest_bags_count - 1
    if (lobby_data.count_unload_bags and lobby_data.count_unload_bags == lobby_data.quest_bags_count) or (not lobby_data.count_unload_bags and lobby_data.count_vehicle_bags == GetMaxBagsOnPoint( lobby_data ) ) then
        for k, v in pairs( lobby_data.participants ) do
            if v.role == JOB_ROLE_GUARD and v.player ~= player then
                triggerEvent( lobby_data.end_step, v.player )
                break
            end
        end
    else
        RefreshDriverBagsPercent( lobby_data )
    end
end

-- Выдать охарннику мешок
function GivePlayerBag( player, lobby_data )
    toggleControl( player, "enter_exit", false )
    toggleControl( player, "enter_passenger", false )
    player:setData( "incasator_has_bag", lobby_data.lobby_id, false )

    local target_elements = getElementsWithinRange( player.position, 500, "player" )
    triggerClientEvent( target_elements, "onClientPlayerTakeBagMoney", resourceRoot, player )
end

-- Получить мешок
function GetPlayerBag( player )
    return player:getData( "incasator_has_bag" )
end

-- Забрать мешок
function TakePlayerBag( player )
    toggleControl( player, "enter_exit", true )
    toggleControl( player, "enter_passenger", true )
    player:setData( "incasator_has_bag", nil, false )
    triggerClientEvent( GetPlayersInGame(), "onClientPlayerPlaceBagMoney", resourceRoot, player )
end

-- Уничтожение мешков
function DestroyBagsData( lobby_data )
    local destroy_client = false
    for k, v in pairs( lobby_data.participants ) do
        if GetPlayerBag( v.player ) and not destroy_client then
            destroy_client = true
        end
        ResetBagDataTimeOut( v.player )
    end

    if destroy_client then
        triggerClientEvent( GetPlayersInGame(), "onClientDestroyBags", resourceRoot, lobby_data.participants )
    end
end

-- Сброс данных с задержкой
function ResetBagDataTimeOut( player )
    setTimer( function()
        if not isElement( player ) then return end
        setElementData( player, "incasator_has_bag", nil, false )
    end, 5000, 1 )
end