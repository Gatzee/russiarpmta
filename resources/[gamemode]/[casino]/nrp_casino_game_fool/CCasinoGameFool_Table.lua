------------------------------------
----- Стол игры (текущая игра) -----
------------------------------------

TABLE_CURRENT = { }
TABLE_CARD_CONF = { px = 190, py = 245, sx = 54 * 1.4, sy = 80 * 1.4, offset_x = 5, offset_y = 30 }

LAST_TABLE_AMOUNT = 0

function CreateTable( info )
    CleanTable( )

    if not isElement( UI_elements.bg ) then return end


    --[[info = {
        { card = { 6, 1 }, beat = { 7, 2 } },
        { card = { 6, 1 }, },
        { card = { 6, 1 }, beat = { 7, 2 } },
        { card = { 6, 1 }, },
        { card = { 6, 1 }, beat = { 7, 2 } },
        { card = { 6, 1 }, },
    }]]

    if info then
        TABLE_CURRENT = info

        local current_cards = 0
        for i, v in pairs( TABLE_CURRENT ) do
            current_cards = current_cards + ( ( v.card and v.beat ) and 2 or 1 )
        end
        if current_cards > 0 and LAST_TABLE_AMOUNT ~= current_cards then
            playSound( "sfx/put" .. math.random( 1, 4 ) .. ".wav" )
        end
        LAST_TABLE_AMOUNT = current_cards

        --local TABLE_CARD_CONF = { px = 223, py = 230, sx = 54, sy = 80, offset_x = 5, offset_y = 20 }

        local cards_offset = #info > CARDS_ON_TABLE_LIMIT and ( #info - CARDS_ON_TABLE_LIMIT ) or 0
        for i = 1, CARDS_ON_TABLE_LIMIT do
            local card_session_number = cards_offset + i
            local card_session = info[ card_session_number ]

            if card_session then

                local px = TABLE_CARD_CONF.px + ( i - 1 ) * ( TABLE_CARD_CONF.sx + TABLE_CARD_CONF.offset_x )
                local py = TABLE_CARD_CONF.py

                local texture = CardImageFile( card_session.card )
                local card_img = ibCreateImage( px, py, TABLE_CARD_CONF.sx, TABLE_CARD_CONF.sy, texture, UI_elements.bg )


                if card_session.beat then
                    local texture_beat = CardImageFile( card_session.beat )
                    local card_beat_img = ibCreateImage( 0, TABLE_CARD_CONF.offset_y, TABLE_CARD_CONF.sx, TABLE_CARD_CONF.sy, texture_beat, UI_elements.bg )
                    card_beat_img:setParent( card_img )
                else
                    card_img:ibData( "card_session", card_session )
                    card_img:ibData( "card_session_number", card_session_number )
                end

                UI_elements[ "table_card_" .. i ] = card_img

            end
        end
    else
        LAST_TABLE_AMOUNT = 0
    end
end
addEvent( "onCasinoGameFoolTableSet", true )
addEventHandler( "onCasinoGameFoolTableSet", root, CreateTable )

function CleanTable( )
    for i = 1, CARDS_ON_TABLE_LIMIT do
        local element_name = "table_card_" .. i
        if isElement( UI_elements[ element_name ] ) then destroyElement( UI_elements[ element_name ] ) end
    end
    TABLE_CURRENT = nil
end