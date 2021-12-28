Extend( "ib" )
Extend( "CPlayer" )

local finish_ts = 0
local items = nil
local my_last_bet
local last_bet

local ui = { }
local sx, sy = 1024, 720
local selected_item = 1

function ShowUI_Auction( state )
	if state then
        if not items then
            triggerServerEvent( "OnClientRequestAuctionData", resourceRoot )
            return
        end

		ibUseRealFonts( true )

		ui.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg.png" ):center( )
		local bg = ui.bg

		-- Countdown
		ui.icon_timer = ibCreateImage( sx-500, 32, 22, 24, "img/icon_timer.png", bg )

		ui.l_countdown = ibCreateLabel( sx-304-8, 0, 0, 90, "До конца аукциона:", bg, _, _, _, "right", "center", ibFonts.regular_16 )
		:ibData( "alpha", 255*0.75 )

        ui.hours = ibCreateLabel( sx-304, 0, 0, 90, "2", bg, _, _, _, "left", "center", ibFonts.oxaniumbold_16 )
        :ibData("disabled", true)
        ui.l_hours = ibCreateLabel( ui.hours:ibData("px")+ui.hours:width()+4, 0, 0, 90, "ч.", bg, _, _, _, "left", "center", ibFonts.regular_16 )
        :ibData("disabled", true)

        ui.minutes = ibCreateLabel( ui.l_hours:ibData("px")+ui.l_hours:width()+4, 0, 0, 90, "2", bg, _, _, _, "left", "center", ibFonts.oxaniumbold_16 )
        :ibData("disabled", true)
        ui.l_minutes = ibCreateLabel( ui.minutes:ibData("px")+ui.minutes:width()+4, 0, 0, 90, "мин.", bg, _, _, _, "left", "center", ibFonts.regular_16 )
        :ibData("disabled", true)

        local function UpdateCountdown()
        	local iSeconds = finish_ts - getRealTimestamp()
        	local iHours = math.floor( iSeconds / 60 / 60 )
        	local iMinutes = math.floor( ( iSeconds - iHours*60*60  ) / 60 )

        	ui.hours:ibData( "text", iHours )
        	ui.minutes:ibData( "text", iMinutes )

        	ui.l_hours:ibData( "px", ui.hours:ibData("px")+ui.hours:width()+4 )
        	ui.minutes:ibData( "px", ui.l_hours:ibData("px")+ui.l_hours:width()+4 )
        	ui.l_minutes:ibData( "px", ui.minutes:ibData("px")+ui.minutes:width()+4 )
        end
        UpdateCountdown()
        ui.hours:ibTimer(UpdateCountdown, 15000, 0)

        ui.btn_close = ibCreateButton( sx - 24 - 26, 34, 24, 24, bg,
                              ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                               0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowUI_Auction( false )
            end )

        ui.btn_rules = ibCreateButton( sx - 190, 30, 107, 31, bg,
                              "img/btn_rules_i.png", "img/btn_rules_h.png", "img/btn_rules_h.png",
                               0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                ShowRulesOverlay( true )
            end )

        -- Items
        local py = 150
        for k,v in pairs( items ) do
        	local item = ibCreateImage( 0, py, 1001, 206, "img/bg_item_"..k.."_i.png", bg ):center_x( )
        	:ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                selected_item = k
                ShowItemOverlay( true )
            end )
        	:ibOnHover( function( )
            	source:ibData( "texture", "img/bg_item_"..k.."_h.png" )
            end )
            :ibOnLeave( function( )
            	source:ibData( "texture", "img/bg_item_"..k.."_i.png" )
            end )

            local btn_details = ibCreateButton( 1001-230, 30, 198, 64, item,
                              "img/btn_details_i.png", "img/btn_details_h.png", "img/btn_details_h.png",
                               0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF ):center_y( 4 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                selected_item = k
                ShowItemOverlay( true )
            end )
            :ibOnHover( function( )
            	item:ibData( "texture", "img/bg_item_"..k.."_h.png" )
            end )
            :ibOnLeave( function( )
            	item:ibData( "texture", "img/bg_item_"..k.."_i.png" )
            end )

            local icon_area = ibCreateArea( 0, 0, 380, 206, item ):ibData( "disabled", true )
            local icon_vehicle = ibCreateContentImage( 0, 0, 300, 160, "vehicle", v.id, icon_area ):center( ):ibData( "disabled", true )

            local tsx, tsy = dxGetTextSize( v.name, 270, 1, ibFonts.bold_20, true )

            local title = ibCreateLabel( 564-270/2, tsy >= 50 and 130 or 110, 270, 0, v.name, item, _, _, _, "center", "center", ibFonts.bold_20 )
            :ibData( "wordbreak", true ):ibData( "disabled", true )

            local dsx, dsy = dxGetTextSize( v.desc, 270, 1, ibFonts.regular_16, true )

            local desc = ibCreateLabel( 564-280/2, 70, 280, 0, v.desc, item, _, _, _, "center", "center", ibFonts.regular_16 )
            :ibData( "wordbreak", true ):ibData( "disabled", true ):ibData( "alpha", 255*0.75 )

        	py = py + 186
        end

        ui.item_overlay = ibCreateRenderTarget( 0, 90, sx, sy-90, bg )
        ui.rules_overlay = ibCreateRenderTarget( 0, 90, sx, sy-90, bg )
        ui.rules_overlay_bg = ibCreateImage( 0, sy-90, 1024, 630, "img/rules.png", ui.rules_overlay ):center_x( )
        ui.rules_overlay_btn_back = ibCreateButton( 30, 22, 103, 17, ui.rules_overlay_bg,
                              "img/btn_back_i.png", "img/btn_back_h.png", "img/btn_back_h.png",
                               0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowRulesOverlay( false )
            end )

        ui.item_overlay_bg = ibCreateImage( 0, sy-90, 1043, 630, "img/overlay_1.png", ui.item_overlay ):center_x( )
        ui.vehicle_area = ibCreateArea( 0, 125, 630, 430, ui.item_overlay_bg )
        ui.item_overlay_name = ibCreateLabel( 0, 96, 630, 0, "", ui.item_overlay_bg, _, _, _, "center", "center", ibFonts.bold_22 )
        ui.item_overlay_desc = ibCreateLabel( 0, 594, 630, 0, "", ui.item_overlay_bg, _, _, _, "center", "center", ibFonts.regular_16 ):ibData( "alpha", 255*0.75 )

        ui.item_overlay_btn_back = ibCreateButton( 30, 22, 103, 17, ui.item_overlay_bg,
                              "img/btn_back_i.png", "img/btn_back_h.png", "img/btn_back_h.png",
                               0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowItemOverlay( false )
            end )

        local title_pt1 = ibCreateLabel( 310, 30, 0, 0, "Аукцион на", ui.item_overlay_bg, _, _, _, "left", "center", ibFonts.regular_18 )
        local title_pt2 = ibCreateLabel( title_pt1:ibGetAfterX( 5 ), 30, 0, 0, "24", ui.item_overlay_bg, _, _, _, "left", "center", ibFonts.bold_18 )
        local title_pt3 = ibCreateLabel( title_pt2:ibGetAfterX( 5 ), 30, 0, 0, "часа. Персональное предложение", ui.item_overlay_bg, _, _, _, "left", "center", ibFonts.regular_18 )

        local arrow_l = ibCreateButton( 30, 85, 14, 23, ui.item_overlay_bg,
                              "img/arrow_l.png", "img/arrow_l.png", "img/arrow_l.png",
                               0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                selected_item = selected_item - 1

                if not items[ selected_item ] then
                    selected_item = 3
                end

                UpdateItemOverlay()
            end )

        local arrow_r = ibCreateButton( 586, 85, 14, 23, ui.item_overlay_bg,
                              "img/arrow_r.png", "img/arrow_r.png", "img/arrow_r.png",
                               0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                selected_item = selected_item + 1

                if not items[ selected_item ] then
                    selected_item = 1
                end

                UpdateItemOverlay()
            end )

        ui.last_bet_area = ibCreateArea( 632, 93, 394, 538, ui.item_overlay_bg )

		showCursor( true )

        addEventHandler( "onClientKey", root, OnClientKeyHandler )
	else
		showCursor( false )
		DestroyTableElements( ui )
		ui = { }
        items = nil

        removeEventHandler( "onClientKey", root, OnClientKeyHandler )
	end
end
addEvent( "ShowUI_VehicleAuction", true )
addEventHandler( "ShowUI_VehicleAuction", root, ShowUI_Auction )

function UpdateItemOverlay( )
    if isElement( ui.item_overlay_vehicle ) then
        destroyElement( ui.item_overlay_vehicle )
    end

    local item_data = items[selected_item]
    UpdateItemBets( )

    ui.item_overlay_bg:ibData( "texture", "img/overlay_"..selected_item..".png" )
    ui.item_overlay_vehicle = ibCreateContentImage( 0, 0, 600, 316, "vehicle", item_data.id, ui.vehicle_area ):center( ):ibData( "disabled", true )
    ui.item_overlay_name:ibData( "text", item_data.name )
    ui.item_overlay_desc:ibData( "text", item_data.desc )

    if isElement( ui.last_bet_area ) then
        destroyElement( ui.last_bet_area )
    end

    ui.last_bet_area = ibCreateArea( 632, 93, 394, 538, ui.item_overlay_bg )

    if last_bet then
        ibCreateLabel( 182, 40, 0, 0, "Лидер ставок:", ui.last_bet_area, _, _, _, "left", "center", ibFonts.regular_14 ):ibData( "alpha", 255*0.75 )
        local splitted_name = split( last_bet.player_name, " " )
        ibCreateLabel( 182, 76, 0, 0, splitted_name[1].."\n"..splitted_name[2], ui.last_bet_area, _, _, _, "left", "center", ibFonts.bold_18 ) 

        ibCreateLabel( 182, 126, 0, 0, "Лидирующая ставка:", ui.last_bet_area, _, _, _, "left", "center", ibFonts.regular_14 ):ibData( "alpha", 255*0.75 )

        local l_bet_sum = ibCreateLabel( 182, 154, 0, 0, format_price( last_bet.value ), ui.last_bet_area, _, _, _, "left", "center", ibFonts.oxaniumbold_26 )
        local icon_hard = ibCreateImage( l_bet_sum:ibGetAfterX(8), 154-14, 28, 28, ":nrp_shared/img/hard_money_icon.png", ui.last_bet_area )

        local avatar_bg = ibCreateImage( 30, 20, 132, 162, _, ui.last_bet_area, 0xffcccccc )
        ibCreateContentImage( 1, 1, 130, 160, "skin", last_bet.skin_id or 1, avatar_bg )

        if my_last_bet then
            local l_bet = ibCreateLabel( 74, 230, 0, 0, "Ваша текущая ставка:", ui.last_bet_area, _, _, _, "left", "center", ibFonts.regular_16 ):ibData( "priority", 1 )
            local l_bet_sum = ibCreateLabel( l_bet:ibGetAfterX(5), 230, 0, 0, format_price( my_last_bet.value ), ui.last_bet_area, _, _, _, "left", "center", ibFonts.bold_18 ):ibData( "priority", 1 )
            local icon_hard = ibCreateImage( l_bet_sum:ibGetAfterX(5), 230-14, 28, 28, ":nrp_shared/img/hard_money_icon.png", ui.last_bet_area ):ibData( "priority", 1 )
            
            ibCreateLabel( 84, 284-18, 230, 0, "Доплата", ui.last_bet_area, _, _, _, "center", "center", ibFonts.regular_14 ):ibData( "alpha", 255*0.5 )
            local edit_bg = ibCreateImage( 84, 284, 230, 40, "img/bg_edit.png", ui.last_bet_area )
            local edit_field = ibCreateEdit( 12, 0, 180, 40, "", edit_bg, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF ):ibData( "font", ibFonts.oxaniumbold_14 )

            ibCreateImage( 184, 340, 27, 33, "img/arrow_d.png", ui.last_bet_area )

            ibCreateLabel( 84, 408-18, 230, 0, "Новая ставка", ui.last_bet_area, _, _, _, "center", "center", ibFonts.regular_14 ):ibData( "alpha", 255*0.5 )
            local edit_bg2 = ibCreateImage( 84, 408, 230, 40, "img/bg_edit.png", ui.last_bet_area )
            local l_new_bet = ibCreateLabel( 12, 0, 100, 40, 0, edit_bg2, _, _, _, "left", "center", ibFonts.oxaniumregular_14 ):ibData( "alpha", 255*0.75 )

            edit_field:ibOnDataChange( function( key, value, old )
                if key ~= "text" then return end
                
                local illegal_symbols = utf8.match( value, "[^0-9]+" )
                local len = utf8.len( value )
                if illegal_symbols or len > 10 then
                    edit_field:ibData( "text", old )
                    edit_field:ibData( "caret_position", 0 )
                    
                    edit_field:ibKillTimers()
                    edit_field:ibTimer( function()
                        edit_field:ibData( "caret_position", utf8.len( old ) )
                    end, 50, 1 )
                    return
                end

                local num = tonumber( value )
                if num then
                    l_new_bet:ibData( "text", format_price( my_last_bet.value + num ) )
                else
                    l_new_bet:ibData( "text", "0" )
                end
            end )

            local btn_raise_bet = ibCreateButton( 104, 466, 198, 57, ui.last_bet_area,
                                  "img/btn_raise_bet_i.png", "img/btn_raise_bet_h.png", "img/btn_raise_bet_h.png",
                                   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )

                    local str = edit_field:ibData( "text" )
                    local num = str and tonumber( str )
                    if not num or not my_last_bet then return end

                    triggerServerEvent( "OnPlayerTryPlaceBet", resourceRoot, selected_item, my_last_bet.value + num, last_bet and last_bet.player_id )
                end )

            local diff = getRealTimestamp() - my_last_bet.timestamp 
            
            if diff < 60 * 60 then
                local diff_bg = ibCreateImage( 8, 200, 400, 350, _, ui.last_bet_area, 0xaa283441 )
                ibCreateLabel( 0, 120, 400, 0, "Возможность сделать ставку через:", diff_bg, _, _, _, "center", "center", ibFonts.regular_16 ):ibData( "alpha", 0.75*255 )
                ibCreateImage( 150, 140, 22, 24, "img/icon_timer.png", diff_bg )
                ibCreateLabel( 180, 140, 0, 24, 60-math.floor( diff/60 ) .." мин.", diff_bg, _, _, _, "left", "center", ibFonts.oxaniumbold_16 )
                --ibCreateImage( 0, 186, 229, 20, "img/skip_cost.png", diff_bg ):center_x( )
                local l_skip_cost = ibCreateLabel( 58, 190, 0, 0, "Стоимость пропуска: ", diff_bg, _, _, _, "left", "center", ibFonts.regular_16 )
                local skip_cost = ibCreateLabel( l_skip_cost:ibGetAfterX( 5 ), 190, 0, 0, math.ceil( item_data.start_bet * BET_SKIP_PERCHANT ), diff_bg, _, _, _, "left", "center", ibFonts.oxaniumbold_18 )
                local icon_hard = ibCreateImage( skip_cost:ibGetAfterX(5), 176, 28, 28, ":nrp_shared/img/hard_money_icon.png", diff_bg )

                local btn_skip = ibCreateButton( 104, 220, 184, 56, diff_bg,
                                  "img/btn_skip_i.png", "img/btn_skip_h.png", "img/btn_skip_h.png",
                                   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :center_x( )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )

                    if localPlayer:GetDonate( ) < 100 then
                        localPlayer:ShowError( "Недостаточно средств" )
                        return
                    end

                    destroyElement( diff_bg )
                end )
            end
        else
            local l_bet = ibCreateLabel( 87, 312, 0, 0, "Минимальная ставка:", ui.last_bet_area, _, _, _, "left", "center", ibFonts.regular_16 )
            local l_bet_sum = ibCreateLabel( l_bet:ibGetAfterX(5), 312, 0, 0, format_price( last_bet.value ), ui.last_bet_area, _, _, _, "left", "center", ibFonts.bold_18 )
            local icon_hard = ibCreateImage( l_bet_sum:ibGetAfterX(5), 298, 28, 28, ":nrp_shared/img/hard_money_icon.png", ui.last_bet_area )
        
            local edit_bg = ibCreateImage( 84, 338, 230, 40, "img/bg_edit.png", ui.last_bet_area )
            local edit_field = ibCreateEdit( 12, 0, 180, 40, "", edit_bg, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF ):ibData( "font", ibFonts.oxaniumbold_14 )

            edit_field:ibOnDataChange( function( key, value, old )
                if key ~= "text" then return end
                
                local illegal_symbols = utf8.match( value, "[^0-9]+" )
                local len = utf8.len( value )
                if illegal_symbols or len > 10 then
                    edit_field:ibData( "text", old )
                    edit_field:ibData( "caret_position", 0 )
                    
                    edit_field:ibKillTimers()
                    edit_field:ibTimer( function()
                        edit_field:ibData( "caret_position", utf8.len( old ) )
                    end, 50, 1 )
                    return
                end
            end )

            local btn_place_bet = ibCreateButton( 104, 398, 198, 57, ui.last_bet_area,
                                  "img/btn_place_bet_i.png", "img/btn_place_bet_h.png", "img/btn_place_bet_h.png",
                                   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )

                    local str = edit_field:ibData( "text" )
                    local num = str and tonumber( str )
                    if not num then return end

                    triggerServerEvent( "OnPlayerTryPlaceBet", resourceRoot, selected_item, num, last_bet and last_bet.player_id )
                end )
        end
    else
        ibCreateImage( 30, 20, 132, 162, "img/no_avatar.png", ui.last_bet_area )
        ibCreateLabel( 182, 100, 0, 0, "Стань лидером —\nсделай ставку!", ui.last_bet_area, _, _, _, "left", "center", ibFonts.regular_16 )

        local l_bet = ibCreateLabel( 87, 312, 0, 0, "Начальная ставка:", ui.last_bet_area, _, _, _, "left", "center", ibFonts.regular_16 )
        local l_bet_sum = ibCreateLabel( l_bet:ibGetAfterX(5), 312, 0, 0, format_price( item_data.start_bet ), ui.last_bet_area, _, _, _, "left", "center", ibFonts.bold_18 )
        local icon_hard = ibCreateImage( l_bet_sum:ibGetAfterX(5), 298, 28, 28, ":nrp_shared/img/hard_money_icon.png", ui.last_bet_area )
    
        local edit_bg = ibCreateImage( 84, 338, 230, 40, "img/bg_edit.png", ui.last_bet_area )
        local edit_field = ibCreateEdit( 12, 0, 180, 40, "", edit_bg, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF ):ibData( "font", ibFonts.oxaniumbold_14 )

            edit_field:ibOnDataChange( function( key, value, old )
                if key ~= "text" then return end
                
                local illegal_symbols = utf8.match( value, "[^0-9]+" )
                local len = utf8.len( value )
                if illegal_symbols or len > 10 then
                    edit_field:ibData( "text", old )
                    edit_field:ibData( "caret_position", 0 )
                    
                    edit_field:ibKillTimers()
                    edit_field:ibTimer( function()
                        edit_field:ibData( "caret_position", utf8.len( old ) )
                    end, 50, 1 )
                    return
                end
            end )


        local btn_place_bet = ibCreateButton( 104, 398, 198, 57, ui.last_bet_area,
                              "img/btn_place_bet_i.png", "img/btn_place_bet_h.png", "img/btn_place_bet_h.png",
                               0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                local str = edit_field:ibData( "text" )
                local num = str and tonumber( str )
                if not num then return end

                triggerServerEvent( "OnPlayerTryPlaceBet", resourceRoot, selected_item, num, last_bet and last_bet.player_id )
            end )
    end
end

function ShowItemOverlay( state, id )
    if state then
        UpdateItemOverlay( )

        ui.item_overlay_bg:ibMoveTo( _, 0, 400, "InOutQuad" )
    else
        ui.item_overlay_bg:ibMoveTo( _, sy-90, 400, "InOutQuad" )
    end
end

function ShowRulesOverlay( state )
    if state then
        ui.rules_overlay_bg:ibMoveTo( _, 0, 400, "InOutQuad" )
    else
        ui.rules_overlay_bg:ibMoveTo( _, sy-90, 400, "InOutQuad" )
    end
end

function UpdateItemBets( )
    last_bet = items[ selected_item ].last_bet
    my_last_bet = items[ selected_item ].my_bet
end

function OnClientAuctionDataReceived( data, open_ui )
    local data = fromJSON( data )

    items = data.items
    finish_ts = data.finish_ts

    if open_ui then
        ShowUI_Auction( true )
    end
end
addEvent( "OnClientAuctionDataReceived", true )
addEventHandler( "OnClientAuctionDataReceived", resourceRoot, OnClientAuctionDataReceived )

function OnClientAuctionItemDataReceived( item_id, data )
    items[ item_id ].last_bet = data.last_bet
    items[ item_id ].my_bet = data.my_bet

    UpdateItemOverlay( )
end
addEvent( "OnClientAuctionItemDataReceived", true )
addEventHandler( "OnClientAuctionItemDataReceived", resourceRoot, OnClientAuctionItemDataReceived )

function OnClientKeyHandler( key, state )
    if key ~= "escape" then return end

    cancelEvent( )
    ShowUI_Auction( false )
end