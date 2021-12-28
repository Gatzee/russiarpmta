loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

--Будем сохранять callback и параметры тут, чтобы не отсылать это на клиент а потом обратно
local activeConfirmations = { }

function EnoughMoneyOffer( self, place, price, fn_callback, ... )
	local lastTimestamp = self:getData( "LastShownConfirm" ) or 0
	local playerMoney = self:GetMoney( )

	--Проводим оплату за софт
	if playerMoney >= price then
		return "Confirmed"
	end

	--Ограничение на отображение раз в 10 минут
	if lastTimestamp + 600 > getRealTimestamp( ) then self:ShowError( "Недостаточно средств" ) return false end

	local playerHard  = self:GetDonate( )
	--Недостающая сумма в софте
	local needMoney = price - playerMoney
	--Недостающая сумма в харде
	local needHard = math.ceil( needMoney / 1000 )

	--Если харда недостаточно
	if playerHard < needHard then
		triggerClientEvent( self, "onShopNotEnoughHard", resourceRoot, place, "onPlayerRequestDonateMenu", "donate" )
		return false
	end

	if triggerClientEvent( self, "onConvertConfirmation", resourceRoot, needHard ) then
		self:setData( "LastShownConfirm", getRealTimestamp( ), false )

		activeConfirmations[ self ] = {
			fn_callback = fn_callback,
			fn_params = { ... },
			data = { needHard = needHard, place = place }
		}

		SendElasticGameEvent( self:GetClientID( ), "show_offer_convert_donate", {
			cost 		= tonumber( needHard ),
			name 		= tostring( self:GetNickName( ) ),
			place 		= tostring( place ),
		} )

		return "Waiting"
	end
end

addEvent( "onClientConvertConfirm", true )
addEventHandler( "onClientConvertConfirm", root, function( state ) 
	local conf = activeConfirmations[ client ]

	if state then 
		if client:TakeDonate( conf.data.needHard, "hard_conversion" ) then
			client:GiveMoney( conf.data.needHard * 1000, "hard_conversion" )

			SendElasticGameEvent( client:GetClientID( ), "offer_convert_donate", {
				cost 		= tonumber( conf.data.needHard ),
				name 		= tostring( client:GetNickName( ) ),
				place 		= tostring( conf.data.place ),
			} )
			
			if conf.fn_callback then 
				triggerEvent( conf.fn_callback, unpack( conf.fn_params ))
			end
		end
	end

	activeConfirmations[ client ] = nil

	return state
end )

addEvent( "onGiveHardOfferShown", true )
addEventHandler( "onGiveHardOfferShown", root, function( place ) 
	SendElasticGameEvent( client:GetClientID( ), "show_offer_give_donate", {
		name		= tostring( client:GetNickName( ) ),
		place		= tostring( place or "Unknown" ),
	} )
end )

addEvent( "onGiveHardOfferAccepted", true )
addEventHandler( "onGiveHardOfferAccepted", root, function( place ) 
	SendElasticGameEvent( client:GetClientID( ), "offer_give_donate", {
		name		= tostring( client:GetNickName( ) ),
		place		= tostring( place or "Unknown" ),
	} )
end )

-- FOR TEST SERVER
if SERVER_NUMBER > 100 then
	addCommandHandler( "resetconvert", function( player )
		player:ShowInfo( "Последний раз сброшен" )
		player:setData( "LastShownConfirm", 0, false )
	end )
end