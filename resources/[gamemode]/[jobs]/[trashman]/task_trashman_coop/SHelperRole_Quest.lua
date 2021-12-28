
-- Подбор мешка
function onTrashmanTryPickup_handler()
    local player = client
    if not isElement( player ) then return end

    local lobby_data = GetLobbyDataByPlayer( player )
    if not lobby_data or lobby_data.taken_bags == MAX_TAKE_BAGS_ON_POINT then return end

    lobby_data.taken_bags = lobby_data.taken_bags + 1

    GivePlayerBag( player, lobby_data )

    if lobby_data.taken_bags == MAX_TAKE_BAGS_ON_POINT then
        DestroyClientPickupPoints( lobby_data )
    end
end
addEvent( "onTrashmanTryPickup", true )
addEventHandler( "onTrashmanTryPickup", resourceRoot, onTrashmanTryPickup_handler )

-- Внесение мешка в машину
function onTrashmanTryPutInVehicle_handler()
    local player = client
    if not isElement( player ) then return end

    local lobby_data = GetLobbyDataByPlayer( player )
    if not lobby_data or lobby_data.count_vehicle_bags == GetMaxBagsOnPoint( lobby_data ) or not GetPlayerBag( player ) then return end

    lobby_data.count_vehicle_bags = lobby_data.count_vehicle_bags + 1

    TakePlayerBag( player, lobby_data )
    RefreshTrashmanHUD( lobby_data )

    if (lobby_data.count_vehicle_bags == GetMaxBagsOnPoint( lobby_data )) or (lobby_data.count_vehicle_bags == lobby_data.quest_bags_count) then
        DestroyClientPickupPoints( lobby_data )
        triggerEvent( lobby_data.end_step, player )
    elseif lobby_data.taken_bags ~= MAX_TAKE_BAGS_ON_POINT then
        triggerClientEvent( player, "onClientCreateNextPickupPoint", resourceRoot, lobby_data.trash_point_id, lobby_data.job_vehicle )
    end
end
addEvent( "onTrashmanTryPutInVehicle", true )
addEventHandler( "onTrashmanTryPutInVehicle", resourceRoot, onTrashmanTryPutInVehicle_handler )

function DestroyClientPickupPoints( lobby_data )
    if lobby_data.taken_bags == MAX_TAKE_BAGS_ON_POINT then
        triggerClientEvent( GetLobbyPlayersByLobbyId( lobby_data.lobby_id ), "onClientDestroyPickupPoints", resourceRoot )
    end
end

function GetMaxBagsOnPoint( lobby_data )
    return lobby_data.quest_bags_count - ((5 - lobby_data.current_point) * 2)
end

-- Выдать мусорщику мешок
function GivePlayerBag( player, lobby_data )
    toggleControl( player, "enter_exit", false )
    toggleControl( player, "enter_passenger", false )
    player:setData( "trashman_has_bag", lobby_data.lobby_id, false )

    local target_elements = getElementsWithinRange( player.position, 300, "player" )
    triggerClientEvent( target_elements, "onClientPlayerTakeTrashBag", resourceRoot, player, lobby_data.job_vehicle )
end

-- Получить мешок
function GetPlayerBag( player )
    return player:getData( "trashman_has_bag" )
end

-- Забрать мешок
function TakePlayerBag( player, lobby_data )
    RemovePlayerBag( player )
    triggerClientEvent( GetPlayersInGame(), "onClientPlayerPlaceTrashBag", resourceRoot, player, lobby_data.job_vehicle )
end

-- Удалить мешок
function RemovePlayerBag( player )
    toggleControl( player, "enter_exit", true )
    toggleControl( player, "enter_passenger", true )
    player:setData( "trashman_has_bag", nil, false )
end

-- Очистка даты мешков
function DestroyBagsData( lobby_data )
    for k, v in pairs( lobby_data.participants ) do
        RemovePlayerBag( v.player )
    end
    -- Мешки на клиенте удалятся вместе с lobby_data.job_vehicle 
    -- (т.к. он установлен как их parent и он удаляется автоматом при завершении смены)
end