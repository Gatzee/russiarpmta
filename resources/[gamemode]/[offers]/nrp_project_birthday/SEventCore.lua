loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShUtils" )
Extend( "SPlayer" )
Extend( "SInterior" )
Extend("ShTimelib")

function LoadNextQuestStage( player )
	if IsEventActive() then
		local pData = player:GetPermanentData( EVENT_NAME ) or {}
		if pData and pData.stage and pData.stage > EVENT_COUNT then return end
		if not pData or not pData.stage then

			-- Задаем дефолтные данные для квеста, для отображения прогресса
			pData = 
			{ 
				stage = 1, 
				progresses = 
				{
					hdd_1  = { current = 0 },
					wait_1 = { current = 0 },
					hdd_2  = { current = 0 },
				},
			}
			SetQuestData( player, pData )
		end
		
        if not EVENT[ "stage_" .. pData.stage ] then return end

		if pData.stage_wait then
			pData.stage_wait = getRealTime().timestamp + pData.time_wait
			SetQuestData( player, pData )
		end

        if EVENT[ "stage_" .. pData.stage ].start == "server" then
			EVENT[ "stage_" .. pData.stage ].start_server( player, pData )
			triggerClientEvent( player, "onChangeClientStage", resourceRoot, pData )
		elseif EVENT[ "stage_" .. pData.stage ].start == "client" then
			if pData.stage_wait then
				pData.time_left = math.max( 0, pData.stage_wait - getRealTime().timestamp )
			end
			pData.progresses = nil
			triggerClientEvent( player, "onClientStartStage", resourceRoot, pData )
		end
	else
		player:InventoryRemoveItem( IN_HDD )
    end
end

function onPlayerCompleteLogin_handler( player )
	if IsEventActive() then
		player = player or source
		if player:GetPermanentData( EVENT_NAME .. "_completed" ) then return end
		LoadNextQuestStage( player )
		onPlayerRequestShowBirthdayEvent_handler( player )
	end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )

-- Запрос на отображение меню ивента
function onPlayerRequestShowBirthdayEvent_handler( player )
	player = player or client
	local pData = player:GetPermanentData( EVENT_NAME ) or {}
	if pData.stage_wait and pData.stage == 4 then
		pData.time_wait = math.max( 0, pData.stage_wait - getRealTime().timestamp )
		pData.progresses.wait_1.current = math.floor( pData.need_wait / 3600 ) - math.ceil( pData.time_wait / 3600 )
	end
	triggerClientEvent( player, "ShowUI_Event", resourceRoot, true, pData.progresses )
end
addEvent( "onPlayerRequestShowBirthdayEvent", true )
addEventHandler( "onPlayerRequestShowBirthdayEvent", root, onPlayerRequestShowBirthdayEvent_handler )

function SetNextStage( player, data )
	data.stage = data.stage + 1
	if EVENT[ "stage_" .. data.stage ] then
    	SetQuestData( player, data )
		LoadNextQuestStage( player )
	elseif data.stage > EVENT_COUNT then
		SetQuestData( player, data )
		triggerClientEvent( player, "onChangeClientStage", resourceRoot )
	end
end

function onServerPlayerStartStage_handler( data )
	local player = client or source
	local pData = player:GetPermanentData( EVENT_NAME ) or {}
    if data.stage and EVENT[ "stage_" .. data.stage ] and IsEventActive() and pData.stage == data.stage then
        EVENT[ "stage_" .. data.stage ].server( player, data )
    end
end
addEvent( "onServerPlayerStartStage", true )
addEventHandler( "onServerPlayerStartStage", root, onServerPlayerStartStage_handler )

function onServerPlayerFailStage_handler( data )
	local player = client or source
	if EVENT[ "stage_" .. data.stage ] then
		LoadNextQuestStage( player )
	end
end
addEvent( "onServerPlayerFailStage", true )
addEventHandler( "onServerPlayerFailStage", root, onServerPlayerFailStage_handler )

function SetQuestData( player, data )
	player:SetPermanentData( EVENT_NAME, data or {} )
end

-- Чекаем время старта ивента каждые сутки
function StartEventTimer()
	ExecAtTime( "00:00", function()
		if IsEventActive() then
			for k, v in pairs( getElementsByType( "player" ) ) do
				if v:IsInGame() then
					onPlayerCompleteLogin_handler( v )
				end
			end
			triggerClientEvent( "onClientCreateClientContent", resourceRoot )
		else
			setTimer( StartEventTimer, 70000, 1 )
		end
	end )
end

function onResourceStart_handler()
    EVENT_STARTS = getTimestampFromString( EVENT_STARTS )
	EVENT_ENDS = getTimestampFromString( EVENT_ENDS )
	
    if IsEventActive() then
    	setTimer( 	function()
    	    for k, v in pairs( getElementsByType( "player" ) ) do
				if v:IsInGame() then
					onPlayerCompleteLogin_handler( v )
				end
			end
		end, 1000, 1 )
	elseif getRealTimestamp() < EVENT_ENDS then
		StartEventTimer()
	end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function OnPlayerTookReward(  )
	if not isElement(client) then return end
	if client:GetPermanentData( EVENT_NAME .. "_completed" ) then return end
	
	local present_get = 0
	local pData = client:GetPermanentData( EVENT_NAME )
    if pData.type_operation == 1 then
        present_get = 75000
    elseif pData.type_operation == 2 then
        present_get = 100000
    end
	
	client:GiveMoney( present_get, "BIRTHDAY" )
	client:SetPermanentData( EVENT_NAME .. "_completed", true )
	
	-- Завершаем квест после награды
	SetNextStage( client, pData )		
	-- Аналитика
	triggerEvent( "onPlayerHbEvent", client, 8, present_get, "soft" )  
end
addEvent( "OnPlayerTookReward", true )
addEventHandler( "OnPlayerTookReward", resourceRoot, OnPlayerTookReward )

-- Сохранение времени ожидания 
function onPlayerPreLogout_handler( pPlayer )
	pPlayer = isElement( pPlayer ) and pPlayer or source
	local pData = pPlayer:GetPermanentData( EVENT_NAME )
	if pData and pData.stage_wait then
		pData.time_wait = math.max( 0, pData.stage_wait - getRealTime().timestamp )
		SetQuestData( pPlayer, pData )
	end
end
addEvent( "onPlayerPreLogout", true )
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_handler )

function onResourceStop_handler()
	for k, v in pairs( getElementsByType( "player" ) ) do
		if v:IsInGame() then
			onPlayerPreLogout_handler( v )
		end
	end
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_handler )