loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "CUI" )
Extend( "ib" )

UI_elements = { }
 
CONF = { 
    hand_card_sx = 133, 
    hand_card_sy = 200, 
} 

-----------------------------
-------- ИНТЕРФЕЙС ----------
-----------------------------
function ShowTableUI_handler( state )
    --iprint( "show table", state, game_info )
    if state then
        ShowTableUI_handler( false )

        GenerateFonts()

        UI_elements = { }

        x, y = guiGetScreenSize()

        UI_elements.bg_sound = playSound( "sfx/bg" .. math.random( 1, 1 ) .. ".ogg", true )
        setSoundVolume( UI_elements.bg_sound, 0.1 )
        -- Общий фон
        UI_elements.black_bg = ibCreateBackground( _, _, 0xaa000000 )
        
        
        -- Фон окна
        sx, sy          = 800, 580
        px, py          = x / 2 - sx / 2, y / 2 - sy / 2

        UI_elements.bg  = ibCreateRenderTarget( px, py + 100, sx, sy, UI_elements.black_bg ):ibData( "alpha", 0 )
        UI_elements.bg:ibAlphaTo( 255, 400 ):ibMoveTo( px, py, 500 )

        UI_elements.key_action_close = ibAddKeyAction( _, _, UI_elements.black_bg, function()
			OnTryLeftGame()
		end )

        UI_elements.bg_image = ibCreateImage( 0, 0, sx, sy, "img/bg.png", UI_elements.bg ):ibData( "priority", -1 )

        -- "Закрыть"
        UI_elements.btn_exit = ibCreateButton(	20, 516, 130, 44, UI_elements.bg,
                                                "img/btn_exit.png", "img/btn_exit.png", "img/btn_exit.png",
                                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        addEventHandler("ibOnElementMouseClick", UI_elements.btn_exit, function( key, state )
            if key ~= "left" or state ~= "up" then return end
            OnTryLeftGame()
        end, false )

        showCursor( true )
    else
        DestroyTableElements( UI_elements )
        UI_elements = { }

        if confirmation then confirmation:destroy() end

        showCursor( false )
    end
end
addEvent( "ShowTableUI", true )
addEventHandler( "ShowTableUI", root, ShowTableUI_handler )

function OnTryLeftGame()
    if confirmation then confirmation:destroy() end
    confirmation = ibConfirm({
        title = "ВЫХОД ИЗ ИГРЫ", 
        text = "Ты точно хочешь выйти из игры?\nТвоя ставка будет утеряна!",
        fn = function( self ) 
            self:destroy()
            ShowTableUI_handler( false )
            triggerServerEvent( "onFoolTableLeaveRequest", localPlayer, true )
        end
    })
end

-----------------------------------
------- ОБРАБОТЧИКИ СОБЫТИЙ -------
-----------------------------------
function onCasinoGameFoolStartRcv_handler( list )
    local hand          = list.hand 
    local trump_card    = list.trump_card
    local deck_amount   = list.deck_amount

    GAME_VAR            = list.game_var
    --iprint( "game var", GAME_VAR )
    
    ShowTableUI_handler( true )

    SetHand( hand )
    CreateDeck( deck_amount, trump_card )
    CreateTable( )
    CreateButtons( )
end
addEvent( "onCasinoGameFoolStartRcv", true )
addEventHandler( "onCasinoGameFoolStartRcv", root, onCasinoGameFoolStartRcv_handler )

function onCasinoGameFoolTurnChange_handler( player_turn, player_target, duration )
    if player_turn == localPlayer then
        --iprint( "Ваш ход!" )
        --localPlayer:ShowSuccess( "Твой ход!" )
        setSoundVolume( playSound( "sfx/yourturn.ogg" ), 0.2 )

        local sx, sy = 182, 70
        local px, py = 400 - sx / 2, 290 - sy / 2

        if isElement( UI_elements.bg ) then

            local image_yourturn_bg = ibCreateImage( 0, 0, 800, 580, nil, UI_elements.bg, 0x77000000 )
            image_yourturn_bg:ibBatchData( { alpha = 0, priority = 10 } )
            image_yourturn_bg:ibAlphaTo( 255, 150 )
            local image_yourturn = ibCreateImage( 400, -sy, 0, 0, "img/yourturn.png", UI_elements.bg )
            image_yourturn:ibBatchData( { alpha = 0, priority = 10 } )
            image_yourturn:ibAlphaTo( 255, 150 ):ibMoveTo( px, py, 150 ):ibResizeTo( sx, sy, 150 )
            setTimer( function( )
                if isElement( image_yourturn ) then
                    image_yourturn:ibAlphaTo( 0, 1000 )
                    image_yourturn_bg:ibAlphaTo( 0, 1000 )
                    setTimer( function( )
                        if isElement( image_yourturn ) then destroyElement( image_yourturn ) end
                        if isElement( image_yourturn_bg ) then destroyElement( image_yourturn_bg ) end
                    end, 1000, 1 )
                end
            end, 800, 1 )

        end
    else
        --iprint( "Ходит", player_turn, "на", player_target )

        setSoundVolume( playSound( "sfx/newturn.ogg" ), 0.2 )
    end

    CURRENT_PLAYER_TURN     = player_turn
    CURRENT_PLAYER_TARGET   = player_target

    UpdateButtons( )

    --RefreshPlayersTasks( )
end
addEvent( "onCasinoGameFoolTurnChange", true )
addEventHandler( "onCasinoGameFoolTurnChange", root, onCasinoGameFoolTurnChange_handler )


-------------------------------
----- Взятие карт и стола -----
-------------------------------
function onCasinoGameFoolTableClear_handler( target )
    CleanTable( )

    if target then playSound( "sfx/move" .. math.random( 1, 2 ) .. ".wav" ) end

    if target == localPlayer then
        --iprint( "Вы забрали стол" )
    elseif target then
        --iprint( target, "забрал весь стол" )
    else
        --iprint( "Стол чист, бита" )
    end
end
addEvent( "onCasinoGameFoolTableClear", true )
addEventHandler( "onCasinoGameFoolTableClear", root, onCasinoGameFoolTableClear_handler )

function onCasinoGameFoolAddToHand_handler( animate )
    if animate == "table" then
        --iprint( source, "Забрал все карты со стола" )
        CleanTable( )
    elseif animate == "deck" then
        --iprint( source, "Взял карту из колоды" )
    end
end
addEvent( "onCasinoGameFoolAddToHand", true )
addEventHandler( "onCasinoGameFoolAddToHand", root, onCasinoGameFoolAddToHand_handler )


function onCasinoGameFoolAskForContinuation_handler( )
    if confirmation then confirmation:destroy() end
        
    confirmation = ibConfirm(
        {
            title = "ПРОДОЛЖИТЬ ИГРУ?", 
            text = "У тебя есть 15 секунд чтобы решить хочешь ли ты продолжить игру или выйти из лобби",
            fn = function( self ) 
                self:destroy()
                triggerServerEvent( "onCasinoGameFoolAskForContinuationResultRcv", localPlayer, true )
            end,
            fn_cancel = function( self )
                self:destroy()
                triggerServerEvent( "onCasinoGameFoolAskForContinuationResultRcv", localPlayer, false )
            end,
            escape_close = true,
        }
    )

end
addEvent( "onCasinoGameFoolAskForContinuation", true )
addEventHandler( "onCasinoGameFoolAskForContinuation", root, onCasinoGameFoolAskForContinuation_handler )