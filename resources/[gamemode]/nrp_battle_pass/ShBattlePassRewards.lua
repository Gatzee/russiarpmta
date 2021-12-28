BP_LEVELS_REWARDS = {
    -- Бесплатная линейка
    free = {
        [ 1  ] = { type = "wof_coin"         , id = "default"        , name = 'Жетон колеса фортуны'      , count = 2, cost = 20            },
        [ 2  ] = { type = "vinyl"            , id = "s121"           , name = 'Кракен'                    , count = 1, cost = 69            },
        [ 3  ] = { type = "fuelcan"          , id = "fuelcan"        , name = 'Канистра'                  , count = 1, cost = 5             },
        [ 4  ] = { type = "repairbox"        , id = "repairbox"      , name = 'Рем комплект'              , count = 1, cost = 25            },
        [ 5  ] = { type = "inventory_expand" , id = "invent_pers_up" , name = 'Расширение рюкзака'        , count = 1, cost = 99            },
        [ 6  ] = { type = "case"             , id = "bp_season_43"   , name = 'Сезонный кейс 43'          , count = 1, cost = 299           },
        [ 8  ] = { type = "wof_coin"         , id = "gold"           , name = 'VIP жетон колеса фортуны'  , count = 2, cost = 75            },
        [ 10 ] = { type = "accessory"        , id = "m3_acse16"      , name = 'Шипастый ошейник'          , count = 1, cost = 129           },
        [ 12 ] = { type = "case"             , id = "bp_season_44"   , name = 'Сезонный кейс 44'          , count = 1, cost = 299           },
        [ 14 ] = { type = "tuning_case"      , id = 2                , name = 'Тюнинг кейс "Счастливчик"' , count = 1,                      },
        [ 16 ] = { type = "vinyl_case"       , id = 1                , name = 'Винил кейс "Стильный"'     , count = 1,                      },
        [ 18 ] = { type = "case"             , id = "bp_season_45"   , name = 'Сезонный кейс 45'          , count = 1, cost = 299           },
        [ 20 ] = { type = "case"             , id = "vinyl_summer2"  , name = 'Винил мини-кейс "Жара"'    , count = 1, cost = 299           },
        [ 22 ] = { type = "case"             , id = "bronze"         , name = 'Бронзовый кейс'            , count = 1, cost = 99            },
        [ 24 ] = { type = "premium"          , id = "3d_prem"        , name = 'Премиум 3 дня'             , count = 1, cost = 299, days = 3 },
    },

    -------------------------------------------------------------------------
    -- Премиум линейка ------------------------------------------------------
    -------------------------------------------------------------------------

    premium = {
        [ 1  ] = { type = "wof_coin"         , id = "gold"           , name = 'VIP жетон колеса фортуны'   , count = 2, cost = 75               },
        [ 2  ] = { type = "repairbox"        , id = "repairbox"      , name = 'Рем комплект'               , count = 2, cost = 25               },
        [ 3  ] = { type = "vehicle"          , id = 411              , name = 'Audi R8 на 24 часа'         , count = 1, cost = 0, temp_days = 1 },
        [ 4  ] = { type = "jailkeys"         , id = "jailkeys"       , name = 'Карточка выхода из тюрьмы'  , count = 2, cost = 25               },
        [ 5  ] = { type = "vinyl"            , id = "s114"           , name = 'Димитреску'                 , count = 1, cost = 169              },
        [ 6  ] = { type = "case"             , id = "bp_season_43"   , name = 'Сезонный кейс 43'           , count = 1, cost = 299              },
        [ 7  ] = { type = "premium"          , id = "2d_prem"        , name = 'Премиум 2 дня'              , count = 1, cost = 199, days = 3    },
        [ 8  ] = { type = "wof_coin"         , id = "gold"           , name = 'VIP жетон колеса фортуны'   , count = 3, cost = 75               },
        [ 9  ] = { type = "inventory_expand" , id = "invent_pers_up" , name = 'Расширение рюкзака'         , count = 1, cost = 99               },
        [ 10 ] = { type = "tuning_case"      , id = 5                , name = 'Тюнинг кейс "Максимальный"' , count = 1,                         },
        [ 11 ] = { type = "vinyl_case"       , id = 3                , name = 'Винил кейс "Королевский"'   , count = 1,                         },
        [ 12 ] = { type = "case"             , id = "bp_season_44"   , name = 'Сезонный кейс 44'           , count = 1, cost = 299              },
        [ 13 ] = { type = "case"             , id = "vinyl_summer2"  , name = 'Винил мини-кейс "Жара"'     , count = 1, cost = 299              },
        [ 14 ] = { type = "vinyl_case"       , id = 3                , name = 'Винил кейс "Королевский"'   , count = 1,                         },
        [ 15 ] = { type = "vinyl"            , id = "s67"            , name = 'Бейсболистка'               , count = 1, cost = 169              },
        [ 16 ] = { type = "tuning_case"      , id = 5                , name = 'Тюнинг кейс "Максимальный"' , count = 1,                         },
        [ 17 ] = { type = "case"             , id = "vinyl_summer2"  , name = 'Винил мини-кейс "Жара"'     , count = 1, cost = 299              },
        [ 18 ] = { type = "case"             , id = "bp_season_45"   , name = 'Сезонный кейс 45'           , count = 1, cost = 299              },
        [ 19 ] = { type = "inventory_expand" , id = "invent_pers_up" , name = 'Расширение рюкзака'         , count = 1, cost = 99               },
        [ 20 ] = { type = "tuning_case"      , id = 3                , name = 'Тюнинг кейс "Фартовый"'     , count = 1,                         },
        [ 21 ] = { type = "case"             , id = "bp_season_46"   , name = 'Сезонный кейс 46'           , count = 1, cost = 299              },
        [ 22 ] = { type = "tuning_case"      , id = 5                , name = 'Тюнинг кейс "Максимальный"' , count = 1,                         },
        [ 23 ] = { type = "case"             , id = "vinyl_summer2"  , name = 'Винил мини-кейс "Жара"'     , count = 1, cost = 299              },
        [ 24 ] = { type = "case"             , id = "bp_season_47"   , name = 'Сезонный кейс 47'           , count = 1, cost = 299              },
    },
}

addEventHandler( localPlayer and "onClientResourceStart" or "onResourceStart", resourceRoot, function( )
    for type, rewards in pairs( BP_LEVELS_REWARDS ) do
        for i, reward in pairs( rewards ) do
            if reward.type == "vehicle" and not reward.temp_days then
                Debug( "У машины в наградах не прописан temp_days", 1 )
            end
            if REGISTERED_ITEMS[ reward.type ] then
                setmetatable( reward, { __index = REGISTERED_ITEMS[ reward.type ] } )
                
                if not reward.uiCreateItem then
                    Debug( "no uiCreateItem of " .. tostring( reward.type ), 1 )
                end
            else
                Debug( "no REGISTERED_ITEMS of " .. tostring( reward.type ), 1 )
            end
        end
    end

    for k,v in pairs( BP_LEVELS_REWARDS ) do
        CheckRewardsTable( v )
    end
end )
