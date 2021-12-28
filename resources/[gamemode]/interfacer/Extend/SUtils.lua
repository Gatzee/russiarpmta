function LogSlackCommand( str, ... )
    local args = { ... }

    for i, v in pairs( args ) do
        if isElement( v ) and getElementType( v ) == "player" then
            local nickname = "*" .. v:GetNickName() .. "*"
            args[ i ] = table.concat( { nickname, " (SERIAL:", v.serial, ", UserID:", v:GetUserID(), ")" }, '' )
        elseif isElement( v ) and getElementType( v ) == "vehicle" then
            local vehicle_name = "*" .. ( VEHICLE_CONFIG[ v.model ] and VEHICLE_CONFIG[ v.model ].model or getVehicleNameFromModel( v.model ) ) .. "*"
            args[ i ] = table.concat( { vehicle_name, " (ID:", v:GetID(), ")" }, '' )
        elseif type( v ) == "number" then
            args[ i ] = "_" .. v .. "_"
        else
            args[ i ] = inspect( v )
        end
        args[ i ] = args[ i ]:gsub( "\"", '\'')
    end

    --iprint( args )

    if #args > 0 then str = string.format( str, unpack( args ) ) end

    local msg_total = str
    local msg_color = "#ff7700"

    local msg_header = "Выполнение команды"
    triggerEvent( "onSlackAlertRequest", root, 3, msg_header, { text = msg_total, color = msg_color, attachment_type = "default" } )
end