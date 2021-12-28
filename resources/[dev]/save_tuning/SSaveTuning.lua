loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SVehicle" )

function GetTuningData( vehicle )
	local r, g, b = vehicle:getColor( true )
	return {
		color = { r, g, b },
		headlights_color = { vehicle:GetHeadlightsColor( ) },
		windows_color = vehicle:GetWindowsColor( ),
		installed_vinyls = vehicle:GetVinyls( ),
		neon_data = vehicle:GetNeon( ),
		tuning_external = vehicle:GetExternalTuning( ),
		hydraulics = vehicle:GetHydraulics( ) and "yes" or nil,
		height_level = vehicle:GetHeightLevel( ),
		wheels = vehicle:GetWheels( ),
		wheels_width = { vehicle:GetWheelsWidth( ) },
		wheels_offset = { vehicle:GetWheelsOffset( ) },
		wheels_camber = { vehicle:GetWheelsCamber( ) },
	}
end

addCommandHandler( "save_tuning", function( player )
	local vehicle = player.vehicle or player.contactElement

	if not isElement( vehicle ) or vehicle.type ~= "vehicle" then
		player:ShowError( "Ошибка!\nВы должны быть в/на машине" )
		return
	end

	local result, data = pcall( GetTuningData, vehicle )

	if not result then
		Debug( data, 1 )
		player:ShowError( "Ошибка!" )
		return
	end

	triggerClientEvent( player, "SaveDataToClipboard", player, data )
	player:ShowInfo( "Скопировано в буфер обмен" )
end )

addEvent( "ApplyTuning", true )
addEventHandler( "ApplyTuning", resourceRoot, function( config )
	local player = client
	local vehicle = player.vehicle or player.contactElement

	if not isElement( vehicle ) or vehicle.type ~= "vehicle" then
		player:ShowError( "Ошибка!\nВы должны быть в/на машине" )
		return
	end
			
	vehicle:SetExternalTuning( config.tuning_external )
	
	if config.wheels and config.wheels ~= 0 then
		vehicle:SetWheels( config.wheels )
	end

	vehicle:SetWheelsWidth( unpack( config.wheels_width or { } ) )
	vehicle:SetWheelsOffset( unpack( config.wheels_offset or { } ) )
	vehicle:SetWheelsCamber( unpack( config.wheels_camber or { } ) )

	if config.wheels_color then
		vehicle:SetWheelsColor( unpack( config.wheels_color ) )
	end

	if config.height_level and config.height_level ~= 0 then
		vehicle:SetHeightLevel( config.height_level )
	end

	vehicle:SetHydraulics( config.hydraulics )

	if config.color then
		vehicle:SetColor( unpack( config.color ) )
	end

	if config.headlights_color then
		vehicle:SetHeadlightsColor( unpack( config.headlights_color ) )
	end

	if config.windows_color then
		vehicle:SetWindowsColor( unpack( config.windows_color ) )
	end

	config.vinyls = config.vinyls or config.installed_vinyls
	if config.vinyls and next( config.vinyls ) then
		vehicle:SetVinyls( config.vinyls )
		setElementData( vehicle, "vehicle_vinyl_data", { vinyls = config.vinyls, color = { vehicle:getColor( true ) } } )
	end

	config.neon = config.neon or config.neon_data
	if config.neon and next( config.neon ) then
		vehicle:SetNeon( config.neon )
	end
end )