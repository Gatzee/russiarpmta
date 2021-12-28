
local UI_elements

function ShowRewardUI( state, data )
    if state and data then
        ShowRewardUI( false )

        UI_elements = { }
        local coeffX, coeffY = scX / 1280, scY / 720

        UI_elements.reward_bg = ibCreateBackground( 0xDD394A5C, _, true )
        :ibData( "alpha", 0 )

         ibCreateImage( 0, 0, 800 * coeffX, 570 * coeffY, "files/img/reward/brush.png", UI_elements.reward_bg )
         :center( 0, 0 )

        --Хидер
        UI_elements.lbl_title = ibCreateLabel( 0, 145 * coeffY, scX, 0, "Поздравляем! Вы получили:", UI_elements.reward_bg, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts[ "bold_" .. math.floor( 18 *  coeffY) ] )
        local reward = SEASON_REWARD[ data.season_number ][ data.race_type ][ data.place ][ 1 ]        
        if reward.type == "vinil" then            
            UI_elements.reward_text = ibCreateLabel( 0, 0, 0, 0, "Уникальный винил", UI_elements.reward_bg, 0xFF87ed72, 1, 1, "center", "center", ibFonts[ "bold_" .. math.floor( 18 *  coeffY) ] )
            :center( 0, 25 * coeffY )

            local sx = 200 * coeffX
            UI_elements.reward_icon = ibCreateImage( 0, 0, sx, 94 * coeffY, ":nrp_vinyls/img/" .. reward.value .. ".dds", UI_elements.reward_bg )
            
            local sx, sy = UI_elements.reward_icon:ibData( "sx" ), UI_elements.reward_icon:ibData( "sy" )
            UI_elements.reward_icon:ibBatchData( { sx = sx * coeffX, sy = sy * coeffY })
            :center( 0, -80 * coeffY )
        elseif reward.type == "accessories" then
            
            UI_elements.reward_text = ibCreateLabel( 0, 0, 0, 0, CONST_ACCESSORIES_INFO[ reward.value ].name, UI_elements.reward_bg, 0xFF87ed72, 1, 1, "center", "center", ibFonts[ "bold_" .. math.floor( 18 *  coeffY) ] )
            :center()

            UI_elements.reward_icon = ibCreateContentImage( 0, 0, 90, 90, "accessory", reward.value, UI_elements.reward_bg )
            :ibSetInBoundSize( 80, 80 )

            local sx, sy = UI_elements.reward_icon:ibData( "sx" ), UI_elements.reward_icon:ibData( "sy" )
            UI_elements.reward_icon:ibBatchData( { sx = sx * coeffX, sy = sy * coeffY })
            :center( 0, -110 )
        elseif reward.type == "vinil_case" then
            UI_elements.reward_text = ibCreateLabel( 0, 0, 0, 0, "Винил кейс \"" .. CASES_NAME[ "vinyl_" .. reward.value ] .. "\"", UI_elements.reward_bg, 0xFF87ed72, 1, 1, "center", "center", ibFonts[ "bold_" .. math.floor( 18 *  coeffY) ] )
            :center( 0, 90 )

            UI_elements.reward_icon = ibCreateContentImage( 0, 0, 372, 252, "case", "vinyl_" .. reward.value, UI_elements.reward_bg )
            :ibSetInBoundSize( 259, 192 )

            local sx, sy = UI_elements.reward_icon:ibData( "sx" ), UI_elements.reward_icon:ibData( "sy" )
            UI_elements.reward_icon:ibBatchData( { sx = sx * coeffX, sy = sy * coeffY })
            :center( 0, -80 )
        elseif reward.type == "tuning_case" then
            UI_elements.reward_text = ibCreateLabel( 0, 0, 0, 0, "Тюнинг кейс \"" .. CASES_NAME[ "tuning_" .. reward.value ] .. "\"", UI_elements.reward_bg, 0xFF87ed72, 1, 1, "center", "center", ibFonts[ "bold_" .. math.floor( 18 *  coeffY) ] )
            :center( 0, 90 )

            UI_elements.reward_icon = ibCreateContentImage( 0, 0, 372, 252, "case", "tuning_" .. reward.value, UI_elements.reward_bg )
            :ibSetInBoundSize( 355, 200 )

            local sx, sy = UI_elements.reward_icon:ibData( "sx" ), UI_elements.reward_icon:ibData( "sy" )
            UI_elements.reward_icon:ibBatchData( { sx = sx * coeffX, sy = sy * coeffY })
            :center( 0, -80 )
        end

        UI_elements.lbl_race_position = ibCreateLabel( 0, 475 * coeffY, scX, 0, "Ваша позиция в списке победителей: " .. data.place .. "\nНоминация: " .. RACE_TYPES_DATA[ data.race_type ].name, 
            UI_elements.area_race_position, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts[ "regular_" .. math.floor( 16 *  coeffY) ] )

        --Забрать
        local tex_take = dxCreateTexture( "files/img/reward/btn_take.png" )
        UI_elements.btn_take = ibCreateButton(	(scX - 140 * coeffX) / 2, 550 * coeffY, 140 * coeffX, 54 * coeffY, UI_elements.reward_bg, tex_take, tex_take, tex_take, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            
            triggerServerEvent( "onPlayerTryTakeRaceReward", localPlayer )
            ShowRewardUI( false )
        end )

        UI_elements.reward_bg:ibAlphaTo( 255, 500 )
        playSound( ":nrp_shop/sfx/reward_small.mp3" )

        showCursor( true )
    else
        DestroyTableElements( UI_elements )
        UI_elements = nil
        showCursor( false )
    end
end

function ShowRaceSeasonRewardUI_handler( data )
    ShowRewardUI( true, data )
end
addEvent( "ShowRaceSeasonRewardUI", true )
addEventHandler( "ShowRaceSeasonRewardUI", resourceRoot, ShowRaceSeasonRewardUI_handler )