GIFTS = {
    [ 1 ] = {
        default_wait = 1 * 60 * 60,
        reward_money = 600,
        onstart = {
            client = function( self, data )
                triggerEvent( "onKsushaWaitStart", localPlayer, data.finish_time - getRealTimestamp( ) )
            end,
        },
        ontimer = {
            client = function( self, data )
                triggerEvent( "onKsushaWaitStop", localPlayer )

                local position = FindQuestNPC( "angela" ).position
                self.tpoint = CreatePoint( position, function( )
                    GivePlayerGift( self.id )

                    local dialog = CreateDialog( { {
                        name = "Анжела",
                        text = "Привет, не переживай, она тебя не динамит, уж поверь.\nПравда очень много дел на нее свалилось. Оставила тебе подарок.",
                        voice_line = "Angela_3",
                    } } )
                    dialog:next( )

                    setTimer( function( )
                        dialog:destroy_with_animation( )
                        localPlayer:ShowRewards( { type = "soft", value = localPlayer:getData( "economy_hard_test" ) and self.reward_economy_test or self.reward_money } )
                    end, 9000, 1 )

                end, "", 1.5, 0, 0, function( )
                    if localPlayer:IsInStoryQuest( ) then
                        return false, "Закончи текущую задачу чтобы продолжить!"
                    end
                    return true
                end, _, _, "checkpoint" )
            end,
            server = function( self, player, data )
                player:PhoneNotification( { title = "Ксюша", msg = "Привет, я сильно извиняюсь перед тобой, но давай перенесем встречу. Меня задерживают в командировке. Передала тебе подарок он у Анжелы. Через 30 минут встретимся." } )
            end,
        },
        ondone = {
            client = function( self, data )
                self.tpoint:destroy( )
            end,
            server = function( self, player, data )
                ClearPlayerGiftWait( player, self.id )
                player:GiveMoney( self.reward_money, "KSUSHA_WAIT_1" )
                StartPlayerGiftWait( player, 2 )
            end,
        },
    },

    [ 2 ] = {
        default_wait = 30 * 60,
        reward_money = 750,
        onstart = {
            client = function( self, data )
                triggerEvent( "onKsushaWaitStart", localPlayer, data.finish_time - getRealTimestamp( ) )
            end,
        },
        ontimer = {
            client = function( self, data )
                triggerEvent( "onKsushaWaitStop", localPlayer )

                local position = FindQuestNPC( "angela" ).position
                self.tpoint = CreatePoint( position, function( )
                    GivePlayerGift( self.id )

                    local dialog = CreateDialog( { {
                        name = "Анжела",
                        text = "Привет, не злись, Ксения там вся на иголках.\nДико извиняется, но забери подарок от нее.",
                        voice_line = "Angela_4",
                    } } )
                    dialog:next( )

                    setTimer( function( )
                        dialog:destroy_with_animation( )
                        localPlayer:ShowRewards( { type = "soft", value = localPlayer:getData( "economy_hard_test" ) and self.reward_economy_test or self.reward_money } )
                    end, 9000, 1 )
                end, "", 1.5, 0, 0, function( )
                    if localPlayer:IsInStoryQuest( ) then
                        return false, "Закончи текущую задачу чтобы продолжить!"
                    end
                    return true
                end, _, _, "checkpoint" )
            end,
            server = function( self, player, data )
                player:PhoneNotification( { title = "Ксюша", msg = "Привет, я не специально, но прости, и все же давай перенесем встречу. Меня задерживают в командировке. Передала тебе подарок он у Анжелы. Через 1 час встретимся." } )
            end,
        },
        ondone = {
            client = function( self, data )
                self.tpoint:destroy( )
            end,
            server = function( self, player, data )
                ClearPlayerGiftWait( player, self.id )
                player:GiveMoney( self.reward_money, "KSUSHA_WAIT_2" )
                StartPlayerGiftWait( player, 3 )
            end,
        },
    },

    [ 3 ] = {
        default_wait = 30 * 60,
        reward_money = 1000,
        onstart = {
            client = function( self, data )
                triggerEvent( "onKsushaWaitStart", localPlayer, data.finish_time - getRealTimestamp( ) )
            end,
        },
        ontimer = {
            client = function( self, data )
                triggerEvent( "onKsushaWaitStop", localPlayer )

                local position = FindQuestNPC( "angela" ).position
                self.tpoint = CreatePoint( position, function( )
                    GivePlayerGift( self.id )
                    local dialog = CreateDialog( { {
                        name = "Анжела",
                        text = "Привет. Ксюша скоро приедет. Я понимаю как это выглядит,\nно давай без истерик, вот тебе успокоительный подарок от нее.",
                        voice_line = "Angela_5",
                    } } )
                    dialog:next( )

                    setTimer( function( )
                        dialog:destroy_with_animation( )
                        localPlayer:ShowRewards( { type = "soft", value = localPlayer:getData( "economy_hard_test" ) and self.reward_economy_test or self.reward_money } )
                    end, 9000, 1 )
                end, "", 1.5, 0, 0, function( )
                    if localPlayer:IsInStoryQuest( ) then
                        return false, "Закончи текущую задачу чтобы продолжить!"
                    end
                    return true
                end, _, _, "checkpoint" )
            end,
            server = function( self, player, data )
                player:PhoneNotification( { title = "Ксюша", msg = "Привет, я не специально, но прости, и все же давай перенесем встречу. Меня задерживают в командировке. Передала тебе подарок он у Анжелы. Через 30 минут встретимся." } )
            end,
        },
        ondone = {
            client = function( self, data )
                self.tpoint:destroy( )
            end,
            server = function( self, player, data )
                ClearPlayerGiftWait( player, self.id )
                player:GiveMoney( self.reward_money, "KSUSHA_WAIT_3" )
                StartPlayerGiftWait( player, 4 )
            end,
        },
    },

    [ 4 ] = {
        default_wait = 1 * 60 * 60,
        onstart = {
            client = function( self, data )
                triggerEvent( "onKsushaWaitStart", localPlayer, data.finish_time - getRealTimestamp( ) )
            end,
        },
        ontimer = {
            client = function( self, data )
                triggerEvent( "onKsushaWaitStop", localPlayer )
            end,
            server = function( self, player, data )
                player:PhoneNotification( { title = "Ксюша", msg = "Привет, я наконец освободилась. Подъезжай к дому Анжелы я у нее." } )
                GivePlayerGift( player, self.id )
            end,
        },
        ondone = {
            client = function( self, data )
                -- pass
            end,
            server = function( self, player, data )
                ClearPlayerGiftWait( player, self.id )
                player:GiveExp( 1000 )
                player:SetQuestEnabled( "ksusha_hotel", true )
            end,
        },
    },
}

for i, v in pairs( GIFTS ) do
    v.id = i
end