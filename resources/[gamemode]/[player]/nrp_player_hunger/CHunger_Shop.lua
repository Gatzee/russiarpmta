Extend( "CInterior" )
Extend( "ib" )

ibUseRealFonts( true )

function marker_create(config)
	config.keypress = false
    config.radius = 2
    config.text = "ALT Взаимодействие"
    config.keypress = "lalt"
	config.marker_image = "img/marker.png"
	config.marker_text = ""
    config.y = config.y+860
    local boutique = TeleportPoint(config)
    boutique.elements = { }
    boutique.elements.blip = Blip( config.x, config.y, config.z, 10, 2, 255, 255, 0, 255, -99999, 300 )
    boutique.elements.blip.dimension = config.dimension or 0
	boutique.marker:setColor( 255, 100, 0, 50 )
	boutique.PostJoin = onShopMarkerHit
    boutique.PostLeave = onShopMarkerLeave
    boutique.element:setData( "material", true, false )
    boutique:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 100, 0, 255, 1.5 } )
end

function onShopMarkerHit( self, player )
    ShowFoodUI_handler( )
end

function onShopMarkerLeave( self, player )
    HideFoodUI_handler( )
end

for i, data in pairs( SHOPS ) do
	marker_create( data )
end

for i, data in pairs( SHOP_INTERIOR ) do
	marker_create( data )
end

function ShowFoodUI_handler( )
    local animation_block = getPedAnimation( localPlayer )
    if animation_block == "food" then return end
    ShowFoodUI( true )
end
addEvent( "ShowFoodUI", true )
addEventHandler( "ShowFoodUI", root, ShowFoodUI_handler )


function HideFoodUI_handler( )
    ShowFoodUI( false )
end
addEvent( "HideFoodUI", true )
addEventHandler( "HideFoodUI", root, HideFoodUI_handler )
addEventHandler( "onClientPlayerWasted", localPlayer, HideFoodUI_handler )

local UI = { }
local x, y = guiGetScreenSize()

function ShowFoodUI( state )
    if state then
        ShowFoodUI( false )
        ibInterfaceSound()
        
        UI.black_bg = ibCreateBackground( 0xaa000000, ShowFoodUI, true, true )
            :ibData( "alpha", 0 )
            :ibAlphaTo( 255, 500 )

        UI.bg_texture = dxCreateTexture( "img/bg.png" )
        local sx, sy = dxGetMaterialSize( UI.bg_texture )
        local px, py = x / 2 - sx / 2, y / 2 - sy / 2

        UI.bg_image = ibCreateImage( px, py + 100, sx, sy, "img/bg.png", UI.black_bg )
            :ibMoveTo( px, py, 500 )
        UI.bg = ibCreateRenderTarget( 0, 0, sx, sy, UI.bg_image )
            :ibData( "modify_content_alpha", true )

        ibCreateButton( 750, 24, 24, 24, UI.bg,
                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowFoodUI( false )
            end )

        UI.rt, sc = ibCreateScrollpane( 30, 80, 740, 480, UI.bg , { scroll_px = 10 } )
        sc:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.2 )
        
        local i = 0
        local npx, npy = 0, 20
        
        for v in pairs( FOOD_LIST ) do
            i = i + 1

            if i > 1 and i % 2 == 1 then
                npx = 0
                npy = npy + 280 + 20
            elseif i > 1 then
                npx = npx + 360 + 20
            end
            local bg_ = create_item( UI.rt, i )
            if bg_ then
                bg_:ibBatchData( { px = npx, py = npy } )
            end
        end
        UI.rt:AdaptHeightToContents( )
        UI.rt:ibData( "sy", UI.rt:ibData( "sy" ) + 20 )

        showCursor( true )
    else
        if isElement( UI and UI.black_bg ) then
            destroyElement( UI.black_bg )
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

    local image = ibCreateImage( 0, 60, 0, 0, "img/food/"..index..".png" , area ):ibData( "disabled", true )
    local sx, sy = image:ibGetTextureSize( )
    local scale = math.min( 143 / sx, 93 / sy )
    sx, sy = sx * scale, sy * scale

    image:ibBatchData( { sx = sx, sy = sy } ):center_x( )

    ibCreateLabel( 0, 15, 0, 0, FOOD_LIST[ index ].name, area, COLOR_WHITE, _, _, "center", "top", ibFonts.regular_16 ):center_x( )
    ibCreateLabel( 187, 170, 0, 0, FOOD_LIST[ index ].calories, area, 0xffffffff, _, _, "left", "top", ibFonts.regular_18 )
    
    local lbl_money = ibCreateLabel( 19, 235, 0, 0, FOOD_LIST[ index ].cost, area ):ibData( "font", ibFonts.semibold_21 )
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
                triggerServerEvent( "onPlayerFoodPurchase", localPlayer, index )
            end
        end )

    return area
end

local sounds = {
    [ 1 ] = { delay = 50, },
    [ 2 ] = { delay = 3200, },
    [ 3 ] = { delay = 3200, },
    [ 4 ] = { delay = 6000, },
    [ 5 ] = { delay = 6000, },
    [ 6 ] = { delay = 6000, },
    [ 7 ] = { delay = 50, },
    [ 8 ] = { delay = 3200, },
    [ 9 ] = { delay = 3200, },
}

function OnPlayerPuke_handler( is_fast_food )
    setPedAnimation( source, "food", "eat_vomit_p", -1, false, true, true, false )
    Timer( function( player )
        if not isElement( player ) then return end
        local px, py, pz = getPedBonePosition( player, 8 )
        local effect = createEffect( "puke", px, py, pz - 0.2, -90, 0, 0, 0, true )
        effect.interior = player.interior
        effect.dimension = player.dimension
    end, 4200, 1, source )

    if source ~= localPlayer then return end
    ShowFoodUI( false )
        
    -- Звук во время начала анимации
    if not is_fast_food then return end

    local gender = localPlayer:GetGender( )
    if fileExists( "sfx/" .. gender .. "/1.mp3" ) then
        local sound_number = math.random( #sounds )
        local sound = sounds[ sound_number ]
        if sound.delay then
            Timer( 
                function() 
                    local sound = playSound( "sfx/" .. gender .. "/" .. sound_number .. ".mp3" )
                    sound.volume = 0.3
                end, 
            sound.delay, 1 )
        else
            local sound = playSound( "sfx/" .. gender .. "/" .. sound_number .. ".mp3" ) 
            sound.volume = 0.3
        end
    end
end
addEvent( "OnPlayerPuke", true )
addEventHandler( "OnPlayerPuke", root, OnPlayerPuke_handler )

addEventHandler( "onClientPlayerWasted", localPlayer, function()
    if isElement(UI.bg_texture) then
        ShowFoodUI(false)
    end
end )

function HideMenu( parent )
    parent
        :ibData( "disabled", true )
        :ibMoveTo( _, parent:height( ), 150 )

    getElementParent( parent )
        :ibTimer( function( self ) self:destroy( ) end, 150, 1 )
end