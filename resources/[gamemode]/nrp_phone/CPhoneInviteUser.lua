INVITE_USER_APP = nil
INVITE_CODES = nil

APPLICATIONS.invite_user = {
    id = "invite_user",
    icon = "img/apps/invite_user.png",
    name = "Пригласить игрока",
    first_open_ts =  0,
    elements = { },

    -- get_notifications_count = function( self )
    --     return 
    -- end,

    create = function( self, parent, conf )
        INVITE_USER_APP = self
		ibUseRealFonts( true )

        self.parent = parent
        self.conf = conf

        self.elements.bg          = ibCreateArea( 0, 0, 204, 0, parent )
        self.elements.header      = ibCreateImage( 0, 0, 204, 55, "img/elements/app_header.png", self.elements.bg )
        self.elements.header_text = ibCreateLabel( 0, 25, 0, 0, "Пригласить игрока", self.elements.header, 0xFFFFFFFF, _, _, "center" ):ibData( "font", ibFonts.bold_12 ):center_x()

        if #INVITE_CODES > 0 then
            ibCreateImage( 87, 69, 30, 30, "img/elements/invite_user/icon.png", self.elements.bg )
            ibCreateLabel( 0, 119, 0, 0, "Приглашай игроков NextRP\nна первый Full RP сервер!", self.elements.bg, ibApplyAlpha( 0xFFFFFFFF, 50 ), _, _, "center", "center", ibFonts.regular_10 ):center_x()

            self.elements.lbl_email   = ibCreateLabel( 0, 146, 0, 0, "Пригласительные коды:", self.elements.bg, 0xFFFFFFFF, _, _, "center", "center", ibFonts.regular_11 ):center_x()

            self:create_codes_list()

            local footer_bg = ibCreateImage( 0, 301, 204, 61, _, self.elements.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
            local line = ibCreateImage( 0, 0, 204, 1, _, footer_bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
            ibCreateLabel( 0, 332, 0, 0, "Каждые 2 уровня\nты получаешь \nдополнительный код", self.elements.bg, 0xFFff6363, _, _, "center", "center", ibFonts.bold_10 ):center_x()
        else
            ibCreateImage( 87, 127, 30, 30, "img/elements/invite_user/icon.png", self.elements.bg )
            local level = localPlayer:GetLevel()
            local next_level = level + ( 2 - level % 2 )
            ibCreateLabel( 0, 168, 0, 0, "На данный момент у вас\nне осталось пригласительных\nкодов.\n\nВы получите новый код\nпри достижении " ..next_level .. " уровня.", self.elements.bg, 0xFFFFFFFF, _, _, "center", "top", ibFonts.regular_11 ):center_x()
        end

		ibUseRealFonts( false )
        return self
    end,

    create_codes_list = function( self )
        if isElement( self.elements.rt ) then
            self.elements.rt:destroy()
            self.elements.sc:destroy()
        end

        local rt_py = 161
        local rt_sy = 140
        self.elements.rt, self.elements.sc = ibCreateScrollpane( 0, rt_py, 204, rt_sy, self.elements.bg, { scroll_px = -17, } )
        self.elements.sc:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.1 )

        local line_upper = ibCreateImage( 0, rt_py - 1, 204, 1, _, self.elements.bg, ibApplyAlpha( COLOR_BLACK, 20 ) )

        for i, code in pairs( INVITE_CODES ) do
            local area = ibCreateArea( 0, ( i - 1 ) * 35, 204, 35, self.elements.rt )
            local lbl_code = ibCreateLabel( 25, 17, 0, 0, code, area, ibApplyAlpha( 0xFFFFFFFF, 75 ), _, _, "left", "center", ibFonts.regular_12 )
            local lbl_copied = ibCreateLabel( 25, 17, 0, 0, "Код скопирован", area, ibApplyAlpha( 0xFF38c175, 80 ), _, _, "left", "center", ibFonts.regular_12 ):ibData( "alpha", 0 )
            local btn_copy = ibCreateImage( 164, 10, 14, 14, "img/elements/invite_user/btn_copy.png", area ):ibData( "disabled", true ):ibData( "alpha", 255 * 0.4 )
            area
                :ibOnHover( function() btn_copy:ibAlphaTo( 255 ) end )
                :ibOnLeave( function() btn_copy:ibAlphaTo( 255 * 0.4 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    setClipboard( code )
                    lbl_code:ibAlphaTo( 0, 100 ):ibTimer( ibAlphaTo, 2100, 1, 255 )
                    lbl_copied:ibAlphaTo( 255 ):ibTimer( ibAlphaTo, 2000, 1, 0 )
                end )

            local line = ibCreateImage( 0, 35, 204, 1, _, area, ibApplyAlpha( COLOR_BLACK, 20 ) )
        end

        self.elements.rt:AdaptHeightToContents( )
        self.elements.sc:UpdateScrollbarVisibility( self.elements.rt )
    end,

    destroy = function( self, parent, conf )
        if confirmation then confirmation:destroy() end
        DestroyTableElements( self.elements )
        INVITE_USER_APP = nil
    end,
}

addEvent( "onInviteCodesReceive", true )
addEventHandler( "onInviteCodesReceive", root, function( codes )
    INVITE_CODES = codes

    if fileExists( "invite_user_first_open_ts" ) then 
        local file = fileOpen( "invite_user_first_open_ts" )
        if file then
            APPLICATIONS.invite_user.first_open_ts = tonumber( fileRead( file, fileGetSize( file ) ) ) or 0
            fileClose( file )
        end
    else
        local file = fileCreate( "invite_user_first_open_ts" )
        APPLICATIONS.invite_user.first_open_ts = getRealTimestamp()
        fileWrite( file, tostring( APPLICATIONS.invite_user.first_open_ts ) )
        fileClose( file )
    end
end )

addEvent( "onNewInviteCodeReceive", true )
addEventHandler( "onNewInviteCodeReceive", root, function( code )
    if not INVITE_CODES then INVITE_CODES = {} end
    table.insert( INVITE_CODES, code )

    if not INVITE_USER_APP then return end
    INVITE_USER_APP:create_codes_list()
end )

addEvent( "onInviteCodeUse", true )
addEventHandler( "onInviteCodeUse", root, function( used_code )
    for i, code in pairs( INVITE_CODES ) do
        if code == used_code then
            table.remove( INVITE_CODES, i )
            break
        end
    end

    if not INVITE_USER_APP then return end
    INVITE_USER_APP:create_codes_list()
end )