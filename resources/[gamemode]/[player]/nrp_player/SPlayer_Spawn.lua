addEvent( "onPlayerAnySpawn" )

SERVER_DATA = { 101, 'BETA 2.0'}

INTRO_DATA =
	{
		m_vecPosition = Vector3( -2.413086,-828.331055,22.02593 ),
		m_pCamera = {
			vecPosition = Vector3(-93, -866, 50),
			vecLookAt = Vector3(-6.8, -830, 15),
			fRoll = 0,
			fFov = 70,
		},
		m_fRotation	= 15.0,
		m_iInterior	= 0,
		m_iDimension = 99,
		m_fHealth = 100.0,
}
		
SPAWN_DATA = {
		m_vecPosition = Vector3(  1948.864, -444.032, 60.585 ),

		m_iMoney = 10000,
		m_fHealth = 100.0,
		m_fRadius = 2,
}
		
RESPAWN_DATA = {
	m_vecPosition = Vector3( -2.413086, -1688.331055, 22.02593 ),
	m_fRotation   = 50.0,
	m_iInterior   = 0,
	m_iDimension  = 0,
}

SPAWNED_NORMALLY    = 1
SPAWNED_VIA_INTRO   = 2
SPAWNED_VIA_RESPAWN = 3

SPAWN_FIX_TIMERS = { }

DEFAULT_DEATH_CALORIES = 60

-- Шаг 1: Сообщение о готовности, вызов спавна
function onPlayerVerifyReadyToSpawn_Callback_handler( )
	-- Чистим лишнее говно
	Cleanup( client )

	-- Сообщаем всем ресурсом о готовности
	client:SetInGame( true )
	triggerEvent( "onPlayerCompleteLogin", client )

	-- Если игрок всё еще существует
	if isElement( client ) then
		-- Спавним игрока
		onPlayerCompleteLogin_spawnHandler( client )

		-- Сохраняем данные по таймеру
		CreateSaveTimerForPlayer( client )
	end
end
addEvent( "onPlayerVerifyReadyToSpawn_Callback", true )
addEventHandler( "onPlayerVerifyReadyToSpawn_Callback", root, onPlayerVerifyReadyToSpawn_Callback_handler )

-- Шаг 2: Непосредственный спавн
function onPlayerCompleteLogin_spawnHandler( player, respawn_request )
    local player = player or client or source
    if not isElement( player ) then return end

    local data = PLAYER_DATA[ player ]

    local intro = data.intro == "Yes"
	local should_enter_urgent_military

    local spawn_mode
    
    local vec_position = Vector3( data.x, data.y, data.z )
    local rotation     = data.rotation or 0
    local interior     = data.interior or 0
    local dimension    = data.dimension or 0
    local health       = data.health or 100
    local armor        = data.armor or 0
    local weapons      = data.weapons and type( data.weapons ) == "table" and data.weapons or {}

    local skin = data.skins and data.skins.s1 or data.skin
	
	local money      = data.money
	local donate     = data.donate or 0
	local coins_default = data[LOCKED_KEY].coins_default or 0
	local gold_coins = data[LOCKED_KEY].coins_gold or 0

    if intro then
		vec_position = SPAWN_DATA.m_vecPosition
		money        = SPAWN_DATA.m_iMoney
		dimension    = player:GetUniqueDimension( )
		rotation     = 0
		interior     = 0

		spawn_mode = SPAWNED_VIA_INTRO
    else
		if respawn_request then
			if type( respawn_request ) == "table" then
				-- Кастомные позиции
				vec_position = respawn_request.position or Vector3( respawn_request.x, respawn_request.y, respawn_request.z )
				rotation     = respawn_request.rotation or 0
				interior     = respawn_request.interior or 0
				dimension    = respawn_request.dimension or 0
			else
				-- Дефолтные позиции
				vec_position = RESPAWN_DATA.m_vecPosition
				rotation     = RESPAWN_DATA.m_fRotation or 0
				interior     = RESPAWN_DATA.m_iInterior or 0
				dimension    = RESPAWN_DATA.m_iDimension or 0
			end
            spawn_mode = SPAWNED_VIA_RESPAWN

		else
			local init_spawn_in_home = player:GetPermanentData( "init_spawn_in_home" )
			-- У игрока включена настройка спавна в доме или он спал внутри на кровати
			if init_spawn_in_home ~= false or player:GetPermanentData( "sleep_timestamp" ) then

				local current_apart_info, current_viphouse

				--Проверка на последнюю посещённую квартиру, спавн в ней если женат на владельце или сам владелец
				local last_visited_apartment = player:GetPermanentData( "last_visited_apart" )
				if last_visited_apartment and player:HasAccessToHouse( last_visited_apartment.id, last_visited_apartment.number ) then
					current_apart_info = last_visited_apartment
				end

				-- аналогично для viphouse, если квартира не найдена
				if not current_apart_info then
					local last_visited_viphouse = player:GetPermanentData( "last_visited_viphouse" )
					if last_visited_viphouse and player:HasAccessToHouse( 0, last_visited_viphouse.id ) then
						current_viphouse = last_visited_viphouse.id
					end
				end

				-- пробуем спавнить в випдоме, затем в квартире
				if not current_apart_info and not current_viphouse then
					if init_spawn_in_home ~= false then
						local player_apartments = player:getData( "apartments" ) or {}
						local player_viphouse_ids = player:getData( "viphouse" ) or {}

						if #player_viphouse_ids > 0 then
							current_viphouse = player_viphouse_ids[ 1 ]

						elseif #player_apartments > 0 then
							current_apart_info = player_apartments[ 1 ]
						end
					-- else
						-- Если игрок спал в доме с отключенной настройкой спавна в доме и у него уже нет доступа к этому дому (был продан за долги/партнер продал)
						-- то оставляем vec_position как есть, и он заспавнится у входа этого дома (т.к. vec_position = last_tp_position)
					end
				end

				if current_apart_info then
					local class_info = APARTMENTS_CLASSES[ APARTMENTS_LIST[ current_apart_info.id ].class ]
					if class_info and class_info.exit_position then
						vec_position = Vector3( class_info.exit_position )
						interior     = class_info.interior
						dimension    = 5000 + current_apart_info.id * 100 + current_apart_info.number
					end

				elseif current_viphouse then
					local info = VIP_HOUSES_LIST[current_viphouse].spawn_position
					if not info and VIP_HOUSES_LIST[current_viphouse].apartments_class then
						local class = VIP_HOUSES_LIST[current_viphouse].apartments_class and VIP_HOUSES_LIST[current_viphouse].apartments_class or ( VIP_HOUSES_LIST[current_viphouse].village_class or 1 )
						local class_info = APARTMENTS_CLASSES[ class ]
						if class_info and class_info.exit_position then
							info = {
								x = class_info.exit_position.x,
								y = class_info.exit_position.y,
								z = class_info.exit_position.z,
								interior = class_info.interior,
								dimension = 5000 + current_viphouse,
							}
						end
					end

					if info then
						vec_position = Vector3( info.x, info.y, info.z )
						interior     = info.interior or 0
						dimension    = info.dimension or 0
					end
				end
			end

            spawn_mode = SPAWNED_NORMALLY
		end
		
		if player:IsOnUrgentMilitary() then
			local resource = getResourceFromName( "nrp_urgent_military_ui" )
			if resource and getResourceState( resource ) == "running" then
				local urgent_military = player:IsInUrgentMilitaryBase() or data.dimension == URGENT_MILITARY_DIMENSION
				if urgent_military or ( getRealTime().timestamp - ( data.last_date or 0 ) ) >= 30 * 60 then
					should_enter_urgent_military = true
				end
			end
		end
	end

	-- Респавн в точке интро если проблема с позицией
	if not vec_position or isZeroCoord( vec_position.x or 0, vec_position.y or 0, vec_position.z or 0, 20 ) or ( vec_position.z > 400 and ( interior or 0 ) == 0 ) then
		local last_pos = player:GetPermanentData( "last_tp_position" )
		if not respawn_request then
			if last_pos then
				vec_position = Vector3( last_pos )
				interior     = 0
				dimension    = 0
			else
				vec_position = SPAWN_DATA.m_vecPosition:AddRandomRange( 2 )
				rotation     = SPAWN_DATA.m_fRotation
				interior     = SPAWN_DATA.interior
				dimension    = SPAWN_DATA.dimension
			end
		end
	end

	local initial_spawn = spawn_mode ~= SPAWNED_VIA_RESPAWN
	local skin = skin or data.skin

	spawnPlayer( player, vec_position, rotation, skin, interior, dimension )

	if initial_spawn then
		-- Установка базовых параметров
		player:SetNickName( data.nickname )
		--player:SetMoney( money )
		--player:SetDonate( donate, "Spawn", "NRPDszx5x" )
		
		player:SetBatchPrivateData( { 
			_srv        = SERVER_DATA,
			_alevel     = data.accesslevel,
			_coins_default = coins_default,
			_coins_gold = gold_coins
		} )

		player:GiveExp( 0 )
		for i, v in pairs( weapons ) do
			player:GiveWeapon(  v[ 1 ], v[ 2 ] )
		end
		player:SetHP( health )
		setPedArmor( player, armor )

		--triggerEvent( "ReadyInventoryServerside", player, data.items or { } )
		triggerEvent( "onPlayerReadyToPlay", player )

		if should_enter_urgent_military then player:EnterOnUrgentMilitaryBase( ) end
	end

	if spawn_mode == SPAWNED_VIA_INTRO then
		triggerEvent( "onPlayerStartTutorialRequest", player )
	else
		setCameraTarget( player, player )
		player:Teleport( nil, nil, nil, spawn_mode == SPAWNED_NORMALLY and 5000 or 2000 ) -- include delay
	end

	vec_position = player.position -- убираем из дебага случаи, когда игрока спавнит в КПЗ или на срочке в triggerEvent( "onPlayerReadyToPlay", player )
	player:setData( "_spawn_tick", getTickCount( ), false )
	triggerClientEvent( player, "onClientPlayerNRPSpawn" , player, spawn_mode, spawn_mode == SPAWNED_NORMALLY and vec_position:totable( ) or nil )
	triggerEvent( "onPlayerAnySpawn", player, spawn_mode )
end

function onPlayerWasted_handler( )
	local player = source
	if not player:IsInGame() then return end

	-- Возможность перехвата функции
	triggerEvent( "onPlayerPreWasted", player )
	if wasEventCancelled() then return end

	player:SetCalories( DEFAULT_DEATH_CALORIES )

	-- Смерть на 1 уровне
	if player:GetLevel() <= 1 then
		local spawn_data = {
			position  = SPAWN_DATA.m_vecPosition:AddRandomRange( 2 ),
			rotation  = SPAWN_DATA.m_fRotation,
			interior  = SPAWN_DATA.interior,
			dimension = SPAWN_DATA.dimension,
		}
		
		onPlayerCompleteLogin_spawnHandler( player, spawn_data )
	else
	-- Обычная смерть
		triggerClientEvent( player, "ShowDeathCountdown", player, player:GetDeathCounter() )
		triggerEvent( "onPlayerShowDeathCountdown", player )
	end
end
addEvent( "onPlayerPreWasted", true )
addEventHandler( "onPlayerWasted", root, onPlayerWasted_handler )


CARTEL_SPAWN_LOCATIONS = { 
	Vector3( { x = -1967.528, y = 658.892 + 860, z = 18.485 } ),
	Vector3( { x = 1939.400, y = -2243.308 + 860, z = 30.343 } ),
}

function OnPlayerHospitalRespawnRequest_handler( )
	local player = client
	if not isElement( player ) then return end
	local cartel_id = player:GetClanCartelID()

	if player:getData( "jailed" ) == "is_prison" then
		local spawn_data = exports.nrp_fsin_jail:GetFsinPlayerData( player, true )
		onPlayerCompleteLogin_spawnHandler( player, spawn_data )
		player:SetCalories( DEFAULT_DEATH_CALORIES )
		player:SetHP( 20 )
	
	elseif cartel_id and CARTEL_SPAWN_LOCATIONS[ cartel_id ] then
		local position = CARTEL_SPAWN_LOCATIONS[ cartel_id ]
		local spawn_data = {
			position  = position:AddRandomRange( 2 ),
			rotation  = 0,
			interior  = 0,
			dimension = 0,
		}

		onPlayerCompleteLogin_spawnHandler( player, spawn_data )
		player:SetCalories( 100 )
		player:SetHP( 100 )

	else
		local hospital = exports.nrp_hospitals:getClosestHospital( player.position )
		local spawn_data = exports.nrp_hospitals:getRandomSpawn_Exported( hospital )
		spawn_data.position = spawn_data.position:AddRandomRange( 1.5 )
		onPlayerCompleteLogin_spawnHandler( player, spawn_data )
		player:SetCalories( DEFAULT_DEATH_CALORIES )
		player:SetHP( player:GetPermanentData( "has_medbook" ) and 75 or 60 )
	end
end
addEvent( "OnPlayerHospitalRespawnRequest", true )
addEventHandler( "OnPlayerHospitalRespawnRequest", root, OnPlayerHospitalRespawnRequest_handler )

function onPlayerChangeInitSpawn_handler( init_spawn_in_home )
	source:SetPermanentData( "init_spawn_in_home", init_spawn_in_home )
end
addEvent( "onPlayerChangeInitSpawn", true )
addEventHandler( "onPlayerChangeInitSpawn", root, onPlayerChangeInitSpawn_handler )

function isZeroCoord( x, y, z, dist )
	local dist = dist or 5
	return  x <= dist and x >= -dist and
		    y <= dist and y >= -dist and
            z <= dist and z >= -dist 
end



----------------------------------------------
-- Чекаем, есть ли баги со спавном

local LAST_DEBUG_TS = 0
addEvent( "onPlayerSpawnFailed", true )
addEventHandler( "onPlayerSpawnFailed", resourceRoot, function( spawn_pos, pos, frozen, on_spawn )
	if LAST_DEBUG_TS < os.time( ) then
		LAST_DEBUG_TS = os.time( ) + 60
		local player = client
		SendToLogserver( "spawn position bug", {
			file_short = "SPlayer_Spawn.lua",
			level = 3,
			client_id = player:GetClientID(),
			on_spawn = on_spawn,
			spawn_pos = spawn_pos,
			pos_C = pos,
			pos_S = { player.position.x, player.position.y, player.position.z, player.interior, player.dimension },
			frozen_C = frozen,
			frozen_S = player.frozen,
			after_ticks = getTickCount( ) - ( player:getData( "_spawn_tick" ) or 0 ),
		} )
	end
end )