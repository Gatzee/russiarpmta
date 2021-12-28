HUD_CONFIGS[ "birthday_event" ] = {
    elements = { },

    create = function( self, data )
        local bg = ibCreateImage( 0, 0, 340, 80, "img/bg_birthday.png", bg ) 
        self.elements.bg = bg

        local tittle =  ibCreateLabel( 80, 10, 0, 50, data.tittle, bg, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_15 )
        local label = ibCreateLabel( 80, 38, 0, 50, "", bg, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.regular_10 )

        if data.type == "wait" then
            data.time_left = math.ceil( data.time_left / 60 )
            local function UpdateTime( )
                if data.time_left >= 1 then
                    data.time_left = data.time_left - 1
                    label:ibData( "text", data.start_text .. getHumanTimeString( data.time_left, false, true ) )
                else
                    label:ibData( "text", data.finish_text )
                end
            end
            UpdateTime( )
            label:ibTimer( UpdateTime, 60000, 0 )
        elseif data.type == "proc" then
            label:ibData( "text", data.desc )
        end

        return bg
    end,

    destroy = function( self )
        local to_destroy = { self.elements.bg }
        DestroyTableElements( to_destroy )
        
        self.elements = { }
    end,
}

function ShowCurrentBirthdayStep_handler( state, data )
    if state then
        RemoveHUDBlock( "birthday_event" )
        AddHUDBlock( "birthday_event", data )
    else
        RemoveHUDBlock( "birthday_event" )
    end
end
addEvent( "ShowCurrentBirthdayStep", true )
addEventHandler( "ShowCurrentBirthdayStep", root, ShowCurrentBirthdayStep_handler )