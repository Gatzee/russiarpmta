loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShPhone" )
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "CSound" )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShVehicleConfig" )
Extend( "ib" )

addEventHandler( "onClientResourceStart", resourceRoot, function() if localPlayer:IsInGame() then bindKey( "p", "down", OnPlayerPhoneKey ) end end )
addEventHandler( "onClientElementDataChange", localPlayer, function( key )
    if key == "_ig" then 
    if localPlayer:getData( key ) then
        bindKey( "p", "down", OnPlayerPhoneKey )
    end
end
end )

function OnPlayerPhoneKey( hide )
    if isPedDead( localPlayer ) then return end

    ShowPhoneUI( hide and false or (not GetPhoneState()), { phone = 1, case = 1, background = 1 } )
end
addEvent( "onPlayerPressPhoneKey", true )
addEventHandler( "onPlayerPressPhoneKey", root, OnPlayerPhoneKey )

local contactsInGame = { }

addEvent( "onPlayerJoinFromContacts", true )
addEventHandler( "onPlayerJoinFromContacts", resourceRoot, function ( player )
    local id = player:GetUserID( )
    if contactsInGame[id] then return end

    contactsInGame[id] = true
end )

function GetPhoneState( )
    return PHONE_STATE
end

-- Интерфейс

UI_elements = { }
local x, y = guiGetScreenSize()

PHONES = {
    -- Айфон
    {
        image = "img/main.png",
        sx = 227, sy = 472,
        px = x - 100 - 227, py = y - 472 + 5,

        --px = x - 50 - 227 - 250, py = y - 472 + 5,

        usable_area = {
            px = 11, py = 55,
            sx = 204, sy = 362,

            columns = 3,
            app_icon_size = 52,
        },

        home_button = {
            px = 90, py = 420,
            sx = 45, sy = 45,
        },

        statusbar = {
            image = "img/elements/statusbar.png",
            px = 5, py = 5,
            clock_y = -4,
            color = 0xaaffffff,
        },

        backgrounds = {
            {
                image = "img/backgrounds/bg_1.png",
            }
        },

        cases = {
            {
                image = "img/cases/case_1.png",
                sx = 235, sy = 479,
                offset_x = -4, offset_y = -4
            },
        },

    },

}

local ONLY_NOTIFICATIONS
function onPhoneDirectlyOpenNotifications_handler( state )
    ONLY_NOTIFICATIONS = state
end
addEvent( "onPhoneDirectlyOpenNotifications", true )
addEventHandler( "onPhoneDirectlyOpenNotifications", root, onPhoneDirectlyOpenNotifications_handler )

function CanShowPhoneUI( )
    local pVehicle = localPlayer.vehicle
    if localPlayer:getData( "in_casino" ) or localPlayer:getData( "isWithinTuning" ) or pVehicle and pVehicle:GetSpecialType( )
       or localPlayer:getData( "parachuting" ) or localPlayer:getData( "skydiving" ) or localPlayer:getData( "in_race_lobby" ) 
       or localPlayer:getData( "in_race" ) or localPlayer:getData( "block_phone" ) then
        return false
    end
    return true
end

function ShowPhoneUI( state, data )
    if state then
        if not CanShowPhoneUI( ) then return end

        NotifButPrepare()

        local data = data or { }
        local phone_conf = data.phone and PHONES[ data.phone ] or PHONES[ 1 ]
        local case_conf = data.case and phone_conf.cases[ data.case ] or phone_conf.cases[ 1 ]
        local background_image = GetPhoneWallpaper()

        CURRENT_PHONE_CONF = phone_conf
        CURRENT_CASE_CONF = case_conf

        local phone_px, phone_py = phone_conf.px, phone_conf.py
        local phone_sx, phone_sy = phone_conf.sx, phone_conf.sy

        local phone_hidden_px, phone_hidden_py = phone_px, y

        -- Кейс
        local case_hidden_px = phone_hidden_px + case_conf.offset_x
        local case_hidden_py = phone_hidden_py + case_conf.offset_y
        local case_px = phone_px + case_conf.offset_x
        local case_py = phone_py + case_conf.offset_y
        local case_sx, case_sy = case_conf.sx, case_conf.sy

        UI_elements.black_bg = ibCreateBackground( 0x00000000, ShowPhoneUI, _, true )
	    UI_elements.case = ibCreateImage( case_hidden_px, case_hidden_py, case_sx, case_sy, case_conf.image, UI_elements.black_bg )
        :ibMoveTo( case_px, case_py, 250, "OutBack" )

        -- Сам телефон
        UI_elements.main = ibCreateImage( -case_conf.offset_x, -case_conf.offset_y, phone_sx, phone_sy, phone_conf.image, UI_elements.case  )

        local usable_area = phone_conf.usable_area
        UI_elements.background_image = ibCreateImage( usable_area.px, usable_area.py, usable_area.sx, usable_area.sy, "img/backgrounds/" .. background_image .. ".png", UI_elements.main )
        UI_elements.background = ibCreateImage( 0, 0, usable_area.sx, usable_area.sy, _, UI_elements.background_image, 0 )

        local statusbar = phone_conf.statusbar
        UI_elements.statusbar_texture = dxCreateTexture( statusbar.image )
        local sx, sy = dxGetMaterialSize( UI_elements.statusbar_texture )
        local usable_area = CURRENT_PHONE_CONF.usable_area
        local required_width = usable_area.sx

        local scale =  sx / required_width
        UI_elements.statusbar = ibCreateImage( usable_area.px + statusbar.px, usable_area.py + statusbar.py, sx * scale, sy * scale, UI_elements.statusbar_texture, UI_elements.main, 0xFFFFFFFF )
        
        local current_phone_number = localPlayer:GetPhoneNumber()
        if current_phone_number then
            UI_elements.t_voice = ibCreateImage( usable_area.px + statusbar.px, usable_area.py + statusbar.py, 54, 8, "img/elements/t_voice.png", UI_elements.main, 0xFFFFFFFF )
        end

        local h, m = getTime()
        local h, m = h < 10 and "0" .. h or h, m < 10 and "0" .. m or m
        local time = h .. ":" .. m
        UI_elements.statusbar_time = ibCreateLabel( usable_area.px, usable_area.py + statusbar.py + statusbar.clock_y, usable_area.sx, 0, time, UI_elements.main, 0xFFFFFFFF, _, _, "center", "top", ibFonts.light_8 )

        if ONLY_NOTIFICATIONS then
            CreateApplication( "notifications", UI_elements.background, usable_area )
        else
            UI_elements.home = ibCreateButton( phone_conf.home_button.px, phone_conf.home_button.py, phone_conf.home_button.sx, phone_conf.home_button.sy, UI_elements.main ):ibData( "alpha", 0 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" or TOWTRUCKER_HINT_SEARCH then return end
                ibClick( )
                CreateApplication( "drawer", UI_elements.background, usable_area )
            end, false )

            CreateDynamicApplications()
            CreateApplication( "drawer", UI_elements.background, usable_area )
        end
        
        showCursor( true )
        PHONE_STATE = true
    else
        if isElement( UI_elements.case ) then
            local px = UI_elements.case:ibData( "px" )
            local phone_hidden_px, phone_hidden_py = px, y

            local case_hidden_px = phone_hidden_px + CURRENT_CASE_CONF.offset_x
            local case_hidden_py = phone_hidden_py + CURRENT_CASE_CONF.offset_y
            UI_elements.case:ibMoveTo( case_hidden_px, case_hidden_py, 100, "InOutQuad" )
        end
        showCursor( false )
        Timer( NukeEverything, 100, 1 )
    end
end
addEvent( "ShowPhoneUI", true )
addEventHandler( "ShowPhoneUI", root, ShowPhoneUI )

function NukeEverything()
    NotifButDestroy()
    CreateApplication( )
    DestroyTableElements( UI_elements )
    PHONE_STATE = nil
end

-- Создание приложения

ENABLED_APPLICATIONS = {
    "contacts",
    "sms",
    "towtruck",
    "notifications",
    "statistic",
    "settings",
    --"party",
    --"clan_id",
    "businesses_sell",
    "transfer",
    "government",
    "phone_individ_shop",
    "report",
    "taxi",
    "races",
    "radio",
    "forbes",
    "svehicles",
    "requests",
    --"bets",
    "halloween",
    "may_events",
}

APPLICATIONS = {
    drawer = {
        id = "drawer",
        icon = "img/1.png",
        elements = { },
        create = function( self, parent, conf )
            local columns = conf.columns
            local app_icon_size = conf.app_icon_size

            local column_size = conf.sx / 3
            local column_positions = { }

            -- Позиции центров иконок
            for i = 1, columns do
                column_positions[ i ] = ( i - 1 ) * column_size + column_size / 2
			end

			self.elements.scroll_pane, self.elements.scroll_bar = ibCreateScrollpane( 0, 20, parent:ibData( "sx" ), parent:ibData( "sy" ) - 20, parent, { scroll_px = -13, bg_color = 0x00FFFFFF } )
			self.elements.scroll_bar:ibData( "sensivity", 0.1 ):ibBatchData( { absolute = true, sensivity = 75 } ):ibSetStyle( "slim_nobg" )

            local current_column = 1
            local current_row = 1
            local is_towtrucker_hint = HINT_ANIMATION[ "towtruck" ] or TOWTRUCKER_HINT_SEARCH or TOWTRUCKER_HINT_EVACUATE
            for i = 1, #ENABLED_APPLICATIONS do
                if current_column > columns then
                    current_row = current_row + 1
                    current_column = 1
                end
                local app_id = ENABLED_APPLICATIONS[ i ]
                local app = APPLICATIONS[ app_id ]
                local px = column_positions[ current_column ] - app_icon_size / 2
                local py = 5 + ( 10 + app_icon_size ) * ( current_row - 1 )

                local btn

                if app.bg then
                    btn = ibCreateButton( px, py, app_icon_size, app_icon_size, self.elements.scroll_pane,
                                                app.bg, app.bg, app.bg, 
                                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                    ibCreateImage( 0, 0, app_icon_size, app_icon_size, app.icon, btn ):ibData( "disabled", true )
                else
                    btn = ibCreateButton( px, py, app_icon_size, app_icon_size, self.elements.scroll_pane,
                                                app.icon, app.icon, app.icon, 
                                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                end

                local name = app.name
                if name then btn:ibAttachTooltip( name ) end

                self.elements[ "app_" .. i ] = btn
                if is_towtrucker_hint and app_id ~= "towtruck" then
                    btn:ibBatchData( { color = 0xFFA3A3A3, color_hover = 0xFFA3A3A3, color_click = 0xFFA3A3A3 } )
                end

                if app.get_notifications_count then
                    local count = app:get_notifications_count()
                    if count and count > 0 then
                        local bg = ibCreateImage( app_icon_size - 15, -5, 19, 19, "img/elements/notifications/circle.png", btn ):ibData( "disabled", true )
                        ibCreateLabel( 0, 0, bg:width( ), bg:height( ), count, bg, _, _, _, "center", "center", ibFonts.regular_10 ):ibData( "disabled", true )
                    end
                elseif app_id == "notifications" then
                    if #pNotificationsCache > 0 then
                        local bg = ibCreateImage( app_icon_size - 15, -5, 19, 19, "img/elements/notifications/circle.png", btn )
                        :ibData( "disabled", true )
                        ibCreateLabel( 0, 0, bg:width( ), bg:height( ), #pNotificationsCache, bg, _, _, _, "center", "center", ibFonts.regular_10 )
                        :ibData( "disabled", true )
                    end
                elseif app_id == "statistic" then
                    local counter = localPlayer:getData( "new_achievement" ) or 0
                    if counter > 0 then
                        local bg = ibCreateImage( app_icon_size - 15, -5, 19, 19, "img/elements/notifications/circle.png", btn )
                        :ibData( "disabled", true )
                        ibCreateLabel( 0, 0, bg:width( ), bg:height( ), counter, bg, nil, nil, nil, "center", "center", ibFonts.regular_10 )
                        :ibData( "disabled", true )
                    end
                elseif app_id == "sms" then
                    if SMS_COUNT > 0 then
                        local bg = ibCreateImage( app_icon_size - 15, -5, 19, 19, "img/elements/notifications/circle.png", btn ):ibData( "disabled", true )
                        ibCreateLabel( 0, 0, bg:width( ), bg:height( ), SMS_COUNT or 0, bg, _, _, _, "center", "center", ibFonts.regular_10 ):ibData( "disabled", true )
                    end
                elseif app_id == "contacts" then
                    if CURRENT_STATUS and CURRENT_STATUS.code == 2 then
                        ibCreateImage( app_icon_size - 15, -5, 20, 20, ":nrp_handler_voice/img/voice_small_phone.png", btn ):ibData( "disabled", true )
                    else
                        local count = 0

                        for id in pairs( contactsInGame ) do
                            local isOnline = GetPlayer( id )

                            if isOnline then count = count + 1
                            elseif not isOnline then contactsInGame[id] = nil end
                        end

                        if count > 0 then
                            local bg = ibCreateImage( app_icon_size - 15, -5, 19, 19, "img/elements/notifications/circle.png", btn ):ibData( "disabled", true )
                            ibCreateLabel( 0, 0, bg:width( ), bg:height( ), count, bg, _, _, _, "center", "center", ibFonts.regular_10 ):ibData( "disabled", true )
                        end
                    end
                elseif app_id == "report" then
                    if ADMIN_INFO_TO_RATE and ADMIN_INFO_TO_RATE.until_date > getRealTimestamp( ) then
                        local bg = ibCreateImage( app_icon_size - 15, -5, 19, 19, "img/elements/notifications/circle.png", btn ):ibData( "disabled", true )
                        ibCreateLabel( 0, 0, bg:width( ), bg:height( ), 1, bg, _, _, _, "center", "center", ibFonts.regular_10 ):ibData( "disabled", true )
                    end
                end

                local turn = true
                local func_interpolate = function( self )
                    if HINT_ANIMATION[ self:ibData( "app_id" ) ] then
                        self:ibInterpolate( function( self )
                            if not isElement( self.element ) then return end
                            --self.easing_value = 1 + 0.1 * self.easing_value
                            self.element:ibBatchData( {
                                rotation = ( self.easing_value ) * 10 * ( turn and 1 or -1 ),
                            } )
                        end, 350, "SineCurve" )
                        turn = not turn
                    end
                end

                self.elements[ "app_" .. i ]:ibData( "alpha", 0 )
                :ibData( "app_id", app_id )
                :ibTimer( 
                    function( self )
                        self:ibAlphaTo( 255, 50 )
                    end, i * 50, 1
                )
                :ibOnClick( 
                    function( button, state )
                        if button ~= "left" or state ~= "up" or (is_towtrucker_hint and app_id ~= "towtruck") then return end
                        ibClick( )
                        EnablePhoneHintAnimation( app_id, nil )
                        CreateApplication( app_id, parent, conf )

                        if app_id == "contacts" then
                            contactsInGame = { }
                        end
                    end )
                :ibTimer( func_interpolate, 750, 0 )

                current_column = current_column + 1
			end

			self.elements.scroll_pane:AdaptHeightToContents( )
			self.elements.scroll_pane:ibData( "sy", self.elements.scroll_pane:ibData( "sy" ) + 10 )
			self.elements.scroll_bar:UpdateScrollbarVisibility( self.elements.scroll_pane )

            return self
        end,

        destroy = function( self )
            DestroyTableElements( self.elements )
        end
    },

    clan_id = {
        id = "clan_id",
        icon = "img/apps/clan.png",
        bg = "img/elements/bg_white.png",
        name = "Клан",
        create = function()
            triggerServerEvent( "onPlayerWantShowClanMainUI", localPlayer )
            ShowPhoneUI( false )
        end,
    },
    businesses_sell = {
        id = "businesses_sell",
        icon = "img/apps/businesses_sell.png",
        name = "Биржа бизнесов",
		create = function()
			triggerEvent( "ShowBusinessSellChooserUI", root, true )
            ShowPhoneUI( false )
        end,
    },
}

HINT_ANIMATION = { }
function EnablePhoneHintAnimation( app_id, state )
    HINT_ANIMATION[ app_id ] = state
end
addEvent( "EnablePhoneHintAnimation", true )
addEventHandler( "EnablePhoneHintAnimation", root, EnablePhoneHintAnimation )

CURRENT_APPLICATION = nil
PREVIOUS_APPLICATION_NAME = nil

function CreateApplication( name, parent, conf )
    if CURRENT_APPLICATION then
        PREVIOUS_APPLICATION_NAME = CURRENT_APPLICATION.id
        CURRENT_APPLICATION:destroy()
        CURRENT_APPLICATION = nil
    end

    if name and APPLICATIONS[ name ] and APPLICATIONS[ name ].create then
        UI_elements.background:ibData( "alpha", 0 )
        CURRENT_APPLICATION = table.copy( APPLICATIONS[ name ] ):create( parent, conf )
        UI_elements.background:ibAlphaTo( 255, 50 )
    end
end

function CreateDynamicApplications( )
    -- Зачистка
    local dynamic_applications = {
        clan_id = true;
        clan_war = true;

        invite_user = true;
        
        new_year = true;
        halloween = true;
        may_events = true;
    }

    for i = #ENABLED_APPLICATIONS, 1, -1 do
        local application = ENABLED_APPLICATIONS[ i ]
        if dynamic_applications[ application ] then
            table.remove( ENABLED_APPLICATIONS, i )
        end
    end

    -- Добавление
    if localPlayer:GetClanID( ) then
        table.insert( ENABLED_APPLICATIONS, 6, "clan_id" )
        table.insert( ENABLED_APPLICATIONS, 7, "clan_war" )
    end

    if INVITE_CODES then
        if getRealTimestamp() - APPLICATIONS.invite_user.first_open_ts < 24 * 60 * 60 then
            table.insert( ENABLED_APPLICATIONS, 1, "invite_user" )
        else
            table.insert( ENABLED_APPLICATIONS, "invite_user" )
        end
    end

	local timestamp = getRealTimestamp( )
    for k, v in pairs( { "new_year", "halloween", "may_events" } ) do
        if timestamp >= EVENTS_TIMES[ v ].from and timestamp < EVENTS_TIMES[ v ].to then
            table.insert( ENABLED_APPLICATIONS, 1, v )
        end
    end
end

addEventHandler( "onClientMinimize", root, function() ShowPhoneUI( false ) end )
addEventHandler( "onClientRestore", root, function() ShowPhoneUI( false ) end )