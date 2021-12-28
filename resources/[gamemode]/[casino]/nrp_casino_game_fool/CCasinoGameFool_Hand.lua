----------------------------------
----- Рука локального игрока -----
----------------------------------

HAND_DRAGGING_CARD = nil 
HAND_ELEMENTS = { } 
HAND_CARD_OFFSET = 0
HAND_CARDS_LIST = { }

function ParseHandScroll( key, state, check_only )
    local old_offset = HAND_CARD_OFFSET
    if key == "mouse_wheel_up" then
        HAND_CARD_OFFSET = HAND_CARD_OFFSET - 1
    elseif key == "mouse_wheel_down" then
        HAND_CARD_OFFSET = HAND_CARD_OFFSET + 1
    end

    if HAND_CARD_OFFSET < 0 or #HAND_CARDS_LIST <= 6 and HAND_CARD_OFFSET ~= 0 then
        HAND_CARD_OFFSET = 0
    elseif #HAND_CARDS_LIST > 6 and HAND_CARD_OFFSET + 6 > #HAND_CARDS_LIST then
        HAND_CARD_OFFSET = #HAND_CARDS_LIST - 6
    end

    if HAND_CARD_OFFSET ~= old_offset and not check_only then
        SetHand( HAND_CARDS_LIST )
    end
end

function ResetHand( )
    for i = 1, 6 do
        if isElement( UI_elements[ "hand_" .. i ] ) then destroyElement( UI_elements[ "hand_" .. i ] ) end
        UI_elements[ "hand_" .. i ] = nil
    end
    HAND_CARDS_LIST = nil

    for i, v in pairs( UI_elements.hand_controls or { } ) do
        if isElement( v ) then destroyElement( v ) end
    end
    UI_elements.hand_controls = nil

    unbindKey( "mouse_wheel_up", "down", ParseHandScroll )
    unbindKey( "mouse_wheel_down", "down", ParseHandScroll )
end
 
function SetHand( list )  
    ResetHand( )

    if not isElement( UI_elements.bg ) then return end

    HAND_CARDS_LIST = list or { }
    ParseHandScroll( _, _, true )
 
    local px, py = 194, 470 
    local card_offset = HAND_CARD_OFFSET

    if not list then return end

    if #list > 6 then
        UI_elements.hand_controls = { }
        UI_elements.hand_controls.lbl_scroll = ibCreateLabel( 196, 448, 378, 12, "Прокрутите колёсико мышки для просмотра полного списка карт", UI_elements.bg )
        UI_elements.hand_controls.lbl_scroll:ibBatchData( { color = 0xaaffffff, font = fonts.regular_10, align_x = "center", align_y = "center" })
        
        UI_elements.hand_controls.btn_left = ibCreateButton(    168, 524, 14, 26, UI_elements.bg,
                                                                "img/btn_left.png", "img/btn_left.png", "img/btn_left.png",
                                                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        addEventHandler( "ibOnElementMouseClick", UI_elements.hand_controls.btn_left, function( key, state )
            if key ~= "left" or state ~= "down" then return end  
            ParseHandScroll( "mouse_wheel_up" )
        end, false )

        UI_elements.hand_controls.btn_right = ibCreateButton(    586, 524, 14, 26, UI_elements.bg,
                                                                "img/btn_left.png", "img/btn_left.png", "img/btn_left.png",
                                                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )                                                        
        UI_elements.hand_controls.btn_right:ibData( "rotation", 180 )

       addEventHandler( "ibOnElementMouseClick", UI_elements.hand_controls.btn_right, function( key, state )
            if key ~= "left" or state ~= "down" then return end  
            ParseHandScroll( "mouse_wheel_down" )
        end, false )

        bindKey( "mouse_wheel_up", "down", ParseHandScroll )
        bindKey( "mouse_wheel_down", "down", ParseHandScroll )
    end

    for i = 1, 6 do 
        local card_number = i + card_offset
        local card = list[ card_number ]

        if card then

            local texture = CardImageFile( card ) 
            local sx, sy = CONF.hand_card_sx, CONF.hand_card_sy 
    
            local this_px, this_py = px, py 
    
            local card_element = ibCreateImage( this_px, this_py, sx, sy, texture, UI_elements.bg )
            card_element:ibData( "priority", 1 )
            card_element:ibData( "card", card )
            card_element:ibData( "card_number", card_number )
    
            addEventHandler( "ibOnElementMouseEnter", card_element, function() 
                local state = card_element:ibData( "state" )
                if state then iprint( "state", state ) return end 
    
                ibMoveTo( card_element, this_px, this_py - 50, 250 ) 
                card_element:ibData( "state", true ) 
            end, false ) 
    
            addEventHandler( "ibOnElementMouseLeave", card_element, function() 
                if HAND_DRAGGING_CARD and HAND_DRAGGING_CARD.element == card_element then return end
                local state = card_element:ibData( "state" )
                if not state or state == "dragging" or state == "coming_back" then return end 
    
                ibMoveTo( card_element, this_px, this_py, 100 ) 
                card_element:ibData( "state", false ) 
            end, false ) 
    
            addEventHandler( "ibOnElementMouseClick", card_element, function( key, state ) 
                if key ~= "left" or state ~= "down" then return end  
             
                HAND_DRAGGING_CARD = {  
                    element         = card_element, 
                    original_px     = this_px,  
                    original_py     = this_py, 
                    original_sx     = sx,  
                    original_sy     = sy, 
                } 
    
                removeEventHandler( "onClientPreRender", root, renderDragging ) 
                addEventHandler( "onClientPreRender", root, renderDragging ) 
    
                card_element:ibData( "state", "dragging" ) 
                card_element:ibData( "priority", 2 )
                card_element:ibData( "disabled", true )

            end, false ) 
    
            UI_elements[ "hand_" .. i ]	= card_element 
            UI_elements[ "hand_pos_" .. card_number ] = card_element
        
            px = px + 50 
        end
    end 
     
    return true 
end 
addEvent( "onCasinoGameFoolHandSet", true )
addEventHandler( "onCasinoGameFoolHandSet", root, SetHand )
 
function renderDragging() 
    if not HAND_DRAGGING_CARD or not isElement( HAND_DRAGGING_CARD.element ) then 
        HAND_DRAGGING_CARD = nil
        removeEventHandler( "onClientPreRender", root, renderDragging ) 
        return 
    end 
     
    local card_element = HAND_DRAGGING_CARD.element 
    local card_element_state = card_element:ibData( "state" )
 
    local wpx, wpy = UI_elements.bg:ibData( "px" ), UI_elements.bg:ibData( "py" )

    local px, py = card_element:ibData( "px" ), card_element:ibData( "py" )
    if getKeyState( "mouse1" ) and card_element_state == "dragging" then 
  
        local mouse_px, mouse_py = getCursorPosition( ) 
        mouse_px, mouse_py = mouse_px * x, mouse_py * y 
 
        local card_sx, card_sy = card_element:ibData( "sx" ), card_element:ibData( "sy" )
        local diff_x, diff_y = mouse_px - px - wpx - card_sx / 2, mouse_py - py - wpy - card_sy / 2 
 
        local increment_x, increment_y = diff_x / 10, diff_y / 10 
 
        card_element:ibBatchData( { px = px + increment_x, py = py + increment_y } )
 
        if isMouseWithinRangeOf( wpx + 90, wpy + 105, 625, 300  ) then 
            local dragging_resized = card_element:ibData( "is_hovering_table" )
            if not dragging_resized then
                card_element:ibResizeTo( TABLE_CARD_CONF.sx, TABLE_CARD_CONF.sy, 100 )
                card_element:ibData( "is_hovering_table", true )
            end
            
        else
            local dragging_resized = card_element:ibData( "is_hovering_table" )
            if dragging_resized then
                card_element:ibResizeTo( HAND_DRAGGING_CARD.original_sx, HAND_DRAGGING_CARD.original_sy, 100 )
                card_element:ibData( "is_hovering_table", false )
            end
        end
 
    elseif card_element_state == "dragging" then 
        local hovered_element = ibGetHoveredElement( )

        --iprint( CURRENT_PLAYER_TURN, CURRENT_PLAYER_TARGET )

        local result = false
        local this_card = card_element:ibData( "card" )

        local can_use_cards = CURRENT_PLAYER_TURN == localPlayer or CURRENT_PLAYER_TARGET == localPlayer
        local is_hovering_table_card = hovered_element and hovered_element:ibData( "card_session" )

        -- Если сейчас ход игрока
        if CURRENT_PLAYER_TURN == localPlayer then
            result = true

        -- Если сейчас игрок отбивается
        elseif CURRENT_PLAYER_TARGET == localPlayer then
            -- Если навёл мышкой на другую карту
            if is_hovering_table_card then
                local card_session = is_hovering_table_card
                -- Если карту вообще можно бить
                if card_session then
                    if not card_session.beat then
                        local card = card_session.card
                        -- Если карта действительно может быть побита
                        if DoesCardBeatAnother( this_card, card, CURRENT_TRUMP ) then
                            result = hovered_element:ibData( "card_session_number" )
                        else
                            localPlayer:ShowError( "Эту карту не побить!" )
                        end
                    end
                end
            end
        end

        -- Карта успешно побита, высылаем запрос на сервер
        if can_use_cards and type( result ) == "number" then
            triggerServerEvent( "onCasinoFoolCardBeatRequest", resourceRoot, card_element:ibData( "card_number" ), result )
            card_element:ibData( "state", "waiting" )

        -- Если новая карта на стол, либо стол переводится
        elseif can_use_cards and 
            ( result == true or GAME_VAR == CASINO_GAME_FOOL_VAR_TRANSLATABLE and not is_hovering_table_card and CURRENT_PLAYER_TARGET == localPlayer ) 
            and card_element:ibData( "is_hovering_table" ) then
            triggerServerEvent( "onCasinoFoolCardAddRequest", resourceRoot, card_element:ibData( "card_number" ) )
            card_element:ibData( "state", "waiting" )

        -- Не туда навёл или карту не побить, возвращаем в руку
        else
            GetCardBackWithAnimation( card_element )
        end
 
    elseif card_element_state == "coming_back" then 

        local mouse_px, mouse_py = HAND_DRAGGING_CARD.original_px, HAND_DRAGGING_CARD.original_py 
        mouse_px, mouse_py = mouse_px, mouse_py 
 
        local diff_x, diff_y = mouse_px - px, mouse_py - py 
 
        local increment_x, increment_y = diff_x / 10, diff_y / 10 
        card_element:ibBatchData( { px = px + increment_x, py = py + increment_y } )
 
        local new_py = py + increment_y
        if math.ceil( new_py ) == mouse_py or math.floor( new_py ) == mouse_py then
            card_element:ibData( "state", false )
            --iprint( "finished coming back", card_element )
            HAND_DRAGGING_CARD = nil
        end
    end 
 
end

function GetCardBackWithAnimation( card_element )
    card_element:ibBatchData( { priority = 1, disabled = false, state = "coming_back" } )
    card_element:ibResizeTo( HAND_DRAGGING_CARD.original_sx, HAND_DRAGGING_CARD.original_sy, 100 ) 
end

function onCardUsageError_handler( card_number )
    --SetHand( HAND_CARDS_LIST )
    local card_element = UI_elements[ "hand_pos_" .. card_number ]
    if isElement( card_element ) then
        GetCardBackWithAnimation( card_element )
    end
end
addEvent( "onCardUsageError", true )
addEventHandler( "onCardUsageError", root, onCardUsageError_handler )