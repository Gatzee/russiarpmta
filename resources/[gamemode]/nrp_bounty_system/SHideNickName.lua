addEvent( "onPlayerReadyToPlay", true )
addEventHandler( "onPlayerReadyToPlay", root, function ( )
    local lastDate = source:GetPermanentData( "last_date" ) or 0
    local hideTime = source:GetHideNickExpirationTime( )
    local timeLeft = hideTime - lastDate

    source:SetHideNickExpirationTime( timeLeft > 0 and getRealTimestamp( ) + timeLeft or hideTime )
end )

addEvent( "onPlayerRequestBuyHiddenNick", true )
addEventHandler( "onPlayerRequestBuyHiddenNick", root, function ( price )
    if client ~= source then return end

    local current_price, coupon_discount_value = 0, false
    if getOrderOfTarget( client ) then
        current_price = SHOP_SERVICES[ 8 ].iFinishPrice
    else
        current_price, coupon_discount_value = client:GetCostService( 8 )
    end
    
    if price ~= current_price then
        client:ShowError( "Время действия акции закончилось" )
        return
    end

    if client:GetDonate( ) < current_price then return end
    if coupon_discount_value then 
        client:TakeSpecialCouponDiscount( coupon_discount_value, "special_services" ) 
        triggerEvent( "onPlayerRequestDonateMenu", client, "services" )
    end

    client:TakeDonate( current_price, "f4_service", "hide_nickname" )
    client:InfoWindow( "Вы скрыли никнейм!" )
    client:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy.wav" )

    local currentTime = getRealTimestamp( )
    local hideTime = source:GetHideNickExpirationTime( )
    local addTime = HIDE_NICK_TIME -- one hour

    source:SetHideNickExpirationTime( hideTime > currentTime and hideTime + addTime or currentTime + addTime )

    triggerEvent( "onPlayerBoughtHiddenNick", client, current_price )
	SendElasticGameEvent( client:GetClientID( ), "f4r_f4_services_purchase", { service = "hide_nickname" } )
end )