_item_id_to_str = {
    "IN_PASSPORT",
    "IN_JOB_HISTORY",
    "IN_VEHICLE_TEMP_KEY",
    "IN_CASE", -- +
    "IN_REPAIRBOX",
    "IN_FIRSTAID",
    "IN_UNWANTED",
    "IN_NEON",
    "IN_CLOTHES",
    "IN_HIDDEN_WEAPON",
    "IN_DRUGS",
    "IN_WEAPON",
    "IN_HANDS",
    "IN_JAILKEYS",
	"IN_CANISTER",
    "IN_LIGHTARMOR",
    "IN_MEDIUMARMOR",
    "IN_HEAVYARMOR",
    "IN_UNFINES",
    "IN_VEHPROTECTOR",
	"IN_DECAL",
	"IN_PAINTJOB",
    "IN_BOOSTER_DOUBLE_EXP_HOUR",
	"IN_BOOSTER_DOUBLE_EXP_SHIFT",
	"IN_BOOSTER_FREE_REPAIR",
	"IN_BOOSTER_FREE_FUEL",
	"IN_BOOSTER_STAMINA",
	"IN_JAILTIME",
	"IN_VEHICLE_TONER",
	"IN_ANGELA_HANDBAG",
	"IN_NEWYEAR_LETTER",
	"IN_MILITARY",
	"IN_ARMYFREE",
	"IN_SMARTWATCH",
	"IN_RP_CERT",
	"IN_RP_TICKET",
	"IN_VEHICLE_PASSPORT",
	"IN_FOOD",
	"IN_9MAY_RIBBON",
	"IN_1SEPTEMBER_FLOWER",
	"IN_TREASURE_MAP",
	"IN_POLICEID",
	"IN_HDD",
	"IN_TUTORIAL_DOCS",
	"IN_QUEST_MONEY",
	"IN_WEDDING_DIS",
	"IN_WEDDING_START",
	"IN_WEDDING_CHOCO",
	"IN_WEDDING_PANAMHAT",
	"IN_WEDDING_HANDBAG",
	"IN_WEDDING_NECKLACEHOPE",
	"IN_WEDDING_GLASSES_WOODBLACK",
	"IN_MEDBOOK",
	"IN_HOBBY_FISHING_ROD",
	"IN_HOBBY_FISHING_BAIT",
	"IN_HOBBY_HUNTING_RIFFLE",
	"IN_HOBBY_HUNTING_AMMO",
	"IN_HOBBY_DIGGING_SHOVEL",
	"IN_GUN_LICENSE",
	"IN_BAG_MONEY",
	"IN_BATTERY",
	"IN_QUEST_CASE",
	"IN_ASSEMBLY_VEHICLE",
	"IN_FREE_TAXI",
	"IN_TUTORIAL_HASH",
	"IN_BOTTLE_DIRTY",
	"IN_BOTTLE",
	"IN_ALCO",
	"IN_HASH_RAW",
	"IN_HASH_DRY",
	"IN_HASH",

	"IN_FOOD_LUNCHBOX",  -- прописать в SHunger_Shop.lua
	"IN_FOOD_SALAD",
	"IN_FOOD_SOUP",
	"IN_FOOD_NAVY_PASTA",
	"IN_FOOD_CARBONARA",
	"IN_FOOD_UKHA",
	"IN_FOOD_OMELETTE",
	"IN_FOOD_SPAGHETTI_FANICINI",
	"IN_FOOD_FISH_WITH_VEGETABLES",
	"IN_FOOD_CHEESE_SANDWICH",

	"IN_WEAPON_1_BRASSKNUCKLE",
	"IN_WEAPON_2_GOLFCLUB",
	"IN_WEAPON_3_NIGHTSTICK",
	"IN_WEAPON_4_KNIFE",
	"IN_WEAPON_5_BAT",
	"IN_WEAPON_6_SHOVEL",
	"IN_WEAPON_7_POOLSTICK",
	"IN_WEAPON_8_KATANA",
	"IN_WEAPON_9_CHAINSAW",
	"IN_WEAPON_10_DILDO",
	"IN_WEAPON_11_DILDO",
	"IN_WEAPON_12_VIBRATOR",
	"IN_WEAPON_13_VIBRATOR",
	"IN_WEAPON_14_FLOWER",
	"IN_WEAPON_15_CANE",
	"IN_WEAPON_16_GRENADE",
	"IN_WEAPON_17_TEARGAS",
	"IN_WEAPON_18_MOLOTOV",
	"IN_WEAPON_19_ROCKET",
	"IN_WEAPON_20_ROCKET",
	"IN_WEAPON_21_FREEFALL_BOMB",
	"IN_WEAPON_22_COLT_45",
	"IN_WEAPON_23_SILENCED",
	"IN_WEAPON_24_DEAGLE",
	"IN_WEAPON_25_SHOTGUN",
	"IN_WEAPON_26_SAWEDOFF",
	"IN_WEAPON_27_COMBAT_SHOTGUN",
	"IN_WEAPON_28_UZI",
	"IN_WEAPON_29_MP5",
	"IN_WEAPON_30_AK47",
	"IN_WEAPON_31_M4",
	"IN_WEAPON_32_TEC9",
	"IN_WEAPON_33_RIFLE",
	"IN_WEAPON_34_SNIPER",
	"IN_WEAPON_35_ROCKET_LAUNCHER",
	"IN_WEAPON_36_ROCKET_LAUNCHER_HS",
	"IN_WEAPON_37_FLAMETHROWER",
	"IN_WEAPON_38_MINIGUN",
	"IN_WEAPON_39_SATCHEL",
	"IN_WEAPON_40_BOMB",
	"IN_WEAPON_41_SPRAYCAN",
	"IN_WEAPON_42_FIRE_EXTINGUISHER",
	"IN_WEAPON_43_CAMERA",
	"IN_WEAPON_44_NIGHTVISION",
	"IN_WEAPON_45_INFRARED",
	"IN_WEAPON_46_PARACHUTE",

    "IN_TUTORIAL_CANISTER",
}

ITEM_IDS_BY_TYPE = {
    [ IN_WEAPON ] = {
        IN_WEAPON_1_BRASSKNUCKLE,
        IN_WEAPON_2_GOLFCLUB,
        IN_WEAPON_3_NIGHTSTICK,
        IN_WEAPON_4_KNIFE,
        IN_WEAPON_5_BAT,
        IN_WEAPON_6_SHOVEL,
        IN_WEAPON_7_POOLSTICK,
        IN_WEAPON_8_KATANA,
        IN_WEAPON_9_CHAINSAW,
        IN_WEAPON_10_DILDO,
        IN_WEAPON_11_DILDO,
        IN_WEAPON_12_VIBRATOR,
        IN_WEAPON_13_VIBRATOR,
        IN_WEAPON_14_FLOWER,
        IN_WEAPON_15_CANE,
        IN_WEAPON_16_GRENADE,
        IN_WEAPON_17_TEARGAS,
        IN_WEAPON_18_MOLOTOV,
        IN_WEAPON_19_ROCKET,
        IN_WEAPON_20_ROCKET,
        IN_WEAPON_21_FREEFALL_BOMB,
        IN_WEAPON_22_COLT_45,
        IN_WEAPON_23_SILENCED,
        IN_WEAPON_24_DEAGLE,
        IN_WEAPON_25_SHOTGUN,
        IN_WEAPON_26_SAWEDOFF,
        IN_WEAPON_27_COMBAT_SHOTGUN,
        IN_WEAPON_28_UZI,
        IN_WEAPON_29_MP5,
        IN_WEAPON_30_AK47,
        IN_WEAPON_31_M4,
        IN_WEAPON_32_TEC9,
        IN_WEAPON_33_RIFLE,
        IN_WEAPON_34_SNIPER,
        IN_WEAPON_35_ROCKET_LAUNCHER,
        IN_WEAPON_36_ROCKET_LAUNCHER_HS,
        IN_WEAPON_37_FLAMETHROWER,
        IN_WEAPON_38_MINIGUN,
        IN_WEAPON_39_SATCHEL,
        IN_WEAPON_40_BOMB,
        IN_WEAPON_41_SPRAYCAN,
        IN_WEAPON_42_FIRE_EXTINGUISHER,
        IN_WEAPON_43_CAMERA,
        IN_WEAPON_44_NIGHTVISION,
        IN_WEAPON_45_INFRARED,
        IN_WEAPON_46_PARACHUTE,
    },

    [ IN_FOOD ] = {
        IN_FOOD_LUNCHBOX,
        IN_FOOD_SALAD,
        IN_FOOD_SOUP,
        IN_FOOD_NAVY_PASTA,
        IN_FOOD_CARBONARA,
        IN_FOOD_UKHA,
        IN_FOOD_OMELETTE,
        IN_FOOD_SPAGHETTI_FANICINI,
        IN_FOOD_FISH_WITH_VEGETABLES,
        IN_FOOD_CHEESE_SANDWICH,
    },
}

ITEM_ID_TO_WEAPON_ID = {
    [ IN_WEAPON_1_BRASSKNUCKLE ] = 1,
    [ IN_WEAPON_2_GOLFCLUB ] = 2,
    [ IN_WEAPON_3_NIGHTSTICK ] = 3,
    [ IN_WEAPON_4_KNIFE ] = 4,
    [ IN_WEAPON_5_BAT ] = 5,
    [ IN_WEAPON_6_SHOVEL ] = 6,
    [ IN_WEAPON_7_POOLSTICK ] = 7,
    [ IN_WEAPON_8_KATANA ] = 8,
    [ IN_WEAPON_9_CHAINSAW ] = 9,
    [ IN_WEAPON_10_DILDO ] = 10,
    [ IN_WEAPON_11_DILDO ] = 11,
    [ IN_WEAPON_12_VIBRATOR ] = 12,
    [ IN_WEAPON_13_VIBRATOR ] = 13,
    [ IN_WEAPON_14_FLOWER ] = 14,
    [ IN_WEAPON_15_CANE ] = 15,
    [ IN_WEAPON_16_GRENADE ] = 16,
    [ IN_WEAPON_17_TEARGAS ] = 17,
    [ IN_WEAPON_18_MOLOTOV ] = 18,
    [ IN_WEAPON_19_ROCKET ] = 19,
    [ IN_WEAPON_20_ROCKET ] = 20,
    [ IN_WEAPON_21_FREEFALL_BOMB ] = 21,
    [ IN_WEAPON_22_COLT_45 ] = 22,
    [ IN_WEAPON_23_SILENCED ] = 23,
    [ IN_WEAPON_24_DEAGLE ] = 24,
    [ IN_WEAPON_25_SHOTGUN ] = 25,
    [ IN_WEAPON_26_SAWEDOFF ] = 26,
    [ IN_WEAPON_27_COMBAT_SHOTGUN ] = 27,
    [ IN_WEAPON_28_UZI ] = 28,
    [ IN_WEAPON_29_MP5 ] = 29,
    [ IN_WEAPON_30_AK47 ] = 30,
    [ IN_WEAPON_31_M4 ] = 31,
    [ IN_WEAPON_32_TEC9 ] = 32,
    [ IN_WEAPON_33_RIFLE ] = 33,
    [ IN_WEAPON_34_SNIPER ] = 34,
    [ IN_WEAPON_35_ROCKET_LAUNCHER ] = 35,
    [ IN_WEAPON_36_ROCKET_LAUNCHER_HS ] = 36,
    [ IN_WEAPON_37_FLAMETHROWER ] = 37,
    [ IN_WEAPON_38_MINIGUN ] = 38,
    [ IN_WEAPON_39_SATCHEL ] = 39,
    [ IN_WEAPON_40_BOMB ] = 40,
    [ IN_WEAPON_41_SPRAYCAN ] = 41,
    [ IN_WEAPON_42_FIRE_EXTINGUISHER ] = 42,
    [ IN_WEAPON_43_CAMERA ] = 43,
    [ IN_WEAPON_44_NIGHTVISION ] = 44,
    [ IN_WEAPON_45_INFRARED ] = 45,
    [ IN_WEAPON_46_PARACHUTE ] = 46,
}

ITEM_ID_TO_FOOD_ID = {
    -- [ IN_FOOD_LUNCHBOX ] = FOOD_LUNCHBOX,
    [ IN_FOOD_SALAD ] = FOOD_SALAD,
    [ IN_FOOD_SOUP ] = FOOD_SOUP,
    [ IN_FOOD_NAVY_PASTA ] = FOOD_NAVY_PASTA,
    [ IN_FOOD_CARBONARA ] = FOOD_CARBONARA,
    [ IN_FOOD_UKHA ] = FOOD_UKHA,
    [ IN_FOOD_OMELETTE ] = FOOD_OMELETTE,
    [ IN_FOOD_SPAGHETTI_FANICINI ] = FOOD_SPAGHETTI_FANICINI,
    [ IN_FOOD_FISH_WITH_VEGETABLES ] = FOOD_FISH_WITH_VEGETABLES,
    [ IN_FOOD_CHEESE_SANDWICH ] = FOOD_CHEESE_SANDWICH,
}

ROMAN_NUMBERS = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV" }

INVENTORY_STE = {
    -- Паспорт (item_passport)
    { 
        [TYPE] = IN_PASSPORT,
        [CATEGORY] = "documents",
        [STATIC] = true,
        [WEIGHT] = 0,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Паспорт"
                                visual_data.description = "Наведите на игрока чтобы показать паспорт"
                                visual_data.image = "img/items/passport.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока чтобы показать паспорт"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                if target:getData( "CARRY" ) then
                                    local texts = {
                                        "Ах ты шалунишка!",
                                        "Твой котёл уже вскипел",
                                        "Ты чё, ватрушка что-ли?",
                                        "Мы всё видим",
                                        "Есть нормальные люди, а есть любители показать паспорт грузчику",
                                    }  
                                    return false, texts[ math.random( 1, #texts ) ]
                                end
                                if not CanShowDocuments( localPlayer, target ) then return false end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    triggerEvent( "OnPassportShowRequest", player, target )
                                    return true -- делает KEEP_INVENTORY_NODE = true, запрещая удалять элемент
                                end;
    },
    -- Трудовая книжка (item_job_history)
    { 
        [TYPE] = IN_JOB_HISTORY,
        [CATEGORY] = "documents",
        [STATIC] = true,
        [WEIGHT] = 0,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Трудовая книжка"
                                visual_data.description = "Наведите на игрока чтобы показать трудовую книжку"
                                visual_data.image = "img/items/faction_history.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока чтобы показать трудовую книжку"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                if not CanShowDocuments( localPlayer, target ) then return false end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    triggerEvent( "OnPlayerRequestFactionHistory", player, target, player:GetUserID() )
                                    return true -- делает KEEP_INVENTORY_NODE = true, запрещая удалять элемент
                                end;
    },

    -- РП Аттестат
    --[[
    { 
        [TYPE] = IN_RP_CERT,
        [CATEGORY] = "documents",
        [STATIC] = true,
        [WEIGHT] = 0,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "РП Аттестат"
                                visual_data.description = "Наведите на игрока чтобы показать аттестат"
                                visual_data.image = "img/items/cert.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока чтобы показать аттестат"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    triggerEvent( "OnCertShowRequest", player, target )
                                    return true -- делает KEEP_INVENTORY_NODE = true, запрещая удалять элемент
                                end;
    },
    ]]

    {
        [TYPE] = IN_RP_CERT,
        [CATEGORY] = "documents",
        [STATIC] = true,
        [WEIGHT] = 0,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
            local visual_data = { }
            visual_data.text = "-"
            visual_data.description = "-"
            visual_data.image = "img/items/cert.png"
            return visual_data
        end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
            if not isElement( target ) or getElementType( target ) ~= "player" then
                return false, "-"
            end
            if localPlayer.position:distance( target.position ) > 10 then
                return false, "Подойдите ближе!"
            end
            if not CanShowDocuments( localPlayer, target ) then return false end
            return true
        end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
            return true -- делает KEEP_INVENTORY_NODE = true, запрещая удалять элемент
        end;
    },

    -- Билет БК
    { 
        [TYPE] = IN_RP_TICKET,
        [CATEGORY] = "documents",
        [STATIC] = true,
        [WEIGHT] = 0,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                local ticket_id = attributes[1]
                                visual_data.text = "Билет бойцовского клуба"
                                visual_data.description = "Наведите на игрока чтобы показать"
                                visual_data.image = "img/items/ticket_"..ticket_id..".png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока чтобы показать"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                if not CanShowDocuments( localPlayer, target ) then return false end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    triggerEvent( "OnFCTicketShowRequest", player, target )
                                    return true -- делает KEEP_INVENTORY_NODE = true, запрещая удалять элемент
                                end;
    },

    -- Кейс (case)
    {
        [TYPE] = IN_CASE,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                local case_number = attributes[1]
                                local case_config = CASES_LIST[ case_number ] or { }
                                visual_data.text = case_config.Name or "Кейс"
                                visual_data.description = "Наведите на себя чтобы открыть этот кейс"
                                visual_data.image = table.concat( { "img/items/", case_config.Icon or "case_1" ,".png" }, '' )
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" or target ~= localPlayer then
                                    return false, "Наведите на себя чтобы открыть этот кейс"
                                end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    if player ~= target then return end
                                    local case_id = attributes[1]
                                    local result = exports.rpbox:onPlayerUseCase_Handler( player, target, case_id )
                                    if result then
                                        -- Если использовал сам, то убираем
                                        player:ShowInfo( "Вы успешно распаковали кейс" )
                                        return
                                    else
                                        -- Не убираем в случае ошибки
                                        return true
                                    end
                                end;
    },

    -- Ремкомплект (repairbox)
    { 
        [TYPE] = IN_REPAIRBOX,
        [WEIGHT] = 4,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Ремкомплект"
                                visual_data.description = "Наведите на машину, чтобы починить автомобиль"
                                if attributes[1] then
                                    visual_data.description = "Наведите на машину, чтобы починить автомобиль\nИстечёт: " .. formatTimestamp(attributes[1])
                                end
                                visual_data.image = "img/items/repairbox.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                target = target == localPlayer and localPlayer.vehicle or target
                                if not isElement( target ) or getElementType( target ) ~= "vehicle" then
                                    return false, "Наведите на машину, чтобы починить автомобиль"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                if target.health >= 990 then
                                    return false, "Данный транспорт не требует ремонта"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                target = target == player and player.vehicle or target
                                if not isElement( target ) or getElementType( target ) ~= "vehicle" then
                                    return false, "Наведите на машину, чтобы починить автомобиль"
                                end
                                if target:getData( "block_repair" ) then
                                    return false, "Ремонт данного транспорта запрещен"
                                end
                                if target.health >= 990 then
                                    return false, "Данный транспорт не требует ремонта"
                                end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    local vehicle = target == player and player.vehicle or target
                                    local vehicle_max_health = 1000 --vehicle:GetMaxHealth()
                                    vehicle.health = vehicle_max_health
                                    vehicle:Fix()
                                    player:ShowInfo( "Вы починили выбранный транспорт" )
                                end;
    },
    -- Аптечка (firstaid)
    { 
        [TYPE] = IN_FIRSTAID,
        [WEIGHT] = 0.5,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Аптечка"
                                visual_data.description = "Наведите на игрока чтобы вылечить на 50%."
                                if attributes[1] then
                                    visual_data.description = "Наведите на игрока чтобы вылечить на 50%.\nИстечёт: " .. formatTimestamp(attributes[1])
                                end
                                visual_data.image = "img/items/firstaid.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока чтобы вылечить"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                if IsFighting() then
                                    return false, "Невозможно использовать во время боя"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                if not isElement( target ) then
                                    return false
                                end
                                if target.health >= ( target:getData( "max_health" ) or 100 ) then
                                    return false, "Персонаж полностью здоров"
                                end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                local add_value = math.floor( 50 * ( 1 + player:GetClanBuffValue( CLAN_UPGRADE_HEALING ) / 100 ) )
                                target:SetHP( target.health + add_value )
                                player:ShowInfo( ( player == target and "Вы вылечили себя на %s%%." or ( target:GetNickName() .." был вылечен на %s%%." ) ):format( add_value ) )
                            end;
    },
    -- Поддельные документы (unwanted)
    { 
        [TYPE] = IN_UNWANTED,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Поддельные документы"
                                visual_data.description = "Наведите на игрока чтобы снять розыск"
                                visual_data.image = "img/items/unwanted.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Снять розыск можно только себе или другому игроку"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                target:SetWantedData()
                                player:ShowInfo( player == target and "Вы успешно убрали у себя розыск" or ( "Вы успешно убрали розыск у игрока %s" ):format( target:GetNickName() ) )
                            end;
    }, 
    -- Неон (neon)
    { 
        [TYPE] = IN_NEON,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Неон"
                                visual_data.description = "Наведите на машину, чтобы включить возможность установки неона"
                                visual_data.image = "img/items/neon.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "vehicle" then
                                    return false, "Неон можно применить только на свою машину"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                do
                                    return false, "Неизвестная ошибка"
                                end
                                if not isElement( target ) or getElementType( target ) ~= "vehicle" or target:GetOwnerID() ~= source:GetUserID() then
                                    return false, "Неон можно применить только на свою машину"
                                end
                                local vehicle_type = target.vehicleType
                                if vehicle_type ~= "Automobile" or target:GetFlag( "profession" ) then
                                    return false, "Нельзя установить неон на данный транспорт"
                                end
                                -- if target:GetFlag( "neon" ) then
                                --     return false, "Нельзя установить неон на данный транспорт"
                                -- end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    local vehicle = target
                                    -- vehicle:SetFlag( "neon" )
                                    player:ShowInfo( "Вы успешно установили неон на свой транспорт!" )
                                end;
    },
    -- Скин (clothes)
    { 
        [TYPE] = IN_CLOTHES,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local model = attributes[1]
                                local visual_data = { }
                                visual_data.text = SKINS_NAMES[ model ] or "Одежда"
                                visual_data.description = "Наведи на себя чтобы переодеться. Твой обычный скин вернется после выхода из игры"
                                visual_data.image = table.concat( { "img/items/clothes.png" }, '' )
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or target ~= localPlayer then
                                    return false, "Этот предмет можно применить только на себя"
                                end
                                return true
                            end;
        [CLIENTSIDE_SUCCESS] = function( self, item_id, attributes, target )
                                --localPlayer.model = attributes[1]
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    if player:IsOnUrgentMilitary( ) then
                                        player:ShowError( "Нельзя переодеться, находясь на срочной службе" )
                                        return true
                                    end
                                    if player:IsOnFactionDuty( ) then
                                        player:ShowError( "Ты на смене во фракции" )
                                        return true
                                    end
                                    local model = attributes[1]
                                    player.model = model
                                    return true -- делает KEEP_INVENTORY_NODE = true, запрещая удалять элемент
                                end;
    },
    -- Оружие (hidden_weapon)
    { 
        [TYPE] = IN_HIDDEN_WEAPON,
        [CATEGORY] = "weapon",
        [WEIGHT] = function( self, item_id, attributes )
            local weapon_id = attributes[1]
            local weapon_data = WEAPONS_LIST[ weapon_id ] or {}
            return weapon_data.Weight or 1
        end,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                local weapon_id = attributes[1]
                                local weapon_data = WEAPONS_LIST[ weapon_id ] or {}
                                visual_data.text = weapon_data.Name or getWeaponNameFromID( attributes[1] )
                                visual_data.description = "Наведите на себя чтобы выдать оружие. Это оружие не могут отобрать при обыске"
                                visual_data.image = table.concat( { "img/items/", weapon_data.Icon or "weapon_ak" ,".png" }, '' )
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or target ~= localPlayer then
                                    return false, "Оружие можно применить только на себя"
                                end

                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end

                                if target:getData("jailed") then
                                    return false, "Нельзя использовать это в тюрьме!"
                                end

                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    --  player:GiveWeapon( attributes[1], attributes[2] or WEAPONS_LIST[ weapon_id ] and WEAPONS_LIST[ weapon_id ].Ammo, true, false, "Инвентарь" )
                                end;
    },

    -- Наркотики (drugs)
    {
        [TYPE] = IN_DRUGS,
        [WEIGHT] = 0.1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                local drug_number = attributes[ 1 ]
                                local drugs_icons = {
                                    [ 1 ] = "drug_1",
                                    [ 2 ] = "drug_2",
                                    [ 3 ] = "drug_3",
                                }
                                visual_data.text = DRUGS[ drug_number ].name
                                visual_data.description = DRUGS[ drug_number ].desc
                                visual_data.image = table.concat( { "img/items/", drugs_icons[ drug_number ], ".png" }, '' )
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if target ~= localPlayer then
                                    return false, "Перемести на себя чтобы применить наркотик"
                                end
                                if IsFighting() then
                                    return false, "Невозможно использовать во время боя"
                                end
                                return exports.nrp_clans_drugs:SetOnDrugs( attributes[1] )
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    player:SetPermanentData( "last_drugs_use_date", os.time( ) )
                                end;
    },

    -- Оружие (weapon)
    { 
        [TYPE] = IN_WEAPON,
        [CATEGORY] = "weapon",
        [WEIGHT] = function( self, item_id, attributes )
            local weapon_id = ITEM_ID_TO_WEAPON_ID[ item_id ]
            local weapon_data = WEAPONS_LIST[ weapon_id ] or {}
            return weapon_data.Weight or 1
        end,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                local weapon_id = ITEM_ID_TO_WEAPON_ID[ item_id ]
                                local weapon_data = WEAPONS_LIST[ weapon_id ] or {}
                                local ammo = attributes and attributes.ammo or weapon_data.Ammo
                                visual_data.text = weapon_data.Name or getWeaponNameFromID( weapon_id )
                                visual_data.description = "Наведи на себя чтобы получить оружие" .. ( ammo and ( " (" .. ammo .. " пт.)" ) or "" )
                                visual_data.image = table.concat( { "img/items/", weapon_data.Icon or "weapon_ak" ,".png" }, '' )
                                return visual_data
                            end;
                            
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if target ~= localPlayer then
                                    return false, "Наведи на себя, чтобы использовать предмет"
                                end

                                if localPlayer:getData( "jailed" ) then
                                    return false, "Нельзя использовать это в тюрьме!"
                                end

                                if localPlayer.vehicle and localPlayer.vehicleSeat == 0 then return end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                local weapon_id = ITEM_ID_TO_WEAPON_ID[ item_id ]
	                            local weapon_slot = getSlotFromWeapon( weapon_id ) 
	                            local current_weapon_id = player:getWeapon( weapon_slot )
                                if current_weapon_id ~= weapon_id and player:getTotalAmmo( weapon_slot ) > 0 then
                                    return false, "У тебя в руках уже есть оружие такого типа!"
                                end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    local weapon_id = ITEM_ID_TO_WEAPON_ID[ item_id ]
                                    local ammo = attributes and attributes.ammo or WEAPONS_LIST[ weapon_id ].Ammo
                                    exports.nrp_handler_weapons:GiveWeapon( player, weapon_id, ammo, true )
                                end;
    },

    -- Выпуск из тюрьмы (jailkeys)
    {
        [TYPE] = IN_JAILKEYS,
        [WEIGHT] = 0.1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Ключи от камеры"
                                visual_data.description = "Наведите на игрока чтобы выпустить его из тюрьмы"
                                visual_data.image = "img/items/jailkeys.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока чтобы выпустить его из тюрьмы"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
								if not target:getData("jailed") then
                                    return false, "Игрок не заключён"
                                end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    target:Release( _, "Карточка выхода", true)
                                    if player == target then
                                        player:ShowInfo( "Вы свободны" )
                                    else
                                        player:ShowInfo( "Вы освободили игрока " .. target:GetNickName() )
                                        target:ShowInfo( player:GetNickName() .. " освободил вас из тюрьмы" )
                                    end
                                end;
    },

    -- Канистра (canister)
    {
        [TYPE] = IN_CANISTER,
        [WEIGHT] = 4,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Канистра 20 л."
                                visual_data.description = "Наведите на транспорт чтобы заправить на 20 литров"
                                if attributes[1] then
                                    visual_data.description = "Наведите на транспорт чтобы заправить на 20 литров\nИстечёт: " .. formatTimestamp(attributes[1])
                                end
                                visual_data.image = "img/items/canister.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                target = target == localPlayer and localPlayer.vehicle or target
                                if not isElement( target ) or getElementType( target ) ~= "vehicle" then
                                    return false, "Наведите на транспорт чтобы заправить"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                if VEHICLE_CONFIG[ target.model ].is_electric then
                                    return false, "Это электрический транспорт!"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                target = target == player and player.vehicle or target
                                if not isElement( target ) or getElementType( target ) ~= "vehicle" then
                                    return false, "Наведите на транспорт чтобы заправить"
                                end
                                local vehicle = target
                                local fuel = vehicle:GetFuel()
                                local additional_fuel = math.floor( math.min( math.max( vehicle:GetMaxFuel() - fuel, 0 ), 20 ) )
                                if additional_fuel <= 0 then
                                    return false, "Данный транспорт не нуждается в заправке"
                                end
                                return true, { fuel, additional_fuel }
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target, conf )
                                    local vehicle = target == player and player.vehicle or target
                                    local fuel, additional_fuel = conf[1], conf[2]
                                    vehicle:SetFuel( fuel + additional_fuel )
                                    player:ShowInfo( ( "Вы успешно заправили транспорт на %s л." ):format( additional_fuel ) )
                                end;
    },

     -- Батарея (battery)
    {
        [TYPE] = IN_BATTERY,
        [WEIGHT] = 4,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Батарея 25 %."
                                visual_data.description = "Наведите на транспорт чтобы зарядить на 25 %"
                                if attributes[1] then
                                    visual_data.description = "Наведите на транспорт чтобы зарядить на 20 %\nИстечёт: " .. formatTimestamp(attributes[1])
                                end
                                visual_data.image = "img/items/battery.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                target = target == localPlayer and localPlayer.vehicle or target
                                if not isElement( target ) or getElementType( target ) ~= "vehicle" then
                                    return false, "Наведите на транспорт чтобы зарядить"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                if not VEHICLE_CONFIG[ target.model ].is_electric then
                                    return false, "Это не электрический транспорт!"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                target = target == player and player.vehicle or target
                                if not isElement( target ) or getElementType( target ) ~= "vehicle" then
                                    return false, "Наведите на транспорт чтобы зарядить"
                                end
                                local vehicle = target
                                local fuel = vehicle:GetFuel()
                                local max_fuel = vehicle:GetMaxFuel( )
                                local liter = math.ceil( 25 * max_fuel / 100 )
                                local additional_fuel = math.floor( math.min( math.max( max_fuel - fuel, 0 ), liter ) )
                                local percent = math.floor( additional_fuel * 100 / max_fuel )

                                if additional_fuel <= 0 then
                                    return false, "Данный транспорт не нуждается в зарядке"
                                end
                                return true, { fuel, additional_fuel, percent }
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target, conf )
                                    local vehicle = target == player and player.vehicle or target
                                    local fuel, additional_fuel, percent = conf[1], conf[2], conf[3]

                                    vehicle:SetFuel( fuel + additional_fuel )
                                    player:ShowInfo( ( "Вы успешно зарядили транспорт\n на %s " ):format( percent ) .. "%." )
                                end;
    },
    
    -- Легкая броня (25)
    {
        [TYPE] = IN_LIGHTARMOR,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Легкая броня"
                                visual_data.description = "Наведите на игрока, чтобы надеть на него легкий бронежилет"
                                visual_data.image = "img/items/lightarmor.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока, чтобы надеть на него легкий бронежилет"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                if target == localPlayer and localPlayer.armor >= 25 then
                                    return false, "У вас уже есть броня"
                                end
                                if IsFighting() then
                                    return false, "Невозможно использовать во время боя"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                local armor = target.armor
                                if armor >= 25 then
                                    return false, "У игрока уже есть броня"
                                end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    target.armor = 25 + 0.775
                                    if player == target then
                                        player:ShowInfo( "Вы надели бронежилет" )
                                    else
                                        player:ShowInfo( "Вы надели бронежилет на игрока " .. target:GetNickName() )
                                        target:ShowInfo( player:GetNickName() .. " выдал вам легкий бронежилет" )
                                    end
                                end;
    },

    -- Средняя броня (50)
    {
        [TYPE] = IN_MEDIUMARMOR,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Средняя броня"
                                visual_data.description = "Наведите на игрока, чтобы надеть на него средний бронежилет"
                                visual_data.image = "img/items/mediumarmor.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока, чтобы надеть на него легкий бронежилет"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                if target == localPlayer and localPlayer.armor >= 50 then
                                    return false, "У вас уже есть броня"
                                end
                                if IsFighting() then
                                    return false, "Невозможно использовать во время боя"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                local armor = target.armor
                                if armor >= 50 then
                                    return false, "У игрока уже есть броня"
                                end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    target.armor = 50 + 0.775
                                    if player == target then
                                        player:ShowInfo( "Вы надели бронежилет" )
                                    else
                                        player:ShowInfo( "Вы надели бронежилет на игрока " .. target:GetNickName() )
                                        target:ShowInfo( player:GetNickName() .. " выдал вам средний бронежилет" )
                                    end
                                end;
    },

    -- Тяжелая броня
    {
        [TYPE] = IN_HEAVYARMOR,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Тяжелая броня"
                                visual_data.description = "Наведите на игрока, чтобы надеть на него бронежилет"
                                visual_data.image = "img/items/heavyarmor.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока, чтобы надеть на него легкий бронежилет"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                if target == localPlayer and localPlayer.armor >= 100 then
                                    return false, "У вас уже есть броня"
                                end
                                if IsFighting() then
                                    return false, "Невозможно использовать во время боя"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                local armor = target.armor
                                if armor >= 100 then
                                    return false, "У игрока уже есть броня"
                                end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    target.armor = 100 + 0.775
                                    if player == target then
                                        player:ShowInfo( "Вы надели бронежилет" )
                                    else
                                        player:ShowInfo( "Вы надели бронежилет на игрока " .. target:GetNickName() )
                                        target:ShowInfo( player:GetNickName() .. " выдал вам бронежилет" )
                                    end
                                end;
    },
    
    -- Номер знакомого из ДПС (unfines)
    {
        [TYPE] = IN_UNFINES,
    },

    -- Защита машины на час
    {
        [TYPE] = IN_VEHPROTECTOR,
    },

    -- Декали (винилы)
    { 
        [TYPE] = IN_DECAL,
        -- [FLAGS] = {
        --     ALLOW_FAKE_BEHAVIOR = true,
        -- },
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                local decal_variant = attributes[1]
                                local decal_data = VEHICLE_DECALS_VARIANTS[ decal_variant ] or {}
                                visual_data.text = decal_data.name or ( "Винил #" .. tostring(  decal_variant ) )
                                visual_data.description = "Чтобы использовать этот предмет проследуйте в ближайший тюнинг-салон"
                                visual_data.image = table.concat( { ":rpbox_decals/", decal_data.icon or decal_data.image }, '' )
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not localPlayer:getData( "IsWithinTuning", false ) then
                                    return false, "Винилы можно установить только в тюнинг-салоне"
                                end

                                if not localPlayer:getData( "IsWithinDecalEditor", false ) then
                                    return false, "Пожалуйста, перейдите в меню установки винилов"
                                end

                                if not isElement( target ) or not isElementLocal( target ) or target.type ~= "vehicle" then
                                    return false, "Винилы можно установить только на авто"
                                end

                                local decal_variant = attributes[ 1 ]
                                if decal_variant then
                                    triggerEvent( "onClientDecalSetup", target, decal_variant )
                                end

                                if self[ FAKE ] then
                                    Inventory_RemoveClientside( IN_DECAL, { decal_variant }, 1 )
                                end

                                return false
                            end;
        [CLIENTSIDE_SUCCESS] = function( self, item_id, attributes, target )
            
                                end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )                               
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                   
                                end;
    },

    -- Покрасочные работы
    { 
        [TYPE] = IN_PAINTJOB,
        -- [FLAGS] = {
        --     ALLOW_FAKE_BEHAVIOR = true,
        -- },
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                local job_variant = attributes[1]
                                local job_class = tonumber( attributes[2] ) or 1
                                if job_class < 1 or job_class > #VEHICLE_CLASS_NAMES then
                                    outputDebugString( "Класса авто " .. job_class .. " не существует!", 2 )
                                    return visual_data
                                end

                                local jobDescription = VEHICLE_PAINTJOB_VARIANTS[ job_class ][ job_variant ] or {}              
                                local name_tbl = { jobDescription.name or "", "(", tostring( VEHICLE_CLASS_NAMES[ job_class ] ), ")" }                                                              

                                visual_data.text = table.concat( name_tbl, " " )
                                visual_data.description = "Чтобы использовать этот предмет проследуйте в ближайший тюнинг-салон"
                                visual_data.image = table.concat( { ":rpbox_decals/", jobDescription.icon or DEFAULT_PAINTJOB_ICON }, '' )

                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not localPlayer:getData( "IsWithinTuning", false ) then
                                    return false, "Винилы можно установить только в тюнинг-салоне"
                                end  

                                if not isElement( target ) or not isElementLocal( target ) or target.type ~= "vehicle" then
                                    return false, "Винилы можно установить только на авто"
                                end

                                local job_class = tonumber( attributes[2] ) or 1
                                if target:GetClass() ~= job_class then
                                    return false, "Эта покраска предназначена для класса авто: " .. VEHICLE_CLASS_NAMES[ job_class ]
                                end

                                local job_variant = attributes[1]
                                local lastPaintJob = target:GetCustomPaintjob( true )
                                if lastPaintJob and job_variant == lastPaintJob then
                                    return false, "Эта покраска уже установлена"
                                end                                

                                if job_variant then
                                    triggerEvent( "onClientPaintjobSetup", target, job_variant, job_class )
                  
                                    if self[ FAKE ] then
                                        Inventory_RemoveClientside( IN_PAINTJOB, { job_variant, job_class }, 1 )
                                    end
                                end                                

                                return false
                            end;
        [CLIENTSIDE_SUCCESS] = function( self, item_id, attributes, target )

                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )                               
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                   
                                end;
    },

    -- Новые расходники и бустеры

    -- х2 опыт на час
    {
        [TYPE] = IN_BOOSTER_DOUBLE_EXP_HOUR,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "х2 Опыт на час"
                                visual_data.description = "Наведите на себя чтобы активировать х2 опыт на 1 час"
                                visual_data.image = "img/items/booster_exp_hour.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or target ~= localPlayer then
                                    return false, "Нужно применять на себя"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                return player:ApplyBooster( BOOSTER_DOUBLE_EXP_HOUR )
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target, jail_data )
                                    player:ShowInfo( "Вы успешно активировали бустер" )
                                end;
    },

    -- х2 опыт на смену
    {
        [TYPE] = IN_BOOSTER_DOUBLE_EXP_SHIFT,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "х2 Опыт на смену"
                                visual_data.description = "Наведите на себя чтобы активировать х2 опыт до конца смены"
                                visual_data.image = "img/items/booster_exp_shift.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or target ~= localPlayer then
                                    return false, "Нужно применять на себя"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                return player:ApplyBooster( BOOSTER_DOUBLE_EXP_SHIFT )
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target, jail_data )
                                    player:ShowInfo( "Вы успешно активировали бустер" )
                                end;
    },

    -- бесплатный ремонт
    {
        [TYPE] = IN_BOOSTER_FREE_REPAIR,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Бесплатный ремонт на 3 часа"
                                visual_data.description = "Наведите на свой автомобиль, и сможете бесплатно ремонтировать его ближайшие 3 часа"
                                visual_data.image = "img/items/booster_free_repair.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType(target) ~= "vehicle" then
                                    return false, "Нужно применять на автомобиль"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                if target:GetOwnerID() ~= player:GetUserID() then
                                    return false, "Можно применить только на свой автомобиль!"
                                end
                                return player:ApplyBooster( BOOSTER_FREE_REPAIR, {iVehicleID = target:GetID()} )
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target, jail_data )
                                    player:ShowInfo( "Вы успешно активировали бустер" )
                                end;
    },

    -- Бесплатный бензин
    {
        [TYPE] = IN_BOOSTER_FREE_FUEL,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Бесплатные заправки на 8 часа"
                                visual_data.description = "Наведите на свой автомобиль, и сможете бесплатно заправлять его ближайшие 8 часов"
                                visual_data.image = "img/items/booster_free_fuel.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType(target) ~= "vehicle" then
                                    return false, "Нужно применять на автомобиль"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                if target:GetOwnerID() ~= player:GetUserID() then
                                    return false, "Можно применить только на свой автомобиль!"
                                end
                                return player:ApplyBooster( BOOSTER_FREE_FUEL, {iVehicleID = target:GetID()} )
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target, jail_data )
                                    player:ShowInfo( "Вы успешно активировали бустер" )
                                end;
    },

    -- Стамина (???)
    {
        [TYPE] = IN_BOOSTER_STAMINA,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Протеин"
                                visual_data.description = "Повышает вышу выносливость на 3 часа"
                                visual_data.image = "img/items/jailkeys.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or target ~= localPlayer then
                                    return false, "Нужно применять на себя"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                return player:ApplyBooster( BOOSTER_STAMINA, {} )
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target, jail_data )
                                    player:ShowInfo( "Вы чувствуете прилив энергии" )
                                end;
    },

    -- Бронирование + тонировка
    {
        [TYPE] = IN_VEHICLE_TONER,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Тюнинг-набор"
                                visual_data.description = "Наведите на свой автомобиль для моментальной установки президентской брони и тонировки"
                                visual_data.image = "img/items/toner.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType(target) ~= "vehicle" then
                                    return false, "Нужно применять на автомобиль"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                if target:GetOwnerID() ~= player:GetUserID() then
                                    return false, "Можно применить только на свой автомобиль!"
                                end

                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target, jail_data )
                                    local vehicle = target

                                    vehicle:SetWindowsColor(0,0,0,255)
                                    exports.rpbox:CVehicle_External(vehicle, "SetTuningData", "Toning", 255, true)
                                    exports.rpbox:CVehicle_External(vehicle, "SetTuningData", "Damage", 5, true)

                                    player:ShowInfo( "Вы успешно укрепили свой автомобиль" )
                                end;
    },
    -- Сумочка Анжелы (квестовый предмет) (unwanted)
    {
        [TYPE] = IN_ANGELA_HANDBAG,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Сумочка Анжелы"
                                visual_data.description = "Наведите на Анжелу, чтобы вернуть её"
                                visual_data.image = "img/items/bag.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "ped" or target:getData("QUESTS_NPC_ID") ~= 5 then
                                    return false, "Вернуть сумочку можно только Анжеле"
                                end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                triggerEvent( "PlayerAction_Tutorial_step_8", player )
                            end;
    }, 
    -- Военный билет
    { 
        [TYPE] = IN_MILITARY,
        [CATEGORY] = "documents",
        [STATIC] = true,
        [WEIGHT] = 0,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Военное удостоверение"
                                visual_data.description = "Наведите на игрока чтобы показать удостоверение"
                                visual_data.image = "img/items/military.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока чтобы показать удостоверение"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                if target:getData( "CARRY" ) then
                                    local texts = {
                                        "Ах ты шалунишка!",
                                        "Твой котёл уже вскипел",
                                        "Ты чё, ватрушка что-ли?",
                                        "Мы всё видим",
                                        "Есть нормальные люди, а есть любители показать удостоверение грузчику",
                                    }  
                                    return false, texts[ math.random( 1, #texts ) ]
                                end
                                if not CanShowDocuments( localPlayer, target ) then return false end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    triggerEvent( "OnMilitaryShowRequest", player, target )
                                    return true -- делает KEEP_INVENTORY_NODE = true, запрещая удалять элемент
                                end;
    },
    -- Военный билет
    { 
        [TYPE] = IN_ARMYFREE,
        [CATEGORY] = "documents",
        [STATIC] = true,
        [WEIGHT] = 0,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                local timestamp = attributes[ 1 ]
                                local timestamp_str = formatTimestamp( timestamp )
                                visual_data.text = "Увольнительная"
                                visual_data.description = "Наведите на игрока чтобы показать увольнительную, срок: " .. timestamp_str
                                visual_data.image = "img/items/armyfree.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока чтобы показать увольнительную"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                if target:getData( "CARRY" ) then
                                    local texts = {
                                        "Ах ты шалунишка!",
                                        "Твой котёл уже вскипел",
                                        "Ты чё, ватрушка что-ли?",
                                        "Мы всё видим",
                                        "Есть нормальные люди, а есть любители показать увольнительную грузчику",
                                    }  
                                    return false, texts[ math.random( 1, #texts ) ]
                                end
                                if not CanShowDocuments( localPlayer, target ) then return false end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    triggerEvent( "OnArmyfreeShowRequest", player, target )
                                    return true -- делает KEEP_INVENTORY_NODE = true, запрещая удалять элемент
                                end;
    },
    -- Смарт-часы
    { 
        [TYPE] = IN_SMARTWATCH,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Смарт-часы"
                                visual_data.description = "Нажмите `1` на клавиатуре чтоб активировать смарт-часы"
                                visual_data.image = "img/items/smartwatch.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                return false
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    return true
                                end;
    },
    -- Буковки на новый год
    { 
        [TYPE] = IN_NEWYEAR_LETTER,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                local letter = attributes[ 1 ]
                                if tonumber( letter ) then
                                    local word = { "N", "E", "X", "T", "R", "P" }
                                    visual_data.text = ( "Буковка '%s'" ):format( word[ letter ] )
                                    visual_data.description = "Частица кодового слова для Деда Мороза. Собери все и получишь подарок!"
                                else
                                    visual_data.text = "Секретное слово!"
                                    visual_data.description = "Кодовое слово для Деда Мороза. Найди дедушку и получи свой подарок! И стишок не забудь :)"
                                end
                                visual_data.image = ":nrp_newyear/img/" .. attributes[ 1 ] .. ".png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                return false
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    return true
                                end;
    },
    
    { 
        [TYPE] = IN_VEHICLE_PASSPORT,
        [CATEGORY] = "documents",
        [STATIC] = true,
        [WEIGHT] = 0,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Техпаспорт"
                                visual_data.description = "Показывает информацию о последней твоей машине, в которой ты находился"
                                visual_data.image = "img/items/vehpassport.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведи на игрока чтобы показать техпаспорт"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                if not CanShowDocuments( localPlayer, target ) then return false end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    if not isElement( target ) or getElementType( target ) ~= "player" then
                                        return false, "Наведите на игрока чтобы показать техпаспорт"
                                    end
                                    triggerEvent( "onVehiclePassportShowRequest", player, target )
                                    return true
                                end;
    },

    -- Еда с собой (food)
    {
        [TYPE] = IN_FOOD,
        [WEIGHT] = function( self, item_id, attributes )
            local food_id = ITEM_ID_TO_FOOD_ID[ item_id ]
            local food = FOOD_DISHES[ food_id ]
            return food and food.weight or 0.3
        end,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                local food_id = ITEM_ID_TO_FOOD_ID[ item_id ]
                                local food = FOOD_DISHES[ food_id ]
                                visual_data.text = food_id and food.name or "Ланч с собой"
                                visual_data.description = "Наведите на себя чтобы съесть"
                                visual_data.image = food_id and ( ":nrp_house_cooking/images/dishes/big/" .. food.img .. ".png" ) or "img/items/food.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" or target ~= localPlayer then
                                    return false, "Наведите на себя чтобы съесть"
                                end
                                if IsFighting() then
                                    return false, "Невозможно использовать во время боя"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player )
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player )
                                    local food_id = ITEM_ID_TO_FOOD_ID[ item_id ]
                                    triggerEvent( "onPlayerEatFood", player, food_id )
                                end;
	},
	
    -- Ленточка на 9-ое мая
    { 
        [TYPE] = IN_9MAY_RIBBON,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
								visual_data.text = "Георгевская ленточка"
								visual_data.description = "Собери все и получишь подарок!"
                                visual_data.image = ":nrp_9may/images/inv_icon.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                return false
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                return true
                            end;
    },

    -- Цветок на 1 сентября
    { 
        [TYPE] = IN_1SEPTEMBER_FLOWER,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Цветок"
                                visual_data.description = "Собери букет и подари его учительнице!"
                                visual_data.image = ":nrp_1september/files/img/inv_icon.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                return false
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                return true
                            end;
    },

    -- Карта сокровищ ( хобби )
    { 
        [TYPE] = IN_TREASURE_MAP,
        [WEIGHT] = 0.1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Карта сокровищ"
                                visual_data.description = "Наведите на себя чтобы использовать"
                                visual_data.image = "img/items/map.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" or target ~= localPlayer then
                                    return false, "Наведите на себя чтобы взять карту в руки"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player )
                                local iLastLocationID = player:GetPermanentData( "last_digging_location" )

                                if iLastLocationID then
                                    triggerClientEvent( player, "ShowUI_DiggingMap", player, true, { map_id = iLastLocationID } )
                                    return false
                                end

                                local pEquippedTool = exports.nrp_hobby_inventory:GetPlayerEquippedTool( player, HOBBY_DIGGING )
                                if not pEquippedTool then
                                    player:ShowError("Ты забыл взять лопату")
                                    return false
                                end

                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player )
                                    triggerEvent( "OnPlayerRequestDiggingLocation", player )
                                    return true
                                end;
    },

    -- Удостоверение сотрудника полиции
    { 
        [TYPE] = IN_POLICEID,
        [CATEGORY] = "documents",
        [STATIC] = true,
        [WEIGHT] = 0,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Удостоверение"
                                visual_data.description = "Наведите на игрока чтобы показать удостоверение"
                                visual_data.image = "img/items/policeid.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока чтобы показать удостоверение"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                if not CanShowDocuments( localPlayer, target ) then return false end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                    triggerEvent( "OnPoliceIDShowRequest", player, target )
                                    return true
                                end;
    },

    -- Жесткий диск на ивент др проекта
    { 
        [TYPE] = IN_HDD,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Жесткий диск"
                                visual_data.description = "Отдай жесткий диск Коле на расшифровку"
                                visual_data.image = "img/items/hdd.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                return false
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                return true
                            end;
    },
    -- Документы для туториала
    {
        [TYPE] = IN_TUTORIAL_DOCS,
        [STATIC] = true,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Накладные"
                                visual_data.description = "Наведи на Администратора Автосалона чтобы передать"
                                visual_data.image = "img/items/tutorial_docs.png"
                                visual_data.highlight = true
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                return true
                            end;
        [CLIENTSIDE_SUCCESS] = function( self, item_id, attributes, target )
                                triggerEvent( "onPlayerGiveTutorialDocs", localPlayer )
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                return true
                            end;
    },
    
    -- Документы для туториала
    {
        [TYPE] = IN_TUTORIAL_HASH,
        [STATIC] = true,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "ХЭШ"
                                visual_data.description = "Наведи на себя, чтобы применить"
                                visual_data.image = "img/items/tutorial_hash.png"
                                visual_data.highlight = true
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                return true
                            end;
        [CLIENTSIDE_SUCCESS] = function( self, item_id, attributes, target )
                                triggerEvent( "onClientQuestPlayerUseDrugs", localPlayer )
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                return true
                            end;
    }, 

    -- Бабки для квеста
    {
        [TYPE] = IN_QUEST_MONEY,
        [STATIC] = true,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Деньги"
                                visual_data.description = "Наведи на Александра чтобы передать"
                                visual_data.image = "img/items/quest_money.png"
                                visual_data.highlight = true
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                return true
                            end;
        [CLIENTSIDE_SUCCESS] = function( self, item_id, attributes, target )
                                triggerEvent( "onPlayerGiveQuestMoney", localPlayer )
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                return true
                            end;
    }, 

    { 
        [TYPE] = IN_WEDDING_DIS,
        [WEIGHT] = 0.4,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Бумаги на развод"
                                visual_data.description = "Наведите на себя, чтобы использовать"
                                visual_data.image = "img/items/wedding_dis.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or target ~= localPlayer then
                                    return false, "Нужно применять на себя"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                if not player:GetPermanentData( "wedding_at_id" ) or player:GetPermanentData( "wedding_at_id" ) == "" then
                                    player:ShowInfo( "Вы не в браке" )
                                    return false
                                end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player )
                                    triggerEvent( "onPlayerWeddingDivorceCall", player )
                                end;
    },

    { 
        [TYPE] = IN_WEDDING_START,
        [WEIGHT] = 0.4,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Свадебный набор"
                                visual_data.description = "Наведите на себя, чтобы использовать"
                                visual_data.image = "img/items/wedding_gift.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or target ~= localPlayer then
                                    return false, "Нужно применять на себя"
                                end
                                return true
                            end;
         [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )

                                    if player:GetPermanentData( "engage_item_applyed" ) then
                                        player:ShowInfo( "Вы уже использовали этот предмет" )
                                        return false
                                    end

                                    if not player:HasAnyApartment() then
                                        player:ShowInfo( "Вы не можете начать помолвку, т.к. не имеете недвижимости" )
                                        return false
                                    end

                                    if #player:GetVehicles( _, true ) <= 0 then
                                        player:ShowInfo( "Вы не можете начать помолвку, т.к. не владеете транспортом" )
                                        return false
                                    end

                                    local wedding_at_id = player:GetPermanentData( "wedding_at_id" )
                                    local engaged_at_id = player:GetPermanentData( "engaged_at_id" )
                                    if wedding_at_id or engaged_at_id then
                                        player:ShowInfo( "Вы не можете начать помолвку т.к.  уже\n " .. ( player:GetGender() == 0 and "женаты" or "замужем" ) ..  " или начали помолвку." )
                                        return false
                                    end
                                
                                    if player:getData( "jailed" ) then
                                        pl:ShowInfo( "Вы не можете начать помолвку, т.к.  в тюрьме." )
                                        return false
                                    end
                                
                                    if player:isDead() then
                                        player:ShowInfo( "Вы не можете начать помолвку, т.к.  на том свете." )
                                        return false
                                    end
                                
                                    if player:IsOnFactionDuty() then
                                        player:ShowInfo( "Вы не можете начать помолвку, т.к. на смене фракции." )
                                        return false
                                    end

                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player )
                                    triggerEvent( "onPlayerWeddingEngageCall", player ) 
                            end;
    },

    { 
        [TYPE] = IN_WEDDING_CHOCO,
        [WEIGHT] = 0.1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Шоколадка"
                                visual_data.description = "Можно подарить игроку или съесть самому."
                                visual_data.image = "img/items/choco.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока чтобы использовать итем."
                                end
                                if IsFighting() then
                                    return false, "Невозможно использовать во время боя"
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                               
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target, jail_data )
                                if not isElement( target ) then return end
                                if target == player then
                                    player:SetHP( 1000 )
                                    player:ShowInfo( "Вы съели шоколадку, тем самым\nвосстановили себе здоровье." )
                                else
                                    triggerEvent( "onWeddingPlayerWantToTransferItemTo", player, target, IN_WEDDING_CHOCO )
                                    return true -- делает KEEP_INVENTORY_NODE = true, запрещая удалять элемент
                                end
                            end;
    },

    { 
        [TYPE] = IN_WEDDING_PANAMHAT,
        [WEIGHT] = 0.2,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Шляпа Panam Hat"
                                visual_data.description = "Подарок для молодожён."
                                visual_data.image = "img/items/panam_hat.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока, чтобы подарить."
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                               
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target, jail_data )
                                if not isElement( target ) then return end
                                if target == player then
                                    player:ShowInfo( "Это подарок для молодожён, его нельзя применить на себя" )
                                else
                                    triggerEvent( "onWeddingPlayerWantToTransferItemTo", player, target, IN_WEDDING_PANAMHAT )
                                end
                                return true -- делает KEEP_INVENTORY_NODE = true, запрещая удалять элемент
                            end;
    },

    { 
        [TYPE] = IN_WEDDING_HANDBAG,
        [WEIGHT] = 0.4,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Сумка с бриллиантом"
                                visual_data.description = "Подарок для молодожён."
                                visual_data.image = "img/items/diamond_bag.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока, чтобы подарить."
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                               
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target, jail_data )
                                if not isElement( target ) then return end
                                if target == player then
                                    player:ShowInfo( "Это подарок для молодожён, его нельзя применить на себя" )
                                else
                                    triggerEvent( "onWeddingPlayerWantToTransferItemTo", player, target, IN_WEDDING_HANDBAG )
                                end
                                return true -- делает KEEP_INVENTORY_NODE = true, запрещая удалять элемент
                            end;
    },

    { 
        [TYPE] = IN_WEDDING_NECKLACEHOPE,
        [WEIGHT] = 0.2,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Алмаз хоуп"
                                visual_data.description = "Подарок для молодожён."
                                visual_data.image = "img/items/diamond_hope.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока, чтобы подарить."
                                end
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                               
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target, jail_data )
                                if not isElement( target ) then return end
                                if target == player then
                                    player:ShowInfo( "Это подарок для молодожён, его нельзя применить на себя" )
                                else
                                    triggerEvent( "onWeddingPlayerWantToTransferItemTo", player, target, IN_WEDDING_NECKLACEHOPE )
                                end
                                return true -- делает KEEP_INVENTORY_NODE = true, запрещая удалять элемент
                            end;
    },

    { 
        [TYPE] = IN_WEDDING_GLASSES_WOODBLACK,
        [WEIGHT] = 0.2,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Очки Wood Black"
                                visual_data.description = "Подарок для молодожён."
                                visual_data.image = "img/items/wood_black_glasses.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока, чтобы подарить."
                                end
                                return true
                            end;
         [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                               
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target, jail_data )
                                if not isElement( target ) then return end
                                if target == player then
                                    player:ShowInfo( "Это подарок для молодожён, его нельзя применить на себя" )
                                else
                                    triggerEvent( "onWeddingPlayerWantToTransferItemTo", player, target, IN_WEDDING_GLASSES_WOODBLACK )
                                end
                                return true -- делает KEEP_INVENTORY_NODE = true, запрещая удалять элемент
                            end;
    },

    -- Медкнижка
    { 
        [TYPE] = IN_MEDBOOK,
        [CATEGORY] = "documents",
        [STATIC] = true,
        [WEIGHT] = 0,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Мед. книжка"
                                visual_data.description = "Наведите на игрока, чтобы показать мед. книжку"
                                visual_data.image = "img/items/medbook.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока, чтобы показать мед. книжку"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                if not CanShowDocuments( localPlayer, target ) then return false end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                triggerEvent( "onPlayerShowMedbook", player, target )
                                return true
                            end;
    },

    -- Хобби
    {
        [TYPE] = IN_HOBBY_FISHING_ROD,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Рыболовная удочка"

                                if attributes and next( attributes ) then
                                    local attrs = attributes
                                    visual_data.description = "Уровень предмета: ".. ROMAN_NUMBERS[ attrs.id ]..( attrs.durability and ( "\nПрочность последнего: ".. attrs.durability .." ед." ) or "" )
                                end

                                visual_data.image = "img/items/icon_rod_1.png"
                                return visual_data
                            end;

        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                return false
                            end;

        [SERVERSIDE_SUCCESS] = function(self, player, target)
                                return true
                            end;
    },

    {
        [TYPE] = IN_HOBBY_FISHING_BAIT,
        [WEIGHT] = 0.1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Наживка для рыбалки"

                                if attributes and next( attributes ) then
                                    local attrs = attributes
                                    visual_data.description = "Уровень предмета: "..ROMAN_NUMBERS[ attrs.id ].."\n+"..attrs.multiplier.."% к шансу добычи"
                                end

                                visual_data.image = "img/items/icon_worm_1.png"
                                return visual_data
                            end;

        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                return false
                            end;

        [SERVERSIDE_SUCCESS] = function(self, player, target)
                                return true
                            end;
    },

    {
        [TYPE] = IN_HOBBY_HUNTING_RIFFLE,
        [WEIGHT] = 3,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Ружье для охоты"

                                if attributes and next( attributes ) then
                                    local attrs = attributes
                                    visual_data.description = "Уровень предмета: "..ROMAN_NUMBERS[ attrs.id ]..( attrs.durability and ( "\nПрочность последнего: ".. attrs.durability .." ед." ) or "" )
                                end

                                visual_data.image = "img/items/icon_rifle_1.png"
                                return visual_data
                            end;

        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                return false
                            end;

        [SERVERSIDE_SUCCESS] = function(self, player, target)
                                return true
                            end;
    },

    {
        [TYPE] = IN_HOBBY_HUNTING_AMMO,
        [WEIGHT] = 0.1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Патроны для ружья"

                                if attributes and next( attributes ) then
                                    local attrs = attributes
                                    visual_data.description = "Уровень предмета: "..ROMAN_NUMBERS[ attrs.id ].."\n+"..attrs.multiplier.."% к шансу добычи"
                                end

                                visual_data.image = "img/items/icon_ammo_1.png"
                                return visual_data
                            end;

        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                return false
                            end;

        [SERVERSIDE_SUCCESS] = function(self, player, target)
                                return true
                            end;
    },

    {
        [TYPE] = IN_HOBBY_DIGGING_SHOVEL,
        [WEIGHT] = 1.2,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Лопата"

                                if attributes and next( attributes ) then
                                    local attrs = attributes
                                    visual_data.description = "Уровень предмета: "..ROMAN_NUMBERS[ attrs.id ]..( attrs.durability and ( "\nПрочность последнего: ".. attrs.durability .." ед." ) or "" )
                                end

                                visual_data.image = "img/items/icon_shovel_1.png"
                                return visual_data
                            end;

        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                return false
                            end;

        [SERVERSIDE_SUCCESS] = function(self, player, target)
                                return true
                            end;
    },

    -- Оружейный магазин
    {
        [TYPE] = IN_GUN_LICENSE,
        [CATEGORY] = "documents",
        [STATIC] = true,
        [WEIGHT] = 0,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Лицензия на оружие"
                                visual_data.description = "Наведите на игрока, чтобы показать лицензию"
                                visual_data.image = "img/items/weapon_license.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if not isElement( target ) or getElementType( target ) ~= "player" then
                                    return false, "Наведите на игрока, чтобы показать лицензию"
                                end
                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                if not CanShowDocuments( localPlayer, target ) then return false end
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                triggerEvent( "onPlayerShowGunLicense", player, target )
                                return true
                            end;
    },

    -- ИНКАССАТОР, мешок с деньками
    {
        [TYPE] = IN_BAG_MONEY,
        [WEIGHT] = 3,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Мешок денег"
                                visual_data.description = "Обналичить можно только у картелей"
                                visual_data.image = "img/items/bug_money.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )

                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )

                                return true
                            end;
    },

    -- КВЕСТ, мешок с деньками
    {
        [TYPE] = IN_QUEST_CASE,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Кейс"
                                visual_data.description = "Передай кейс"
                                visual_data.image = "img/items/icon_quest_case.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )

                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )

                                return true
                            end;
    },

    -- Карточка на бесплатную поездку на такси
    {
        [TYPE] = IN_FREE_TAXI,
        [WEIGHT] = 0.1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Карточка на такси"
                                visual_data.description = "С помощью данной карточки ты сможешь проехать на такси бесплатно 6000 метров"
                                visual_data.image = "img/items/taxi.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )

                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )

                                return true
                            end;
    },

    -- Детали для акции "Сборка машины"
    {
        [TYPE] = IN_ASSEMBLY_VEHICLE,
        [WEIGHT] = 1,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                local detail_id = attributes[ 1 ]
                                local detail = exports.nrp_assembly_vehicle:GetAssemblyVehicleDetailById( detail_id )

                                visual_data.text = detail.name
                                visual_data.description = "Необходимо для сборки авто"
                                visual_data.image =":nrp_assembly_vehicle/img/inventory/" .. detail.type .. ".png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                return false
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player )
                                return false
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player )
                            end;
	},

    {
        [TYPE] = IN_BOTTLE_DIRTY,
        [WEIGHT] = 0.2,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Грязная бутылка"
                                visual_data.description = "Необходим для производства алкоголя.\nНужно помыть в алко-цехе"
                                visual_data.image = "img/items/bottle_dirty.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )

                                return false
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )

                                return true
                            end;
    },

    {
        [TYPE] = IN_BOTTLE,
        [WEIGHT] = 0.2,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Чистая бутылка"
                                visual_data.description = "Необходим для производства алкоголя"
                                visual_data.image = "img/items/bottle.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )

                                return false
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )

                                return true
                            end;
    },

    {
        [TYPE] = IN_ALCO,
        [WEIGHT] = 0.2,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Алкоголь"
                                local quality = attributes[ 1 ]
                                visual_data.description = ALCOHOLS[ quality ].desc
                                visual_data.image = "img/items/alco_" .. quality .. ".png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if target ~= localPlayer then
                                    return false, "Перемести на себя чтобы применить"
                                end
                                if IsFighting() then
                                    return false, "Невозможно использовать во время боя"
                                end
                                local quality = attributes[ 1 ]
                                return exports.nrp_clans_drugs:SetDrunk( quality )
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                local quality = attributes[ 1 ]
                                exports.nrp_clans_drugs:SetDrunk( player, quality )
                            end;
    },

    {
        [TYPE] = IN_HASH_RAW,
        [WEIGHT] = 0.2,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Шишка-петрушки"
                                visual_data.description = "Необходим для производства петрушки"
                                visual_data.image = "img/items/hash_raw.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )

                                return false
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )

                                return true
                            end;
    },

    {
        [TYPE] = IN_HASH_DRY,
        [WEIGHT] = 0.2,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Сушеная петрушка"
                                visual_data.description = "Осталось только упаковать"
                                visual_data.image = "img/items/hash_dry.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )

                                return false
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )

                                return true
                            end;
    },

    {
        [TYPE] = IN_HASH,
        [WEIGHT] = 0.2,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Петрушка"
                                local quality = attributes[ 1 ]
                                visual_data.description = DRUGS[ 3 + quality ].desc
                                visual_data.image = "img/items/hash_" .. quality .. ".png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                if target ~= localPlayer then
                                    return false, "Перемести на себя чтобы применить"
                                end
                                if IsFighting() then
                                    return false, "Невозможно использовать во время боя"
                                end
                                local quality = attributes[ 1 ]
                                return exports.nrp_clans_drugs:SetOnDrugs( 3 + quality )
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                return true
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target )
                                player:SetPermanentData( "last_drugs_use_date", os.time( ) )
                            end;
    },
    {
        [TYPE] = IN_TUTORIAL_CANISTER,
        [WEIGHT] = 4,
        [VISUAL_CONSTRUCT] = function( self, item_id, attributes )
                                local visual_data = { }
                                visual_data.text = "Бесплатная канистра"
                                visual_data.description = "Наведите на мопед чтобы заправить"

                                visual_data.image = "img/items/canister.png"
                                return visual_data
                            end;
        [CLIENTSIDE_CHECK] = function( self, item_id, attributes, target )
                                target = target == localPlayer and localPlayer.vehicle or target
                                if not isElement( target ) or getElementType( target ) ~= "vehicle" or localPlayer:getData( "temp_vehicle" ) ~= target then
                                    return false, "Наведите на мопед чтобы заправить"
                                end

                                if localPlayer.position:distance( target.position ) > 10 then
                                    return false, "Подойдите ближе!"
                                end
                                
                                triggerEvent( "onClientPlayerUseQuestCanister", localPlayer )
                                return true
                            end;
        [SERVERSIDE_CHECK] = function( self, item_id, attributes, player, target )
                                target = target == player and player.vehicle or target
                                if not isElement( target ) or getElementType( target ) ~= "vehicle" or player:getData( "temp_vehicle" ) ~= target then
                                    return false, "Наведите на мопед чтобы заправить"
                                end
                                
                                return true, { }
                            end;
        [SERVERSIDE_SUCCESS] = function( self, item_id, attributes, player, target, conf )
                                    local vehicle = target == player and player.vehicle or target
                                    vehicle:SetFuel( "full" )
                                    player:ShowInfo( "Вы успешно заправили мопед на 20 л." )
                                end;
    },
}

ITEMS_CONFIG = { }
ITEMS_IDS_BY_CATEGORY = { }

for i, v in pairs( INVENTORY_STE ) do
    local item_type = v[ TYPE ]
    ITEMS_CONFIG[ item_type ] = v

    local category = v[ CATEGORY ] or "stuff"
    if not ITEMS_IDS_BY_CATEGORY[ category ] then
        ITEMS_IDS_BY_CATEGORY[ category ] = {}
    end
    table.insert( ITEMS_IDS_BY_CATEGORY[ category ], item_type )

    if ITEM_IDS_BY_TYPE[ item_type ] then
        for i, item_id in pairs( ITEM_IDS_BY_TYPE[ item_type ] ) do
            ITEMS_CONFIG[ item_id ] = v
            table.insert( ITEMS_IDS_BY_CATEGORY[ category ], item_id )
        end
    end
end

if localPlayer then
    local last_damage_tick = 0
    addEventHandler( "onClientPlayerDamage", localPlayer, function( attacker, weapon )
        if attacker and attacker ~= localPlayer and weapon ~= 0 then
            last_damage_tick = getTickCount()
        end
    end )

    function IsFighting()
        return getTickCount() - last_damage_tick <= 20000
    end
end