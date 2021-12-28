
function onLicenseGunOfferShowFirst( player )
    SendElasticGameEvent( player:GetClientID( ), "license_gun_offer_show_first" )
end

function onLicenseGunOfferPurchase_handler( player, license_cost )
    player:SetPermanentData( "offer_gun_license_bought", true )
    
    player:SetPermanentData( "offer_gun_license_time_left", nil )
    player:SetPrivateData( "offer_gun_license_time_left", nil )

    SendElasticGameEvent( player:GetClientID( ), "license_gun_offer_purchase", 
    { 
        license_cost = tonumber( license_cost ),
        quantity     = 1,
        spend_sum    = tonumber( license_cost ),
        currency     = "soft"
    } )
end
addEvent( "onLicenseGunOfferPurchase", true )
addEventHandler( "onLicenseGunOfferPurchase", root, onLicenseGunOfferPurchase_handler )