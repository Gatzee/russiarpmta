loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SPlayer")
Extend("ShVehicleConfig")
Extend("SVehicle")

addEvent( "onSubscriptionExpired", true )
addEventHandler( "onSubscriptionExpired", resourceRoot, function()
	if not client then return end
	if client:IsPremiumActive() then return end

	if client:IsPremiumRenewalEnabled( ) and client:TryAutoProlongPremium( ) then
		return
	end
	
	client:CleanPremiumStuff( )
	client:ShowInfo( "Ваш премиум истёк!" )
end )

function OnPlayerReadyToPlay()
	if not isElement(source) then return end

	if not source:IsPremiumActive( ) then 
		if source:IsPremiumRenewalEnabled( ) then
			source:TryAutoProlongPremium( )
			return
		end

		source:CleanPremiumStuff( ) 
	end

	local pBoostersData = source:GetBoostersData()
	--[[local bFoundBroken = false
	for k,v in pairs(pBoostersData) do
		if ( v.id == BOOSTER_DOUBLE_EXP or v.id == BOOSTER_DOUBLE_MONEY ) and v.expires >= ( getRealTime().timestamp + 24*60*60 ) then
			v.expires = 0
			bFoundBroken = true
		end
	end

	if bFoundBroken then
		source:SetBoostersData( pBoostersData )
	end]]

	source:SetPrivateData("temp_boosters", pBoostersData)
	
	local pTempDiscount = source:GetPermanentData("temp_vehicle_discount")
	if pTempDiscount and pTempDiscount.timestamp > getRealTime().timestamp then
		source:SetPrivateData("temp_vehicle_discount", pTempDiscount)
	end

	-- Конверт подписки в новый премиум
	local iSubscriptionTimestamp = source:GetPermanentData("subscription_time_left") or 0
	local iSubscriptionTimeLeft = iSubscriptionTimestamp - getRealTime().timestamp

	if iSubscriptionTimeLeft > 0 then
		source:SetSubscriptionExpirationTime( 0 )
		source:GivePremiumExpirationTime( iSubscriptionTimeLeft/86400 )
	end
end
addEventHandler("onPlayerReadyToPlay", root, OnPlayerReadyToPlay)

Player.TryAutoProlongPremium = function( self )
	local premium_last_duration = self:GetPermanentData( "prolong_last_duration" )
	if not premium_last_duration then return end
	local premium_time_left = self:GetPermanentData( "premium_time_left" )
	if not premium_time_left then return end
	if getRealTimestamp() - premium_time_left >= 60*60*24*3 then return end

	triggerEvent( "onPremiumPurchaseRequest", self, premium_last_duration, true )

	return true
end

if SERVER_NUMBER > 100 then
	addCommandHandler( "expire_premium", function( ply )
		if not ply:IsAdmin( ) then return end

		ply:SetPremiumExpirationTime( getRealTimestamp( ) + 120 )
		outputChatBox( "Премиум истечёт через две минуты.", ply, 255, 255, 255 ) 
	end)
end