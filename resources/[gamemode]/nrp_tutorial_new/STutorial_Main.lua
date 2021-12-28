Extend( "SDB" )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )

-- Запрос на начало регистрации (ввод данных)
function onPlayerStartRegisterRequest_handler( )
    local player = source

	-- Перенос в измерение чтобы не видеть других игроков
	player.dimension = 994
	player:setData( "is_registering", true, false )
	triggerClientEvent( player, "onRegisterStart", root, true )
end
addEvent( "onPlayerStartRegisterRequest" )
addEventHandler( "onPlayerStartRegisterRequest", root, onPlayerStartRegisterRequest_handler )

-- Подтверждение данных регистрации
function onRegisterConfirmRequest_handler( data )
	if not client or not client:getData( "is_registering" ) or type( data.name ) ~= "string" or type( data.last_name ) ~= "string" then 
		return
    end

	data.name, data.last_name = FixWarningCharacters( data.name, data.last_name )
	
	local result, err = CheckRegistrationData( data.name, data.last_name, data.day, data.month, data.year, data.gender, data.skin )
	if not result then
		if err then client:ShowError( err ) end
		return
	end

	data.birthday = math.max( 0, os.time( { 
		year = data.year, 
		month = data.month, 
		day = data.day, 
		hour = 0, 
		min = 0, 
		sec = 0, 
	} ) )
	data.nickname = data.name .. " " .. data.last_name

	triggerEvent( "onAsyncRegisterProcess", root, client, data )
end
addEvent( "onRegisterConfirmRequest", true )
addEventHandler( "onRegisterConfirmRequest", root, onRegisterConfirmRequest_handler )

-- Начало туториала из регистрации
function onPlayerStartTutorialRequest_handler( )
	local player = source

	player.dimension = player:GetUniqueDimension( )
	player:SetPrivateData( "tutorial", true )

	triggerClientEvent( player, "onRegisterConfirm", resourceRoot )
end
addEvent( "onPlayerStartTutorialRequest" )
addEventHandler( "onPlayerStartTutorialRequest", root, onPlayerStartTutorialRequest_handler )

-- Завершение туториала
function onPlayerCompleteTutorial_handler( )
	client:SetPrivateData( "tutorial", false )
	StartFirstQuest( client )

	triggerEvent( "onPlayerSomeDo", client, "finish_tutorial" ) -- achievements
end
addEvent( "onPlayerCompleteTutorial", true )
addEventHandler( "onPlayerCompleteTutorial", root, onPlayerCompleteTutorial_handler )

function StartFirstQuest( player )
	player:PhoneNotification( { title = "Неизвестный номер", msg = "Здарова это Александр, я слышал, что ты уже выздоровел. Зайди ко мне, есть новости. Журнал квестов - кнопка F2." } )
	
	-- Выбор базового квеста. Можно изменять
	triggerEvent( "PlayeStartQuest_alexander_get_vehicle_bike", player )
end

-- Автостарт квеста получения байка при спавне
function onPlayerAnySpawn_handler( spawn_mode )
	if spawn_mode == 1 then
		if source:GetLevel( ) == 1 and source:HasFinishedBasicTutorial( ) then
			StartFirstQuest( source )
		end
	end
end
addEventHandler( "onPlayerAnySpawn", root, onPlayerAnySpawn_handler )