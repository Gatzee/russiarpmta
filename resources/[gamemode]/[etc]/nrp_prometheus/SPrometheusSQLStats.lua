function SQLWatcher( )
    local self = {
        data = { },
    }

    function self.recieve_stats( gauges, counters )
        local resource_name = getResourceName( sourceResource )

        if self.data[ resource_name ] and not self.data[ resource_name ].next_is_refresh then
            local gauges_old = self.data[ resource_name ].gauges
            for alias, count in pairs( gauges ) do
                gauges_old[ alias ] = math.max( gauges_old[ alias ] or 0, count )
            end
            gauges = gauges_old
        end

        self.data[ resource_name ] = {
            gauges = gauges,
            counters = counters,
            last_updated = getRealTime( ).timestamp,
        }
    end
    addEvent( "onSDBSendConnectionPoolCounter" )
    addEventHandler( "onSDBSendConnectionPoolCounter", root, self.recieve_stats )

    function self.update_timed_metrics( )
        -- Check outdated metrics and remove them
        for resource_name, data in pairs( self.data ) do
            if getRealTime( ).timestamp - data.last_updated >= 120 then
                self.data[ resource_name ] = nil
            end
        end

        self.sql_queue = self.get_sql_queue( )
    end
    self.timed_metrics = setTimer( self.update_timed_metrics, 5000, 0 )

    function self.get_sql_queue( )
        local category = {
            name = "sql_queue",
            type = "gauge",
            help = "Gauge for current sql queue",
            metrics = { },
        }

        for resource_name, data in pairs( self.data ) do
            for alias, value in pairs( data.gauges ) do
                table.insert( category.metrics, {
                    params = {
                        resource_name = resource_name,
                        queue_name = alias,
                    },
                    value = value,
                } )
            end
        end

        return category
    end

    function self.get_sql_counters( )
        local category = {
            name = "sql_counters",
            type = "counter",
            help = "Counter for sql requests",
            metrics = { },
        }

        for resource_name, data in pairs( self.data ) do
            for alias, value in pairs( data.counters ) do
                table.insert( category.metrics, {
                    params = {
                        resource_name = resource_name,
                        queue_name = alias,
                    },
                    value = value,
                } )
            end
        end

        return category
    end

    function self.get_metrics( )
        local data = table.imerge_all( {
            self.sql_queue, self.get_sql_counters( ),
        } )
        
        for i, v in pairs( self.data ) do
            v.next_is_refresh = true
            if i == "nrp_player" then
                iprint( i, v )
            end
        end
        return data
    end

    function self.destroy( )
        DestroyTableElements( self )
        self = nil
    end

    return self
end