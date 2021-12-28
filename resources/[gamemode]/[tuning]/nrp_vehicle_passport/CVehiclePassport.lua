loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ib" )
Extend( "ShVehicle" )
Extend( "ShVehicleConfig" )
Extend( "ShPlayer" )
Extend( "ShUtils" )
Extend( "CPlayer" )
Extend( "ShInventoryConfig" )

local ui = { }

function showPassportUI( state, conf, source )
    if not localPlayer:SetStateShowDocuments( state, source ) then return end
    
    if isElement( ui.black_bg ) then
        if not state then
            destroyElement( ui.black_bg )
            showCursor( false )
        end

        return
    elseif not state then
        return
    end

    ibUseRealFonts( true )

    local vehicle = conf.vehicle

    ui.black_bg = ibCreateBackground( _, _, true )
    ui.bg = ibCreateImage( 0, 0, 1024, 768, "img/bg.png", ui.black_bg ):center( )

    ibCreateButton( 971, 28, 24, 24, ui.bg,
            ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
            0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "down" then return end
        showPassportUI( false )
    end, false )

    -- Название машины, номера, ник владельца и дата покупки
    local vehName = vehicle:tostring( ):gsub( " (%(ID:%d+%))", "" )
    local vehVarian = conf.variant
    local variant_data = VEHICLE_CONFIG[ vehicle.model ].variants[ vehVarian ]
    local variant = variant_data.mod or ""
    local tradeLv = not ( variant_data.untradable or conf.untradable ) and variant_data.level
    local showTriangle = not VEHICLE_CONFIG[ vehicle.model ].is_boat and not VEHICLE_CONFIG[ vehicle.model ].is_airplane
    local vehNumber = vehicle:GetNumberPlate( )

    vehNumber = "(" .. vehNumber:sub( 3, vehNumber:len( ) - 2 ) .. ")"

    ibCreateLabel( 512, 92, 0, 0, vehName .. " " .. variant, ui.bg ):ibBatchData( { align_x = "center", font = ibFonts.regular_20, color = 0xffffffff } ):center_x( )
    ibCreateLabel( 512, 122, 0, 0, utf8.upper( vehNumber ), ui.bg ):ibBatchData( { align_x = "center", font = ibFonts.bold_18, color = 0xffffffff } )
    ibCreateLabel( 115, 105, 0, 0, source:GetNickName( ), ui.bg ):ibBatchData( { font = ibFonts.regular_18, color = 0xffffffff } )

    -- status of car
    local statusString = CAR_STATUS_NAMES[ conf.statusNumber ]
    if VEHICLE_CONFIG[ vehicle.model ].is_moto then
        statusString = MOTO_STATUS_NAMES[ conf.statusNumber ]
    end

    local loss = {
        [STATUS_TYPE_HARD] = 10,
        [STATUS_TYPE_CRIT] = 20,
    }
    local lossInfo = "(скорость снижена на " .. ( loss[conf.statusNumber] or 0 ) .. ")"

    local lbl_status = ibCreateLabel( 125, 140, 0, 0, statusString, ui.bg ):ibBatchData( { font = ibFonts.regular_18, color = 0xffffffff } )

    ibCreateButton( lbl_status:ibGetAfterX( 10 ), 142, 14, 18, ui.bg, "img/information/tip", true, true ):ibData( "priority", 1 )
    :ibAttachTooltip( "Справка" )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "down" then return end

        ShowInformation( conf )
    end, false )

    ibCreateLabel( 125, 162, 0, 0, lossInfo, ui.bg ):ibBatchData( { font = ibFonts.regular_14, color = 0xffff965d } )
    ibCreateLabel( 249, 192, 0, 0, conf.repairs, ui.bg ):ibBatchData( { font = ibFonts.bold_18, color = 0xffffffff } )

    -- purchase data & trade level
    ibCreateLabel( 994, 104, 0, 0, conf.purchase_date, ui.bg ):ibBatchData( { align_x = "right", font = ibFonts.regular_18, color = 0x66FFFFFF } )

    if tradeLv then
        ibCreateLabel( 994, 136, 0, 0, "Доступно для б/у с         уровня", ui.bg ):ibBatchData( { align_x = "right", font = ibFonts.light_16, color = 0x88ffffff } )
        ibCreateLabel( 922, 134, 0, 0, tradeLv, ui.bg ):ibBatchData( { align_x = "center", font = ibFonts.regular_18, color = 0xffffffff } )
    else
        ibCreateLabel( 994, 136, 0, 0, "Недоступно для продажи на б/у", ui.bg ):ibBatchData( { align_x = "right", font = ibFonts.light_16, color = 0x88ffffff } )
    end

    local inventory_max_weight = VEHICLES_MAX_WEIGHTS[ vehicle.model ] and ( VEHICLES_MAX_WEIGHTS[ vehicle.model ] + ( conf.inventory_expand or 0 ) )
    if inventory_max_weight then
        local lbl_max_weight = ibCreateLabel( 994, 166, 0, 0, " " .. inventory_max_weight .. " кг", ui.bg ):ibBatchData( { align_x = "right", font = ibFonts.regular_18, color = 0xffffffff } )
        ibCreateLabel( lbl_max_weight:ibGetBeforeX(), 168, 0, 0, "Вместимость багажника: ", ui.bg ):ibBatchData( { align_x = "right", font = ibFonts.light_16, color = 0x88ffffff } )
    end

    ui.image_vehicle_area = ibCreateArea( 180, 149, 662, 380, ui.bg ) -- выравниваем фото тачки

    ibCreateContentImage( 0, 0, 600, 316, "vehicle", vehicle.model, ui.image_vehicle_area ):center( )

    -- Список деталей
    local npx, npy = 121, 652
    for i = 1, 7 do
        local id = conf.parts[ i ] and conf.parts[ i ].id
        local part = getTuningPartByID( id, conf.vehicle:GetTier( ) )

        if part then
            part.damaged = conf.parts[ i ] and conf.parts[ i ].damaged
        end

        local bg = CreatePartElement( npx, npy, part )
        local area = ibCreateArea( 0, 0, 86, 86, bg )

        addEventHandler( "ibOnElementMouseEnter", area, function( )
            --bg:ibData( "texture", ":nrp_tuning_shop/img/bg_part_hover.png" )
            if part then
                CreatePartHint( part )
            end
        end, false )

        addEventHandler( "ibOnElementMouseLeave", area, function( )
            --bg:ibData( "texture", ":nrp_tuning_shop/img/bg_part.png" )
            DestroyPartHint( )
        end, false )

        npx = npx + 86 + 30
    end

    -- цвет и класс
    ibCreateImage( 82, 307, 26, 26, "img/color_inner.png", ui.bg, conf.color )
    ibCreateImage( 82, 307, 26, 26, "img/color_outer.png", ui.bg )
    ibCreateLabel( 933, 307, 0, 0, "Class " .. VEHICLE_CLASSES_NAMES[ conf.class ], ui.bg ):ibBatchData( { font = ibFonts.regular_18, color = 0xffffffff } )

    -- triangle of characteristics's car
    local speed, acceleration, controllability, clutch, slip = unpack( conf.stats )

    --[[ if showTriangle then  -- Оригинальный хандлинг или что-то такое
        local oControllability, oClutch, oSlip = getVehicleOriginalParameters( conf.vehicle.model )
        exports.nrp_tuning_shop:generateTriangleTexture( 156, 505, ui.bg, controllability + oControllability, clutch + oClutch, slip + oSlip )
    end]]

    -- скорость, ускорение, управляемость
    local maxSpeed, maxAcceleration = 400, 400

    ibCreateLabel( 594, 533, 0, 10, speed, ui.bg ):ibBatchData( { align_x = "right", font = ibFonts.regular_12, color = 0xffffffff } )
    ibCreateImage( 415, 552, 179 * ( speed / maxSpeed > 1 and 1 or speed / maxSpeed ), 15, nil, ui.bg, 0xffff965d )

    ibCreateLabel( 594, 583, 0, 10, acceleration, ui.bg ):ibBatchData( { align_x = "right", font = ibFonts.regular_12, color = 0xffffffff } )
    ibCreateImage( 415, 602, 179 * ( acceleration / maxAcceleration > 1 and 1 or acceleration / maxAcceleration ), 15, nil, ui.bg, 0xffff965d )

    -- влияние на дамаг и пробег
    ibCreateLabel( 692, 549, 0, 0, "Уменьшение урона на " .. tostring( conf.damageCoeff ) .. "%", ui.bg ):ibBatchData( { font = ibFonts.regular_16, color = 0xffffffff } )
    ibCreateLabel( 692, 598, 0, 0, "Уменьшение износа на " .. tostring( conf.mileanceCoeff ) .. "%", ui.bg ):ibBatchData( { font = ibFonts.regular_16, color = 0xffffffff } )
    showCursor( true )

    ibUseRealFonts( false )
end

function getCapitalCost( vehiclePrice, tier, status )
	capitalRepairCost = STATUSES_DATA.capitalRepairCost[ tier ][ status - 2 ]
	if not capitalRepairCost then return "Отсутствует" end

	capitalRepairCost = capitalRepairCost * vehiclePrice
	capitalRepairCost = math.max( STATUSES_DATA.capitalRepairMin[ tier ], capitalRepairCost )
	capitalRepairCost = math.min( STATUSES_DATA.capitalRepairMax[ tier ], capitalRepairCost )

	return capitalRepairCost
end

function ShowInformation( conf )
    if isElement( ui.overlay_area ) then
        destroyElement( ui.overlay_area )
        return
	end
    ibUseRealFonts( true )

    ui.overlay_area = ibCreateArea( 0, 0, ui.bg:width( ), ui.bg:height( ), ui.bg ):ibBatchData( { priority = 2, alpha = 0 })

	local overlay_bg = ibCreateImage( 0, 80, ui.bg:width( ), ui.bg:height( ), "img/information/overlay_bg.png", ui.overlay_area ):ibSetRealSize( )

	local mileageList = STATUSES_DATA.mileage[ conf.class ]

	for i,v in pairs( CAR_STATUS_NAMES ) do 
		local startX = 30 + ( ( i - 1 ) * 246 )

		local statusArea = ibCreateArea( startX, 188, 226, 468, ui.overlay_area)

		--Ось X пришлось костылить из-за позиции которая отличается от остальных
		ibCreateLabel( 125 + ( i == 1 and 14 or 0 ), 59, 0, 0, mileageList[ i - 1 ] or 0, statusArea, 0xFFFFFFFF, _, _, _, _, ibFonts.bold_18 )

		local price = getCapitalCost( conf.price, conf.class, i )
		--Если результат функции вернул число, то форматируем его
		price = type( price ) == "number" and format_price( price ) or price
		--Само не рассчитало размер текста, ibSetRealsize тоже не помог, юзаем dxgettextwidth
		local costsLabel = ibCreateLabel( 0, 425, dxGetTextWidth( price, 1, ibFonts.bold_18 ), 0, price, statusArea, 0xFFFFFFFF, _, _, _, _, ibFonts.bold_18 ):center_x( - 15 )
		ibCreateImage( costsLabel:ibGetAfterX( ) + 8, 425, 22, 21, "img/information/soft.png", statusArea )
	end
		
	ibCreateButton( 0, 695, 108, 42, ui.overlay_area, "img/information/hide.png", "img/information/hide_hover.png" ):center_x()
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "down" then return end
        ShowInformation( conf )
    end, false )
	--Применяем анимацию после того как создались все обьекты
	ui.overlay_area:ibAlphaTo( 255, 500 )
    ibUseRealFonts( false )
end

function CreatePartElement( px, py, part, parent )
    local real_parent = ui.bg
    if parent == false then real_parent = false end

    local textureBGPath = part and ( ":nrp_tuning_internal_parts/img/bg_part_" .. part.category .. ".png" ) or ":nrp_tuning_shop/img/bg_part.png"
    local bg = ibCreateImage( px, py, 86, 86, textureBGPath, real_parent )

    if part then
        local texturePath = ":nrp_tuning_internal_parts/img/" .. PARTS_IMAGE_NAMES[ part.type ] .. ".png"
        local texturePathForMoto = ":nrp_tuning_internal_parts/img/" .. PARTS_IMAGE_NAMES[ part.type ] .. "_m.png"

        if part.is_moto and fileExists( texturePathForMoto ) then
            texturePath = texturePathForMoto
        end

        local detail = ibCreateImage( 5, 0, 76, 76, texturePath, bg )

        if ( part.damaged or 0 ) >= 1 then
            detail:ibData( "alpha", 125 )
        end

        ibCreateLabel( 12, 76, 0, 0, ("TYPE"):gsub( ".", "%1 "):sub( 1, - 2 ), bg, nil, nil, nil, nil, nil, ibFonts.oxaniumbold_8 )

        local charOfType = INTERNAL_PARTS_NAMES_TYPES[ part.subtype ]
        ibCreateLabel( 67, 65, 0, 0, charOfType, bg, nil, nil, nil, nil, nil, ibFonts.oxaniumbold_14 )
    end

    return bg
end

function CreatePartHint( part )
    DestroyPartHint( )

    ibUseRealFonts( true )

    local cx, cy = getCursorPosition( )
    cx, cy = cx * _SCREEN_X, cy * _SCREEN_Y

    local bg = ibCreateImage( cx + 10, cy - 100, 200, 117, ":nrp_tuning_shop/img/bg_hint.png", _, 0xffffffff ):ibBatchData( { alpha = 0, disabled = true } )
    bg:ibAlphaTo( 255, 150, "OutQuad" )

    ibCreateLabel( 20, 10, 0, 0, PARTS_NAMES[ part.type ] .. " - " .. part.name .. " (" .. PARTS_TIER_NAMES[ part.category ] .. ")", bg )
    :ibBatchData( { font = ibFonts.bold_13, color = 0xffffffff } )

    local value_positions = {
        { 42, 43 },
        { 42, 65 },
        { 42, 87 },
        { 130, 53 },
        { 130, 76 },
    }

    local values = {
        part.controllability, part.clutch, part.slip, part.speed, part.acceleration
    }

    for i, v in pairs( values ) do
        local width = dxGetTextWidth( math.abs( v ), 1, ibFonts.regular_12 )

        local px, py = unpack( value_positions[ i ] )
        local is_changed = v ~= 0
        ibCreateLabel( px + 4, py, 0, 0, math.abs( v ), bg ):ibBatchData( { font = ibFonts.bold_10, color = v < 0 and 0xffff3a3a or v > 0 and 0xff00ff63 or 0xffffffff } )

        if is_changed then
            local icon_texture = v < 0 and ":nrp_tuning_shop/img/icon_arrowdown_red.png" or v > 0 and ":nrp_tuning_shop/img/icon_arrowup_green.png"
            local icon_px, icon_py = px + 5 + width, py + 1
            local icon_sx, icon_sy = 27 * 0.6, 24 * 0.6
            ibCreateImage( icon_px, icon_py, icon_sx, icon_sy, icon_texture, bg )
        end
    end

    if ( part.damaged or 0 ) >= 1 then
        ibCreateLabel( 105, 95, 0, 0, "Изношена", bg ):ibBatchData( { font = ibFonts.semibold_11, color = 0xffff3a3a } )
    end

    ui.part_hint = bg
    addEventHandler( "onClientCursorMove", root, RenderMovePartHint )

    ibUseRealFonts( false )
end

function DestroyPartHint( )
    removeEventHandler( "onClientCursorMove", root, RenderMovePartHint )
    if isElement( ui.part_hint ) then destroyElement( ui.part_hint ) end
end

function RenderMovePartHint( _, _, ax, ay )
    ui.part_hint:ibBatchData( { px = ax + 10, py = ay - 100 } )
end

addEvent( "onVehiclePassportShow", true )
addEventHandler( "onVehiclePassportShow", root, function ( state, conf )
    showPassportUI( state, conf, source )
end )