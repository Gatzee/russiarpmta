CONFISCATION_SEQUENCES = {}

function StartConfiscationSequence( pPlayer, pVehicle )
	if not isElement(pPlayer) or not isElement(pVehicle) then return end
	if IsSpecialVehicle( pVehicle.model ) then return end

	BreakConfiscationSequence( pPlayer )
	
	CONFISCATION_SEQUENCES[ pPlayer ] = 
	{
		vehicle = pVehicle,
	}

	CONFISCATION_SEQUENCES[ pPlayer ].timer = setTimer( function( player )
		if not isElement( player ) or not isElement( CONFISCATION_SEQUENCES[ player ].vehicle ) then return end
		
		if not CONFISCATION_SEQUENCES[ player ] then return end
		CONFISCATION_SEQUENCES[ player ].vehicle:SetConfiscated( true )
		CONFISCATION_SEQUENCES[ player ].vehicle:setData("being_confiscated", false, false)
		CONFISCATION_SEQUENCES[ player ] = nil
	end, 300000, 1, pPlayer )

	pVehicle:setData("being_confiscated", true, false)

	triggerClientEvent( pPlayer, "ShowConfiscationUI", pPlayer, { vehicle = pVehicle, time = 300 } )
end
addEvent("StartConfiscationSequence", true)
addEventHandler("StartConfiscationSequence", root, StartConfiscationSequence)

function BreakConfiscationSequence( pPlayer )
	if CONFISCATION_SEQUENCES[ pPlayer ] then
		if isTimer( CONFISCATION_SEQUENCES[ pPlayer ].timer ) then killTimer( CONFISCATION_SEQUENCES[ pPlayer ].timer ) end
		CONFISCATION_SEQUENCES[ pPlayer ].vehicle:setData("being_confiscated", false, false)
		CONFISCATION_SEQUENCES[ pPlayer ] = nil
	end

	if isElement( pPlayer ) then
		triggerClientEvent( pPlayer, "HideConfiscationUI", pPlayer, { vehicle = pVehicle, time = 60 } )
	end
end

function OnPlayerVehicleEnter( pVehicle, iSeat )
	if iSeat ~= 0 then return end
	if pVehicle:GetID() < 0 then return end
	
	local pPlayer = source

	if pPlayer:IsWantedFor( "1.11" ) and not CONFISCATION_SEQUENCES[ pPlayer ] then
		if pVehicle:GetOwnerID() == pPlayer:GetID() then
			StartConfiscationSequence( pPlayer, pVehicle )
		end
	end
end
addEventHandler("onPlayerVehicleEnter", root, OnPlayerVehicleEnter)