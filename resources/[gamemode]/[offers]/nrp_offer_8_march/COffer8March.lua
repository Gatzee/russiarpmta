Extend( "ib" )
Extend( "CPlayer" )

ibUseRealFonts( true )

local UI = { }
local DATA = { }

function ShowOffer8March( offer_data )
	if offer_data then
        DATA = offer_data
        DATA.finish_ts = OFFER_END_DATE
        DATA.bought_packs = offer_data.bought_packs or { }
        DATA.current_lvl = offer_data.bought_packs_count or 1
		localPlayer:setData( "march_offer", DATA, false )
	elseif not next( DATA ) then
        return
	end

	if isElement( UI.black_bg ) then return end

	showCursor( true )

	UI.black_bg = ibCreateBackground( _, function( ) showCursor( false ) end )
	UI.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg.png", UI.black_bg )
		:center( )
		:ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )

	UI.btn_close = ibCreateButton( 972, 29, 24, 24, UI.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
			destroyElement( UI.black_bg )
		end, false )
	
	UI.area_timer = ibCreateArea( 0, 43, 0, 0, UI.bg )
	ibCreateImage( 0, 0, 30, 32, ":nrp_shared/img/icon_timer.png", UI.area_timer, ibApplyAlpha( COLOR_WHITE, 75 ) ):center_y( )
	UI.lbl_text = ibCreateLabel( 36, 0, 0, 0, "До конца акции: ", UI.area_timer, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_16 )
	UI.lbl_timer = ibCreateLabel( UI.lbl_text:ibGetAfterX( ), 0, 0, 0, getHumanTimeString( DATA.finish_ts ) or "0 с", UI.area_timer, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
		:ibTimer( function( self )
			self:ibData( "text", getHumanTimeString( DATA.finish_ts ) or "0 с" )
            UI.area_timer:ibData( "px", UI.btn_close:ibGetBeforeX( -30 ) - UI.lbl_timer:ibGetAfterX( ) )
		end, 1000, 0 )
	UI.area_timer:ibData( "px", UI.btn_close:ibGetBeforeX( -30 ) - UI.lbl_timer:ibGetAfterX( ) )

    UI.rt = ibCreateRenderTarget( 0, UI.bg:height( ) - 630, 1024, 630, UI.bg ):ibData( "priority", 3 )

    CreatePacks( )
    CreateVinylCase( )

    if UI.packs[ 1 ].btn_info then
        UI.packs[ 1 ].btn_info
            :ibData( "color", COLOR_WHITE )
            :ibTimer( ibAlphaTo, 1100, 0, 0, 900, "SineCurve" )
            :ibOnHover( function( )
                source
                    :ibKillTimers( )
                    :ibData( "color", 0xFFDDDDDD )
                    :ibData( "alpha", 255 )
            end )
    end

    CheckNotTakenPacks( )
end
addEvent( "ShowOffer8March", true )
addEventHandler( "ShowOffer8March", root, ShowOffer8March )

function CheckNotTakenPacks( )
    if not DATA.bought_packs then return end
    for pack_id in pairs( DATA.bought_packs ) do
        if not DATA.taken_packs or not DATA.taken_packs[ pack_id ] then
            ShowPackRewards( pack_id )
            break
        end
    end
end

function CreatePacks( )
    local packs_positions = {
        { x = 30  , y = 134, lines = { x = 310, y = 0   , sx =  51, sy =  252 }, rivet = { x = 37, y = 62, sx = 57, sy = 121, }, },
        { x = 30  , y = 438, lines = { x = 310, y = 252 , sx =  51, sy = -252 }, rivet = { x = 37, y = -68 - 121, sx = 57, sy = 121, }, },
        { x = 684 , y = 134, lines = { x = 0  , y = 0   , sx = -51, sy =  252 }, rivet = { x = -37, y = 62, sx = -57, sy = 121, }, },
        { x = 684 , y = 438, lines = { x = 0  , y = 252 , sx = -51, sy = -252 }, rivet = { x = -37, y = -68 - 121, sx = -57, sy = 121, }, },
    }
    UI.packs = { }
    for pack_id, packs_by_lvl in pairs( PACKS ) do
        UI.packs[ pack_id ] = CreatePack( pack_id, packs_positions[ pack_id ], UI.bg )
    end
end

function CreatePack( pack_id, pos, parent )
    local self = { }
    local pack_lvl = DATA.bought_packs[ pack_id ] or DATA.current_lvl
    local pack = PACKS[ pack_id ][ pack_lvl ]
    local is_pack_bought = DATA.bought_packs[ pack_id ]
    local is_bought_last = DATA.last_bought_pack == pack_id

    local url_end = is_pack_bought and "unlocked.png" or "locked.png"
    local lines_anim_delay = is_bought_last and 500 or 0
    local lines_anim_time = is_bought_last and 1000 or 200
    self.lines = ibCreateImage( pos.x + pos.lines.x, pos.y + pos.lines.y, pos.lines.sx, pos.lines.sy, "img/pack_lines_" .. url_end, parent ):
        ibData( "alpha", 0 ):ibTimer( ibAlphaTo, lines_anim_delay, 1, 255, lines_anim_time )
    self.rivet = ibCreateImage( pos.rivet.x, pos.rivet.y, pos.rivet.sx, pos.rivet.sy, "img/vinyl_case/rivet_" .. url_end, self.lines )

    self.img = ibCreateImage( pos.x, pos.y, 310, 252, "img/packs/" .. pack.key .. "/" .. pack_lvl .. ".png", parent ):ibData( "alpha", 0 ):ibAlphaTo( 255, 200 )
    self.bg = ibCreateImage( 0, -28, 310, 280, "img/pack.png", self.img )

    if not is_pack_bought then
        for i = 1, 4 do
            local px = 116 + ( i - 1 ) * 22
            local img_url = i > DATA.current_lvl and "img/star_unavailable" or "img/star"
            local btn_star_h = ibCreateImage( px - 6, 3 - 6, 28, 28, img_url .. "_h.png", self.bg ):ibData( "alpha", 0 )
            ibCreateButton( px, 3, 17, 17, self.bg, img_url .. ".png" )
                :ibOnHover( function( ) btn_star_h:ibAlphaTo( 255, 50 ) end )
                :ibOnLeave( function( ) btn_star_h:ibAlphaTo( 0, 50 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    -- destroyElement( UI.black_bg )
                    -- triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "cases", "premium_discount_case" )
                end, false )
        end

        self.btn_info = ibCreateButton( 283, 20, 34, 34, self.bg, "img/btn_info.png", _, _, 0xFFDDDDDD, _, 0xFFAAAAAA )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowPackInfo( pack_id )
            end, false )

        self.ChangeInfoBtnTextures = function( state )
            local url = state and "img/btn_info.png" or "img/btn_close.png"
            self.btn_info:ibBatchData( {
                texture         = url,
                texture_hover   = url,
                texture_click   = url,
            } )
        end
    end

    ibCreateLabel( 156, 31, 0, 0, "Набор “" .. pack.name .. "”", self.bg, _, _, _, "center", "center", ibFonts.regular_16 )
    ibCreateLabel( 172, 62, 0, 0, pack.discount .. "%", self.bg, _, _, _, "left", "center", ibFonts.oxaniumbold_11 )
    
    local lbl_cost_original = ibCreateLabel( 200, 191, 0, 0, format_price( pack.cost_original ), self.bg, _, _, _, "left", "center", ibFonts.oxaniumbold_15 ):ibData( "alpha", 255 * 0.75 )
    ibCreateImage( 175, 191, 26 + lbl_cost_original:width( ) + 3, 1, _, self.bg )
    ibCreateLabel( 203, 213, 0, 0, format_price( pack.cost ), self.bg, _, _, _, "left", "center", ibFonts.oxaniumbold_18 )

    -- ПОДРОБНЕЕ
    self.btn_details = ibCreateButton( 85, 233, 140, 32, self.bg, "img/btn_details.png", _, _, 0x0, _, 0xFFCCCCCC )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowPackInfo( false )
            ShowPackBuyOverlay( pack_id )
        end, false )

    if is_pack_bought then
        ibCreateImage( 0, 12, 311, 268, "img/pack_bought.png", self.bg )
    end

    self.destroy = function( )
        self.img:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
        local is_bought_last = DATA.last_bought_pack == pack_id
        local lines_anim_time = is_bought_last and 1000 or 200
        self.lines:ibAlphaTo( 0, lines_anim_time ):ibTimer( destroyElement, lines_anim_time, 1 )
    end

    return self
end

function CreateVinylCase( )
    local area = ibCreateArea( 0, 0, 0, 0, UI.bg ):ibData( "priority", 1 )

    function CreateVinylCaseBlockUnlocked( )
        return ibCreateImage( 300, 58, 423, 662, "img/vinyl_case/block_unlocked.png", area ):ibData( "priority", -1 )
    end
    if ( DATA.bought_packs_count or 0 ) >= #PACKS then
        CreateVinylCaseBlockUnlocked( )
    else
        UI.vinyl_case_block = ibCreateImage( 373, 103, 277, 590, "img/vinyl_case/block_locked.png", area )
        UI.lock_chains = ibCreateImage( 381, 249, 262, 323, "img/vinyl_case/lock_chains.png", area )
    end

    local lbl_cost_original = ibCreateLabel( 557, 600, 0, 0, format_price( VINYL_CASE.cost_original ), area, _, _, _, "left", "center", ibFonts.oxaniumbold_15 ):ibData( "alpha", 255 * 0.75 )
    ibCreateImage( 532, 600, 26 + lbl_cost_original:width( ) + 3, 1, _, area )
    ibCreateLabel( 560, 623, 0, 0, format_price( VINYL_CASE.cost ), area, _, _, _, "left", "center", ibFonts.oxaniumbold_18 )

    -- ПОДРОБНЕЕ
    ibCreateButton( 442, 643, 140, 32, area, "img/btn_details.png", _, _, 0x0, _, 0xFFCCCCCC )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowVinylCaseOverlay( true )
        end, false )
end

function ShowPackInfo( pack_id )
    if isElement( UI.info_bg ) then
        UI.info_bg:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
        UI.selected_pack.img:ibTimer( UI.selected_pack.img.ibData, 200, 1, "priority", 0 )
        UI.selected_pack.ChangeInfoBtnTextures( true )
        return
    end
    if not pack_id then return end
    
    UI.info_bg = ibCreateImage( 0, 0, 1024, 630, _, UI.rt, ibApplyAlpha( 0xFF1f2934, 75 ) ):ibData( "alpha", 1 ):ibAlphaTo( 255, 500 )
    UI.selected_pack = UI.packs[ pack_id ]
    UI.selected_pack.img:ibKillTimers( ):ibData( "priority", 4 )
    
    local pack_img_px = UI.selected_pack.img:ibData( "px" )
    local pack_img_py = UI.selected_pack.img:ibData( "py" ) - 90
    local is_left = pack_img_px < 512
    local is_upper = pack_img_py < 260

    local all_items_bg = ibCreateImage( is_left and 296 or -12, 1, 741, 656, "img/all_items_bg.png", UI.info_bg )
    ibCreateImage( pack_img_px - 33, pack_img_py + ( is_upper and 252 - 33 or - 173 ), 377, 209, "img/all_items_info.png", UI.info_bg )

    ibCreateImage( pack_img_px + (is_left and -28 or 338), pack_img_py - 27, (is_left and 479 or -479), 316, "img/pack_selected.png", UI.info_bg )

    ibCreateButton( 674, 52, 14, 14, all_items_bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowPackInfo( false )
        end, false )

    UI.selected_pack.ChangeInfoBtnTextures( false )

    local packs_by_lvl = PACKS[ pack_id ]
    ibCreateLabel( 367, 58, 0, 0, "Состав набора “" .. packs_by_lvl.name .."”", all_items_bg, _, _, _, "center", "center", ibFonts.regular_16 )

    local oy = 0
    for pack_lvl = 1, #PACKS do
        local pack = packs_by_lvl[ pack_lvl ]
        ibCreateLabel( 134, 90 + oy, 0, 0, format_price( pack.cost ), all_items_bg, _, _, _, "left", "center", ibFonts.oxaniumbold_14 )

        local area_items = ibCreateArea( 0, 108 + oy, 0, 0, all_items_bg )
        local px = 0
        for i, item in pairs( pack.items ) do
            local item_bg = ibCreateImage( px, 0, 116, 92, "img/item_bg.png", area_items )
            REGISTERED_ITEMS[ item.type ].uiCreateItem( item.type, item, item_bg )
            if pack_lvl > DATA.current_lvl then
                ibCreateImage( 1, 1, 114, 90, "img/item_locked_bg.png", item_bg )
            end
            ibCreateArea( 0, 0, 116, 92, item_bg )
                :ibAttachTooltip( REGISTERED_ITEMS[ item.type ].uiGetDescriptionData( item.type, item ).title )

            px = px + 116 + 8
        end
        area_items:ibData( "sx", px - 8 ):center_x( )

        oy = oy + 132
    end
end

function ShowPackBuyOverlay( pack_id )
    if isElement( UI.overlay_bg ) then
        UI.overlay_discount:ibAlphaTo( 0, 200 )
        UI.overlay_bg:ibMoveTo( 0, UI.bg:height( ), 200 ):ibTimer( destroyElement, 200, 1 )
    end
    if not pack_id then return end

    UI.overlay_bg = ibCreateImage( 0, 630, 1024, 630, "img/buy_overlay/bg.png", UI.rt )
        :ibMoveTo( 0, 0, 250 )

    local btn_back = ibCreateButton( 32, 22, 103, 17, UI.overlay_bg, "img/buy_overlay/btn_back.png", _, _, 0x9FFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowPackBuyOverlay( false )
        end )

    local pack = PACKS[ pack_id ][ DATA.current_lvl ]
    ibCreateLabel( 512, 17, 0, 0, "Набор “" .. pack.name .."”", UI.overlay_bg, _, _, _, "center", "center", ibFonts.bold_18 )

    UI.overlay_discount = ibCreateLabel( 977, 44, 0, 0, pack.discount .. "%", UI.overlay_bg, _, _, _, "center", "center", ibFonts.oxaniumbold_30 )
        :ibBatchData( {
            rotation = 45,
            rotation_center_x = 975,
            rotation_center_y = 46,
            alpha = 0,
        } )
        :ibTimer( ibAlphaTo, 100, 1, 255 )

    local area_items = ibCreateArea( 0, 49, 0, 0, UI.overlay_bg )
    local px = 0
    local sx = #pack.items == 5 and 255 or 301
    for i, item in pairs( pack.items ) do
        local item_bg = ibCreateImage( px, 0, sx, 294, #pack.items == 5 and "img/buy_overlay/item_small_bg.png" or "img/buy_overlay/item_bg.png", area_items )

        local item_info = REGISTERED_ITEMS[ item.type ].uiGetDescriptionData( item.type, item, item_bg )
        ibCreateLabel( 0, 25, 0, 0, item_info.title, item_bg, _, _, _, "center", "center", ibFonts.regular_14 ):center_x( )

        local item_img = REGISTERED_ITEMS[ item.type ].uiCreateBigItem( item.type, item, item_bg )
        if item_img and item.type ~= "skin" then
            item_img:ibSetInBoundSize( sx - 90 ):center( 0, 10 )
        end

        if i ~= #pack.items then
            ibCreateImage( sx - 35 - 21, 140, 46, 46, "img/buy_overlay/plus.png", item_bg )
        end
        px = px + sx - 32 * 2 - 3
    end
    area_items:ibData( "sx", px + 32 * 2 ):center_x( )

    ibCreateLabel( 433, 356, 0, 0, format_price( pack.cost ), UI.overlay_bg, _, _, _, "left", "center", ibFonts.oxaniumbold_21 )
    local lbl_cost_original = ibCreateLabel( 425, 382, 0, 0, format_price( pack.cost_original ), UI.overlay_bg, _, _, _, "left", "center", ibFonts.oxaniumbold_16 ):ibData( "alpha", 255 * 0.5 )
    ibCreateImage( 399, 382, 26 + lbl_cost_original:width( ) + 3, 1, _, UI.overlay_bg )

    ibCreateButton( 491, 340, 158, 66, UI.overlay_bg, "img/buy_overlay/btn_buy.png", _, _, 0, _, 0xFFAAAAAA )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            ibConfirm(
                {
                    title = "ПОДТВЕРЖДЕНИЕ", 
                    text = "Ты точно хочешь купить этот набор за",
                    cost = pack.cost,
                    fn = function( self )
                        triggerServerEvent( "8M:onPlayerWantBuyPack", resourceRoot, pack_id )
                        self:destroy()
                    end,
                    escape_close = true,
                }
            )
        end, false )

    if ( DATA.bought_packs_count or 0 ) < #PACKS - 1 then
        ibCreateLabel( 512, 430, 0, 0, "После покупки данного набора в остальные наборы добавится:", UI.overlay_bg, _, _, _, "center", "center", ibFonts.regular_16 )
        
        local pack_i = 0
        local pack_px = 0
        local pack_sx = UI.overlay_bg:width( ) / ( #PACKS - ( DATA.bought_packs_count or 0 ) - 1 )
        for other_pack_id, other_packs_by_lvl in pairs( PACKS ) do
            if other_pack_id ~= pack_id and not DATA.bought_packs[ other_pack_id ] then
                pack_i = pack_i + 1

                local name_bg = ibCreateImage( pack_px, 447, pack_sx, 30, "img/buy_overlay/other_pack_name_bg.png", UI.overlay_bg )
                ibCreateLabel( 0, 0, 0, 0, "Набор “" .. other_packs_by_lvl.name .."”", name_bg, _, _, _, "center", "center", ibFonts.regular_14 ):center( 0, -1 )

                local area_items = ibCreateArea( 0, 492, 0, 0, UI.overlay_bg )
                local px = 0
                local sx = 122
                
                for i, item in pairs( other_packs_by_lvl[ DATA.current_lvl + 1 ].items ) do
                    local is_item_new = true
                    for i, old_item in pairs( other_packs_by_lvl[ DATA.current_lvl ].items ) do
                        if table.compare( item, old_item ) then
                            is_item_new = false
                            break
                        end
                    end

                    if is_item_new then
                        local item_bg = ibCreateImage( px, 0, sx, sx, "img/buy_overlay/other_item_bg.png", area_items )
                        local item_img = REGISTERED_ITEMS[ item.type ].uiCreateItem( item.type, item, item_bg )
                        px = px + sx + 8
                    end
                end

                area_items:ibData( "px", pack_px + pack_sx / 2 - ( px - 8 ) / 2 )
                pack_px = pack_px + pack_sx

                if pack_i ~= #PACKS - ( DATA.bought_packs_count or 0 ) - 1 then
                    ibCreateImage( pack_px - 58 / 2, 439, 58, 191, "img/buy_overlay/separator_line.png", UI.overlay_bg )
                end
            end
        end
    else
        ibCreateLabel( 512, 430, 0, 0, "После покупки данного набора тебе откроется доступ к винил кейсу:", UI.overlay_bg, _, _, _, "center", "center", ibFonts.regular_16 )
        ibCreateImage( 0, 447, 1024, 183, "img/buy_overlay/vinyl_case_img.png", UI.overlay_bg )
    end
end

function ShowVinylCaseOverlay( state )
    if isElement( UI.overlay_bg ) then
        UI.overlay_bg:ibMoveTo( 0, UI.bg:height( ), 200 ):ibTimer( destroyElement, 200, 1 )
    end
    if not state then return end

    UI.overlay_bg = ibCreateImage( 0, 630, 1024, 630, "img/vinyl_case/overlay.png", UI.rt )
        :ibMoveTo( 0, 0, 250 )

    local btn_back = ibCreateButton( 32, 22, 103, 17, UI.overlay_bg, "img/buy_overlay/btn_back.png", _, _, 0x9FFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowVinylCaseOverlay( false )
        end )

    if ( DATA.bought_packs_count or 0 ) < #PACKS then
        ibCreateImage( 390, 8, 12, 17, "img/vinyl_case/icon_locked.png", UI.overlay_bg )
    end

    local scrollpane, scrollbar = ibCreateScrollpane( 0, 35, 1024, 477, UI.overlay_bg, { scroll_px = -20 } )
    scrollbar:ibSetStyle( "slim_nobg" )

    local px, py = 0, 10
    local sx, sy = 301, 294
    for i, vinyl_id in pairs( VINYL_CASE.items ) do
        local item_bg = ibCreateImage( px, py, sx, 294, "img/buy_overlay/item_bg.png", scrollpane )

        local item_params = { id = vinyl_id }
        local item_info = REGISTERED_ITEMS[ "vinyl" ].uiGetDescriptionData( "vinyl", item_params, item_bg )
        ibCreateLabel( 0, 25, 0, 0, item_info.title, item_bg, _, _, _, "center", "center", ibFonts.regular_14 ):center_x( )

        local item_img = REGISTERED_ITEMS[ "vinyl" ].uiCreateBigItem( "vinyl", item_params, item_bg )
            :ibSetInBoundSize( sx - 90 ):center( 0, 10 )

        if i % 4 > 0 then
            ibCreateImage( sx - 35 - 21, 140, 46, 46, "img/buy_overlay/plus.png", item_bg )
            px = px + sx - 32 * 2 - 3
        else
            px = 0
            py = py + sy - 21
        end
    end

    scrollpane:AdaptHeightToContents( )
    scrollbar:UpdateScrollbarVisibility( scrollpane )

    ibCreateImage( UI.overlay_bg:width( ) - 129, 0, 129, 131, "img/vinyl_case/discount.png", UI.overlay_bg )

    -- Новая стоимость:
    ibCreateLabel( 501, 561, 0, 0, format_price( VINYL_CASE.cost ), UI.overlay_bg, _, _, _, "left", "center", ibFonts.oxaniumbold_21 )
    local lbl_cost_original = ibCreateLabel( 488, 585, 0, 0, format_price( VINYL_CASE.cost_original ), UI.overlay_bg, _, _, _, "left", "center", ibFonts.oxaniumbold_16 ):ibData( "alpha", 255 * 0.5 )
    ibCreateImage( 463, 585, 26 + lbl_cost_original:width( ) + 3, 1, _, UI.overlay_bg )

    -- КУПИТЬ
    ibCreateButton( 551, 543, 158, 66, UI.overlay_bg, "img/buy_overlay/btn_buy.png", _, _, 0, _, 0xFFAAAAAA )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )

            if ( DATA.bought_packs_count or 0 ) < #PACKS then
                localPlayer:ShowError( "Сначала нужно приобрести все наборы" )
                return
            end

            ibConfirm(
                {
                    title = "ПОДТВЕРЖДЕНИЕ", 
                    text = "Ты точно хочешь купить этот винил-кейс за",
                    cost = VINYL_CASE.cost,
                    fn = function( self )
                        triggerServerEvent( "8M:onPlayerWantBuyVinylCase", resourceRoot )
                        self:destroy()
                    end,
                    escape_close = true,
                }
            )
        end, false )
end

addEvent( "8M:onClientPackBuy", true )
addEventHandler( "8M:onClientPackBuy", resourceRoot, function( pack_id )
    DATA.bought_packs[ pack_id ] = DATA.current_lvl
    DATA.bought_packs_count = ( DATA.bought_packs_count or 0 ) + 1
    DATA.last_bought_pack = pack_id
    DATA.current_lvl = math.min( #PACKS, DATA.current_lvl + 1 )

    ShowPackBuyOverlay( false )
    ShowPackInfo( false )

    ShowPackRewards( pack_id )
end )

function ShowPackRewards( pack_id )
	local rewards_data = { }
	local reward_element = ibCreateDummy( UI.bg )
    local reward_id = 1

    local function ShowTakeReward( pack_id )
        local item = PACKS[ pack_id ][ DATA.bought_packs[ pack_id ] ].items[ reward_id ]
        if item then
            triggerEvent( "ShowTakeReward", reward_element, UI.black_bg, item.type, { params = item } )
        else
            reward_element:destroy( )
            triggerServerEvent( "8M:onPlayerWantTakePack", resourceRoot, pack_id, rewards_data )

            if not DATA.taken_packs then DATA.taken_packs = { } end
            DATA.taken_packs[ pack_id ] = true

            if DATA.last_bought_pack then
                ShowPackBoughtAnimations( )
            else
                CheckNotTakenPacks( )
            end
        end
    end

    addEventHandler( "ShowTakeReward_callback", reward_element, function( data )
        rewards_data[ reward_id ] = data

        reward_id = reward_id + 1
        ShowTakeReward( pack_id )
    end )
    ShowTakeReward( pack_id )
end

function ShowPackBoughtAnimations( )
    UI.bg:ibTimer( function( )
        for other_pack_id, packs_by_lvl in pairs( PACKS ) do
            -- if pack_id ~= other_pack_id and not DATA.bought_packs[ other_pack_id ] then
                UI.packs[ other_pack_id ]:destroy( )
            -- end
        end
        CreatePacks( )

        if DATA.bought_packs_count >= #PACKS then
            -- 
            local delay = 1500

            UI.bg:ibTimer( function( )
                for pack_id, packs_by_lvl in pairs( PACKS ) do
                    local px = UI.packs[ pack_id ].rivet:ibData( "px" )
                    local sx = UI.packs[ pack_id ].rivet:ibData( "sx" )
                    local dir = -sx / math.abs( sx )
                    UI.packs[ pack_id ].rivet
                        :ibTimer( ibMoveTo, pack_id * 500, 1, px + 300 * dir, _, 1000 )
                        :ibTimer( ibAlphaTo, pack_id * 500 + 100, 1, 0, 1000 )
                end
            end, delay, 1 )

            delay = delay + 2300

            UI.bg:ibTimer( function( )
                -- local px = UI.lock_chains:ibData( "px" )
                -- local py = UI.lock_chains:ibData( "py" )
                -- local sx = UI.lock_chains:ibData( "sx" )
                -- local sy = UI.lock_chains:ibData( "sy" )
                -- local add_size = -300
                -- UI.lock_chains
                --     :ibResizeTo( sx + add_size, sy + add_size, 500 )
                --     :ibMoveTo( px - add_size / 2, py - add_size / 2, 500 )
                --     :ibAlphaTo( 0, 500 )
                UI.lock_chains
                    :ibMoveTo( _, UI.lock_chains:ibData( "py" ) + 300, 500 )
                    :ibAlphaTo( 0, 500 )
            end, delay, 1 )

            delay = delay + 500

            UI.bg:ibTimer( function( )
                UI.vinyl_case_block:ibAlphaTo( 0, 500 )
                CreateVinylCaseBlockUnlocked( ):ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )
            end, delay, 1 )
        end
    end, 200, 1 )
end