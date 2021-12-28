loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "Globals" )
Extend( "CVehicle" )
Extend( "CPlayer" )
Extend( "ShUtils" )

QUESTS_VEHICLES = {
	{
		model = 451;
		position = Vector3( 510.474, -1669.723, 20.416 );
		rotation = Vector3( 0, 0, 27 );
	};
	-- Армия срочка
	{
		model = 433;
		position = Vector3( -2419.350, -242.144, 20.700 );
		rotation = Vector3( 0, 0, 76 );
		dimension = URGENT_MILITARY_DIMENSION;
		non_movable = true;
	};
	{
		model = 433;
		position = Vector3( -2419.452, -261.664, 20.707 );
		rotation = Vector3( 0, 0, 104 );
		dimension = URGENT_MILITARY_DIMENSION;
		non_movable = true;
	};
	-- То же самое, но обычная армия
	{
		model = 433;
		position = Vector3( -2419.350, -242.144, 20.700 );
		rotation = Vector3( 0, 0, 76 );
	};
	{
		model = 433;
		position = Vector3( -2419.452, -261.664, 20.707 );
		rotation = Vector3( 0, 0, 104 );
	};
	-- Мед авто
	{
		model = 416;
		position = Vector3( 394.700, -2483.892, 21.222 );
		rotation = Vector3( 0, 0, 127 );
	};
	{
		model = 416;
		position = Vector3( 1937.862, -565.474, 61.016 );
		rotation = Vector3( 0, 0, 12 );
	};
	-- Делориан
	{
		model = 575;
		position = Vector3( 262.920, -2688.833, 20.8 );
		rotation = Vector3( 0, 0, 0 );
	};
}

local doc_ped = nil
local bttf_sound = nil

function onPlayerMoveQuestElements_handler( dimension )
	local dimension = dimension or localPlayer.dimension

	for i, v in pairs( QUESTS_NPC ) do
		if v.ped and not v.non_movable then
			v.ped.dimension = dimension
		end
	end

	for i, v in pairs( QUESTS_VEHICLES ) do
		if v.veh and not v.non_movable and ( v.model ~= 433 or dimension ~= URGENT_MILITARY_DIMENSION ) then
			v.veh.dimension = dimension
		end
	end

	CheckExistingQuests()
end
addEvent( "onPlayerMoveQuestElements", true )
addEventHandler( "onPlayerMoveQuestElements", root, onPlayerMoveQuestElements_handler )

function GetQuestNPC( id )
	for i, v in pairs( QUESTS_NPC ) do
		if v.id == id then
			return v
		end
	end
end

function IsLastStartedQuestFailure( quest_id )
	for k, v in pairs( LIST.available ) do
		if v.id == quest_id and (v.failed and v.failed > 0) then
			return true
		end
	end
	return false
end

function CreateQuestElements( )
	if ELEMENTS_CREATED then
		onPlayerMoveQuestElements_handler( )
		return
	end

	for i, npc in pairs(QUESTS_NPC) do
		
		npc.ped = createPed(npc.model, npc.position, npc.rotation)
		npc.ped.frozen = true
		npc.ped.interior = npc.interior or 0
		if npc.dimension == "UNIQUE_DIMENSION" then
			npc.dimension = localPlayer:GetUniqueDimension( )
		end
		npc.ped.dimension = npc.dimension or 0
		npc.ped:setData("QUESTS_NPC_ID", i, false)
		addEventHandler("onClientPedDamage", npc.ped, cancelEvent)
		addEventHandler( "onClientPlayerStealthKill", localPlayer, function( target )
			if target == npc.ped then
				cancelEvent( )
			end
		end )

		if npc.sound then
			local sound = playSound3D("sounds/".. npc.sound ..".mp3", npc.position, true)
			sound.minDistance = 10
			sound.maxDistance = 20
			sound.volume = 0.07
		end
	end

	for i, vehicle in ipairs(QUESTS_VEHICLES) do
		
		vehicle.veh = createVehicle(vehicle.model, vehicle.position, vehicle.rotation)
		vehicle.veh.dimension = vehicle.dimension or 0
		vehicle.veh.overrideLights = 2
		vehicle.veh:setColor( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
		addEventHandler("onClientVehicleDamage", vehicle.veh, cancelEvent)
		addEventHandler("onClientVehicleStartEnter", vehicle.veh, cancelEvent)

		if vehicle.model == 575 then
			vehicle.veh:setColor( 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 )
			vehicle.veh:setWheelStates( 2, 2, 2, 2 )
			vehicle.veh:SetNumberPlate( "1: " )

			doc_ped = createPed( 111, 0, 0, 0 )
			doc_ped:warpIntoVehicle( vehicle.veh )
			doc_ped.alpha = 0
		end

		vehicle.veh.frozen = true
	end

	ELEMENTS_CREATED = true

	onPlayerMoveQuestElements_handler( )
	CheckExistingQuests( )

	Timer( CheckExistingQuests, 250, 0 )
end
addEvent( "onClientPlayerNRPSpawn", true )
addEventHandler("onClientPlayerNRPSpawn", root, CreateQuestElements )

function onClientResourceStart_handler( )
	if localPlayer:IsInGame( ) then
		CreateQuestElements( )
	end
end
addEventHandler( "onClientResourceStart", resourceRoot, onClientResourceStart_handler )


function CheckExistingQuests()
	EXISTING_QUESTS = { }

	local x, y, z = getCameraMatrix( )
	local dimension = localPlayer.dimension
	local additional_height = Vector3( 0, 0, 1 )

	-- Имем NPC рядом
	local data = GetQuestInfo( )
	
	for i, npc in pairs( QUESTS_NPC ) do
		if not npc.condition or npc.condition( npc, data ) then
			if dimension == npc.ped.dimension and getDistanceBetweenPoints3D( x, y, z, npc.position ) <= 10 then
				table.insert( EXISTING_QUESTS, { npc, npc.position + additional_height } )
			end
		else
			npc.ped.dimension = localPlayer.dimension + 1
		end
	end

	-- Добавляем отрисовку если ее нет
	if #EXISTING_QUESTS > 0 and not QUESTS_RENDERER then
		addEventHandler("onClientHUDRender", root, RenderQuests )
		QUESTS_RENDERER = true

	-- Удаляем отрисовку если она не нужна и она есть
	elseif #EXISTING_QUESTS == 0 and QUESTS_RENDERER then
		removeEventHandler("onClientHUDRender", root, RenderQuests )
		QUESTS_RENDERER = nil
	end

	if isElement( doc_ped ) then
		local h, m = getTime( )
		if h > 21 or h < 3 then
			doc_ped.alpha = 60
		else
			doc_ped.alpha = 0
		end

		if not isElement( bttf_sound ) then
			if h == 0 and m == 0 then
				setPedAnimation( doc_ped, "ped", "car_tune_radio", -1, false )
				bttf_sound = playSound3D( "sounds/bttf.mp3", doc_ped.position )
			end
		end
	end
end

function RenderQuests()
	local x, y, z = getCameraMatrix()
	local cam_vector = Vector3( x, y, z )
	for i, npc in pairs( EXISTING_QUESTS ) do
		local conf = npc[ 1 ]
		local distance = ( conf.position - cam_vector ).length
		local scale = math.min( 5 / distance, 1.5 )
		local scx, scy = getScreenFromWorldPosition( npc[ 2 ] )
		if scx and scy then
			dxDrawText( conf.name, scx+1, scy+1, scx+1, scy+1, 0xff000000, scale, "default-bold", "center", "center", false, false, false, true )
			dxDrawText( conf.name, scx, scy, scx, scy, 0xffffe2a7, scale, "default-bold", "center", "center", false, false, false, true )
		end
	end
end

--[[addCommandHandler( "db", function( )
	local function outputVector( prefix, vector )
		outputConsole( ( prefix or "" ) .. "Vector3( " .. vector.x .. ", " .. vector.y .. ", " .. vector.z .. " )" )
	end
	outputConsole( "----------------" )
	outputVector( "POS: ", localPlayer.position )
	outputConsole( "POS: " .. inspect( localPlayer.position ) )
	outputVector( "ROT: ", localPlayer.rotation )
	outputConsole( "ROT: " .. inspect( localPlayer.rotation ) )

	if localPlayer.vehicle then
		outputVector( "VEH POS: ", localPlayer.vehicle.position )
		outputVector( "VEH ROT: ", localPlayer.vehicle.rotation )
	end

	local matrix = { getCameraMatrix( ) }
	outputConsole( "MATRIX: " .. table.concat( matrix, ", " ) )
end )]]