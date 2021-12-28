loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShVehicleConfig" )
Extend( "ShFood" )
Extend( "ShHobby" )
Extend( "ShClans" )

-- Глобальные enum (для item_conf)
enum "INDEXES" {
    "TYPE",
    "CATEGORY",
    "STATIC",
    "WEIGHT",
    "VISUAL_CONSTRUCT",
    "VISUAL_DATA",
    "CLIENTSIDE_CHECK",
    "CLIENTSIDE_SUCCESS",
    "SERVERSIDE_CHECK",
    "SERVERSIDE_SUCCESS",
}

INVENTORIES = { }

local function CompareAttributes( a1, a2 )
    local a1_size = 0
    for k, v in pairs( a1 ) do
        a1_size = a1_size + 1
        if v ~= a2[ k ] then return false end
    end
    local a2_size = 0
    for k, v in pairs( a2 ) do
        a2_size = a2_size + 1
    end
    return a1_size == a2_size
end

function GetItemWeight( item_id, item_data, count )
    if not (count or item_data.count) then
        iprint( "not (count or item_data.count)", item_id, _item_id_to_str[ item_id ], item_data, count )
        error( "seka", 2 )
    end
    if not ITEMS_CONFIG[ item_id ] then
        iprint( item_id, _item_id_to_str[ item_id ] )
        error( "seka", 2 )
    end
    local item_conf = ITEMS_CONFIG[ item_id ]
    local item_weight = item_conf[ WEIGHT ]
    local weight = type( item_weight ) == "function" and item_weight( item_conf, item_id, item_data and item_data.attributes ) or item_weight or 1
    return weight * ( count or item_data.count )
end

function CreateInventory( owner, data, max_weight, expand_value )
    local self = { 
        owner = owner,
        owner_type = type( owner ) == "string" and "house" or owner.type,
        data = data or {},
        max_weight = ( max_weight or 50 ) + ( expand_value or 0 ),
        expand_value = expand_value or 0,
        total_weight = 0,
    }

    for item_id, item_container in pairs( self.data ) do
        if item_container[ 1 ] > 0 then
            self.total_weight = self.total_weight + GetItemWeight( item_id, _, item_container[ 1 ] )
        end
        for i = #item_container, 2, -1 do
            local item_data = item_container[ i ]
            if item_data.attributes._temp then
                -- Очистка временных предметов (при создании инвентаря игрока (при логине) или машины (при первом открытии))
                table.remove( item_container, i )
            else
                self.total_weight = self.total_weight + GetItemWeight( item_id, item_data )
            end
        end
    end

    function self:GetItemCount( item_id, attributes, temp )
        local item_container = self.data[ item_id ]
        if not item_container then return 0 end

        if temp then
            attributes = attributes or { }
            attributes._temp = true
        end

        if attributes == false then -- общее колво
            local total_count = item_container[ 1 ]
            for i = 2, #item_container do
                total_count = total_count + item_container[ i ].count
            end
            return total_count

        elseif attributes == nil then -- только без атрибутов
            return item_container[ 1 ]

        else -- только с нужными атрибутами
            for i = 2, #item_container do
                local item_data = item_container[ i ]
                if CompareAttributes( attributes, item_data.attributes ) then
                    return item_data.count
                end
            end
            return 0
        end
    end

    function self:AddItem( item_id, attributes, add_count, temp )
        add_count = add_count or 1
        if temp then
            attributes = attributes or { }
            attributes._temp = true
        end

        local item_container = self.data[ item_id ]
        if item_container then
            if not attributes then
                item_container[ 1 ] = item_container[ 1 ] + add_count
            else
                local exists_already = false
                for i = 2, #item_container do
                    local item_data = item_container[ i ]
                    if CompareAttributes( attributes, item_data.attributes ) then
                        exists_already = true
                        item_data.count = ( item_data.count or 1 ) + add_count
                        break
                    end
                end
                if not exists_already then
                    table.insert( item_container, {
                        count = add_count,
                        attributes = attributes,
                    } )
                end
            end
        elseif attributes then
            self.data[ item_id ] = {
                0,
                {
                    count = add_count,
                    attributes = attributes,
                },
            }
        else
            self.data[ item_id ] = { add_count }
        end

        local weight = GetItemWeight( item_id, attributes, add_count )
        self.total_weight = self.total_weight + weight

        onInventoryChange( self, item_id, weight )
    end

    function self:AddIfNotExists( item_id, attributes )
        if self:GetItemCount( item_id, attributes ) <= 0 then
            self:AddItem( item_id, attributes )
        end
    end

    -- при remove_count == nil
    --   и attributes == nil -- удалить всё, игноря атрибуты (но если temp == true, то удаляются только временные)
    --   и attributes ~= nil -- удалить всё, отфильтровав по attributes
    function self:RemoveItem( item_id, attributes, remove_count, temp )
        local item_container = self.data[ item_id ]
        if not item_container then return end

        if temp then
            if not attributes then attributes = {} end
            attributes._temp = true
        end

        local removed_weight = 0
        if not attributes and not remove_count then
            if temp then
                for i = #item_container, 2, -1 do
                    local item_data = item_container[ i ]
                    if item_data.attributes._temp then
                        table.remove( item_container, i )
                        removed_weight = removed_weight + GetItemWeight( item_id, item_data )
                    end
                end
            else
                self.data[ item_id ] = nil
                if item_container[ 1 ] > 0 then
                    removed_weight = GetItemWeight( item_id, {}, item_container[ 1 ] )
                end
                for i = 2, #item_container do
                    local item_data = item_container[ i ]
                    removed_weight = removed_weight + GetItemWeight( item_id, item_data )
                end
            end
        elseif attributes then
            for i = #item_container, 2, -1 do
                local item_data = item_container[ i ]
                if CompareAttributes( attributes, item_data.attributes ) then
                    local count = item_data.count or 1
                    if remove_count and count > remove_count then
                        item_data.count = count - remove_count
                        removed_weight = GetItemWeight( item_id, item_data, remove_count )
                    else
                        table.remove( item_container, i )
                        removed_weight = GetItemWeight( item_id, item_data )
                    end
                    break
                end
            end
        else
            local count = item_container[ 1 ]
            if remove_count and count > remove_count then
                item_container[ 1 ] = count - remove_count
                removed_weight = GetItemWeight( item_id, {}, remove_count )
            else
                item_container[ 1 ] = 0
                removed_weight = GetItemWeight( item_id, {}, count )
            end
        end

        self.total_weight = self.total_weight - removed_weight

        onInventoryChange( self, item_id, -removed_weight )
    end

    function self:Clear()
        self.data = {}
        self.total_weight = 0
        onInventoryChange( self )
    end

    INVENTORIES[ self.owner ] = self

    if isElement( self.owner ) and self.owner.type == "vehicle" then
        addEventHandler( localPlayer and "onClientElementDestroy" or "onElementDestroy", self.owner, function()
            INVENTORIES[ self.owner ] = nil
        end )
    end

    return self
end

function Inventory_GetItemCount( player, item_id, attributes )
	return INVENTORIES[ player ]:GetItemCount( item_id, attributes )
end

function Inventory_GetById( player, item_id )
    return INVENTORIES[ player ].data[ item_id ] or { 0 }
end

function Inventory_CheckWeight( player, item_id, attributes, count )
    local inventory = INVENTORIES[ player ]
    local item_weight = GetItemWeight( item_id, { attributes = attributes }, count ) 
    return inventory.total_weight + item_weight <= inventory.max_weight
end

function CanShowDocuments( player, target )
    if target ~= player then
        local time = getRealTimestamp( )
        local data = player:getData( "show_document_timeout" )
        if data and data > time then
            localPlayer:ShowError( "Нельзя так часто показывать документы" )
            return false
        end
        
        player:setData( "show_document_timeout", time + 15, false )
    end
    return true
end