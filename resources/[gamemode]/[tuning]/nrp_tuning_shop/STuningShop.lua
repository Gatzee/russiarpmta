loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "ShNeons" )
Extend( "ShClans" )

function onTuningShopJoinRequest_handler( )
    local vehicle = client.vehicle

    if not vehicle then return end

    local owner_id = vehicle:GetOwnerID()
    local user_id  = client:GetUserID()
    local rights   = client:GetAccessLevel( )
    local is_admin = rights >= ACCESS_LEVEL_HEAD_ADMIN
    local model = vehicle.model

    if vehicle:GetSpecialType( ) then
        client:ShowError( "Данный транспорт нельзя тюнинговать" )
        return
    end

    if not VEHICLE_CONFIG[ model ] or VEHICLE_TYPE_BIKE[ model ] or VEHICLE_TYPE_QUAD[ model ] then
        client:ShowError( "Вы не можете тюнинговать данный транспорт" )
        return
    end
    
    --Камаз / картинг / мопед
    if model == 573 or model == 571 or model == 468 then
        client:ShowError( "Данный транспорт нельзя тюнинговать" )
        return
    end

    if vehicle == client:getData( "quest_vehicle" ) then
        client:ShowError( "Нельзя заехать в тюнинг на квестовой машине" )
        return
    end

    if not owner_id and not is_admin then
        client:ShowError( "Ты не можешь тюнинговать временный транспорт" )
        return
	end
	
    if vehicle:GetPermanentData( "temp_timeout" ) and vehicle:GetPermanentData( "temp_timeout" ) > 0 then
        client:ShowError( "Ты не можешь тюнинговать временный транспорт" )
        return
	end

    if owner_id ~= user_id and not is_admin then
		client:ShowError( "Вы не можете тюнинговать чужой транспорт" )
		return
	end

	if vehicle:getData( "rentable" ) then
		client:ShowError( "Вы не можете тюнинговать арендованный автомобиль" )
		return
	end

	local occupants = vehicle:getOccupants()
	if #occupants > 1 then
		client:ShowInfo( "Перед входом в тюнинг-ателье вы должны высадить других игроков" )
		return
	end

	local faction = vehicle:GetFaction( )
	if faction and faction > 0 then
		client:ShowError( "Нельзя тюнить фракционный транспорт" )
		return
	end

	if model == 530 or model == 455 then
		client:ShowError( "Ты шо, езжай работать, начальнику расскажу" )
		return
	end
    
    if client:GetJobClass( ) == JOB_CLASS_TAXI_PRIVATE and client:GetOnShift( ) then
		client:ShowError( "Закончи смену в такси чтобы тюнинговать машину!" )
		return
    end
    
    if client:GetBlockInteriorInteraction() then
        client:ShowInfo( "Вы не можете войти во время задания" )
        return false
    end

    local data = client:GetBatchPermanentData( "vehicle_access_sub_id", "vehicle_access_sub_time" )
    local is_black_tuning_enabled = ( data.vehicle_access_sub_id or 0 ) == vehicle:GetID( )
    is_black_tuning_enabled = is_black_tuning_enabled and client:IsPremiumActive()

    local pos = Vector3( 0, 0, 100 ) + client.position

    local neon = vehicle:GetNeon( )

    -- Отсылаемая информация для клиента
    local conf = {
        position_tbl            = { pos.x, pos.y, pos.z },
        vehicle                 = vehicle,
        color                   = { getVehicleColor( vehicle, true ) },
        element_data            = getAllElementData( vehicle ),
        parts                   = vehicle:GetParts( ),
        default_stats           = { vehicle:GetStats( ) },
        now_stats               = { vehicle:GetStats( vehicle:GetParts( ) ) },
        wheels                  = vehicle:GetWheels(),
        wheels_color            = { vehicle:GetWheelsColor() },
        hydraulics              = vehicle:GetHydraulics(),
        headlights_color        = { vehicle:GetHeadlightsColor() },
        height_level            = vehicle:GetHeightLevel(),
        all_parts               = client:GetTuningParts( ),
        subscription            = client:IsPremiumActive(),
        is_subscription_vehicle = is_black_tuning_enabled,
        variant                 = vehicle:GetVariant( ),
        available_vinyls        = client:GetVinyls( vehicle:GetTier() ),
        installed_vinyls        = vehicle:GetVinyls(),
        neon_image              = neon and neon.neon_image,
    }
    
    setVehicleLocked( vehicle, true ) -- закрытие машины автоматом
    triggerClientEvent( client, "ShowTuningShopUI", client, true, conf )

    client:setData( "tuning_vehicle", vehicle, false )
    client:SetPrivateData( "tuning_active", true )
    client:CloseInfo( )
end
addEvent( "onTuningShopJoinRequest", true )
addEventHandler( "onTuningShopJoinRequest", root, onTuningShopJoinRequest_handler )

function onTuningShopLeaveRequest_handler( )
    if client.vehicle then
		onServerCompleteApplyVinyls_hander( client.vehicle:GetVinyls(), client )
    end
    triggerClientEvent( client, "ShowTuningShopUI", client, nil )
    client:setData( "tuning_vehicle", false, false )
    client:SetPrivateData( "tuning_active", nil )
end
addEvent( "onTuningShopLeaveRequest", true )
addEventHandler( "onTuningShopLeaveRequest", root, onTuningShopLeaveRequest_handler )

-- Всякие полезные функции
function Player.RefreshPartsInventory( self )
    triggerClientEvent( self, "onPartsInventoryUpdate", resourceRoot, self:GetTuningParts( ) )
end

function Player.RefreshInstalledParts( self )
    local vehicle = self.vehicle
    triggerClientEvent( self, "onPartsListUpdate", resourceRoot, vehicle:GetParts( ), { vehicle:GetStats( vehicle:GetParts( ) ) } )
end

function Player.FindPart( self, tier, id )
    local parts = self:GetTuningParts( tier )

    for idx, partID in pairs( parts ) do
        if partID == id then
            return idx
        end
    end
end

--------------------------------------------
-- Вспомогательный функционал для винилов --
--------------------------------------------

function GetVinylSellPrice( vinyl )
    local price = vinyl[ P_PRICE ]
    if vinyl[ P_PRICE_TYPE ] == "hard" then
        price = math.floor( price * 1000 * 0.2 )
    else
        price = math.floor( price * 0.2 )
    end
    return price
end

function Player.FindVinyl( self, vinyl )
    local vinyl = table.copy( vinyl )
    local vinyls = self:GetVinyls()
    for i, v in pairs( vinyls ) do
        if CompareVinyl( v, vinyl ) then
            v[ P_LAYER ] = vinyl[ P_LAYER ]
            return v, i
        end
    end
end

function Vehicle.FindVinyl( self, vinyl )
    local vinyl = table.copy( vinyl )
    local vinyls = self:GetVinyls( self:GetTier() )
    for i, v in pairs( vinyls ) do
        if CompareVinyl( v, vinyl ) then
            v[ P_LAYER ] = vinyl[ P_LAYER ]
            return v, i
        end
    end
end

function Player.RefreshVinylsInventory( self )
    triggerClientEvent( self, "onVinylsInventoryUpdate", resourceRoot, self:GetVinyls( self.vehicle:GetTier() ) )
end

function Player.RefreshInstalledVinyls( self, inventory_update )
    local vehicle = self.vehicle
    if not isElement( vehicle ) then return end
    
    local vinyl_list = vehicle:GetVinyls()
    setElementData( vehicle, "vehicle_vinyl_data", { vinyls = vinyl_list, color = { vehicle:getColor( true ) } } )

    triggerClientEvent( self, "onVinylsListUpdate", resourceRoot, vinyl_list, { getVehicleColor( vehicle, true ) }, inventory_update and self:GetVinyls(vehicle:GetTier()) )

    return true
end

--------------------------------------------