Extend( "SVehicle" )
Extend( "ShVehicleConfig" )

ERR_VEHICLE_NOT_FOUND = "Автомобиль не найден"

function VehicleParseCommand( player, command, target_id )
    if not player:HasCommandAccess( command ) then player:outputChat( ERR_NO_ACCESS, 255, 0, 0 ) return end

    local target_vehicle = GetVehicle( tonumber( target_id ) ) or getPedOccupiedVehicle( player )
    if not isElement( target_vehicle ) then player:outputChat( ERR_VEHICLE_NOT_FOUND, 255, 0, 0 ) return end

    return target_vehicle
end

function Vehicle_Get( player, cmd, target_id )
	local pTarget = VehicleParseCommand( player, cmd, target_id )
	if pTarget then
		pTarget.position = player.position + Vector3( 2, 0, 1 ) -- vehicle get
	end
end
addCommandHandler( "vget", Vehicle_Get )

function Vehicle_Goto( player, cmd, target_id )
	local pTarget = VehicleParseCommand( player, cmd, target_id )
	if pTarget then
		player:Teleport( pTarget.position + Vector3(2,0,1), pTarget.dimension, pTarget.interior )
	end
end
addCommandHandler( "vgoto", Vehicle_Goto )

function Vehicle_Fix( player, cmd, target_id )
	local pTarget = VehicleParseCommand( player, cmd, target_id )
	if pTarget then
		pTarget:Fix()
	end
end
addCommandHandler( "fixveh", Vehicle_Fix )

function Vehicle_Flip( player, cmd, target_id )
	local pTarget = VehicleParseCommand( player, cmd, target_id )
	if pTarget then
		local _, _, rz = getElementRotation(pTarget)
		setElementRotation( pTarget, 0, 0, rz )
	end
end
addCommandHandler( "flip", Vehicle_Flip )

function Vehicle_SetColor( player, cmd, target_id, r, g, b )
	local pTarget = VehicleParseCommand( player, cmd, target_id )
	if pTarget then
		local old_r, old_g, old_b = getVehicleColor( pTarget )
		local r = tonumber(r) or old_r
		local g = tonumber(g) or old_g
		local b = tonumber(b) or old_b
		setVehicleColor( pTarget, r, g, b )
	end
end
addCommandHandler( "vsetcolor", Vehicle_SetColor )

function Vehicle_TempsetColor( player, cmd, target_id, r, g, b )
	local pTarget = VehicleParseCommand( player, cmd, target_id )
	if pTarget then
		if pTarget:GetID() > 0 then
			player:outputChat( "Установить цвет можно только на временную машину" )
			return
		end
		local old_r, old_g, old_b = getVehicleColor( pTarget )
		local r = tonumber(r) or old_r
		local g = tonumber(g) or old_g
		local b = tonumber(b) or old_b
		setVehicleColor( pTarget, r, g, b )
	end
end
addCommandHandler( "vtempsetcolor", Vehicle_TempsetColor )

function Vehicle_SetFuel( player, cmd, target_id, value )
	local pTarget = VehicleParseCommand( player, cmd, target_id )
	if pTarget then
		pTarget:SetFuel( tonumber(value) or "full" )
	end
end
addCommandHandler( "setfuel", Vehicle_SetFuel )

function Vehicle_SetFuelLoss( player, cmd, target_id, value )
	local pTarget = VehicleParseCommand( player, cmd, target_id )
	if pTarget then
		pTarget:SetFuelLoss( tonumber(value) or 1 )
	end
end
--addCommandHandler( "setfuelloss", Vehicle_SetFuelLoss )

function Vehicle_SetLocked( player, cmd, target_id )
	local pTarget = VehicleParseCommand( player, cmd, target_id )
	if pTarget then
		setVehicleLocked( pTarget, not isVehicleLocked(pTarget) )
		local bState = isVehicleLocked(pTarget)
		local sState = bState and "#dd2222закрыт" or "#22dd22открыт" 
		outputChatBox( "Автомобиль "..sState, player, 255,255,255, true )
	end
end
addCommandHandler( "vlock", Vehicle_SetLocked )

function Vehicle_SetStatic( player, cmd, target_id )
	local pTarget = VehicleParseCommand( player, cmd, target_id )
	if pTarget then
		pTarget:SetStatic( not pTarget:IsStatic() )
		local bState = pTarget:IsStatic()
		local sState = bState and "#dd2222заморожен" or "#22dd22разморожен" 
		outputChatBox( "Автомобиль "..sState, player, 255,255,255, true )
	end
end
addCommandHandler( "setstatic", Vehicle_SetStatic )

function Vehicle_SetDamageProof( player, cmd, target_id )
	local pTarget = VehicleParseCommand( player, cmd, target_id )
	if pTarget then
		pTarget.damageProof = not pTarget.damageProof
		local bState = pTarget.damageProof
		local sState = bState and "#22dd22неуязвим" or "#dd2222уязвим" 
		outputChatBox( "Автомобиль "..sState, player, 255,255,255, true )
	end
end
addCommandHandler( "vdamageproof", Vehicle_SetDamageProof )

function Vehicle_SetOwner( player, cmd, target_id, owner_id )
	local pTarget = VehicleParseCommand( player, cmd, target_id )
	if pTarget then
		local owner_id = tonumber(owner_id) or player:GetID()
		local pOwner = GetPlayer(owner_id)
		if pOwner then
			pTarget:SetOwnerPID( "p:"..pOwner:GetUserID() )
			LogSlackCommand( "%s сменил владельца %s на %s", player, pTarget, pOwner )
		else
			outputChatBox( "Игрок должен быть в сети", player, 200,50,50, true )
		end
	end
end
addCommandHandler( "vsetowner", Vehicle_SetOwner )

function Vehicle_Delete( player, cmd, target_id )
	local pTarget = VehicleParseCommand( player, cmd, target_id )
	if pTarget then
		if pTarget:GetID() > 0 then
			outputChatBox( "Удалить можно только временный автомобиль!", player, 200,50,50, true )
			return false
		end

		pTarget:DestroyTemporary()
	end
end
addCommandHandler( "vdelete", Vehicle_Delete )

function Vehicle_SpawnTemporary( player, cmd, model_id, variant_id )
	if not player:HasCommandAccess( cmd ) then player:ShowError( ERR_NO_ACCESS ) return end

	local model_id = tonumber(model_id)
	local variant_id = tonumber(variant_id) or 1

	if not model_id then
		outputChatBox( "Не указана модель автомобиля!", player, 200,50,50, true )
		return false
	end

	local x,y,z = getElementPosition(player)
	local pVehicle = Vehicle.CreateTemporary( model_id, x, y, z+1 )
	if pVehicle then
		pVehicle:SetVariant(variant_id)
		pVehicle:SetFuel("full")
		pVehicle.dimension = player.dimension
		warpPedIntoVehicle( player, pVehicle )
		pVehicle.engineState = true
		
		outputChatBox( "Автомобиль #22dd22"..pVehicle:GetShortName().."(ID:"..pVehicle:GetID()..") #ffffffуспешно создан", player, 255,255,255, true )
	else
		outputChatBox( "Ошибка создания автомобиля", player, 200,50,50, true )
	end
end
addCommandHandler( "veh", Vehicle_SpawnTemporary )

function Vehicle_PermanentAdd( player, cmd, model_id, owner_id, variant_id )
	if not player:HasCommandAccess( cmd ) then player:ShowError( ERR_NO_ACCESS ) return end

	local model_id = tonumber(model_id)
	local owner_id = tonumber(owner_id)
	local variant_id = tonumber(variant_id)

	if not model_id or not owner_id then return ERRCODE_WRONG_SYNTAX end

	local pOwner = GetPlayer( tonumber(owner_id), true )
	if not pOwner then
		outputChatBox( "Игрок должен быть в сети!", player, 200,50,50, true )
		return false
	end

	local x,y,z = getElementPosition(player)
	local conf = 
	{
		model = model_id,
		variant = (VEHICLE_CONFIG[ model_id ] and VEHICLE_CONFIG[ model_id ].variants[ variant_id ]) and variant_id or 1,
		x = x+2, 
		y = y, 
		z = z, 
		owner_pid = "p:"..owner_id, 
	}

	local result = exports.nrp_vehicle:AddVehicle(conf, true)

	if result then
		outputChatBox( "Автомобиль успешно создан", player, 255,255,255, true )
		LogSlackCommand( "%s создал автомобиль %s для %s", player, model_id, pOwner )

		SendAdminActionToLogserver(
            player:GetNickName( ) .. " выдал автомобиль " .. pOwner:GetNickName( ),
            { },
            { player, "admin" }, { pOwner, "player" }
        )
	else
		outputChatBox( "Ошибка создания автомобиля", player, 200,50,50, true )
	end
end
addCommandHandler( "vpermanentadd", Vehicle_PermanentAdd )

function Vehicle_PermanentRemove( player, cmd, target_id, reason )
	local pTarget = VehicleParseCommand( player, cmd, target_id )
	if pTarget then
		if pTarget:GetID() < 0 then
			outputChatBox( "Отобрать можно только постоянный автомобиль!", player, 200,50,50, true )
			return false
		end

		LogSlackCommand( "%s уничтожил автомобиль %s", player, pTarget )
		exports.nrp_vehicle:DestroyForever( pTarget:GetID(), reason )
		
		outputChatBox( "Автомобиль успешно уничтожен", player, 255,255,255, true )
	end
end
addCommandHandler( "vpermanentremove", Vehicle_PermanentRemove )

function Vehicle_SetNumbersColor( player, cmd, target_id, r, g, b )
	local pTarget = VehicleParseCommand( player, cmd, target_id )
	if pTarget then
		local old_number = pTarget:GetNumberPlate()
		local r = tonumber(r) or 255
		local g = tonumber(g) or 255
		local b = tonumber(b) or 255

		local new_hex = rgb2hex({r,g,b}, true)
		pTarget:SetNumberPlate( new_hex..old_number )

		LogSlackCommand( "%s изменил цвет номеров %s на %s", player, pTarget, new_hex )
		
		outputChatBox( "Цвет номеров успешно изменён", player, 255,255,255, true )
	end
end
addCommandHandler( "setnumberscolor", Vehicle_SetNumbersColor )