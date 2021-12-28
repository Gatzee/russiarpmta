loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShUtils" )
Extend( "SPlayer" )
Extend( "SInterior" )

local FLOWERS_COUNT = 7

PLAYERS_FLOWERS = { }
FLOWERS_POSITIONS = LoadXMLIntoArrayXYZPositions( "packages_0.map" )

if fileExists( "flowers.nrp" ) then
    local file = fileOpen( "flowers.nrp" )
    local file_contents = fileRead( file, fileGetSize( file ) )
    PLAYERS_FLOWERS = file_contents and fromJSON( file_contents ) or { }
    fileClose( file )
end

function onPlayerCompleteLogin_handler( player )
	local player = isElement( player ) and player or source

	if not IsEventActive() then
		player:InventoryRemoveItem( IN_1SEPTEMBER_FLOWER )
		return false
	end

	local user_id = "uid" .. player:GetUserID()

	if not player:GetPermanentData("1september_flowers_collected") then
		local inventory_flowers = player:InventoryGetItemCount( IN_1SEPTEMBER_FLOWER )
		local current_flowers = PLAYERS_FLOWERS[ user_id ]

		if not current_flowers then
			local possible_locations = table.copy( FLOWERS_POSITIONS )
			local new_flowers = { }
			for i = 1, ( FLOWERS_COUNT - inventory_flowers_count ) do
				local random_number = math.random( 1, #possible_locations )
				local random_position = possible_locations[ random_number ]
				table.remove( possible_locations, random_number )
				table.insert( new_flowers, random_position )
			end
			PLAYERS_FLOWERS[ user_id ] = new_flowers
			current_flowers = new_flowers
		end

		if inventory_flowers_count >= FLOWERS_COUNT then
			ParseFlowers( player, true )
			current_flowers = { }
		end

		if next( current_flowers ) then
			player:triggerEvent( "OnEventFlowersLoad", player, current_flowers )
		end
	end

	if player:GetPermanentData( "1september_quest_timer" ) then
		Timer( TimerQuest_handler, 60000, 0, player )
	end

	local iLastTask = 0
	for k,v in pairs( EVENT_TASKS ) do
		if v.get_progress( player ) < v.progress_max then
			iLastTask = k
			break
		end
	end

	if iLastTask > 0 then
		if EVENT_TASKS[iLastTask].on_start then
			EVENT_TASKS[iLastTask].on_start( player )
		end
	end

	if not player:GetPermanentData("1september_quest_completed") then
		setTimer(function( pPlayer )
			if not isElement(pPlayer) then return end
			OnPlayerRequest1SeptemberUI( pPlayer )
		end, 3000, 1, player)
	end
end
addEvent( "onInventoryInitializationFinished" )
addEventHandler( "onInventoryInitializationFinished", root, onPlayerCompleteLogin_handler )

function OnEventFlowerCollected_handler( position )
	if not client then return end

    local user_id = "uid" .. client:GetUserID()
    table.remove( PLAYERS_FLOWERS[ user_id ], position )
	client:InventoryAddItem( IN_1SEPTEMBER_FLOWER, nil, 1 )

	local inventory_flowers_count = client:InventoryGetItemCount( IN_1SEPTEMBER_FLOWER )

	if inventory_flowers_count < FLOWERS_COUNT then
		client:InfoWindow("Осталось собрать "..(FLOWERS_COUNT - inventory_flowers_count).." роз")
	end

	ParseFlowers( client )

	if fileExists( "flowers.nrp" ) then fileDelete( "flowers.nrp" ) end
    local file = fileCreate( "flowers.nrp" )
    fileWrite( file, toJSON( PLAYERS_FLOWERS, true ) )
    fileClose( file )
end
addEvent( "OnEventFlowerCollected", true )
addEventHandler( "OnEventFlowerCollected", root, OnEventFlowerCollected_handler )

function ParseFlowers( player, force )
    local user_id = "uid" .. player:GetUserID()
	if #PLAYERS_FLOWERS[ user_id ] == 0 or force then
		player:InfoWindow( "Ты собрал все цветы! Отправляйся в магазин и собери их в букет!" )
		PLAYERS_FLOWERS[ user_id ] = { }

		OnPlayerEventTaskComplete( player, 1 )
        return true
    end
end

function onResourceStart_handler()
	if IsEventActive() then
	    Timer(
	        function()
	            for i, v in pairs( getElementsByType( "player" ) ) do
	                if v:IsInGame() then
	                    onPlayerCompleteLogin_handler( v )
	                end
	            end
	        end
	    , 1000, 1 )

    	CreateEventMarkers()
    else
    	if getRealTime().timestamp < EVENT_STARTS then
    		local iTimeLeft = EVENT_STARTS - getRealTime().timestamp + 10

    		setTimer(onResourceStart_handler, iTimeLeft * 1000, 1)
    	end
    end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function onResourceStop_handler()
    if fileExists( "flowers.nrp" ) then fileDelete( "flowers.nrp" ) end
    local file = fileCreate( "flowers.nrp" )
    fileWrite( file, toJSON( PLAYERS_FLOWERS, true ) )
    fileClose( file )
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_handler )

function OnPlayerRequest1SeptemberUI( pPlayer )
	local pPlayer = isElement(pPlayer) and pPlayer or client

	local time_passed = 0
	if pPlayer:GetPermanentData( "1september_quest" ) then
		time_passed = pPlayer:GetPermanentData( "1september_quest_timer" ) or 12*60
	end

	local hours = math.floor( time_passed / 60 )

	local pData = {}
	for k,v in pairs(EVENT_TASKS) do
		pData[k] = v.get_progress( pPlayer )
	end

	triggerClientEvent( pPlayer, "ShowUI_Event", resourceRoot, true, pData )
end
addEvent("OnPlayerRequest1SeptemberUI", true)
addEventHandler("OnPlayerRequest1SeptemberUI", root, OnPlayerRequest1SeptemberUI)

function OnPlayerEventTaskComplete( pPlayer, iTask )
	if EVENT_TASKS[iTask].on_complete then
		EVENT_TASKS[iTask].on_complete( pPlayer )
	end

	if EVENT_TASKS[iTask+1] and EVENT_TASKS[iTask+1].on_start then
		EVENT_TASKS[iTask+1].on_start( pPlayer )
	end

	triggerEvent( "On1SeptemberStepCompleted", pPlayer, iTask )
end

local CONST_TIMES_TO_INFO = {
	[60] = "Букет будет готов через";
	[120] = "Букет будет готов через";
	[180] = "Букет будет готов через";
	[240] = "Букет будет готов через";
	[270] = "Букет будет готов через";
	[CONST_TIME_TO_LEFT_REWARD] = true;
}

function TimerQuest_handler( player )
	if not isElement( player ) or not player:IsInGame( ) then
		killTimer( sourceTimer )
		return
	end

	times = player:GetPermanentData( "1september_quest_timer" )
	if not times then
		killTimer( sourceTimer )
		return
	end

	player:SetPermanentData( "1september_quest_timer", times + 1 )

	if player:GetPermanentData( "1september_flowers_collected" ) then
		local time_left = CONST_TIME_TO_LEFT_REWARD - times - 1

		if time_left <= 0 then
			player:SetPermanentData( "1september_quest_timer", nil )
			killTimer( sourceTimer )

			triggerClientEvent( player, "OnClientReceivePhoneNotification", root, {
				title = "Флорист";
				msg = "Твой букет готов, забери его из магазина!";
			} )

			OnPlayerEventTaskComplete( player, 2 )

			return
		end

		if CONST_TIMES_TO_INFO[ times ] then
			local hours = string.format( "%02d", math.floor( time_left / 60 ) )
			local minutes = string.format( "%02d", math.floor( ( time_left - hours * 60 ) ) )

			triggerClientEvent( player, "OnClientReceivePhoneNotification", root, {
				title = "Флорист";
				msg = CONST_TIMES_TO_INFO[ times ] ..
				" ".. hours .." ч. и ".. minutes .." м.";
			} )
		end
	end
end

function CreateEventMarkers()
	-- Маркер крафта букета
	local marker = { x = 189.782, y = -906.513, z = 20.983 }
	marker.color = { 180, 90, 90, 150 }
	marker.keypress = false
	marker.radius = 2

	local tpoint = TeleportPoint( marker )
	tpoint.marker:setColor( unpack( marker.color ) )

	tpoint.PreJoin = function( self, player )
		if player:getData( "current_quest" ) then
			return false
		end

		if not IsEventActive() then
			return false
		end

		if not player:GetPermanentData( "1september_quest_info" ) then
			player:SetPermanentData( "1september_quest_info", true )
			player:InfoWindow( "Принеси сюда цветы, и мы превратим их в замечательный букет!" )
		end

		if not player:GetPermanentData( "1september_quest" ) then
			return false
		end

		if player:GetPermanentData( "1september_flowers_received" ) then
			return false
		end

		local inventory_flowers_count = player:InventoryGetItemCount( IN_1SEPTEMBER_FLOWER )

		if inventory_flowers_count == 0 then
			local user_id = "uid" .. player:GetUserID()
			local current_flowers = PLAYERS_FLOWERS[ user_id ]
			if PLAYERS_FLOWERS[ user_id ] and player:GetPermanentData( "1september_flowers_collected" ) then
				if player:GetPermanentData( "1september_quest_timer" ) then
					local time_left = CONST_TIME_TO_LEFT_REWARD - player:GetPermanentData( "1september_quest_timer" )
					if time_left > 0 then
						local hours = string.format( "%02d", math.floor( time_left / 60 ) )
						local minutes = string.format( "%02d", math.floor( ( time_left - hours * 60 ) ) )

						player:ShowInfo( "Твой букет будет готов через ".. hours .." ч. и ".. minutes .." м." )
					else
						player:SetPermanentData( "1september_quest_timer", nil )
						player:SetPermanentData( "1september_flowers_received", true )
						player:InfoWindow( "Вот твой букет!" )
						OnPlayerEventTaskComplete( player, 3 )
					end
				else
					player:SetPermanentData( "1september_flowers_received", true )
					player:InfoWindow( "Вот твой букет!" )

					OnPlayerEventTaskComplete( player, 3 )
				end
				return false
			end
		end

		if inventory_flowers_count < FLOWERS_COUNT then
			local user_id = "uid" .. player:GetUserID()
			if not next( PLAYERS_FLOWERS[ user_id ] ) then
				PLAYERS_FLOWERS[ user_id ] = nil
				onPlayerCompleteLogin_handler( player )
			end

			player:ShowInfo( "Осталось собрать еще ".. ( FLOWERS_COUNT - inventory_flowers_count ) .." шт." )

			return false
		end
		return true
	end
	tpoint.PostJoin = function( self, player )
		player:InventoryRemoveItem( IN_1SEPTEMBER_FLOWER )
		player:SetPermanentData( "1september_flowers_collected", true )

		local time_passed = player:GetPermanentData( "1september_quest_timer" )
		if not time_passed then return end
		
		local iTimeLeft = CONST_TIME_TO_LEFT_REWARD - time_passed - 1
		triggerClientEvent( player, "Show1SeptemberTimer", resourceRoot, true, iTimeLeft )

		local time_left = CONST_TIME_TO_LEFT_REWARD - ( player:GetPermanentData( "1september_quest_timer" ) or 0 )
		local hours = string.format( "%02d", math.floor( time_left / 60 ) )
		local minutes = string.format( "%02d", math.floor( ( time_left - hours * 60 ) ) )

		player:InfoWindow("Замечательные розы!\nМы подготовим твой букет через ".. hours .." ч. и ".. minutes .." м.")
	end

	-- Маркер учительницы
	local marker = { x = -101.259, y = -1128.895, z = 20.802 }
	marker.color = { 0, 0, 0, 0 }
	marker.keypress = false
	marker.radius = 3

	local tpoint = TeleportPoint( marker )
	tpoint.marker:setColor( unpack( marker.color ) )

	tpoint.PreJoin = function( self, player )
		local current_quest = player:getData( "current_quest" )
		if current_quest then
			return false
		end

		if not IsEventActive() then
			return false
		end

		if not player:GetPermanentData( "1september_quest" ) then
			triggerClientEvent( player, "ShowUI_Dialog", resourceRoot, true, "start" )

			return false
		end

		if player:GetPermanentData( "1september_quest_completed" ) or not player:GetPermanentData( "1september_flowers_received" ) then
			return false
		end

		return true
	end
	tpoint.PostJoin = function( self, player )
		triggerClientEvent( player, "ShowUI_Dialog", resourceRoot, true, "finish" )
	end

	createBlipAttachedTo( tpoint.marker, 21, 2, 255, 255, 255, 255, 0, 1500 )
end

function OnPlayerFirstDialogFinished(  )
	client:SetPermanentData( "1september_quest", true )
	client:SetPermanentData( "1september_quest_timer", 0 )

	Timer( TimerQuest_handler, 60000, 0, client )
end
addEvent( "OnPlayerFirstDialogFinished", true )
addEventHandler( "OnPlayerFirstDialogFinished", resourceRoot, OnPlayerFirstDialogFinished )

function OnPlayerTookReward(  )
	if not isElement(client) then return end
	if client:GetPermanentData("1september_quest_completed") then return end

	client:GiveMoney(100000, "event_1st_september")
	client:SetPermanentData( "1september_quest_completed", true )

	OnPlayerEventTaskComplete( client, 4 )
end
addEvent( "OnPlayerTookReward", true )
addEventHandler( "OnPlayerTookReward", resourceRoot, OnPlayerTookReward )