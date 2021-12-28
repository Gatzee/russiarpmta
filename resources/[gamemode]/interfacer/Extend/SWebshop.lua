Import( "ShWebshop" )

PACKS = {
    -- Оффер X2
    [ 601 ] = {
        name = "Х2",
        fn = function( self, player, profit, transaction_id, sum )
            player:GiveDonate( sum * 2, "donate_pack", self.name )
            triggerEvent( "onX2Purchase", player, sum, player:getData( "x2_11day_test" ) )
            return true
        end,
        fn_offline = function( self, client_id, profit, transaction_id, sum )
            client_id:GiveDonate( sum * 2, "donate_pack", self.name )
            triggerEvent( "onX2Purchase_Offline", root, client_id, sum )
            return true
        end,
    },

    -- Оффер X3
    [ 602 ] = {
        name = "Х3",
        fn = function( self, player, profit, transaction_id, sum )
            player:GiveDonate( sum * 3, "donate_pack", self.name )
            return true
        end,
        fn_offline = function( self, client_id, profit, transaction_id, sum )
            client_id:GiveDonate( sum * 3, "donate_pack", self.name )
            return true
        end,
    },

    -- Офферы после 3 дней без покупок
    [ 701 ] = {
        name = "Минимальный",
        price = 79,
        fn = function( self, player, profit, transaction_id, sum )
            player:GiveDonate( 79, "donate_pack", self.name )
            player:GivePremiumExpirationTime( 1 )
            triggerEvent( "on3daysPurchase", player, sum )
            return true
        end
    },

    [ 702 ] = {
        name = "Стандарт",
        price = 149,
        fn = function( self, player, profit, transaction_id, sum )
            player:GiveDonate( 149, "donate_pack", self.name )
            player:GivePremiumExpirationTime( 2 )
            triggerEvent( "on3daysPurchase", player, sum )
            return true
        end
    },

    [ 703 ] = {
        name = "Солидный",
        price = 199,
        fn = function( self, player, profit, transaction_id, sum )
            player:GiveDonate( 199, "donate_pack", self.name )
            player:GivePremiumExpirationTime( 3 )
            triggerEvent( "on3daysPurchase", player, sum )
            return true
        end
    },

    [ 704 ] = {
        name = "Лучший",
        price = 249,
        fn = function( self, player, profit, transaction_id, sum )
            player:GiveDonate( 249, "donate_pack", self.name )
            player:GivePremiumExpirationTime( 3 )
            player:InventoryAddItem( IN_FIRSTAID, nil, 2 )
            player:InventoryAddItem( IN_REPAIRBOX, nil, 2 )
            player:InventoryAddItem( IN_JAILKEYS, nil, 2 )
            triggerEvent( "on3daysPurchase", player, sum )
            return true
        end
    },


    [ 801 ] = {
        name = "Базовый",
        price = 99,
        fn = function( self, player, profit, transaction_id, sum )
            player:InventoryAddItem( IN_CANISTER, nil, 2 )
            player:InventoryAddItem( IN_REPAIRBOX, nil, 2 )
            player:InventoryAddItem( IN_JAILKEYS, nil, 1 )
            player:InventoryAddItem( IN_FIRSTAID, nil, 2 )
            player:GivePremiumExpirationTime( 1 )

            triggerEvent( "onServerPlayerPurchaseOfferComfort", player, 3, "basic", 99 )
            return true
        end
    },

    [ 802 ] = {
        name = "Стандартный",
        price = 149,
        fn = function( self, player, profit, transaction_id, sum )
            player:InventoryAddItem( IN_CANISTER, nil, 3 )
            player:InventoryAddItem( IN_REPAIRBOX, nil, 3 )
            player:InventoryAddItem( IN_JAILKEYS, nil, 2 )
            player:InventoryAddItem( IN_FIRSTAID, nil, 3 )
            player:GivePremiumExpirationTime( 3 )

            triggerEvent( "onServerPlayerPurchaseOfferComfort", player, 3, "standart", 149 )
            return true
        end
    },

    [ 803 ] = {
        name = "Комфортный",
        price = 199,
        fn = function( self, player, profit, transaction_id, sum )
            player:InventoryAddItem( IN_CANISTER, nil, 5 )
            player:InventoryAddItem( IN_REPAIRBOX, nil, 5 )
            player:InventoryAddItem( IN_JAILKEYS, nil, 3 )
            player:InventoryAddItem( IN_FIRSTAID, nil, 5 )
            player:InventoryAddItem( IN_FOOD_LUNCHBOX, 5 )
            player:GivePremiumExpirationTime( 7 )

            triggerEvent( "onServerPlayerPurchaseOfferComfort", player, 3, "comfort", 199 )
            return true
        end
    },

    [ 900 ] = {
        name = "Персональное авто",
        fn = function( self, player, profit, transaction_id, sum )
            local packages =
            { 
                [ 1 ] = { cost = 69,  }, 
                [ 2 ] = { cost = 249, },
                [ 3 ] = { cost = 549, },
                [ 4 ] = { cost = 890, },
            }

            local pack_id = nil
            for k, v in ipairs( packages ) do
                if v.cost == sum then
                    pack_id = k
                    break
                end
            end

            if pack_id then
                triggerEvent( "onPlayerPurchaseOfferVehicle", root, player, pack_id )
                return true
            end

            return false
        end
    },
    
    [ 901 ] = {
        name = "Третий платёж",
        fn = function( self, player, profit, transaction_id, sum )
            return triggerEvent( "onServerPlayerPurchaseOffer3rdPayment", player, sum )
        end
    },

    [ 902 ] = {
        name = "Последние богатства",
        fn = function( self, player, profit, transaction_id, sum )
            triggerEvent( "onServerPlayerPurchasedDonate", root, player, sum )
            return true
        end
    },

    [ 903 ] = {
        name = "День святого Валентина",
        fn = function( self, player, profit, transaction_id, sum )
            triggerEvent( "onServerPlayerPurchaseValentinePack", root, player, sum )
            return true
        end
    },

    [ 904 ] = {
        name = "День защитника отечества",
        fn = function( self, player, profit, transaction_id, sum )
            triggerEvent( "onServerPlayerPurchaseDefenderFatherlandDayPack", root, player, sum )
            return true
        end
    },

    [ 905 ] = {
        name = "Скидочный дар",
        fn = function( self, player, profit, transaction_id, sum )
            triggerEvent( "onServerPlayerPurchaseDiscountGiftPack", root, player, sum )
            return true
        end
    },

    [ 906 ] = {
        name = "Сезонный Майский пак валюты",
        fn = function( self, player, profit, transaction_id, sum )
            triggerEvent( "BP:onPlayerPurchaseHardOffer", player, sum )
            return true
        end
    },

    [ 907 ] = {
        name = "Двойной беспредел",
        fn = function( self, player, profit, transaction_id, sum )
            triggerEvent( "onServerPlayerPurchasedDoubleMayhem", player, sum )
            return true
        end
    },
 
    -- Оффер после реги
    --[[[ 1001 ] = {
        name = "Новый в городе",
        price = 49,
        payment_type = PAYMENT_METHOD_HARD,
        fn = function( self, player )
            if not player:GetOfferConf( "registration", "purchased" ) then
                player:GiveDonate( 100, self.name, "NRPDszx5x" )
                player:SetOfferConf( "registration", "purchased", true )
                triggerClientEvent( player, "ShowSegmentedPayofferUI", player, false )
                triggerEvent( "onSegmentedoffersPurchase", player, "registration", self.price )
            end
            return true
        end
    },]]
}

-- Premium
-- 10001 - 1 day
-- 10002 - 3 days
-- 10003 - 7 days
-- ....
if PREMIUM_SETTINGS then
    local data = { }
    for days, cost in pairs( PREMIUM_SETTINGS.cost_by_duration ) do
        table.insert( data, { days, cost, PREMIUM_SETTINGS.pack_ids[ days ] } )
    end

    table.sort( data, function( a, b ) return a[ 1 ] < b[ 1 ] end )
    
    for i, v in pairs( data ) do
        local days, cost, pack_id = unpack( v )
        PACKS[ pack_id ] = {
            name = "Премиум " .. days .. " д.",
            price = cost,
            fn = function( self, player, profit, transaction_id, sum )
                player:GivePremiumExpirationTime( days )
                return true
            end,
            fn_offline = function( self, client_id, profit, transaction_id, sum )
                client_id:GivePremiumExpirationTime( days )
                return true
            end
        }
    end


    -- Discount Pack id
    data = { }
    for days, cost in pairs( PREMIUM_SETTINGS.discount_cost_by_duration ) do
        table.insert( data, { days, cost, PREMIUM_SETTINGS.discount_pack_ids[ days ] } )
    end

    table.sort( data, function( a, b ) return a[ 1 ] < b[ 1 ] end )
    
    for i, v in pairs( data ) do
        local days, cost, pack_id = unpack( v )
        PACKS[ pack_id ] = {
            name = "Премиум " .. days .. " д.",
            price = cost,
            fn = function( self, player, profit, transaction_id, sum )
                player:GivePremiumExpirationTime( days )
                return true
            end,
            fn_offline = function( self, client_id, profit, transaction_id, sum )
                client_id:GivePremiumExpirationTime( days )
                return true
            end
        }
    end
end

-- payoffers
for i, data in pairs( WEB_PACKS ) do
    local main = data.main

    for index, pack in pairs( data.packs ) do
        PACKS[ pack.id ] = {
            id = pack.id,
            name = main.name,
            hard = pack.hard,
            price = pack.price,
            limit = pack.limit,
            analytics_id_default = main.analytics_id,
            analytics_id = main.analytics_id and main.analytics_id .. "_" .. index or tostring( index ),
            event = main.event,
            fn = main.fn,
            fn_offline = main.fn_offline,
        }
    end
end