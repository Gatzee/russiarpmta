loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShVehicle" )
Extend( "ShVehicleConfig" )

--[[local showComponents = false
bindKey("f3", "down", function() showComponents = not showComponents end)


addEventHandler("onClientRender", root,
    function()

        if (showComponents) then
            for _, veh in pairs(getElementsByType("vehicle", root, true)) do
                for compname in pairs(veh:getComponents()) do
                    local x, y = getScreenFromWorldPosition(veh:getComponentPosition(compname, "world"))

                    if (x) then
                        dxDrawText(compname, x, y, 0, 0, tocolor(255, 255, 255))
                    end
                end 
            end
        end

    end
)]]

math_max = math.max

function UpdateVehicleComponents( vehicle )
	local vehicle = vehicle or source
	local vehicle_model = getElementModel( vehicle )
	local components = VEHICLE_CONFIG[ vehicle_model ] and VEHICLE_CONFIG[ vehicle_model ].custom_tuning

	if components then
		local external_tuning = getElementData( vehicle, "tuning_external" ) or { }
		for component_name, components_list in pairs( components ) do
			local component_id = TUNING_IDS[ component_name ]
			local is_installed = false
			for n, data in pairs( components_list ) do
				if type( data ) == "table" then
					local this_part_is_installed = external_tuning[ component_id ] == n
					is_installed = is_installed or this_part_is_installed
					setVehicleComponentVisible( vehicle, data.component, this_part_is_installed )
				end
			end
			if not is_installed and components_list[ 1 ].stock then
				setVehicleComponentVisible( vehicle, components_list[1].component, true )
			end
		end
	else
		local vehicle_variant = vehicle:GetVariant()
		local hidden_components = VEHICLE_CONFIG[ vehicle_model ] and VEHICLE_CONFIG[ vehicle_model ].variants[ vehicle_variant ].hidden_components
		if hidden_components then
			for k, v in pairs( hidden_components ) do
				setVehicleComponentVisible( vehicle, k, false )
			end
		end

		local stock_components = VEHICLE_CONFIG[ vehicle_model ] and VEHICLE_CONFIG[ vehicle_model ].variants[ vehicle_variant ].stock_components
		if stock_components then
			for k, v in pairs( stock_components ) do
				setVehicleComponentVisible( vehicle, k, true )
			end
		end
	end
end
addEvent( "onVehicleRequestTuningRefresh", true )
addEventHandler( "onVehicleRequestTuningRefresh", root, UpdateVehicleComponents )

local STREAMED_VEHICLES = { }

addEventHandler("onClientResourceStart", resourceRoot, function()
	for k,v in pairs(getElementsByType("vehicle", root, true)) do
		UpdateVehicleComponents( v )
		STREAMED_VEHICLES[ v ] = true
		addEventHandler( "onClientElementDataChange", v, onClientElementDataChange_handler )
		addEventHandler( "onClientElementStreamOut", v, onClientElementStreamOut_handler )
		addEventHandler( "onClientElementDestroy", v, onClientElementStreamOut_handler )
	end
end)

local VEHICLE_DOORS = {}

function onClientElementDataChange_handler( key, oldData, newData )
	if key == "tuning_external" then
		UpdateVehicleComponents( source )
	elseif key == "cd_state_0" then
		table.insert(VEHICLE_DOORS, { vehicle = source, door = 0, started = getTickCount(), state = newData } )
		
		removeEventHandler("onClientPreRender", root, UpdateCustomDoorsRotation)
		addEventHandler("onClientPreRender", root, UpdateCustomDoorsRotation)
	elseif key == "cd_state_1" then
		table.insert(VEHICLE_DOORS, { vehicle = source, door = 1, started = getTickCount(), state = newData } )
		
		removeEventHandler("onClientPreRender", root, UpdateCustomDoorsRotation)
		addEventHandler("onClientPreRender", root, UpdateCustomDoorsRotation)
	end
end

addEventHandler("onClientElementStreamIn", root, function( )
	if getElementType(source) ~= "vehicle" then return end
	if STREAMED_VEHICLES[ source ] then return end
	UpdateVehicleComponents( source )
	STREAMED_VEHICLES[ source ] = true
	addEventHandler( "onClientElementDataChange", source, onClientElementDataChange_handler )
	addEventHandler( "onClientElementStreamOut", source, onClientElementStreamOut_handler )
	addEventHandler( "onClientElementDestroy", source, onClientElementStreamOut_handler )
end)

function onClientElementStreamOut_handler( )
	removeEventHandler( "onClientElementDataChange", source, onClientElementDataChange_handler )
	removeEventHandler( "onClientElementStreamOut", source, onClientElementStreamOut_handler )
	removeEventHandler( "onClientElementDestroy", source, onClientElementStreamOut_handler )
	removeEventHandler("onClientPreRender", root, UpdateCustomDoorsRotation)
	STREAMED_VEHICLES[ source ] = nil
end

function VehicleDoorListIsEmpty()
	if not next( VEHICLE_DOORS ) then
		removeEventHandler("onClientPreRender", root, UpdateCustomDoorsRotation)
	end
end

function UpdateCustomDoorsRotation()
	local tick = getTickCount()
	for k = #VEHICLE_DOORS, 1, -1 do
		local v = VEHICLE_DOORS[ k ]
		local vehicle = v.vehicle
		if isElement( vehicle ) and isElementStreamedIn( vehicle ) and not v.break_stop then
			local fRatio = ( tick - v.started ) / 1000
			if v.state == 0 then
				fRatio = math_max( 1 - fRatio, 0 )
				if fRatio == 0 then v.break_stop = true end
			end

			if fRatio <= 1 and fRatio >= 0 then
				local conf = VEHICLE_CONFIG[ vehicle.model ]
				local doors_config = conf and conf.customDoors

				local this_door_conf = doors_config and doors_config[v.door]
				if this_door_conf then
					for i, door_name in pairs( this_door_conf.names ) do
						local def_x, def_y, def_z = this_door_conf.def_x or 0, this_door_conf.def_y or 0, this_door_conf.def_z or 0
						setVehicleComponentRotation( vehicle, door_name, def_x + this_door_conf.x*fRatio, def_y + this_door_conf.y*fRatio, def_z + this_door_conf.z*fRatio )
					end
				else
					table.remove(VEHICLE_DOORS, k)
					VehicleDoorListIsEmpty()
				end
			else
				table.remove(VEHICLE_DOORS, k)
				VehicleDoorListIsEmpty()
			end
		else
			table.remove(VEHICLE_DOORS, k)
			VehicleDoorListIsEmpty()
		end
	end
end

---------------------------------------------------------------------------
------------ Временный фикс кривого освещения приборов у весты ------------
---------------------------------------------------------------------------

local SHADER_CODE = [[
	technique tec0
	{
		pass P0
		{
			MaterialDiffuse = float4(0,0,0,0);
		}
	}
]]

local HIDE_SHADER = dxCreateShader( SHADER_CODE, 0, 20, false, "vehicle" )

if HIDE_SHADER then
	addEventHandler( "onClientPlayerVehicleEnter", localPlayer, function( vehicle )
		if vehicle.model == 6564 then
			engineApplyShaderToWorldTexture( HIDE_SHADER, "gauges_on", vehicle )
		end
	end)
end