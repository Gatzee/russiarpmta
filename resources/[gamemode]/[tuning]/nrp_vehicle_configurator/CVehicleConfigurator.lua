local UI_elements

function InitConfigurator( )
    if not _CONFIGURATOR_INITIALIZED then
        loadstring( exports.interfacer:extend( "Interfacer" ) )( )
        Extend( "CVehicle" )
        Extend( "ShVehicleConfig" )
        Extend( "ib" )
        Extend( "CPlayer" )
        _CONFIGURATOR_INITIALIZED = true
    end
end

function ShowConfiguratorUI( state, conf )
    if state then
		InitConfigurator( )
		
		if conf then
            for i, v in pairs( conf.values ) do
				setModelHandling( localPlayer.vehicle.model, localPlayer.vehicle:GetVariant( ) - 1, i, v )
			end
		else
			local vals = { }
			for i, v in pairs( values ) do
                local k = getVehicleHandling( localPlayer.vehicle )[ v ]
				vals[ v ] = k
			end
			conf = { values = vals }
		end

        ShowConfiguratorUI( false )

        UI_elements = { }

        local x, y = guiGetScreenSize( )
        local sx, sy = 600, 700

        local px, py = ( x - sx ) / 2, ( y - sy ) / 2

        UI_elements.black_bg = ibCreateBackground( 0xaa000000, _, true )
        UI_elements.bg = ibCreateImage( px, py, sx, sy, nil, UI_elements.black_bg, 0xcc000000 )

        ibCreateLabel( 0, 26, sx, 24, "Крутой хендлинг эдитор", UI_elements.bg ):ibBatchData( { align_x = "center", align_y = "center", font = ibFonts.bold_16 } )

        UI_elements.btn_close = ibCreateButton(  sx - 24 - 26, 26, 24, 24, UI_elements.bg, 
                                                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        addEventHandler( "ibOnElementMouseClick", UI_elements.btn_close, function( key, state )
            if key ~= "left" or state ~= "down" then return end
            ShowConfiguratorUI( false )
        end, false )

        local value_edits = { }
        UI_elements.value_edits = value_edits

        local height = 25
        local npx, npy = 10, 70
        for i, v in pairs( values ) do

            local val = conf.values[ v ]
            if type( val ) == "table" then
                val = table.concat( val, "," )
            else
                val = tostring( val )
            end

            UI_elements[ "lbl_" .. v ] = ibCreateLabel( npx, npy, 0, height, v .. ":", UI_elements.bg ):ibBatchData( { align_y = "center", font = ibFonts.regular_10 } )

            UI_elements[ "edit_" .. v ] = ibCreateEdit( npx + UI_elements[ "lbl_" .. v ]:width( ) + 10, npy, 140, height, tostring( val ), UI_elements.bg, 0xffffffff, 0x00000000, 0xffffffff )

            value_edits[ v ] = UI_elements[ "edit_" .. v ]:ibData( "font", ibFonts.bold_10 )

            if npy + height * 2 + 5 > sy then
                npx = npx + 250
                npy = 70
            else
                npy = npy + height + 5
            end
        end

        local bsx, bsy = 150, 30
        local bpx, bpy = 400, 500

        ibCreateLabel( bpx, bpy, bsx, bsy, "Сбросить всю машину", UI_elements.bg ):ibBatchData( { align_x = "center", align_y = "center" } )
        UI_elements.btn_reset = ibCreateButton( bpx, bpy, bsx, bsy, UI_elements.bg, 
                                                nil, nil, nil, 
                                                0x33ffffff, 0x55CCCCCC, 0x77808080 )
        addEventHandler( "ibOnElementMouseClick", UI_elements.btn_reset, function( key, state )
            if key ~= "left" or state ~= "down" then return end
            local vehicle = localPlayer.vehicle
            local model_id = vehicle.model
            local variant = vehicle:GetVariant( )
            local config = VEHICLE_CONFIG[ model_id ].variants[ variant ]
                  
            if config.handling.centerOfMassX then
                config.handling.centerOfMass = {
                    config.handling.centerOfMassX,
                    config.handling.centerOfMassY,
                    config.handling.centerOfMassZ,
                }

                config.handling.centerOfMassX = nil
                config.handling.centerOfMassY = nil
                config.handling.centerOfMassZ = nil
            end

            for key, value in pairs( config.handling ) do
                setModelHandling( model_id, variant - 1, key, value )
            end

			local speed, accleration, handling = getVehicleParameters( vehicle )
            setVehicleParameters( vehicle, speed, accleration, handling )
            triggerServerEvent( "VehConfiguratorReset", localPlayer )
            localPlayer:ShowSuccess( "Настройки сброшены на стандартные" )
        end, false )

        local bsx, bsy = 150, 30
        local bpx, bpy = 400, 500 + 40
        ibCreateLabel( bpx, bpy, bsx, bsy, "Применить", UI_elements.bg ):ibBatchData( { align_x = "center", align_y = "center" } )
        UI_elements.btn_apply = ibCreateButton( bpx, bpy, bsx, bsy, UI_elements.bg, 
                                                nil, nil, nil, 
                                                0x33ffffff, 0x55CCCCCC, 0x77808080 )
        addEventHandler( "ibOnElementMouseClick", UI_elements.btn_apply, function( key, state )
            if key ~= "left" or state ~= "down" then return end

            local values = { }
            for i, v in pairs( value_edits ) do
                local val = v:ibData( "text" )
                local tst = split( val, "," )

                if #tst > 1 then
                    val = tst
                end

                values[ i ] = val
            end
            

            for i, v in pairs( values ) do
				setModelHandling( localPlayer.vehicle.model, localPlayer.vehicle:GetVariant( ) - 1, i, v )
            end
            local speed, accleration, handling = getVehicleParameters( localPlayer.vehicle )
            setVehicleParameters( localPlayer.vehicle, speed, accleration, handling )
            localPlayer:ShowSuccess( "Настройки применены" )
        end, false )

        local bsx, bsy = 150, 30
        local bpx, bpy = 400, 500 + 40 + 40
        ibCreateLabel( bpx, bpy, bsx, bsy, "Скопировать настройки", UI_elements.bg ):ibBatchData( { align_x = "center", align_y = "center" } )
        UI_elements.btn_copy = ibCreateButton( bpx, bpy, bsx, bsy, UI_elements.bg, 
                                                nil, nil, nil, 
                                                0x33ffffff, 0x55CCCCCC, 0x77808080 )

        addEventHandler( "ibOnElementMouseClick", UI_elements.btn_copy, function( key, state )
            if key ~= "left" or state ~= "down" then return end

            local str = { }
            for i, v in pairs( values ) do
                local edit = value_edits[ v ]

                local val = edit:ibData( "text" )
                local tst = split( val, "," )

                if #tst <= 1 then
                    table.insert( str, v .. " = " .. ( tonumber( val ) and val or isbool( val ) and val or '"' .. tostring( val ) .. '"' ) .. "," )
                else
                    table.insert( str, v .. " = { " .. table.concat( tst, ", " ) .. " }," )
                end
            end

            setClipboard( table.concat( str, "\n" ) )
            localPlayer:ShowSuccess( "Настройки скопированы в буфер обмена" )
        end, false )

        local bsx, bsy = 150, 30
        local bpx, bpy = 400, 500 + 40 + 40 + 40
        ibCreateLabel( bpx, bpy, bsx, bsy, "Вставить настройки", UI_elements.bg ):ibBatchData( { align_x = "center", align_y = "center" } )
        UI_elements.btn_paste = ibCreateButton( bpx, bpy, bsx, bsy, UI_elements.bg, 
                                                nil, nil, nil, 
                                                0x33ffffff, 0x55CCCCCC, 0x77808080 )

        addEventHandler( "ibOnElementMouseClick", UI_elements.btn_paste, function( key, state )
            if key ~= "left" or state ~= "down" then return end

            local sx, sy = 400, 400
            local bg = ibCreateImage( x/2 - sx/2, y/2-sy/2, sx, sy, _, _, 0xff111111 )
            local title = ibCreateLabel( 0, 0, sx, 40, "Таблица настроек", bg ):ibBatchData( { align_x = "center", align_y = "center" } )
            local memo = ibCreateWebMemo( 20, 60, sx-40, sy-120, "", bg, 0xffffffff, 0xff222222 )

            ibCreateLabel( 40, sy-50, sx-80, 40, "Применить", bg ):ibBatchData( { align_x = "center", align_y = "center" } )
            UI_elements.btn_memo_apply = ibCreateButton( 40, sy-50, sx-80, 40, bg, 
                                                nil, nil, nil, 
                                                0x33ffffff, 0x55CCCCCC, 0x77808080 )

            addEventHandler( "ibOnElementMouseClick", UI_elements.btn_memo_apply, function( key, state )
                if key ~= "left" or state ~= "down" then return end
                local text = memo:ibData( "text" )
                local tab = string_to_table( text )

                if not tab then 
                    localPlayer:ShowError("Некорректный формат настроек")
                    return 
                end

                iprint( tab )

                triggerServerEvent( "ApplyTableToVehicle_handler", localPlayer, tab )

                destroyElement( bg )
            end, false )
        end, false )

        showCursor( true )

        local bsx, bsy = 200, 30
        local bpx, bpy = 180, 500 + 40 + 40
        ibCreateLabel( bpx, bpy, bsx, bsy, "Скопировать из другой машины", UI_elements.bg ):ibBatchData( { align_x = "center", align_y = "center" } )
        UI_elements.btn_copy = ibCreateButton( bpx, bpy, bsx, bsy, UI_elements.bg, 
                                                nil, nil, nil, 
                                                0x33ffffff, 0x55CCCCCC, 0x77808080 )

        addEventHandler( "ibOnElementMouseClick", UI_elements.btn_copy, function( key, state )
            if key ~= "left" or state ~= "down" then return end
            ShowVehlistUI( true )
        end, false )

        showCursor( true )
    else
        for i, v in pairs( UI_elements or { } ) do
            if isElement( v ) then destroyElement( v ) end
        end
        ShowVehlistUI( false )
        UI_elements = nil
        showCursor( false )
    end
end
addEvent( "ShowConfiguratorUI", true )
addEventHandler( "ShowConfiguratorUI", root, ShowConfiguratorUI )


function ShowVehlistUI( state )
    if state then
        ShowVehlistUI( false )

        local x, y = guiGetScreenSize( )
        local sx, sy = 600, 600

        local px, py = ( x - sx ) / 2, ( y - sy ) / 2

        UI_elements.veh_black_bg = ibCreateBackground( 0xaa000000, _, true )
        UI_elements.veh_bg = ibCreateImage( px, py, sx, sy, nil, UI_elements.veh_black_bg, 0xcc000000 )

        ibCreateLabel( 0, 26, sx, 24, "Выбор машины", UI_elements.veh_bg ):ibBatchData( { align_x = "center", align_y = "center", font = ibFonts.bold_16 } )

        UI_elements.veh_btn_close = ibCreateButton(  sx - 24 - 26, 26, 24, 24, UI_elements.veh_bg, 
                                                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        addEventHandler( "ibOnElementMouseClick", UI_elements.veh_btn_close, function( key, state )
            if key ~= "left" or state ~= "down" then return end
            ShowVehlistUI( false )
        end, false )

        local scroll_sx = sx - 60
        local rows = 14
        local height = 35
        UI_elements.rt, UI_elements.sc = ibCreateScrollpane( 10, 70, scroll_sx, rows * height, UI_elements.veh_bg, { scroll_px = 5 } )

        local npy = 0
        local is_white = true
        for i, v in pairs( VEHICLE_CONFIG ) do
            local bg = ibCreateImage( 0, npy, scroll_sx, height, nil, UI_elements.rt, is_white and 0x55ffffff or 0x33ffffff )

            ibCreateLabel( 10, 0, 10, height, i, bg ):ibBatchData( { align_y = "center", font = ibFonts.bold_12 } )
            ibCreateLabel( 60, 0, 10, height, v.model, bg ):ibBatchData( { align_y = "center", font = ibFonts.regular_12 } )

            for n, modconf in pairs( v.variants ) do
                local bsx, bsy = 70, 30
                local bpx, bpy = scroll_sx - n * 80, ( height - bsy ) / 2

                local modname = tostring( modconf.mod )
                if utf8.len( modname ) <= 1 then
                    modname = "к. " .. n
                end

                ibCreateLabel( bpx, bpy, bsx, bsy, modname, bg ):ibBatchData( { align_x = "center", align_y = "center" } )
                local btn = ibCreateButton( bpx, bpy, bsx, bsy, bg, 
                                                        nil, nil, nil, 
                                                        0x33ffffff, 0x55CCCCCC, 0x77808080 )

                addEventHandler( "ibOnElementMouseClick", btn, function( key, state )
                    if key ~= "left" or state ~= "down" then return end
                    --iprint( "COPY" )
                    triggerServerEvent( "ApplyVehicleToVehicle", localPlayer, i, n )
                end, false )
            end


            npy = npy + height
            is_white = not is_white
        end

        UI_elements.rt:AdaptHeightToContents()

    else
        if isElement( UI_elements and UI_elements.veh_black_bg ) then destroyElement( UI_elements.veh_black_bg ) end

    end
end

function isbool( v )
    return tostring( v ) == "true" or tostring( v ) == "false"
end

function string_to_table( str )
    str = string.gsub( str, "[\n\r]", '"' )
    str = string.gsub( str, " =", '":' )
    str = string.gsub( str, "{", '"{' )
    str = string.gsub( str, "}", '}"' )
    str = '[{"' .. str .. '}]'

    local tab = fromJSON( str )

    if not tab or type( tab ) ~= "table" then
        return
    end

    local output = table.copy( tab )
    tab = nil

    return output
end