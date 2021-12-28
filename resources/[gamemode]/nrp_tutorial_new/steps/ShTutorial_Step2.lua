local id = "talk_to_npc"
local function GetSelf( ) return TUTORIAL_STEPS[ id ] end

TUTORIAL_STEPS[ id ] = {
    entrypoint = function( self )
        BlockAllKeys( )
        fadeCamera( false, 1.0 )
        setTimer( function( )
            DisableHUD( true )
            self.client_start_cutscene( )
            fadeCamera( true, 1.0 )
        end, 2000, 1 )
    end,

    client_start_cutscene = function( )
        local self = GetSelf( )

        self.stripes = CreateBlackStripes( )
        self.stripes:show( )

        self.ped = createPed( 108, 1775.112, -630.205+860, 60.856, 190 )
        setPedAnimation( self.ped, "ped", "IDLE_chat", -1, true, false, false )

        self.local_ped = createPed( localPlayer.model, 1775.560, -632.769+860, 60.856, 3.5 )
        setCameraMatrix( 1774.7780761719, -633.95196533203+860, 61.718490600586, 1806.5170898438, -539.02886962891+860, 43.571151733398, 0, 70 )
        showCursor( true )

        self.dialog = CreateDialog( {
            { name = "Администратор автосалона", text = "Босс, нужны документы на товар", voice_line = "Dominic_1" },
            { name = "Администратор автосалона", text = "Отлично, теперь можно принимать товар, вот ваши деньги с продаж", voice_line = "Dominic_2" },
            { custom = function( parent )
                local area = ibCreateArea( 0, 0, 0, 70, parent ):center_x( )
                ibCreateImage( 0, 0, 0, 0, "img/tips/takemoney.png", area ):ibSetRealSize( ):center( )
                return area
            end },
        } )
        self.dialog:reposition_to_stripes( self.stripes )

        -- Ставим машину в нужное положение
        CallServerStepFunction( id, "server_reposition_vehicle" )
        
        self.dialog:next( )
        setTimer( self.client_start_waiting_for_inventory, 3000, 1 )
    end,

    server_reposition_vehicle = function( self, player )
        player.dimension = player:GetUniqueDimension( )
        DestroyTutorialVehicle( player )
        CreateTutorialVehicleForPlayer( player, Vector3( 1797.427, -626.987+860, 60.741 ), Vector3( 0, 0, 336 ), true )
    end,

    server_give_docs = function( self, player )
        player:InventoryRemoveItem( IN_TUTORIAL_DOCS )
        player:InventoryAddTempItem( IN_TUTORIAL_DOCS )
    end,

    server_take_docs = function( self, player )
        player:InventoryRemoveTempItem( IN_TUTORIAL_DOCS )
    end,

    client_start_waiting_for_inventory = function( )
        local self = GetSelf( )
        CallServerStepFunction( id, "server_give_docs" )

        BlockAllKeys( { "q", "space" } )

        setPedAnimation( self.ped )

        self.hint = CreateSutiationalHint({
            py = _SCREEN_Y - 250,
            text = "Нажми key=Q чтобы открыть инвентарь и перетащи накладные на администратора",
            condition = function()
                return true
            end,
        } )

        local t = { }
        t.OnGiveTutorialDocs = function( )
            if self.hint then self.hint:destroy() end
            
            removeEventHandler( "onPlayerGiveTutorialDocs", localPlayer, t.OnGiveTutorialDocs )
            CallServerStepFunction( id, "server_take_docs" )

            -- Шаг 14 - Передача документов в катсцене
            triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 13, getRealTimestamp( ) - TUTORIAL_START_TICK )
            
            setPedAnimation( self.ped, "ped", "IDLE_chat", -1, true, false, false )

            self.dialog:next( )
            setTimer( function( )
                self.dialog:next( )

                -- Шаг 15 - Нажатие "Забрать"
                triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 14, getRealTimestamp( ) - TUTORIAL_START_TICK )

                local t = { }
                t.ParseSpace = function( )
                    unbindKey( "space", "down", t.ParseSpace )
                    ibClick( )

                    showCursor( false )
                    self.dialog:destroy_with_animation( )

                    local money = CreateMoneyHUD( 1000000 )
                    money:reposition_to_stripes( self.stripes )
                    setTimer( function( ) money:destroy_with_animation( 1000 ) end, 2000, 1 )

                    localPlayer:setData( "money", 1000000, false )

                    setTimer( function( ) fadeCamera( false, 2.0 ) end, 1000, 1 )
                    setTimer( self.client_finish_cutscene, 5000, 1 )
                end

                bindKey( "space", "down", t.ParseSpace )
            end, 3000, 1 )
        end
        addEventHandler( "onPlayerGiveTutorialDocs", localPlayer, t.OnGiveTutorialDocs )
    end,

    client_finish_cutscene = function( )
        local self = GetSelf( )
        DestroyTableElements( { self.ped, self.local_ped } )
        DisableHUD( false )
        self.stripes:destroy_with_animation( )

        UnblockAllKeys(  )

        StartTutorialStep( "go_home", false )
    end
}

addEvent( "onPlayerGiveTutorialDocs", true )