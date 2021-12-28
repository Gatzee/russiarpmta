---------------------------
----- Игроки на столе -----
---------------------------

TABLE_CONF = {
    [ 1 ] = { 
        box = { px = 5, py = 209, sx = 180, sy = 50 },
        avatar = { image = "img/avatars/meme1.png", px = 2, py = 2, sx = 46, sy = 46 },
        --task = CASINO_TASK_PLAYING,
    },
    [ 2 ] = { 
        box = { px = 34, py = 83, sx = 180, sy = 50 },
        avatar = { image = "img/avatars/meme1.png", px = 2, py = 2, sx = 46, sy = 46 },
        --task = CASINO_TASK_WAITING,
    },
    [ 3 ] = { 
        box = { px = 304, py = 45, sx = 180, sy = 50 },
        avatar = { image = "img/avatars/meme1.png", px = 2, py = 2, sx = 46, sy = 46 },
        --task = CASINO_TASK_DEFENDING,
    },
    [ 4 ] = { 
        box = { px = 573, py = 83, sx = 180, sy = 50 },
        avatar = { image = "img/avatars/meme1.png", px = 2, py = 2, sx = 46, sy = 46 },
        --task = CASINO_TASK_TAKING,
    },
    [ 5 ] = { 
        box = { px = 597, py = 209, sx = 180, sy = 50 },
        avatar = { image = "img/avatars/meme1.png", px = 2, py = 2, sx = 46, sy = 46 },
        --task = CASINO_TASK_TAKING,
    },
}

PLAYERS_DATA = { }
CURRENT_PLAYERS = { }
function CreatePlayers( players, only_update )
    if not isElement( UI_elements.bg ) then return end

    -- Если список есть и нужно только обновить инфу
    if only_update then
        for i, v in pairs( players ) do
            SetPlayer( i, players[ i ] )
        end
    
    -- Если нужно построить список заново
    else
        for i, v in pairs( UI_elements.players_data or { } ) do
            if isElement( v ) then
                destroyElement( v )
            end
        end
        UI_elements.players_data = { }

        CURRENT_PLAYERS = players

        if not players then return end

        for i, v in pairs( TABLE_CONF ) do
            if players[ i ] then
                CreatePlayer( i, players[ i ] )
                SetPlayer( i, players[ i ] )
            end
        end

    end
end
addEvent( "onCasinoFoolCreatePlayersRequest", true )
addEventHandler( "onCasinoFoolCreatePlayersRequest", root, CreatePlayers )

PLAYERS_CARD_CONF = { sx = 54, sy = 80 }
function SetPlayer( position, player_conf )
    -- Установка данных на будущее
    for i, v in pairs( player_conf ) do
        PLAYERS_DATA[ position ][ i ] = v
    end

    -- Изменение имени
    if player_conf.name then 
        local name = PLAYERS_DATA[ position ].player == localPlayer and "ТЫ" or player_conf.name
        PLAYERS_DATA[ position ].lbl_name:ibData( "text", name ) 
    end

    -- Изменение текущего таска
    if player_conf.task then 
        PLAYERS_DATA[ position ].lbl_task:ibData( "text", TASK_TEXTS[ player_conf.task ] or TASK_TEXTS[ 1 ] ) 
    end

    -- Если игрок еще в раунде
    if player_conf.state == CASINO_PLAYER_STATE_PLAYING then
        PLAYERS_DATA[ position ].img_box:ibData( "alpha", 255 ) 
    
        -- Отрисовка количества карт в руке, максимум 8 шт
        local table_conf= TABLE_CONF[ position ]
        local box       = table_conf.box

        if isElement( UI_elements.players_data[ position .. "_cards_box" ] ) then
            destroyElement( UI_elements.players_data[ position .. "_cards_box" ] )
        end
        local hand_amount   = math.min( 9, player_conf.hand_amount )
        local gap           = hand_amount > 6 and 12 or 20
        local total_sx      = ( hand_amount - 1 ) * gap + PLAYERS_CARD_CONF.sx
        local cards_box     = ibCreateImage( box.px + box.sx / 2 - total_sx / 2, box.py - 40, 0, box.sy, nil, UI_elements.bg, 0x00000000 )
        cards_box:ibData( "priority", -1 )

        for i = 1, hand_amount do
            ibCreateImage( ( i - 1 ) * gap, 0, PLAYERS_CARD_CONF.sx, PLAYERS_CARD_CONF.sy, "img/cards/cardback.png", cards_box )
        end

        UI_elements.players_data[ position .. "_cards_box" ] = cards_box

    else
        PLAYERS_DATA[ position ].img_box:ibData( "alpha", 150 )
    end
    
    return true
end

function ResetPlayer( position )
    if isElement( UI_elements.players_data[ position .. "img_box" ] ) then
        destroyElement( UI_elements.players_data[ position .. "img_box" ] )
    end
    if isElement( UI_elements.players_data[ position .. "_cards_box" ] ) then
        destroyElement( UI_elements.players_data[ position .. "_cards_box" ] )
    end
end

function CreatePlayer( position, player_conf )
    ResetPlayer( position )

    local table_conf= TABLE_CONF[ position ]
    local box       = table_conf.box
    local avatar    = table_conf.avatar

    local img_box       = ibCreateImage( box.px, box.py, box.sx, box.sy, "img/bg_user.png", UI_elements.bg )
    ibCreateImage( avatar.px, avatar.py, avatar.sx, avatar.sy, avatar.image, img_box )

    local lbl_name = ibCreateLabel( avatar.px + avatar.sx, 2, box.sx - avatar.px - avatar.sx, ( box.sy - 4 ) / 2, "", img_box )
    lbl_name:ibBatchData( { font = fonts.bold_10, align_x = "center", align_y = "center" } )

    local lbl_task = ibCreateLabel( avatar.px + avatar.sx, ( box.sy - 4 ) / 2, box.sx - avatar.px - avatar.sx, ( box.sy - 4 ) / 2, "Тестовое действие", img_box )
    lbl_task:ibBatchData( { font = fonts.regular_10, align_x = "center", align_y = "center" } )
    
    PLAYERS_DATA[ position ] = table_conf

    for i, v in pairs( player_conf ) do
        PLAYERS_DATA[ position ][ i ] = v
    end

    table_conf.img_box = img_box
    table_conf.lbl_name = lbl_name
    table_conf.lbl_task = lbl_task


    UI_elements.players_data[ position .. "_img_box" ] = img_box

    return true
end