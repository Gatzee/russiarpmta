loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SDB" )
Extend( "SPlayerCommon" )
Extend( "ShTimelib" )

INSTALL_DATE_CONSIDERATION_ECONOMY = getTimestampFromString( "11 июня 2020 00:00" )

function onX2WelcomeOfferComplete_handler()
    local player = source

    -- Пользователи не из органики не участвуют в распределении
    local utm_source = exports.nrp_elastic:GetTrackedData( player:GetClientID(), "utm_source" )
    if tostring(utm_source or "false" ) ~= "false" then
        return false
    end

    player:GetCommonData( { "offer_new_player_group", "install_date" }, { player }, function( result, player )
        if not isElement( player ) then return end
        if ( tonumber( result.install_date ) or 0 ) < INSTALL_DATE_CONSIDERATION_ECONOMY then return end

        if not result.offer_new_player_group then
            CommonDB:queryAsync( function( result, player )
                if not isElement( player ) then return end

                local values = result:poll( -1 )

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

                    player:SetCommonData( { offer_new_player_group = next_group.group_name } )
                    triggerEvent( "onSegmentedOfferNewPlayerGroupLoad", player, next_group.group_name, true )

                    CommonDB:exec( "UPDATE offers_segmented_offer_new_player_group SET count=`count`+1, today_count=`today_count`+1 WHERE id=? ", next_group.id )

                    triggerEvent( "onComfortOfferStart", player, next_group.group_name )
                end
            end, { player }, "SELECT * FROM offers_segmented_offer_new_player_group" )
        
        else
            triggerEvent( "onSegmentedOfferNewPlayerGroupLoad", player, result.offer_new_player_group )
        end
    end )
end
addEvent( "onX2WelcomeOfferComplete", true )
addEventHandler( "onX2WelcomeOfferComplete", root, onX2WelcomeOfferComplete_handler )

function CleanDatabase( )
    CommonDB:exec( "UPDATE offers_segmented_offer_new_player_group SET today_count=0" )
    DATABASE_CLEAN_TIMER = setTimer( CleanDatabase, 24 * 60 * 60 * 1000, 1 )
end
ExecAtTime( "00:00", CleanDatabase )

function onSegmentedOfferNewPlayerGroupLoad_handler( group_name, is_first_time )
    iprint( "Player load offer new player", group_name, is_first_time )
    if group_name == "group_A" then
        source:SetPrivateData( "offer_segmented_new_player", true, false )
        if is_first_time then
            triggerEvent( "OnServerPlayerOpenComfortOffer", source )
        end
    end
end
addEvent( "onSegmentedOfferNewPlayerGroupLoad", true )
addEventHandler( "onSegmentedOfferNewPlayerGroupLoad", root, onSegmentedOfferNewPlayerGroupLoad_handler )