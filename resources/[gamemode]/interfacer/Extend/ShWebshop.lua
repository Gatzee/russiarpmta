-- default format
PACK_FORMAT_DEFAULT_1 = 1
PACK_FORMAT_DEFAULT_2 = 2
PACK_FORMAT_DEFAULT_3 = 3
PACK_FORMAT_DEFAULT_4 = 4
-- format 1
PACK_FORMAT_1_1 = 650
PACK_FORMAT_1_2 = 651
PACK_FORMAT_1_3 = 652
PACK_FORMAT_1_4 = 653
PACK_FORMAT_1_5 = 654
PACK_FORMAT_1_6 = 655
-- format 2
PACK_FORMAT_2_1 = 660
PACK_FORMAT_2_2 = 661
PACK_FORMAT_2_3 = 662
PACK_FORMAT_2_4 = 663
PACK_FORMAT_2_5 = 664
-- format 3
PACK_FORMAT_3_1 = 670

-- hard discount (payoffers)
WEB_PACKS = {
    format_default = {
        main = {
            name = "Акция на донат валюту",
            analytics_id = "universal",
            fn = function( self, player )
                player:GiveDonate( self.hard, "donate_pack", self.analytics_id )
                return true
            end,
            fn_offline = function( self, client_id )
                client_id:GiveDonate( self.hard, "donate_pack", self.analytics_id )
                return true
            end,
        },
        packs = {
            {
                id = PACK_FORMAT_DEFAULT_1,
                hard = 249,
                price = 219,
            },
            {
                id = PACK_FORMAT_DEFAULT_2,
                hard = 800,
                price = 699,
            },
            {
                id = PACK_FORMAT_DEFAULT_3,
                hard = 2150,
                price = 1699,
            },
            {
                id = PACK_FORMAT_DEFAULT_4,
                hard = 6000,
                price = 3999,
            },
        },
    },

    format_1 = {
        main = {
            name = "Акция на донат валюту",
            analytics_id = "donate_offer_more",
            event = "more_donate_pack_offer_purchase",
            fn = function( self, player )
                player:GiveDonate( self.hard, "donate_pack", self.analytics_id )
                triggerEvent( "onPlayerBoughtDonatePack", player, player:GetClientID( ), self.id )
                return true
            end,
            fn_offline = function( self, client_id )
                client_id:GiveDonate( self.hard, "donate_pack", self.analytics_id )
                triggerEvent( "onPlayerBoughtDonatePack", resourceRoot, client_id, self.id )
                return true
            end,
        },
        packs = {
            {
                id = PACK_FORMAT_1_1,
                hard = 249,
                price = 219,
            },
            {
                id = PACK_FORMAT_1_2,
                hard = 800,
                price = 699,
            },
            {
                id = PACK_FORMAT_1_3,
                hard = 2150,
                price = 1699,
            },
            {
                id = PACK_FORMAT_1_4,
                hard = 6000,
                price = 3999,
            },
            {
                id = PACK_FORMAT_1_5,
                hard = 9990,
                price = 5990,
            },
            {
                id = PACK_FORMAT_1_6,
                hard = 29980,
                price = 14990,
            },
        }
    },

    format_2 = {
        main = {
            name = "Акция на донат валюту",
            analytics_id = "donate_offer_locked",
            event = "locked_donate_pack_offer_purchase",
            fn = function( self, player )
                player:GiveDonate( self.hard, "donate_pack", self.analytics_id )
                triggerEvent( "onPlayerBoughtDonatePack", player, player:GetClientID( ), self.id )
                return true
            end,
            fn_offline = function( self, client_id )
                client_id:GiveDonate( self.hard, "donate_pack", self.analytics_id )
                triggerEvent( "onPlayerBoughtDonatePack", resourceRoot, client_id, self.id )
                return true
            end,
        },
        packs = {
            {
                id = PACK_FORMAT_2_1,
                hard = 249,
                price = 219,
            },
            {
                id = PACK_FORMAT_2_2,
                hard = 800,
                price = 699,
            },
            {
                id = PACK_FORMAT_2_3,
                hard = 2150,
                price = 1699,
            },
            {
                id = PACK_FORMAT_2_4,
                hard = 6000,
                price = 3999,
            },
            {
                id = PACK_FORMAT_2_5,
                hard = 16980,
                price = 8490,
            },
        },
    },

    format_3 = {
        main = {
            name = "Акция на донат валюту",
            analytics_id = "donate_offer_limited",
            event = "limited_donate_pack_offer_purchase",
            fn = function( self, player )
                player:GiveDonate( self.hard, "donate_pack", self.analytics_id )
                triggerEvent( "onPlayerBoughtDonatePack", player, player:GetClientID( ), self.id )
                return true
            end,
            fn_offline = function( self, client_id )
                client_id:GiveDonate( self.hard, "donate_pack", self.analytics_id )
                triggerEvent( "onPlayerBoughtDonatePack", resourceRoot, client_id, self.id )
                return true
            end,
        },
        packs = {
            {
                id = PACK_FORMAT_3_1,
                hard = 25000,
                price = 12500,
                limit = 120,
            },
        },
    },
}