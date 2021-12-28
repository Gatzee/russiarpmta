loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ib" )

x, y = guiGetScreenSize()

SCREEN_DURATION = 3000
ANIMATION_IN_DURATION = 200
ANIMATION_OUT_DURATION = 600

function ShowRewards( conf )
    if conf[ 1 ] and conf[ 1 ].list then
        conf = conf[ 1 ]
    end

    if not conf or ( not conf.list and not next( conf ) ) then
        ShowRewardsUI( false )
        return
    end

    ShowRewardsUI( true, conf )

    if not conf.no_auto_destroy then
        UI_elements.destruction_timer = setTimer(
            function()
                UI_elements.area:ibAlphaTo( 0, ANIMATION_OUT_DURATION, "InOutQuad" )
                UI_elements.destruction_timer = setTimer(
                    function()
                        ShowRewardsUI( false )
                    end,
                ANIMATION_OUT_DURATION, 1 )
            end,
        SCREEN_DURATION, 1 )
    end
end
addEvent( "ShowRewards", true )
addEventHandler( "ShowRewards", root, ShowRewards )

function ShowRewardsUI( state, conf )
    if state then
        ShowRewardsUI( false )

        UI_elements = { }

        UI_elements.area = ibCreateArea( 0, 0, x, y )
        UI_elements.area:ibBatchData( { alpha = 0, disabled = true, priority = 5 } ):ibAlphaTo( 255, ANIMATION_IN_DURATION, "InOutQuad" )

        if not conf.no_title then
            local tsx, tsy = 670, 376
            local tpx, tpy = ( x - tsx ) / 2, y - tsy + ( conf.offset_y or 0 )
            UI_elements.title = ibCreateImage( tpx, tpy, tsx, tsy, "img/title.png", UI_elements.area )
            -- ibCreateLabel( x / 2, tpy + 191, 0, 0, conf.msg or "ПОЗДРАВЛЯЕМ! ВЫ ПОЛУЧИЛИ НАГРАДУ:", UI_elements.area, 0xFFffd339 )
            --     :ibBatchData( { outline = true, align_x = "center", align_y = "center", font = ibFonts.bold_15 } )
        end

        local real_rewards = { }
        if conf.list then
            real_rewards = conf.list
        else
            for i, v in pairs( conf ) do
                if type( v ) == "table" then
                    table.insert( real_rewards, v )
                end
            end
        end

        local message = type( conf[ 1 ] ) == "string" and conf[ 1 ]

        local isx, isy = 100, 111
        if conf.big then
            isx, isy = 120, 130
        end

        local total_rewards = #real_rewards
        local gap = 10
        local total_width = total_rewards * ( isx + gap ) - gap
        local npx, npy = x / 2 - total_width / 2, y - isy - 50 + ( conf.big and 25 or 0 ) + ( conf.offset_y or 0 )

        ibUseRealFonts( conf.big or false )

        for i, v in ipairs( real_rewards ) do
            local key = "reward_" .. i
            local bg = conf.big and CreateBigReward( npx, npy, isx, isy, v ) or CreateReward( npx, npy, isx, isy, v )

            UI_elements[ key ] = bg
            npx = npx + isx + gap
        end
        
        ibUseRealFonts( false )

        if message then
            ibCreateLabel( x / 2, y - 25, 0, 0, message, UI_elements.area ):ibBatchData( { align_x = "center", align_y = "center", font = ibFonts.regular_13 } )
        end
    else
        for i, v in pairs( UI_elements or { } ) do
            if isTimer( v ) then killTimer( v ) end
            if isElement( v ) then destroyElement( v ) end
        end
        UI_elements = nil
    end
end

function CreateReward( px, py, sx, sy, reward )
    local bg = ibCreateImage( px, py, sx, sy, "img/bg_reward.png", UI_elements.area )

    -- Деньги софтом
    if reward.type == "soft" then
        local isx, isy = 31, 26
        ibCreateImage( sx / 2 - isx / 2, 33, isx, isy, "img/icon_soft.png", bg )
        local value = reward.value or 0
        ibCreateLabel( sx / 2, 81, 0, 0, value, bg ):ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )

    -- Деньги хардом
    elseif reward.type == "hard" then
        local isx, isy = 28, 28
        ibCreateImage( sx / 2 - isx / 2, 32, isx, isy, ":nrp_shared/img/hard_money_icon.png", bg )
        local value = reward.value or 0
        ibCreateLabel( sx / 2, 81, 0, 0, value, bg ):ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )

    -- Опыт
    elseif reward.type == "exp" then
        local isx, isy = 52, 42
        ibCreateImage( sx / 2 - isx / 2, 24, isx, isy, "img/icon_exp.png", bg )
        local value = reward.value or 0
        ibCreateLabel( sx / 2, 81, 0, 0, value, bg ):ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )

    -- Фракционный опыт
    elseif reward.type == "faction_exp" then
        local isx, isy = 52, 42
        ibCreateImage( sx / 2 - isx / 2, 24, isx, isy, ":nrp_shared/img/exp_faction.png", bg )
        local value = reward.value or 0
        ibCreateLabel( sx / 2, 81, 0, 0, value, bg ):ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )

    -- Опыт на срочке
    elseif reward.type == "military_exp" then
        local isx, isy = 52, 42
        ibCreateImage( sx / 2 - isx / 2, 24, isx, isy, ":nrp_shared/img/exp_military.png", bg )
        local value = reward.value or 0
        ibCreateLabel( sx / 2, 81, 0, 0, value, bg ):ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )

    -- Тюнинг деталь
    elseif reward.type == "tuning_internal" then
        local part = reward.value
        local texture = ":nrp_tuning_internal_parts/img/" .. PARTS_IMAGE_NAMES[ part.type ] .. ".png"
        local isx, isy = 60, 60
        ibCreateImage( sx / 2 - isx / 2, 32, isx, isy, texture, bg )

    -- Скидка на авто
    elseif reward.type == "discount" then
        local isx, isy = 45, 43
        ibCreateImage( 0, 0, isx, isy, "img/icon_discount.png", bg ):center( 0, 5 )

    -- Тюнинг кейс
    elseif reward.type == "tuning_case" then
        local case_image = ( reward.value - 1 ) % 3 + 1
        local isx, isy = 166 / 2.5, 168 / 2.5
        ibCreateImage( 0, 0, isx, isy, ":nrp_tuning_cases/images/cases/" .. case_image .. ".png", bg ):center( 0, 5 )

    -- Кейс в F4
    elseif reward.type == "case" then
        ibCreateImage( 0, 0, 0, 0, ":nrp_shop/img/cases/big/" .. reward.value .. ".png", bg )
            :ibSetRealSize( ):ibSetInBoundSize( 94 ):center( 0, 5 )

    -- Хэллоуин
    elseif reward.type == "halloween_coins" then
        ibCreateImage( 0, 0, 28, 28, "img/icon_halloween_coins.png", bg ):center( 0, -8 )
        local value = reward.value or 0
        ibCreateLabel( 0, 81, 0, 0, value, bg ):center_x( ):ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )

	-- Хэллоуин бустер
    elseif reward.type == "halloween_coins_booster" then
        ibCreateImage( 0, 0, 39, 36, "img/icon_halloween_coins_b.png", bg ):center( 0, -8 )
        local value = reward.value or 0
        ibCreateLabel( 0, 81, 0, 0, value, bg ):center_x( ):ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )
        ibCreateLabel( 0, 130, 0, 0, "А столько монет\nты бы получил с бустером", bg ):center_x( ):ibBatchData( { font = ibFonts.bold_8, align_x = "center", align_y = "center" } )

    else
		local img = ibCreateImage( 0, 0, 45, 45, ":nrp_quests/images/rewards/".. reward.type ..".png", bg )

		if reward.value then
			img:center( 0, -8 )
			ibCreateLabel( sx / 2, 81, 0, 0, reward.value, bg ):ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )
		end
    end

    return bg
end

local REWARDS_NAMES = {
    soft = "Деньги",
    money = "Деньги",
    clan_exp = "Ранговый опыт",
    clan_honor = "Очки чести",
    clan_money = "Общак клана",
}

function CreateBigReward( px, py, sx, sy, reward )
    local bg = ibCreateImage( px, py, sx, sy, "img/bg_reward_big.png", UI_elements.area )

    if REWARDS_NAMES[ reward.type ] then
        ibCreateLabel( 0, 34, 0, 0, REWARDS_NAMES[ reward.type ], bg, _, _, _, "center", "center", ibFonts.regular_14 )
            :center_x( )
    end

    if reward.type == "soft" or reward.type == "money" or reward.type == "clan_money" then
        ibCreateImage( 0, 0, 0, 0, "img/icon_soft_big.png", bg )
            :ibSetRealSize( )
            :center( 0, 3 )

    elseif reward.type == "clan_exp" then
        ibCreateImage( 0, 0, 0, 0, ":nrp_clans/img/ui/icon_clan_exp.png", bg )
            :ibSetRealSize( )
            :center( 0, 3 )

    elseif reward.type == "clan_honor" then
        ibCreateImage( 0, 0, 0, 0, ":nrp_clans/img/ui/icon_clan_honor.png", bg )
            :ibSetRealSize( )
            :center( 0, 3 )
    end

    if reward.value then
        ibCreateLabel( 0, 108, 0, 0, reward.value, bg, _, _, _, "center", "center", ibFonts.bold_22 )
            :center_x( )
    end

    return bg
end