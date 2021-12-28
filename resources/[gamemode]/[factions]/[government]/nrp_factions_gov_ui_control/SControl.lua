loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "SPlayer" )
Extend( "SDB" )

DB:createTable( "nrp_government",
	{
		{ Field = "gov_id",		Type = "int(11) unsigned",	Null = "NO",    Key = "PRI",	Default = 0		},
        { Field = "data",		Type = "json",				Null = "YES",	Key = ""                        },
	}
)

local CONST_GOV_STATE_CURRENT_VERSION = 4

local CONST_DEFAULT_GOV_STATE = {
	[ F_GOVERNMENT_NSK ] = {
		points = 15;
		timeout = 0;
		version = CONST_GOV_STATE_CURRENT_VERSION;

		data = {
			businesses = {
				points = 5;
			};
			jobs = {
				points = 5;
			};
			factions = {
				points = 5;
				timeout = 0;
				data = { };
			};
			rating = {
				points = 0;
			};
		};
	};
}
CONST_DEFAULT_GOV_STATE[ F_GOVERNMENT_GORKI ] = table.copy( CONST_DEFAULT_GOV_STATE[ F_GOVERNMENT_NSK ] )
CONST_DEFAULT_GOV_STATE[ F_GOVERNMENT_MSK ] = table.copy( CONST_DEFAULT_GOV_STATE[ F_GOVERNMENT_NSK ] )

for faction_id, gov_id in pairs( FACTIONS_BY_CITYHALL ) do
	local data = CONST_DEFAULT_GOV_STATE[ gov_id ].data
	data.factions.data[ faction_id ] = {
		points = 5;
	}

	if FACTION_RIGHTS.ECONOMY[ gov_id ][ faction_id ] then
		data.factions.data[ faction_id ].timeout = 0
		data.factions.data[ faction_id ].data = { }

		for level in pairs( FACTIONS_LEVEL_NAMES[ faction_id ] ) do
			data.factions.data[ faction_id ].data[ level ] = 5
		end
	end
end

local gov_state = table.copy( CONST_DEFAULT_GOV_STATE )


addEventHandler( "onResourceStart", resourceRoot, function( )
	DB:queryAsync( function( query )
		local results = dbPoll( query, -1 )
		if #results > 0 then
			for i, result in pairs( results ) do
				if result.gov_id then
					gov_state[ result.gov_id ] = fromJSON( result.data )
	
					local new_factions = { }
					for faction_id, faction_data in pairs( gov_state[ result.gov_id ].data.factions.data ) do
						local faction_id = tonumber( faction_id )
						if FACTIONS_BY_CITYHALL[ faction_id ] == result.gov_id then
							new_factions[ faction_id ] = faction_data
						end
					end
	
					gov_state[ result.gov_id ].data.factions.data = new_factions

					if gov_state[ result.gov_id ].version ~= CONST_GOV_STATE_CURRENT_VERSION then
						ResetGovStateToDefault( result.gov_id )
					end
				end
			end
		end
	end, { }, "SELECT gov_id, data FROM nrp_government" )
end )

addEventHandler( "onResourceStop", resourceRoot, function( )
	for gov_id, data in pairs( gov_state ) do
		data_json = toJSON( data, true )
		if data_json then
			DB:exec( DB:prepare( "REPLACE INTO nrp_government ( gov_id, data ) VALUES ( ?, ? )", gov_id, data_json ) )
		end
	end
end )

function ClientRequestShowUIGovControl_handler( )
	if not client then return end
	if not gov_state[ client:GetFaction( ) ] then return end
	if not client:IsFactionOwner( ) then return end

	triggerClientEvent( client, "ShowUIGovControl", resourceRoot, gov_state[ client:GetFaction( ) ] )
end
addEvent( "ClientRequestShowUIGovControl", true )
addEventHandler( "ClientRequestShowUIGovControl", resourceRoot, ClientRequestShowUIGovControl_handler )

function PlayerUpdateGovStateData_handler( new_gov_state, gov_state_chgs, sub_data_names )
	if not client then return end
	if not gov_state[ client:GetFaction( ) ] then return end
	if not client:IsFactionOwner( ) then return end

	local l_gov_state = gov_state[ client:GetFaction( ) ]
	if not l_gov_state then return end

	if sub_data_names then
		for _, name in ipairs( sub_data_names ) do
			l_gov_state = l_gov_state.data[ name ]
			if not l_gov_state then return end
		end
	end

	if l_gov_state.timeout and l_gov_state.timeout > getRealTime( ).timestamp then return end

	local free_points = 0
	local count = 0
	for id, value in pairs( l_gov_state.data ) do
		if not new_gov_state[ id ] then iprint( "not new_gov_state[ id ]", id ) return end
		if gov_state_chgs[ id ] then
			local value_points = ( type( value ) == "table" and value.points or value )
			if gov_state_chgs[ id ] ~= value_points then iprint( "gov_state_chgs[ id ] ~= value_points", id, gov_state_chgs[ id ], value_points ) return end
			if type( value ) == "table" and value.data then
				local data_used_points = 0
				local count = 0
				for i, v in pairs( value.data ) do
					data_used_points = data_used_points + ( type( v ) == "table" and v.points or v )
					count = count + 1
				end

				if ( new_gov_state[ id ] * count - data_used_points ) < 0 then iprint( "( new_gov_state[ id ] * count - data_used_points ) < 0", new_gov_state[ id ], count, data_used_points ) return end
			end
		end

		free_points = free_points - new_gov_state[ id ]
		count = count + 1
	end
	free_points = free_points + l_gov_state.points * ( sub_data_names and count or 1 )

	if free_points < 0 then return end

	for id in pairs( gov_state_chgs ) do
		if type( l_gov_state.data[ id ] ) == "table" then
			l_gov_state.data[ id ].points = new_gov_state[ id ]
		else
			l_gov_state.data[ id ] = new_gov_state[ id ]
		end
	end

	l_gov_state.timeout = getRealTime( ).timestamp + 12 * 60 * 60

	triggerClientEvent( client, "ShowUIGovControl", resourceRoot, gov_state[ client:GetFaction( ) ], true )
end
addEvent( "PlayerUpdateGovStateData", true )
addEventHandler( "PlayerUpdateGovStateData", resourceRoot, PlayerUpdateGovStateData_handler )


function GetFactionGovEconomyPercent( faction_id, faction_level, money )
	local gov_id = FACTIONS_BY_CITYHALL[ faction_id ]
	if gov_id then
		local faction_data = gov_state[ gov_id ].data.factions.data[ faction_id ]
		if faction_data then
			local points = faction_data.points
			if faction_data.data then
				points = faction_data.data[ faction_level ]
			end

			local money_real = money * 0.95
			local percent = ( 100 + points - 5 ) / 100
			money = money * percent
			return money, money_real, money - money_real
		end 
	end

	local money_real = money * 0.95
	return money, money_real, money - money_real
end

function GetJobGovEconomyPercent( city_id, money )
	if city_id then
		local CITY_ID_TO_CITYHALL_ID = {
			[0] = F_GOVERNMENT_NSK;
			[1] = F_GOVERNMENT_GORKI;
			[2] = F_GOVERNMENT_MSK;
		}
		if gov_state[ CITY_ID_TO_CITYHALL_ID[ city_id ] ] then
			local jobs_data = gov_state[ CITY_ID_TO_CITYHALL_ID[ city_id ] ].data.jobs
			if jobs_data then
				local points = jobs_data.points

				local money_real = math.floor( money * 0.95 )
				local percent = ( 100 + points - 5 ) / 100
				money = math.floor( money * percent )
				return money, money_real, money - money_real
			end
		end
	end

	local money_real = math.floor( money * 0.95 )
	return money, money_real, money - money_real
end

function GetBussnessesEconomyPercent( gov_id, money )
	if gov_id and gov_state[ gov_id ] then
		local businesses_data = gov_state[ gov_id ].data.businesses
		if businesses_data then
			local points = businesses_data.points

			local money_real = math.floor( money * 0.95 )
			local percent = ( 100 + points - 5 ) / 100
			money = math.floor( money * percent )
			return money, money_real, money - money_real
		end
	end

	local money_real = math.floor( money * 0.95 )
	return money, money_real, money - money_real
end

function GetMayorRatingEconomyPercent( gov_id )
	if gov_id and gov_state[ gov_id ] then
		local rating_data = gov_state[ gov_id ].data.rating
		if rating_data then
			return ( 100 + rating_data.points * 10 ) / 100
		end
	end

	return 1
end

function GetAllGovPercent(  )
	return gov_state
end

function ResetGovStateToDefault( gov_id )
	gov_state[ gov_id ] = table.copy( CONST_DEFAULT_GOV_STATE[ gov_id ] )
end