
function ShowSuccessRate( result_rate )
    if isElement( UI_elements.black_bg_result ) then
        destroyElement( UI_elements.black_bg_result )
    end

    UI_elements.black_bg_result = ibCreateBackground( 0xAA181818, _, true )
    ibCreateImage( 0, 0, scX, scY, "img/reward/bg_green.png", UI_elements.black_bg_result )
    UI_elements.text_effect_result = ibCreateImage( 0, 120 * cfY, scX, 26 * cfY, "img/reward/green_text_effect.png", UI_elements.black_bg_result )
    ibCreateLabel( 0, 0, scX, 18 * cfY, result_rate.is_black_jack and "БЛЕК ДЖЕК" or "ВЫ ПОБЕДИЛИ", UI_elements.text_effect_result, 0xFF54FF68, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 36 * cfY ) ] )
    
    UI_elements.bg_reward_text = ibCreateImage( (scX - 939 * cfX) / 2, scY - 500 * cfY, 939 * cfX, 416 * cfY, "img/reward/reward_text_effect.png", UI_elements.black_bg_result )
    ibCreateLabel( 0, 0, 939 * cfX, 416 * cfY, "ПОЗДРАВЛЯЕМ! ВАШ ВЫИГРЫШ:", UI_elements.bg_reward_text, 0xFFFFD339, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 21 * cfY ) ] )

    UI_elements.box_reward = ibCreateImage( (scX - 120 * cfX) / 2, scY - 235 * cfY, 120 * cfX, 120 * cfX, "img/reward/block_reward.png", UI_elements.black_bg_result )
    ibCreateImage( 37 * cfX, 20 * cfY, 47 * cfX, 40 * cfY, "img/big_soft.png", UI_elements.box_reward )
    ibCreateLabel( 0, 80 * cfY, 120 * cfX, 40 * cfY, format_price( result_rate.game_rate_result or 0 ), UI_elements.box_reward, 0xFFFFFFFF, _, _, "center", "top", ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] )
    
    ibGetRewardSound()
end

function ShowDrawRate( result_rate )
    if isElement( UI_elements.black_bg_result ) then
        destroyElement( UI_elements.black_bg_result )
    end
    
    UI_elements.black_bg_result = ibCreateBackground( 0xAA181818, _, true )
    
    ibCreateImage( 0, 0, scX, scY, "img/reward/bg_yellow.png", UI_elements.black_bg_result )
    UI_elements.text_effect_result = ibCreateImage( 0, 120 * cfX, scX, 26 * cfY, "img/reward/yellow_text_effect.png", UI_elements.black_bg_result )
    ibCreateLabel( 0, 0, scX, 18 * cfY, "НИЧЬЯ", UI_elements.text_effect_result, 0xFFFFD854, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 36 * cfY ) ] )
    
    UI_elements.bg_reward_text = ibCreateImage( (scX - 939 * cfX) / 2, scY - 500 * cfY, 939 * cfX, 416 * cfY, "img/reward/reward_text_effect.png", UI_elements.black_bg_result )
    ibCreateLabel( 0, 0, 939 * cfX, 416 * cfY, "ВАШ ВЫИГРЫШ:", UI_elements.bg_reward_text, 0xFFFFD339, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 21 * cfY ) ] )

    UI_elements.box_reward = ibCreateImage( (scX - 120 * cfX) / 2, scY - 235 * cfY, 120 * cfX, 120 * cfX, "img/reward/block_reward.png", UI_elements.black_bg_result )
    ibCreateImage( 37 * cfX, 20 * cfY, 47 * cfX, 40 * cfY, "img/big_soft.png", UI_elements.box_reward )
    ibCreateLabel( 0, 80 * cfY, 120 * cfX, 40 * cfY, format_price( result_rate.game_rate_result or 0 ), UI_elements.box_reward, 0xFFFFFFFF, _, _, "center", "top", ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] )
end

function ShowFailRate( result_rate )
    if isElement( UI_elements.black_bg_result ) then
        destroyElement( UI_elements.black_bg_result )
    end
    
    UI_elements.black_bg_result = ibCreateBackground( 0xAA181818, _, true )
    
    ibCreateImage( 0, 0, scX, scY, "img/reward/bg_red.png", UI_elements.black_bg_result )
    UI_elements.text_effect_result = ibCreateImage( 0, 120 * cfX, scX, 26 * cfY, "img/reward/red_text_effect.png", UI_elements.black_bg_result )
    ibCreateLabel( 0, 0, scX, 18 * cfY, "ВЫ ПРОИГРАЛИ", UI_elements.text_effect_result, 0xFFD42D2D, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 36 * cfY ) ] )

    UI_elements.box_reward = ibCreateImage( (scX - 120 * cfX) / 2, scY - 235 * cfY, 120 * cfX, 120 * cfX, "img/reward/block_reward.png", UI_elements.black_bg_result )
    ibCreateImage( 37 * cfX, 20 * cfY, 47 * cfX, 40 * cfY, "img/big_soft.png", UI_elements.box_reward )
    ibCreateLabel( 0, 80 * cfY, 120 * cfX, 40 * cfY, format_price( result_rate.game_rate_result or 0 ), UI_elements.box_reward, 0xFFFFFFFF, _, _, "center", "top", ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] )
end

function onClientPlayerShowResultRate_handler( result_rate )
    if not UI_elements then return end

    if result_rate.game_result == BLACK_JACK_RESULT_WIN then
        ShowSuccessRate( result_rate )
    elseif result_rate.game_result == BLACK_JACK_RESULT_DRAW then
        ShowDrawRate( result_rate )
    elseif result_rate.game_result == BLACK_JACK_RESULT_LOSE then
        ShowFailRate( result_rate )
    end

    setTimer( function() 
        if not isElement( UI_elements and UI_elements.black_bg_result ) then return end
        UI_elements.black_bg_result:ibAlphaTo( 0, 250 )
        setTimer( function()
            if not isElement( UI_elements and UI_elements.black_bg_result ) then return end
            destroyElement( UI_elements.black_bg_result )
        end, 250, 1 )
    end, 2000, 1 )
end
addEvent( "onClientPlayerShowResultRate", true )
addEventHandler( "onClientPlayerShowResultRate", resourceRoot, onClientPlayerShowResultRate_handler )