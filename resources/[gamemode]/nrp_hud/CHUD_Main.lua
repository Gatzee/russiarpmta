HUD_CONFIGS.main = {
    order = 1000,
    elements = { },

    create = function( self )
        local bg = ibCreateImage( 0, 0, 340, 156, _, _, 0xd72a323c )
        
        ibCreateImage( 0, 0, 340, 156, "img/bg_main.png", bg )
        self.elements.bg = bg

        -- Разделители
        self.elements.sep1 = ibCreateImage( 135, 0, 1, 156, _, bg, COLOR_WHITE ):ibData( "alpha", 255*0.2 )
        self.elements.sep2 = ibCreateImage( 0, 70, 135, 1, _, bg, COLOR_WHITE ):ibData( "alpha", 255*0.2 )
        self.elements.sep3 = ibCreateImage( 0, 101, 135, 1, _, bg, COLOR_WHITE ):ibData( "alpha", 255*0.2 )

        -- Деньги
        self.elements.lbl_money = ibCreateLabel( 198, 12, 0, 0, "0", bg, nil, nil, nil, nil, nil, ibFonts.oxaniumbold_16 )

        -- Жизни
        self.elements.lbl_health = ibCreateLabel( 304, 49, 0, 0, "100", bg, _, nil, nil, nil, nil, ibFonts.oxaniumbold_10 )
        self.elements.bar_health = ibCreateImage( 158, 57, 0, 4, _, bg, 0xffff4b4b )

        -- Выносливость
        self.elements.lbl_stamina = ibCreateLabel( 304, 73, 0, 0, "100", bg, _, nil, nil, nil, nil, ibFonts.oxaniumbold_10 )
        self.elements.bar_stamina = ibCreateImage( 158, 80, 0, 4, _, bg, 0xff0096e6 )

        -- Еда
        self.elements.lbl_calories = ibCreateLabel( 304, 99, 0, 0, "100", bg, _, nil, nil, nil, nil, ibFonts.oxaniumbold_10 )
        self.elements.bar_calories = ibCreateImage( 158, 106, 0, 4, _, bg, 0xfff6a943 )

        -- Броня
        self.elements.lbl_armor = ibCreateLabel( 304, 125, 0, 0, "100", bg, _, nil, nil, nil, nil, ibFonts.oxaniumbold_9 )
        self.elements.bar_armor = ibCreateImage( 242, 131, 0, 4, _, bg, 0xffa8c3ff )

        -- Воздух
        self.elements.lbl_air = ibCreateLabel( 226, 125, 0, 0, "100", bg, _, nil, nil, "center", nil, ibFonts.oxaniumbold_9 )
        self.elements.bar_air = ibCreateImage( 158, 131, 0, 4, _, bg, 0xff63545c )

        -- Кольцо опыта
        self.elements.radial_shader = dxCreateShader( "fx/circle_exp.fx" )
        self.elements.radial_texture = dxCreateTexture( "img/circle_exp.png" )
        dxSetShaderValue( self.elements.radial_shader, "tex", self.elements.radial_texture )
        dxSetShaderValue( self.elements.radial_shader, "angle", 1 )
        self.elements.bg_circle = ibCreateImage( 16, 10, 47, 47, "img/bg_exp.png", bg )
        self.elements.img_circle = ibCreateImage( 0, 0, 47, 47, self.elements.radial_shader, self.elements.bg_circle, 0xffe3ca41 ):ibData( "rotation", 90 )

        -- Уровень
        self.elements.lbl_level = ibCreateLabel( 0, 0, 47, 47, "1", self.elements.bg_circle, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_16 )

        -- Опыт
        self.elements.lbl_exp = ibCreateLabel( 71, 10, 0, 47, "", bg, 0xff999999, nil, nil, nil, "center", ibFonts.oxaniumregular_9 )

        -- Социальный рейтинг
        local iRating = localPlayer:GetSocialRating()

        self.elements.rating_area = ibCreateArea( 0, 71, 135, 30, bg )
        self.elements.icon_rating = ibCreateImage( 30, 0, 43, 15, iRating >= 0 and "img/icon_wings.png" or "img/icon_horns.png", self.elements.rating_area )
        :ibSetRealSize():center_y()
        self.elements.lbl_rating = ibCreateLabel( 77, 0, 0, 30, iRating, self.elements.rating_area, nil, nil, nil, "left", "center", ibFonts.oxaniumbold_12 )

        -- Болезнь
        self.elements.bg_disease = ibCreateImage( 19, 112, 34, 34, "img/bg_disease.png", bg )
        self.elements.circle_disease_bg = ibCreateImage( 0, 0, 36, 36, "img/circle_disease_bg.png", self.elements.bg_disease ):center()
        self.elements.circle_disease = ibCreateImage( 0, 0, 36, 36, "img/circle_disease_1.png", self.elements.circle_disease_bg ):center()
        :ibData("alpha", 0)

        self.elements.disease_icon = ibCreateImage( 0, 0, 0, 0, "img/icon_skull.png", self.elements.bg_disease, 0xffe3cc27 )
        :ibSetRealSize():center()

        self.elements.lbl_disease = ibCreateLabel( 68, 130, 0, 0, "Болезнь:\n1 стадия", bg, 0xff999999, nil, nil, nil, "center", ibFonts.regular_10 )

        -- Обновление содержимого
        self.elements.timer = setTimer( RefreshOther, 200, 0 )
        RefreshOther( )

        -- Деньги, опыт, др
        addEventHandler( "onClientElementDataChange", localPlayer, RefreshElementData )
        RefreshElementData( )
        return bg
    end,

    destroy = function( self )
        removeEventHandler( "onClientElementDataChange", localPlayer, RefreshElementData )
        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}

function RefreshElementData( key, old )
    local is_empty = not key

    local id = "main"
    local self = HUD_CONFIGS[ id ]

    if is_empty or key == "money" then
        local money = getElementData( localPlayer, "money" ) or 0
        self.elements.lbl_money:ibData( "text", format_price( money ) )

        if old then
            self.elements.lbl_money:ibAlphaTo( 0, 100 )

            local bg = self.elements.bg -- 0xFFB6F4B6 / 0xFFF4B6B6
            local diff = money - old
            local diff = diff > 0 and "+" .. format_price( diff ) or format_price( diff )
            if isElement( self.elements.lbl_money_change ) then destroyElement( self.elements.lbl_money_change ) end
            self.elements.lbl_money_change = ibCreateLabel( 198, 12, 0, 0, diff, bg, money > old and 0xFFB6F4B6 or 0xFFF4B6B6, nil, nil, nil, nil, ibFonts.bold_16 ):ibData( "alpha", 0 )
            self.elements.lbl_money_change:ibAlphaTo( 255, 100 )

            if isTimer( self.elements.money_timer ) then killTimer( self.elements.money_timer ) end
            self.elements.money_timer = setTimer(
                function( )
                    self.elements.lbl_money_change:ibAlphaTo( 0, 100 )
                    self.elements.lbl_money:ibAlphaTo( 255, 100 )
                    self.elements.money_timer = setTimer(
                        function( )
                            self.elements.lbl_money_change:destroy( )
                        end
                    , 100, 1 )
                end
            , 2000, 1 )
        end
    end

    if is_empty or key == "exp" or key == "level" then
        -- Кольцо опыта
        local level, exp = localPlayer:GetLevel( ), localPlayer:GetExp( )
        local required_exp = LEVELS_EXPERIENCE[ level ]
        local percentage = required_exp and math.max( 0, math.min( 1, exp / required_exp ) ) or 1
        dxSetShaderValue( self.elements.radial_shader, "dg", percentage * 2 )

        -- Опыт
        if not required_exp then
            self.elements.lbl_exp:ibData( "text", "MAX\nLEVEL" )
        else
            self.elements.lbl_exp:ibData( "text", exp .. " /\n" .. required_exp )
        end

        if old then
            local diff = exp - old
            local diff = diff > 0 and "+" .. diff or diff
            if isElement( self.elements.lbl_exp_change ) then destroyElement( self.elements.lbl_exp_change ) end
            self.elements.lbl_exp_change = ibCreateLabel( 0, 0, 0, 0, diff, self.elements.lbl_exp, exp > old and 0xFFB6F4B6 or 0xFFF4B6B6, nil, nil, "left", "center", ibFonts.oxaniumregular_9 ):ibData( "alpha", 0 )
            self.elements.lbl_exp_change:ibAlphaTo( 255, 100 )

            if isTimer( self.elements.exp_timer ) then killTimer( self.elements.exp_timer ) end
            self.elements.exp_timer = setTimer(
                function( )
                    self.elements.lbl_exp_change:ibAlphaTo( 0, 100 )
                    self.elements.exp_timer = setTimer(
                        function( )
                            self.elements.lbl_exp_change:destroy( )
                        end
                    , 100, 1 )
                end
            , 2000, 1 )
        end
    end

    if is_empty or key == "social_rating" then
        local iRating = localPlayer:GetSocialRating()

        self.elements.lbl_rating:ibData( "text", iRating )
        self.elements.icon_rating:ibData( "texture", iRating >= 0 and "img/icon_wings.png" or "img/icon_horns.png" )
        :ibSetRealSize():center_y()

        if old then
            local diff = iRating - old
            local s_diff = diff > 0 and "+" .. diff or diff

            if isElement( self.elements.icon_rating_change ) then destroyElement( self.elements.icon_rating_change ) end
            if isElement( self.elements.lbl_rating_change ) then destroyElement( self.elements.lbl_rating_change ) end

            self.elements.rating_area:ibMoveTo( -22, _, 300, "InOutQuad" )

            self.elements.icon_rating:ibTimer(function()
                self.elements.lbl_rating_change = ibCreateLabel( self.elements.lbl_rating:ibGetAfterX( 4 ), 0, 0, 30, s_diff, 
                    self.elements.rating_area, diff > 0 and 0xff8dff6f or 0xffe73f5e, _, _, "left", "center", ibFonts.oxaniumregular_12 )
                :ibData("outline", 1)

                self.elements.icon_rating_change = ibCreateImage( self.elements.lbl_rating_change:ibGetAfterX( 4 ), 0, 11, 8, diff >= 0 and "img/icon_rating_up.png" or "img/icon_rating_down.png", self.elements.rating_area )
                :center_y()
            end, 300, 1)

            self.elements.icon_rating:ibTimer(function()
                self.elements.lbl_rating_change:ibAlphaTo( 0, 300 )
                self.elements.icon_rating_change:ibAlphaTo( 0, 300 )

                self.elements.rating_area:ibMoveTo( 0, _, 300, "InOutQuad" )
            end, 1300, 1)
        end
    end
end

function RefreshOther( )
    local id = "main"
    local self = HUD_CONFIGS[ id ]

    -- Жизни
    local max_health = localPlayer:getData( "max_health" ) or 100
    local health = getElementHealth( localPlayer )
    health = ( max_health - health < 1 ) and max_health or math.floor( health )
    self.elements.lbl_health:ibData( "text", health )
    self.elements.bar_health:ibResizeTo( math.min( 1, health / max_health ) * 112, 4, 200 )

    -- Выносливость
    local max_stamina = localPlayer:getData( "max_stamina" ) or 100
    local stamina = math.floor( localPlayer:GetStamina( ) )
    self.elements.lbl_stamina:ibData( "text", stamina )
    self.elements.bar_stamina:ibResizeTo( math.min( 1, stamina / max_stamina ) * 112, 4, 200 )

    -- Еда
    local max_calories = localPlayer:getData( "max_calories" ) or 100
    local calories = math.floor( localPlayer:GetCalories( ) )
    self.elements.lbl_calories:ibData( "text", calories )
    self.elements.bar_calories:ibResizeTo( math.min( 1, calories / max_calories ) * 112, 4, 200 )

    -- Броня
    local armor = math.floor( getPedArmor( localPlayer ) )
    self.elements.lbl_armor:ibData( "text", armor )
    self.elements.bar_armor:ibResizeTo( armor / 100 * 28, 4, 200 )

    -- Воздух
    local air = math.floor( getPedOxygenLevel( localPlayer ) / 10 )
    self.elements.lbl_air:ibData( "text", air )
    self.elements.bar_air:ibResizeTo( air / 100 * 28, 4, 200 )

    -- Уровень
    self.elements.lbl_level:ibData( "text", localPlayer:GetLevel( ) )
    --self.elements.lbl_level_sub:ibData( "px", 95 + self.elements.lbl_level:width( ) )

    -- Цвет радиалки уровня
    dxSetShaderValue( self.elements.radial_shader, "rgba", 255, 236, 161 )

    -- Болезнь
    SetDiseaseStageHud( self )
end

function MAIN_onStart( )
    if localPlayer:IsInGame( ) then
        AddHUDBlock( "main" )
    end
end
addEventHandler( "onClientResourceStart", resourceRoot, MAIN_onStart )

function onClientPlayerNRPSpawn_handler( spawn_mode )
    if spawn_mode == 3 then return end
    MAIN_onStart( )
end
addEvent( "onClientPlayerNRPSpawn", true )
addEventHandler( "onClientPlayerNRPSpawn", root, onClientPlayerNRPSpawn_handler )

function GetMainBG( )
    return HUD_CONFIGS.main.elements.bg
end

function SetDiseaseStageHud( self )
    local pDiseaseConfig = 
    {
        [1] = { color = 0xffe3cc27, text = "Болезнь:\n1 стадия" },
        [2] = { color = 0xffc56700, text = "Болезнь:\n2 стадия" },
        [3] = { color = 0xffd50909, text = "Болезнь:\n3 стадия" },
        [4] = { color = 0xffffffff, text = "Вы\nздоровы", bias_x = 1, bias_y = 1 },
    }

    local has_disease = localPlayer:HasDisease( )
    local stage_disease = localPlayer:GetDiseaseStage( ) or 4

    local pConf = pDiseaseConfig[ stage_disease ]

    self.elements.circle_disease:ibData("alpha", has_disease and 255 or 0)
    self.elements.disease_icon:ibData( "texture", has_disease and "img/icon_skull.png" or "img/icon_healthy.png" )
    :ibSetRealSize( )
    :center( pConf.bias_x or 0, pConf.bias_y or 0 )
    :ibData( "color", pConf.color )

    self.elements.lbl_disease:ibData( "text", pDiseaseConfig[ stage_disease ].text )

    if has_disease then
        self.elements.circle_disease:ibData( "texture", "img/circle_disease_"..stage_disease..".png" )
    end
end