function CartGet( )
    return UI_elements.cart or { }
end

function CartIsAdded( class, value )
    if not UI_elements.cart then UI_elements.cart = { } end
    for i, v in pairs( UI_elements.cart ) do
        local are_both_tables = type( value ) == "table" and type( v[ 2 ] ) == "table"
        if v[ 1 ] == class and ( not value or value == v[ 2 ] or are_both_tables and table.compare( value, v[ 2 ] ) ) then
            return true
        end
    end
end

function CartAdd( class, value )
    if not UI_elements.cart then UI_elements.cart = { } end
    if type( value ) == "table" then value = table.copy( value ) end
    table.insert( UI_elements.cart, { class, value } )
    triggerEvent( "onTuningShopCartAdd", resourceRoot, class, value )
end

function CartRemove( class, value, ignore_vehicle_changes )
    if not UI_elements.cart then UI_elements.cart = { } end
    for i = #UI_elements.cart, 1, -1 do
        local v = UI_elements.cart[ i ]
        local are_both_tables = type( value ) == "table" and type( v[ 2 ] ) == "table"
        if v and v[ 1 ] == class and ( not value or value == v[ 2 ] or are_both_tables and table.compare( value, v[ 2 ] ) ) then
            table.remove( UI_elements.cart, i )
            triggerEvent( "onTuningShopCartRemove", resourceRoot, v[ 1 ], v[ 2 ], ignore_vehicle_changes )
        end
    end
end

function CartClear( )
    for i, v in pairs( UI_elements.cart or { } ) do
        triggerEvent( "onTuningShopCartRemove", resourceRoot, v[ 1 ], v[ 2 ] )
    end
    UI_elements.cart = { }
    triggerEvent( "onTuningShopCartClear", resourceRoot )
end

function onTuningShopCartPurchaseCallback_handler( success, updated_data )
    if success then
        CartClear( )
        localPlayer:InfoWindow( "Товар успешно приобретен!" )
        ibBuyProductSound()

        for i, v in pairs( updated_data or { } ) do
            DATA[ i ] = v
        end
    end
end
addEvent( "onTuningShopCartPurchaseCallback", true )
addEventHandler( "onTuningShopCartPurchaseCallback", root, onTuningShopCartPurchaseCallback_handler )
