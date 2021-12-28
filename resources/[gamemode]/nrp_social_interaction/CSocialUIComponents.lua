Extend( "ib" )
Extend( "ShUtils" )
Extend( "ShFood" )
Extend( "ShDiseases" )
Extend( "ShSocialRating" )
Extend( "ShAchievements" )

-- use real fonts as PS
ibUseRealFonts( true )

local ui = { }
local tex = { }
local mainComponents = { }

local function loadMenu( )
    if #mainComponents ~= 0 then return end

    tex = {
        main_bg         = dxCreateTexture( "img/bg.png" ),

        like_bg         = dxCreateTexture( "img/like_bg_u.png" ),
        like_bg_s       = dxCreateTexture( "img/like_bg_s.png" ),
        law_bg          = dxCreateTexture( "img/law.png" ),
        progress        = dxCreateTexture( "img/progress.png" ),
        like            = dxCreateTexture( "img/like.png" ),
        dislike         = dxCreateTexture( "img/dislike.png" ),

        good            = dxCreateTexture( "img/good.png" ),
        bad             = dxCreateTexture( "img/bad.png" ),

        achievement     = dxCreateTexture( "img/achievement.png" ),
        achievement2    = dxCreateTexture( "img/achievement2.png" ),
        achievement_s   = dxCreateTexture( "img/achievement_s.png" ),
        achievement_s2  = dxCreateTexture( "img/achievement_s2.png" ),
    }
end

local function unloadMenu( )
    if #mainComponents ~= 0 then return end

    for _, texture in pairs( tex ) do
        destroyElement( texture )
    end

    tex = { }
    data = { }
end

local function syncCursor( component, state )
    if state then
        table.insert( mainComponents, component )
    else
        table.removevalue( mainComponents, component )
    end

    if state and #mainComponents == 1 then
        showCursor( true )
    elseif not state and #mainComponents == 0 then
        showCursor( false )
    end
end

local function setStateComponent( component, state )
    if state and isElement( component ) then return false
    elseif not state then
        if isElement( component ) then
            -- destroyElement( component )
            component:ibAlphaTo( 0, 250 )
            component:ibTimer( destroyElement, 250, 1 )

            syncCursor( component, false )
        end

        return false
    end

    return true
end

components = {

    -- singleton ui components

    window = function ( state )
        if not setStateComponent( ui.bg, state ) then return else end

        -- load imgs
        loadMenu( )

        -- background
        ui.bg = ibCreateBackground( nil, function()
            setStateComponent( ui.bg, false )
        end, true, true )
        :ibData( "alpha", 0 ):ibAlphaTo( 255, 250 ):ibOnDestroy( unloadMenu )

        -- window
        ui.window = ibCreateImage( 0, 0, 1024, 770, tex.main_bg, ui.bg ):center( )

        -- close button
        ibCreateButton( 960, 30, 30, 30, ui.window, ":nrp_shared/img/confirm_btn_close.png", nil, nil, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            setStateComponent( ui.bg, false )
        end )
        :ibData( "priority", 1 )

        -- header
        ibCreateLabel( 30, 30, 0, 0, "Статистика", ui.window, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_20 )

        -- show menu
        components.menu( true, ui.window )

        -- show law rating
        components.rating( true, ui.window )

        -- sync cursor
        syncCursor( ui.bg, true )
    end,

    menu = function ( state, window )
        if not setStateComponent( ui.menu, state ) then return end

        ui.menu = ibCreateArea( 0, 155, 0, 0, window ):ibData( "priority", 1 )

        -- line
        ibCreateImage( 30, 0, 964, 1, nil, ui.menu, 0x22ffffff )

        -- orange shadow
        local shadow = ibCreateImage( 30, - 3, 4, 4, nil, ui.menu, 0xffff965d )

        -- buttons
        local buttons = {
            { to = "rating",       name = "Социальный рейтинг",    selected = true },
            { to = "leaders",      name = "Лидерборд" },
            { to = "statistic",    name = "Статистика" },
            { to = "buffs",        name = "Баффы" },
            { to = "achievements", name = "Достижения",            data = "new_achievement" },
        }

        local oldNum = 1
        for num, button in ipairs( buttons ) do
            local x = buttons[num - 1] and buttons[num - 1].element:ibGetAfterX( ) + 30 or 30
            local width = dxGetTextWidth( button.name, 1, ibFonts.bold_16 )

            button.element = ibCreateLabel( x, - 50, width, 50, button.name, ui.menu, 0xffffffff, nil, nil, "left", "center", ibFonts.bold_16 )
            :ibData( "alpha", button.selected and 255 or 100 )
            :ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then return end

                if isElement( button.element_i ) then
                    button.element_i:destroy( )
                    localPlayer:setData( button.data, false, false )
                end

                for buttonNum, button in ipairs( buttons ) do
                    button.selected = buttonNum == num and true or false
                    button.element:ibAlphaTo( button.selected and 255 or 100, 50 )

                    if not button.selected then
                        components[button.to]( false, window, oldNum > num and 50 or - 50 ) -- hide component
                    end
                end

                ibClick( )

                if oldNum == num then return end

                shadow:ibMoveTo( x, nil, 200 )
                shadow:ibResizeTo( width, 4, 200 )

                components[button.to]( true, window, oldNum < num and 50 or - 50 ) -- show component

                oldNum = num
            end )
            :ibOnHover( function( )
                button.element:ibAlphaTo( 255, 200 )
            end )
            :ibOnLeave( function ( )
                if button.selected then return end

                button.element:ibAlphaTo( 100, 200 )
            end )

            if button.data and localPlayer:getData( button.data ) then
                button.element_i = ibCreateImage( button.element:width( ) + x, - 44, 23, 23, "img/icon_indicator_new.png", ui.menu )
            end

            if button.selected then
                shadow:ibData( "sx", width )
                shadow:ibMoveTo( x, nil, 200 )
            end
        end
    end,

    share = function ( state, window )
        if not setStateComponent( ui.share, state ) then return end

        ui.share = ibCreateImage( 0, - 82, 1024, 677, nil, window, 0xef1f2934 ):ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )

        -- info
        ibCreateLabel( 0, 210, 1024, 0, "Введите ник игрока, которому хотите показать свое имущество", ui.share,nil, nil, nil, "center", "top", ibFonts.bold_20 )

        -- edit
        local edit_bg = ibCreateImage( 225, 260, 575, 58, "img/edit_bg2.png", ui.share )
        local edit = ibCreateWebEdit( 0, 0, 575, 58, "", edit_bg, 0x80ffffff, 0 )
        edit:ibBatchData( { max_length = 48, placeholder = "Введите имя игрока", font = "regular_12_200", text_align = "center" } )

        ibCreateLabel( 0, 335, 1024, 0, "", ui.share,0xffab464b, nil, nil, "center", "top", ibFonts.regular_14 )
        :ibTimer( function ( self )
            if data.sendStatistic == nil then return end

            self:ibBatchData( data.sendStatistic and { text = "Статистика отправлена", color = "0xffffde9e" } or { text = "Игрок не найден / не в сети", color = "0xffab464b" } )
        end, 250, 0 )

        -- add
        ibCreateButton( 434, 370, 156, 49, ui.share, "img/btn_add.png", nil, nil, 0xaaffffff, 0xffffffff, 0xffffffff )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            updateData( "sendStatistic", edit:ibData( "text" ) )
        end )

        -- hide
        ibCreateButton( 459, 608, 108, 42, ui.share, "img/btn_hide.png", nil, nil, 0xaaffffff, 0xffffffff, 0xffffffff )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            components.share( false )
        end )

        -- update data
        data.sendStatistic = nil
    end,

    share_achievements = function ( state, window )
        if not setStateComponent( ui.share_achievements, state ) then return end

        ui.share_achievements = ibCreateImage( 0, -67, 1024, 682, nil, window, 0xef1f2934 ):ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )

        -- info
        ibCreateLabel( 0, 210, 1024, 0, "Введите ник игрока, которому хотите показать свои достижения", ui.share_achievements,nil, nil, nil, "center", "top", ibFonts.bold_20 )

        -- edit
        local edit_bg = ibCreateImage( 225, 260, 575, 58, "img/edit_bg2.png", ui.share_achievements )
        local edit = ibCreateWebEdit( 0, 0, 575, 58, "", edit_bg, 0x80ffffff, 0 )
        edit:ibBatchData( { max_length = 48, placeholder = "Введите имя игрока", font = "regular_12_200", text_align = "center" } )

        ibCreateLabel( 0, 335, 1024, 0, "", ui.share_achievements,0xffab464b, nil, nil, "center", "top", ibFonts.regular_14 )
        :ibTimer( function ( self )
            if data.sendAchievements == nil then return end

            self:ibBatchData( data.sendAchievements and { text = "Достижения отправлены", color = "0xffffde9e" } or { text = "Игрок не найден / не в сети", color = "0xffab464b" } )
        end, 250, 0 )

        -- add
        ibCreateButton( 434, 370, 156, 49, ui.share_achievements, "img/btn_add.png", nil, nil, 0xaaffffff, 0xffffffff, 0xffffffff )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            updateData( "sendAchievements", edit:ibData( "text" ) )
        end )

        -- hide
        ibCreateButton( 459, 608, 108, 42, ui.share_achievements, "img/btn_hide.png", nil, nil, 0xaaffffff, 0xffffffff, 0xffffffff )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            components.share_achievements( false )
        end )

        -- update data
        data.sendAchievements = nil
    end,

    rules = function ( state, window )
        if not setStateComponent( ui.rules, state ) then return end

        ui.rules = ibCreateImage( 0, - 82, 1024, 677, nil, window, 0xef1f2934 ):ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )

        ibCreateLabel( 0, 82, 1024, 30, "Правила", ui.rules, 0xffffffff, nil, nil, "center", "top", ibFonts.bold_18 )

        local bg = ibCreateImage( 0, 115, 1024, 35, nil, ui.rules, 0xff586c80 )
        ibCreateLabel( 273, 0, 0, 35, "№", bg,0x66ffffff, nil, nil, "center", "center", ibFonts.regular_12 )
        ibCreateLabel( 513, 0, 0, 35, "Описание правила", bg, 0x66ffffff, nil, nil, "center", "center", ibFonts.regular_12 )
        ibCreateLabel( 754, 0, 0, 35, "Влияние на рейтинг", bg, 0x66ffffff, nil, nil, "center", "center", ibFonts.regular_12 )

        local scrollpane, scrollbar = ibCreateScrollpane( 0, 150, 1024, 420, ui.rules, { scroll_px = - 20, bg_color = 0x00FFFFFF  } )
        scrollbar:ibSetStyle( "slim_small_nobg" ):ibData( "absolute", true ):ibData( "sensivity", 50 )

        local num = 1

        local rules = { }
        for _, rule in pairs( SOCIAL_RATING_RULES ) do
            table.insert( rules, rule )
        end
        table.sort( rules, function ( a, b ) return a.rating > b.rating end )

        local color = 0x11000000
        for _, rule in ipairs( rules ) do
            color = color == 0x11000000 and 0x22000000 or 0x11000000

            local bg = ibCreateImage( 0, num * 35 - 35, 1024, 35, nil, scrollpane, color )

            ibCreateLabel( 273, 0, 0, 35, num, bg, 0xffffffff, nil, nil, "center", "center", ibFonts.bold_14 )
            ibCreateLabel( 513, 0, 0, 35, rule.name, bg, 0xffffffff, nil, nil, "center", "center", ibFonts.bold_14 )
            ibCreateLabel( 754, 0, 0, 35, rule.rating, bg, 0xffffffff, nil, nil, "center", "center", ibFonts.bold_14 )

            num = num + 1
        end

        scrollpane:AdaptHeightToContents( )
        scrollbar:UpdateScrollbarVisibility( scrollpane )

        -- hide
        ibCreateButton( 459, 608, 108, 42, ui.rules, "img/btn_hide.png", nil, nil, 0xaaffffff, 0xffffffff, 0xffffffff )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            components.rules( false )
        end )
    end,

    rating = function ( state, window, animOffset )
        if not setStateComponent( ui.rating, state ) then
            if isElement( ui.rating ) then ui.rating:ibMoveTo( animOffset, nil, 250 ) end
            return
        end

        ui.rating = ibCreateArea( animOffset, 175, 1024, 595, window ):ibData( "alpha", 0 ):ibAlphaTo( 255, 250 ):ibMoveTo( 0, nil, 250 )

        -- rules
        ibCreateButton( 910, - 50, 76, 13, ui.rating, "img/btn_rules.png", "img/btn_rules.png", "img/btn_rules.png", 0x55FFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            components.rules( true, ui.rating )
        end )

        -- info
        local bg_info = ibCreateImage( 0, -10, 964, 68, "img/sr_info.png", ui.rating ):center_x( )

        ibCreateButton( 794, 14, 150, 40, bg_info, "img/btn_details_i.png", "img/btn_details_h.png", "img/btn_details_h.png", COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
        :ibOnClick( function( key, state ) 
            if key ~= "left" or state ~= "up" then return end

            ibClick( )

            triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, 4, "nrp_social_interaction" )
        end )

        -- law
        components.law( ui.rating, 0, 66, true )

        -- find
        local bottom_area = ibCreateArea( 0, 0, 0, 0, ui.rating )

        -- like & dislike
        local function hoverBG( bg )
            bg:ibData( "texture", tex.like_bg_s )
        end

        local function leaveBG( bg )
            bg:ibData( "texture", tex.like_bg )
        end

        local disLikeBG = ibCreateImage( 30, 360, 470, 210, tex.like_bg, bottom_area, 0xffffffff )
        local likeBG = ibCreateImage( 525, 360, 470, 210, tex.like_bg, bottom_area, 0xffffffff )

        ibCreateImage( 30, 360, 470, 210, tex.dislike, bottom_area, 0xffffffff )
        ibCreateImage( 525, 360, 470, 210, tex.like, bottom_area, 0xffffffff )

        ibCreateLabel( 0, 165, 470, 30, "Осталось дизлайков: -", disLikeBG, 0xffffffff, nil, nil, "center", "top", ibFonts.regular_14 )
        :ibTimer( function ( self )
            self:ibData( "text", "Осталось дизлайков: " .. ( data.available_dislike or "-" ) )
        end, 500, 0 )

        ibCreateLabel( 0, 165, 470, 30, "Осталось лайков: -", likeBG, 0xffffffff, nil, nil, "center", "top", ibFonts.regular_14 )
        :ibTimer( function ( self )
            self:ibData( "text", "Осталось лайков: " .. ( data.available_like or "-" ) )
        end, 500, 0 )

        ibCreateArea( 30, 360, 470, 210, bottom_area )
        :ibOnHover( function ( ) hoverBG( disLikeBG ) end )
        :ibOnLeave( function ( ) leaveBG( disLikeBG ) end )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end
            if not data.findedPlayerData or not data.available_dislike then
                localPlayer:ShowError( "Для начала необходимо найти игрока\nкоторого хотите оценить!" )
                return
            end

            if data.available_dislike < 1 then
                localPlayer:ShowError( "В наличии недостаточно дизлайков!" )
                return
            end

            updateData( "dislikeFindedPlayer", data.findedPlayerData )
        end )

        ibCreateArea( 525, 360, 470, 210, bottom_area )
        :ibOnHover( function ( ) hoverBG( likeBG ) end )
        :ibOnLeave( function ( ) leaveBG( likeBG ) end )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end
            if not data.findedPlayerData or not data.available_like then
                localPlayer:ShowError( "Для начала необходимо найти игрока\nкоторого хотите оценить!" )
                return
            end

            if data.available_like < 1 then
                localPlayer:ShowError( "В наличии недостаточно лайков!" )
                return
            end

            updateData( "likeFindedPlayer", data.findedPlayerData )
        end )

        ibCreateLabel( 0, 270, 1024, 30, "Благодарность игроку", bottom_area, 0xffffffff, nil, nil, "center", "top", ibFonts.bold_18 )

        local edit_bg = ibCreateImage( 30, 310, 850, 37, "img/edit_bg.png", bottom_area )
        local edit = ibCreateWebEdit( 30, 0, 800, 37, "", edit_bg, 0x80ffffff, 0 )
        :ibBatchData( { max_length = 48, placeholder = "Введите имя игрока", font = "regular_11_200", placeholder_color = "0xaaffffff" } )

        ibCreateLabel( 830, 0, 0, 37, "", edit_bg, 0xffab464b, nil, nil, "right", "center", ibFonts.regular_12 )
        :ibTimer( function ( self )
            if data.findedPlayerData == nil then return end

            self:ibBatchData( data.findedPlayerData and { text = "Игрок найден", color = "0xffffde9e" } or { text = "Игрок не найден или не в сети", color = "0xffab464b" } )
        end, 250, 0 )

        local list_bg = ibCreateImage( 30, 310, 850, 202, "img/bg_players.png", bottom_area )
        :ibData( "alpha", 0 ):ibData( "disabled", true )

        local scrollpane, scrollbar = ibCreateScrollpane( 0, 57, 850, 130, list_bg, { scroll_px = - 20, bg_color = 0x00FFFFFF  } )
        scrollbar:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.05 )

        local players_list_elements = {}

        local function UpdateClosestPlayersList()
            DestroyTableElements( players_list_elements )
            players_list_elements = { }

            local pPlayers = { }
            pPlayers = getElementsWithinRange( localPlayer.position, 50, "player" ) or { }

            for k,v in pairs( pPlayers ) do
                if v == localPlayer then
                    table.remove( pPlayers, k )
                    break
                end
            end

            if #pPlayers <= 0 then
                list_bg:ibData( "alpha", 0 ):ibData( "disabled", true )
                return
            end

            local bEven = true
            local py = 0
            for i, player in pairs( pPlayers ) do
                local player_bg = ibCreateButton( 1, py, 848, 37, scrollpane, _, _, _, bEven and 0xbf506f91 or 0x00ffffff, 0xbf131c25, 0xbf131c25 )
                :ibOnClick( function( key, state ) 
                    if key ~= "left" or state ~= "down" then return end
                    if list_bg:ibData( "disabled" ) then return end

                    edit:ibData( "text", player:GetNickName() )
                end)

                local icon_search = ibCreateImage( 17, 11, 14, 14, "img/icon_search.png", player_bg )
                local l_player_name = ibCreateLabel( 45, 0, 0, 37, player:GetNickName(), player_bg, COLOR_WHITE, _, _, "left", "center", ibFonts.regular_14 )

                table.insert( players_list_elements, player_bg )
                
                bEven = not bEven
                py = py + 37
            end

            scrollpane:AdaptHeightToContents( )
            scrollbar:UpdateScrollbarVisibility( scrollpane )
        end

        edit:ibOnFocusChange(function( state )
            list_bg:ibData("alpha", state and 255 or 0)

            list_bg:ibTimer(function()
                list_bg:ibData("disabled", not state)
            end, 100, 1)

            if state then
                UpdateClosestPlayersList()
            end
        end)

        edit:ibOnTextChange(function( state )
            list_bg:ibData("alpha", 0):ibData("disabled", true)
        end)

        ibCreateButton( 900, 310, 93, 37, bottom_area, "img/btn_find.png", nil, nil, 0xaaffffff, 0xffffffff, 0xffffffff )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            updateData( "findedPlayerData", edit:ibData( "text" ) )
        end )

        -- update data
        if not data.available_dislike then
            updateData( "available_dislike" )
            updateData( "available_like" )
            updateData( "social_rating" )
        end

        if localPlayer:GetLevel( ) < 5 then
            bottom_area:ibData( "alpha", 255*0.2 ):ibData( "disabled", true )
            ibCreateImage( 0, 256, 1024, 339, "img/sr_blocked.png", ui.rating )
        end

        data.findedPlayerData = nil
    end,

    leaders = function ( state, window, animOffset )
        if not setStateComponent( ui.leaders, state ) then
            if isElement( ui.leaders ) then ui.leaders:ibMoveTo( animOffset, nil, 250 ) end
            return
        end

        ui.leaders = ibCreateArea( animOffset, 185, 1024, 585, window ):ibData( "alpha", 0 ):ibAlphaTo( 255, 250 ):ibMoveTo( 0, nil, 250 )

        -- line
        ibCreateImage( 511, 0, 1, 557, nil, ui.leaders, 0x22ffffff )

        -- tops
        local function generateTopList( x, y, name, arrayName )
            local top = ibCreateImage( x, y, 462, 557, nil, ui.leaders, 0x22000000 )
            local width = dxGetTextWidth( name, 1, ibFonts.regular_16 )

            ibCreateImage( 0, 19, 23, 23, "img/analytics.png", top ):center_x( - width / 2 - 10 )
            ibCreateLabel( 30, 0, 432, 60, name, top, 0xffffffff, nil, nil, "center", "center", ibFonts.regular_16 )

            local header = ibCreateImage( 0, 60, 462, 32, nil, top, 0xff586c80 )
            ibCreateLabel( 20, 0, 0, 32, "Топ", header,0x66ffffff, nil, nil, "left", "center", ibFonts.regular_12 )
            ibCreateLabel( 85, 0, 0, 32, "Ник игрока", header, 0x66ffffff, nil, nil, "left", "center", ibFonts.regular_12 )
            ibCreateLabel( 355, 0, 0, 32, "Соц. рейтинг", header, 0x66ffffff, nil, nil, "left", "center", ibFonts.regular_12 )

            local updated = false

            local scrollpane, scrollbar = ibCreateScrollpane( 0, 92, 462, 465, top, { scroll_px = - 20, bg_color = 0x00FFFFFF  } )
            scrollbar:ibSetStyle( "slim_small_nobg" ):ibData( "absolute", true ):ibData( "sensivity", 50 )
            scrollbar:ibTimer( function ( )
                if updated or not data.top_players then return end

                local color = 0x11000000
                for num, leader in ipairs( data.top_players[arrayName] ) do
                    color = color == 0x11000000 and 0x22000000 or 0x11000000

                    local bg = ibCreateImage( 0, num * 46 - 46, 462, 46, nil, scrollpane, color )

                    ibCreateLabel( 20, 0, 0, 46, num, bg, 0xffffffff, nil, nil, "left", "center", ibFonts.bold_14 )
                    local n = ibCreateLabel( 85, 0, 0, 46, leader.nickname, bg, 0xffffffff, nil, nil, "left", "center", ibFonts.bold_14 )
                    ibCreateLabel( 355, 0, 0, 46, leader.social_rating, bg, 0xffffffff, nil, nil, "left", "center", ibFonts.bold_14 )

                    if num < 11 then
                        if arrayName == "goodPlayers" then
                            ibCreateImage( n:ibGetAfterX( ) + 8, 16, 37, 13, tex.good, bg )
                        elseif arrayName == "badPlayers" then
                            ibCreateImage( n:ibGetAfterX( ) + 8, 16, 37, 13, tex.bad, bg )
                        end
                    end
                end

                scrollpane:AdaptHeightToContents( )
                scrollbar:UpdateScrollbarVisibility( scrollpane )

                updated = true
            end, 250, 4 )
        end

        generateTopList( 30, 0, "Топ мирных игроков", "goodPlayers" )
        generateTopList( 532, 0, "Топ опасных игроков", "badPlayers" )

        -- update data
        if not data.top_players then
            updateData( "top_players" )
        end
    end,

    statistic = function ( state, window, animOffset )
        if not setStateComponent( ui.statistic, state ) then
            if isElement( ui.statistic ) then ui.statistic:ibMoveTo( animOffset, nil, 250 ) end
            return
        end

        ui.statistic = ibCreateArea( animOffset, 175, 1024, 595, window ):ibData( "alpha", 0 )
        :ibAlphaTo( 255, 250 )
        :ibMoveTo( 0, nil, 250 )

        local scrollpane, scrollbar = ibCreateScrollpane( 0, 0, 1024, 505, ui.statistic, { scroll_px = - 20, bg_color = 0x00FFFFFF  } )
        scrollbar:ibSetStyle( "slim_small_nobg" ):ibData( "absolute", true ):ibData( "sensivity", 50 )

        components.panels( scrollpane, 30, 0, "Основные", "statistic", { "mission", "task", "accumulation", "casino", "hobby", "event", "arrest", "kill", "death", } )
        components.panels( scrollpane, 30, 450, "Имущество", "property_statistic", { "property", "car", "house", "skin", "accessory", "business", "moto", "airplane", "vessel", } )

        scrollpane:AdaptHeightToContents( )
        scrollbar:UpdateScrollbarVisibility( scrollpane )

        -- share statistic
        ibCreateButton( 430, 527, 163, 42, ui.statistic, "img/btn_share.png", nil, nil, 0xaaffffff, 0xffffffff, 0xffffffff )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            components.share( true, ui.statistic )
        end )

        -- update data
        if not data.statistic then
            updateData( "statistic" )
            updateData( "property_statistic" )
        end
    end,

    buffs = function ( state, window, animOffset )
        if not setStateComponent( ui.buffs, state ) then
            if isElement( ui.buffs ) then ui.buffs:ibMoveTo( animOffset, nil, 250 ) end
            return
        end

        ui.buffs = ibCreateArea( animOffset, 175, 1024, 595, window )
        :ibData( "alpha", 0 ):ibAlphaTo( 255, 250 ):ibMoveTo( 0, nil, 250 )

        -- buffs
        local updated = false

        ibCreateLabel( 30, 0, 1024, 30, "Текущие баффы персонажа", ui.buffs, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_18 )
        :ibTimer( function ( )
            if updated or not data.buffs then return end

            if #data.buffs < 1 then
                ibCreateLabel( 0, 250, 1024, 30, "Нет ни одного баффа/дебаффа...", ui.buffs, 0xffffffff, nil, nil, "center", "top", ibFonts.bold_18 )
            else
                local currentTime = getRealTimestamp()
                local index = 0
                for _, data in ipairs( data.buffs ) do
                    if not data.timeTo or ( data.timeTo and data.timeTo > currentTime ) then
                        local line = math.floor( index / 3 )
                        local id = data.id and data.id or ""
                        local imgPath = "img/buffs/" .. data.name .. "" .. id .. ".png"
                        local yOfDesc = 57

                        local img = ibCreateImage( 30 + index * 328 - line * 328 * 3, 45 + line * 130, 308, 110, imgPath, ui.buffs )

                        if data.timeTo then
                            yOfDesc = 70

                            local function upTimerLabel( label )
                                local seconds = data.timeTo - getRealTimestamp()
                                local timeLabel = seconds

                                if timeLabel <= 0 then
                                    -- end of buff
                                    destroyElement( ui.buffs )
                                    components.buffs( true, window, 0 )
                                    return
                                end

                                if timeLabel >= 3600 * 24 then
                                    local day = math.ceil( timeLabel / ( 3600 * 24 ) )
                                    timeLabel =  day .. " " .. plural( day, "день", "дня", "дней" )
                                elseif timeLabel >= 3600 then
                                    local hour = math.ceil( timeLabel / 3600 )
                                    timeLabel =  hour .. " " .. plural( hour, "час", "часа", "часов" )
                                elseif timeLabel >= 60 then
                                    local min = math.ceil( timeLabel / 60 )
                                    timeLabel =  min .. " " .. plural( min, "минута", "минуты", "минут" )
                                elseif timeLabel > 0 then
                                    local sec = math.ceil( timeLabel )
                                    timeLabel =  sec .. " " .. plural( sec, "секунда", "секунды", "секунд" )
                                end

                                label:ibData( "text", timeLabel )
                            end

                            ibCreateImage( 132, 15, 16, 18, "img/timer.png", img )
                            local label = ibCreateLabel( 160, 24, 0, 0, "", img, 0xffff965d, nil, nil, "left", "center", ibFonts.bold_18 )
                            :ibTimer( upTimerLabel, 1000, 0 )
                            upTimerLabel( label )
                        end

                        local description = "-"

                        -- FOOD
                        if data.name == "food" and FOOD_DISHES[id] and FOOD_DISHES[id].buffs[data.index] then
                            local buff = FOOD_DISHES[id].buffs[data.index]
                            local descriptions = {
                                "Каллории расходуются\nна " .. buff.duration / 60 .. " мин. дольше",
                                "Восстанавливает\nжизни: " .. ( buff.add_value or "-" ) .. " ед. /" .. ( buff.interval or "-" ) .. " с.",
                                "Восстанавливает\nвыносливость: " .. ( buff.add_value or "-" ) .. " ед. /" .. ( buff.interval or "-" ) .. " с.",
                            }
                            description = descriptions[data.index]

                            -- DISEASE
                        elseif data.name == "disease" and DISEASES_INFO[data.index] then
                            description = "Персонаж болен.\nДиагноз: " .. DISEASES_INFO[data.index].name .. ",\n" .. data.stage .. " стадии"

                            -- DRUG
                        elseif data.name == "drug" then
                            local descriptions = {
                                "Регенерация 5 HP /5 с.,\n-5% получения урона",
                                "Регенерация 6 HP /5 с.,\n-10% получения урона",
                                "Регенерация 7 HP /5 с.,\n-15% получения урона",
                            }
                            description = descriptions[data.id]

                            -- ALCOHOL
                        elseif data.name == "alco" then
                            local descriptions = {
                                "Алкогольное опьянение.\nЛёгкий эффект",
                                "Алкогольное опьянение.\nСредний эффект",
                                "Алкогольное опьянение.\nСильный эффект",
                                "Алкогольное опьянение.\nОчень сильный эффект",
                            }
                            description = descriptions[data.id]

                            -- DOUBLE EXP
                        elseif data.name == "exp" then
                            description = "Увеличен опыт\nна работах в 2 раза"

                            -- DOUBLE SOFT
                        elseif data.name == "soft" then
                            description = "Увеличена ЗП\nна работах в 2 раза"

                            -- PARTNER
                        elseif data.name == "partner" then
                            description = "Ваш партнёр рядом,\nувеличен получаемый\nопыт на 20%"

                            -- PREMIUM
                        elseif data.name == "premium" then
                            description = "Увеличено количество\nполучаемого опыта\nна работах в 2 раза"

                            -- JOB PARTNER
                        elseif data.name == "job_partner" then
                            description = "Повышение награды\nна 25% за совместную\nработу"

                            -- HIDE NICKNAME
                        elseif data.name == "hide_nickname" then
                            description = "Ваш ник скрыт от\nдругих игроков и\nобнаружения спутником"

                            -- ORDERS
                        elseif data.name == "order1" then
                            description = "За вашу голову\nобъявлена награда"

                        elseif data.name == "order2" then
                            description = "За вашу поимку\nобъявлена награда"

                        elseif data.name == "clan_buff" then
                            local upgrade_conf = CLAN_UPGRADES_LIST[ data.id ]
                            local lvl_conf = upgrade_conf[ data.lvl ]
                            img:ibData( "texture", "img/buffs/" .. ( upgrade_conf.img or upgrade_conf.key ) .. ".png" )

                            description = ( lvl_conf.desc or upgrade_conf.desc ):format( data.buff_value )
                        end

                        ibCreateLabel( 130, yOfDesc, 175, 0, description, img, 0xaaffffff, nil, nil, "left", "center", ibFonts.regular_14 )
                            :ibData( "wordbreak", true )

                        index = index + 1
                    end
                end
            end

            updated = true
        end, 100, 4 )

        -- update data
        if not data.buffs then
            updateData( "buffs" )
        end
    end,

    achievements = function ( state, window, animOffset )
        if not setStateComponent( ui.achievements, state ) then
            if isElement( ui.achievements ) then ui.achievements:ibMoveTo( animOffset, nil, 250 ) end
            return
        end

        ui.achievements = ibCreateRenderTarget( animOffset, 155, 1024, 615, window ):ibData( "alpha", 0 )
        :ibAlphaTo( 255, 250 )
        :ibMoveTo( 0, nil, 250 )

        ibCreateImage( 0, 0, 1024, 275, "img/bg_achievements.png", ui.achievements )
        ibCreateImage( 30, 15, 26, 26, "img/icon_achievements.png", ui.achievements )
        ibCreateLabel( 68, 15, 1024, 30, "Полученные достижения", ui.achievements, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_16 )

        ibCreateButton( 892, 20, 102, 13, ui.achievements, "img/btn_share_achievements.png" )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            components.share_achievements( true, ui.achievements )
        end )

        local achieve_list = localPlayer:getData( "achievements_list" ) or { }
        local counter = 0
        local list_is_open = false

        for id in pairs( achieve_list ) do
            counter = counter + 1
        end

        -- my achievements
        local function switchAchievementList( need_state )
            list_is_open = need_state -- switch state

            if isElement( ui.hide_my_achiev ) then ui.hide_my_achiev:destroy( ) end
            if isElement( ui.scrollpane_m ) then ui.scrollpane_m:destroy( ) end
            if isElement( ui.scrollbar_m ) then ui.scrollbar_m:destroy( ) end

            if list_is_open then
                ui.scrollpane_m, ui.scrollbar_m = ibCreateScrollpane( 0, 55, 1024, list_is_open and 370 or 130, ui.achievements, { scroll_px = - 20, bg_color = 0x00FFFFFF  } )
                ui.scrollbar_m:ibSetStyle( "slim_small_nobg" ):ibData( "absolute", true ):ibData( "sensivity", 50 )
            else
                ui.scrollpane_m = ibCreateArea( 0, 55, 0, 0, ui.achievements )
            end

            local index = 0
            for idx, v in pairs( ACHIEVEMENTS_SORTED ) do
                if achieve_list[ v.id ] then
                    -- show all
                    if not list_is_open and counter > 3 and index == 2 then
                        local line = math.floor( index / 3 )
                        local a_bg = ibCreateImage( 30 + index * 328 - line * 328 * 3, line * 130, 308, 110, "img/achievement3.png", ui.scrollpane_m )
                        :ibData( "alpha", 180 )

                        ibCreateLabel( 0, 42, 308, 0, "+" .. counter - 2, a_bg, nil, nil, nil, "center", "center", ibFonts.bold_40 )
                        ibCreateLabel( 0, 76, 308, 0, "Посмотреть все ачивки", a_bg, nil, nil, nil, "center", "center", ibFonts.regular_14 )

                        ibCreateArea( 0, 0, 308, 110, a_bg )
                        :ibOnHover( function ( )
                            a_bg:ibAlphaTo( 255, 250 )
                        end )
                        :ibOnLeave( function ( )
                            a_bg:ibAlphaTo( 200, 250 )
                        end )
                        :ibOnClick( function ( key, state )
                            if key ~= "left" or state ~= "up" then return end

                            ibOverlaySound( )
                            switchAchievementList( true )
                        end )

                        index = index + 1
                    end

                    local line = math.floor( index / 3 )
                    local px = 30 + index * 328 - line * 328 * 3
                    local py = line * 130

                    -- achievement
                    if index < 2 and not list_is_open then
                        components.achievement( ui.scrollpane_m, px, py, v.id, true )
                    elseif list_is_open then
                        ui.scrollpane_m:ibTimer( function ( )
                            components.achievement( ui.scrollpane_m, px, py, v.id, true )

                            ui.scrollpane_m:AdaptHeightToContents( )
                            ui.scrollbar_m:UpdateScrollbarVisibility( ui.scrollpane_m )
                        end, index * 30, 1 )
                    end

                    index = index + 1
                end
            end

            if list_is_open then
                ui.tab_all_achiev:ibMoveTo( nil, 490, 150 )

                -- hide
                ui.hide_my_achiev = ibCreateButton( 0, 435, 108, 42, ui.achievements, "img/btn_hide.png", nil, nil, 0xaaffffff, 0xffffffff, 0xffffffff )
                :center_x( ):ibData( "alpha", 0 ):ibAlphaTo( 255, 300 ):ibOnClick( function ( key, state )
                    if key ~= "left" or state ~= "up" then return end

                    ibClick( )
                    switchAchievementList( false )
                end )
            elseif isElement( ui.tab_all_achiev ) then
                ui.tab_all_achiev:ibMoveTo( nil, 190, 150 )
            end
        end

        switchAchievementList( false )

        -- all achievements
        ui.tab_all_achiev = ibCreateArea( 0, 190, 0, 0, ui.achievements )
        ibCreateImage( 0, -62, 1024, 319, "img/bg_achievements_all.png", ui.tab_all_achiev )
        ibCreateImage( 30, 18, 36, 26, "img/icon_achievements_all.png", ui.tab_all_achiev )
        ibCreateLabel( 77, 20, 1024, 30, "Все достижения", ui.tab_all_achiev, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_16 )

        ui.scrollpane_a, ui.scrollbar_a = ibCreateScrollpane( 0, 64, 1024, 361, ui.tab_all_achiev, { scroll_px = - 20, bg_color = 0x00FFFFFF  } )
        ui.scrollbar_a:ibSetStyle( "slim_small_nobg" ):ibData( "absolute", true ):ibData( "sensivity", 50 )

        local index = 1
        local total_counter = 0
        for i, v in pairs( ACHIEVEMENTS_SORTED ) do
            if not achieve_list[ v.id ] then
                local line = math.floor( ( index - 1 ) / 3 )
                local px = 30 + ( index - 1 ) * 328 - line * 328 * 3
                local py = line * 130

                ui.scrollpane_a:ibTimer( function ( )
                    if px == 30 then
                        ibCreateArea( 0, line * 130, 0, 130, ui.scrollpane_a )
                    end

                    components.achievement( ui.scrollpane_a, px, py, v.id, false )

                    ui.scrollpane_a:AdaptHeightToContents( )
                    ui.scrollbar_a:UpdateScrollbarVisibility( ui.scrollpane_a )
                end, index * 30, 1 )

                index = index + 1
            end

            total_counter = total_counter + 1
        end

        local c = ibApplyAlpha( 0xffffffff, 75 )
        local lbl_t = ibCreateLabel( 1024 - 30, 31, 0, 0, "/ " .. total_counter, ui.tab_all_achiev, c, nil, nil, "right", "center", ibFonts.regular_14 )
        local lbl_c = ibCreateLabel( 989 - lbl_t:width( ), 30, 0, 0, counter, ui.tab_all_achiev, nil, nil, nil, "right", "center", ibFonts.bold_16 )
        ibCreateLabel( 984 - lbl_t:width( ) - lbl_c:width( ), 31, 0, 0, "Получено достижений:", ui.tab_all_achiev, c, nil, nil, "right", "center", ibFonts.regular_14 )
    end,

    windowStats = function ( state )
        if not setStateComponent( ui.bgStats, state ) then return else end

        -- load images
        loadMenu( )

        -- background
        ui.bgStats = ibCreateBackground( nil, function()
            setStateComponent( ui.bgStats, false )
        end, true, true )
        :ibData( "alpha", 0 ):ibAlphaTo( 255, 250 ):ibOnDestroy( unloadMenu )

        -- window
        local window = ibCreateImage( 0, 0, 1024, 770, tex.main_bg, ui.bgStats ):center( )

        -- close button
        ibCreateButton( 960, 30, 30, 30, window, ":nrp_shared/img/confirm_btn_close.png", nil, nil, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            setStateComponent( ui.bgStats, false )
        end )
        :ibData( "priority", 1 )

        -- header
        ibCreateLabel( 30, 30, 0, 0, "Имущество", window, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_20 )

        -- property stats
        components.panels( window, 30, 124, nil, "statistic_other_player", { "property", "car", "house", "skin", "accessory", "business", "moto", "airplane", "vessel", } )

        -- hide
        ibCreateButton( 459, 702, 108, 42, window, "img/btn_hide.png", nil, nil, 0xaaffffff, 0xffffffff, 0xffffffff )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            setStateComponent( ui.bgStats, false )
        end )

        -- sync cursor
        syncCursor( ui.bgStats, true )
    end,

    windowAchievements = function ( state, nickname )
        if not setStateComponent( ui.windowAchievements, state ) then return else end

        -- load images
        loadMenu( )

        -- background
        ui.windowAchievements = ibCreateBackground( nil, function()
            setStateComponent( ui.windowAchievements, false )
        end, true, true )
        :ibData( "alpha", 0 ):ibAlphaTo( 255, 250 ):ibOnDestroy( unloadMenu )

        -- window
        local window = ibCreateImage( 0, 0, 1024, 770, tex.main_bg, ui.windowAchievements ):center( )

        -- close button
        ibCreateButton( 960, 30, 30, 30, window, ":nrp_shared/img/confirm_btn_close.png", nil, nil, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            setStateComponent( ui.windowAchievements, false )
        end )
        :ibData( "priority", 1 )

        -- header
        ibCreateLabel( 30, 30, 0, 0, "Достижения", window, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_20 )

        ibCreateImage( 0, 91, 1024, 275, "img/bg_achievements.png", window )
        ibCreateImage( 30, 110, 26, 26, "img/icon_achievements.png", window )
        ibCreateLabel( 68, 112, 0, 0, "Полученные достижения", window, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_16 )

        local lbl_nick = ibCreateLabel( 994, 112, 0, 0, nickname, window, 0xffffffff, nil, nil, "right", "top", ibFonts.bold_14 )
        ibCreateLabel( 994 - lbl_nick:width( ) - 5, 112, 0, 0, "Все достижения:", window, 0xffffffff, nil, nil, "right", "top", ibFonts.regular_14 )

        -- achievements list
        local function updateList( achievements_list )
            local index = 1
            for i, v in pairs( ACHIEVEMENTS_SORTED ) do
                if achievements_list[ v.id ] then
                    local line = math.floor( ( index - 1 ) / 3 )
                    local px = 30 + ( index - 1 ) * 328 - line * 328 * 3
                    local py = line * 130

                    ui.scrollpane_o:ibTimer( function ( )
                        if px == 30 then
                            ibCreateArea( 0, line * 130, 0, 130, ui.scrollpane_o )
                        end

                        components.achievement( ui.scrollpane_o, px, py, v.id, true )

                        ui.scrollpane_o:AdaptHeightToContents( )
                        ui.scrollbar_o:UpdateScrollbarVisibility( ui.scrollpane_o )
                    end, index * 30, 1 )

                    index = index + 1
                end
            end
        end

        ui.scrollpane_o, ui.scrollbar_o = ibCreateScrollpane( 0, 157, 1024, 613, window, { scroll_px = - 20, bg_color = 0x00FFFFFF  } )
        ui.scrollbar_o:ibSetStyle( "slim_small_nobg" ):ibData( "absolute", true ):ibData( "sensivity", 50 )
        :ibTimer( function ( )
            if data.achievements_other_player then
                updateList( data.achievements_other_player )
                data.achievements_other_player = nil
            end
        end, 50, 0 )

        -- sync cursor
        syncCursor( ui.windowAchievements, true )
    end,

    windowDonation = function ( state )
        if not setStateComponent( ui.bgDonation, state ) then return else end

        -- load imgs
        loadMenu( )

        -- background
        ui.bgDonation = ibCreateBackground( nil, function()
            setStateComponent( ui.bgDonation, false )
        end, true, true )
        :ibData( "alpha", 0 ):ibAlphaTo( 255, 250 ):ibOnDestroy( unloadMenu )

        -- window
        local window = ibCreateImage( 0, 0, 1024, 770, tex.main_bg, ui.bgDonation ):center( )

        -- close button
        ibCreateButton( 960, 30, 30, 30, window, ":nrp_shared/img/confirm_btn_close.png", nil, nil, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            setStateComponent( ui.bgDonation, false )
        end )
        :ibData( "priority", 1 )

        -- header
        ibCreateLabel( 30, 30, 0, 0, "Пожертвования", window, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_20 )

        -- law
        components.law( window, 0, 113 )

        -- donation up & down
        local function hoverBG( bg )
            if bg:ibData( "selected" ) then return end
            bg:ibData( "texture", "img/donate_bg_s.png" )
        end

        local function leaveBG( bg )
            if bg:ibData( "selected" ) then return end
            bg:ibData( "texture", "img/donate_bg_u.png" )
        end

        local direction = nil

        local socialDownBG = ibCreateImage( 30, 347, 472, 334, "img/donate_bg_u.png", window, 0xffffffff )
        local socialUpBG = ibCreateImage( 522, 347, 472, 334, "img/donate_bg_u.png", window, 0xffffffff )

        ibCreateImage( 0, 0, 472, 334, "img/social_down.png", socialDownBG, 0xffffffff )
        ibCreateImage( 0, 0, 472, 334, "img/social_up.png", socialUpBG, 0xffffffff )

        ibCreateArea( 0, 0, 472, 334, socialDownBG )
        :ibOnHover( function ( ) hoverBG( socialDownBG ) end )
        :ibOnLeave( function ( ) leaveBG( socialDownBG ) end )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            direction = false
            socialUpBG:ibData( "selected", false )
            leaveBG( socialUpBG )
            socialDownBG:ibData( "selected", true )
            ibClick( )
        end )

        ibCreateArea( 0, 0, 472, 334, socialUpBG )
        :ibOnHover( function ( ) hoverBG( socialUpBG ) end )
        :ibOnLeave( function ( ) leaveBG( socialUpBG ) end )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            direction = true
            socialDownBG:ibData( "selected", false )
            leaveBG( socialDownBG )
            socialUpBG:ibData( "selected", true )
            ibClick( )
        end )

        -- edit
        local edit_bg = ibCreateImage( 30, 700, 791, 38, "img/edit_bg3.png", window )
        local edit = ibCreateWebEdit( 30, 0, 730, 38, "", edit_bg, 0x80ffffff, 0 )
        :ibBatchData( { max_length = 24, placeholder = "Введите сумму", font = "regular_11_200", placeholder_color = "0xaaffffff", focus = true } )

        local currentValue = nil

        local info = ibCreateImage( 750, 9, 19, 19, nil, edit_bg )
        info:ibOnHover( function ( )
            if info:ibData( "color" ) == 0 then return end
            info:ibData( "color", "0xaaffffff" )
        end )
        info:ibOnLeave( function ( )
            if info:ibData( "color" ) == 0 then return end
            info:ibData( "color", "0xffffffff" )
        end )
        info:ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" or info:ibData( "color" ) == 0 then return end
            ibClick( )
            triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, 2 )
        end )

        local info2 = ibCreateLabel( 0, 0, 0, 37, "", edit_bg,0xaaffffff, nil, nil, "right", "center", ibFonts.regular_14 )

        local function event( )
            local value = edit:ibData( "text" )

            if currentValue == value then
                return
            else
                currentValue = value:match( "%d+" ) or ""
                edit:ibData( "text", tonumber( currentValue ) and tostring( tonumber( currentValue ) ) or currentValue )
            end

            local digit = tonumber( currentValue )
            if digit then
                if digit > localPlayer:GetMoney( ) then
                    info2:ibBatchData( { px = 635, text = "На вашем счете недостаточно средств -", color = "0xaaffffff" } )
                    info:ibBatchData( { px = 640, py = 13, sx = 130, sy = 13, texture = "img/btn_cashup.png", color = "0xffffffff" } )
                else
                    local rating = math.floor( digit / CONVERT_CASH_TO_RATING )
                    local price = format_price( rating * CONVERT_CASH_TO_RATING )

                    if rating == 0 then
                        info2:ibBatchData( { px = 740, text = "Сумма должна быть от " .. format_price( CONVERT_CASH_TO_RATING ), color = "0xaaffffff" } )
                        info:ibBatchData( { px = 750, py = 9, sx = 19, sy = 19, texture = ":nrp_shared/img/money_icon.png", color = "0xffffffff" } )
                    else
                        info2:ibBatchData( { px = 740, text = "Сумма " .. rating .. " ед. рейтинга = " .. price, color = "0xaaffffff" } )
                        info:ibBatchData( { px = 750, py = 9, sx = 19, sy = 19, texture = ":nrp_shared/img/money_icon.png", color = "0xffffffff" } )
                    end
                end
            else
                info2:ibBatchData( { px = 740, text = "Сумма 1 ед. рейтинга = 5 000", color = "0xaaffffff" } )
                info:ibBatchData( { px = 750, py = 9, sx = 19, sy = 19, texture = ":nrp_shared/img/money_icon.png", color = "0xffffffff" } )
            end
        end

        addEventHandler( "onClientKey", root, event )
        info2:ibOnDestroy( function ( ) removeEventHandler( "onClientKey", root, event ) end )
        
        -- donate
        ibCreateButton( 843, 700, 151, 38, window, "img/btn_donate.png", nil, nil, 0xaaffffff, 0xffffffff, 0xffffffff )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            if direction == nil then
                localPlayer:ShowError( "Повышать или понижать\nбудем рейтинг?" )
                return
            end

            ibClick( )

            local amount = tonumber( edit:ibData( "text" ) )
            if not amount or amount < CONVERT_CASH_TO_RATING then return end

            if amount > localPlayer:GetMoney( ) then return end

            local rating = math.floor( amount / CONVERT_CASH_TO_RATING )
            local price = rating * CONVERT_CASH_TO_RATING
            local dir = direction and "+" or "-"
            local description = ""

            if data.available_rating <= 0 then
                updateData( "sendDonate", 0 ) -- get info
                return
            end

            if rating > data.available_rating then
                rating = data.available_rating
                price = rating * CONVERT_CASH_TO_RATING

                description = "За один день можно изменить только " .. AVAILABLE_RATING_DONATE .. " ед. рейтинга."
                description = description .. "\nЖелаешь получить оставшиеся " .. dir .. rating .. " ед. за " .. format_price( price ) .. " рублей?"
            else
                description = "Ты точно желаешь изменить свой рейтинг?"
                description = description .. "\nЦена вопроса: " .. dir .. rating .. " ед. рейтинга за " .. format_price( price ) .. " рублей?"
            end

            if price > localPlayer:GetMoney( ) then return end

            ibConfirm( {
                title = "ОПЛАТА",
                text = description,
                fn = function ( self )
                    self:destroy( )
                    edit:ibData( "text", "" )
                    updateData( "sendDonate", rating, direction )
                end,
                escape_close = true,
            } )
        end )

        -- update data
        updateData( "social_rating" )
        updateData( "available_rating" )

        -- sync cursor
        syncCursor( ui.bgDonation, true )
    end,

    -- non singleton ui components

    achievement = function ( parent, x, y, id, got )
        local achievement = ACHIEVEMENTS[ id ]
        local bg_tex = got and tex.achievement or tex.achievement2
        local bg_tex2 = got and tex.achievement_s or tex.achievement_s2

        local bg = ibCreateImage( x, y, 308, 110, bg_tex, parent )
        :ibData( "alpha", 0 ):ibAlphaTo( 255, 100 )

        ibCreateImage( 10, 15, 80, 80, bg_tex2, bg )
        local icon = ibCreateContentImage( 10, 15, 80, 80, "achievement", id, bg )

        if not got then
            icon:ibData( "alpha", 50 )
        end

        ibCreateLabel( 105, 24, 0, 0, achievement.name, bg, nil, nil, nil, nil, "center", ibFonts.bold_12 )
        ibCreateLabel( 105, 55, 190, 0, achievement.description, bg, nil, nil, nil, nil, "center", ibFonts.regular_11 )
        :ibData( "wordbreak", true )

        local area = ibCreateArea( 0, 0, 308, 110, bg )
        :ibOnHover( function ( )
            icon:ibData( "rotation", 0 )
            icon:ibRotateTo( 360, 500 )
        end )

        if achievement.tooltip then
            area:ibAttachTooltip( achievement.tooltip )
        end
    end,

    panels = function ( window, x, y, title, dataName, names )
        if title then
            ibCreateLabel( x, y, 1024, 30, title, window, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_18 )
        end

        local index = 0
        for _, name in ipairs( names ) do
            local line = math.floor( index / 3 )

            local img = ibCreateImage( x + index * 328 - line * 328 * 3, y + ( title and 45 or 0 ) + line * 130, 308, 110, "img/stats/" .. name .. ".png", window )
            ibCreateLabel( 141, 32, 0, 0, "-", img, 0xffffffff, nil, nil, "left", "center", ibFonts.bold_16 )
            :ibTimer( function ( self )
                if not data[dataName] or not data[dataName][name] then return end

                local value = data[dataName][name]
                value = tonumber( value ) and format_price( value ) or value

                self:ibData( "text", value )
            end, 250, 0 )

            index = index + 1
        end
    end,

    law = function ( window, x, y, show_anchor )
        local rating = nil

        local law = ibCreateImage( x, y, 1024, 269, tex.law_bg, window, 0xffffffff )
        local progress = ibCreateImage( 164, 110, 700, 27, tex.progress, law )

        local bg_anchor, anchor_lower_limit, anchor_higher_limit

        if show_anchor and not localPlayer:IsPremiumActive( ) then
            local tooltip = [[
Это границы рейтинга.
Обознаюащие, что за их пределы
рейтинг упасть или подняться
не может. Границы обновляются
в зависимости от самого рейтинга.
]]

            bg_anchor = ibCreateImage( 360, 0, 229, 50, "img/bg_anchor.png", progress ):center_y( )
            :ibAttachTooltip( tooltip )
            
            ibCreateImage( 229/2-33, 0, 2, 50, _, bg_anchor, 0x88ffffff ):ibData( "disabled", true )
            ibCreateImage( 229/2+72, 0, 2, 50, _, bg_anchor, 0x88ffffff ):ibData( "disabled", true )

            anchor_lower_limit = ibCreateLabel( 229/2-33, -14, 2, 0, "-200", bg_anchor, _, _, _, "center", "center", ibFonts.regular_14 ):ibData( "alpha", 0.4*255 )
            anchor_higher_limit = ibCreateLabel( 229/2+72, -14, 2, 0, "100", bg_anchor, _, _, _, "center", "center", ibFonts.regular_14 ):ibData( "alpha", 0.4*255 )
        end


        local pos = ibCreateImage( 350, - 6, 3, 40, nil, progress, 0xffffffff )
        :ibData( "disabled", true )
        :ibData( "alpha", 255*0.7 )

        local ratingName = ibCreateLabel( 0, 22, 1024, 30, "", law, 0xffffffff, nil, nil, "center", "top", ibFonts.bold_18 )
        ibCreateLabel( 0, 50, 1024, 30, "Ваш социальный рейтинг:", law, 0xffffffff, nil, nil, "center", "top", ibFonts.regular_16 )
        local l_rating = ibCreateLabel( 620, 50, 0, 30, "", law, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_16 )

        local delta = GetSocialRatingDelta()
        local l_delta = ibCreateLabel( l_rating:ibGetAfterX( 8 ), 50, 0, 30, delta, law,
            delta > 0 and 0xff8dff6f or 0xffe73f5e, nil, nil, "left", "top", ibFonts.regular_16 )
        :ibData( "alpha", delta ~= 0 and 255 or 0 )

        local icon_delta = ibCreateImage( l_delta:ibGetAfterX( 6 ), 56, 11, 8, 
                delta > 0 and "img/icon_rating_up.png" or "img/icon_rating_down.png", law )
        :ibData( "alpha", delta ~= 0 and 255 or 0 )

        l_rating:ibTimer( function ( self )
            if rating and rating == ( data.social_rating or 0 ) then return
            else rating = data.social_rating or 0 end

            local function findName( )
                local name = ""
                local lv = 0
                for _, data in pairs( RATING_NAMES ) do
                    if ( rating >= 0 and rating >= data.value and data.value >= lv)
                    or ( rating < 0 and rating <= data.value and data.value <= lv) then
                        name = data.name
                        lv = data.value
                    end
                end
                return name
            end

            ratingName:ibData( "text", findName( ) )
            self:ibData( "text", rating )
            pos:ibData( "px", 350 + rating / 100 * 350 / 10 )
            l_delta:ibData( "px", self:ibGetAfterX( 8 ) )
            icon_delta:ibData( "px", l_delta:ibGetAfterX( 6 ) )

            if isElement( bg_anchor ) then
                local rating_anchor = localPlayer:getData( "social_rating_anchor" ) or rating or 0
                local px = Clamp( -50, ( 350 + rating_anchor / 100 * 350 / 10 ) - 229*0.66, 700-196 )
                bg_anchor:ibData( "px", px )
                anchor_lower_limit:ibData( "text", Clamp( -1000, rating_anchor-200, 1000 ) )
                anchor_higher_limit:ibData( "text", Clamp( -1000, rating_anchor+100, 1000 ) )
            end
        end, 50, 0 )
    end
}
