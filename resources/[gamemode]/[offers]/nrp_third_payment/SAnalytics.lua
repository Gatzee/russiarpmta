function onShowFirstTime( player )
	SendElasticGameEvent( player:GetClientID(), "3rd_payment_offer_show_first" )
end

function onPlayerOfferPurchase( player, pack_id, pack_name, cost )
	SendElasticGameEvent( player:GetClientID(), "3rd_payment_offer_purchase", 
	{
		pack_id     = tonumber( pack_id ),
		pack_name   = tostring( pack_name ),
		pack_cost   = tonumber( cost ),
		quantity 	= 1,
		spend_sum 	= tonumber( cost ),
		currency 	= "hard"
	} )
end

----------------------------------------------------------------------------------
-- Тестирование
----------------------------------------------------------------------------------

if SERVER_NUMBER > 100 then
	addCommandHandler( "requirementsthirdoffer", function( player ) 
		player:ShowInfo("Данные для попадания под условия - прописаны.")
		player:SetPermanentData( "donate_transactions"	, 2 )
		player:SetPermanentData( "donate_last_date"	, 0 )
	end )

	addCommandHandler( "clearthirdoffer", function( player ) 
		player:ShowInfo("Оффер очищен.")
		player:SetGlobalData( "third_payment_end_date"	, nil )
		player:SetGlobalData( "third_payment_bought", nil )
		player:SetPrivateData( "third_payment_end_date"		, nil )
	end )

	addCommandHandler( "offerthirdshow", function( player )
		onThirdPaymentOfferUIRequest_handler( player )
	end )

	addCommandHandler( "offerthirdsettestcosts", function( player )
		PACKAGES_BY_COST = { }
		for i, pack in pairs( PACKAGES ) do
			pack.cost = i
			PACKAGES_BY_COST[ pack.cost ] = pack
		end
		player:ShowInfo("Цены для теста установлены.")
	end )
end