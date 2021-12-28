local BEDS_LIST = {}
tHospitals = {}

function onResourceStart()
	loadstring(exports.interfacer:extend("Interfacer"))()
	Extend("ShUtils")
	Extend("SPlayer")
	Extend("SInterior")

	-- Создаём госпитали
	for k,v in pairs(HOSPITALS_LIST) do
		createHospital(v)
	end

	SET("HOSPITAL_ENABLED",true)
	setElementData(root,"hospital_enabled",true)
end
addEventHandler("onResourceStart",resourceRoot,onResourceStart)

function onResourceStop()
	SET("HOSPITAL_ENABLED",false)
	setElementData(root,"hospital_enabled",false)
end
addEventHandler("onResourceStop",resourceRoot,onResourceStop)

function createBed(vecPos,rotation,iDim,iInt)
	local self = {}
	self.position = vecPos + Vector3(0,0,2)
	self.rotation = rotation
	self.owner = false
	self.dimension = iDim or 0
	self.interior = iInt or 0
	self.col = createColSphere( vecPos+Vector3(0,0,0.75), 1.5 )
	self.col.dimension = iDim or 0
	self.col.interior = iInt or 0

	self.keyHandler = function(ply)
		if ply.health >= 60 then
			ply:ShowInfo("Вы уже здоровы")
			return
		end
		if not isElement( self.owner ) then
			-- Ложимся в кровать
			self.owner = ply
			ply:SetPrivateData( "_healing", true )
			ply.position = self.position
			ply.rotation = Vector3(0,0,self.rotation)
			ply.velocity = Vector3()

			local pPlayersAround = {}
			for k,v in pairs( getElementsWithinRange(self.position, 50, "player") ) do
				if v.interior == self.interior and v.dimension == self.dimension then
					table.insert(pPlayersAround, v)
				end
			end

			local pDataToSend = 
			{
				position = { self.position.x, self.position.y, self.position.z },
				rotation = self.rotation,
				col = self.col,
			}

			triggerClientEvent( pPlayersAround, "OnClientPlayerUseHospitalBed", resourceRoot, ply, true, pDataToSend )
		elseif self.owner == ply then
			-- Встаём с кровати
			OnPlayerHospitalBedLeave( ply )
		else
			ply:ShowInfo("Эта кровать занята")
		end
	end

	addEventHandler ( "onColShapeHit", self.col, function(ply)
		if getElementType(ply) == "player" then
			if self.owner ~= ply then
				ply:ShowInfo("Нажмите Alt чтобы лечь на кровать")
			end
			bindKey(ply,"lalt","down",self.keyHandler)
		end
	end)

	addEventHandler ( "onColShapeLeave", self.col, function(ply)
		if getElementType(ply) == "player" then
			unbindKey(ply,"lalt","down",self.keyHandler)
		end

		if self.owner == ply then
			OnPlayerHospitalBedLeave( ply )
		end
	end)

	table.insert( BEDS_LIST, self )

	return self
end

function createHospital(config)
	local hospital = config
	hospital.beds = {}

	-- for k,v in pairs(config.tBeds) do
	-- 	local bed = createBed(v.position,v.rotation,config.dimension,config.interior)
	-- 	table.insert(hospital.beds,bed)
	-- end

	hospital.getRandomSpawn = function(hospital)
		for k,v in pairs(hospital.beds) do
			if not isElement( v.owner ) then
				return v
			end
		end

		-- Если нет свободной кровати
		return hospital.tDefaultRespawns[math.random(1,#hospital.tDefaultRespawns)]
	end


	-- Вход
	local entrance_config = {
		x = config.position.x, y = config.position.y + 860, z = config.position.z,
		interior = 0,
		dimension = 0,
		radius = 2,
		marker_text = "Больница",
	}
	local entrance = TeleportPoint(entrance_config)
	entrance.element:setData( "material", true, false )
	entrance:SetDropImage( { ":nrp_shared/img/dropimage.png", 255,255,255, 255, 1.55 } )
	entrance.marker:setColor(255,255,255,50)
	entrance.text = "ALT Взаимодействие"
	entrance.PreJoin = function(self, player)
		if player:GetBlockInteriorInteraction() then
			player:ShowInfo( "Вы не можете войти во время задания" )
			return false
		end
		return true
	end
	entrance.PostJoin = function(self, player)
		-- local pDataToSend = {}
		-- for k,v in pairs(hospital.beds) do
		-- 	if v.owner then
		-- 		table.insert( pDataToSend, v )
		-- 	end
		-- end
		player:CompleteDailyQuest( "np_visit_hospital" )
		player:CompleteDailyQuest( "band_get_into_hospital" )
		-- triggerClientEvent(player, "OnClientPlayerHospitalEnter", player, pDataToSend)
	end

	-- Выход
	local exit_config = {
		x = config.vecExit.x, y = config.vecExit.y, z = config.vecExit.z,
		interior = config.interior,
		dimension = config.dimension,
		radius = 1.5,
		marker_text = "Выход на улицу",
	}
	local exit = TeleportPoint(exit_config)
	exit.element:setData( "material", true, false )
	exit:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 150, 250, 255, 1.15 } )
	exit.marker:setColor( 0, 150, 250,50 )
	exit.text = "ALT Взаимодействие"
	exit.PostJoin = function(self,player)
		bFlag = player:getData( "CPlayer::m_bInHospital" )
		if bFlag then
			player:setData( "CPlayer::m_bInHospital", false )
		end

		triggerClientEvent(player, "OnClientPlayerHospitalLeave", player, pDataToSend)
		triggerEvent( "onTaxiPrivateFailWaiting", player, "Пассажир отменил заказ", "Ты зашёл в помещение, заказ в Такси отменен" )
		
		triggerClientEvent( player, "onPlayerMoveQuestElements", player )
	end

	entrance.teleport = exit
	exit.teleport = entrance

	-- for k,v in pairs(config.tNoColZones) do
	-- 	local pCol = createColSphere( v.x, v.y, v.z, v.radius )
	-- 	--iprint(getElementType(pCol), getElementType(exit.element))
	-- 	--setElementDimension(pCol, exit.colshape.dimension)
	-- 	--setElementInterior(pCol, exit.colshape.interior)
	-- 	setElementParent(pCol, exit.element)
	-- end

	table.insert(tHospitals,hospital)
end

function getClosestHospital(position,faction)
	local minDistance = math.huge
	local closest = 1
	local temp_table = {}

	if faction then
		-- Собираем фракционные больницы
		for k,v in pairs(tHospitals) do
			if v.iFaction == faction then
				table.insert(temp_table,v)
			end
		end

		-- Если у фракции нет больниц
		if #temp_table == 0 then
			for k,v in pairs(tHospitals) do
				if not v.iFaction then
					table.insert(temp_table,v)
				end
			end
		end
	else
		-- Если нет фракции - подаём обычные
		for k,v in pairs(tHospitals) do
			if not v.iFaction then
				table.insert(temp_table,v)
			end
		end
	end

	for k, hosp in pairs(temp_table) do
		local dist = position-hosp.position
		if dist.length < minDistance then
			minDistance = dist.length
			closest = k
		end
	end

	return temp_table[closest]
end


function getRandomSpawn_Exported(hospital)
	-- Проверка на свободные позиции
	for k, v in pairs( hospital.beds ) do
		if not isElement( v.owner ) and #getElementsWithinColShape( v.col, "player" ) <= 0 then
			return v
		end
	end
	-- Если нет свободной кровати
	return hospital.tDefaultRespawns[math.random(1,#hospital.tDefaultRespawns)]
end

function OnPlayerHospitalBedLeave( pPlayer )
	local pPlayer = pPlayer or client

	pPlayer:SetPrivateData( "_healing", false )

	local pPlayersAround = {}
	for k,v in pairs( getElementsWithinRange(pPlayer.position, 50, "player") ) do
		if v.interior == pPlayer.interior and v.dimension == pPlayer.dimension then
			table.insert(pPlayersAround, v)
		end
	end

	for k,v in pairs(BEDS_LIST) do
		if v.owner == pPlayer then
			v.owner = false
		end
	end

	triggerClientEvent( pPlayersAround, "OnClientPlayerUseHospitalBed", resourceRoot, pPlayer, false )
end
addEvent("OnPlayerHospitalBedLeave", true)
addEventHandler("OnPlayerHospitalBedLeave", root, OnPlayerHospitalBedLeave)
