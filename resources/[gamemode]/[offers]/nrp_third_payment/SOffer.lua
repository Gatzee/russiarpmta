loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "SPlayer" )
Extend( "SPlayerCommon" )
Extend( "ShTimelib" )

CONST_OFFER_TIME = 12 * 60 * 60
PACKAGES = 
{
	[ 1 ] = 
	{
		id = "Basic",
		name = "Базовый",
		cost = 199,
		reward = 
		{
			hard = 199,
			premium_days = 2,
		}
	},

	[ 2 ] = 
	{
		id = "Standart",
		name = "Стандартный",
		cost = 249,
		reward = 
		{
			hard = 249,
			premium_days = 3,
		}
	},

	[ 3 ] = 
	{
		id = "Practical",
		name = "Практичный",
		cost = 299,
		reward = 
		{
			hard = 299,
			premium_days = 3,
			starter_pack = true,
		}
	},

	[ 4 ] = 
	{
		id = "VIP",
		name = "VIP",
		cost = 399,
		reward = 
		{
			hard = 399,
			premium_days = 5,
			starter_pack = true,
		}
	},
}

PACKAGES_BY_COST = { }
for i, pack in pairs( PACKAGES ) do
	pack.number = i
	PACKAGES_BY_COST[ pack.cost ] = pack
end

function onPlayerSessionStart_handler( player )
	local player = source or player
	if not isElement( player ) then return end

	-- Если оффер уже куплен
	local third_payment_bought = player:GetGlobalData( "third_payment_bought" )
    if third_payment_bought then
        return false
    end

	local timestamp = getRealTimestamp()
	local third_payment_end_date = player:GetGlobalData( "third_payment_end_date" )

	-- Если закончилось время оффера
	if third_payment_end_date and third_payment_end_date < timestamp then
		return false

	-- Если время ещё есть, то подгружаем
	elseif third_payment_end_date then
		
		onThirdPaymentOfferUIRequest_handler( player )
		return true
	end
	
	-- Условие оффера, 2 транзации и прошло больше суток
	local donate_transactions = player:GetPermanentData( "donate_transactions" )
	local donate_last_date = player:GetPermanentData( "donate_last_date" )
	if donate_transactions ~= 2 or ( timestamp - donate_last_date ) < 86400 then 
		return false
	end
	
	onThirdPaymentOfferUIRequest_handler( player )
end
addEvent( "onPlayerSessionStart", true )
addEventHandler( "onPlayerSessionStart", root, onPlayerSessionStart_handler )

function onThirdPaymentOfferUIRequest_handler( player )
	local player = player or source
	local timestamp = getRealTimestamp( )
	
	local third_payment_end_date = player:GetGlobalData( "third_payment_end_date" )
	if not third_payment_end_date then 
		third_payment_end_date = timestamp + CONST_OFFER_TIME
		player:SetGlobalData( "third_payment_end_date", third_payment_end_date )
		onShowFirstTime( player )
	end

	triggerClientEvent( player, "onStartOfferThirdPaymentRequest", resourceRoot, third_payment_end_date - timestamp )
end
addEvent( "onThirdPaymentOfferUIRequest" )
addEventHandler( "onThirdPaymentOfferUIRequest", root, onThirdPaymentOfferUIRequest_handler )

function onServerPlayerPurchaseOffer3rdPayment_handler( sum )
	local player = source
	local package = PACKAGES_BY_COST[ sum ]
	if not package then cancelEvent( ) return end

	if package.reward.hard then 
		player:GiveDonate( package.reward.hard, "Third payment offer", package.id )
	end 

	if package.reward.premium_days then 
		player:GivePremiumExpirationTime( package.reward.premium_days )
	end 

	if package.reward.starter_pack then
		player:InventoryAddItem( IN_JAILKEYS, nil, 3 )
		player:InventoryAddItem( IN_FIRSTAID, nil, 2 )
		player:InventoryAddItem( IN_REPAIRBOX, nil, 2 )

		player:GiveFreeEvacuation( 0 )
		player:GiveFreeEvacuation( 0 )
	end

	player:ShowInfo( 'Вы получили пакет "'.. package.name ..'"')

	player:SetGlobalData( "third_payment_bought", true )
	player:SetPrivateData( "third_payment_end_date", 0 )

	onPlayerOfferPurchase( player, package.number, package.id, package.cost )
end
addEvent( "onServerPlayerPurchaseOffer3rdPayment" )
addEventHandler( "onServerPlayerPurchaseOffer3rdPayment", root, onServerPlayerPurchaseOffer3rdPayment_handler )

function onServerThirdPaymentBuyRequest_handler( package_id )
	local player = client or source
	local package = PACKAGES[ package_id ]
	if not player or not package or ( player:GetGlobalData( "third_payment_end_date" ) or 0 ) < getRealTimestamp() then return end

	triggerClientEvent( player, "onClientSelectThirdPackInBrowser", resourceRoot, 901, package.cost )
end
addEvent( "onServerThirdPaymentBuyRequest", true )
addEventHandler( "onServerThirdPaymentBuyRequest", root, onServerThirdPaymentBuyRequest_handler )