Import( "ShVehicle" )

Vehicle.GetProperties = function( self )
	return self:getData("properties") or {}
end

Vehicle.GetProperty = function( self, key )
	return self:GetProperties()[key]
end

Vehicle.SetVariant = function( self, variant )
	--return setVehicleModelVariant( self, variant - 1 )
	return true
end

Vehicle.SetFuel = function( self, fuel )
	local fuel = fuel == "full" and ( self:GetMaxFuel() or 100 ) or fuel
	setElementData( self, "fFuel", fuel, false )
end

Vehicle.SetNumberPlate = function( self, text )
	setElementData( self, "_numplate", text, false )
end

Vehicle.ApplyNumberPlateColor = function( self, hex )
	local numplate = self:GetNumberPlate( ):gsub( "#%x%x%x%x%x%x:", "" )
	if utf8.len( hex ) >= 6 then
		local numplate_new = "#" .. hex:gsub( "#", "" ) .. ":" .. numplate
		setElementData( self, "_numplate", numplate_new, false )
	else
		setElementData( self, "_numplate", numplate, false )
	end
end

Vehicle.SetMileage = function ( self, mileage )
	local old_mileage = self:GetMileage( )
	setElementData( self, "fMileage", mileage, false )
end

Vehicle.SetWindowsColor = function( self, r, g, b, a )
	local r, g, b, a = r or 0, g or 0, b or 0, a or 120
	setElementData( self, "_wincolor", { r, g, b, a }, false )
end

Vehicle.SetColor = Vehicle.setColor
Vehicle.SetHeadlightsColor = Vehicle.ApplyHeadlightsColor
Vehicle.SetHydraulics = Vehicle.ApplyHydraulics
Vehicle.SetWheels = Vehicle.ApplyWheels
Vehicle.SetHeightLevel = Vehicle.ApplyHeightLevel

Vehicle.GetWheels = function( self )
	local wheels = getVehicleUpgradeOnSlot( self, 12 )
	return wheels and wheels > 0 and wheels
end

Vehicle.SetWheelsWidth = function( self, front, rear )
	self:setData( "_wheels_w", { front, rear }, false )
end

Vehicle.GetWheelsWidth = function( self )
	local values = self:getData( "_wheels_w" )
	return values and values[ 1 ] or 0, values and values[ 2 ] or 0
end

Vehicle.SetWheelsOffset = function( self, front, rear )
	self:setData( "_wheels_o", { front, rear }, false )
end

Vehicle.GetWheelsOffset = function( self )
	local values = self:getData( "_wheels_o" )
	return values and values[ 1 ] or 0, values and values[ 2 ] or 0
end

Vehicle.SetWheelsCamber = function( self, front, rear )
	self:setData( "_wheels_c", { front, rear }, false )
end

Vehicle.GetWheelsCamber = function( self )
	local values = self:getData( "_wheels_c" )
	return values and values[ 1 ] or 0, values and values[ 2 ] or 0
end

Vehicle.SetWheelsColor = function( self, r, g, b )
	setElementData( self, "_wheels_color", { r or 255, g or 255, b or 255 }, false )
end

Vehicle.GetWheelsColor = function( self )
	local r, g, b = unpack( getElementData( self, "_wheels_color" ) or { 255, 255, 255 } )
	return r, g, b
end

Vehicle.GetHydraulics = function( self )
	local hydraulics = getVehicleUpgradeOnSlot( self, 9 )
	return hydraulics == 1087
end

-- Внешний тюнинг - компоненты
Vehicle.SetExternalTuning = function( self, list )
	setElementData( self, "tuning_external", list, false )
end

Vehicle.GetExternalTuning = function( self )
	return getElementData( self, "tuning_external" ) or { }
end

Vehicle.SetExternalTuningValue = function( self, key, value )
	local tuning = self:GetExternalTuning( )
	tuning[ key ] = value
	self:SetExternalTuning( tuning )
end

Vehicle.GetExternalTuningValue = function( self, key )
	return self:GetExternalTuning( )[ key ]
end

Vehicle.SetWindowsColor = function(self, r, g, b, a)
	local r = math.ceil(r or 0)
	local g = math.ceil(g or 0)
	local b = math.ceil(b or 0)
	local a = math.ceil(a or 120)
	if r == 0 and g == 0 and b == 0 and a == 120 then
		sync = false
	end
	setElementData( self, "_wincolor", {r, g, b, a}, false )
end

Vehicle.StartRecord = function(self, name)
	exports.nrp_vehicle_record:StartRecord(self, name)
end

Vehicle.EndRecord = function(self)
	exports.nrp_vehicle_record:EndRecord()
end

Vehicle.ping = function( self )
	triggerServerEvent( "PingVehicle", self )
end


------------------------------------------
-- 	   Функционал работы с винилами	    --
------------------------------------------

local SHADER_RAW = [[
		texture tTexture;

		technique tech
		{
			pass p0
			{
				Texture[0] = tTexture;
			}
		}
	]]

Vehicle.ApplyVinyls = function( self, vinyl_list, vehicle_color )
	self:ResetVinyls()

	if VINYL_FACTION_VEHICLES[ getElementModel( self ) ] then
		setVehiclePaintjob( self, 0 )
	end
	setVehicleColor( self, 255, 255, 255 )

	local shader = dxCreateShader( SHADER_RAW, 1, MAX_VINYL_DISTANCE, false, "vehicle" )
	if shader then
		local texture = dxCreateRenderTarget( MAX_VINYL_SIZE, MAX_VINYL_SIZE )
		if texture then
			dxSetRenderTarget( texture, true )

			dxDrawRectangle ( 0, 0, MAX_VINYL_SIZE, MAX_VINYL_SIZE, tocolor( vehicle_color[ 1 ], vehicle_color[ 2 ], vehicle_color[ 3 ], 255 ) )
			for _, vinyl in pairs( vinyl_list ) do
				local vinyl_img = vinyl[ P_IMAGE ]
				local layer = vinyl[ P_LAYER_DATA ]

				if not TEXTURE_LIST[ vinyl_img ] then
					TEXTURE_LIST[ vinyl_img ] = {}
					TEXTURE_LIST[ vinyl_img ].texture = dxCreateTexture( ":nrp_vinyls/img/" .. vinyl_img .. ".dds", "dxt3", false, "clamp" )
				end
				TEXTURE_LIST[ vinyl_img ].ticks = getTickCount()

				local ratio = MAX_VINYL_SIZE / 1024
				local width, height = dxGetMaterialSize( TEXTURE_LIST[ vinyl_img ].texture  )
				width, height = math.floor( width * layer.size * ratio ), math.floor( height * layer.size * ratio )
				
				if layer.mirror then
					dxDrawImage( layer.x * ratio + width / 2, layer.y * ratio - height / 2, width * -1, height, TEXTURE_LIST[ vinyl_img ].texture, layer.rotation, 0, 0, layer.color or 0xFFFFFFFF )
				else
					dxDrawImage( layer.x * ratio - width / 2, layer.y * ratio - height / 2, width, height, TEXTURE_LIST[ vinyl_img ].texture, layer.rotation, 0, 0, layer.color or 0xFFFFFFFF )
				end
			end

			dxSetRenderTarget()

			dxSetShaderValue( shader, "tTexture", texture )
			for i, v in pairs( VINYL_TEXTURE_NAMES ) do
				engineApplyShaderToWorldTexture( shader, v, self )
			end
			
			if not REFRESH_TEXTURE_TIMER then
				REFRESH_TEXTURE_TIMER = setTimer( function()
					for k, v in pairs( TEXTURE_LIST ) do
						if getTickCount() - v.ticks > 300000 then
							destroyElement( v.texture )
							TEXTURE_LIST[ k ] = nil
						end
					end
				end, 300000, 0 )
			end

			setElementData( self, "vehicle.shader_data", 
			{ 
				shader = shader, 
				vinyl_list = vinyl_list, 
				texture = texture, 
				default_color = vehicle_color 
			}, false )

			--iprint("VINYL_ADD")
		else
			destroyElement( shader )
		end
	end
end

Vehicle.GetVinylShaderData = function( self )
	return getElementData( self, "vehicle.shader_data" )
end

Vehicle.ResetVinyls = function( self )
	local shader_data = getElementData( self, "vehicle.shader_data" )
	if VINYL_FACTION_VEHICLES[ getElementModel( self ) ] then
        setVehiclePaintjob( self, 3 )
    end
	if shader_data then
		setVehicleColor( self, unpack( shader_data.default_color ) )

		if isElement( shader_data.shader ) then
			for i, v in pairs( VINYL_TEXTURE_NAMES ) do
				engineRemoveShaderFromWorldTexture( shader_data.shader, v, self )
			end
			destroyElement( shader_data.shader )
		end

		if isElement( shader_data.texture ) then
			destroyElement( shader_data.texture )
		end

		setElementData( self, "vehicle.shader_data", nil, false )
		
		--iprint("VINYL_REMOVED")
	end
end

Vehicle.DoesVehicleHaveVinyls = function( self )
	return getElementData( self, "vehicle.shader_data" ) and true or false
end

Vehicle.IsNormalVehicle = function( self )
	return VEHICLE_CONFIG[ self.model ] and ( not VEHICLE_CONFIG[ self.model ].is_airplane and not VEHICLE_CONFIG[ self.model ].is_boat and not VEHICLE_CONFIG[ self.model ].is_moto )
end

-------------------------------------------------------------------

Vehicle.GetNeon = function( self )
	return self:getData( "ne_i" ) or 0
end

Vehicle.SetNeon = function( self, neon_image )
	self:setData( "ne_i", neon_image, false )
end