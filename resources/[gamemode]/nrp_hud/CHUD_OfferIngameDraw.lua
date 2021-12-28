local offers_table = { }

HUD_CONFIGS.offer_ingame_draw = {
    elements = { },
    order = 950,
    create = function( self, data )
        ibUseRealFonts( true )

        local bg = ibCreateImage( 0, 0, 340, 50, data.ticket_code and "img/bg_offer_competition_finish.png" or "img/bg_offer_competition_acitve.png", bg )
        self.elements.bg = bg

        ibCreateLabel( 53, 7, 0, 0, data.task_name, bg, 0xFFFF965D, _, _, "left", "top", ibFonts.semibold_14 )
        if data.time_left ~= -1 then
            ibCreateLabel( 53, 25, 0, 0, data.task_desc, bg, 0xFFD7D8D9, _, _, "left", "top", ibFonts.regular_12 )

            local label_time = ibCreateLabel( 268, 16, 0, 0, "", bg, 0xFFFFFFFF, _, _, "left", "top", ibFonts.oxaniumbold_14 )

            function UpdateTimer( )
                local time_diff = data.time_left - getRealTimestamp( )
                if time_diff < 0 then
                    CheckingActiveCompetitionOffers( )
                    return
                end

                local hours = math.floor( time_diff / 60 / 60 )
                local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )
                local seconds = math.max( 0, math.floor( time_diff - hours * 60 * 60 - minutes * 60 ) )

                local text = string.format( "%02d", hours ) .. ":" .. string.format( "%02d", minutes ) .. ":" .. string.format( "%02d", seconds )
                label_time:ibData( "text", text )
            end

            self.elements.timer = setTimer( UpdateTimer, 1000, 0 )
            UpdateTimer( )
        elseif data.ticket_code then
            local task_desc_lbl = ibCreateLabel( 54, 25, 0, 0, "Твой код:", bg, 0xFFD7D8D9, _, _, "left", "top", ibFonts.regular_12 )
            ibCreateLabel( task_desc_lbl:ibGetAfterX() + 4, 25, 0, 0, data.ticket_code, bg, 0xFFFFFFFF, _, _, "left", "top", ibFonts.oxaniumbold_12 )
        end

        ibUseRealFonts( false )
        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}

function AddQueueCompetitionOffer( name, data )
    offers_table[ name ] = data
    CheckingActiveCompetitionOffers( )
end

function RemoveQueueCompetitionOffer( name )
    offers_table[ name ] = nil
    CheckingActiveCompetitionOffers( )
end

function CheckingActiveCompetitionOffers( )
    local target_data = nil
    local timestamp_end_min = math.huge
    for name, data in pairs( offers_table ) do
        if data.ticket_code or (data.time_left < timestamp_end_min and data.time_left > getRealTimestamp( )) then
            timestamp_end_min = data.time_left
            target_data = data
        end
    end

    RemoveHUDBlock( "offer_ingame_draw" )
    if not target_data then return end
    AddHUDBlock( "offer_ingame_draw", target_data )

    if localPlayer:getData( "photo_mode" ) then
        onClientHideHudComponents_handler( { "offer_ingame_draw" }, true )
    end
end

function onClientShowIngameDrawOfferInfo_handler( name, data )
    if data and data.time_left then
        if data.time_left ~= -1 then data.time_left = data.time_left + getRealTimestamp() end
        AddQueueCompetitionOffer( name, data )
    end
end
addEvent( "onClientShowIngameDrawOfferInfo", true )
addEventHandler( "onClientShowIngameDrawOfferInfo", root, onClientShowIngameDrawOfferInfo_handler )

function onClientHideIngameDrawOfferInfo_handler( name )
    RemoveQueueCompetitionOffer( name )
end
addEvent( "onClientHideIngameDrawOfferInfo", true )
addEventHandler( "onClientHideIngameDrawOfferInfo", root, onClientHideIngameDrawOfferInfo_handler )