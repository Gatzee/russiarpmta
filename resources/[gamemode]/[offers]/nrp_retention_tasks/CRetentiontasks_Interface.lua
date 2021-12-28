function CreateDataSlider( self, data, parent )
    ibUseRealFonts( true )

    local bg = ibCreateImage( 0, 0, 800, 580, "img/backgrounds/" .. self.id .. ".png", parent )

    -- Заголовок
    ibCreateImage( 0, 20, 0, 0, "img/unique_offer.png", bg ):ibSetRealSize( ):center_x( )

    -- Описание
    ibCreateLabel( 94, 119, 0, 0, self.name, bg, COLOR_WHITE, _, _, _, _, ibFonts.bold_18 )

    local function GenerateReadableDate( ts )
        local months = {
            [ 1 ] = "января",
            [ 2 ] = "февраля",
            [ 3 ] = "марта",
            [ 4 ] = "апреля",
            [ 5 ] = "мая",
            [ 6 ] = "июня",
            [ 7 ] = "июля",
            [ 8 ] = "августа",
            [ 9 ] = "сентября",
            [ 10 ] = "октября",
            [ 11 ] = "ноября",
            [ 12 ] = "декабря",
        }
        local time = os.date( "%m/%d", ts )
        local month, day = unpack( split( time, "/" ) )
        return tonumber( day ) .. " " .. months[ tonumber( month ) ]
    end

    ibCreateLabel( 94, 147, 0, 0, "Акция продлится с " .. GenerateReadableDate( data.timestamp_start ) .. " по " .. GenerateReadableDate( data.timestamp_end ), bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, _, _, ibFonts.regular_16 )

    -- Награды
    local icon_medal = ibCreateImage( 94, 259, 30, 20, "img/icon_medal.png", bg )
    ibCreateLabel( icon_medal:ibGetAfterX( 10 ), icon_medal:ibGetCenterY( ), 0, 0, "Награда за выполнение условия:", bg, 0xffffd236, _, _, "left", "center", ibFonts.regular_16 )

    -- Прогресс
    local progress_bg = ibCreateImage( 94, 417, 280, 14, _, bg, ibApplyAlpha( COLOR_BLACK, 25 ) )
    local progress = math.max( 0, math.min( 1, data.progress ) )
    ibCreateImage( 0, 0, 280 * progress, 14, _, progress_bg, 0xff00b0ff )
    ibCreateLabel( 381, progress_bg:ibGetCenterY( ), 0, 0, data.readable_progress, bg, COLOR_WHITE, _, _, "left", "center", ibFonts.regular_14 )

    -- Время до завершения
    local icon = ibCreateImage( 94, 182, 16, 18, "img/icon_timer.png", bg, ibApplyAlpha( COLOR_WHITE, 50 ) ):ibData( "disabled", true )
    local lbl = ibCreateLabel( icon:ibGetAfterX( 8 ), icon:ibGetCenterY( ), 0, 0, "До завершения:", bg, ibApplyAlpha( 0xffffde96, 50 ), _, _, "left", "center", ibFonts.regular_14 )
    local lbl_timer = ibCreateLabel( lbl:ibGetAfterX( 8 ), icon:ibGetCenterY( ) - 2, 0, 0, getHumanTimeString( data.timestamp_end, true ), bg, 0xffffde96, _, _, "left", "center", ibFonts.bold_18 )

    -- Описание под прогрессом
    ibCreateLabel( 94, 462, 0, 0, self.desc or "-", bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, _, _, ibFonts.regular_16 )

    ibUseRealFonts( false )
    return bg
end

function CreateMoneyReward( self, data, parent )
    local amount = format_price( data.amount )
    local lbl = ibCreateLabel( 94, 283, 0, 0, amount, parent, COLOR_WHITE, _, _, _, _, ibFonts.bold_34 ):ibData( "outline", 1 )
    ibCreateImage( lbl:ibGetAfterX( 8 ), lbl:ibGetCenterY( ) - 17, 40, 34, "img/money_big.png", parent )
end