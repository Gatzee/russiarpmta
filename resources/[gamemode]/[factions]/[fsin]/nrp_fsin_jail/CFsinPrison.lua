loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CPlayer" )
Extend( "ShUtils" )
Extend( "CInterior" )

CURRENT_JAIL_DATA = {}
TIME_DIFF = 0

-- Игрок заключен в тюрьму
function OnPlayerJailed( data, server_time )

    TIME_DIFF = server_time - getRealTime().hour

	data.end_tick = getTickCount() + data.time_left * 1000

	CURRENT_JAIL_DATA = data

    --Включаем проверку на выход из камеры
    addEventHandler("onClientPreRender", root, CheckForEscape)

    --Создаём информацию об аресте
    CreateDescriptionJail()

    --Создаем маркер выхода на работу в камере
    CreateToJobMarker( CURRENT_JAIL_DATA.jail_id, CURRENT_JAIL_DATA.room_id )

    --Чекаем побег
    addEventHandler ("onClientColShapeHit", PRISON_AREA, onEnterPrisonArea )
    addEventHandler("onClientColShapeLeave", PRISON_AREA, onLeavePrisonArea )

end
addEvent( "prison:OnPlayerJailed", true )
addEventHandler( "prison:OnPlayerJailed", root, OnPlayerJailed )


--Игрок освобожден из тюрьмы
function OnPlayerReleased()

    --Выключаем првоерку на выход из камеры
    removeEventHandler("onClientPreRender", root, CheckForEscape)

    --Уничтожаем маркер выхода на работу
    DestroyToJobMarker()

    --Уничтожаем маркеры работы
    DestroyJobsMarkers()

    --Отключаем проверку на побег
    removeEventHandler ("onClientColShapeHit", PRISON_AREA, onEnterPrisonArea )
    removeEventHandler("onClientColShapeLeave", PRISON_AREA, onLeavePrisonArea )


    localPlayer.dimension = 0
    localPlayer.interior  = 0

    UI_Elements.bg:destroy()
    UI_Elements.bg = nil

    CURRENT_JAIL_DATA = {}

end
addEvent( "prison:OnPlayerReleased", true )
addEventHandler( "prison:OnPlayerReleased", root, OnPlayerReleased )


-- Игрок пошёл на работу, отрабает чек позиции
function OnPlayerGoToJob()
    localPlayer.dimension = 0
    localPlayer.interior  = 0
    removeEventHandler( "onClientPreRender", root, CheckForEscape )
end


-- Игрок вернулся в камеру, возвращаем проверку позиции
function OnPlayerGoToJailRoom()
    removeEventHandler( "onClientPreRender", root, CheckForEscape )
    addEventHandler( "onClientPreRender", root, CheckForEscape )
end

-- Игрок заключен в камеру сотрудником ФСИН
function OnPlayerJailedByFsin( data )

    CURRENT_JAIL_DATA.jail_id = data.jail_id
    CURRENT_JAIL_DATA.room_id = data.room_id
    CURRENT_JAIL_DATA.room_element = data.room_element
    CURRENT_JAIL_DATA.room_element.position = Vector3( data.x, data.y, data.z )
	CURRENT_JAIL_DATA.room_element.dimension = data.dimension
	CURRENT_JAIL_DATA.room_element.interior = data .interior

    OnPlayerGoToJailRoom()

    --Уничтожаем маркер выхода на работу в старой камере
    DestroyToJobMarker()

    --Создаем маркер выхода на работу в новой камере
    CreateToJobMarker( CURRENT_JAIL_DATA.jail_id, CURRENT_JAIL_DATA.room_id )

end
addEvent( "prison:OnPlayerJailedByFsin", true )
addEventHandler( "prison:OnPlayerJailedByFsin", root, OnPlayerJailedByFsin )

-- Проверка на выход из камеры во время заключения
function CheckForEscape( )
    if isElementWithinColShape( localPlayer, CURRENT_JAIL_DATA.room_element ) then return end
    localPlayer:Teleport( CURRENT_JAIL_DATA.room_element.position, CURRENT_JAIL_DATA.room_element.dimension, CURRENT_JAIL_DATA.room_element.interior )
end