MAYEVENTSAPP = nil

APPLICATIONS.may_events = {
    id = "may_events",
    icon = "img/apps/may_events.png",
    name = "Майский",
    elements = { },
	create = function( self, parent, conf )

        self.parent = parent
        self.conf = conf

		self.elements.header = ibCreateImage( 0, 0, 0, 0, "img/elements/events/header/may_events.png", parent ):ibSetRealSize( )

		self:create_list( )

        MAYEVENTSAPP = self
        return self
	end,

	create_list = function( self )
		ibUseRealFonts( true )

		local py = self.elements.header:ibGetAfterY( )

		if isElement( self.elements.bg_list ) then
			destroyElement( self.elements.bg_list )
		end

		self.elements.bg_list = ibCreateArea( 0, py, self.parent:ibData( "sx" ), 0, self.parent )

		local event_id = localPlayer:getData( "event_id" )
		local lobby_id = localPlayer:getData( "lobby_id" )

		local offset_y = 0

		local events = exports.nrp_events:GetEventListByGroup( "may_events" )
		for i, info in pairs( events ) do
			local bg = ibCreateArea( 0, offset_y, 204, 74, self.elements.bg_list )
			ibCreateImage( 0, 0, 0, 0, "img/elements/events/icons/".. info.id ..".png", bg ):ibSetRealSize( ):center( -73, 0 )
			ibCreateLabel( 58, 20, 0, 0, info.name, bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_11 )

			offset_y = offset_y + 74

			local status = false
			if event_id == info.id then
                status = lobby_id and "lobby" or "wait"
			end

			if status then
				local event_lobby_data = localPlayer:getData( "event_lobby_data" )
				if status == "wait" then
					local lbl_time = ibCreateLabel( 58, 35, 0, 0, "Сбор лобби:", bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_10 )

					local time = math.max( 0, getRealTimestamp( ) - event_lobby_data.start )
					ibCreateLabel( lbl_time:ibGetAfterX( 3 ), 35, 0, 0, time .. " " .. plural( time, "секунда", "секунды", "секунд" ), bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.regular_10 )	
						:ibData( "timestamp", event_lobby_data.start )
						:ibTimer( function( self )
							local time = math.max( 0, getRealTimestamp( ) - self:ibData( "timestamp" ) )
							self:ibData( "text", time .. " " .. plural( time, "секунда", "секунды", "секунд" ) )
						end, 500, 0 )

					local lbl_count = ibCreateLabel( 58, 50, 0, 0, "Найдено игроков:", bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_10 )
					local lbl_found_count = ibCreateLabel( lbl_count:ibGetAfterX( 3 ), 50, 0, 0, event_lobby_data.players, bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_10 )
					ibCreateLabel( lbl_found_count:ibGetAfterX( ), 50, 0, 0, "/".. event_lobby_data.max_players, bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_10 )

					ibCreateButton( 58, 65, 78, 23, bg, "img/elements/events/btn_cancel", true )
						:ibOnClick( function( key, state )
							if key ~= "left" or state ~= "up" then return end
							ibClick( )

							triggerServerEvent( "PlayerWantCancelRegisterOnEvent", root )
						end )

					offset_y = offset_y + 25
				else
					local lbl_time = ibCreateLabel( 58, 35, 0, 0, "Ожидание игроков:", bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_10 )

					local time = math.abs( getRealTimestamp( ) - event_lobby_data.start )
					ibCreateLabel( lbl_time:ibGetAfterX( 3 ), 35, 0, 0, time .. " сек.", bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.regular_10 )	
						:ibData( "timestamp", event_lobby_data.start )
						:ibTimer( function( self )
							local time = math.abs( getRealTimestamp( ) - self:ibData( "timestamp" ) )
							self:ibData( "text", time .. " сек." )
						end, 500, 0 )

					local lbl_count = ibCreateLabel( 58, 50, 0, 0, "Готовы:", bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_10 )
					local lbl_found_count = ibCreateLabel( lbl_count:ibGetAfterX( 3 ), 50, 0, 0, event_lobby_data.players, bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_10 )
					ibCreateLabel( lbl_found_count:ibGetAfterX( ), 50, 0, 0, "/".. event_lobby_data.max_players, bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_10 )

					if event_lobby_data.not_ready then
						ibCreateButton( 58, 65, 63, 23, bg, "img/elements/events/btn_start", true )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end
								ibClick( )

								triggerServerEvent( "LobbyEventPlayerReady", root )
							end )

						offset_y = offset_y + 25
					end
				end
			else
				ibCreateButton( 58, 35, 98, 23, bg, "img/elements/events/btn_reg", true )
					:ibData( "disabled", not not event_id )
					:ibData( "alpha", ( not not event_id ) and 128 or 255 )
					:ibOnClick( function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )

						triggerServerEvent( "PlayerWantRegisterOnEvent", root, info.id )
					end )
			end

			ibCreateImage( 0, offset_y - 1, 204, 1, _, self.elements.bg_list, ibApplyAlpha( COLOR_BLACK, 10 ) )
		end

		ibUseRealFonts( false )
	end,

    destroy = function( self, parent, conf )
        DestroyTableElements( self.elements )
        MAYEVENTSAPP = nil
    end,
}

function onEventsUpdatePhoneListCallback_handler( )
	if not MAYEVENTSAPP then return end
	MAYEVENTSAPP:create_list( )
end
addEvent( "onEventsUpdatePhoneListCallback", true )
addEventHandler( "onEventsUpdatePhoneListCallback", root, onEventsUpdatePhoneListCallback_handler )