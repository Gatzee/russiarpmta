loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CVehicle" )
Extend( "ShUtils" )

OVERLAYS_CONF = {
    {
        shader = "fx/replace.fx",
        texture = "img/1.jpg",
        fn_start =  function( elements, vehicle )
            dxSetShaderValue( elements.shader, "tTexture", elements.texture )
            if vehicle then
                engineApplyShaderToWorldTexture( elements.shader, "vinil", vehicle )
                engineApplyShaderToWorldTexture( elements.shader, "remap", vehicle )
            else
                engineApplyShaderToWorldTexture( elements.shader, "vinil" )
                engineApplyShaderToWorldTexture( elements.shader, "remap" )
            end
        end
    },
    {
        shader = "fx/replace.fx",
        texture = "img/2.jpg",
        fn_start =  function( elements, vehicle )
            dxSetShaderValue( elements.shader, "tTexture", elements.texture )
            if vehicle then
                engineApplyShaderToWorldTexture( elements.shader, "vinil", vehicle )
                engineApplyShaderToWorldTexture( elements.shader, "remap", vehicle )
            else
                engineApplyShaderToWorldTexture( elements.shader, "vinil" )
                engineApplyShaderToWorldTexture( elements.shader, "remap" )
            end
        end
    },
    {
        shader = "fx/replace.fx",
        texture = "img/3.png",
        fn_start =  function( elements, vehicle )
            dxSetShaderValue( elements.shader, "tTexture", elements.texture )
            if vehicle then
                engineApplyShaderToWorldTexture( elements.shader, "vinil", vehicle )
                engineApplyShaderToWorldTexture( elements.shader, "remap", vehicle )
            else
                engineApplyShaderToWorldTexture( elements.shader, "vinil" )
                engineApplyShaderToWorldTexture( elements.shader, "remap" )
            end
        end
    },
    {
        shader = "fx/replace.fx",
        texture = "img/4.png",
        fn_start =  function( elements, vehicle )
            dxSetShaderValue( elements.shader, "tTexture", elements.texture )
            if vehicle then
                engineApplyShaderToWorldTexture( elements.shader, "vinil", vehicle )
                engineApplyShaderToWorldTexture( elements.shader, "remap", vehicle )
            else
                engineApplyShaderToWorldTexture( elements.shader, "vinil" )
                engineApplyShaderToWorldTexture( elements.shader, "remap" )
            end
        end
    },
    {
        shader = "fx/colorize.fx",
        fn_start =  function( elements, vehicle )
            if vehicle then
                engineApplyShaderToWorldTexture( elements.shader, "vinil", vehicle )
                engineApplyShaderToWorldTexture( elements.shader, "remap", vehicle )
            else
                engineApplyShaderToWorldTexture( elements.shader, "vinil" )
                engineApplyShaderToWorldTexture( elements.shader, "remap" )
            end
        end
    },
    {
        shader = "fx/replace.fx",
        texture = "img/6.png",
        fn_start =  function( elements, vehicle )
            dxSetShaderValue( elements.shader, "tTexture", elements.texture )
            if vehicle then
                engineApplyShaderToWorldTexture( elements.shader, "vinil", vehicle )
                engineApplyShaderToWorldTexture( elements.shader, "remap", vehicle )
            else
                engineApplyShaderToWorldTexture( elements.shader, "vinil" )
                engineApplyShaderToWorldTexture( elements.shader, "remap" )
            end
        end
    },
}

TESTING_OVERLAYS = { }

function Vehicle.AddOverlay( self, id )
    local conf = OVERLAYS_CONF[ id ]

    if not conf then return false, "Такого оверлея не существует" end

    if not TESTING_OVERLAYS[ self ] then TESTING_OVERLAYS[ self ] = { } end

    TESTING_OVERLAYS[ self ] = {
        overlay_id = id,
        elements = {
            shader  = conf.shader and dxCreateShader( conf.shader, 1, 100, true, "vehicle" ),
            texture = conf.texture and dxCreateTexture( conf.texture ),
        }
    }

    if conf.fn_start then
        conf.fn_start( TESTING_OVERLAYS[ self ].elements, self )
    end

    return true
end

function Vehicle.RemoveOverlays( self )
    if TESTING_OVERLAYS[ self ] then
        DestroyTableElements( TESTING_OVERLAYS[ self ].elements )
        TESTING_OVERLAYS[ self ] = nil
        return true
    end
    return false, "На машине не применены никакие наложения"
end

addCommandHandler( "overlay", function( _, vehicle_id, num )
    if not num then num = vehicle_id; vehicle_id = nil end

    local vehicle_id = tonumber( vehicle_id )
    local num = tonumber( num )

    iprint( num, vehicle_id )
    local vehicle = vehicle_id and GetVehicle( vehicle_id ) or localPlayer.vehicle
    
    if not isElement( vehicle ) then
        outputChatBox( "Ты должен быть в автомобиле чтобы включить оверлей, либо указать id машины:", 255, 0, 0 )
        outputChatBox( "/overlay_add vehicle_id overlay_num", 255, 0, 0 )
        return
    end

    if not num then
        local result, err = vehicle:RemoveOverlays( )
        if result then
            outputChatBox( "С машины " .. vehicle:GetID( ) .. " (model " .. vehicle.model .. ") удалены все наложения", 255, 255, 0 )
        else
            outputChatBox( "Ошибка удаления наложения: " .. err, 255, 0, 0 )
        end
    else
        vehicle:RemoveOverlays( )
        local result, err = vehicle:AddOverlay( num )
        if result then
            outputChatBox( "На машине " .. vehicle:GetID( ) .. " (model " .. vehicle.model .. ") включено наложение " .. num, 0, 255, 0 )
        else
            outputChatBox( "Ошибка наложения: " .. err, 255, 0, 0 )
        end
    end
end )

addCommandHandler( "overlay_clear", function( )
    for i, v in pairs( TESTING_OVERLAYS ) do
        v:RemoveOverlays( )
    end
end )

addCommandHandler( "overlay_model", function( cmd, model, num )
    local model = tonumber( model )
    if not model then
        outputChatBox( "Ошибка наложения: не указана модель", 255, 0, 0 )
        return
    end

    local num = tonumber( num )
    if not num then
        outputChatBox( "Ошибка наложения: не указан номер оверлея", 255, 0, 0 )
        return
    end

    local count_replaced = 0

    for i, v in pairs( getElementsByType( "vehicle" ) ) do
        if v.model == model then
            v:RemoveOverlays( )
            local result, err = v:AddOverlay( num )
            count_replaced = count_replaced + ( result and 1 or 0 )
        end
    end

    if count_replaced > 0 then
        outputChatBox( "Наложение применено на " .. count_replaced .. " авто", 0, 255, 0 )
    else
        outputChatBox( "Ошибка наложения: машин с такой моделью не найдено", 255, 0, 0 )
    end
end )

addCommandHandler( "overlay_model_clear", function( cmd, model )
    local model = tonumber( model )
    if not model then
        outputChatBox( "Ошибка наложения: не указана модель", 255, 0, 0 )
        return
    end

    local count_cleared = 0

    for i, v in pairs( getElementsByType( "vehicle" ) ) do
        if v.model == model then
            local result, err = v:RemoveOverlays( )
            count_cleared = count_cleared + ( result and 1 or 0 )
        end
    end

    if count_cleared > 0 then
        outputChatBox( "Наложение очищено на " .. count_cleared .. " авто", 0, 255, 0 )
    else
        outputChatBox( "Ошибка удаления наложений: машин с такой моделью не найдено", 255, 0, 0 )
    end
end )