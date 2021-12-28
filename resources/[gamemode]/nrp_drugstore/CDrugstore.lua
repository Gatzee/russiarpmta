Extend( "CInterior" )
Extend( "CPlayer" )
Extend( "ib" )

ibUseRealFonts( true )

function marker_create(config)
	config.keypress = false
    config.radius = 2
    config.text = "ALT Взаимодействие"
    config.keypress = "lalt"
	config.marker_image = "img/marker.png"
	config.marker_text = ""
    config.y = config.y + 860

    local boutique = TeleportPoint(config)
    boutique.elements = { }
    boutique.elements.blip = Blip( config.x, config.y, config.z, 22, 2, 255, 255, 0, 255, -99999, 300 )
    boutique.elements.blip.dimension = config.dimension or 0
	boutique.marker:setColor( 255, 0, 0, 50 )
	boutique.PostJoin = onShopMarkerHit
    boutique.PostLeave = onShopMarkerLeave
    boutique.element:setData( "material", true, false )
    boutique:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 0, 0, 255, 1.55 } )
end

function onShopMarkerHit( self, player )
    ShowDrugstoreUI_handler( )
end 

function onShopMarkerLeave( self, player )
    HideDrugstoreUI_handler( )
end

for i, data in pairs( SHOPS ) do
	marker_create( data )
end

function ShowDrugstoreUI_handler( )
    ShowDrugstoreUI( true )
end
addEvent( "ShowDrugstoreUI", true )
addEventHandler( "ShowDrugstoreUI", root, ShowDrugstoreUI_handler )

function HideDrugstoreUI_handler( )
    ShowDrugstoreUI( false )
end
addEvent( "HideDrugstoreUI", true )
addEventHandler( "HideDrugstoreUI", root, HideDrugstoreUI_handler )
addEventHandler( "onClientPlayerWasted", localPlayer, HideDrugstoreUI_handler )
local UI_elements = { }
local x, y = guiGetScreenSize()

function ShowDrugstoreUI( state )
    if state then
        ShowDrugstoreUI( false )
        ibInterfaceSound()
        showCursor( true )

        UI_elements.black_bg = ibCreateBackground( 0xaa000000, ShowDrugstoreUI, true, true )
        :ibData( "alpha", 0 )
        :ibAlphaTo( 255, 500 )

        UI_elements.bg_texture = dxCreateTexture( "img/bg.png" )
        local sx, sy = dxGetMaterialSize( UI_elements.bg_texture )
        local px, py = x / 2 - sx / 2, y / 2 - sy / 2

        UI_elements.bg_image = ibCreateImage( px, py + 100, sx, sy, "img/bg.png", UI_elements.black_bg )
        :ibMoveTo( px, py, 500 )
        UI_elements.bg = ibCreateRenderTarget( 0, 0, sx, sy, UI_elements.bg_image )
        :ibData( "modify_content_alpha", true )

        ibCreateButton( 750, 24, 24, 24, UI_elements.bg,
                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowDrugstoreUI( false )
        end )
        UI_elements.rt, sc = ibCreateScrollpane( 30, 80, 740, 480, UI_elements.bg , { scroll_px = 10 } )
        sc:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.2 )

        local i = 0
        local npx, npy = 0, 20

        for s in pairs( MEDS_LIST ) do
            i = i + 1

            if i > 1 and i % 2 == 1 then
                npx = 0
                npy = npy + 280 + 20
            elseif i > 1 then
                npx = npx + 360 + 20
            end
            local bg_ = create_item( UI_elements.rt, i )
            if bg_ then
                bg_:ibBatchData( { px = npx, py = npy } )
            end
        end
        UI_elements.rt:AdaptHeightToContents( )
        UI_elements.rt:ibData( "sy", UI_elements.rt:ibData( "sy" ) + 20 )
    else
        if isElement(UI_elements and UI_elements.black_bg) then
			destroyElement( UI_elements.black_bg )
		end
        showCursor( false )
    end
end

create_item = function( parent, index )
    local sx, sy = 360, 280
    local area = ibCreateArea( 0, 0, sx, sy, parent )
    local bg = ibCreateImage( 0, 0, sx, sy, "img/block.png", area )

    local bg_light = ibCreateImage( 0, 0, sx, sy, "img/light.png", area )
        :ibData( "disabled", true ):ibData( "alpha", 0 ):ibData( "priority", -1 )

    bg:ibOnHover( function( ) bg_light:ibAlphaTo( 255, 200 ) end )
    bg:ibOnLeave( function( ) bg_light:ibAlphaTo( 0, 200 ) end )

    local image = ibCreateImage( 0, 60, 0, 0, "img/meds/"..index..".png" , area ):ibData( "disabled", true )
    local sx, sy = image:ibGetTextureSize( )
    local scale = math.min( 143 / sx, 83 / sy )
    sx, sy = sx * scale, sy * scale

    image:ibBatchData( { sx = sx, sy = sy } ):center_x( )

    ibCreateLabel( 0, 15, 0, 0, MEDS_LIST[ index ].name, area, COLOR_WHITE, _, _, "center", "top", ibFonts.regular_16 ):center_x( )
    ibCreateLabel( 187, 165, 0, 0, MEDS_LIST[ index ].health, area, 0xffffffff, _, _, "left", "top", ibFonts.regular_18 )
    
    local lbl_money = ibCreateLabel( 19, 235, 0, 0, MEDS_LIST[ index ].cost, area ):ibData( "font", ibFonts.semibold_21 )
    ibCreateImage( lbl_money:ibGetAfterX( 8 ), 235, 30, 30, ":nrp_shared/img/money_icon.png", area ):ibData( "disabled", true )

    local btn = ibCreateImage( 227, 230, 113, 34, "img/btn_buy.png", area )
    ibCreateImage( 0, 0, 0, 0, "img/btn_buy.png", btn ):ibSetRealSize( ):center( )
        :ibData( "alpha", 200 )
        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            
            local ticks = getTickCount( )
            if not LAST_PURCHASE or ticks - LAST_PURCHASE > 1000 then
                LAST_PURCHASE = ticks
                triggerServerEvent( "onPlayerMedsPurchase", localPlayer, index )
            end
        end )

    return area
end

addEventHandler( "onClientPlayerWasted", localPlayer, function()
    if isElement( UI_elements and UI_elements.bg_texture ) then
        ShowDrugstoreUI( false )
    end
end )

function HideMenu( parent )
    parent
        :ibData( "disabled", true )
        :ibMoveTo( _, parent:height( ), 150 )

    getElementParent( parent )
        :ibTimer( function( self ) self:destroy( ) end, 150, 1 )
end