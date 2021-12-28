Extend( "SPlayer" )

CONST_GAMES_COUNT = 30
CONST_INSTALL_TIME = 7 * 24 * 60 * 60
CONST_TIME_TO_BUY = 2 * 24 * 60 * 60

function onCasinoPlayersGame_handler( game_id, players )
	for _, player in pairs( players ) do
		local games_count = player:GetPermanentData( "casino_games_count" ) or 0
		player:SetPermanentData( "casino_games_count", games_count + 1 )

		triggerEvent( "onPlayerSomeDo", player, "enter_casino_game" ) -- achievements
	end
end
addEvent( "onCasinoPlayersGame" )
addEventHandler( "onCasinoPlayersGame", root, onCasinoPlayersGame_handler )

function onPlayerCasinoEnter_handler( )
	local reg_date = source:GetPermanentData( "reg_date" ) or 0
	local timestamp = getRealTime( ).timestamp
	if ( timestamp - reg_date ) < CONST_INSTALL_TIME then
		local games_count = source:GetPermanentData( "casino_games_count" ) or 0
		if games_count >= 30 then
			if not source:GetPermanentData( "annuity_payment_timeout" ) then
				local annuity_payment_timeout = timestamp + CONST_TIME_TO_BUY
				source:SetPermanentData( "annuity_payment_timeout", annuity_payment_timeout )
				source:SetPrivateData( "annuity_payment_timeout", annuity_payment_timeout )
				triggerClientEvent( source, "ShowAnnuityPaymentsUI", resourceRoot )

				SendElasticGameEvent( source:GetClientID( ), "casino_offer1_48hrs_showfirst", {
					casino_games_num = games_count
				} )
			end
		end
	end
end
addEvent( "onPlayerCasinoEnter" )
addEventHandler( "onPlayerCasinoEnter", root, onPlayerCasinoEnter_handler )

function PlayerWantBuyAnnuityPaymentsPack_handler( )
	if not client then return end

	local annuity_payment_timeout = client:GetPermanentData( "annuity_payment_timeout" )
	if not annuity_payment_timeout then return end

	local annuity_payment = client:GetPermanentData( "annuity_payment" )
	if annuity_payment then return end

	if client:TakeDonate( 490, "annuity_purchase" ) then
		annuity_days = { DAY_RECEIVED }
		client:SetPermanentData( "annuity_days", annuity_days )
		client:SetPrivateData( "annuity_days", annuity_days )

		local games_count = client:GetPermanentData( "casino_games_count" ) or 0
		SendElasticGameEvent( client:GetClientID( ), "casino_offer1_48hrs_purchase", {
			casino_games_num = games_count
		} )

		-- Установка времени начало первого дня. Так как цикл начинается не с 0:00, а с 4:00, то нужно немного магии
		do
			local timestamp = getRealTime( ).timestamp
			local time_data = getRealTime( timestamp - 4 * 60 * 60 )
			annuity_payment = timestamp - ( time_data.second + time_data.minute * 60 + time_data.hour * 60 * 60 )
			client:SetPermanentData( "annuity_payment", annuity_payment )
			client:SetPrivateData( "annuity_payment", annuity_payment )
		end

		triggerClientEvent( client, "ShowAnnuityPaymentsUI", resourceRoot, annuity_days )
	end
end
addEvent( "PlayerWantBuyAnnuityPaymentsPack", true )
addEventHandler( "PlayerWantBuyAnnuityPaymentsPack", root, PlayerWantBuyAnnuityPaymentsPack_handler )

function onPlayerCompleteLogin_handler( )
	local annuity_payment = source:GetPermanentData( "annuity_payment" )
	if not annuity_payment then return end

	local timestamp = getRealTime( ).timestamp
	local current_day = math.min( math.ceil( ( timestamp - annuity_payment ) / ( 60 * 60 * 24 ) ), #CONST_DAYS )

	local annuity_days = source:GetPermanentData( "annuity_days" )
	if annuity_days[ current_day ] then
		for day, state in pairs( annuity_days ) do
			if state == DAY_RECEIVED then
				triggerClientEvent( source, "ShowAnnuityPaymentsUI", resourceRoot, annuity_days )
				return
			end
		end

		return
	end

	annuity_days[ current_day ] = DAY_RECEIVED

	for day = 2, ( current_day - 1 ) do
		if not annuity_days[ day ] then
			annuity_days[ day ] = DAY_MISSED
			SendElasticGameEvent( source:GetClientID( ), "casino_offer1_presen_lost", {
				day_num = day
			} )
		end
	end

	source:SetPermanentData( "annuity_days", annuity_days )
	source:SetPrivateData( "annuity_days", annuity_days )


	triggerClientEvent( source, "ShowAnnuityPaymentsUI", resourceRoot, annuity_days )
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )


function PlayerWantTakeAnnuityPaymentsPack_handler( )
	if not client then return end

	local annuity_payment = client:GetPermanentData( "annuity_payment" )
	local annuity_days = client:GetPermanentData( "annuity_days" )

	if not annuity_payment then return end
	if not annuity_days then return end


	local items_name_to_item_id = {
		repairbox = IN_REPAIRBOX;
		firstaid = IN_FIRSTAID;
		canister = IN_CANISTER;
	}

	for day, reward in pairs( CONST_DAYS ) do
		if annuity_days[ day ] and annuity_days[ day ] == DAY_RECEIVED then
			annuity_days[ day ] = DAY_TAKEN
			SendElasticGameEvent( client:GetClientID( ), "casino_offer1_present_get", {
				day_num = day
			} )

			client:GiveMoney( reward[ 1 ], "annuity_payment", "day_" .. day )

			client:InventoryAddItem( items_name_to_item_id[ reward[ 2 ] ], nil, 1 )
			client:InventoryAddItem( items_name_to_item_id[ reward[ 3 ] ], nil, 1 )
		end
	end

	client:SetPermanentData( "annuity_days", annuity_days )
	client:SetPrivateData( "annuity_days", annuity_days )


	triggerClientEvent( client, "ShowAnnuityPaymentsUI", resourceRoot, annuity_days )
end
addEvent( "PlayerWantTakeAnnuityPaymentsPack", true )
addEventHandler( "PlayerWantTakeAnnuityPaymentsPack", root, PlayerWantTakeAnnuityPaymentsPack_handler )