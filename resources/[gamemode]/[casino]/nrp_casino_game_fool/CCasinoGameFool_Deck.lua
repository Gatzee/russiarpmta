------------------------------------
----- Колода на столе и козырь -----
------------------------------------

function CreateDeck( cards, trump_card )
    ResetDeck( )

    if not isElement( UI_elements.bg ) then return end

    if trump_card then TRUMP_CARD = trump_card end

    --iprint( "deck amount", cards )
    --iprint( "trump card", TRUMP_CARD )

    local cards_conf = { px = 352, py = 85, offset_y = 40, sx = 53 * 1.4, sy = 80 * 1.4 }

    if cards and cards > 1 then
        local deck = { image = "img/cards/cardback.png", rotation = 90 }
        local img_deck = ibCreateImage( cards_conf.px, cards_conf.py, cards_conf.sx, cards_conf.sy, deck.image, UI_elements.bg )
        img_deck:ibData( "rotation", deck.rotation )

        UI_elements.deck = img_deck

        if cards >= 2 then
            UI_elements.lbl_amount = ibCreateLabel( cards_conf.px - 20, cards_conf.py, 0, cards_conf.sy, cards, UI_elements.bg ):ibBatchData( { priority = 1, font = fonts.bold_12, align_x = "right", align_y = "center" } )
        end
    end

    if TRUMP_CARD and cards > 0 then
        local trump = { image = CardImageFile( TRUMP_CARD ) }
        local img_trump = ibCreateImage( cards_conf.px, cards_conf.py + cards_conf.offset_y, cards_conf.sx, cards_conf.sy, trump.image, UI_elements.bg )
        img_trump:ibData( "priority", -1 )
        UI_elements.trump = img_trump

        CURRENT_TRUMP = TRUMP_CARD[ 2 ]
    end
end
addEvent( "onCasinoGameFoolDeckRefresh", true )
addEventHandler( "onCasinoGameFoolDeckRefresh", root, CreateDeck )

function ResetDeck( )
    if isElement( UI_elements.trump ) then destroyElement( UI_elements.trump ) end
    if isElement( UI_elements.deck ) then destroyElement( UI_elements.deck ) end
    if isElement( UI_elements.lbl_amount ) then destroyElement( UI_elements.lbl_amount ) end
end