loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShVehicle" )
Extend( "ShVehicleConfig" )
Extend( "CPayments" )

ibUseRealFonts( true )

local UI_elements

function ShowOfferVehicle( state, finish_timestamp )
    if state then
        ShowOfferVehicle( false )
        
        UI_elements = { time_left = finish_timestamp - getRealTimestamp() }
        UI_elements.black_bg = ibCreateBackground( _, _, true )
        UI_elements.bg = ibCreateImage( 0, 0, 0, 0, "img/bg.png", UI_elements.black_bg ):ibSetRealSize():center( )

        ibCreateButton( UI_elements.bg:ibData( "sx" ) - 52, 29, 24, 24, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowOfferVehicle( false )
            end )

        local tick = getTickCount( )

        local time_left =  finish_timestamp - getRealTimestamp()
        local h = math.floor(time_left / 60 / 60)
        local m = math.floor( (time_left - h * 60 * 60) / 60 )
        UI_elements.area_timer = ibCreateArea( 1024-350, 40, 0, 0, UI_elements.bg )
        UI_elements.lbl_text = ibCreateLabel( 36, 0, 0, 0, "До конца акции: ", UI_elements.area_timer, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_16 )
        UI_elements.lbl_timer = ibCreateLabel( UI_elements.lbl_text:ibGetAfterX( ), 0, 0, 0, h.." ч. "..m.." мин.", UI_elements.area_timer, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
            :ibTimer( function( self )
                local time_left =  finish_timestamp - getRealTimestamp()
                local h = math.floor(time_left / 60 / 60)
                local m = math.floor( (time_left - h * 60 * 60) / 60 )

                self:ibData( "text", h.." ч. "..m.." мин." )
                UI_elements.area_timer:ibData( "sx", UI_elements.lbl_timer:ibGetAfterX( ) )
            end, 1000, 0 )
        UI_elements.area_timer:ibData( "sx", UI_elements.lbl_timer:ibGetAfterX( ) )

        UI_elements.scrollpane, UI_elements.scrollbar = ibCreateScrollpane( 0, 140, 1024, 720-140, UI_elements.bg, { scroll_px = - 20, bg_color = 0x00FFFFFF  } )
        UI_elements.scrollbar:ibSetStyle( "slim_small_nobg" )

        UI_elements.overlay_rt = ibCreateRenderTarget( 0, 80, 1024, 720-80, UI_elements.bg ):ibData( "priority", 2 )

        local function ShowVehicleOverlay( state, data )
            if state then
                if isElement( UI_elements.overlay_bg ) then destroyElement( UI_elements.overlay_bg ) end

                UI_elements.overlay_bg = ibCreateImage( 0, 720, 1024, 720-80, _, UI_elements.overlay_rt, 0x00ffffff )
                UI_elements.overlay_bg:ibMoveTo( 0, 0, 400 )

                local parent = UI_elements.overlay_bg
                local bg = ibCreateImage( 0, 0, 0, 0, "img/overlay_bg.png", parent ):ibSetRealSize( ):center( )
                ibUseRealFonts( true )

                local offer = OFFER_DATA.pack_data[ data.id ]
                local model = offer.vehicle_id
                local variant = 1

                --Класс автомобиля
                ibCreateLabel( 800, 34, 0, 0, VEHICLE_CLASSES_NAMES[ tostring( model ):GetTier( variant ) ], parent, 0xFFFFFFFF, _, _, _, _, ibFonts.regular_18 )
                --Привод
                ibCreateLabel( 924, 36, 0, 0, DRIVE_TYPE_NAMES[ VEHICLE_CONFIG[ model ].variants[ variant ].handling.driveType ], parent, 0xFFFFFFFF, _, _, _, _, ibFonts.regular_14 )

                ibCreateLabel( 700, 492, 0, 0, format_price( offer.cost ), parent, 0xFFFFFFFF, _, _, _, _, ibFonts.bold_27)
                if offer.cost_original then
                    --Цена без скидки
                    local previous_price = ibCreateLabel( 560+196, 360+118, 0, 0, format_price( offer.cost_original ), parent, 0xFFFFFFFF, _, _, _, _, ibFonts.bold_16 )
                    ibCreateLine( 536+196, 370+118, previous_price:ibGetAfterX( 2 ), 370+118, 0xFFFFFFFF, 1, parent )
                end
                
                local vehicleIconArea = ibCreateArea( 0, 40, 512, 300, bg )
                --Название транспорта средства
                ibCreateLabel( 0, 0, vehicleIconArea:width( ), 0, VEHICLE_CONFIG[ model ].model, vehicleIconArea, 0xFFFFFFFF, _, _, "center", "top", ibFonts.bold_22 )
                --Превью транспортного средства
                ibCreateContentImage( 0, 0, 300, 160, "vehicle", model, vehicleIconArea ):center( 0, 20 )

                -- triangle
                exports.nrp_tuning_shop:generateTriangleTexture( 170, 400, bg, getVehicleOriginalParameters( model ) )

                local vehicleConfig = VEHICLE_CONFIG[ model ].variants[ variant ]
                local vPower = vehicleConfig.power
                local vMaxSpeed = vehicleConfig.max_speed
                local vAccelerationTo100 = vehicleConfig.ftc
                local vFuelLoss = vehicleConfig.fuel_loss
                local acceleration = vehicleConfig.stats_acceleration

                local progressbar_width = 346

                local function getProgressWidth( value, maximum )
                    return ( ( value / maximum ) * progressbar_width ) > progressbar_width and progressbar_width or ( value / maximum ) * progressbar_width
                end

                -- Мощность
                ibCreateLabel( 680, 90, 308, 0, vPower .. " л.с.", parent, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
                ibCreateLine( 646, 118, 646 , 118, 0xFFFF965D, 14, parent ):ibMoveTo( 646 + getProgressWidth( vPower, 600 ), 118, 800, "InOutQuad" )

                -- Разгон от 0 до 100
                ibCreateLabel( 680, 90 + 58, 308, 0, vAccelerationTo100 .. " сек.", parent, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
                ibCreateLine( 646, 176, 646 , 176, 0xFFFF965D, 14, parent ):ibMoveTo( 646 + getProgressWidth( vAccelerationTo100, 30 ), 176, 800, "InOutQuad" )

                -- Расход
                local v = VEHICLE_CONFIG[ model ].is_electric and "%" or "л."
                ibCreateLabel( 680, 90 + 58 * 2, 308, 0, vFuelLoss .. " " .. v, parent, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
                ibCreateLine( 646, 234, 646 , 234, 0xFFFF965D, 14, parent ):ibMoveTo( 646 + getProgressWidth( vFuelLoss, 25 ), 234, 800, "InOutQuad" )

                -- Максимальная скорость
                ibCreateLabel( 680, 90 + 58 * 3 + 3, 308, 0, vMaxSpeed .. " км/ч", parent, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
                ibCreateLine( 646, 292, 646 , 292, 0xFFFF965D, 14, parent ):ibMoveTo( 646 + getProgressWidth( vMaxSpeed, 400 ), 292, 800, "InOutQuad" )

                -- Ускорение
                ibCreateLabel( 680, 90 + 58 * 4 + 2, 308, 0, acceleration, parent, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
                ibCreateLine( 646, 352, 646 , 352, 0xFFFF965D, 15, parent ):ibMoveTo( 646 + getProgressWidth( acceleration, 400 ), 352, 800, "InOutQuad" )

                --Просто по координатам создаем одну невидимую картинку, по производительности это лучше чем создавать 6 картинок
                local colors_settings = {
                    BLUE =      {   x = 723,                color = { 1, 177, 250, 220 }    },
                    RED =       {   x = 723 + 38,           color = { 250, 1, 1, 220 }      },
                    YELLOW =    {   x = 723 + 38 * 2,       color = { 250, 207, 1, 220 }    },
                    GRAY =      {   x = 723 + 38 * 3,       color = { 130, 131, 131, 220 }  },
                    WHITE =     {   x = 723 + 38 * 4,       color = { 255, 255, 255, 220 }  },
                    BLACK =     {   x = 723 + 38 * 5,       color = { 0, 0, 0, 220 }        },
                }
                --Сразу выбираем стандартный цвет
                local selected = "WHITE"
                for i, v in pairs( colors_settings ) do
                    --Формула вычисления нужного нам смещения из-за свечения (glow.size - colorbox.size) / 2
                    colors_settings[i].image = ibCreateImage( v.x - 14, 293+90, 24, 24, ":nrp_shop/img/overlays/vehicle_details/color_glow.png", parent, 0xFFFFFFFF )
                    :ibSetRealSize( )
                    :ibData( "alpha", i == selected and 255 or 0 )

                    ibCreateImage( v.x, 307+90, 24, 24, nil, parent, tocolor( unpack( v.color ) ) )
                    :ibOnHover( function( ) colors_settings[ i ].image:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) if selected == i then return end colors_settings[i].image:ibAlphaTo( 0, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        --Убираем подсветку с прошлого выбранного цвета
                        colors_settings[selected].image:ibAlphaTo( 0, 200 )
                        --Сохраняем ключ активного элемента
                        selected = i
                    end )
                end

                --Кнопка "Купить"
                ibCreateButton( 850, 480, 0, 0, parent, ":nrp_shop/img/overlays/vehicle_details/btn_buy.png", ":nrp_shop/img/overlays/vehicle_details/btn_buy_h.png", ":nrp_shop/img/overlays/vehicle_details/btn_buy.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                    :ibSetRealSize()
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )

                        local vehicle_name = VEHICLE_CONFIG[ OFFER_DATA.pack_data[ data.id ].vehicle_id ].model
                        local vehicle_cost = OFFER_DATA.pack_data[ data.id ].cost

                        UI_elements.confirmation = ibConfirm( {
                            title = "ПОКУПКА АВТО", 
                            text = "Вы уверены что хотите приобрести авто\n" .. vehicle_name .. " за " .. format_price( vehicle_cost ) .. "р.?" ,
                            fn = function( self )
                                triggerServerEvent( "onServerPlayerTryBuyOfferVehicle", localPlayer, data.id, colors_settings[ selected ].color )
                                self:destroy()
                                UI_elements.confirmation = nil
                            end,
                            escape_close = true,
                        } )
                end )

                ibCreateButton( 0, 560, 0, 0, parent, "img/btn_hide_i.png", "img/btn_hide_h.png", "img/btn_hide_h.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                    :ibSetRealSize()
                    :center_x()
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        ShowVehicleOverlay( false )
                end )
            else
                if isElement( UI_elements.overlay_bg ) then
                    UI_elements.overlay_bg:ibMoveTo( 0, 720, 400 )
                end
            end
        end

        UI_elements.blocks = {}
        for k, v in ipairs( { { 32, 0 }, { 522, 0 }, { 32, 298 }, { 522, 298 } } ) do
            UI_elements.blocks[ k ] = ibCreateImage( v[ 1 ], v[ 2 ], 470, 270, "img/block_bg.png", UI_elements.scrollpane )
                :ibOnHover( function( )
                    UI_elements.blocks[ k ]:ibData( "texture", "img/block_bg_hover.png" )
                end )
                :ibOnLeave( function( )
                    UI_elements.blocks[ k ]:ibData( "texture", "img/block_bg.png" )
                end )

            ibCreateImage( 0, 0, 470, 270, "img/" .. k .. ".png", UI_elements.blocks[ k ] ):ibData( "disabled", true )

            UI_elements.blocks[ k .. "_btn" ] = ibCreateButton( 320, 210, 130, 46, UI_elements.blocks[ k ], "img/btn_details_i.png", "img/btn_details_h.png", "img/btn_details_h.png", 0xFFFFFFFF, 0xFFffffff, 0xFFffffff )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    if UI_elements.confirmation then return end

                    local vehicle_name = VEHICLE_CONFIG[ OFFER_DATA.pack_data[ k ].vehicle_id ].model
                    local vehicle_cost = OFFER_DATA.pack_data[ k ].cost

                    ShowVehicleOverlay( true, { id = k } )
                end )
                :ibOnHover( function( )
                    UI_elements.blocks[ k ]:ibData( "texture", "img/block_bg_hover.png" )
                end )
        end

        UI_elements.scrollpane:AdaptHeightToContents( )
        UI_elements.scrollbar:UpdateScrollbarVisibility( UI_elements.scrollpane )
        showCursor( true )
    elseif isElement( UI_elements and UI_elements.black_bg ) then
        destroyElement( UI_elements.black_bg )
        showCursor( false )
        UI_elements = nil
    end
end

function onClientStartOfferlVehicleRequest_handler( data )
    OFFER_DATA = data

    local finish_timestamp = getRealTimestamp() + data.time_left
    localPlayer:setData( "offer_vehicle_finish", finish_timestamp, false )

    triggerEvent( "ShowSplitOfferInfo", root, "offer_vehicle", data.time_left )

    if OFFER_DATA.is_first_time then ShowOfferVehicle( true, finish_timestamp ) end
end
addEvent( "onClientStartOfferlVehicleRequest", true )
addEventHandler( "onClientStartOfferlVehicleRequest", root, onClientStartOfferlVehicleRequest_handler )


function onClientTryShowOfferVehicle_handler( )
    local finish_timestamp = localPlayer:getData( "offer_vehicle_finish" ) or 0
    if finish_timestamp - getRealTimestamp() < 0 then
        onClientOfferlVehicleHide_handler()
    else
        ShowOfferVehicle( true, finish_timestamp )
    end
end
addEvent( "onClientTryShowOfferVehicle" )
addEventHandler( "onClientTryShowOfferVehicle", root, onClientTryShowOfferVehicle_handler )


function onClientOfferlVehicleHide_handler( )
    HidePaymentWindow( )
    ShowOfferVehicle( false )
    
    OFFER_DATA = nil
    localPlayer:setData( "offer_vehicle_finish", false, false )
    triggerEvent( "HideSplitOfferInfo", root, "offer_vehicle" )
end
addEvent( "onClientOfferlVehicleHide", true )
addEventHandler( "onClientOfferlVehicleHide", root, onClientOfferlVehicleHide_handler )