loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "ShVehicleConfig" )
Extend( "SVehicle" )

CONST_START_TIME_REWARD = 1567544400 -- среда, 4 сентября 2019 г., 0:00:00 GMT+03:00
CONST_LAST_TIME_DONATE = 1567566000 -- среда, 4 сентября 2019 г., 6:00:00 GMT+03:00

-- Костыль выдачи скинов тем, кто не получил
FAILED_GET_PLAYERS = {
	[ 1 ] = {
		[ 74620 ] = 1;
		[ 59508 ] = 1;
		[ 74663 ] = 1;
		[ 124193 ] = 1;
		[ 116493 ] = 1;
		[ 5356 ] = 1;
		[ 18417 ] = 1;
		[ 72980 ] = 1;
		[ 9630 ] = 1;
		[ 30198 ] = 1;
		[ 73524 ] = 1;
		[ 9336 ] = 1;
		[ 145194 ] = 1;
		[ 149312 ] = 1;
		[ 21666 ] = 1;
		[ 24936 ] = 1;
		[ 4340 ] = 2;
		[ 5874 ] = 2;
		[ 54558 ] = 2;
		[ 146649 ] = 2;
		[ 53736 ] = 2;
		[ 183370 ] = 2;
		[ 84189 ] = 2;
		[ 2952 ] = 2;
		[ 267729 ] = 2;
		[ 224958 ] = 2;
		[ 5247 ] = 2;
		[ 37073 ] = 2;
		[ 2426 ] = 2;
		[ 26068 ] = 2;
		[ 252023 ] = 2;
		[ 245353 ] = 2;
		[ 16061 ] = 2;
		[ 149447 ] = 2;
		[ 2577 ] = 2;
		[ 34460 ] = 2;
		[ 108538 ] = 2;
		[ 166903 ] = 2;
		[ 190691 ] = 2;
		[ 966 ] = 2;
		[ 321 ] = 2;
		[ 1447 ] = 2;
		[ 15898 ] = 2;
		[ 14022 ] = 2;
		[ 1748 ] = 2;
		[ 22965 ] = 2;
		[ 142 ] = 2;
		[ 23575 ] = 2;
		[ 8976 ] = 2;
		[ 160423 ] = 2;
		[ 2441 ] = 2;
		[ 2098 ] = 2;
		[ 2791 ] = 2;
		[ 31828 ] = 2;
		[ 1801 ] = 2;
		[ 81963 ] = 2;
		[ 10606 ] = 2;
	};
	[ 2 ] = {
		[ 8187 ] = 1;
		[ 100117 ] = 1;
		[ 59980 ] = 1;
		[ 47749 ] = 1;
		[ 56626 ] = 1;
		[ 57192 ] = 1;
		[ 116289 ] = 1;
		[ 15 ] = 1;
		[ 38692 ] = 1;
		[ 71955 ] = 1;
		[ 56594 ] = 1;
		[ 144115 ] = 1;
		[ 3751 ] = 1;
		[ 10018 ] = 1;
		[ 1126 ] = 1;
		[ 66240 ] = 2;
		[ 5015 ] = 2;
		[ 79634 ] = 2;
		[ 48270 ] = 2;
		[ 28989 ] = 2;
		[ 224 ] = 2;
		[ 79761 ] = 2;
		[ 18727 ] = 2;
		[ 135477 ] = 2;
		[ 123596 ] = 2;
		[ 30386 ] = 2;
		[ 77989 ] = 2;
		[ 67149 ] = 2;
		[ 6111 ] = 2;
		[ 10993 ] = 2;
		[ 2342 ] = 2;
		[ 66712 ] = 2;
		[ 91594 ] = 2;
		[ 38380 ] = 2;
		[ 58695 ] = 2;
		[ 75632 ] = 2;
		[ 163130 ] = 2;
		[ 64846 ] = 2;
		[ 127611 ] = 2;
		[ 62759 ] = 2;
		[ 33315 ] = 2;
		[ 15362 ] = 2;
		[ 68018 ] = 2;
		[ 17250 ] = 2;
	};
	[ 3 ] = {
		[ 8695 ] = 1;
		[ 89157 ] = 1;
		[ 3601 ] = 1;
		[ 91564 ] = 1;
		[ 78306 ] = 1;
		[ 37208 ] = 1;
		[ 44944 ] = 1;
		[ 10690 ] = 2;
		[ 54872 ] = 2;
		[ 19564 ] = 2;
		[ 12266 ] = 2;
		[ 92440 ] = 2;
		[ 47761 ] = 2;
		[ 67249 ] = 2;
		[ 77797 ] = 2;
		[ 56447 ] = 2;
		[ 4183 ] = 2;
		[ 18054 ] = 2;
	};
	[ 4 ] = {
		[ 9206 ] = 1;
		[ 12874 ] = 1;
		[ 2917 ] = 1;
		[ 17918 ] = 1;
		[ 372 ] = 1;
		[ 32199 ] = 1;
		[ 14465 ] = 1;
		[ 63524 ] = 1;
		[ 4878 ] = 2;
		[ 4675 ] = 2;
		[ 34403 ] = 2;
		[ 12230 ] = 2;
		[ 66488 ] = 2;
		[ 46994 ] = 2;
		[ 6882 ] = 2;
		[ 6825 ] = 2;
		[ 28366 ] = 2;
		[ 1674 ] = 2;
		[ 59003 ] = 2;
		[ 14887 ] = 2;
		[ 69503 ] = 2;
	};
	[ 5 ] = {
		[ 45719 ] = 1;
		[ 4139 ] = 1;
		[ 37783 ] = 1;
		[ 4556 ] = 1;
		[ 17825 ] = 2;
		[ 2309 ] = 2;
		[ 15713 ] = 2;
		[ 6018 ] = 2;
		[ 5006 ] = 2;
		[ 6 ] = 2;
		[ 7445 ] = 2;
		[ 18483 ] = 2;
		[ 52902 ] = 2;
		[ 8274 ] = 2;
		[ 3462 ] = 2;
	};
	[ 6 ] = {
		[ 63637 ] = 1;
		[ 6619 ] = 1;
		[ 36982 ] = 1;
		[ 22000 ] = 2;
		[ 31243 ] = 2;
		[ 10224 ] = 2;
		[ 20897 ] = 2;
		[ 60915 ] = 2;
		[ 32214 ] = 2;
		[ 30375 ] = 2;
		[ 48254 ] = 2;
		[ 4439 ] = 2;
		[ 592 ] = 2;
	};
	[ 7 ] = {
		[ 6402 ] = 1;
		[ 14667 ] = 1;
		[ 3364 ] = 1;
		[ 34526 ] = 2;
		[ 34351 ] = 2;
		[ 23850 ] = 2;
		[ 23391 ] = 2;
		[ 29645 ] = 2;
		[ 4633 ] = 2;
	};
	[ 8 ] = {
		[ 12184 ] = 1;
		[ 6409 ] = 2;
		[ 116 ] = 2;
		[ 19061 ] = 2;
		[ 23391 ] = 2;
		[ 1383 ] = 2;
		[ 11940 ] = 2;
		[ 267 ] = 2;
	};
}

addEventHandler( "onInventoryInitializationFinished", root, function( )
	local timestamp = getRealTime( ).timestamp
	if timestamp < CONST_START_TIME_REWARD then return end
	if source:GetPermanentData( "special_thks_reward" ) then
		local server_number = tonumber( get( "server.number" ) )
		if FAILED_GET_PLAYERS[ server_number ] and FAILED_GET_PLAYERS[ server_number ][ source:GetUserID( ) ] then
			if not source:GetPermanentData( "special_thks_reward_failed_get" ) then
				source:SetPermanentData( "special_thks_reward_failed_get", true )

				if FAILED_GET_PLAYERS[ server_number ][ source:GetUserID( ) ] == 1 then
					source:GiveSkin( 182 )
					WriteLog( "thks_reward", "[REPEAT RECEIVE / 1] %s", source )

				elseif FAILED_GET_PLAYERS[ server_number ][ source:GetUserID( ) ] == 2 then
					source:GiveSkin( 114 )
					WriteLog( "thks_reward", "[REPEAT RECEIVE / 2] %s", source )
				end

				source:PhoneNotification( { title = "Просим прощения", msg = "Из-за косяка мы выдали подарок не полностью. Мы исправились! Скин помещен к тебе в инвентарь" } )
			end
		end
		
		return
	end

	source:SetPermanentData( "special_thks_reward", timestamp )

	WriteLog( "thks_reward", "[SEGMENTED] %s", source )

	if source:GetPermanentData( "donate_last_date" ) < CONST_LAST_TIME_DONATE then
		local donate_total = source:GetPermanentData( "donate_total" )
		if donate_total >= 35000 then
			triggerClientEvent( source, "ShowSpecialThksRewardUI", resourceRoot, "high" )

			source:GiveSkin( 182 )
			rewardPlayer( source, { color = { 200, 50, 50 }, model = 446, variant = 1, cost = 15000000 } )

			triggerEvent( "onPlayerReceiveSpecialThksReward", source, 1 )
			WriteLog( "thks_reward", "[RECEIVE / 1] %s", source )

		elseif donate_total > 15000 then
			triggerClientEvent( source, "ShowSpecialThksRewardUI", resourceRoot, "low" )

			source:GiveMoney( 500000, "thanks_reward" )
			source:GiveSkin( 114 )

			triggerEvent( "onPlayerReceiveSpecialThksReward", source, 2 )
			WriteLog( "thks_reward", "[RECEIVE / 2] %s", source )
		end
	end
end )


function rewardPlayer(player, data)
	local aColor		= data.color
	local sOwnerPID		= "p:" .. player:GetUserID()
	local pRow	= {
		model 		= data.model;
		variant		= data.variant;
		x			= 0;
		y			= 0;
		z			= 0;
		rx			= 0;
		ry			= 0;
		rz			= 0;
		owner_pid	= sOwnerPID;
		color		= aColor;
	}

	exports.nrp_vehicle:AddVehicle( pRow, true, "OnBoatMarketVehicleAdded", { player = player, cost = data.cost } )

	return true
end

function OnBoatMarketVehicleAdded( vehicle, data )
	if isElement(vehicle) and isElement(data.player) then
		local sOwnerPID = "p:" ..data.player:GetUserID()

		vehicle.locked = true
		vehicle.engineState = true
		vehicle:SetFuel("full")
		vehicle:SetPermanentData("showroom_cost", data.cost)
		vehicle:SetPermanentData("showroom_date", getRealTime().timestamp)
		vehicle:SetPermanentData("first_owner", sOwnerPID)

		data.player:AddVehicleToList( vehicle )

		triggerEvent("OnSpecialVehicleBought", vehicle)
	end
end
addEvent("OnBoatMarketVehicleAdded", true)
addEventHandler( "OnBoatMarketVehicleAdded", resourceRoot, OnBoatMarketVehicleAdded )