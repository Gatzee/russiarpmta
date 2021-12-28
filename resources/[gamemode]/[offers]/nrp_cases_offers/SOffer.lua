loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SPlayerCommon" )

CONST_64_HOURS = 64 * 3600 -- 64 hours

addEventHandler( "onPlayerReadyToPlay", root, function ( )
	if ( source:GetGlobalData( "donate_transactions" ) or 0 ) == 0 then return end
	if getRealTimestamp( ) - source:GetPermanentData( "reg_date" ) < CONST_64_HOURS then return end
	if ( source:GetGlobalData( "cases_count" ) or 0 ) > 0 then return end

	if not source:HasFinishedTutorial( ) then return end
	if source:GetPermanentData( "cases_bronze_passed" ) then return end
	if not source:GetPermanentData( "is_first_character" ) then return end

	if not source:GetPermanentData( "cases_bronze_show_before" ) then
		SendElasticGameEvent( source:GetClientID( ), "64hr_no_case_gift_offer_show_first" )
		source:SetPermanentData( "cases_bronze_show_before", true )
	end

    triggerClientEvent( source, "onPlayerCasesOfferB", resourceRoot )
end, true, "high+9999999" )

addEvent( "onCasesOffersRequestBronze", true )
addEventHandler( "onCasesOffersRequestBronze", resourceRoot, function ( )
	if not isElement( client ) then return end
	if client:GetPermanentData( "cases_bronze_passed" ) then return end

	client:GiveCase( "bronze", 1 )
	client:SetPermanentData( "cases_bronze_waiting", true )
	client:SetPermanentData( "cases_bronze_passed", true )

	triggerEvent( "onPlayerRequestDonateMenu", client, "cases", "cases_offers" )
end )

addEvent( "onCasesOpenCase" )
addEventHandler( "onCasesOpenCase", root, function ( case_id )
	if case_id ~= "bronze" or not source:GetPermanentData( "cases_bronze_waiting" ) then return end

	source:SetPermanentData( "cases_bronze_waiting", nil )

	SendElasticGameEvent( source:GetClientID( ), "64hr_no_case_gift_offer_open" )
end )

-- FOR TEST SERVER
if SERVER_NUMBER > 100 then
	addCommandHandler( "reset_cases_bronze", function( player )
        player:SetPermanentData( "cases_bronze_passed", nil )
		player:SetPermanentData( "cases_bronze_waiting", nil )
		player:SetPermanentData( "cases_bronze_show_before", nil )
		player:SetPermanentData( "is_first_character", true )
		player:SetCommonData( { cases_count = 0 } )

		player:ShowInfo( "Данные о получении сброшены!" )
	end )
end