loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )

enum "eWeaponTypes" {
	"WEAPON",
	"ARMOR",
	"LICENSE",
}

GOODS_SORT = { 22, 25, 33, 1, 2, 3, 100, }

GOODS = {
    [ 22 ] = {
        item_id = 22,
        name = "makarov",
        cost = 18000,
        currency = "soft",
        ammo = 17,
        verbose_name = "Пистолет Макарова",
        damage = 5,
        class = WEAPON,
        inv_type = IN_WEAPON,
        icon = "img/cart/icons/makarov.png",
        image = "img/items/makarov.png",
        hover_image = "img/items/makarov_phantom.png"
    },
    [ 25 ] = {
        item_id = 25,
        name = "shotgun",
        cost = 54000,
        currency = "soft",
        ammo = 12,
        verbose_name = "Дробовик",
        damage = 20,
        class = WEAPON,
        inv_type = IN_WEAPON,
        icon = "img/cart/icons/shotgun.png",
        image = "img/items/shotgun.png",
        hover_image = "img/items/shotgun_phantom.png"
    },
    [ 33 ] = {
        item_id = 33,
        name = "gun",
        cost = 36000,
        currency = "soft",
        ammo = 10,
        verbose_name = "Ружье",
        damage = 10,
        class = WEAPON,
        inv_type = IN_WEAPON,
        icon = "img/cart/icons/riffle.png",
        image = "img/items/riffle.png",
        hover_image = "img/items/riffle_phantom.png"
    },
    [ 1 ] = {
        item_id = 1,
        name = "light_armor",
        cost = 20000,
        currency = "soft",
        ammo = 25,
        verbose_name = "Легкий бронежилет",
        class = ARMOR,
        inv_type = IN_LIGHTARMOR,
        icon = "img/cart/icons/light_armor.png",
        image = "img/items/light_armor.png",
        hover_image = "img/items/armor_phantom.png"
    },
    [ 2 ] = {
        item_id = 2,
        name = "medium_armor",
        cost = 40000,
        currency = "soft",
        ammo = 50,
        verbose_name = "Средний бронежилет",
        class = ARMOR,
        inv_type = IN_MEDIUMARMOR,
        icon = "img/cart/icons/medium_armor.png",
        image = "img/items/medium_armor.png",
        hover_image = "img/items/armor_phantom.png"
    },
    [ 3 ] = {
        item_id = 3,
        name = "heavy_armor",
        cost = 60000,
        currency = "soft",
        ammo = 75,
        verbose_name = "Тяжелый бронежилет",
        class = ARMOR,
        inv_type = IN_HEAVYARMOR,
        icon = "img/cart/icons/heavy_armor.png",
        image = "img/items/heavy_armor.png",
        hover_image = "img/items/armor_phantom.png"
    },
    [ 100 ] = {
        item_id = 100,
        name = "license",
        cost = 590000,
        currency = "soft",
        ammo = 1,
        verbose_name = "Лицензия на оружие",
        tooltip = "Лицензия на оружие\n(30 дней)",
        class = LICENSE,
        inv_type = IN_GUN_LICENSE,
        icon = "img/cart/icons/license.png",
        image = "img/items/license.png",
        hover_image = "img/items/license_phantom.png"
    },
}

function GetTotalArmorAmmoInStoreCart( armor_id )
    local function get_armor_items( )
        local armors = { }
        for _, pItem in pairs( GOODS ) do
            if pItem.class == ARMOR then
                armors[ pItem.item_id ] = pItem
            end
        end
        return armors
    end

    local armors = get_armor_items( )
    local total_armor_ammo_in_cart = 0
    for item_id, item in pairs(Store.cart_items) do
        if armors[ item_id ] then
            local armor_item = armors[ item_id ]
            total_armor_ammo_in_cart = total_armor_ammo_in_cart + math.floor( armor_item.ammo ) * item.count
        end
    end

    total_armor_ammo_in_cart = total_armor_ammo_in_cart + math.floor( armors[ armor_id ].ammo )

    return total_armor_ammo_in_cart
end

function IsPlayerGunLicenseActive( expiration_time )
    local current_time = getRealTimestamp( )
    local diff_time = expiration_time - current_time

    return diff_time >= 0
end

function CanPlayerBuyGunLicense( pPlayer )
    if pPlayer:GetLevel( ) < 6 then
        return false, "Требуется 6 уровень"
    end

    return true
end
