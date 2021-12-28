BUSINESSES_BLIPS = { }

function UpdateBusinessBlips( )
    for i, v in pairs( BUSINESSES ) do
        local business_id = v.id

        if BUSINESSES_DATA[ business_id ] then
            local is_purchased = GetBusinessData( v.id, "userid" ) ~= 0
            
            -- Удаляем купленные
            if BUSINESSES_BLIPS[ business_id ] and is_purchased then
                if isElement( BUSINESSES_BLIPS[ business_id ] ) then
                    BUSINESSES_BLIPS[ business_id ]:destroy( )
                    BUSINESSES_BLIPS[ business_id ] = nil
                end

            -- Добавляем свободные
            elseif not BUSINESSES_BLIPS[ business_id ] and not is_purchased then
                BUSINESSES_BLIPS[ business_id ] = createBlip( v.x, v.y, v.z, 52, 2, 255, 255, 255, 255, 0, 150 )

            end
        end
    end
end

function onBusinessLoad_handler( )
    UpdateBusinessBlips( )
end
addEvent( "onBusinessLoad", true )
addEventHandler( "onBusinessLoad", root, onBusinessLoad_handler )