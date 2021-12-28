local id = "hospital_scene"
local function GetSelf( ) return TUTORIAL_STEPS[ id ] end

TUTORIAL_STEPS[ id ] = {
    entrypoint = function( self )
        local self = GetSelf( )

        DisableHUD( true )

        BlockAllKeys( )

        triggerEvent( "ClearAllPhoneNotifications", localPlayer )

        setTimer( function( )
            self.weeks_tip = CreateTip( "weeks" )
            SetTipImportant( self.weeks_tip )

            CallServerStepFunction( id, "server_set_default_data" )
        end, 2000, 1 )
    end,

    server_set_default_data = function( self, player )
        player.position  = Vector3( 1916.393, -515.410+860, 60.719 ):AddRandomRange( 4 )
        player.rotation  = Vector3( 0, 0, 355 )
        player.interior  = 0
        player.dimension = 0
        player.frozen    = true

        player:SetMoney( 2500, "TUTORIAL_FINISH" )

        player:SetPermanentData( "intro", "No" )

        triggerEvent( "onGameTimeRequest", player )

        CallClientStepFunction( player, id, "client_start_info" )
    end,

    client_start_info = function( self )
        setTimer( function( )
            DestroyTip( self.weeks_tip )
            setCameraTarget( localPlayer )
            
            setTimer( function( )
                fadeCamera( true, 2.0 )

                setTimer( function( )
                    -- Шаг 19 - Показ окна 1
                    triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 18, getRealTimestamp( ) - TUTORIAL_START_TICK )
                    ShowWindow( ):create_mafia( )
                end, 3000, 1 )

            end, 1000, 1 )

        end, 4000, 1 )
    end,

    client_show_chat_keys = function( )
        local self = GetSelf( )
        BlockAllKeys( { "t", "z" } )

        self.tip_chat = CreateTip( "chat" )
        SetTipImportant( self.tip_chat )

        local t = { }
        t.CheckKeys = function( )
            unbindKey( "z", "down", t.CheckKeys )
            unbindKey( "t", "down", t.CheckKeys )

            DestroyTip( self.tip_chat )
            setTimer( function( )
                removeEventHandler( "onClientPlayerDamage", localPlayer, onClientPlayerDamage_handler )
                DisableHUD( false )
                triggerEvent( "ShowInventoryHotbar", localPlayer, true, "tutorial" )
                UnblockAllKeys( )
                triggerServerEvent( "onPlayerCompleteTutorial", localPlayer, localPlayer, true )
                CallServerStepFunction( id, "server_unfreeze_player" )
                ShowNPCs( )
            end, 2000, 1 )

        end

        bindKey( "z", "down", t.CheckKeys )
        bindKey( "t", "down", t.CheckKeys )
    end,

    server_unfreeze_player = function( self, player )
        player.frozen = false
        player.health = 100

        --player:PhoneNotification( { title = "Неизвестный номер", msg = "Здарова это Александр, я слышал, что ты уже выздоровел. Зайди ко мне, есть новости. Журнал квестов - кнопка F2." } )
    end,
}

function ShowWindow( )
    local self = { }

    showCursor( true )
    self.black_bg = ibCreateBackground( _, _, true ):ibData( "alpha", 0 ):ibAlphaTo( 255, 500 )

    self.destroy = function( )
        DestroyTableElements( self )
        setmetatable( self, nil )
        local action = GetSelf( )
        setTimer( action.client_show_chat_keys, 1000, 1 )
    end

    self.destroy_with_animation = function( )
        self.black_bg:ibAlphaTo( 0, 500 ):ibTimer( function( ) self:destroy( ) end, 500, 1 )
    end

    self.create_mafia = function( )
        self.window = ibCreateImage( 0, 0, 0, 0, "img/bg_mafia.png", self.black_bg ):ibSetRealSize( ):center( )
        local text = [[Тебя ограбила мафия, отняв у тебя все средства, оставив тебе только паспорт... Верни всё, что принадлежало тебе и восстанови справедливость! Как это сделать - решать тебе!]]
        ibCreateLabel( 0, 245, 535, 0, text, self.window, _, _, _, "center", "top", ibFonts.regular_18 ):ibData( "wordbreak", true ):center_x( )
        local btn = ibCreateImage( 0, 338, 0, 0, "img/btn_next.png", self.window )
            :ibData( "alpha", 200 )
            :ibSetRealSize( ):center_x( )
            :ibOnHover( function( )
                source:ibAlphaTo( 255, 100 )
            end )
            :ibOnLeave( function( )
                source:ibAlphaTo( 200, 100 )
            end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                self.window:destroy( )
                self:create_ways( )

                -- Шаг 20 - Показ окна 2
                triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 19, getRealTimestamp( ) - TUTORIAL_START_TICK )
            end )
    end

    self.create_ways = function( )
        self.window = ibCreateImage( 0, 0, 0, 0, "img/bg_ways.png", self.black_bg ):ibSetRealSize( ):center( ):ibData( "alpha", 0 ):ibAlphaTo( 255, 500 )

        local infos = {
            { tab = { 2, "Работы", 1 } },
            { tab = { 2, "Фракции", 1 } },
            { tab = { 2, "Кланы", 1 } },
        }

        local npx = 71
        for i, v in pairs( infos ) do
            local btn = ibCreateImage( npx, 493, 0, 0, "img/btn_more.png", self.window )
                :ibData( "alpha", 200 )
                :ibSetRealSize( )
                :ibOnHover( function( )
                    source:ibAlphaTo( 255, 100 )
                end )
                :ibOnLeave( function( )
                    source:ibAlphaTo( 200, 100 )
                end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    triggerEvent( "ShowInfoUI", localPlayer, true, v.tab )
                end )
            
            npx = npx + 253
        end

        ibCreateButton( self.window:ibData( "sx" ) - 24 - 24, 24, 22, 22, self.window,
                        ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                        0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                showCursor( false )
                self:destroy_with_animation( )

                -- Шаг 21 - Закрытие окна 2
                triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), -2, getRealTimestamp( ) - TUTORIAL_START_TICK )
            end )
    end

    return self
end