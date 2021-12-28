local offers_table = { }

HUD_CONFIGS.offers = {
    elements = { },
    order = 950,
    create = function( self, timestamp_end )
        local bg = ibCreateImage( 0, 0, 340, 80, "img/bg_offers.png", bg )
        self.elements.bg = bg

        local positions = { { 33, 40 }, { 60, 40 }, { 106, 40 }, { 135, 40 }, }
        for i, v in pairs( positions ) do
            local lbl = ibCreateLabel( v[ 1 ], v[ 2 ], 0, 0, "", bg, 0xffffffff, _, _, "center", "center", ibFonts.regular_26 )
            self.elements[ "lbl_symbol_" .. i ] = lbl
        end

        function UpdateTimer( )
            local time_diff = timestamp_end - getRealTimestamp( )
            if time_diff < 0 then
                CheckingActiveOffers( )
                return
            end

            local hours = math.floor( time_diff / 60 / 60 )
            local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )
            hours = string.format( "%02d", hours )
            minutes = string.format( "%02d", minutes )

            local str = hours .. minutes

            for i = 1, #positions do
                local symbol = utf8.sub( str, i, i )
                self.elements[ "lbl_symbol_" .. i ]:ibData( "text", symbol )
            end
        end

        self.elements.timer = setTimer( UpdateTimer, 200, 0 )
        UpdateTimer( )
        localPlayer:setData( "offers", time_left, false )

        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}

function AddQueueOffers( name, timestamp_end )
    offers_table[ name ] = timestamp_end
    CheckingActiveOffers( )
end

function RemoveQueueOffers( name )
    offers_table[ name ] = nil
    CheckingActiveOffers( )
end

function CheckingActiveOffers( )
    local timestamp_end_min = math.huge

    for name, timestamp_end in pairs( offers_table ) do
        if timestamp_end < timestamp_end_min and timestamp_end > getRealTimestamp( ) then
            timestamp_end_min = timestamp_end
        end
    end

    RemoveHUDBlock( "offers" )
    if timestamp_end_min == math.huge then  return end
    AddHUDBlock( "offers", timestamp_end_min )

    if localPlayer:getData( "photo_mode" ) then
        onClientHideHudComponents_handler( { "offers" }, true )
    end
end

--OFFERS EVENTS

--offer_3days
function Show3daysInfo_handler( time_left )
    if not time_left then
        time_left = localPlayer:getData( "offer_3days_time_left" )
    end
    if time_left then
        local timestamp_end = getRealTimestamp() + time_left
        AddQueueOffers( "offer_3days", timestamp_end )
    end
end
addEvent( "Show3daysInfo", true )
addEventHandler( "Show3daysInfo", root, Show3daysInfo_handler )

function Hide3daysInfo_handler( )
    RemoveQueueOffers( "offer_3days" )
end
addEvent( "Hide3daysInfo", true )
addEventHandler( "Hide3daysInfo", root, Hide3daysInfo_handler )

--offer_3rdPayment
function Show3rdPaymentInfo_handler( time_left )
    if not time_left then
        time_left = localPlayer:getData( "offer_3rd_payment_timeleft" )
    end
    if time_left then
        local timestamp_end = getRealTimestamp() + time_left
        AddQueueOffers( "offer_3rdPayment", timestamp_end )
    end
end
addEvent( "Show3rdPaymentInfo", true )
addEventHandler( "Show3rdPaymentInfo", root, Show3rdPaymentInfo_handler )

function Hide3rdPaymentInfo_handler( )
    RemoveQueueOffers( "offer_3rdPayment" )
end
addEvent( "Hide3rdPaymentInfo", true )
addEventHandler( "Hide3rdPaymentInfo", root, Hide3rdPaymentInfo_handler )

--aparts_discount
function ShowApartDiscountHUD_handler( time_left )
    if not time_left then
        time_left = localPlayer:getData( "offer_apart20_time_left" )
    end
    if time_left then
        local timestamp_end = getRealTimestamp() + time_left
        AddQueueOffers( "aparts_discount", timestamp_end )
    end
end
addEvent( "ShowApartDiscountHUD", true )
addEventHandler( "ShowApartDiscountHUD", root, ShowApartDiscountHUD_handler )

function HideApartDiscountHUD_handler( )
    RemoveQueueOffers( "aparts_discount" )
end
addEvent( "HideApartDiscountHUD", true )
addEventHandler( "HideApartDiscountHUD", root, HideApartDiscountHUD_handler )

--businesses_offer
function IsCanShowBusinessOffer()
    if not localPlayer:getData( "in_race" ) then
        return true
    end
    return false
end

function BUSINESSESOFFER_onElementDataChange( key )
    if (not key or key == "businesses_offer") and IsCanShowBusinessOffer() then
        local businesses_offer = localPlayer:getData( "businesses_offer" )
        if businesses_offer and businesses_offer.segment > 0 and businesses_offer.count > 0 and businesses_offer.end_timestamp > getRealTimestamp( ) then
            AddQueueOffers( "businesses_offer", businesses_offer.end_timestamp )
        else
            RemoveQueueOffers( "businesses_offer" )
		end
    end
end
addEventHandler( "onClientElementDataChange", localPlayer, BUSINESSESOFFER_onElementDataChange )

addEvent( "onClientRefreshBusinessOffer", true )
addEventHandler( "onClientRefreshBusinessOffer", root, BUSINESSESOFFER_onElementDataChange )

function BUSINESSESOFFER_onStart( )
    BUSINESSESOFFER_onElementDataChange( )
end
addEventHandler( "onClientResourceStart", resourceRoot, BUSINESSESOFFER_onStart )

--angela_discount
function ANGELADISCOUNT_onElementDataChange( key )
    if not key or key == "all_vehicles_discount" then
        local data = localPlayer:GetAllVehiclesDiscount( )
        if not data then
            RemoveQueueOffers( "angela_discount" )
            return
        end

        AddQueueOffers( "angela_discount", localPlayer:GetAllVehiclesDiscount( ).timestamp )
    end
end
addEventHandler( "onClientElementDataChange", localPlayer, ANGELADISCOUNT_onElementDataChange )

function ANGELADISCOUNT_onStart( )
    ANGELADISCOUNT_onElementDataChange( )
end
addEventHandler( "onClientResourceStart", resourceRoot, ANGELADISCOUNT_onStart )

addEvent( "onClientRefreshAngelaDiscount", true )
addEventHandler( "onClientRefreshAngelaDiscount", root, ANGELADISCOUNT_onElementDataChange )

--split_offer
function ShowSplitOfferInfo_handler( name, time_left )
    if time_left then
        local timestamp_end = getRealTimestamp() + time_left
        AddQueueOffers( name, timestamp_end )
    end
end
addEvent( "ShowSplitOfferInfo", true )
addEventHandler( "ShowSplitOfferInfo", root, ShowSplitOfferInfo_handler )

function HideSplitOfferInfo_handler( name )
    RemoveQueueOffers( name )
end
addEvent( "HideSplitOfferInfo", true )
addEventHandler( "HideSplitOfferInfo", root, HideSplitOfferInfo_handler )