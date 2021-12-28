loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "ShSocialRating" )

function OnPlayerReceiveSpeedRadarFine( pVehicle, pPlayer )
	if not isElement(pVehicle) then return end
	if pVehicle.dimension ~= 0 then return end 
	
	if pVehicle:GetOwnerID() then
		local pSource = pSource or client
		local pOwner = GetPlayer( pVehicle:GetOwnerID( ) )

		if pOwner == client then
			triggerClientEvent( client, "OnClientReceiveSpeedRadarFine", client )
		end

		pSource:ChangeSocialRating( SOCIAL_RATING_RULES.over_speed.rating )
		pSource:AddFine( 9 )
	end
end
addEvent("OnPlayerReceiveSpeedRadarFine", true)
addEventHandler("OnPlayerReceiveSpeedRadarFine", resourceRoot, OnPlayerReceiveSpeedRadarFine)