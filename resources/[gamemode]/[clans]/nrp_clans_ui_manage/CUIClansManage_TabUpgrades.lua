TABS_CONF.upgrades = {
    fn_create = function( self, parent )
        local upgrade_blocks_create_fns = {
            -- Хранилище
            function( parent )
                local bg_info = ibCreateImage( 30, 267, 963, 235, "img/upgrades/1/bg_info.png", parent )
                local upgrade_id = CLAN_UPGRADE_STORAGE
                local upgrade_conf = CLAN_UPGRADES_LIST[ upgrade_id ]

                local area_buy
                UI.UpdateStorageUpgrade = function( )
                    if isElement( area_buy ) then area_buy:destroy( ) end

                    local upgrade_next_level = ( CLAN_DATA.upgrades[ upgrade_id ] or 0 ) + 1
                    if upgrade_conf[ upgrade_next_level ] then
                        area_buy = ibCreateArea( 0, bg_info:height( ) + 28, 154, 42, bg_info )
                            local cost = upgrade_conf[ upgrade_next_level ].cost
                            local lbl_cost_text = ibCreateLabel( 0, 0, 0, 42, "Стоимость: ", area_buy, COLOR_WHITE, 1, 1, "left", "center", ibFonts.regular_16 )
                            local lbl_cost = ibCreateLabel( lbl_cost_text:ibGetAfterX( ), -1, 0, 42, format_price( cost ), area_buy, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_20 )
                            local img_cost = ibCreateImage( lbl_cost:ibGetAfterX( 8 ), 0, 24, 24, ":nrp_shared/img/money_icon.png", area_buy ):center_y( )
                            local btn_buy = ibCreateButton( img_cost:ibGetAfterX( 20 ), 0, 154, 42, area_buy, "img/upgrades/1/btn_buy.png", "img/upgrades/1/btn_buy_hover.png", "img/upgrades/1/btn_buy_hover.png", _, _, 0xFFAAAAAA )
                                :ibOnClick( function( key, state )
                                    if key ~= "left" or state ~= "up" then return end
                                    ibClick( )
                                    
                                    ConfirmUpgrade( upgrade_id, cost )
                                end )
                        area_buy:ibData( "sx", btn_buy:ibGetAfterX( ) ):center_x( )
                    end
                end
                UI.UpdateStorageUpgrade( )
                
                return bg_info
            end,
            
            -- Алко и хеш цеха
            function( parent )
                local bg_info = ibCreateImage( 30, 267, 963, 317, "img/upgrades/2/bg_info.png", parent )

                local function create_upgrade_button( upgrade_id, px, py )
                    local upgrade_conf = CLAN_UPGRADES_LIST[ upgrade_id ]
                    local upgrade_next_level = ( CLAN_DATA.upgrades[ upgrade_id ] or 0 ) + 1
                    local btn_color = { 0xFF7295bc, 0xFF7fa5d0, 0xFF597391 }
                    local btn_text = utf8.upper( upgrade_conf.name )
                    -- if upgrade_next_level > 1 then
                    --     btn_color = { 0xFF38c175, 0xFF3ee589, 0xFF2ba060 }
                    -- end
                    local btn = ibCreateButton( px, py, 314, 51, bg_info, "img/upgrades/2/btn.png", _, _, unpack( btn_color ) )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            ShowFactoryUpgradeOverlay( parent, upgrade_id )
                        end )
                    ibCreateLabel( 0, 0, 0, 0, btn_text, btn, _,_,_, "center", "center", ibFonts.bold_18 ):center( )
                end
                create_upgrade_button( CLAN_UPGRADE_ALCO_FACTORY, 592, 104 )
                create_upgrade_button( CLAN_UPGRADE_HASH_FACTORY, 592, 175 )

                return bg_info
            end,

            -- Тематика клана
            function( parent )
                local bg_info = ibCreateImage( 30, 267, 963, 322, "img/upgrades/3/bg_info.png", parent )

                for way, way_name in pairs( CLAN_WAY_NAMES ) do
                    ibCreateLabel( 160 + ( way - 1 ) * 327, 32, 0, 0, way_name, bg_info, _,_,_, "center", "center", ibFonts.bold_18 )

                    local btn_url = "img/upgrades/3/btn_details"
                    if CLAN_DATA.way == way then
                        btn_url = "img/upgrades/3/btn_upgrades"
                        ibCreateLabel( 160 + ( way - 1 ) * 327, 68, 0, 0, "Выбрано", bg_info, 0xFF38c175, 1, 1, "center", "center", ibFonts.regular_16 )
                            :ibData( "outline", 1 )
                    end
                    ibCreateButton( 65 + ( way - 1 ) * 327, bg_info:height( ) - 30 - 40, 190, 40, bg_info, btn_url .. ".png", btn_url .. "_h.png", btn_url .. "_h.png", _, _, 0xFFAAAAAA )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )

                            ShowBuffUpgradesOverlay( parent, way )
                        end )
                end
                
                return bg_info
            end,
        }

        local area
        local selected_block_i = 1

        function UpdateUpgradesTab( )
            if isElement( area ) then
                area:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
            end

            area = ibCreateArea( 0, 0, parent:width( ), parent:height( ), parent )

            local selected_bg_title
            local selected_bg_upgrade_hover
            local bg_upgrade_info
            local function switch_upgrade_info( block_i )
                selected_block_i = block_i
                if bg_upgrade_info then
                    bg_upgrade_info:ibAlphaTo( 0, 250 ):ibTimer( destroyElement, 250, 1 )
                end
                bg_upgrade_info = upgrade_blocks_create_fns[ block_i ]( area )
                    :ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )
            end

            local block_sx = 308
            local gap = 20
            for i = 1, 3 do
                -- local upgrade_id = upgrade_id_by_block_i[ i ]
                local is_upgrade_unlocked = true --CLAN_DATA.upgrades[ upgrade_id ]
                local is_upgrade_available = true -- ( i == 1 )

                local img_url = "img/upgrades/" .. i .. "/block.png"
                local bg_upgrade = ibCreateImage( 30 + ( block_sx + gap ) * ( i - 1 ), 30, block_sx, 219, img_url, area )
                local bg_upgrade_hover = ibCreateImage( 0, 0, block_sx, 219, "img/upgrades/bg_upgrade_hover.png", bg_upgrade )
                    :ibData( "disabled", true )
                    :ibData( "alpha", i == selected_block_i and 255 or 0 )

                local bg_title = ibCreateImage( 0, -10, 193, 50, "img/upgrades/bg_title.png", bg_upgrade, i == selected_block_i and 0xFF7fa5d0 or 0xFF6887aa )
                    :center_x( ):ibData( "disabled", true )
                ibCreateLabel( 0, 0, 0, 0, "УЛУЧШЕНИЕ " .. i, bg_title, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
                    :center( )

                -- local text = is_upgrade_unlocked and "Получено" or is_upgrade_available and "Доступно" or "В разработке"
                -- local lbl_info = ibCreateLabel( 0, 180, 0, 0, text, bg_upgrade, COLOR_WHITE, 1, 1, "center", "top", ibFonts.regular_12 )
                --     :center_x( )
                -- if is_upgrade_unlocked then
                --     ibCreateImage( lbl_info:ibGetBeforeX( -7 - 12 ), 182, 14, 12, "img/upgrades/icon_unlocked.png", bg_upgrade )
                -- end

                if is_upgrade_available then
                    bg_upgrade
                        :ibOnHover( function( ) bg_upgrade_hover:ibAlphaTo( i == selected_block_i and 255 or 150 ) end )
                        :ibOnLeave( function( ) bg_upgrade_hover:ibAlphaTo( i == selected_block_i and 255 or 0 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" or i == selected_block_i then return end
                            ibClick( )
                            selected_bg_title:ibData( "color", 0xFF6887aa )
                            selected_bg_title = bg_title:ibData( "color", 0xFF7fa5d0 )
                            selected_bg_upgrade_hover:ibAlphaTo( 0 )
                            selected_bg_upgrade_hover = bg_upgrade_hover:ibAlphaTo( 255 )
                            switch_upgrade_info( i )
                        end )
                end

                if i == selected_block_i then
                    selected_bg_title = bg_title
                    selected_bg_upgrade_hover = bg_upgrade_hover
                    switch_upgrade_info( selected_block_i )
                end
            end
        end
        UpdateUpgradesTab( )
    end,
}

function ShowFactoryUpgradeOverlay( parent, upgrade_id )
    if isElement( UI.bg_overlay ) then
        UI.bg_overlay
            :ibMoveTo( _, UI.bg_overlay:height( ), 200 )
            :ibTimer( destroyElement, 200, 1 )
    end
    if not parent then return end

    ibOverlaySound( )
    
    local navbar_sy = UI.tab_panel.navbar.sy
    local bg_overlay = ibCreateImage( 0, parent:height( ) + navbar_sy, parent:width( ), parent:height( ) + navbar_sy, _, parent, ibApplyAlpha( 0xff1f2934, 95 ) )
        :ibData( "priority", 2 )
        :ibMoveTo( 0, -navbar_sy, 250 )
    UI.bg_overlay = bg_overlay

    local btn_back = ibCreateButton( 30, 79, 73, 20, bg_overlay, "img/upgrades/btn_back.png", _, _, 0x9FFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibData( "priority", 1 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowFactoryUpgradeOverlay( false )
        end )
    
    local area_upgrade

    function UpdateFactoryUpgradesOverlay( )
        if isElement( area_upgrade ) then
            area_upgrade:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
        elseif area_upgrade ~= nil then
            return
        end

        area_upgrade = ibCreateArea( 0, 0, bg_overlay:width( ), bg_overlay:height( ), bg_overlay )
            
        local upgrade_conf = CLAN_UPGRADES_LIST[ upgrade_id ]
        local upgrade_lvl = CLAN_DATA.upgrades[ upgrade_id ] or 0

        local name = upgrade_conf.name .. ( upgrade_lvl > 0 and (" " .. upgrade_lvl .. " ур.") or "" )
        ibCreateLabel( 0, 88, 0, 0, name, area_upgrade, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_18 ):center_x( )
        ibCreateImage( 30, 119, 0, 0, "img/upgrades/2/overlay/info_" .. upgrade_conf.key .. ".png", area_upgrade ):ibSetRealSize( )

        if upgrade_conf[ upgrade_lvl + 1 ] then
            local area_buy = ibCreateArea( 0, area_upgrade:height( ) - 82, 0, 46, area_upgrade )
            local cost = upgrade_conf[ upgrade_lvl + 1 ].cost
            local lbl_cost_text = ibCreateLabel( 0, 0, 0, 46, "Стоимость: ", area_buy, ibApplyAlpha( COLOR_WHITE, 75 ), 1, 1, "left", "center", ibFonts.regular_16 )
            local lbl_cost = ibCreateLabel( lbl_cost_text:ibGetAfterX( ), -1, 0, 46, format_price( cost ), area_buy, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_20 )
            local img_cost = ibCreateImage( lbl_cost:ibGetAfterX( 8 ), 0, 24, 24, ":nrp_shared/img/money_icon.png", area_buy ):center_y( )
            local btn_buy = ibCreateButton( img_cost:ibGetAfterX( 20 ), 0, 284, 46, area_buy, "img/upgrades/2/overlay/btn_upgrade.png", _, _, 0xAFffffff, _, 0xFFCCCCCC )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    
                    ConfirmUpgrade( upgrade_id, cost )
                end )
            local text = upgrade_lvl == 0 and utf8.upper( "ПРИОБРЕСТИ " .. upgrade_conf.name ) or ( "УЛУЧШИТЬ ДО " .. ( upgrade_lvl + 1 ) .. " УРОВНЯ" )
            local lbl_lvl = ibCreateLabel( 0, 0, 0, 0, text, btn_buy, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_16 ):center( )
            area_buy:ibData( "sx", btn_buy:ibGetAfterX( ) ):center_x( )
        end
    end
    UpdateFactoryUpgradesOverlay( )
end

function ShowBuffUpgradesOverlay( parent, way )
    if isElement( UI.bg_overlay ) then
        UI.bg_overlay
            :ibMoveTo( _, UI.bg_overlay:height( ), 200 )
            :ibTimer( destroyElement, 200, 1 )
    end
    if not parent then return end

    ibOverlaySound( )
    
    local navbar_sy = UI.tab_panel.navbar.sy
    local bg_overlay = ibCreateImage( 0, parent:height( ) + navbar_sy, parent:width( ), parent:height( ) + navbar_sy, _, parent, ibApplyAlpha( 0xff1f2934, 95 ) )
        :ibData( "priority", 2 )
        :ibMoveTo( 0, -navbar_sy, 250 )
    UI.bg_overlay = bg_overlay

    local btn_back = ibCreateButton( 30, 90, 73, 20, bg_overlay, "img/upgrades/btn_back.png", _, _, 0x9FFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibData( "priority", 1 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowBuffUpgradesOverlay( false )
        end )

    local btn_change_way = ibCreateButton( bg_overlay:width( ) - 30 - 188, 24, 188, 23, bg_overlay, "img/upgrades/3/btn_change_way.png", _, _, 0xBFFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
        :ibData( "alpha", 0 ):ibTimer( ibAlphaTo, 250, 1, 255 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowChangeWayOverlay( parent )
        end )
    
    local scrollpane, scrollbar

    function UpdateBuffUpgradesOverlay( )
        local old_scroll_pos = scrollbar and scrollbar:ibData( "position" ) or 0
        if isElement( scrollpane ) then
            scrollpane:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
            scrollbar:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
        elseif scrollpane ~= nil then
            return
        end

        scrollpane, scrollbar = ibCreateScrollpane( 0, 62, bg_overlay:width( ), bg_overlay:height( ) - 62, bg_overlay, { scroll_px = -20 } )
        scrollbar:ibSetStyle( "slim_nobg" ):ibBatchData( { sensivity = 100, absolute = true } )

        ibCreateLabel( 0, 36, 0, 0, "Путь развития “" .. CLAN_WAY_NAMES[ way ] .. "”", scrollpane, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_18 ):center_x( )
        ibCreateLabel( 0, 36 + 28, 0, 0, "Данные баффы кланов активируются только для игроков от 3 уровня в клане", scrollpane, ibApplyAlpha( COLOR_WHITE, 75 ), 1, 1, "center", "center", ibFonts.regular_14 ):center_x( )

        local UPGRADES_TREE = {
            [ CLAN_WAY_BIKERS ] = {
                {
                    {CLAN_UPGRADE_MAX_HP},
                    {CLAN_UPGRADE_HEALING},
                },
                {
                    {CLAN_UPGRADE_MOTO_DISCOUNT, level = 1},
                },
                {
                    {CLAN_UPGRADE_GROUP_MAX_HP},
                    {CLAN_UPGRADE_HASH_DRYING_TIME},
                },
                {
                    {CLAN_UPGRADE_MOTO_DISCOUNT, level = 2},
                },
                {
                    {CLAN_UPGRADE_MAX_HP_2},
                    {CLAN_UPGRADE_HASH_SALE_COST},
                },
                {
                    {CLAN_UPGRADE_MOTO_DISCOUNT, level = 3},
                },
            },
            [ CLAN_WAY_RACERS ] = {
                {
                    {CLAN_UPGRADE_MAX_STAMINA},
                    {CLAN_UPGRADE_DRUGS_DISCOUNT},
                },
                {
                    {CLAN_UPGRADE_TUNING_DISCOUNT, level = 1},
                },
                {
                    {CLAN_UPGRADE_FIST_DAMAGE},
                    {CLAN_UPGRADE_DISEASE_RESISTANCE},
                },
                {
                    {CLAN_UPGRADE_TUNING_DISCOUNT, level = 2},
                },
                {
                    {CLAN_UPGRADE_MAX_STAMINA_2},
                    {CLAN_UPGRADE_DRUGS_TIME},
                },
                {
                    {CLAN_UPGRADE_TUNING_DISCOUNT, level = 3},
                },
            },
            [ CLAN_WAY_BRATVA ] = {
                {
                    {CLAN_UPGRADE_JAIL_TIME},
                    {CLAN_UPGRADE_SLOW_HUNGER},
                },
                {
                    {CLAN_UPGRADE_WEAPON_DISCOUNT, level = 1},
                },
                {
                    {CLAN_UPGRADE_MAX_HP_AND_STAMINA},
                    {CLAN_UPGRADE_ALCO_FERMENT_TIME},
                },
                {
                    {CLAN_UPGRADE_WEAPON_DISCOUNT, level = 2},
                },
                {
                    {CLAN_UPGRADE_JAIL_TIME_2},
                    {CLAN_UPGRADE_ALCO_SALE_COST},
                },
                {
                    {CLAN_UPGRADE_WEAPON_DISCOUNT, level = 3},
                },
            },
        }

        local py = 94
        local buff_sx, buff_sy = 180, 180
        local is_all_upgrades_completed = ( way == CLAN_DATA.way ) and true
        local upgrades_tree = UPGRADES_TREE[ way ]
        for branch, upgrades in pairs( upgrades_tree ) do
            local is_all_previous_upgrades_completed = is_all_upgrades_completed
            for col, upgrade in pairs( upgrades ) do
                local upgrade_id = upgrade[ 1 ]
                local upgrade_conf = CLAN_UPGRADES_LIST[ upgrade_id ]
                local upgrade_lvl = CLAN_DATA.upgrades[ upgrade_id ] or 0
                local upgrade_max_lvl = upgrade.level or #upgrade_conf
                local lvl_conf = upgrade_conf[ upgrade.level or ( upgrade_lvl + 1 ) ] or upgrade_conf[ upgrade_max_lvl ]
                local is_upgrade_available = is_all_previous_upgrades_completed and upgrade_lvl < upgrade_max_lvl

                local center_ox = #upgrades == 2 and 336 * ( col == 1 and -1 or 1 ) or 0
                local bg_buff = ibCreateImage( 0, py, buff_sx, buff_sy, _, scrollpane, 0xFF48617b ):center_x( center_ox )
                local bg_buff_hover = ibCreateImage( 0, 0, 216, 216, "img/upgrades/3/bg_buff_h.png", bg_buff ):center( ):ibData( "alpha", 0 ):ibData( "disabled", true )
                bg_buff
                    :ibAttachTooltip( ( lvl_conf.desc or upgrade_conf.desc ):format( lvl_conf.buff_value ) )
                    :ibOnHover( function( ) return is_upgrade_available and bg_buff_hover:ibAlphaTo( 255 ) end )
                    :ibOnLeave( function( ) return is_upgrade_available and bg_buff_hover:ibAlphaTo( 0 ) end )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "up" then return end
                        if not is_upgrade_available then return end
                        ibClick( )
                        if upgrade_lvl < upgrade_max_lvl then
                            local cost = lvl_conf.cost
                            ConfirmUpgrade( upgrade_id, cost )
                        end
                    end )
                
                local lbl_name = ibCreateLabel( 0, 19, 0, 0, upgrade_conf.name, bg_buff, COLOR_WHITE, 1, 1, "center", "center", ibFonts.regular_14 ):center_x( )
                
                ibCreateImage( 0, 0, 0, 0, "img/upgrades/3/buffs/" .. ( upgrade_conf.img or upgrade_conf.key ) .. ".png", bg_buff ):ibSetRealSize( ):center( ):ibData( "disabled", true )

                if upgrade_lvl < upgrade_max_lvl then  
                    is_all_upgrades_completed = false

                    local area_buy = ibCreateArea( 0, 155, 0, 0, bg_buff )
                    local cost = lvl_conf.cost
                    local lbl_cost = ibCreateLabel( 0, 0, 0, 0, format_price( cost ), area_buy, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_15 )
                    local img_cost = ibCreateImage( lbl_cost:ibGetAfterX( 8 ), 0, 21, 21, ":nrp_shared/img/money_icon.png", area_buy ):center_y( ):ibData( "disabled", true )
                    area_buy:ibData( "sx", img_cost:ibGetAfterX( ) ):center_x( )
                else
                    lbl_name:center_x( -( -7 - 12 ) / 2 )
                    ibCreateImage( lbl_name:ibGetBeforeX( -5 - 13 ), 12, 14, 12, "img/upgrades/icon_unlocked.png", bg_buff )
                end

                if is_all_previous_upgrades_completed then
                    local progress = upgrade.level and upgrade_lvl < upgrade.level and 0 or math.min( 1, upgrade_lvl / upgrade_max_lvl )
                    local bg_progress = ibCreateImage( 0, buff_sy - 5, buff_sx, 5, _, bg_buff, ibApplyAlpha( COLOR_BLACK, 25 ) ):ibData( "disabled", true )
                    local progressbar = ibCreateImage( 0, buff_sy - 5, buff_sx * progress, 5, _, bg_buff, 0xFF47afff ):ibData( "disabled", true )
                else
                    bg_buff:ibData( "alpha", 128 )
                    lbl_name:center_x( -( -7 - 12 ) / 2 )
                    ibCreateImage( lbl_name:ibGetBeforeX( -5 - 9 ), 13, 9, 12, "img/upgrades/icon_locked.png", bg_buff )
                end
            end
            
            if upgrades_tree[ branch + 1 ] then
                local link_img
                if #upgrades == 2 then
                    link_img = ibCreateImage( 0, py + 180, 0, 0, "img/upgrades/3/link_1_2.png", scrollpane ):ibData( "rotation", 180 )
                elseif #upgrades_tree[ branch + 1 ] == 2 then
                    link_img = ibCreateImage( 0, py + 180, 0, 0, "img/upgrades/3/link_1_2.png", scrollpane )
                else
                    link_img = ibCreateImage( 0, py + 180, 0, 0, "img/upgrades/3/link_1_1.png", scrollpane )
                end
                link_img:ibSetRealSize( ):center_x( )
                py = link_img:ibGetAfterY( )
            end
        end
        scrollpane:ibData( "sy", py + buff_sy + 30 )
        scrollbar:UpdateScrollbarVisibility( scrollpane ):ibData( "position", old_scroll_pos )
    end
    UpdateBuffUpgradesOverlay( )
end

function ShowChangeWayOverlay( parent )
    if isElement( UI.bg_overlay ) then
        UI.bg_overlay
            :ibMoveTo( _, UI.bg_overlay:height( ), 200 )
            :ibTimer( destroyElement, 200, 1 )
    end
    if not parent then return end

    ibOverlaySound( )
    
    local navbar_sy = UI.tab_panel.navbar.sy
    local bg_overlay = ibCreateImage( 0, parent:height( ) + navbar_sy, parent:width( ), parent:height( ) + navbar_sy, _, parent, ibApplyAlpha( 0xff1f2934, 95 ) )
        :ibData( "priority", 2 )
        :ibMoveTo( 0, -navbar_sy, 250 )
    UI.bg_overlay = bg_overlay

    local btn_back = ibCreateButton( 30, 90, 73, 20, bg_overlay, "img/upgrades/btn_back.png", _, _, 0x9FFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibData( "priority", 1 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowChangeWayOverlay( false )
        end )
    
    ibCreateImage( 30, 77, 0, 0, "img/upgrades/3/change_way/blocks.png", bg_overlay ):ibSetRealSize( )

    local col_sx, col_sy = 308, 511
    for i = 1, 3 do
        local area_col = ibCreateArea( 0, 135, col_sx, col_sy, bg_overlay )
            :center_x( 328 * ( i - 2 ) )

        local bg_hover = ibCreateArea( 0, 0, col_sx, col_sy, area_col )
            :ibData( "alpha", 0 )
            :ibOnHover( function() source:ibAlphaTo( 255, 500, "OutQuad" ) end)
            :ibOnLeave( function() source:ibAlphaTo( 0, 500, "OutQuad" ) end)
        ibCreateImage( 0, 0, col_sx, 2, _, bg_hover, 0xFF6996c7 )
        ibCreateImage( 0, 2, 2, col_sy - 2, _, bg_hover, 0xFF6996c7 )
        ibCreateImage( col_sx, 2, -2, col_sy - 2, _, bg_hover, 0xFF6996c7 )
        ibCreateImage( 2, col_sy, col_sx - 4, -2, _, bg_hover, 0xFF6996c7 )

        ibCreateLabel( 30, 239, col_sx - 60, 0, CLAN_WAY_DESCRIPTION[ i ], area_col, ibApplyAlpha( COLOR_WHITE, 75 ), 1, 1, "center", "top", ibFonts.regular_14 )
            :ibData( "wordbreak", true )

        if CLAN_DATA.way == i then
            ibCreateImage( 0, 135, col_sx, col_sy, "img/upgrades/3/change_way/block_selected.png", bg_overlay ):ibData( "priority", -1 )
                :center_x( 328 * ( i - 2 ) )
            ibCreateLabel( 0, col_sy - 72, col_sx, 0, "Выбрано", area_col, 0xFF38c175, 1, 1, "center", "center", ibFonts.regular_16 )
        else
            ibCreateButton( 0, 423, 138, 42, area_col, "img/upgrades/3/change_way/btn_change.png", "img/upgrades/3/change_way/btn_change_h.png", "img/upgrades/3/change_way/btn_change_h.png", _, _, 0xFFAAAAAA )
                :ibSetRealSize( )
                :center_x( )
                :ibOnHover( function() bg_hover:ibAlphaTo( 255, 500, "OutQuad" ) end)
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end
                    if ( CLICK_TIMEOUT or 0 ) > getTickCount( ) then return end
                    CLICK_TIMEOUT = getTickCount( ) + 1000
                    ibClick( )

                    ibConfirm(
                        {
                            title = "ПОДТВЕРЖДЕНИЕ", 
                            text = "Ты точно хочешь сменить путь развития за" ,
                            cost = CLAN_WAY_CHANGE_COST,
                            cost_is_soft = true,
                            fn = function( self )
                                triggerServerEvent( "onPlayerWantChangeClanWay", localPlayer, i )
                                self:destroy()
                            end,
                            escape_close = true,
                        }
                    )
                end )
            
            local area_buy = ibCreateArea( 0, 485, 0, 0, area_col )
            local lbl_cost_text = ibCreateLabel( 0, 0, 0, 0, "Стоимость: ", area_buy, ibApplyAlpha( COLOR_WHITE, 75 ), 1, 1, "left", "center", ibFonts.regular_16 )
            local lbl_cost = ibCreateLabel( lbl_cost_text:ibGetAfterX( ), 0, 0, 0, format_price( CLAN_WAY_CHANGE_COST ), area_buy, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_16 )
            local img_cost = ibCreateImage( lbl_cost:ibGetAfterX( 8 ), 0, 24, 24, ":nrp_shared/img/money_icon.png", area_buy ):center_y( )
            area_buy:ibData( "sx", img_cost:ibGetAfterX( ) ):center_x( )
        end
    end
end

function ConfirmUpgrade( upgrade_id, cost )
    if localPlayer:GetClanRole( ) ~= CLAN_ROLE_LEADER then
        localPlayer:ShowError( "Только лидер клана может приобрести улучшения" )
        return
    end

    if CLAN_DATA.money < cost then
        localPlayer:ShowError( "Недостачно средств в общаке клана" )
        return
    end

    ibConfirm(
        {
            title = "ПОКУПКА УЛУЧШЕНИЯ", 
            text = "Ты точно хочешь приобрести это улучшение за" ,
            cost = cost,
            cost_is_soft = true,
            fn = function( self )
                UI.upgrade_loading = ibLoading( { parent = UI.tab_panel.elements.rt } )
                triggerServerEvent( "onPlayerRequestClanUpgrade", localPlayer, upgrade_id )
                self:destroy()
            end,
            escape_close = true,
        }
    )
end

addEvent( "onClientClanUpgradeResponse", true )
addEventHandler( "onClientClanUpgradeResponse", root, function( msg )
    if msg then
        localPlayer:ShowError( msg )
    end
    if isElement( UI.upgrade_loading ) then
        UI.upgrade_loading:destroy( )
    end
end )

addEvent( "onClientClanUpgrade", true )
addEventHandler( "onClientClanUpgrade", root, function( upgrade_id, lvl )
    if not isElement( UI.bg ) then return end

    CLAN_DATA.upgrades[ upgrade_id ] = lvl
    
    if isElement( UI.upgrade_loading ) then
        UI.upgrade_loading:destroy( )
    end

    if CLAN_UPGRADES_LIST[ upgrade_id ][ 1 ].buff_value then
        if UpdateBuffUpgradesOverlay then
            UpdateBuffUpgradesOverlay( )
        end
    elseif upgrade_id == CLAN_UPGRADE_STORAGE then
        UI.UpdateStorageUpgrade( )
    else
        if UpdateFactoryUpgradesOverlay then
            UpdateFactoryUpgradesOverlay( )
        end
    end
end )

addEvent( "onClientClanUpgradesSync", true )
addEventHandler( "onClientClanUpgradesSync", root, function( upgrades )
    if not isElement( UI.bg ) then return end

    CLAN_DATA.upgrades = upgrades

    UpdateUpgradesTab( )
end )