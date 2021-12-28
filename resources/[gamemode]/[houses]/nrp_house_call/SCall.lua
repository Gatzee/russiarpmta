loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "ShApartments" )
Extend( "ShVipHouses" )

function onPlayerHouseCallConfirm_handler( id, number )
	if not isElement( source ) then return end
	
	if source:GetBlockInteriorInteraction() then
		source:ShowInfo( "Вы не можете войти во время задания" )
		return false
	end

	local pos = id == 0 and VIP_HOUSES_LIST[ number ].enter_marker_position or APARTMENTS_LIST[ id ].enter_position
	if getDistanceBetweenPoints3D( pos.x, pos.y, pos.z, source.position ) > 7 then return end

	if id == 0 then
		triggerEvent( "PlayerWantEnterVipHouse", source, number, true )
	else
		triggerEvent( "PlayerWantEnterApartment", source, id, number )
	end
end
addEvent( "onPlayerHouseCallConfirm", true )
addEventHandler( "onPlayerHouseCallConfirm", root, onPlayerHouseCallConfirm_handler )