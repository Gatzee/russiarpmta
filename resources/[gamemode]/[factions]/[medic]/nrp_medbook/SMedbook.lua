Extend( "SPlayer" )
Extend( "SDB" )

MEDBOOK_MAX_ROWS_COUNT = 20

local PLAYERS_MEDBOOK_DATA = { }

function OnResourceStart( )
    DB:createTable ( "nrp_player_medbook", 
        {
            { Field = "user_id",		Type = "int(11) unsigned",	    Null = "NO",	Key = "PRI",    Default = 0      };
            { Field = "data",			Type = "longtext",				Null = "NO",	Key = "",	    Default = "[[]]" };
        } 
    )
end
addEventHandler( "onResourceStart", resourceRoot, OnResourceStart )

Player.GetMedbook = function( self, callback )
    if PLAYERS_MEDBOOK_DATA[ self ] then
        callback( PLAYERS_MEDBOOK_DATA[ self ] )
    else
        DB:queryAsync( 
            function( query, self )
                local result = query:poll( 0 )
                if not result then return end
                if not isElement( self ) then return end

                PLAYERS_MEDBOOK_DATA[ self ] = result[ 1 ] and fromJSON( result[ 1 ].data ) or { }
                callback( PLAYERS_MEDBOOK_DATA[ self ] )
            end,
            { self },
            "SELECT data FROM nrp_player_medbook WHERE user_id = ? LIMIT 1", self:GetUserID( )
        )
    end
end

function onPlayerShowMedbook_handler( target, new_disease_id, note, is_update )
    local player = client or source
    local last_drugs_use_date = FACTION_RIGHTS.HEALTH[ target:GetFaction() ] and player:GetPermanentData( "last_drugs_use_date" ) or false
    player:GetMedbook( function( medbook )
        if not isElement( target ) then return end
        target:triggerEvent( is_update and "onShowMedbookUI" or "ShowMedbookUI", player, true, 
            medbook, new_disease_id, last_drugs_use_date, note, is_update )
    end )
end
addEvent( "onPlayerShowMedbook" )
addEventHandler( "onPlayerShowMedbook", root, onPlayerShowMedbook_handler )

function onMedicAddNoteToMedbook_handler( target, disease_id, note )
    if not isElement( target ) then return end

    local medbook_data = PLAYERS_MEDBOOK_DATA[ target ]
    if not medbook_data then return end

    table.insert( medbook_data, {
        date = os.time( ), 
        disease_id = disease_id, 
        note = note,
    } )
    if #medbook_data > MEDBOOK_MAX_ROWS_COUNT then
        table.remove( medbook_data, 1 )
    end

    UpdateMedbookData( target, medbook_data )
end
addEvent( "onMedicAddNoteToMedbook", true )
addEventHandler( "onMedicAddNoteToMedbook", root, onMedicAddNoteToMedbook_handler )

local function RemoveRecordByDate( list, recorded_at )
    for i, note_data in ipairs( list or {} ) do
        if note_data.date == recorded_at then
            --outputDebugString( "Удалена запись "..note_data.date )
            return table.remove( list, i )
        end
    end
end

function UpdateMedbookData( medbook_owner, medbook )
    local json = toJSON( medbook or PLAYERS_MEDBOOK_DATA[ medbook_owner ] )
    DB:exec( [[
        INSERT INTO nrp_player_medbook(user_id, data) VALUES (?, ?)
        ON DUPLICATE KEY UPDATE data = VALUES(data);
    ]], tonumber( medbook_owner ) or medbook_owner:GetUserID( ), json )
end

function onAdminRemoveMedbookRecord_handler( medbook_owner, recorded_at )
    -- @recorded_at - время, когда была сделана запись

    if not isElement( client ) then return end
    if not isElement( medbook_owner ) then return end
    if client:GetAccessLevel( ) < ACCESS_LEVEL_SUPERVISOR then return end

    if PLAYERS_MEDBOOK_DATA[ medbook_owner ] then

        local is_removed = RemoveRecordByDate( PLAYERS_MEDBOOK_DATA[ medbook_owner ], recorded_at )
        if is_removed then
            UpdateMedbookData( medbook_owner )
        end
        triggerEvent( "onPlayerShowMedbook", medbook_owner, client, _, _, true )
    else
        DB:queryAsync(
            function( query, client, medbook_owner, recorded_at )
                local result = query:poll( 0 )

                if not result then return end
                if not isElement( client ) then return end
                if not isElement( medbook_owner ) then return end

                PLAYERS_MEDBOOK_DATA[ medbook_owner ] = result[ 1 ] and fromJSON( result[ 1 ].data ) or {}

                local is_removed = RemoveRecordByDate( PLAYERS_MEDBOOK_DATA[ medbook_owner ], recorded_at )
                if is_removed then
                    UpdateMedbookData( medbook_owner )
                end

                triggerEvent( "onPlayerShowMedbook", medbook_owner, client, _, _, true )
            end,
            { client, medbook_owner, recorded_at, },
            "SELECT data FROM nrp_player_medbook WHERE user_id = ? LIMIT 1", medbook_owner:GetUserID( )
        )
    end
end
addEvent( "onAdminRemoveMedbookRecord", true )
addEventHandler( "onAdminRemoveMedbookRecord", resourceRoot, onAdminRemoveMedbookRecord_handler )

function onPlayerPreLogout_handler( )
    PLAYERS_MEDBOOK_DATA[ source ] = nil
end
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_handler )
