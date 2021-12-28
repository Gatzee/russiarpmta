loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )
Extend( "CAI" )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )

local UI_elements = nil
local cfX, cfY = _SCREEN_X / 1920 * 1.1, _SCREEN_Y / 1080 * 1.1

function ShowSuccessRate( result_rate )
    UI_elements = {}
    UI_elements.black_bg_result = ibCreateBackground( 0xAA181818, _, true )
    ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, ":nrp_casino_black_jack/img/reward/bg_green.png", UI_elements.black_bg_result )
    UI_elements.text_effect_result = ibCreateImage( 0, 120 * _SCREEN_Y, _SCREEN_X, 26 * cfY, ":nrp_casino_black_jack/img/reward/green_text_effect.png", UI_elements.black_bg_result )
    ibCreateLabel( 0, 0, _SCREEN_X, 18 * cfY, "ВЫ ПОБЕДИЛИ", UI_elements.text_effect_result, 0xFF54FF68, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 36 * cfY ) ] )
    
    UI_elements.bg_reward_text = ibCreateImage( (_SCREEN_X - 939 * cfX) / 2, _SCREEN_Y - 500 * cfY, 939 * cfX, 416 * cfY, ":nrp_casino_black_jack/img/reward/reward_text_effect.png", UI_elements.black_bg_result )
    ibCreateLabel( 0, 0, 939 * cfX, 416 * cfY, "ПОЗДРАВЛЯЕМ! ВАШ ВЫИГРЫШ:", UI_elements.bg_reward_text, 0xFFFFD339, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 21 * cfY ) ] )

    UI_elements.box_reward = ibCreateImage( (_SCREEN_X - 120 * cfX) / 2, _SCREEN_Y - 235 * cfY, 120 * cfX, 120 * cfX, ":nrp_casino_black_jack/img/reward/block_reward.png", UI_elements.black_bg_result )
    ibCreateImage( 37 * cfX, 20 * cfY, 47 * cfX, 40 * cfY, ":nrp_casino_black_jack/img/big_soft.png", UI_elements.box_reward )
    ibCreateLabel( 0, 80 * cfY, 120 * cfX, 40 * cfY, format_price( result_rate or 0 ), UI_elements.box_reward, 0xFFFFFFFF, _, _, "center", "top", ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] )
    
    ibGetRewardSound()
end

function ShowFailRate( result_rate )
    UI_elements = {}
    UI_elements.black_bg_result = ibCreateBackground( 0xAA181818, _, true )
    
    ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, ":nrp_casino_black_jack/img/reward/bg_red.png", UI_elements.black_bg_result )
    UI_elements.text_effect_result = ibCreateImage( 0, 120 * cfX, _SCREEN_X, 26 * cfY, ":nrp_casino_black_jack/img/reward/red_text_effect.png", UI_elements.black_bg_result )
    ibCreateLabel( 0, 0, _SCREEN_X, 18 * cfY, "ВЫ ПРОИГРАЛИ", UI_elements.text_effect_result, 0xFFD42D2D, _, _, "center", "center", ibFonts[ "bold_" .. math.ceil( 36 * cfY ) ] )

    UI_elements.box_reward = ibCreateImage( (_SCREEN_X - 120 * cfX) / 2, _SCREEN_Y - 235 * cfY, 120 * cfX, 120 * cfX, ":nrp_casino_black_jack/img/reward/block_reward.png", UI_elements.black_bg_result )
    ibCreateImage( 37 * cfX, 20 * cfY, 47 * cfX, 40 * cfY, ":nrp_casino_black_jack/img/big_soft.png", UI_elements.box_reward )
    ibCreateLabel( 0, 80 * cfY, 120 * cfX, 40 * cfY, format_price( result_rate or 0 ), UI_elements.box_reward, 0xFFFFFFFF, _, _, "center", "top", ibFonts[ "bold_" .. math.ceil( 20 * cfY ) ] )
end

function ShowGameResult( success, data )
	local show_func = success and ShowSuccessRate or ShowFailRate
	show_func( 1000 )

	GEs._hide_tmr = setTimer( function() 
        if not isElement( UI_elements and UI_elements.black_bg_result ) then return end

        UI_elements.black_bg_result:ibAlphaTo( 0, 250 )
        setTimer( function()
            if not isElement( UI_elements and UI_elements.black_bg_result ) then return end
            destroyElement( UI_elements.black_bg_result )
        end, 250, 1 )
    end, 2000, 1 )
end