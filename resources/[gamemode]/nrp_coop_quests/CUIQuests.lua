local sx, sy = 1024, 769

local ui = { }
local selected_tab = 1
local last_remote_action = 0

local TAB_LOBBY = 1
local TAB_SHOP = 2
local TAB_HELP = 3

local CONST_GET_DATA_URL
local CASES_DATA

local DEFAULT_LOBBY_DATA = 
{
    team = 1,
    is_searching = false,
    team_found = false,
    opponents_found = false,

    teams = 
    {
        {
            {
                name = localPlayer:GetNickName( ),
                element = localPlayer,
                ready = false,
            },
        },
        { }
    }
}

local LOBBY_DATA

local TABS_LIST = { 
    { name = "Лобби", key = TAB_LOBBY }, 
    { name = "Магазин", key = TAB_SHOP },
    { name = "Задания", key = TAB_HELP },
}

local TABS_CONF = 
{
    [ TAB_LOBBY ] = 
    {
        ui_elements = { },

        fn_create = function( self, area )
            self.area = area

            ui.l_quests_left_value = ibCreateLabel( sx-38, 125, 0, 0, localPlayer:GetCoopQuestAttempts( ), area, _, _, _, "left", "center", ibFonts.oxaniumbold_16 ):ibData( "alpha", 255*0.8 )
            ibCreateLabel( sx-45, 126, 0, 0, "Сегодня осталось заданий:", area, _, _, _, "right", "center", ibFonts.regular_14 ):ibData( "alpha", 255*0.5 )
        
            ibCreateImage( 0, 172, 953, 72, "img/description.png", area ):center_x( )
            ibCreateImage( 0, 228, 1024, 137, "img/info.png", area )
            ibCreateImage( 0, 352, 1024, 418, "img/teams.png", area )

            ui.l_search = ibCreateLabel( 30, sy-56, 0, 0, "Поиск игроков:", area, _, _, _, "left", "center", ibFonts.bold_16 )
            ui.l_lobby_status = ibCreateLabel( 30, sy-33, 0, 0, "Лобби не собрано", area, 0xffffde96, _, _, "left", "center", ibFonts.regular_12 )
            


            ui.btn_invite = ibCreateButton( sx-306, sy-65, 167, 56, area, 
                                    "img/btn_invite_i.png", "img/btn_invite_h.png", "img/btn_invite_h.png",
                                    COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
                :ibOnClick( function( key, state ) 
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )

                    self:show_invite_overlay( true )
                end )

            ui.btn_search = ibCreateButton( sx-142, sy-65, 128, 56, area, 
                                    "img/btn_search_i.png", "img/btn_search_h.png", "img/btn_search_h.png",
                                    COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
                :ibOnClick( function( key, state ) 
                    if key ~= "left" or state ~= "up" then return end
                    if not IsRemoteActionAvailable( ) then return end
                    last_remote_action = getTickCount( )

                    ibClick( )
                    triggerServerEvent( "OnPlayerRequestToggleSearch", resourceRoot, _, _, GetLastQuestStartLocation( ) )
                end )

            ui.btn_cancel_search = ibCreateButton( sx-221, sy-65, 204, 52, area, 
                                    "img/btn_cancel_search_i.png", "img/btn_cancel_search_h.png", "img/btn_cancel_search_h.png",
                                    COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
                :ibOnClick( function( key, state ) 
                    if key ~= "left" or state ~= "up" then return end
                    if not IsRemoteActionAvailable( ) then return end
                    last_remote_action = getTickCount( )

                    ibClick( )
                    triggerServerEvent( "OnPlayerRequestToggleSearch", resourceRoot, _, _, GetLastQuestStartLocation( ) )
                end )

            ui.btn_ready = ibCreateButton( sx-120, sy-65, 105, 55, area, 
                                    "img/btn_ready_i.png", "img/btn_ready_h.png", "img/btn_ready_h.png",
                                    COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
                :ibOnClick( function( key, state ) 
                    if key ~= "left" or state ~= "up" then return end
                    if not IsRemoteActionAvailable( ) then return end
                    last_remote_action = getTickCount( )

                    ibClick( )
                    triggerServerEvent( "OnPlayerRequestToggleReady", resourceRoot )
                end )

            ui.btn_not_ready = ibCreateButton( sx-120, sy-65, 114, 53, area, 
                                    "img/btn_not_ready_i.png", "img/btn_not_ready_h.png", "img/btn_not_ready_h.png",
                                    COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
                :ibOnClick( function( key, state ) 
                    if key ~= "left" or state ~= "up" then return end
                    if not IsRemoteActionAvailable( ) then return end
                    last_remote_action = getTickCount( )

                    ibClick( )
                    triggerServerEvent( "OnPlayerRequestToggleReady", resourceRoot )
                end )

            ui.btn_leave_lobby = ibCreateButton( sx-334, sy-64, 204, 52, area, 
                                    "img/btn_leave_i.png", "img/btn_leave_h.png", "img/btn_leave_h.png",
                                    COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
                :ibOnClick( function( key, state ) 
                    if key ~= "left" or state ~= "up" then return end
                    if not IsRemoteActionAvailable( ) then return end
                    last_remote_action = getTickCount( )

                    ibClick( )
                    triggerServerEvent( "OnPlayerRequestLeaveLobby", resourceRoot )
                end )

            ui.btn_ready:ibData( "disabled", true )
            ui.btn_ready:ibData( "alpha", 0 )

            ui.btn_not_ready:ibData( "disabled", true )
            ui.btn_not_ready:ibData( "alpha", 0 )

            ui.btn_cancel_search:ibData( "disabled", true )
            ui.btn_cancel_search:ibData( "alpha", 0 )

            ui.btn_leave_lobby:ibData( "disabled", true )
            ui.btn_leave_lobby:ibData( "alpha", 0 )

            self.ui_elements = { }

            self:update_players( )
            self:update_lobby( )
        end,

        show_invite_overlay = function( self, state )
            if state then
                if not isElement( ui.invite_rt ) then
                    ui.invite_rt = ibCreateRenderTarget( 0, 90, sx, sy-90, self.area ):ibData( "priority", 2 )
                    ui.shadow = ibCreateImage( 0, sy, sx, sy-90, _, ui.invite_rt, 0xff1f2934 ):ibData( "alpha", 0 )

                    local header = ibCreateImage( 0, 83, 1000, 113, "img/invite_header.png", ui.shadow ):center_x( )

                    ui.btn_back = ibCreateButton( 30, 12, 103, 17, header, 
                                    "img/btn_back_i.png", "img/btn_back_h.png", "img/btn_back_h.png",
                                    COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
                    :ibOnClick( function( key, state ) 
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        self:show_invite_overlay( false )
                    end )

                    ibCreateLabel( 0, 152, sx, 0, "Ты можешь выбрать из списка или найти и пригласить игрока к себе в напарники", ui.shadow, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_16 )
                
                    local edit_bg = ibCreateImage( 30, 180, 836, 45, "img/bg_edit.png", ui.shadow )
                    local edit = ibCreateWebEdit( 30, 0, 800, 42, "", edit_bg, 0x80ffffff, 0 )
                    :ibBatchData( { max_length = 48, placeholder = "Введите имя игрока", font = "regular_14_200", placeholder_color = "0xaaffffff" } )
                
                    edit:ibOnFocusChange(function( state )
                        if state then
                            edit_bg:ibData( "texture", "img/bg_edit_h.png" )
                        else
                            edit_bg:ibData( "texture", "img/bg_edit.png" )
                        end
                    end)

                    ui.btn_search_players = ibCreateButton( sx-140, 175, 125, 61, ui.shadow, 
                                    "img/btn_search2_i.png", "img/btn_search2_h.png", "img/btn_search2_h.png",
                                    COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
                    :ibOnClick( function( key, state ) 
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        
                        local name = edit:ibData( "text" )
                        if name and utf8.len( name ) > 4 then
                            self:update_overlay_list( name )
                        else
                            self:update_overlay_list( )
                        end
                    end )

                    ibCreateImage( 0, 248, 1024, 27, "img/invite_line.png", ui.shadow )
                    
                    ui.p_scrollpane, ui.p_scrollbar = ibCreateScrollpane( 0, 275, sx, 400, ui.shadow, { scroll_px = - 20, bg_color = 0x00FFFFFF  } )
                    ui.p_scrollbar:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.05 )
                end

                ui.shadow:ibAlphaTo( 255*0.95, 500, "InOutQuad" )
                ui.shadow:ibMoveTo( 0, 0, 500, "InOutQuad" )
                ui.invite_rt:ibData( "disabled", false )

                self:update_overlay_list( )
            else
                ui.invite_rt:ibData( "disabled", true )
                ui.shadow:ibAlphaTo( 0, 500, "InOutQuad" )
                ui.shadow:ibMoveTo( 0, sy, 500, "InOutQuad" )
            end
        end,

        update_overlay_list = function( self, name )
            local function GetPlayersByName( name )
                local output = { }

                local all_players = GetPlayersInGame( )

                for k,v in pairs( all_players ) do
                    local nickname = v:GetNickName( )

                    if utf8.find( nickname, name ) and v:GetLevel() >= REQUIRED_PLAYER_LEVEL then
                        table.insert( output, v )

                        if #output >= 10 then
                            break
                        end
                    end
                end

                return output
            end

            local players_list = name and GetPlayersByName( name ) or getElementsWithinRange( localPlayer.position, 50, "player" ) or { }

            for k,v in pairs( players_list ) do
                if v == localPlayer then
                    table.remove( players_list, k )
                    break
                end
            end

            DestroyTableElements( self.players_list_elements )
            self.players_list_elements = { }

            if #players_list <= 0 then
                return
            end

            local bEven = true
            local py = 0
            for i, player in pairs( players_list ) do
                local player_bg = ibCreateImage( 0, py, sx, 51, _, ui.p_scrollpane, bEven and 0x40314050 or 0x00ffffff )
                local icon_level = ibCreateImage( 60, -4, 58, 58, "img/icon_level.png", player_bg )
                local l_level = ibCreateLabel( 0, 0, 58, 58, player:GetLevel( ), icon_level, COLOR_WHITE, _, _, "center", "center", ibFonts.oxaniumbold_12 )
                local l_player_name = ibCreateLabel( 194, 0, 0, 51, player:GetNickName(), player_bg, COLOR_WHITE, _, _, "left", "center", ibFonts.regular_16 )

                local btn_invite = ibCreateButton( sx-152, 4, 137, 52, player_bg,
                "img/btn_invite2_i.png", "img/btn_invite2_h.png", "img/btn_invite2_h.png",
                                    COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
                    :ibOnClick( function( key, state ) 
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        source:ibData( "disabled", true )
                        source:ibData( "alpha", 255*0.5 )

                        triggerServerEvent( "OnPlayerTryInviteAnotherPlayer", resourceRoot, player )
                    end )

                table.insert( self.players_list_elements, player_bg )
                
                bEven = not bEven
                py = py + 52

                ibCreateImage( 0, 51, sx, 1, _, player_bg, COLOR_WHITE ):ibData( "alpha", 255*0.1 )
            end

            ui.p_scrollpane:AdaptHeightToContents( )
            ui.p_scrollbar:UpdateScrollbarVisibility( ui.p_scrollpane )
        end,

        update_lobby = function( self )
            if not isElement( self.area ) then return end

            if LOBBY_DATA.team_found then
                -- Союзник найден
                ui.btn_search:ibData( "disabled", true ):ibData( "alpha", 0 )
                ui.btn_invite:ibData( "disabled", true ):ibData( "alpha", 0 )
                ui.btn_leave_lobby:ibData( "disabled", false ):ibData( "alpha", 255 )

                LOBBY_DATA.teammate = GetLobbyTeammate( )
                LOBBY_DATA.me = GetLobbyLocalPlayer( )

                -- Ищем оппонентов
                if LOBBY_DATA.is_searching then
                    ui.l_lobby_status:ibData( "text", "Поиск соперников" )
                    ui.btn_ready:ibData( "disabled", true ):ibData( "alpha", 0 )
                    ui.btn_not_ready:ibData( "disabled", false ):ibData( "alpha", 255*0.5 )
                else
                    ui.l_lobby_status:ibData( "text", "Ожидание готовности" )

                    if LOBBY_DATA.me and LOBBY_DATA.me.ready then
                        ui.btn_ready:ibData( "disabled", true ):ibData( "alpha", 0 )
                        ui.btn_not_ready:ibData( "disabled", false ):ibData( "alpha", 255 )
                    else
                        ui.btn_not_ready:ibData( "disabled", true ):ibData( "alpha", 0 )
                        ui.btn_ready:ibData( "disabled", false ):ibData( "alpha", 255 )
                    end
                end


                -- Оппоненты найдены
                if LOBBY_DATA.opponents_found and not LOBBY_DATA.started_countdown then
                    LOBBY_DATA.started_countdown = true

                    ui.btn_close:ibData( "disabled", true ):ibData( "alpha", 0.5*255 )
                    ui.btn_leave_lobby:ibData( "disabled", true ):ibData( "alpha", 0.5*255 )
                    ui.btn_not_ready:ibData( "disabled", true ):ibData( "alpha", 0.5*255 )

                    ui.l_lobby_status:ibData( "alpha", 0 )
                    ui.l_search:ibData( "alpha", 0 )

                    ibCreateLabel( 30, sy-94, 0, 94, "Начало игры:", self.area, _, _, _, "left", "center", ibFonts.bold_16 )
                    ibCreateImage( 150, sy-55, 14, 16, "img/icon_timer.png", self.area )
                    ibCreateLabel( 168, sy-94, 0, 94, "через", self.area, 0xffffde96, _, _, "left", "center", ibFonts.regular_16 )

                    local countdown = 3
                    local l_countdown = ibCreateLabel( 218, sy-94, 0, 94, countdown, self.area, 0xffffde96, _, _, "left", "center", ibFonts.oxaniumbold_16 )
                
                    l_countdown:ibTimer( function()
                        countdown = countdown - 1
                        l_countdown:ibData( "text", countdown )
                    end, 1000, 3 )
                end
            else
                -- Союзник не найден
                ui.btn_ready:ibData( "disabled", true ):ibData( "alpha", 0 )
                ui.btn_not_ready:ibData( "disabled", true ):ibData( "alpha", 0 )
                ui.btn_cancel_search:ibData( "disabled", true ):ibData( "alpha", 0 )
                ui.btn_leave_lobby:ibData( "disabled", true ):ibData( "alpha", 0 )
                ui.btn_close:ibData( "disabled", false ):ibData( "alpha", 255 )

                if LOBBY_DATA.is_searching then
                    ui.btn_invite:ibData( "disabled", true ):ibData( "alpha", 0 )
                    ui.btn_search:ibData( "disabled", true ):ibData( "alpha", 0 )
                    ui.btn_cancel_search:ibData( "disabled", false ):ibData( "alpha", 255 )
                else
                    ui.btn_search:ibData( "disabled", false ):ibData( "alpha", 255 )
                    ui.btn_invite:ibData( "disabled", false ):ibData( "alpha", 255 )
                end

                ui.l_lobby_status:ibData( "text", LOBBY_DATA.is_searching and "Поиск игроков запущен" or "Идет подготовка команды" )
            end
        end,

        update_players = function( self )
            if not isElement( self.area ) then return end

            DestroyTableElements( self.ui_elements )
            self.ui_elements = { }

            local function CreatePlayer( p_data )
                local area = ibCreateArea( 0, 0, 510, 122, self.area )
                local name = ibCreateLabel( 30, 0, 0, 122, p_data.name, area, _, _, _, "left", "center", ibFonts.bold_16 )

                if p_data.element == localPlayer then
                    ibCreateImage( 30 + name:width( ) + 8, 55, 13, 13, "img/icon_player.png", area )
                end

                if p_data.ready then
                    ibCreateImage( 346, 44, 90, 43, "img/icon_ready.png", area )
                else
                    ibCreateImage( 336, 44, 113, 43, "img/icon_not_ready.png", area )
                end

                table.insert( self.ui_elements, area )

                return { area = area, name = name, ready = ready }
            end

            local function CreateSlot( team, slot )
                local area = ibCreateArea( 0, 0, 510, 122, self.area )

                if team == 1 then
                    ibCreateLabel( 30, 0, 0, 122, "Место свободно", area, _, _, _, "left", "center", ibFonts.regular_16 ):ibData( "alpha", 255*0.5 )
                else
                    ibCreateLabel( 30, 0, 0, 122, "Противник "..slot, area, _, _, _, "left", "center", ibFonts.regular_16 ):ibData( "alpha", 255 )
                    ibCreateLabel( 360, 0, 0, 122, "Ожидание", area, 0xffffde96, _, _, "left", "center", ibFonts.regular_16 )
                end

                table.insert( self.ui_elements, area )

                return { area = area }
            end

            local used_slots = 
            {
                { false, false },
                { false, false },
            }

            for i, team in pairs( LOBBY_DATA.teams ) do
                for k, v in pairs( team ) do
                    local ui_player = CreatePlayer( v )

                    ui_player.area:ibData( "px", i == LOBBY_DATA.team and 0 or 512 )
                    ui_player.area:ibData( "py", k == 1 and 430 or 552 )

                    used_slots[ i == LOBBY_DATA.team and 1 or 2 ][ k == 1 and 1 or 2 ] = true
                end
            end

            for team, slots in pairs( used_slots ) do
                for k, slot in pairs( slots ) do
                    if not slot then
                        local ui_slot = CreateSlot( team, k )

                        ui_slot.area:ibData( "px", team == LOBBY_DATA.team and 0 or 512 )
                        ui_slot.area:ibData( "py", k == 1 and 430 or 552 )
                    end
                end
            end
        end,
    },

    [ TAB_SHOP ] = 
    {
        fn_create = function( self, area )
            self.area = area

            ui.scrollpane, ui.scrollbar = ibCreateScrollpane( 0, 156, 1024, sy-166, area, { scroll_px = -20, bg_color = 0x00FFFFFF } )
            --ui.scrollbar:ibData( "sensivity", 0.1 )
            --ui.scrollbar:ibData( "alpha", 0.35*255 )
            ui.scrollbar:ibSetStyle( "slim_nobg" )

            local px, py = 30, 10

            for k, v in pairs( SHOP_ITEMS_LIST ) do
                local item_conf = REGISTERED_ITEMS[ v.type ]

                local item_bg = ibCreateButton( px, py, 472, 360, ui.scrollpane,
                                    "img/shop_item_i.png", "img/shop_item_h.png", "img/shop_item_h.png",
                                    COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )

                        self:show_item( true, k, v )
                    end )

                local item_name = ibCreateLabel( 0, 29, 472, 0, v.name, item_bg, _, _, _, "center", "center", ibFonts.regular_18 )
                :ibData( "disabled", true )

                if v.is_case then
                    local item_image, img = ibCreateRewardImage( 0, 0, 472, 360, v, item_bg, true )
                    item_image:ibData( "disabled", true )
                    img:ibData( "disabled", true )

                    local l_cost = ibCreateLabel( 0, 330, 0, 0, v.cost, item_bg, _, _, _, "left", "center", ibFonts.bold_26 )

                    local total_width = l_cost:width( ) + 10 + 24
                    local lx = 472 / 2 - total_width / 2

                    l_cost:ibData( "px", lx )

                    local icon_cost = ibCreateImage( lx + l_cost:width( ) + 10, 318, 24, 24, "img/icon_vallet.png", item_bg )
                    :ibData( "disabled", true )
                else
                    local item_image, img = ibCreateRewardImage( 0, 60, 472, 120, v, item_bg, true )
                    item_image:ibData( "disabled", true )
                    img:ibData( "disabled", true )

                    local l_cost = ibCreateLabel( 0, 330-60, 0, 0, v.cost, item_bg, _, _, _, "left", "center", ibFonts.bold_26 )

                    local total_width = l_cost:width( ) + 10 + 24
                    local lx = 472 / 2 - total_width / 2

                    l_cost:ibData( "px", lx )

                    local icon_cost = ibCreateImage( lx + l_cost:width( ) + 10, 318-60, 24, 24, "img/icon_vallet.png", item_bg )
                    :ibData( "disabled", true )

                    local btn_buy = ibCreateButton( 0, 290, 158, 66, item_bg,
                                    "img/btn_buy_i.png", "img/btn_buy_h.png", "img/btn_buy_h.png",
                                    COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
                        :center_x( )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )

                            self:buy_item( k, v )
                        end )

                    -- Count
                    local bg_items_count = ibCreateImage( 176+36, 218, 48, 30, "img/bg_items_amount.png", item_bg )
                    local l_items_count = ibCreateLabel( 0, 0, 48, 30, v.temp_count or 1, bg_items_count, _, _, _, "center", "center", ibFonts.oxaniumbold_18 )

                    local function UpdateBuyCount( value )
                        if not v.temp_count then v.temp_count = 1 end

                        local new_items_amount = v.temp_count + value
                        if new_items_amount <= 0 then 
                            new_items_amount = 99
                        elseif new_items_amount >= 99 then
                            new_items_amount = 1
                        end

                        v.temp_count = new_items_amount

                        l_items_count:ibData("text", v.temp_count)
                        l_cost:ibData( "text", v.cost * v.temp_count )

                        local total_width = l_cost:width( ) + 10 + 24
                        local lx = 472 / 2 - total_width / 2
                        l_cost:ibData( "px", lx )

                        icon_cost:ibData( "px", lx + l_cost:width( ) + 10 )
                    end

                    ui.btn_minus = ibCreateButton( 176, 218, 31, 31, item_bg, 
                        "img/btn_minus_i.png", "img/btn_minus_h.png", "img/btn_minus_h.png",
                        COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
                    :ibOnClick(function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick()
                        UpdateBuyCount( -1 )
                    end)

                    ui.btn_plus = ibCreateButton( 176+90, 218, 31, 31, item_bg, 
                        "img/btn_plus_i.png", "img/btn_plus_h.png", "img/btn_plus_h.png",
                        COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
                    :ibOnClick(function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick()
                        UpdateBuyCount( 1 )
                    end)
                end

                if k / 2 == math.floor( k / 2 ) then
                    px = 30
                    py = py + 380
                else
                    px = 522
                end
            end

            ui.scrollpane:AdaptHeightToContents( )
        end,

        show_item = function( self, state, item_id, item )
            if state then
                if not item.is_case then return end

                local case_info = CASES_DATA[ item.id ]

                if not isElement( ui.item_rt ) then
                    ui.item_rt = ibCreateRenderTarget( 0, 90, sx, sy-90, self.area ):ibData( "priority", 2 )
                    ui.item_shadow = ibCreateImage( sx, 0, sx, sy-90, _, ui.item_rt, 0x00475d75 ):ibData( "alpha", 0 )

                    local item_bg = ibCreateImage( 0, 0, 421, sy-90, _, ui.item_shadow, 0xbf4f647b )
                    local title_bg = ibCreateImage( 421, 0, sx-421, 61, _, ui.item_shadow, 0xbf4f647b )
                    ibCreateImage( 420, 1, 1, sy-90, _, ui.item_shadow, 0x1affffff )
                    ibCreateImage( 420, 60, sx-420, 1, _, ui.item_shadow, 0x1affffff )

                    -- LEFT SIDE

                    ui.btn_back = ibCreateButton( 30, 30, 103, 17, item_bg, 
                                    "img/btn_back_i.png", "img/btn_back_h.png", "img/btn_back_h.png",
                                    COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
                    :ibOnClick( function( key, state ) 
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        self:show_item( false )
                    end )

                    local item_image, img = ibCreateRewardImage( 0, 60, 420, 300, item, item_bg )
                    item_image:ibData( "disabled", true )
                    img:ibData( "disabled", true )

                    local l_cost = ibCreateLabel( 0, 330+40, 0, 0, item.cost, item_bg, _, _, _, "left", "center", ibFonts.bold_26 )

                    local total_width = l_cost:width( ) + 10 + 24
                    local lx = 420 / 2 - total_width / 2

                    l_cost:ibData( "px", lx )

                    local icon_cost = ibCreateImage( lx + l_cost:width( ) + 10, 318+40, 24, 24, "img/icon_vallet.png", item_bg )
                    :ibData( "disabled", true )

                    local btn_buy = ibCreateButton( 0, 540, 158, 66, item_bg,
                                    "img/btn_buy_i.png", "img/btn_buy_h.png", "img/btn_buy_h.png",
                                    COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
                        :center_x( )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )

                            self:buy_item( item_id, item )
                        end )

                    -- Count
                    local bg_items_count = ibCreateImage( 150+36, 450, 48, 30, "img/bg_items_amount.png", item_bg )
                    local l_items_count = ibCreateLabel( 0, 0, 48, 30, item.temp_count or 1, bg_items_count, _, _, _, "center", "center", ibFonts.oxaniumbold_18 )
                    local l_case_name = ibCreateLabel( 0, 410, 420, 0, case_info.name, item_bg, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_18 )

                    local function UpdateBuyCount( value )
                        if not item.temp_count then item.temp_count = 1 end

                        local new_items_amount = item.temp_count + value
                        if new_items_amount <= 0 then 
                            new_items_amount = 99
                        elseif new_items_amount >= 99 then
                            new_items_amount = 1
                        end

                        item.temp_count = new_items_amount

                        l_items_count:ibData("text", item.temp_count)
                        l_cost:ibData( "text", item.cost * item.temp_count )

                        local total_width = l_cost:width( ) + 10 + 24
                        local lx = 420 / 2 - total_width / 2
                        l_cost:ibData( "px", lx )

                        icon_cost:ibData( "px", lx + l_cost:width( ) + 10 )
                    end

                    ui.btn_minus = ibCreateButton( 150, 450, 31, 31, item_bg, 
                        "img/btn_minus_i.png", "img/btn_minus_h.png", "img/btn_minus_h.png",
                        COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
                    :ibOnClick(function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick()
                        UpdateBuyCount( -1 )
                    end)

                    ui.btn_plus = ibCreateButton( 150+90, 450, 31, 31, item_bg, 
                        "img/btn_plus_i.png", "img/btn_plus_h.png", "img/btn_plus_h.png",
                        COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
                    :ibOnClick(function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick()
                        UpdateBuyCount( 1 )
                    end)

                    -- RIGHT SIDE

                    ui.content_bg = ibCreateImage( 421, 62, sx-421, 600, _, ui.item_shadow, 0x00ffffff )

                    ui.content_case_name = ibCreateLabel( 0, 0, sx-420, 60, case_info.name, title_bg, COLOR_WHITE, _, _, "center", "center", ibFonts.bold_18 )
                    :ibData("disabled", true)

                    ibCreateLabel( 0, 40, sx-420, 0, "Содержимое кейса:", ui.content_bg, COLOR_WHITE, _, _, "center", "center", ibFonts.bold_18 )

                    ui.items_pane, ui.scroll_v    = ibCreateScrollpane( 0, 110, 581, 500, ui.content_bg, { scroll_px = -25, bg_color = 0x00FFFFFF } )
                    ui.scroll_v:ibData( "sensivity", 0.1 )
                    ui.scroll_v:ibData( "alpha", 0.35*255 )

                    if next( case_info.items ) then
                        for j, item in pairs( case_info.items ) do
                            if REGISTERED_CASE_ITEMS[ item.id ] then
                                CreateCaseItem( item, 80 + 108 * ( ( j - 1 ) % 4 ), 5 + 108 * math.floor( ( j - 1 ) / 4 ), ui.items_pane )
                            end
                        end
                    end

                    ui.items_pane:AdaptHeightToContents( )
                end

                ui.scrollbar:ibAlphaTo( 0, 200, "InOutQuad" ):ibData( "disabled", true )
                ui.scrollpane:ibAlphaTo( 0, 200, "InOutQuad" ):ibData( "disabled", true )
                ui.item_rt:ibData( "disabled", false )
                ui.item_shadow:ibMoveTo( 0, 0, 500, "InOutQuad" ):ibAlphaTo( 255, 500, "InOutQuad" )
                ui.tab_panel.navbar.elements.area:ibData( "alpha", 0 ):ibData( "disabled", true ):ibData( "py", 3000 )
            else
                ui.item_rt:ibData( "disabled", true )
                ui.item_shadow:ibMoveTo( sx, 0, 500, "InOutQuad" ):ibAlphaTo( 0, 500, "InOutQuad" )
                ui.scrollbar:ibAlphaTo( 255, 200, "InOutQuad" ):ibData( "disabled", false )
                ui.scrollpane:ibAlphaTo( 255, 200, "InOutQuad" ):ibData( "disabled", false )
                ui.tab_panel.navbar.elements.area:ibData( "alpha", 255 ):ibData( "disabled", false ):ibData( "py", 0 )

                ui.item_rt:ibTimer(function()
                    destroyElement( ui.item_rt )
                end, 500, 1)
            end
        end,

        buy_item = function( self, item_id, item )
            local total_cost = ( item.temp_count or 1 ) * item.cost

            if localPlayer:GetCoopQuestKeys( ) < total_cost then
                localPlayer:ShowError( "Недостаточно ключей для совершения покупки" )
                return
            end

            ShowTakeReward( _, item, function( data ) 
                triggerServerEvent( "OnPlayerWantBuyKeysItem", resourceRoot, item_id, data, item.temp_count or 1 )
            end )
        end,
    },

    [ TAB_HELP ] = 
    {
        fn_create = function( self, area )
            self.area = area

            ibCreateImage( 0, 140, 1027, 113, "img/info_header.png", area ):center_x( )

            ibCreateLabel( 30, 224, 0, 0, "Название задания", area, 0xffffffff, _, _, "left", "center", ibFonts.regular_14 ):ibData( "alpha", 255*0.4 )
            ibCreateLabel( 240, 224, 0, 0, "Описание задания", area, 0xffffffff, _, _, "left", "center", ibFonts.regular_14 ):ibData( "alpha", 255*0.4 )
            ibCreateLabel( sx-140, 224, 0, 0, "Награда", area, 0xffffffff, _, _, "left", "center", ibFonts.regular_14 ):ibData( "alpha", 255*0.4 )
        
            local py = 240
            for k,v in pairs( COOP_QUESTS_CONFIG ) do
                local quest = ibCreateImage( 30, py, 965, 140, "img/bg_quest.png", area )
                ibCreateLabel( 20, 56, 0, 0, "Задание "..k, quest, 0x80ffffff, _, _, "left", "center", ibFonts.regular_12 )
                ibCreateLabel( 20, 78, 0, 0, v.name, quest, 0xffffffff, _, _, "left", "center", ibFonts.bold_16 )

                ibCreateLabel( 230, 0, 590, 80, v.desc, quest, 0xffffffff, _, _, "left", "center", ibFonts.regular_15 ):ibData( "wordbreak", true )

                ibCreateLabel( 965-62, 46, 0, 0, "2", quest, 0xffffffff, _, _, "right", "center", ibFonts.oxaniumbold_18 )
                ibCreateLabel( 965-62, 114, 0, 0, "1", quest, 0xffffffff, _, _, "right", "center", ibFonts.oxaniumbold_18 )

                ibCreateButton( 965-360, 74, 186, 50, quest,
                              "img/btn_buy_weapon_i.png", "img/btn_buy_weapon_h.png", "img/btn_buy_weapon_h.png",
                               0xFFFFFFFF, 0xFFffffff, 0xFFffffff )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )

                    local location = exports.nrp_help:FindClosestLocation( "gunshop" )
                    if location then
                        triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "special" )

                        --triggerEvent( "ToggleGPS", localPlayer, location )
                        --localPlayer:ShowInfo( "Магазин оружия отмечен на карте" )
                    end
                end )
                py = py + 150
            end
        end,
    },
}

function ShowUI_Quests( state, data )
    if state then
        if ui.hidden then
            HideQuestsUI( false )
            return
        end

        if not CASES_DATA then
            LoadWebData( )
        end

        ShowUI_Quests( false )

        LOBBY_DATA = table.copy( DEFAULT_LOBBY_DATA )
        LOBBY_DATA.teams[1][1].name = localPlayer:GetNickName( )

        ui.bg = ibCreateImage( 0, 0, sx, sy, "img/bg.png" ):center( )
        ui.tab_area = ibCreateArea( 0, 0, sx, sy, ui.bg )

        ui.title = ibCreateLabel( 32, 0, 0, 90, "Опасные задания", ui.bg, _, _, _, "left", "center", ibFonts.bold_20 )

        ui.btn_close = ibCreateButton( sx - 24 - 26, 32, 24, 24, ui.bg,
                              ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                               0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                
                if LOBBY_DATA and LOBBY_DATA.is_searching or LOBBY_DATA.team_found then
                    HideQuestsUI( true )
                else
                    ShowUI_Quests( false )
                end
            end )

        ui.icon_vallet = ibCreateImage( sx-106, 30, 24, 24, "img/icon_vallet.png", ui.bg )
        ui.l_vallet_value = ibCreateLabel( sx-114, 42, 0, 0, localPlayer:GetCoopQuestKeys( ), ui.bg, _, _, _, "right", "center", ibFonts.oxaniumbold_18 )
        ui.l_vallet = ibCreateLabel( sx - 114 - ui.l_vallet_value:width( ) - 10, 42, 0, 0, "Твой счет:", ui.bg, _, _, _, "right", "center", ibFonts.regular_14 )

        ui.tab_panel = ibCreateTabPanel( {
            px = 0,
            py = 90,
            sx = sx,
            sy = sy,
            tab_area_px = 0,
            tab_area_py = -90,
            tab_area_sx = sx,
            tab_area_sy = sy,
            parent = ui.bg,
            tabs = TABS_LIST,
            tabs_conf = TABS_CONF,
            current = selected_tab or 1,
            precreate_all_tabs_content = true,
            create_tab_area_under_navbar = true,
            navbar_conf = {
                sy = 50,
                font = ibFonts.bold_16,
            },
        } )

        showCursor( true )

        if data.zone then
            LOBBY_DATA.search_zone = data.zone == -1 and createColSphere( localPlayer.position, 50 ) or data.zone
            LOBBY_DATA.is_temp_zone = data.zone == -1 and true or false
            addEventHandler( "onClientElementColShapeLeave", localPlayer, OnClientLeftSearchZone )
        end

        addEventHandler( "onClientElementDataChange", localPlayer, OnClientElementDataChange )
    else
        --if LOBBY_DATA then
        --    if LOBBY_DATA.team_found then
        --        triggerServerEvent( "OnPlayerRequestLeaveLobby", resourceRoot )
        --    elseif LOBBY_DATA.is_searching then
        --        triggerServerEvent( "OnPlayerRequestToggleSearch", resourceRoot, _, true )
        --    end
        --end
        
        DestroyTableElements( ui )
        ui = { }

        showCursor( false )

        removeEventHandler( "onClientElementColShapeLeave", localPlayer, OnClientLeftSearchZone )
        removeEventHandler( "onClientElementDataChange", localPlayer, OnClientElementDataChange )
    end
end

function OnClientElementDataChange( key, old_value, value )
    if source ~= localPlayer then return end
    if not ui or not isElement( ui.bg ) then return end

    if key == "coop_quest_keys" then
        ui.l_vallet_value:ibData( "text", value )
    elseif key == "coop_quest_attempts" then
        ui.l_quests_left_value:ibData( "text", value )
    end
end

function HideQuestsUI( state )
    if not ui or not isElement( ui.bg ) then return end

    ui.hidden = state
    ui.bg:ibData( "alpha", state and 0 or 255 )
    showCursor( not state )
end

function OnClientLeftSearchZone( col )
    if LOBBY_DATA and LOBBY_DATA.search_zone == col then
        ShowUI_Quests( false )

        if not LOBBY_DATA.opponents_found then
            if LOBBY_DATA.team_found then
                triggerServerEvent( "OnPlayerRequestLeaveLobby", resourceRoot )
            elseif LOBBY_DATA.is_searching then
                triggerServerEvent( "OnPlayerRequestToggleSearch", resourceRoot, _, true )
            end
        end

        if LOBBY_DATA.is_temp_zone and isElement( LOBBY_DATA.search_zone ) then
            destroyElement( LOBBY_DATA.search_zone )
        end
    end
end

function GetLobbyLocalPlayer( )
    for k,v in pairs( LOBBY_DATA.teams[ LOBBY_DATA.team ] ) do
        if v.element == localPlayer then
            return v
        end
    end
end

function GetLobbyTeammate( )
    for k,v in pairs( LOBBY_DATA.teams[ LOBBY_DATA.team ] ) do
        if v.element ~= localPlayer then
            return v
        end
    end
end

function OnClientLobbyDataSynced( data )
    if not isElement( ui.bg ) then
        ShowUI_Quests( true, { zone = -1 } )
    end

    for k,v in pairs( data ) do
        LOBBY_DATA[ k ] = v
    end

    TABS_CONF[ TAB_LOBBY ]:update_players( )
    TABS_CONF[ TAB_LOBBY ]:update_lobby( )

    if ui.hidden then
        HideQuestsUI( false )
    end
end
addEvent( "OnClientLobbyDataSynced", true )
addEventHandler( "OnClientLobbyDataSynced", resourceRoot, OnClientLobbyDataSynced )

function OnClientTeamsDataSynced( data )
    if not isElement( ui.bg ) then
        ShowUI_Quests( true, { zone = -1 } )
    end

    LOBBY_DATA.teams = data

    for i, team in pairs( LOBBY_DATA.teams ) do
        for k, data in pairs( team ) do
            if not data.name then
                data.name = data.element:GetNickName( )
            end
        end
    end

    TABS_CONF[ TAB_LOBBY ]:update_players( )
    TABS_CONF[ TAB_LOBBY ]:update_lobby( )
end
addEvent( "OnClientTeamsDataSynced", true )
addEventHandler( "OnClientTeamsDataSynced", resourceRoot, OnClientTeamsDataSynced )

function OnClientLobbyJoined( data )
    for k,v in pairs( data ) do
        LOBBY_DATA[ k ] = v
    end
end
addEvent( "OnClientLobbyJoined", true )
addEventHandler( "OnClientLobbyJoined", resourceRoot, OnClientLobbyJoined )

function OnClientLobbyLeft( )
    ShowUI_Quests( false )
end
addEvent( "OnClientLobbyLeft", true )
addEventHandler( "OnClientLobbyLeft", resourceRoot, OnClientLobbyLeft )

function IsRemoteActionAvailable( )
    local state = getTickCount() - last_remote_action >= 500

    if not state then
        localPlayer:ShowError( "Подождите немного" )
    end

    return state
end

function GetAdditionalCasesIDs( )
    local additional_ids = { }
    for i, v in pairs( SHOP_ITEMS_LIST ) do
        if v.is_case then
            table.insert( additional_ids, v.id )
        end
    end
    return additional_ids
end

function LoadWebData( )
    if not CONST_GET_DATA_URL then
        CONST_GET_DATA_URL = exports.nrp_shop:GetConstDataURL( )
    end

    if not CONST_GET_DATA_URL then
        if isTimer( RELOAD_WEB_DATA_TIMER ) then killTimer( RELOAD_WEB_DATA_TIMER ) end
        RELOAD_WEB_DATA_TIMER = setTimer(LoadWebData, 1000, 1)
        return 
    end

    local server = localPlayer:getData( "_srv" )[ 1 ]
    local url = CONST_GET_DATA_URL .. server
    local additional_ids = GetAdditionalCasesIDs( )
    if #additional_ids > 0 then
        url = url .. "?additional=" .. table.concat( additional_ids, "," )
    end

    fetchRemote( url,
        {
            queueName = "f4_data",
            connectionAttempts = 10,
            connectTimeout = 15000,
            method = "GET",
        },
        function( json_data, err )
            -- Если ошибка чтения, но раньше уже читались кейсы
            if ( not err.success or err.statusCode ~= 200 ) then
                UpdateCasesInfo( false )
                return
            end

            local data = fromJSON( json_data )
            UpdateCasesInfo( data.cases_info )
        end
    )
end

function UpdateCasesInfo( cases_info )
    if not cases_info then return end

    CASES_DATA = cases_info
end

local CONST_RARE_COLORS = {
    [1] = 0xffaff7ff;
    [2] = 0xffa975ff;
    [3] = 0xfffd56ff;
    [4] = 0xffff6464;
    [5] = 0xffffb346;
}

function CreateCaseItem( item, pos_x, pos_y, bg )
    local item_bg       = ibCreateImage( pos_x, pos_y, 96, 96, ":nrp_shop/img/cases/item_bg.png", bg )
    local item_bg_hover = ibCreateImage( 0, 0, 96, 96, ":nrp_shop/img/cases/item_bg_hover.png", item_bg ):ibData( "alpha", 0 )
    ibCreateImage( 16, -9, 65, 29, ":nrp_shop/img/cases/rare.png", item_bg, CONST_RARE_COLORS[ item.rare ] )
    REGISTERED_CASE_ITEMS[ item.id ].uiCreateItem_func( item.id, item.params, item_bg, fonts )

    local description_area  = ibCreateArea( 3, 3, 90, 90, item_bg )
    addEventHandler( "ibOnElementMouseEnter", description_area, function( )
        if isElement( ui.description_box ) then
            destroyElement( ui.description_box )
        end

        item_bg_hover:ibAlphaTo( 255, 350 )

        local description_data = REGISTERED_CASE_ITEMS[ item.id ].uiGetDescriptionData_func( item.id, item.params )
        if description_data then
            local title_len = dxGetTextWidth( description_data.title, 1, ibFonts.bold_15 ) + 30
            local box_s_x = math.max( 170, title_len )
            local box_s_y = 92
            if not description_data.description then
                box_s_x = title_len
                box_s_y = 35
            end

            local pos_x, pos_y = getCursorPosition( )
            pos_x, pos_y = pos_x * _SCREEN_X, pos_y * _SCREEN_Y
    
            ui.description_box = ibCreateImage( pos_x - 5, pos_y - box_s_y - 5, box_s_x, box_s_y, nil, nil, 0xCC000000 )
                :ibData( "alpha", 0 )
                :ibAlphaTo( 255, 350 )
                :ibOnRender( function ( )
                    local cx, cy = getCursorPosition( )
                    cx, cy = cx * _SCREEN_X, cy * _SCREEN_Y
                    ui.description_box:ibBatchData( { px = cx - 5, py = cy - box_s_y - 5 } )
                end )

            ibCreateLabel( 0, 17, box_s_x, 0, description_data.title, ui.description_box ):ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" })
            if description_data.description then
                ibCreateLabel( 0, 30, box_s_x, 0, description_data.description, ui.description_box, 0xffd3d3d3 ):ibBatchData( { font = ibFonts.regular_13, align_x = "center", align_y = "top" })
            end
        end
    end, false )

    addEventHandler( "ibOnElementMouseLeave", description_area, function( )
        if isElement( ui.description_box ) then
            destroyElement( ui.description_box )
        end

        item_bg_hover:ibAlphaTo( 0, 350 )
    end, false )

    return item_bg
end