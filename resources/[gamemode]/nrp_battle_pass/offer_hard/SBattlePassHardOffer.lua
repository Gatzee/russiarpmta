local OFFER_DURATION = 1 * 60 * 60
local PACK_ID = 906
local BASE_URL = "https://pyapi.gamecluster.nextrp.ru/v1.0/payments/pay"
local PACKS_BY_SEGMENTS = {
	[ 1 ] = {
		cost = 3500,
		cost_original = 7000,
		discount = 50,
	},
	[ 2 ] = {
		cost = 1500,
		cost_original = 3000,
		discount = 50,
	},
	[ 3 ] = {
		cost = 450,
		cost_original = 900,
		discount = 50,
	},
	[ 4 ] = {
		cost = 450,
		cost_original = 900,
		discount = 50,
	},
}

function GiveHardOffer( player )
    local data = {
		segment = exports.nrp_shop:GetCurrentSegment( player ),
		finish_ts = getRealTimestamp( ) + OFFER_DURATION,
	}
	player:SetPermanentData( "bp_hard_offer", data )
	ShowHardOffer( player, data )

	SendElasticGameEvent( player:GetClientID( ), "bp_reward_donate_pack_offer_show", {
		id = "donate_offer_bp_reward",
	} )
end

function ShowHardOffer( player, data )
	local pack = PACKS_BY_SEGMENTS[ data.segment ]
	data.pack_id       = PACK_ID
	data.url           = BASE_URL
	data.cost          = pack.cost
	data.cost_original = pack.cost_original
	data.discount      = pack.discount
	triggerClientEvent( player, "BP:ShowHardOffer", resourceRoot, data )
end

function onPlayerCompleteLogin_handler_hardOffer( player )
	local player = isElement( player ) and player or source
    local data = player:GetPermanentData( "bp_hard_offer" )
	if data and data.finish_ts > getRealTimestamp( ) then
		ShowHardOffer( player, data )
	end
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerCompleteLogin_handler_hardOffer )

addEventHandler( "onResourceStart", resourceRoot, function( )
	setTimer( function( )
		for i, player in pairs( GetPlayersInGame( ) ) do
			onPlayerCompleteLogin_handler_hardOffer( player )
		end
	end, 1000, 1 )
end )

addEvent( "BP:onPlayerPurchaseHardOffer" )
addEventHandler( "BP:onPlayerPurchaseHardOffer", root, function( sum )
    local player = source
    local data = player:GetPermanentData( "bp_hard_offer" )
	if not data then return end

	local pack = PACKS_BY_SEGMENTS[ data.segment ]
	if not pack or pack.cost ~= sum then return end

	player:GiveDonate( pack.cost_original, "donate_pack", "donate_offer_bp_reward" )

	data.finish_ts = 0
	player:SetPermanentData( "bp_hard_offer", data )

	triggerClientEvent( player, "BP:onClientPlayerPurchaseHardOffer", resourceRoot )

	SendElasticGameEvent( player:GetClientID( ), "bp_reward_donate_pack_offer_purchase", {
		id        = "donate_offer_bp_reward",
		name      = "bp_reward_hard_offer"  ,
		segment   = data.segment            ,
		cost      = pack.cost               ,
		hard_sum  = pack.cost_original      ,
		quantity  = 1                       ,
		spend_sum = sum                     ,
		currency  = "hard"                  ,
	} )
end )