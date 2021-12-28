loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SDB" )
Extend( "SPlayerCommon" )
Extend( "ShTimelib" )

INSTALL_DATE_CONSIDERATION_F4 = 1563483600

function onPlayerSessionStart_handler( session_count, install_date )
    local player = source

    player:GetCommonData( { "segmentedf4_group", "segmentedf4_ready" }, { player }, function( result, player )
        if not isElement( player ) then return end
        if ( install_date or 0 ) < INSTALL_DATE_CONSIDERATION_F4 then return end

        if not result.segmentedf4_group then
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

                    player:SetCommonData( { segmentedf4_group = next_group.group_name } )
                    triggerEvent( "onSegmentedf4GroupLoad", player, next_group.group_name, true )

                    CommonDB:exec( "UPDATE offers_segmentedf4 SET count=`count`+1, today_count=`today_count`+1 WHERE id=? ", next_group.id )
                end
            end, { player },
            "SELECT * FROM offers_segmentedf4" )
        
        elseif result.segmentedf4_group then
            triggerEvent( "onSegmentedf4GroupLoad", player, result.segmentedf4_group )

        end
    end )
end
addEvent( "onPlayerSessionStart", true )
addEventHandler( "onPlayerSessionStart", root, onPlayerSessionStart_handler )

function CleanDatabase( )
    CommonDB:exec( "UPDATE offers_segmentedf4 SET today_count=0" )
    DATABASE_CLEAN_TIMER = setTimer( CleanDatabase, 24 * 60 * 60 * 1000, 1 )
end
ExecAtTime( "00:00", CleanDatabase )

function onSegmentedf4GroupLoad_handler( group_name, is_first_time )
    iprint( "Player load f4 group", group_name, is_first_time )
    if group_name == "group_A" then
        source:SetPrivateData( "f4_only_free_input", true )
    end
end
addEvent( "onSegmentedf4GroupLoad", true )
addEventHandler( "onSegmentedf4GroupLoad", root, onSegmentedf4GroupLoad_handler )