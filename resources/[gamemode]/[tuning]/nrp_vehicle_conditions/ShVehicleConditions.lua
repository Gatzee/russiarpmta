loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShVehicleConfig" )

Vehicle.GetNotSuitableType = function( self )
    return not VEHICLE_CONFIG[ self.model ] or VEHICLE_CONFIG[ self.model ].is_boat or VEHICLE_CONFIG[ self.model ].is_airplane
end