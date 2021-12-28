loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SVehicle" )

function CheckDetailAssemblyVehicle( detail_id, player )
	if player:InventoryInventoryGetItemCount( IN_ASSEMBLY_VEHICLE, { detail_id } ) > 0 then return true end
	return false
end

function CheckActiveAssemblyVehicleByPlace( place, player )
	if not CheckActiveAssemblyVehicle( ) then return false end
	
	local detail_id = DETAILS_PLACE[ place ]
	if not detail_id or not isElement( player ) then return end

	return not CheckDetailAssemblyVehicle( detail_id, player ) and not player:GetPermanentData( "assembly_vehicle_passed" )
end

function GiveAssemblyVehicleDetail( place, player, delay )
	local detail_id = DETAILS_PLACE[ place ]
	if not detail_id or not isElement( player ) then return end
	if getRealTimestamp( ) < OFFER_CONFIG.start_date then return end

	if CheckDetailAssemblyVehicle( detail_id, player ) or not CheckActiveAssemblyVehicle( ) or player:GetPermanentData( "assembly_vehicle_passed" ) then
		player:GiveMoney( OFFER_CONFIG.cost_soft, "sale", "assembly_vehicle" )
		setTimer( function( )
			if not isElement( player ) then return end
			player:InfoWindow( "У тебя уже есть эта деталь, поэтому ты получаешь компенсацию " .. format_price( OFFER_CONFIG.cost_soft ) .. "р." )
		end, delay or 0, 1 )
		return 
	end

	player:InventoryAddItem( IN_ASSEMBLY_VEHICLE, { detail_id } )

	setTimer( function( )
		if not isElement( player ) then return end
		player:ShowInfo( "Полученная деталь в твоем инвентаре" )
	end, delay or 0, 1 )

	SendElasticGameEvent( player:GetClientID( ), "assembly_vehicle_take", 
		{ 
			part_name = DETAILS_INFO[ detail_id ].type,
			place_name = place,
			part_num = player:InventoryGetItemCount( IN_ASSEMBLY_VEHICLE ),
		} 
	)
	return true
end

function BuyAssemblyVehicleDetails_handler( )
	if not CheckActiveAssemblyVehicle( ) then return end
	if client:GetPermanentData( "assembly_vehicle_passed" ) then return end

	local count_detail = client:InventoryGetItemCount( IN_ASSEMBLY_VEHICLE )
	if count_detail >= 6 then
		client:ShowError( "Ты уже собрал все детали" )
		return
	end

	local cost = ( 6 - count_detail ) * OFFER_CONFIG.cost_hard

	if client:TakeDonate( cost, "sale", "assembly_vehicle" ) then
		for detail_id, info in pairs( DETAILS_INFO ) do
			if not CheckDetailAssemblyVehicle( detail_id, client ) then
				client:InventoryAddItem( IN_ASSEMBLY_VEHICLE, { detail_id } )
			end
		end

		SendElasticGameEvent( client:GetClientID( ), "assembly_vehicle_purchase", 
			{ 
				part_count = count_detail,
				spend_sum = cost,
			} 
		)

		client:ShowInfo( "Ты получил все детали" )

		triggerClientEvent( client, "ShowOfferAssemblyVehicle", resourceRoot, true )
	else
		client:ShowError( "Недостаточно денег" )
	end
end
addEvent( "BuyAssemblyVehicleDetails", true )
addEventHandler( "BuyAssemblyVehicleDetails", resourceRoot, BuyAssemblyVehicleDetails_handler )

function GiveAssemblyVehicleVehicle_handler( )
	if not CheckActiveAssemblyVehicle( ) and count_detail ~= 6 and not CheckActiveAssemblyVehicle( true ) then return end
	if client:GetPermanentData( "assembly_vehicle_passed" ) then return end

	client:SetPermanentData( "assembly_vehicle_passed", true )
	client:SetPrivateData( "assembly_vehicle_passed", true )
	client:InventoryRemoveItem( IN_ASSEMBLY_VEHICLE )

	CreateAssemblyVehicle( client, OFFER_CONFIG.vehicle.params )

	SendElasticGameEvent( client:GetClientID( ), "assembly_vehicle_finish", 
		{ 
			vehicle_id = tostring( OFFER_CONFIG.vehicle.params.model ),
			vehicle_name = OFFER_CONFIG.vehicle.name,
			vehicle_cost = OFFER_CONFIG.vehicle.cost,
		} 
	)
end
addEvent( "GiveAssemblyVehicleVehicle", true )
addEventHandler( "GiveAssemblyVehicleVehicle", resourceRoot, GiveAssemblyVehicleVehicle_handler )

function GetFreePlaceAssemblyVehicle( )
	local points = OFFER_CONFIG.vehicle_points
	local vehicle_point
	for _, point in ipairs( points ) do
		if not isAnythingWithinRange( Vector3( point ), 2 ) then 
			vehicle_point = point
			break 
		end
	end
	return vehicle_point and vehicle_point or OFFER_CONFIG.vehicle_reserve_point
end

addEventHandler( "onPlayerReadyToPlay", root, function ( )
	if not source:HasFinishedTutorial( ) then return end
	if source:GetPermanentData( "assembly_vehicle_passed" ) then
		source:SetPrivateData( "assembly_vehicle_passed", true )
		return
	end

	local after_finish
	if not CheckActiveAssemblyVehicle( ) then 
		local count_detail = source:InventoryGetItemCount( IN_ASSEMBLY_VEHICLE )
		if count_detail == 6 and CheckActiveAssemblyVehicle( true ) then
			after_finish = true
		elseif count_detail > 0 then
			source:InventoryRemoveItem( IN_ASSEMBLY_VEHICLE )
			return
		else
			return
		end
	end

	source:SetPrivateData( "assembly_vehicle_start", after_finish and OFFER_CONFIG.after_start_date or OFFER_CONFIG.start_date ) 
	source:SetPrivateData( "assembly_vehicle_finish", after_finish and OFFER_CONFIG.after_finish_date or OFFER_CONFIG.finish_date ) 

	triggerClientEvent( source, "ActivateAssemblyVehicle", resourceRoot )
end, true, "high+9999999" )

-- Тестирование
if SERVER_NUMBER > 100 then
	addCommandHandler( "reset_assembly_vehicle_all", function( player )
		player:InventoryRemoveItem( IN_ASSEMBLY_VEHICLE )
		player:SetPermanentData( "assembly_vehicle_passed", nil )
		player:SetPrivateData( "assembly_vehicle_passed", nil )
		iprint( "reset_assembly_vehicle_all" )
	end )

	addCommandHandler( "give_assembly_vehicle_detail", function( player, cmd, detail_id )
		local detail_id = detail_id and tonumber( detail_id ) or nil
		if not detail_id or not DETAILS_INFO[ detail_id ] or CheckDetailAssemblyVehicle( detail_id, player ) then return end
		player:InventoryAddItem( IN_ASSEMBLY_VEHICLE, { tonumber( detail_id ) } )
		iprint( "give_assembly_vehicle_detail" )
	end )
end

-- TEMP
--[[ setTimer( function( )
	local source = GetPlayer( 9 )

	if not source:HasFinishedTutorial( ) then return end
	if source:GetPermanentData( "assembly_vehicle_passed" ) then
		source:SetPrivateData( "assembly_vehicle_passed", true )
		return
	end

	local after_finish
	if not CheckActiveAssemblyVehicle( ) then 
		local count_detail = source:InventoryGetItemCount( IN_ASSEMBLY_VEHICLE )
		if count_detail == 6 and CheckActiveAssemblyVehicle( true ) then
			after_finish = true
		elseif count_detail > 0 then
			source:InventoryRemoveItem( IN_ASSEMBLY_VEHICLE )
			return
		else
			return
		end
	end

	source:SetPrivateData( "assembly_vehicle_start", after_finish and OFFER_CONFIG.after_start_date or OFFER_CONFIG.start_date ) 
	source:SetPrivateData( "assembly_vehicle_finish", after_finish and OFFER_CONFIG.after_finish_date or OFFER_CONFIG.finish_date ) 

	triggerClientEvent( source, "ActivateAssemblyVehicle", resourceRoot )
end, 2000, 1 )

setTimer( function( )
	local player = GetPlayer( 9 )
	local vehicle = player.vehicle

	local dimension = player:GetUniqueDimension( )
	local free_point = GetFreePlaceAssemblyVehicle( )


	player:SetPrivateData( "give_assembly_vehicle", true )
	setVehicleOverrideLights( vehicle, 2 )

	vehicle:SetParked( false, OFFER_CONFIG.vehicle_position, OFFER_CONFIG.vehicle_rotation )
	player:setDimension( dimension )
	vehicle:setDimension( dimension )
	player:warpIntoVehicle( vehicle, 0 )

	triggerClientEvent( player, "StartSceneGiveActiveAssemblyVehicle", resourceRoot, vehicle )

	setTimer( function( player, vehicle, free_point )
		vehicle:setPosition( free_point.x, free_point.y, free_point.z )
		player:warpIntoVehicle( vehicle, 0 )
		player:setDimension( 0 )
		vehicle:setDimension( 0 )
		player:SetPrivateData( "give_assembly_vehicle", false )
	end, 5000, 1, player, vehicle, free_point )

end, 2000, 1, player, vehicle ) ]]
-- TEMP