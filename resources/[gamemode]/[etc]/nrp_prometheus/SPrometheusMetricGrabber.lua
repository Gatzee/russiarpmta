function MetricGrabber( )
    local self = {
        objects = { },
    }

    self.prefix = "mta_server_"

    function self.add_object( object )
        table.insert( self.objects, object )
    end

    function self.get_all_metrics( )
        -- Get categories array for further conversion
        local categories = { }
        for _, object in pairs( self.objects ) do
            if object and object.get_metrics then
                -- Get specific object categories
                local object_categories = object.get_metrics( )

                -- Add all categories to global array
                for _, object_category_info in pairs( object_categories ) do
                    local object_category_name = object_category_info.name

                    -- Add category type to its name, so that collisions are not possible between same category names
                    object_category_name = self.prefix .. object_category_name .. "_" .. object_category_info.type

                    -- Create category array to global array
                    if not categories[ object_category_name ] then
                        categories[ object_category_name ] = {
                            name = object_category_info.name,
                            type = object_category_info.type,
                            help = object_category_info.help,
                            metrics = { },
                        }
                    end

                    -- Add all metrics if they exist
                    if object_category_info.metrics then
                        for _, metric in pairs( object_category_info.metrics ) do
                            table.insert( categories[ object_category_name ].metrics, metric )
                        end
                    end
                end
            end
        end

        return categories
    end

    function self.get_all_metrics_string( )
        local final_string_list = { }

        local function add_lines( lines )
            final_string_list = table.imerge_all( final_string_list, lines )
        end

        for category_name, category_info in pairs( self:get_all_metrics( ) ) do
            add_lines( {
                string.format( "# HELP %s %s", category_name, category_info.help or "ADD EXPLANATION" ),
                string.format( "# TYPE %s %s", category_name, category_info.type or "gauge" ),
            } )

            for i, metric in pairs( category_info.metrics ) do
                local params = {
                    game_server = SERVER_NUMBER,
                    --game_server_name = get("#server.name") or "unknown",
                }
                for key, value in pairs( metric.params or { } ) do
                    params[ key ] = value
                end

                local merged_params = { }
                for key, value in pairs( params ) do
                    table.insert( merged_params, string.format( '%s="%s"', key, value ) )
                end
                merged_params = table.concat( merged_params, ", " )

                add_lines( {
                    string.format( '%s{%s} %s', category_name, merged_params, metric.value or "" )
                } )
            end
        end

        return table.concat( final_string_list, "\n" )
    end

    return self
end