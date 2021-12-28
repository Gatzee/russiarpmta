loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "ShVehicleConfig" )
Extend( "SVehicle" )

--Инициализация переменных
startTime = 0
endTime = 0
CONST_OFFER_TIME = 48 * 60 * 60

function onPlayerReadyToPlay_handler( object )
	local player = getElementType(source) == "player" and source or object
	local timestamp = getRealTimestamp()

	if timestamp < startTime then return end
	if player:GetLevel() < 7 then return end

	if player:HasAnyApartment( false ) then 
		if player:GetPermanentData( "apartments_offer" ) then 
			player:SetPrivateData( "apartments_offer", 0 )
			player:SetPermanentData( "apartments_offer", 0 )
		end
		return
	end
	
	local apartments_offer = player:GetPermanentData( "apartments_offer" )
	if apartments_offer and apartments_offer > startTime then
		if apartments_offer > timestamp then
			player:SetPrivateData( "apartments_offer", apartments_offer )
			if player:HasFinishedTutorial( ) then
				triggerClientEvent( player, "ShowApartmentsOffer", resourceRoot )
			end
		end
	else
		if timestamp > endTime then return end

		apartments_offer = timestamp + CONST_OFFER_TIME
		player:SetPrivateData( "apartments_offer", apartments_offer )
		player:SetPermanentData( "apartments_offer", apartments_offer )
		
		triggerEvent( "SDEV2DEV_apartments_offer", player )
		if player:HasFinishedTutorial( ) then
			triggerClientEvent( player, "ShowApartmentsOffer", resourceRoot )
		end
	end
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler, true, "high+9999999" )

function onPlayerHousePurchase_handler() 
	if not source:GetPermanentData( "apartments_offer" ) then return end

	source:SetPrivateData( "apartments_offer", 0 )
	source:SetPermanentData( "apartments_offer", 0 )
end
addEventHandler( "onPlayerHousePurchase", root, onPlayerHousePurchase_handler )

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
	if key ~= "apartments_discount" then return end

	if not value or next( value ) == nil then 
		startTime = 0
		endTime = 0
	else
		startTime = getTimestampFromString( value[1].start_date )
		endTime = getTimestampFromString( value[1].finish_date )
	end
end )
--После запуска ресурса обновляем все даты
triggerEvent( "onSpecialDataRequest", getResourceRootElement( ), "apartments_discount" )


if SERVER_NUMBER > 100 then 
	addCommandHandler( "resetapartoffer", function( player ) 
		player:SetPrivateData( "apartments_offer", nil )
		player:SetPermanentData( "apartments_offer", nil )
		player:ShowInfo("Offer reset success!")
	end )
end