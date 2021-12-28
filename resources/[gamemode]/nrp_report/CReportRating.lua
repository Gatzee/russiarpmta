function CreateRateWindow( admin_info_to_rate )
    local fonts_real = ibIsUsingRealFonts( )
    ibUseRealFonts( false )

    showCursor( true )

	local self = { }

	self.sx, self.sy = self.sx or 520, self.sy or 238
	self.px, self.py = self.px or _SCREEN_X_HALF - self.sx / 2, self.py or _SCREEN_Y_HALF - self.sy / 2

	self.elements = { }

    self.elements.black_bg = ibCreateBackground( _, _, true ):ibData( "priority", 100 )
    self.elements.bg = ibCreateImage( self.px, self.py - 100, self.sx, self.sy, ":nrp_shared/img/confirm_bg.png", self.elements.black_bg )
    self.elements.bg:ibData( "alpha", 0 )
    self.elements.bg:ibMoveTo( self.px, self.py, 500 ):ibAlphaTo( 255, 400 )

    -- Заголовок
	self.elements.title = ibCreateLabel( self.sx / 2, 26, 0, 0, "Оценка репорта", self.elements.bg, 0xFFFFFFFF )
    self.elements.title:ibBatchData( { font = ibFonts.bold_14, align_x = "center" } )

    -- Текст
	self.elements.text = ibCreateLabel( 30, 88, self.sx - 60, 0, "Пожалуйста, оцените работу администрации", self.elements.bg, 0xFFBBBBBB )
    self.elements.text:ibBatchData( { font = ibFonts.regular_12, align_x = "center", wordbreak = true } )

    self.elements.btns_area = ibCreateArea( 0, 146, 60 * 5, 0, self.elements.bg ):center_x( )
    for i = 1, 5 do
        local btn = ibCreateButton(	60 * ( i - 1 ), 0, 44, 44, self.elements.btns_area, "img/btn_circle.png", _, _,  0x50FFFFFF, 0xB0FFFFFF, 0xFFFFFFFF)
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                self.elements.black_bg:destroy()
                showCursor( IS_REPORT_OPEN )
                triggerServerEvent( "onPlayerRateAdmin", localPlayer, admin_info_to_rate, i )
            end, false )

        ibCreateLabel( 0, 0, 44, 44, i, btn, 0xFFFFFFFF )
            :ibBatchData( { font = ibFonts.bold_14, align_x = "center", align_y = "center", disabled = true } )
    end

    ibUseRealFonts( fonts_real )

	return self
end
addEvent( "onClientOpenRateReportWindow", true )
addEventHandler( "onClientOpenRateReportWindow", root, CreateRateWindow )