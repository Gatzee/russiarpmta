loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )

FREQ_MUL = 2 -- умножение частоты выплаты (в 2 раза чаще)

local MULTIPLIER = {
	is_enabled = {
		[ F_POLICE_PPS_MSK ] = true,
		[ F_POLICE_DPS_MSK ] = true,
		[ F_MEDIC_MSK ] = true,
		[ F_GOVERNMENT_MSK ] = true,
	},
	money = 2,
	exp = 1.75,
	prem = 3.5,
}

local PAYOUTS = {
	[ 1 ] = { money = 6000, exp = 75 },
	[ 2 ] = { money = 8000, exp = 100 },
	[ 3 ] = { money = 10000, exp = 150 },
	[ 4 ] = { money = 12000, exp = 200 },
	[ 5 ] = { money = 16000, exp = 250 },
	[ 6 ] = { money = 20000, exp = 300 },
	[ 7 ] = { money = 24000, exp = 350 },
	[ 8 ] = { money = 28000, exp = 400 },
	[ 9 ] = { money = 32000, exp = 450 },
	[ 10 ] = { money = 36000, exp = 500 },
	[ 11 ] = { money = 42000, exp = 550 },
	[ 12 ] = { money = 48000, exp = 600 },
}

PAYOUT_FREQ = 60 * 60 * 1000 / FREQ_MUL
PAYOUT_CHECK_FREQ = 0.5 * 60 * 1000 / FREQ_MUL -- сохранение каждые 30 сек
PAYOUT_CHECK_STEP = PAYOUT_CHECK_FREQ

PLAYERS_TIMERS = { }

function onPlayerCompleteLogin_handler( player )
	local player = isElement( player ) and player or source
	if player:IsInFaction() then
		OnPlayerFactionDutyStart_handler( player )
	else
		OnPlayerFactionDutyEnd_handler( player )
	end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler, true, "low-100000" )
addEventHandler( "onPlayerFactionChange", root, onPlayerCompleteLogin_handler )

function onResourceStart_handler()
	for i, v in pairs( getElementsByType( "player" ) ) do
		if v:IsInGame() then
			onPlayerCompleteLogin_handler( v )
		end
	end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function Payout( player )
	if player:IsOnFactionDuty( ) and player:GetAFKTime( ) < 5 * 60 * 1000 then
		local faction = player:GetFaction( )
		local faction_level = player:GetFactionLevel( )
		if faction == 0 or faction_level == 0 then
			player:EndFactionDuty()
			return
		elseif player.model ~= FACTION_SKINS_BY_GENDER[ faction ][ faction_level ][ player:GetGender() ] then
			player:EndFactionDuty()
			player:ShowInfo( "Смена завершена, так как вы одеты не по форме" )
			return
		end

		local current_time = player:GetPermanentData( "faction_payout" ) or 0
		local new_time = math.floor( current_time + PAYOUT_CHECK_STEP )
		if new_time >= PAYOUT_FREQ then
			new_time = 0

			local faction_id = player:GetFaction( )
			local current_level = player:GetFactionLevel( )
			local payout_conf = PAYOUTS[ current_level ]
			if payout_conf then
				local money = payout_conf.money / FREQ_MUL
				local exp = math.ceil( payout_conf.exp / FREQ_MUL )

				if MULTIPLIER.is_enabled[ faction_id ] then
					money = money * MULTIPLIER.money
					exp = exp * MULTIPLIER.exp
				end

				local money_premium = math.floor( PREMIUM_SETTINGS.fFactionMoneyMul * money )
				local exp_premium = math.floor( PREMIUM_SETTINGS.fFactionMoneyMul * exp )

				money = player:IsPremiumActive( ) and money_premium or money
				exp = player:IsPremiumActive() and exp_premium or exp

				money = exports.nrp_factions_gov_ui_control:GetFactionGovEconomyPercent( faction_id, current_level, money )

				local method = "Factions.Payout.Level_" .. current_level
				player:GiveMoney( money, "faction_payout", FACTIONS_ENG_NAMES[ faction_id ] )
				player:GiveExp( exp, method )

				local msg = "Награда от " .. FACTIONS_NAMES[ FACTIONS_BY_CITYHALL[ faction_id ] ] .. " - " .. format_price( money ) .. " рублей и " .. exp .. " опыта"
				if player:IsPremiumActive( ) then
					msg = msg .. " - твоя награда повышена с помощью премиума!"
				else
					msg = msg .. ", но с премиумом могло бы быть " .. format_price( money_premium ) .. " рублей и " .. exp_premium .. " опыта!"
				end

				local message = {
					special = not player:IsPremiumActive( ) and "factions_reward" or nil,
					title = FACTIONS_NAMES[ FACTIONS_BY_CITYHALL[ faction_id ] ],
					msg_short = "Зачисление зарплаты",
					msg = msg,
				}
				player:PhoneNotification( message )

				iprint( player:GetNickName(), " получил зарплату ", money, exp .. " опыта" )

				triggerEvent( "onPlayerFactionPayout", player, money, exp )

				-- analytics
				SendElasticGameEvent( player:GetClientID( ), "faction_income", {
					faction_id = FACTIONS_ENG_NAMES[ faction_id ],
					rank_num = faction_level,
					exp_sum = exp,
					receive_sum = money,
					currency = "soft",
				} )
			else
				iprint( player:GetNickName(), " ОШИБКА ЗАРПЛАТЫ ", current_level )
			end

		end
		player:SetPermanentData( "faction_payout", new_time )
	end
end

function OnPlayerFactionDutyStart_handler( player )
	local player = isElement( player ) and player or source
	OnPlayerFactionDutyEnd_handler( player )
	PLAYERS_TIMERS[ player ] = Timer( Payout, PAYOUT_CHECK_FREQ, 0, player )
	addEventHandler( "OnPlayerFactionDutyEnd", player, OnPlayerFactionDutyEnd_handler )
end
addEventHandler( "OnPlayerFactionDutyStart", root, OnPlayerFactionDutyStart_handler )

function OnPlayerFactionDutyEnd_handler( player )
	local player = isElement( player ) and player or source

	if PLAYERS_TIMERS[ player ] then
		removeEventHandler( "OnPlayerFactionDutyEnd", player, OnPlayerFactionDutyEnd_handler )
		if isTimer( PLAYERS_TIMERS[ player ] ) then killTimer( PLAYERS_TIMERS[ player ] ) end
		PLAYERS_TIMERS[ player ] = nil
	end
end
addEventHandler( "onPlayerPreLogout", root, OnPlayerFactionDutyEnd_handler )