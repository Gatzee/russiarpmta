tuning_parts = { }

addEvent( "onTuningPartsListResponse", true )
addEventHandler( "onTuningPartsListResponse", resourceRoot, function ( data )
    tuning_parts = data
end )

triggerServerEvent( "onTuningPartsListRequest", resourceRoot )