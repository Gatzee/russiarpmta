
loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SVehicle" )
Extend( "Globals" )
Extend( "ShVehicleConfig" )

function IsNormalVehicle( vehicle )
	return VEHICLE_CONFIG[ vehicle.model ] and (not VEHICLE_CONFIG[ vehicle.model ].is_airplane and not VEHICLE_CONFIG[ vehicle.model ].is_boat )
end


function onServerResourceStart()
    setTimer( function()
        for k, v in pairs( getElementsByType( "vehicle" ) ) do
			local vehilce_vinyls = v:GetVinyls()
            if IsNormalVehicle( v ) and next( vehilce_vinyls ) then
                setElementData( v, "vehicle_vinyl_data", { vinyls = vehilce_vinyls, color = { v:getColor( true ) } } )
            end
        end
    end, 5000, 1 )
end
addEventHandler( "onResourceStart", resourceRoot, onServerResourceStart )