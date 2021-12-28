HUD_CONFIGS.taxi = {
    elements = { },

    create = function( self )
        local bg = ibCreateImage( 0, 0, 340, 80, "img/bg_taxi.png", bg ) --ibCreateImage( 0, 0, 340, 80, _, _, 0xd72a323c )
        self.elements.bg = bg

        --ibCreateImage( 0, 0, 340, 80, "img/bg_taxi.png", bg )
        self.elements.lbl_amount = ibCreateLabel( 278, 10, 0, 0, "0", bg, 0xfff3cc8a, nil, nil, nil, nil, ibFonts.semibold_14 )
        return bg
    end,

    destroy = function( self )
        local to_destroy = { self.elements.bg }
        DestroyTableElements( to_destroy )
        
        self.elements = { }
    end,
}

function ShowTaxiInfo_handler( amount )
    TAXI_AMOUNT = amount or TAXI_AMOUNT or 0

    HideTaxiInfo_handler( )
    AddHUDBlock( "taxi" )
    UpdateTaxiAmount(  )
end
addEvent( "ShowTaxiInfo", true )
addEventHandler( "ShowTaxiInfo", root, ShowTaxiInfo_handler )

function HideTaxiInfo_handler( )
    RemoveHUDBlock( "taxi" )
end
addEvent( "HideTaxiInfo", true )
addEventHandler( "HideTaxiInfo", root, HideTaxiInfo_handler )

function UpdateTaxiAmount( )
    local id = "taxi"
    local self = HUD_CONFIGS[ id ]

    if isElement( self.elements.lbl_amount ) then
        self.elements.lbl_amount:ibData( "alpha", 0 )
        self.elements.lbl_amount:ibData( "text", TAXI_AMOUNT )
        self.elements.lbl_amount:ibAlphaTo( 255, 200 )
    end
end

function onTaxiClientAdd_handler( )
    TAXI_AMOUNT = TAXI_AMOUNT + 1
    UpdateTaxiAmount( )
end
addEvent( "onTaxiClientAdd", true )
addEventHandler( "onTaxiClientAdd", root, onTaxiClientAdd_handler )