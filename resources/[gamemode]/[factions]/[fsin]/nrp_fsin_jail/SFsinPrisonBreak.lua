--Игрок сбежал с тюрьмы( прошло 15 минут )
function OnPlayerLeavePrisonArea()

	client:ShowInfo("Вы сбежали из тюрьмы")

	local pData = JAILED_PLAYERS_LIST[ client ]
	local pRoomData = PRISON_ROOM_POSITIONS[ pData.jail_id ].rooms[ pData.room_id ]
	for k,v in pairs(pRoomData.players) do
		if v == client then
			table.remove( pRoomData.players, k )
			break
		end
	end

	JAILED_PLAYERS_LIST[ client ] = nil	

	client:ClearWanted()
	client:SetPermanentData("prison_data", {})

	removeElementData( client, "jailed" )

	if client:IsOnUrgentMilitary() then
		client:EnterOnUrgentMilitaryBase()
	end

end
addEvent("prison:OnPlayerLeavePrisonArea", true)
addEventHandler("prison:OnPlayerLeavePrisonArea", root, OnPlayerLeavePrisonArea)


--Игрок вышел с территории тюрьмы
function OnPlayerStartLeavePrisonArea()
	client:AddWanted( "3.1", 1, true )
	client:SetPrivateData( "prison_break", true )
	DropJailQuests( client, "Вы сбежали из тюрьмы" )
	if JAILED_PLAYERS_LIST[ client ] then
		JAILED_PLAYERS_LIST[ client ].prison_break = true
	end
end
addEvent("prison:OnPlayerStartLeavePrisonArea", true)
addEventHandler("prison:OnPlayerStartLeavePrisonArea", root, OnPlayerStartLeavePrisonArea)

-- Игрок попытался сбежать после 18:00-12:00
function OnPlayerStartLeavePrisonAreaNight_handler(  )
	if JAILED_PLAYERS_LIST[ client ] then
		
		local pData = JAILED_PLAYERS_LIST[ client ]
		local pJailData = PRISON_ROOM_POSITIONS[ pData.jail_id ]
		local pRoomData = pJailData.rooms[ pData.room_id ]

		client:removeFromVehicle()
		setElementInterior( client, pRoomData.interior or pJailData.interior )
		setElementDimension( client, pRoomData.dimension or pJailData.dimension )

		local vecPositionBias = Vector3( math.random( -pRoomData.size * 0.15, pRoomData.size * 0.15), math.random( -pRoomData.size * 0.15, pRoomData.size * 0.15), 0 )
		local tPosition = Vector3( pRoomData.x, pRoomData.y, pRoomData.z )	+ vecPositionBias
		setElementPosition( client, tPosition )

		triggerClientEvent( client, "prison:OnPlayerJailedByFsin", client,
		{
			x = tPosition.x, y = tPosition.y, z = tPosition.z,
			dimension = pRoomData.dimension or pJailData.dimension,
			interior = pRoomData.interior or pJailData.interior,
			room_element = pRoomData.element,
			jail_id = pData.jail_id,
			room_id = pData.room_id,
		}, getRealTime().hour )

		BlockGoToJobs( client, 15 * 60 )

	end
end
addEvent("prison:OnPlayerStartLeavePrisonAreaNight", true)
addEventHandler("prison:OnPlayerStartLeavePrisonAreaNight", root, OnPlayerStartLeavePrisonAreaNight_handler )

--Игрок вернулся на территорию тюрьмы после побега
function OnPlayerResetLeavePrisonArea()
	if JAILED_PLAYERS_LIST[ client ] then
		JAILED_PLAYERS_LIST[ client ].prison_break = false
		local add_time = GetTotalJailTime( client )
		JAILED_PLAYERS_LIST[ client ].time_left = JAILED_PLAYERS_LIST[ client ].time_left + add_time
		triggerClientEvent( client, "prison:OnClientRefreshJailTime", client, JAILED_PLAYERS_LIST[ client ].time_left )
		client:ClearWanted()

		local pDataToSave =
		{
			time_left = JAILED_PLAYERS_LIST[ client ].time_left,
			jail_id   = JAILED_PLAYERS_LIST[ client ].jail_id,
			reason 	  = JAILED_PLAYERS_LIST[ client ].reason,
			admin 	  = JAILED_PLAYERS_LIST[ client ].admin,
			block_go_to_jobs = JAILED_PLAYERS_LIST[ client ].block_go_to_jobs or false,
		}
		client:SetPermanentData("prison_data", pDataToSave)
		client:setData( "jailed", "is_prison" )
	end
end
addEvent("prison:OnPlayerResetLeavePrisonArea", true)
addEventHandler("prison:OnPlayerResetLeavePrisonArea", root, OnPlayerResetLeavePrisonArea)