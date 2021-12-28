HUD_CONFIGS.notifications = {
    order = -999,
    elements = { },

    create = function( self )
        local bg = ibCreateArea( 0, 0, 340, 60, bg )
        self.elements.bg = bg
        
        self.elements.body = ibCreateImage( 0, 0, 275, 60, "img/notification_body.png", bg )
        self.elements.box = ibCreateImage( bg:width( ) - 60, 0, 60, 60, "img/notification_box.png", bg )

        RefreshNotifications( )
        
        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}


local pNotification = {
	total_count = 0,
}

function RefreshNotifications( )
    local id = "notifications"
    local self = HUD_CONFIGS[ id ]

    local body, box = self.elements.body, self.elements.box

    local desc = pNotification.short_msg or pNotification.msg
    if not isElement( self.elements.lbl_counter ) then
        self.elements.lbl_counter = ibCreateLabel( 40, 20, 0, 0, pNotification.total_count, box, _, _, _, "center", "center", ibFonts.regular_10 )
        self.elements.lbl_title = ibCreateLabel( 20, 20, 0, 0, pNotification.title, body, _, _, _, _, "center", ibFonts.bold_10 )
        self.elements.lbl_desc = ibCreateLabel( 20, 30, 0, 0, desc, body, _, _, _, _, _, ibFonts.regular_10 )
    else
        self.elements.lbl_counter:ibData( "text", pNotification.total_count )
        self.elements.lbl_title:ibData( "text", pNotification.title )
        self.elements.lbl_desc:ibData( "text", desc )
    end

    self.elements.body:ibAlphaTo( 255, 0 )
    if isTimer( self.elements.timer ) then killTimer( self.elements.timer ) end
    self.elements.timer = setTimer( 
        function( ) 
            if isElement( self.elements.body ) then
                self.elements.body:ibAlphaTo( 0, 5000 ) 
            end
        end
    , 5000, 1 )
end

function IsCanShowNotifications()
    if not localPlayer:getData( "in_race" ) then
        return true
    end
    return false
end

function GetShortMessage( msg )
    if utf8.len( msg ) < 30 then return msg end

    local new_msg = ""
    for word in msg:gmatch( "%S+" ) do
        if utf8.len( new_msg .. word ) > 30 then
            return new_msg .. "..."
        end
        new_msg = new_msg .. " " .. word
    end
end

function UpdatePhoneNotificationsIcon( data, amount )
    if data then
		pNotification = {
			title = data.title or "",
            short_msg = data.short_msg,
            msg = data.msg and GetShortMessage( data.msg ) or "Проверь уведомления в телефоне",
        }
        pNotification.total_count = amount or 1
    end
    
    if IsCanShowNotifications() and next( pNotification or { } ) and pNotification and pNotification.total_count > 0 then
        AddHUDBlock( "notifications" )
        RefreshNotifications( )
    else
        RemoveHUDBlock( "notifications" )
    end
end
addEvent( "UpdatePhoneNotificationsIcon", true )
addEventHandler( "UpdatePhoneNotificationsIcon", root, UpdatePhoneNotificationsIcon )

function OnClientReadPhoneNotifications( )
    pNotification.total_count = 0
    RemoveHUDBlock( "notifications" )
end
addEvent( "OnClientReadPhoneNotifications", true )
addEventHandler( "OnClientReadPhoneNotifications", root, OnClientReadPhoneNotifications )