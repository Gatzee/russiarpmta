function onStartupFinished( )
    loadstring( exports.interfacer:extend( "Interfacer" ) )( )

    -- Стандартные настройки МТА

    VALID_VALUES = {
        -- Основные параметры синхронизации
        bandwidth_reduction                = "medium",
        player_sync_interval               = 100,
        lightweight_sync_interval          = 1500,
        camera_sync_interval               = 500,
        ped_sync_interval                  = 400,
        unoccupied_vehicle_sync_interval   = 1000,
        keysync_mouse_sync_interval        = 100,
        keysync_analog_sync_interval       = 100,

        -- Параметры основного потока
        busy_sleep_time                    = 20,
        idle_sleep_time                    = 40,

        -- Прочее
        bullet_sync                        = 1,
        donkey_work_interval               = 100,
        ped_syncer_distance                = 100,
        unoccupied_vehicle_syncer_distance = 130,
        vehext_percent                     = 0,
        vehext_ping_limit                  = 100,
    }
    --outputConsole( toJSON( VALID_VALUES, true ) )

    RECENT_VALUES = { }

    local function UpdateSyncSettings( )
        local sync_array_json = MariaGet( "sync_settings" )

        if sync_array_json then
            local sync_array = fromJSON( sync_array_json ) or { }

            for i, v in pairs( sync_array ) do
                if VALID_VALUES[ i ] then
                    local value = tostring( v )

                    if value ~= RECENT_VALUES[ i ] then
                        local result = setServerConfigSetting( i, value, false )
                        if result then
                            outputDebugString( "SYNC: " .. i .. " = " .. value, 0, 255, 255, 255 )
                            RECENT_VALUES[ i ] = value
                        else
                            outputDebugString( "SYNC ERR: " .. i .. " = " .. value, 0, 255, 0, 0 )
                        end
                    end

                end
            end
        end
    end

    UPDATE_SYNC_TIMER = setTimer( UpdateSyncSettings, 5000, 0 )
    UpdateSyncSettings( )
end