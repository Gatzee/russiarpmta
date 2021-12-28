loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SDB" )
Extend( "SPlayerCommon" )
Extend( "ShTimelib" )

INSTALL_DATE_CONSIDERATION = getTimestampFromString( "30 января 2020 00:00" )
TEST_START_POSTPONE = 11 * 24 * 60 * 60
OFFER_DURATION = 24 * 60 * 60

function onPlayerSessionStart_handler( session_count, install_date )
    local player = source

    player:GetCommonData( { "x2_11day_group", "install_date", "X2_start", "X2_bought" }, { player }, function( result, player )
        if not isElement( player ) then return end

        local install_date = ( tonumber( result.install_date ) or 0 )

        if install_date < INSTALL_DATE_CONSIDERATION then return end
        if getRealTime( ).timestamp - install_date <= TEST_START_POSTPONE then return end

        -- Start group find
        if not result.x2_11day_group then
            local donate_total = player:GetPermanentData( "donate_total" ) or 0
            if donate_total == 0 and ( not result.X2_start or result.X2_bought ) then
				CommonDB:queryAsync( function( query, player )
					if not isElement( player ) then
						dbFree( query )
						return
					end

					local values = query:poll( -1 )

					local sum = 0
					local available_groups = { }
					for i, v in pairs( values ) do
						sum = sum + v.count
						if ( v.count < v.max_count or v.max_count == -1 ) and ( v.today_count < v.today_max_count or v.today_max_count == -1 ) then
							table.insert( available_groups, v )
						end
					end

					if #available_groups > 0 then
						local next_group_num = 1 + ( sum + 1 ) % #available_groups
						local next_group = available_groups[ next_group_num ]

						player:SetCommonData( { x2_11day_group = next_group.group_name } )
						triggerEvent( "onSegmentedX2On11DayGroupLoad", player, next_group.group_name, true )

						triggerEvent( "onX211DaySegmented", player, next_group.group_name == "group_A" )

						CommonDB:exec( "UPDATE offers_segmented_x2_11day SET count=`count`+1, today_count=`today_count`+1 WHERE id=? ", next_group.id )
					end
				end, { player },
				"SELECT * FROM offers_segmented_x2_11day" )
            end
        elseif result.x2_11day_group then
            triggerEvent( "onSegmentedX2On11DayGroupLoad", player, result.x2_11day_group )
        end
    end )
end
addEvent( "onPlayerSessionStart", true )
addEventHandler( "onPlayerSessionStart", root, onPlayerSessionStart_handler )

function CleanDatabase( )
    CommonDB:exec( "UPDATE offers_segmented_x2_11day SET today_count=0" )
    DATABASE_CLEAN_TIMER = setTimer( CleanDatabase, 24 * 60 * 60 * 1000, 1 )
end
ExecAtTime( "00:00", CleanDatabase )

function onSegmentedX2On11DayGroupLoad_handler( group_name, is_first_time )
    if group_name == "group_A" then
		if is_first_time then
			source:SetCommonData( { X2_start = getRealTime( ).timestamp + OFFER_DURATION } )
			triggerClientEvent( source, "onStartX2Request", source, OFFER_DURATION, true, "https://pyapi.gamecluster.nextrp.ru/v1.0/payments/pack" )
			triggerEvent( "onX211DayShowFirst", source )
		else
			triggerEvent( "onPlayerOfferX2Available", source )
		end

        source:setData( "x2_11day_test", true, false )
    end
end
addEvent( "onSegmentedX2On11DayGroupLoad", true )
addEventHandler( "onSegmentedX2On11DayGroupLoad", root, onSegmentedX2On11DayGroupLoad_handler )

function onX2Purchase_handler( cost, x2_11day_test )
    local player = source
    
    if x2_11day_test then
        player:setData( "x2_11day_test", false, false )
		player:SetCommonData( { x2_11day_group = "finished" } )
	end
end
addEvent( "onX2Purchase" )
addEventHandler( "onX2Purchase", root, onX2Purchase_handler )