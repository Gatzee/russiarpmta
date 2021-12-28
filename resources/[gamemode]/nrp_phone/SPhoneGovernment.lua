local requests_handler = {
	fines = function( player )
		local fines = { }

		local gov_data = exports.nrp_factions_gov_ui_control:GetAllGovPercent( )
		for gov_id, data in pairs( gov_data ) do
			fines[ gov_id ] = { }

			for category_id, data in pairs( data.data ) do
				if data.data then
					for data_id, info in pairs( data.data ) do
						fines[ gov_id ][ category_id .."_".. data_id ] = info.points
					end
				else
					fines[ gov_id ][ category_id ] = data.points
				end
			end
		end

		return fines
	end;

	vote = function( player )
		return exports.nrp_factions_gov_voting:GetAllVotesData( )
	end;

	fines2 = function( player )
		local pFinesList = player:GetFines()
		local pListToSend = {}

		for k,v in pairs(pFinesList) do
			table.insert(pListToSend, v.fine_id)
		end

		return pListToSend
	end;

	reports = function( player )
		return true
	end;

	house_pay = function( player )
		local data = {}
		local house_list = exports.nrp_house_sale:GetPlayerHouseList( player )

		for k, house in pairs( house_list[1] or {} ) do
			table.insert( data, {
				type      = "viphouse",
				hid       = house.hid,
				name      = house.name,
				cost_day  = house.daily_cost * ( player:IsPremiumActive() and 0.5 or 1 ),
				paid_days = house.paid_days,
			})
		end

		for k, apartment in pairs( house_list[2] or {} ) do
			table.insert( data, {
				type      = "apartments",
				id        = apartment.id,
				number    = apartment.number,
				name      = "Дом " .. apartment.id .. " квартира #" .. apartment.number ,
				cost_day  = apartment.cost_day * ( player:IsPremiumActive() and 0.5 or 1 ),
				paid_days = apartment.paid_days,
			})
		end

		return data
	end;
}

function onClientRequestGovernmentList_handler( tab )
	if not client then return end
	if not requests_handler[ tab ] then return end

	local data = requests_handler[ tab ]( client )
    triggerClientEvent( client, "onClientRequestGovernmentListCallback", resourceRoot, tab, data )
end
addEvent( "onClientRequestGovernmentList", true )
addEventHandler( "onClientRequestGovernmentList", root, onClientRequestGovernmentList_handler )