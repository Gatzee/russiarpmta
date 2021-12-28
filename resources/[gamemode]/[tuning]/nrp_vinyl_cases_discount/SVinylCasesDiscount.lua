Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )

OFFER_START_DATE = 0
OFFER_END_DATE = 0

DISCOUNTS = { 
    { id = 1, buy_count = 3,   value = 0.1 }, 
    { id = 2, buy_count = 6,   value = 0.2 }, 
    { id = 3, buy_count = 10,  value = 0.3 }, 
}


function IsOfferActive()
	local ts = getRealTimestamp( )
    return ts >= OFFER_START_DATE and ts <= OFFER_END_DATE
end

addEvent( "PlayerWantShowVinylCasesDiscount", true )
addEventHandler( "PlayerWantShowVinylCasesDiscount", root, function ( )
    if not IsOfferActive( ) then return end

    if not isElement( source.vehicle ) then
        source:ErrorWindow( "Вы должны быть в машине" )
        return
    end
    
    local cases, tier = exports.nrp_tuning_cases:GetVinylCasesForPlayer( source )
    triggerClientEvent( source, "ShowVinylCasesDiscountUI", resourceRoot, cases, VEHICLE_CLASSES_NAMES[ tier ], DISCOUNTS )
end )

addEvent( "PlayerWantBuyVinylCasesWithDiscount", true )
addEventHandler( "PlayerWantBuyVinylCasesWithDiscount", root, function ( case_id, discount_id )
    local discount = DISCOUNTS[ discount_id ]

    local case = exports.nrp_tuning_cases:GetVinylCases( )[ case_id ]

    local case_cost     = exports.nrp_tuning_shop:ApplyDiscount( case.cost * ( 1 - discount.value ), client )
    local count         = discount.buy_count
	local total_cost    = case_cost * count

	if case.cost_is_soft then
		if not client:TakeMoney( total_cost, "vinyl_case_purchase", case_id .. "_" .. count ) then
			return
		end
	else
		if not client:TakeDonate( total_cost, "vinyl_case_purchase", case_id .. "_" .. count ) then
			return
		end
    end
    
    local rewards_imgs = { }

    for i = 1, count do
        local item = exports.nrp_tuning_cases:GetRandomVinylCaseItem( client, case_id )
        if item then
            WriteLog( "cases_vinyl", "[OPEN] %s / CASE_ID[ %s ]:ITEM[ %s ]", client, case_id, inspect( item ) )

            local vinyl = item.params
            client:GiveVinyl( vinyl )
            
            -- АНАЛИТИКА / Получение награды из кейса / Предметы могут иметь одинаковый `id`, но разные переменные в `params`.
            triggerEvent( "onVinylCasesTakeItem", client, vinyl[ P_PRICE ], vinyl[ P_CLASS ], tostring( vinyl[ P_NAME ] ) )
            
            table.insert( rewards_imgs, vinyl[ P_IMAGE ] )
        end
    end

    triggerClientEvent( client, "ShowTuningCasesRewardsList", resourceRoot, rewards_imgs )

    if client:getData( "tuning_vehicle" ) then
        triggerClientEvent( client, "onVinylsInventoryUpdate", resourceRoot, client:GetVinyls( client.vehicle:GetTier() ) )
    end
end )
function onResourceStart_handler( )
	addEventHandler( "onSpecialDataUpdate", root, function( key, value )
		if key ~= "vinyl_cases_discount" then return end
	
		if not value or next( value ) == nil then 
			OFFER_START_DATE = 0
			OFFER_END_DATE = 0
		else
			OFFER_START_DATE = getTimestampFromString( value[ 1 ].start_date ) 
			OFFER_END_DATE = getTimestampFromString( value[ 1 ].finish_date ) 
			DISCOUNTS = value[ 1 ].discounts
		end
	end )
	triggerEvent( "onSpecialDataRequest", getResourceRootElement( ), "vinyl_cases_discount" )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )


--При открытии ф4 синхронизируем акции на винилы с клиентом
addEventHandler( "onPlayerRequestDonateMenu", root, function( ) 
	triggerClientEvent( client or source, "UpdateVinylDiscounts", client or source, OFFER_START_DATE, OFFER_END_DATE, DISCOUNTS )
end, true, "high+10000" )--Без приоритета нужно будет дважды открывать меню чтобы акции начали отображатся