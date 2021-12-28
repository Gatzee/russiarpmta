function PerformanceWatcher( )
    local self = { }

    function self.update_timed_10s_metrics( )
        self.packet_usage = self.get_packet_usage( )
        self.lua_timing = self.get_lua_timing( )
        self.lua_memory = self.get_lua_memory( )
    end
    self.timed_10s_metrics = setTimer( self.update_timed_10s_metrics, 10000, 0 )

    function self.update_timed_5s_metrics( )
        self.event_stats = self.get_event_stats( )
        self.rpc_stats = self.get_rpc_stats( )
    end
    self.timed_5s_metrics = setTimer( self.update_timed_5s_metrics, 5000, 0 )

	local function convert_value( column_value )
		if column_value == "-" or column_value == "" then return end
		column_value = string.gsub( column_value, "%%", "" )
		column_value = string.gsub( column_value, " KB", "" )
		return column_value
	end

    function self.get_lua_memory( )
        local columns, rows = getPerformanceStats( "Lua memory" )

        local category = {
            name = "lua_memory",
            type = "gauge",
            help = "Lua memory for CPU info and etc",
            metrics = { },
        }

        local function convert_column_name( column_name )
            local column_name = string.gsub( column_name, " ", "_" )
            return column_name
        end

        for row_num, row_values in pairs( rows ) do
            if row_values[ 1 ] ~= "Lua VM totals" then
                local params = { }
                local values = { }

                for column_num, column_name in pairs( columns ) do
                    values[ column_name ] = convert_value( row_values[ column_num ] )
                    if column_num == 1 then
                        params[ convert_column_name( column_name ) ] = convert_value( row_values[ column_num ] )
                    end
                end

                local metric = {
                    params = params,
                    value = tonumber( values.current ),
                }
                metric.params.current = nil

                table.insert( category.metrics, metric )
            end
        end

        table.sort( category.metrics, function( a, b ) return ( a.value or 0 ) > ( b.value or 0 ) end )
        while #category.metrics > 15 do
            table.remove( category.metrics, #category.metrics )
        end

        return category
    end

    function self.get_lua_timing( )
        local columns, rows = getPerformanceStats( "Lua timing" )

        local category = {
            name = "lua_timing",
            type = "gauge",
            help = "Lua timing for CPU info and etc",
            metrics = { },
        }

        local allowed_metric_types = {
            cpu = true,
            time = true,
            calls = true,
        }

        for row_num, row_values in pairs( rows ) do
            for column_num, column_name in pairs( columns ) do
                if column_num > 1 then
                    local mt = split( column_name, "." )[ 2 ]

                    if allowed_metric_types[ mt ] then

                        local column_value = row_values[ column_num ]
                        column_value = ( column_value == "-" or column_value == "" ) and 0 or column_value
                        column_value = string.gsub( column_value, "%%", "" )

                        local resource_name = row_values[ 1 ]

                        if resource_name ~= "" and string.find( column_name, "60s" ) then
                            local metric = {
                                params = {
                                    resource_name = resource_name,
                                    metric_type = mt
                                },
                                value = column_value,
                            }
                            table.insert( category.metrics, metric )
                        end
                    end
                end

            end
        end

        return category
    end

    function self.get_packet_usage( )
        local _, rows = getPerformanceStats( "Packet usage" )
        local columns = {
            "packet_type",
            "incoming_msgs_sec", "incoming_bytes_sec", "incoming_logic_cpu",
            "outcoming_msgs_sec", "outcoming_bytes_sec", "outcoming_msgs_share",
        }

        local category = {
            name = "packets",
            type = "gauge",
            help = "Gauges for main traffic info",
            metrics = { },
        }

        for row_num, row_values in pairs( rows ) do
            for column_num, column_name in pairs( columns ) do

                if column_num > 1 then
                    local column_value = row_values[ column_num ]
                    column_value = convert_value(column_value) or 0

                    local packet_type = string.match( row_values[ 1 ], "%d+_(.*)" )
                    local metric = {
                        params = { packet_type = packet_type, metric_type = column_name },
                        value = column_value,
                    }
                    table.insert( category.metrics, metric )
                end

            end
        end

        return category
    end

    function self.get_event_stats( )
        self.event_stats_data = self.event_stats_data or { }

        local _, rows = getPerformanceStats( "Event Packet usage" )
        for row_num, row_values in pairs( rows ) do
            local sync_type, sync_name, value = row_values[ 1 ], row_values[ 2 ], row_values[ 4 ]
            if sync_type ~= "" then
                sync_type = utf8.gsub( sync_type, " ", "" )
                if not self.event_stats_data[ sync_type ] then
                    self.event_stats_data[ sync_type ] = { }
                end

                self.event_stats_data[ sync_type ][ sync_name ] = ( self.event_stats_data[ sync_type ][ sync_name ] or 0 ) + value
            end
        end

        local category = {
            name = "events",
            type = "counter",
            help = "Counters for event calls (element data and triggers)",
            metrics = { },
        }
        for sync_name, sync_data in pairs( self.event_stats_data or { } ) do
            for event_name, event_value in pairs( sync_data ) do
                local metric = {
                    params = { sync_name = sync_name, event_name = event_name },
                    value = event_value,
                }
                table.insert( category.metrics, metric )
            end
        end
        
        return category
    end

    function self.get_rpc_stats( )
        self.rpc_stats_data = self.rpc_stats_data or { }
        local _, rows = getPerformanceStats( "RPC Packet usage" )
        for _, row_data in pairs( rows ) do
            local rpc_name = string.match( row_data[ 1 ], "%d+_(.*)" )

            if not self.rpc_stats_data[ rpc_name ] then
                self.rpc_stats_data[ rpc_name ] = { }
            end

            self.rpc_stats_data[ rpc_name ].incoming_msg_sec = ( self.rpc_stats_data[ rpc_name ].incoming_msg_sec or 0 ) + ( tonumber( row_data[ 2 ] ) or 0 )
            self.rpc_stats_data[ rpc_name ].outcoming_msg_sec = ( self.rpc_stats_data[ rpc_name ].outcoming_msg_sec or 0 ) + ( tonumber( row_data[ 5 ] ) or 0 )

            self.rpc_stats_data[ rpc_name ].incoming_bytes_sec = ( self.rpc_stats_data[ rpc_name ].incoming_bytes_sec or 0 ) + ( tonumber( row_data[ 3 ] ) or 0 )
            self.rpc_stats_data[ rpc_name ].outcoming_bytes_sec = ( self.rpc_stats_data[ rpc_name ].outcoming_bytes_sec or 0 ) + ( tonumber( row_data[ 6 ] ) or 0 )
        end

        local category = {
            name = "rpc_stats",
            type = "counter",
            help = "Counters for RPC calls",
            metrics = { },
        }
        for rpc_name, rpc_data in pairs( self.rpc_stats_data ) do
            for rpc_category, rpc_value in pairs( rpc_data ) do
                if rpc_value > 0 then
                    table.insert( category.metrics, {
                        params = { rpc_name = rpc_name, rpc_category = rpc_category },
                        value = rpc_value,
                    } )
                end
            end
        end

        return category
    end

    function self.get_metrics( )
        return table.imerge_all( {
            self.packet_usage, self.lua_timing, self.lua_memory, self.event_stats, self.rpc_stats,
        } )
    end

    function self.destroy( )
        DestroyTableElements( self )
        self = nil
    end

    self.update_timed_10s_metrics( )
    self.update_timed_5s_metrics( )
    return self
end