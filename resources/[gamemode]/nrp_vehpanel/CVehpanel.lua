UI_elements = { }
MY_VEHICLES = { }

function onVehpanelCreate_handler( vehicle )
    table.insert( MY_VEHICLES, vehicle )
    refreshMyVehicles()
end
addEvent( "onVehpanelCreate", true )
addEventHandler( "onVehpanelCreate", root, onVehpanelCreate_handler )

function refreshMyVehicles()
    if not isElement( UI_elements.window ) then return end

    if isElement( UI_elements.my_vehicles ) then destroyElement( UI_elements.my_vehicles ) end

    UI_elements.my_vehicles = guiCreateGridList( sx / 2, 50, sx / 2 - 20, sy - 100, false, UI_elements.window )

    local model_column = guiGridListAddColumn( UI_elements.my_vehicles, "Модель", 0.25 )
    guiGridListAddColumn( UI_elements.my_vehicles, "Название", 1 )

    for i, v in pairs( MY_VEHICLES ) do
        if isElement( v ) then
            local id = v:GetID()
            local model = v.model
            local name = v:tostring()
            local row = guiGridListAddRow( UI_elements.my_vehicles, model, name )
            guiGridListSetItemData( UI_elements.my_vehicles, row, model_column, id )
        end
    end

end


function ShowVehpanelUI( state )
    if state then
        ShowVehpanelUI( false )

        if not _MODULES_LOADED then
            loadstring( exports.interfacer:extend( "Interfacer" ) )()
            Extend( "Globals" )
            Extend( "CPlayer" )
            Extend( "CVehicle" )
            Extend( "ShVehicleConfig" )
            _MODULES_LOADED = true
        end

        x, y = guiGetScreenSize()
        sx, sy = 400, 400
        UI_elements.window = guiCreateWindow( x / 2 - sx / 2, y / 2 - sy / 2, sx, sy, "Панель транспорта", false )

        UI_elements.close = guiCreateButton( sx - 24, 26, 32, 16, "X", false, UI_elements.window )
        addEventHandler( "onClientGUIClick", UI_elements.close, 
            function( key, state ) 
                if key ~= "left" and state ~= "down" then return end
                ShowVehpanelUI( false )
            end
        , false )



        UI_elements.available_vehicles_label = guiCreateLabel( 10, 25, 200, 20, "Создать новую машину:", false, UI_elements.window )

        UI_elements.available_vehicles = guiCreateGridList( 10, 50, sx / 2 - 20, sy - 100, false, UI_elements.window )

        local model_column = guiGridListAddColumn( UI_elements.available_vehicles, "Модель", 0.25 )
        guiGridListAddColumn( UI_elements.available_vehicles, "Название", 0.6 )
        for i, v in pairs( VEHICLE_CONFIG ) do
            local model = i
            local name = v and v.model or getVehicleNameFromModel( i ) or "Неизв."
            local row = guiGridListAddRow( UI_elements.available_vehicles, model, name )
            guiGridListSetItemData( UI_elements.available_vehicles, row, model_column, model )
        end

        addEventHandler( "onClientGUIClick", UI_elements.available_vehicles, 
            function( key, state ) 
                if key ~= "left" and state ~= "down" then return end
                local item = guiGridListGetSelectedItem( source )
                local model = guiGridListGetItemData( source, item, model_column )
                --iprint( item, model )
                guiSetText( UI_elements.custom_vehicle, model )
            end
        , false )

        UI_elements.custom_vehicle = guiCreateEdit( 10, sy - 40, ( sx / 2 - 20 ) / 2, 27, "", false, UI_elements.window )
        UI_elements.create_vehicle = guiCreateButton( 20 + ( sx / 2 - 20 ) / 2, sy - 40, ( sx / 2 - 20 ) / 2 - 10, 27, "Создать", false, UI_elements.window )

        addEventHandler( "onClientGUIClick", UI_elements.create_vehicle, 
            function( key, state ) 
                if key ~= "left" and state ~= "down" then return end
                local vehicle_id = tonumber( guiGetText( UI_elements.custom_vehicle ) )
                if not vehicle_id then 
                    localPlayer:ShowError( "Выбери машину из правого списка либо введи айди в поле" )
                    return 
                end
                triggerServerEvent( "onVehpanelCreateRequest", localPlayer, vehicle_id )
            end
        , false )

        UI_elements.my_vehicles_label = guiCreateLabel( 20 + ( sx / 2 - 20 ), 25, 100, 20, "Твои машины:", false, UI_elements.window )

        refreshMyVehicles()

        UI_elements.destroy = guiCreateButton( 20 + ( sx / 2 - 20 ), sy - 40, ( sx / 2 - 20 ) / 2 - 10, 27, "Удалить", false, UI_elements.window )
        addEventHandler( "onClientGUIClick", UI_elements.destroy, 
            function( key, state ) 
                if key ~= "left" and state ~= "down" then return end
                local item = guiGridListGetSelectedItem( UI_elements.my_vehicles )
                if not item then 
                    localPlayer:ShowError( "Выбери машину из правого списка чтобы удалить ее" )
                    return 
                end
                local id = guiGridListGetItemData( UI_elements.my_vehicles, item, 1 )
                guiGridListRemoveRow( UI_elements.my_vehicles, item )
                for i, v in pairs( MY_VEHICLES ) do
                    if v:GetID() == id then
                        table.remove( MY_VEHICLES, i )
                        break
                    end
                end
                triggerServerEvent( "onVehpanelDestroyRequest", localPlayer, id )
            end
        , false )


        UI_elements.teleport = guiCreateButton( 20 + ( sx / 2 - 20 ) + ( sx / 2 - 20 ) / 2 + 10, sy - 40, ( sx / 2 - 20 ) / 2 - 10, 27, "Телепорт", false, UI_elements.window )
        addEventHandler( "onClientGUIClick", UI_elements.teleport, 
            function( key, state ) 
                if key ~= "left" and state ~= "down" then return end
                local item = guiGridListGetSelectedItem( UI_elements.my_vehicles )
                if not item then 
                    localPlayer:ShowError( "Выбери машину из правого списка чтобы телепортировать ее к себе" )
                    return 
                end
                local id = guiGridListGetItemData( UI_elements.my_vehicles, item, 1 )
                triggerServerEvent( "onVehpanelTeleportRequest", localPlayer, id )
            end
        , false )

        showCursor( true )
    else
        for i, v in pairs( UI_elements or { } ) do
            if isElement( v ) then destroyElement( v ) end
        end
        UI_elements = { }
        showCursor( false )
    end
end

function ToggleVehpanel_handler()
    ShowVehpanelUI( not UI_elements.window )
end
addEvent( "ToggleVehpanel", true )
addEventHandler( "ToggleVehpanel", root, ToggleVehpanel_handler )