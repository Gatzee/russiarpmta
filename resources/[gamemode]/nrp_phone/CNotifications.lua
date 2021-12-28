NOTIFICATIONSAPP = nil

pNotificationsCache = { }
pNotifTexturesTemp = {}

SPECAIL_NOTIFICATIONS = 
{
    race_lobby_created = 
    {
        draw_func = function( self, parent, conf, k, data )
            local title = data.title or "Уличная гонка"
            local lbl_title = ibCreateLabel( 15, self.py, 0, 0, title, parent ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 20 + lbl_title:width( ), self.py, 0, 0, data.time, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_9 )
            local lbl_msg = ibCreateLabel( 15, self.py+15, conf.sx-40, 0, data.msg or "Открыта новая уличная гонка!", parent, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            local but_accept = ibCreateButton( 15, self.py + 55 + ( lbl_msg:width( ) > conf.sx-40 and lbl_msg:height() or 0 ), 86, 28, parent, 
                            pNotifTexturesTemp.accept_texture, pNotifTexturesTemp.accept_texture, pNotifTexturesTemp.accept_texture,
                            0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function(key, state)
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                local can_join, msg = localPlayer:CanJoinToEvent({ event_type = "race", skip_check_job = true })
		        if not can_join then
                    localPlayer:ShowError( msg )
                    return true
                end
                
                if localPlayer:GetOnShift( ) or localPlayer:IsOnFactionDuty() then
                    onTryStopJobByEvent( data.title or "Уличная гонка", function()
                        triggerEvent( "onClientRaceWindowShow", resourceRoot )
                        triggerServerEvent( "RC:OnPlayerAcceptedLobbyInvitation", localPlayer, data.args.id )
                    end )
                    return
                end
                
                triggerEvent( "onClientRaceWindowShow", resourceRoot )
                triggerServerEvent("RC:OnPlayerAcceptedLobbyInvitation", localPlayer, data.args.id)
                ShowPhoneUI( false )
            end )

            ibCreateButton( 110, but_accept:ibData( 'py' ), 86, 28, parent, 
                            pNotifTexturesTemp.cancel_texture, pNotifTexturesTemp.cancel_texture, pNotifTexturesTemp.cancel_texture, 
                            0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function(key, state)
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                RemoveNotification( k )
            end )
        end,

        height = 104,
    },

    race_drag_created = 
    {
        draw_func = function( self, parent, conf, k, data )
            local title = data.title or "Драг рейсинг"
            local lbl_title = ibCreateLabel( 15, self.py, 0, 0, title, parent ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 20 + lbl_title:width( ), self.py, 0, 0, data.time, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_9 )
            local lbl_msg = ibCreateLabel( 15, self.py+15, conf.sx-40, 0, data.msg or "Открыта новая уличная гонка!", parent, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            local but_accept = ibCreateButton( 15, self.py + 70 + ( lbl_msg:width( ) > conf.sx-40 and lbl_msg:height() or 0 ), 86, 28, parent, 
                            pNotifTexturesTemp.accept_texture, pNotifTexturesTemp.accept_texture, pNotifTexturesTemp.accept_texture,
                            0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function(key, state)
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                local can_join, msg = localPlayer:CanJoinToEvent({ event_type = "race", skip_check_job = true })
		        if not can_join then
                    localPlayer:ShowError( msg )
                    return true
                end
                
                if localPlayer:GetOnShift( ) or localPlayer:IsOnFactionDuty() then
                    onTryStopJobByEvent( data.title or "Драг рейсинг", function()
                        triggerServerEvent( "RC:OnPlayerAcceptedDragInvitation", localPlayer, true, data.args.id )
                    end )
                    return
                end

                triggerEvent( "onClientRaceWindowShow", resourceRoot )
                triggerServerEvent( "RC:OnPlayerAcceptedDragInvitation", localPlayer, true, data.args.id )
                ShowPhoneUI( false )
            end )

            ibCreateButton( 110, but_accept:ibData( 'py' ), 86, 28, parent, 
                            pNotifTexturesTemp.cancel_texture, pNotifTexturesTemp.cancel_texture, pNotifTexturesTemp.cancel_texture, 
                            0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function(key, state)
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                RemoveNotification( k )
                triggerEvent( "onClientRaceWindowShow", resourceRoot )
                triggerServerEvent( "RC:OnPlayerAcceptedDragInvitation", localPlayer, false, data.args.id )
                if isTimer( self[ "drag_destroy_tmr" .. k ]  ) then
                    killTimer( self[ "drag_destroy_tmr" .. k ]  )
                end
            end )
        end,

        height = 104,
    },

    roulette_spin_earned = 
    {
        draw_func = function( self, parent, conf, k, data )
            local title = data.title or "Колесо фортуны"
            local lbl_title = ibCreateLabel( 15, self.py, 0, 0, title, parent ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 20 + lbl_title:width( ), self.py, 0, 0, data.time, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 15, self.py+15, conf.sx-40, 0, data.msg or "Ты получил жетон для колеса фортуны!", parent, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            ibCreateButton( 55, self.py + 55, 86, 28, parent, 
                pNotifTexturesTemp.accept_texture, pNotifTexturesTemp.accept_texture, pNotifTexturesTemp.accept_texture,
                            0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function(key, state)
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                triggerServerEvent("InitRouletteWindow", localPlayer)
				SendElasticGameEvent( "f4r_phone_wof_icon_click" )
                RemoveNotification( k )
                ShowPhoneUI( false )
            end )
        end,

        height = 94,
    },

    clan_event_created = 
    {
        draw_func = function( self, parent, conf, k, data )
            local title = data.title
            local lbl_title = ibCreateLabel( 15, self.py, 0, 0, title, parent ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 20 + lbl_title:width( ), self.py, 0, 0, data.time, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 15, self.py+15, conf.sx-40, 0, data.msg, parent, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            ibCreateButton( 15, self.py + 55, 86, 28, parent, 
                            pNotifTexturesTemp.accept_texture, pNotifTexturesTemp.accept_texture, pNotifTexturesTemp.accept_texture,
                            0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function(key, state)
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                local can_join, msg = localPlayer:CanJoinToEvent({ event_type = "clan_event_created", skip_check_job = true })
		        if not can_join then
                    localPlayer:ShowError( msg )
                    return true
                end
                
                if localPlayer:GetOnShift( ) or localPlayer:IsOnFactionDuty() then
                    onTryStopJobByEvent( data.title, function()
                        triggerServerEvent( "CEV:OnPlayerRequestEventRegister", localPlayer, data.args.lobby_id )
                        RemoveNotification( k )
                    end )
                    return
                end
                
                triggerServerEvent( "CEV:OnPlayerRequestEventRegister", localPlayer, data.args.lobby_id )
                RemoveNotification( k )
            end )

            ibCreateButton( 110, self.py + 55, 86, 28, parent, 
                            pNotifTexturesTemp.cancel_texture, pNotifTexturesTemp.cancel_texture, pNotifTexturesTemp.cancel_texture,
                            0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                RemoveNotification( k )
            end )

        end,

        height = 88,
    },

    clan_event_join =
    {
        draw_func = function( self, parent, conf, k, data )
            local title = data.title
            local lbl_title = ibCreateLabel( 15, self.py, 0, 0, title, parent ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 20 + lbl_title:width( ), self.py, 0, 0, data.time, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 15, self.py+15, conf.sx-40, 0, data.msg, parent, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            ibCreateButton( 15, self.py + 55, 86, 28, parent, 
                            pNotifTexturesTemp.accept_texture, pNotifTexturesTemp.accept_texture, pNotifTexturesTemp.accept_texture,
                            0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function(key, state)
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                local can_join, msg = localPlayer:CanJoinToEvent({ event_type = "clan_event_join", skip_check_job = true })
		        if not can_join then
                    localPlayer:ShowError( msg )
                    return true
                end
                
                if localPlayer:GetOnShift( ) or localPlayer:IsOnFactionDuty() then
                    onTryStopJobByEvent( data.title, function()
                        triggerServerEvent( "CEV:OnPlayerRequestEventJoin", localPlayer )
                        RemoveNotification( k )
                    end )
                    return
                end
                
                triggerServerEvent( "CEV:OnPlayerRequestEventJoin", localPlayer )
                RemoveNotification( k )
            end )

            ibCreateButton( 110, self.py + 55, 86, 28, parent, 
                            pNotifTexturesTemp.cancel_texture, pNotifTexturesTemp.cancel_texture, pNotifTexturesTemp.cancel_texture,
                            0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                RemoveNotification( k )
            end )

        end,

        height = 88,
    },

    megaphone_notification =
    {
        draw_func = function( self, parent, conf, k, data )
            local title = data.title
            local lbl_title = ibCreateLabel( 15, self.py, 0, 0, title, parent ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 20 + lbl_title:width( ), self.py, 0, 0, data.time, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_9 )
            
            local text_sx, text_sy = dxGetTextSize( data.msg, conf.sx-40, 1, ibFonts.regular_9, true)
            local text_area = ibCreateArea( 15, self.py+15, conf.sx-40, text_sy, parent )
            ibCreateLabel( 0, 0, conf.sx-40, 0, data.msg, text_area, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            ibCreateButton( 15, self.py + 20 + text_sy, 86, 28, parent,  pNotifTexturesTemp.accept_texture, pNotifTexturesTemp.accept_texture, pNotifTexturesTemp.accept_texture, 0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function(key, state)
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    
                    triggerEvent( "ToggleGPS", localPlayer, Vector3( unpack( data.position ) ) )
                    RemoveNotification( k )
                end )  
            
            ibCreateButton( 110, self.py + 20 + text_sy, 86, 28, parent, pNotifTexturesTemp.cancel_texture, pNotifTexturesTemp.cancel_texture, pNotifTexturesTemp.cancel_texture, 0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )

                    RemoveNotification( k )
                end )

            return text_sy + 50
        end,
    },

	events_lobby_created = {
		draw_func = function( self, parent, conf, k, data )
			ibCreateLabel( 0, self.py + 13, 0, 0, "Лобби собрано. Готов?", parent, COLOR_WHITE, 1, 1, "center", "center" ):center_x( ):ibData( "font", ibFonts.bold_11 )

			local btn = ibCreateButton( 0, self.py + 30, 86, 28, parent, "img/elements/notifications/btn_accept.png", _, _, 0xFFFFFFFF, 0xAAFFFFFF, 0xAAFFFFFF ):center_x( -20 )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					ibClick( )
                    local can_join, msg = localPlayer:CanJoinToEvent({ event_type = "events_lobby_created", skip_check_job = true })
		            if not can_join then
                        localPlayer:ShowError( msg )
                        return true
		            end
					triggerServerEvent( "LobbyEventPlayerReady", root )
					ShowPhoneUI( false )
				end )

			ibCreateLabel( btn:ibGetAfterX( 10 ), self.py + 45, 0, 0, ( data.args.timeout - getRealTimestamp( ) ) .." с.", parent, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_10 )
				:ibTimer( function( self )
					local seconds = data.args.timeout - getRealTimestamp( )
					if seconds >= 0 then
						self:ibData( "text", seconds .." с." )
					end
				end, 500, 0 )
		end,
		height = 65,
	},

    admin_event = {
        draw_func = function( self, parent, conf, k, data )
            local title = data.title
            local lbl_title = ibCreateLabel( 15, self.py, 0, 0, title, parent ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 20 + lbl_title:width( ), self.py, 0, 0, data.time, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 15, self.py+15, conf.sx-40, 0, "Начат набор на ивент - \"" .. title .. "\"", parent, 0xFFFFFFFF )
                :ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            ibCreateButton( 15, self.py + 55, 86, 28, parent, pNotifTexturesTemp.accept_texture, _, _, 0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function(key, state)
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    local can_join, msg = localPlayer:CanJoinToEvent({ event_type = "admin_event" })
                    if not can_join then
                        localPlayer:ShowError( msg )
                        return true
                    end
                    triggerServerEvent( "onPlayerJoinToAdminEvent", localPlayer, data.args.event_id )
                    RemoveNotification( k )
                end )

            ibCreateButton( 110, self.py + 55, 86, 28, parent, pNotifTexturesTemp.cancel_texture, _, _,  0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    RemoveNotification( k )
                end )
        end,

        height = 88,
    },

    medic_revive_call = {
        height = 0,
        draw_func = function( self, parent, conf, k, data )
            local target = data.args.target
            local time_left = 2 * 60 - ( os.time( ) - data.receive_timestamp )
            if time_left <= 0 or not isElement( target ) then
                parent:ibTimer( function( self )
					RemoveNotification( k )
                end, 0, 1 )
                return
            end

            -- local title = "Минздрав"
            -- local lbl_title = ibCreateLabel( 15, self.py, 0, 0, title, parent ):ibData( "font", ibFonts.regular_9 )
            -- ibCreateLabel( 20 + lbl_title:width( ), self.py, 0, 0, data.time, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_9 )
            
            local msg = target:GetNickName( ) .. " в критическом состоянии, у вас есть 2 минуты чтобы спасти его! "
            local text, lines_count = GetWrappedText( msg, conf.sx-40, ibFonts.regular_9 )
            ibCreateLabel( 15, self.py, conf.sx-40, lines_count * 15, text, parent, 0xFFFFFFFF )
                :ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )
                :ibTimer( function( self )
					RemoveNotification( k )
                end, time_left * 1000, 0 )

            local height = lines_count * 15 + 10

            ibCreateButton( 15, self.py + height, 86, 28, parent, pNotifTexturesTemp.accept_texture, _, _, 0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function(key, state)
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    RemoveNotification( k )
                    if not isElement( target ) then return end
                    triggerServerEvent( "onMedicTryAcceptReviveCall", localPlayer, target )
                end )

            ibCreateButton( 110, self.py + height, 86, 28, parent, pNotifTexturesTemp.cancel_texture, _, _,  0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    RemoveNotification( k )
                end )

            height = height + 33
            return height
        end,
    },

    got_player_statistic = {
        draw_func = function( self, parent, conf, k, data )
            local lbl_title = ibCreateLabel( 15, self.py, 0, 0, data.title, parent ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 20 + lbl_title:width( ), self.py, 0, 0, data.time, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 15, self.py+15, conf.sx-40, 0, data.msg, parent, 0xFFFFFFFF )
            :ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            ibCreateButton( 15, self.py + 65, 86, 28, parent, "img/elements/notifications/btn_open.png", _, _, 0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function(key, state)
                if key ~= "left" or state ~= "up" then return end

                ibClick( )
                RemoveNotification( k )
                triggerEvent( "socialInteractionShowStats", localPlayer, data.player, data.is_achievements )
            end )

            ibCreateButton( 110, self.py + 65, 86, 28, parent, pNotifTexturesTemp.cancel_texture, _, _,  0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibClick( )
                RemoveNotification( k )
                triggerServerEvent( "socialInteractionDontShowStats", localPlayer, data.player, data.is_achievements )
            end )
        end,
        height = 104,
    },

    party_by_youtuber = {
        draw_func = function( self, parent, conf, k, data )
            local lbl_title = ibCreateLabel( 15, self.py, 0, 0, data.title, parent ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 20 + lbl_title:width( ), self.py, 0, 0, data.time, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 15, self.py+15, conf.sx - 40, 0, data.msg, parent, 0xFFFFFFFF )
            :ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            ibCreateButton( 15, self.py + 65, 86, 28, parent, "img/elements/notifications/btn_accept.png", _, _, 0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function(key, state)
                if key ~= "left" or state ~= "up" then return end

                ibClick( )
                RemoveNotification( k )
                triggerServerEvent( "onPartyStart", localPlayer )
            end )

            ibCreateButton( 110, self.py + 65, 86, 28, parent, pNotifTexturesTemp.cancel_texture, _, _,  0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibClick( )
                RemoveNotification( k )
            end )
        end,
        height = 104,
    },

    factions_reward = {
        draw_func = function( self, parent, conf, k, data )
            ibCreateLabel( 15, self.py, 0, 0, data.title, parent ):ibData( "font", ibFonts.bold_10 )
            ibCreateLabel( 15, self.py + 25, conf.sx - 40, 0, data.msg, parent )
            :ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            ibCreateButton( 15, self.py + 105, 97, 23, parent, "img/elements/notifications/btn_show_more", true )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibClick( )
                RemoveNotification( k )

                triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "premium" )
            end )

            ibCreateButton( 120, self.py + 105, 71, 23, parent, pNotifTexturesTemp.cancel_texture, nil, nil,  0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibClick( )
                RemoveNotification( k )
            end )
        end,
        height = 130,
    },

    order_for_bounty = {
        draw_func = function( self, parent, conf, k, data )
            ibCreateLabel( 60, self.py + 10, 0, 0, "На вас началась охота", parent ):ibData( "font", ibFonts.regular_9 )
            ibCreateImage( 14, self.py + 15, 39, 39, "img/elements/hunting.png", parent )

            ibCreateButton( 60, self.py + 32, 97, 23, parent, "img/elements/notifications/btn_show_more", true )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibClick( )
                RemoveNotification( k )

                triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "services" )
            end )
        end,
        height = 70,
    },

    new_year_auction_rerate = {
        draw_func = function( self, parent, conf, k, data )
            local lbl_title = ibCreateLabel( 15, self.py, 0, 0, data.title, parent ):ibData( "font", ibFonts.bold_10 )

            ibCreateLabel( 15, self.py + 25, 0, 0, data.msg, parent ):ibData( "font", ibFonts.regular_9 )

            if data.finish then return end

            ibCreateButton( 60, self.py + 63, 97, 23, parent, "img/elements/notifications/btn_show_more", true )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                
                    ibClick( )
                    RemoveNotification( k )
                
                    triggerServerEvent( "onServerPlayerRequestNewYearAuction", localPlayer )
                end )
        end,
        height = 90,
    },

    order_for_bounty_completed = {
        draw_func = function( self, parent, conf, k, data )
            local lbl_title = ibCreateLabel( 15, self.py, 0, 0, data.title, parent ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 20 + lbl_title:width( ), self.py, 0, 0, data.time, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 15, self.py+15, conf.sx-40, 0, data.msg, parent, 0xFFFFFFFF )
            :ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            ibCreateButton( 15, self.py + 70, 86, 28, parent, "img/elements/notifications/btn_accept.png", _, _, 0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function(key, state)
                if key ~= "left" or state ~= "up" then return end

                ibClick( )
                RemoveNotification( k )
                triggerEvent( "onPlayerShowOrderComplete", localPlayer, data.data )
            end )

            ibCreateButton( 110, self.py + 70, 86, 28, parent, pNotifTexturesTemp.cancel_texture, _, _,  0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibClick( )
                RemoveNotification( k )
            end )
        end,
        height = 100,
    },

    coop_job_invite =
    {
        draw_func = function( self, parent, conf, k, data )

            local job_icon = ibCreateImage( 15, self.py, 25, 25, ":nrp_job_coop_controller/img/" .. JOB_ID[ data.args.job_class ] .. "/marker.png", parent )

            local lbl_title = ibCreateLabel( job_icon:ibGetAfterX() + 5, self.py + 8, 0, 0, data.title or "Работа", parent ):ibData( "font", ibFonts.regular_10 )

            ibCreateLabel( 50 + lbl_title:width( ), lbl_title:ibData( 'py' ), 0, 0, data.time, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_10 )
            local lbl_msg = ibCreateLabel( 15, self.py + 29, conf.sx - 40, 0, "Приглашение на смену", parent, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            local lbl_owner = ibCreateLabel( 15, self.py + 48, conf.sx - 40, 0, "Основатель: " .. data.args.owner, parent, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            local but_accept = ibCreateButton( 15, self.py + 83 + ( lbl_msg:width( ) > conf.sx-40 and lbl_msg:height() or 0 ), 86, 28, parent,  pNotifTexturesTemp.accept_texture, pNotifTexturesTemp.accept_texture, pNotifTexturesTemp.accept_texture, 0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                if localPlayer:GetOnShift( ) or localPlayer:IsOnFactionDuty() then
                    onTryStopJobByEvent( data.title or "Работа", function()
                        RemoveNotification( k )
                        triggerServerEvent( data.args.trigger, localPlayer, data.args.id )
                    end )
                    return
                end

                RemoveNotification( k )
                triggerServerEvent( data.args.trigger, localPlayer, data.args.id )
                ShowPhoneUI( false )
            end )

            ibCreateButton( 110, but_accept:ibData( 'py' ), 86, 28, parent, pNotifTexturesTemp.cancel_texture, pNotifTexturesTemp.cancel_texture, pNotifTexturesTemp.cancel_texture, 0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function(key, state)
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                RemoveNotification( k )
            end )
        end,

        height = 114,
    },

    coop_job_leave =
    {
        draw_func = function( self, parent, conf, k, data )

            local job_icon = ibCreateImage( 15, self.py, 25, 25, ":nrp_job_coop_controller/img/" .. JOB_ID[ data.args.job_class ] .. "/marker.png", parent )

            local lbl_title = ibCreateLabel( job_icon:ibGetAfterX() + 5, self.py + 8, 0, 0, data.title or "Работа", parent ):ibData( "font", ibFonts.regular_10 )

            ibCreateLabel( 50 + lbl_title:width( ), lbl_title:ibData( 'py' ), 0, 0, data.time, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_10 )
            local lbl_msg = ibCreateLabel( 15, self.py + 29, conf.sx - 40, 0, "Покинуть смену", parent, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            local lbl_owner = ibCreateLabel( 15, self.py + 44, conf.sx - 40, 0, "Основатель: " .. data.args.owner, parent, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            local but_accept = ibCreateButton( 59, self.py + 79 + ( lbl_msg:width( ) > conf.sx-40 and lbl_msg:height() or 0 ), 86, 28, parent,  pNotifTexturesTemp.cancel_texture, pNotifTexturesTemp.cancel_texture, pNotifTexturesTemp.cancel_texture, 0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                if localPlayer:GetOnShift( ) or localPlayer:IsOnFactionDuty() then
                    onTryStopJobByEvent( data.title or "Работа", function()
                        RemoveNotification( k )
                        triggerServerEvent( data.args.trigger, localPlayer, data.args.id )
                    end )
                    return
                end

                RemoveNotification( k )
                triggerServerEvent( data.args.trigger, localPlayer, data.args.id )
                ShowPhoneUI( false )
            end )
        end,

        height = 110,
    },

    incasator_pps_call =
    {
        draw_func = function( self, parent, conf, k, data )
            local lbl_title = ibCreateLabel( 15, self.py, 0, 0, data.title, parent ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 20 + lbl_title:width( ), self.py, 0, 0, data.time, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_9 )
            local lbl_msg = ibCreateLabel( 15, self.py+15, conf.sx-40, 0, data.msg, parent, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            local but_accept = ibCreateButton( 15, self.py + 65 + ( lbl_msg:width( ) > conf.sx-40 and lbl_msg:height() or 0 ), 86, 28, parent,  pNotifTexturesTemp.accept_texture, pNotifTexturesTemp.accept_texture, pNotifTexturesTemp.accept_texture, 0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function(key, state)
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                RemoveNotification( k )
                triggerServerEvent( data.args.trigger, localPlayer, data.args.id )
                ShowPhoneUI( false )
            end )

            ibCreateButton( 110, but_accept:ibData( 'py' ), 86, 28, parent, pNotifTexturesTemp.cancel_texture, pNotifTexturesTemp.cancel_texture, pNotifTexturesTemp.cancel_texture, 0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function(key, state)
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                RemoveNotification( k )
            end )
        end,

        height = 110,
    },

    battle_pass = {
        draw_func = function( self, parent, conf, k, data )
            local lbl_title = ibCreateLabel( 15, self.py, 0, 0, data.title, parent ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 20 + lbl_title:width( ), self.py, 0, 0, data.time, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_9 )
            
            local text, lines_count = GetWrappedText( data.msg, conf.sx - 40, ibFonts.regular_9 )
            ibCreateLabel( 15, self.py + 15, conf.sx - 30, 0, text, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_9 )

            ibCreateButton( 0, self.py + 15 + lines_count * 15 + 10, 86, 28, parent, "img/elements/notifications/btn_open.png", _, _, 0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :center_x( )
                :ibOnClick( function(key, state)
                    if key ~= "left" or state ~= "up" then return end

                    ibClick( )
                    RemoveNotification( k )
                    triggerServerEvent( "BP:onPlayerWantShowUI", localPlayer )
                end )

            return 15 + lines_count * 15 + 10 + 28 + 5
        end,
    },

    diseases_notification =
    {
        draw_func = function( self, parent, conf, k, data )
            ibCreateLabel( 15, self.py + 7, conf.sx - 40, 0, data.msg, parent, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            ibCreateButton( 14, self.py + 61, 72, 23, parent, "img/elements/notifications/btn_search", true )
            :ibOnClick( function(key, state)
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                triggerEvent( "ToggleGPS", localPlayer, data.position, true )
                RemoveNotification( k )
            end )

            ibCreateButton( conf.sx - 25, self.py + 25, 13, 14, parent,
                self.textures.close_texture, self.textures.close_texture, self.textures.close_texture,
                0x55FFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                RemoveNotification( k )
            end )
        end,
        height = 88,
    },

    coop_quest_invite = {
        draw_func = function( self, parent, conf, k, data )
            local player_name = data.player:GetNickName( )
            local lbl_title = ibCreateLabel( 15, self.py, 0, 0, "Кооперативный квест", parent ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 20 + lbl_title:width( ), self.py, 0, 0, data.time, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_9 )
            ibCreateLabel( 15, self.py+15, conf.sx-40, 0, "Приглашение от игрока - \"" .. player_name .. "\"", parent, 0xFFFFFFFF )
                :ibBatchData( { font = ibFonts.regular_9, wordbreak = true } )

            ibCreateButton( 15, self.py + 55, 86, 28, parent, pNotifTexturesTemp.accept_texture, _, _, 0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function(key, state)
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    triggerServerEvent( "OnPlayerCoopQuestInviteAccepted", localPlayer, data.player )
                    RemoveNotification( k )
                end )

            ibCreateButton( 110, self.py + 55, 86, 28, parent, pNotifTexturesTemp.cancel_texture, _, _,  0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    triggerServerEvent( "OnPlayerCoopQuestInviteDeclined", localPlayer, data.player )
                    RemoveNotification( k )
                end )
        end,

        height = 88,
    },
}

APPLICATIONS.notifications = {
    id = "notifications",
    icon = "img/apps/notifications.png",
    name = "Уведомления",
    elements = { },
    create = function( self, parent, conf )
        self.parent = parent
        self.conf = conf
        self.textures = {}
        self.textures.header_texture = dxCreateTexture( "img/elements/app_header.png" )
        self.textures.close_texture = dxCreateTexture( "img/elements/notifications/close.png" )
        local hsx, hsy = dxGetMaterialSize( self.textures.header_texture )

        local size_y = hsy * conf.sx / hsx
        self.elements.header = ibCreateImage( 0, 0, hsx, size_y, self.textures.header_texture, parent )

        self.elements.lbl_header = ibCreateLabel( 15, 25, 0, 0, "Уведомления", parent ):ibBatchData( { font = ibFonts.bold_12, color = 0xFFFFFFFF } )
        local usable_y_space = conf.sy - size_y

        if #pNotificationsCache > 0 then
            self.elements.counter_bg = ibCreateImage( 175, 27, 19, 19, "img/elements/notifications/circle.png", parent )
            self.elements.counter = ibCreateLabel( 0, 0, self.elements.counter_bg:width( ), self.elements.counter_bg:height( ), #pNotificationsCache, self.elements.counter_bg, nil, nil, nil, "center", "center", ibFonts.regular_10 )
        end

        self.elements.rt, self.elements.sc = ibCreateScrollpane( 0, size_y, conf.sx, usable_y_space, UI_elements.background, { scroll_px = -12 } )
        self.elements.sc:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.05 )

        local parent = self.elements.rt

        self.py = 5
        for k, v in pairs( pNotificationsCache ) do
            local height = 15
            if v.special then
                height = SPECAIL_NOTIFICATIONS[ v.special ].draw_func( self, parent, conf, k, v )
                height = type( height ) == "number" and height or SPECAIL_NOTIFICATIONS[ v.special ].height
            else
                local lbl_title = ibCreateLabel( 15, self.py, 0, 15, v.title, parent ):ibData( "font", ibFonts.regular_9 )
                ibCreateLabel( 20 + lbl_title:width( ), self.py, 0, 15, v.time, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_9 )

                local text, lines_count = GetWrappedText( v.msg, conf.sx-40, ibFonts.regular_9 )
                local lbl_text = ibCreateLabel( 15, self.py+15, conf.sx-40, lines_count * 15, text, parent, 0xFFCCCCCC ):ibBatchData( { font = ibFonts.regular_9 } )

                height = height + lines_count * 15

                ibCreateButton( conf.sx-25, self.py+height/2-7, 13, 14, parent,
                                self.textures.close_texture, self.textures.close_texture, self.textures.close_texture,
                                0x55FFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    RemoveNotification( k )
                end )
            end

            ibCreateImage( 14, self.py+height+5, conf.sx-28, 1, _, parent, 0xAA252f3b )
            self.py = self.py + height + 10
        end

        self.elements.rt:AdaptHeightToContents( )
        self.elements.sc:UpdateScrollbarVisibility( self.elements.rt )
        
        if not pNotificationsCache or #pNotificationsCache == 0 then
            ibCreateLabel( 0, 90, conf.sx, 0, "Уведомлений нет", parent, 0xFFFFFFFF - 0x55000000, _, _, "center", "center", ibFonts.regular_10 )
        end

        triggerEvent("OnClientReadPhoneNotifications", localPlayer)

        NOTIFICATIONSAPP = self
        return self
    end,

    destroy = function( self, parent, conf )
        DestroyTableElements( self.elements )
        NOTIFICATIONSAPP = nil
    end,
}

function RemoveNotification( id )
    table.remove( pNotificationsCache, id )
    if NOTIFICATIONSAPP then
        DestroyTableElements( NOTIFICATIONSAPP.elements )
        NOTIFICATIONSAPP:create( NOTIFICATIONSAPP.parent, NOTIFICATIONSAPP.conf )
    end
end

function ClearAllPhoneNotifications_handler( )
    pNotificationsCache = { }

    if NOTIFICATIONSAPP then
        DestroyTableElements( NOTIFICATIONSAPP.elements )
        NOTIFICATIONSAPP:create( NOTIFICATIONSAPP.parent, NOTIFICATIONSAPP.conf )
    end

    triggerEvent( "UpdatePhoneNotificationsIcon", localPlayer, false, #pNotificationsCache )
end
addEvent( "ClearAllPhoneNotifications", true )
addEventHandler( "ClearAllPhoneNotifications", root, ClearAllPhoneNotifications_handler )

local SPECIAL_NOTIFICATIONS = 
{
    [ "race_lobby_created" ] = { accept_setting = "race_notifications", },
    [ "race_drag_created" ]  = { accept_setting = "race_notifications", },

    [ "coop_job_invite" ]    = { accept_setting = "jobs_notifications", }, 
    [ "coop_job_leave" ]     = { accept_setting = "jobs_notifications", },

    [ "coop_quest_invite" ]  = { accept_setting = "coop_quest_notifications", },
}

function OnClientReceivePhoneNotification( data )
    if (localPlayer:getData( "tutorial" ) or localPlayer:GetLevel() < 2) and (data and not data.is_quest_msg) then return end
    
    -- Переключение уведомлений гонок
    if data and SPECIAL_NOTIFICATIONS[ data.special ] and not SETTINGS[ SPECIAL_NOTIFICATIONS[ data.special ].accept_setting ] then return end
    
    data.time = ( "%02d:%02d" ):format(getRealTime().hour, getRealTime().minute)
    data.receive_timestamp = os.time( )
    table.insert(pNotificationsCache, 1, data)

    triggerEvent("UpdatePhoneNotificationsIcon", localPlayer, data, #pNotificationsCache)

    if not data.no_sound then
        setSoundVolume( playSound( "sound/notification/" .. PHONE_CURRENT_SOUNDS.notification .. ".wav" ), SETTINGS.notifications or 0.4 )
    end
end
addEvent("OnClientReceivePhoneNotification", true)
addEventHandler("OnClientReceivePhoneNotification", root, OnClientReceivePhoneNotification)

function OnRaceNotificationExpired( id )
    if localPlayer:getData( "tutorial" ) or localPlayer:GetLevel() < 2 then return end

    for k,v in pairs( pNotificationsCache ) do
        if SPECIAL_NOTIFICATIONS[ v.special ] and v.args.id == id then
            if NOTIFICATIONSAPP then
                RemoveNotification( k )
            else
                table.remove(pNotificationsCache, k)
            end
            triggerEvent( "UpdatePhoneNotificationsIcon", localPlayer, false, #pNotificationsCache )
            break
        end
    end
end
addEvent("RC:NotificationExpired", true)
addEventHandler("RC:NotificationExpired", root, OnRaceNotificationExpired)

function OnEventsNotificationExpired_handler( id )
    if localPlayer:getData( "tutorial" ) or localPlayer:GetLevel() < 2 then return end

    while true do
        local found = false

        for k,v in pairs( pNotificationsCache ) do
            if v.special == "events_lobby_created" then
				found = true

				if NOTIFICATIONSAPP then
					RemoveNotification( k )
				else
					table.remove(pNotificationsCache, k)
				end

                break
            end
        end

        if not found then
            break
        end
    end

    triggerEvent( "UpdatePhoneNotificationsIcon", localPlayer, false, #pNotificationsCache )
end
addEvent( "OnEventsNotificationExpired", true )
addEventHandler( "OnEventsNotificationExpired", root, OnEventsNotificationExpired_handler )

function NotifButPrepare()
    NotifButDestroy()
    pNotifTexturesTemp = {
        accept_texture = dxCreateTexture( "img/elements/notifications/btn_accept.png" ),
        cancel_texture = dxCreateTexture( "img/elements/notifications/btn_cancel.png" )
    }
end

function NotifButDestroy()
    DestroyTableElements( pNotifTexturesTemp )
    pNotifTexturesTemp = {}
end

function GetWrappedText( text, max_sx, font )
	text = string.gsub( text, "\n", " ` " )

	local strs = { }
	local line_sx = 0
	local lines_count = 1
	for word in string.gmatch( text, "%S+" ) do
		word = word == "`" and "" or ( word .. " " )
        local word_sx = word == "" and 0 or dxGetTextWidth( word, 1, font )
        line_sx = line_sx + word_sx
		if word == "" or line_sx > max_sx then
            lines_count = lines_count + 1
			strs[ #strs + 1 ] = "\n"
			strs[ #strs + 1 ] = word
			line_sx = word_sx
		else
            strs[ #strs + 1 ] = word
		end
	end
	
	return table.concat( strs ), lines_count
end

function onTryStopJobByEvent( event_name, callback )
    if isElement( UI_elements.confirm_stop_job ) then
        destroyElement( UI_elements.confirm_stop_job )
    end

    UI_elements.confirm_stop_job = ibConfirm( {
        title = "ОКОНЧАНИЕ СМЕНЫ", 
        text = "Ваша смена будет завершена. Хотите принять участие в\n\"" .. event_name .. "\"?",
        fn = function( self )
            if localPlayer:IsOnFactionDuty() then
                triggerServerEvent( "PlayerWantEndDuty", root )
            else
                triggerServerEvent( localPlayer:HasCoopJobClass() and "onServerLeaveCoopJobLobby" or "onJobEndShiftRequest", localPlayer, "Задание отменено" )
            end

            callback()
            self:destroy()
            ShowPhoneUI( false )

            if localPlayer:GetJobClass() == JOB_CLASS_TAXI_PRIVATE then
                localPlayer:MissionFailed( "Задание отменено" )
            end
        end,
        escape_close = true,
    } )
end