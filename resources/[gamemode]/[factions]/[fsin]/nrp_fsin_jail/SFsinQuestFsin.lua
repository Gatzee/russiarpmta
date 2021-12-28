OFF_CONTROLS = { "fire", "aim_weapon", "next_weapon", "previous_weapon", "enter_exit", "enter_passenger" }

--Игроки посажены в машину ФСИН для перевозки в тюрьму
function onServerImrisonJailedPlayers_handler( jailedPlayers )

	for _, v in pairs( jailedPlayers ) do
		--Отключаем контролы, чтобы заключенный ничего не сделал во время перевозки
		OffPlayerControls( v.player )
		local pDataToSave =
		{
			time_left = v.data.time_left,
			jail_id = v.data.jail_id,
			reason = v.data.reason,
			admin = v.data.admin,
		}
		v.player:SetPermanentData( "prison_data", pDataToSave )
		v.player:setData( "jailed", "move_prison" )
    end

end
addEvent( "onServerImrisonJailedPlayers", true )
addEventHandler( "onServerImrisonJailedPlayers", root, onServerImrisonJailedPlayers_handler )

--Игроки доставлены в тюрьму ФСИН
function onServerJailedPlayerDeliveredToPrison_handler( jailedPlayers )

	for _, v in pairs( jailedPlayers ) do
		if isElement( v.player ) and v.player:getData("jailed") == "move_prison" then
            JailPlayer( v.data.admin, v.player, v.data.jail_id, v.data.time_left, v.data.reason )
            for _, control in pairs( OFF_CONTROLS ) do
                toggleControl( v.player, control, true )
            end
		end
	end

end
addEvent( "onServerJailedPlayerDeliveredToPrison", true )
addEventHandler( "onServerJailedPlayerDeliveredToPrison", root, onServerJailedPlayerDeliveredToPrison_handler )

function onJailedPlayerWastedWithDelivered_handler( player )

    player:removeFromVehicle()

    local playerJailData = player:GetPermanentData( "prison_data" )

    local iJailID = playerJailData.jail_id
	local iRoomID = JailGetFreeRoomID( iJailID )
	local pJailData = PRISON_ROOM_POSITIONS[ iJailID ]
	local pRoomData = pJailData.rooms[ iRoomID ]

	table.insert( pRoomData.players, player )

	JAILED_PLAYERS_LIST[ player ] =
	{
		jail_id = iJailID,
		room_id = iRoomID,
		room_element = pRoomData.element,
		time_left = playerJailData.time_left,
		reason = playerJailData.reason,
		admin = playerJailData.admin,
	}

	player:setData( "jailed", "is_prison" )

	triggerClientEvent( player, "prison:OnPlayerJailed", player, JAILED_PLAYERS_LIST[ player ], getRealTime().hour )

end
addEvent( "onJailedPlayerWastedWithDelivered", true )
addEventHandler( "onJailedPlayerWastedWithDelivered", root, onJailedPlayerWastedWithDelivered_handler )

function OffPlayerControls( player )
    for _, v in pairs( OFF_CONTROLS ) do
        toggleControl( player, v, false )
    end
end