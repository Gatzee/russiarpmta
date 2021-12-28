function ShowTuningCasesReward( item, case_type )
    if case_type == "vinyl" then
        item.params = FixTableData( item.params )
        item.name = "Винил для твоего транспорта"
        item.img = ":nrp_vinyls/img/" .. item.params[ P_IMAGE ] .. ".dds"
        item.take_event = "PlayerWantTakeOpenedVinylCaseItem"
    else
        local title = "Поздравляем! Вы получили:\n#ffe743"

        item.is_part = true
        item.name = title .. PARTS_NAMES[ item.type ] .. " - " .. item.name .. " (" .. PARTS_TIER_NAMES[ item.category ] .. ")"
        item.img = ":nrp_tuning_internal_parts/img/200x200/" .. PARTS_IMAGE_NAMES[ item.type ] .. ".png"

        local pathImgForMoto = ":nrp_tuning_internal_parts/img/200x200/" .. PARTS_IMAGE_NAMES[ item.type ] .. "_m.png"
        if item.is_moto and fileExists( pathImgForMoto ) then
            item.img = pathImgForMoto
        end
        -- item.take_event = "PlayerWantTakeOpenedTuningCaseItem"
    end

    ShowCaseReward( item )
end
addEvent( "ShowTuningCasesReward", true )
addEventHandler( "ShowTuningCasesReward", resourceRoot, ShowTuningCasesReward )

function ShowCaseReward( item )
    if isElement( UI.reward_bg ) then return end

    local function close( )
        if isElement( UI.reward_bg ) then destroyElement( UI.reward_bg ) end
    end

    UI.reward_bg = ibCreateBackground( 0xF2394a5c, _, true )
    :ibData( "alpha", 0 )
    :ibAlphaTo( 255, 500 )

    ibCreateImage( 0, 0, 0, 0, "images/brush.png", UI.reward_bg )
    :ibSetRealSize( ):center( )

    ibCreateLabel( 0, 0, 0, 0, item.name, UI.reward_bg )
    :ibBatchData( { font = ibFonts.bold_22, align_x = "center", colored = true } )
    :center( 0, - 300 )

    if item.is_part then
        local bg = ibCreateImage( 0, 0, 170, 170, "images/item_bg.png", UI.reward_bg, CONST_RARE_COLORS.tuning[ item.category ] )
        :center( 0, - 85 )

        UI.reward_img = ibCreateImage( 0, 0, 140, 140, item.img, bg ):center( )
    else
        UI.reward_img = ibCreateImage( 0, 0, 0, 0, item.img, UI.reward_bg )
        :ibSetRealSize( ):ibSetInBoundSize( 368 ):center( 0, - 75 )
    end

    ibCreateButton( 0, 0, 192, 110, UI.reward_bg,
    "images/btn_take_i.png", "images/btn_take_h.png", "images/btn_take_h.png",
    0xFFFFFFFF, 0xFFFFFFFF, 0xBBFFFFFF )
    :center( 0, 200 )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        ibClick( )

        if item.take_event then
            triggerServerEvent( item.take_event, resourceRoot )
        end

        if item.is_part then
            triggerEvent( "onPartsInventoryRefresh", localPlayer )
        end

        close( )
    end )

    if item.is_part then
        CreatePartStatsLine( item )
    end

    if ( item.rare and item.rare > 3 ) or ( item.category and item.category > 3 ) then ibGetRewardSound( 1 )
    else playSound( ":nrp_shop/sfx/reward_small.mp3" ) end
end

function ShowCaseRewardsList( items_imgs )
    local count = #items_imgs
    local i = 1

    ShowCaseReward( {
        name = "Поздравляем! Вы получили " .. count .. plural( count, " винил", " винила", " винилов" ),
        img = ":nrp_vinyls/img/" .. items_imgs[ i ] .. ".dds",
        rare = 5,
    } )
    
    UI.reward_counter_lbl = ibCreateLabel( 0, 0, 0, 0, "#ffe743" .. i .. " #adb455/ " .. count, UI.reward_bg )
    :ibBatchData( { font = ibFonts.bold_20, align_x = "center", colored = true } )
    :center( 0, 140 )

    local function SetSelectedReward( new_i )
        i = new_i
        UI.reward_counter_lbl:ibData( "text", "#ffe743" .. i .. " #adb455/ " .. count )
        UI.reward_img:ibData( "texture", ":nrp_vinyls/img/" .. items_imgs[ i ] .. ".dds" )
        :ibSetRealSize( ):ibSetInBoundSize( 368 )
        :center( 0, -50 )
    end

    ibCreateButton( 0, 0, 0, 0, UI.reward_bg,
        "images/btn_arrow_left.png", "images/btn_arrow_left.png", "images/btn_arrow_left.png",
        0x80FFFFFF, 0xFFFFFFFF, 0xBBFFFFFF )
        :ibSetRealSize( )
        :center( -300, -50 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )

            SetSelectedReward( ( i - 2 ) % count + 1 )
        end )

    ibCreateButton( 0, 0, 0, 0, UI.reward_bg,
        "images/btn_arrow_right.png", "images/btn_arrow_right.png", "images/btn_arrow_right.png",
        0x80FFFFFF, 0xFFFFFFFF, 0xBBFFFFFF )
        :ibSetRealSize( )
        :center( 300, -50 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )

            SetSelectedReward( i % count + 1 )
        end )
end
addEvent( "ShowTuningCasesRewardsList", true )
addEventHandler( "ShowTuningCasesRewardsList", root, ShowCaseRewardsList )

function CreatePartStatsLine( part )
    local stats_line = ibCreateImage( 0, 0, 630, 40, "images/stats_line.png", UI.reward_bg )
    :center( -36, 90 )
    
    local value_positions = {
        { 40, 5 },
        { 182, 5 },
        { 334, 5 },
        { 493, 5 },
        { 645, 5 },
    }

    local values = {
        part.controllability, part.clutch, part.slip, part.speed, part.acceleration
    }

    local icon_sx, icon_sy = 27 * 0.8, 24 * 0.8

    for i, v in pairs( values ) do
        local px, py = unpack( value_positions[ i ] )
        local is_changed = v ~= 0
        local label = ibCreateLabel( px, py, 0, 0, math.abs( v ), stats_line )
        :ibBatchData( { font = ibFonts.bold_22, color = v < 0 and 0xffff3a3a or v > 0 and 0xff00ff63 or 0xffffffff } )

        if is_changed then
            local icon_texture = v < 0 and ":nrp_tuning_shop/img/icon_arrowdown_red.png" or v > 0 and ":nrp_tuning_shop/img/icon_arrowup_green.png"
            local icon_px, icon_py = label:ibGetAfterX( 0 ), label:ibData( "py" ) + 6
            ibCreateImage( icon_px, icon_py, icon_sx, icon_sy, icon_texture, stats_line )
        end
    end
end