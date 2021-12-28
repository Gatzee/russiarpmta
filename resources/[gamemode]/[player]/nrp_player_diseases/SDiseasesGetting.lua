Extend( "SDB" )

RANDOMLY_INFECTING_DISEASES = {
    DIS_ABSCESS, 
    DIS_ARVI, 
    DIS_FLU, 
    DIS_INFECTION, 
    DIS_RUBELLA,
}

function InfectRandomPlayers( current_infection_date )
    local selected_disease_id = RANDOMLY_INFECTING_DISEASES[ math.random( #RANDOMLY_INFECTING_DISEASES ) ]
    local current_date = os.time( )
    local players = GetPlayersInGame( )
    local infected_count = 0

    while infected_count < math.ceil( #players * 0.1 ) do
        local i = math.random( #players )
        local player = players[ i ]
        local player_diseases = PLAYERS_DISEASES[ player ]
        -- local disease = player_diseases and player_diseases[ selected_disease_id ]
        -- local last_treat_date = disease and disease.stage == 0 and disease.last_treat_date
        local last_treat_date = player:GetPermanentData( "last_treat_date" )
        local is_recently_recovered = last_treat_date and current_date - last_treat_date < 72 * 60 * 60
        if is_recently_recovered or not player:HasAnyApartment( true ) or math.random( ) < 0.5 then
            table.remove( players, i )
            if player_diseases and not is_recently_recovered then
                if player:SetDisease( selected_disease_id ) then
                    infected_count = infected_count + 1
                end
            end
        end
    end

    SetInfectionTimer( current_infection_date )
    
    CommonDB:exec( [[
        INSERT INTO last_infection_date (server_id, date) VALUES (?, ?)
        ON DUPLICATE KEY UPDATE date = ?
    ]], SERVER_NUMBER, current_infection_date, current_infection_date )
end

function SetInfectionTimer( last_infection_date )
    local current_date = os.time( )
    local dt = last_infection_date and os.date( "*t", last_infection_date )
    local new_infection_date = dt and os.time( { year = dt.year, month = dt.month, day = dt.day + 2, hour = 12 } ) or current_date
    local dt = os.date( "*t", current_date )
    local tomorrow_date = os.time( { year = dt.year, month = dt.month, day = dt.day + 1, hour = 0 } )

    local remaining_time = 0
    if tomorrow_date > new_infection_date then
        remaining_time = math.random( tomorrow_date - current_date )
        new_infection_date = current_date
    else
        remaining_time = new_infection_date + math.random( 12 * 60 * 60 ) - current_date
    end

    setTimer( InfectRandomPlayers, remaining_time * 1000, 1, new_infection_date )
end

addEventHandler( "onResourceStart", resourceRoot, function()
    CommonDB:createTable( "last_infection_date", 
        {
            { Field = "server_id",		Type = "smallint(3)",	        Null = "NO",    Key = "PRI",	Default = "0"	};
            { Field = "date",			Type = "int(11) unsigned",	    Null = "NO",	Key = "", 		Default = "0"	};
        } 
    )

    CommonDB:queryAsync( function( query )
        local result = query:poll( 0 )
        SetInfectionTimer( result and result[ 1 ] and result[ 1 ].date )
    end, { }, "SELECT date FROM last_infection_date WHERE server_id = ? LIMIT 1", SERVER_NUMBER )
end )