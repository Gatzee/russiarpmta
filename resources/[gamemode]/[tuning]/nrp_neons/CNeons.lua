loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CVehicle" )
Extend( "ShNeons" )

NEON_SCALE_COEFF = 2
NEON_BASE_COEFF = 0.5

function NeonManager( )
    local self = {
        vehicles = { },
    }

    function self.update_or_create_neon( vehicle )
        local neon_image = vehicle:getData( "ne_i" ) or 0

        if self.vehicles[ vehicle ] == nil then
            self.create_shader( vehicle, neon_image )
        end

        self.update_shader( vehicle, neon_image )
    end

    function self.destroy_neon( vehicle )
        if self.vehicles[ vehicle ] then
            if self.vehicles[ vehicle ].texture_id then
                self.texture_manager.del_ref( self.vehicles[ vehicle ].texture_id )
            end

            if isElement( self.vehicles[ vehicle ].shader ) then
                destroyElement( self.vehicles[ vehicle ].shader )
            end

            self.vehicles[ vehicle ] = nil

            if not next( self.vehicles ) then
                removeEventHandler( "onClientPreRender", root, self.render_neons )
            end
        end
    end

    function self.create_shader( vehicle, neon_image )
        local neon_image = neon_image or vehicle:getData( "ne_i" ) or 0
        if NEONS_LIST[ neon_image ] == nil then
            self.destroy_neon( vehicle )
            return
        end

        if self.vehicles[ vehicle ] == nil then
            local scale, base_y = self.get_neon_size( vehicle )

            self.vehicles[ vehicle ] = {
                shader = dxCreateShader( "fx/projection.fx", 0, 30, true, "world,object" ),
                texture_id = nil,
                base_y = base_y,
            }

            engineApplyShaderToWorldTexture( self.vehicles[ vehicle ].shader, "*" )
            for i,v in pairs( NEON_REMOVAL_LIST ) do
                engineRemoveShaderFromWorldTexture( self.vehicles[ vehicle ].shader, v )
            end

            dxSetShaderValue( self.vehicles[ vehicle ].shader, "scale", scale )

            removeEventHandler( "onClientPreRender", root, self.render_neons )
            addEventHandler( "onClientPreRender", root, self.render_neons )
        end
    end
    
    function self.update_shader( vehicle, neon_image )
        if self.vehicles[ vehicle ] then
            local neon_image = neon_image or vehicle:getData( "ne_i" ) or 0
            if NEONS_LIST[ neon_image ] == nil then
                self.destroy_neon( vehicle )
                return
            end

            if neon_image ~= self.vehicles[ vehicle ].texture_id then
                self.texture_manager.del_ref( self.vehicles[ vehicle ].texture_id )
                self.texture_manager.add_ref( neon_image )

                self.vehicles[ vehicle ].texture_id = neon_image
                dxSetShaderValue( self.vehicles[ vehicle ].shader, "tex", self.texture_manager.textures[ neon_image ].pointer )
            end
        end
    end

    local neon_size_cache = { }
    setmetatable( neon_size_cache, { __mode = "kv" } )

    function self.get_neon_size( vehicle )
        if neon_size_cache[ vehicle ] == nil then
            local x0, y0, z0, x1, y1, z1 = getElementBoundingBox( vehicle )
            local scale = y1 * NEON_SCALE_COEFF
            local base_y = z0 * NEON_BASE_COEFF

            neon_size_cache[ vehicle ] = { scale, base_y }

            return scale, base_y
        end

        return unpack( neon_size_cache[ vehicle ] )
    end

    function self.render_neons( )
        for vehicle, neon_data in pairs( self.vehicles ) do
            local m = getElementMatrix( vehicle )

            local b1, b2, b3 = m[3][1], m[3][2], m[3][3]
            local c1, c2, c3 = m[4][1], m[4][2], m[4][3]
            local px, py, pz = neon_data.base_y * b1 + c1, neon_data.base_y * b2 + c2, neon_data.base_y * b3 + c3
            local mx, my, mz = c1 - b1, c2 - b2, c3 - b3

            dxSetShaderValue( neon_data.shader, "pos", px, py, pz )
            dxSetShaderValue( neon_data.shader, "mt", mx - px, my - py, mz - pz )
            local rx, ry, rz = getElementRotation( vehicle, "ZYX" )
            dxSetShaderValue( neon_data.shader, "rt", -math.rad( ry ), -math.rad( rx ), -math.rad( rz ) )
        end
    end

    function self.add_texture_manager( texture_manager )
        self.texture_manager = texture_manager
    end

    return self
end

function TextureManager( )
    local self = {
        textures = { },
    }

    function self.create( texture_id )
        if self.textures[ texture_id ] == nil then
            local texture_path = "img/" .. NEONS_LIST[ texture_id ] .. ".dds"
            local texture = dxCreateTexture( texture_path, "dxt3" )
            self.textures[ texture_id ] = {
                refs = 0,
                pointer = texture,
            }
        end
    end

    function self.destroy( texture_id )
        if self.textures[ texture_id ] then
            if isElement( self.textures[ texture_id ].pointer ) then
                destroyElement( self.textures[ texture_id ].pointer )
            end
            self.textures[ texture_id ] = nil
        end
    end

    -- Add texture reference for in-memory cache
    function self.add_ref( texture_id )
        if texture_id then
            if self.textures[ texture_id ] == nil then
                self.create( texture_id )
            end
            self.textures[ texture_id ].refs = self.textures[ texture_id ].refs + 1
        end
    end

    -- Delete references to a texture to know when to remove from cache
    function self.del_ref( texture_id )
        if texture_id then
            if self.textures[ texture_id ] then
                self.textures[ texture_id ].refs = self.textures[ texture_id ].refs - 1
                if self.textures[ texture_id ].refs <= 0 then
                    self.destroy( texture_id )
                end
            end
        end
    end

    return self
end

function StreamingManager( neon_manager )
    local self = {
        max_vehicles = math.huge,
        streamed_vehicles = { },
        vehicles_with_neons = { },
    }

    function self.add_data_change_handlers( vehicle )
        self.remove_data_change_handlers( vehicle )
        addEventHandler( "onClientElementDataChange", vehicle, self.on_client_element_data_change )
    end

    function self.add_destruction_handlers( vehicle )
        self.remove_destruction_handlers( vehicle )
        addEventHandler( "onClientElementStreamOut", vehicle, self.on_client_element_stream_out )
        addEventHandler( "onClientElementDestroy", vehicle, self.on_client_element_stream_out )
    end

    function self.remove_data_change_handlers( vehicle )
        removeEventHandler( "onClientElementDataChange", vehicle, self.on_client_element_data_change )
    end

    function self.remove_destruction_handlers( vehicle )
        removeEventHandler( "onClientElementStreamOut", vehicle, self.on_client_element_stream_out )
        removeEventHandler( "onClientElementDestroy", vehicle, self.on_client_element_stream_out )
    end

    function self.handle_streaming( )
        local streamed_vehicles_list = { }
        for vehicle, _ in pairs( self.streamed_vehicles ) do
            if isElement( vehicle ) and vehicle:GetNeon( ) > 0 then
                table.insert( streamed_vehicles_list, vehicle )
            end
        end
        
        local cam_pos = getCamera( ).position
        table.sort( streamed_vehicles_list, function( a, b )
            return ( cam_pos - a.position ).length < ( cam_pos - b.position ).length
        end )

        -- Add new handlers
        local new_vehicles_with_neons = { }
        for i = 1, math.min( self.max_vehicles, #streamed_vehicles_list ) do
            local vehicle = streamed_vehicles_list[ i ]
            if vehicle then
                new_vehicles_with_neons[ vehicle ] = true

                if not self.vehicles_with_neons[ vehicle ] then
                    self.neon_manager.update_or_create_neon( vehicle )

                    self.add_destruction_handlers( vehicle )
                    self.add_data_change_handlers( vehicle )
                end
            end
        end

        -- Remove old vehicles
        for vehicle, _ in pairs( self.vehicles_with_neons ) do
            if not new_vehicles_with_neons[ vehicle ] then
                self.neon_manager.destroy_neon( vehicle )
                self.remove_data_change_handlers( vehicle )
            end
        end
        
        self.vehicles_with_neons = new_vehicles_with_neons
    end

    function self.on_client_element_stream_in( )
        if getElementType( source ) == "vehicle" then
            self.streamed_vehicles[ source ] = true
            self.add_destruction_handlers( source )
        end
    end

    function self.on_client_element_stream_out( )
        self.remove_data_change_handlers( source )
        self.remove_destruction_handlers( source )

        if self.vehicles_with_neons[ source ] then
            self.neon_manager.destroy_neon( source )
            self.vehicles_with_neons[ source ] = nil
        end

        self.streamed_vehicles[ source ] = nil
    end

    function self.on_client_element_data_change( key, old, new )
        if key == "ne_i" then
            self.neon_manager.update_or_create_neon( source )
        end
    end

    function self.add_neon_manager( neon_manager )
        self.neon_manager = neon_manager
    end

    function self.start( )
        for i, v in pairs( getElementsByType( "vehicle", root, true ) ) do
            self.streamed_vehicles[ v ] = true
        end
        addEventHandler( "onClientElementStreamIn", root, self.on_client_element_stream_in )
        self.timer = setTimer( self.handle_streaming, 500, 0 )
    end

    return self
end

function onSettingsChange_handler( changed, values )
    if changed.count_show_neons then
        streaming_manager.max_vehicles = values.count_show_neons
        streaming_manager.handle_streaming( )
    end
end
addEvent( "onSettingsChange" )
addEventHandler( "onSettingsChange", root, onSettingsChange_handler )

function onClientResourceStart_handler( )
    neon_manager = NeonManager( )
    texture_manager = TextureManager( )
    streaming_manager = StreamingManager( )

    neon_manager.add_texture_manager( texture_manager )
    streaming_manager.add_neon_manager( neon_manager )

    streaming_manager.start( )

    triggerEvent( "onSettingsUpdateRequest", localPlayer, "count_show_neons" )
end
addEventHandler( "onClientResourceStart", resourceRoot, onClientResourceStart_handler )