Import( "CPlayer" )
Import( "CVehicle" )
Import( "ShUtils" )
Import( "ib" )
Import( "cases/_ShItems" )

local CONST_RARE_COLORS = {
    [1] = 0xffaff7ff;
    [2] = 0xffa975ff;
    [3] = 0xfffd56ff;
    [4] = 0xffff6464;
    [5] = 0xffffb346;
}

WEB_CASES_DATA = nil

local description_box

function LoadCasesWebData( additional_ids, callback_event, ... )
	local callback_args = { ... }
    local server = localPlayer:getData( "_srv" )[ 1 ]
    local url = CONST_GET_CASES_URL .. server
    if #additional_ids > 0 then
        url = url .. "?additional=" .. table.concat( additional_ids, "," )
    end

    if root:getData( "timestamp_fake_diff" ) then
        url = url .. ( #additional_ids > 0 and "&" or "?" ) .. "fake_ts=" .. getRealTimestamp()
    end

    fetchRemote( url,
        {
            queueName = "cases_data",
            connectionAttempts = 10,
            connectTimeout = 15000,
            method = "GET",
        },
        function( json_data, err )
            -- Если ошибка чтения, но раньше уже читались кейсы
            if ( not err.success or err.statusCode ~= 200 ) then
                UpdateWebCasesInfo( false )
                return
            end

            local data = fromJSON( json_data )
            UpdateWebCasesInfo( data )

            if callback_event then
            	triggerEvent( callback_event, localPlayer, callback_args and unpack( callback_args ) )
            end
        end
    )
end

function UpdateWebCasesInfo( cases_info )
    if not cases_info then return end
    WEB_CASES_DATA = cases_info
end

function onUpdateCasesCacheGlobalCount_handler( case_id, new_count )
    if not WEB_CASES_DATA then return end

    for i, info in pairs( WEB_CASES_DATA ) do
        if info.id == case_id then
            info.count = new_count
            break
        end
    end
end
addEvent( "onUpdateCasesCacheGlobalCount", true )
addEventHandler( "onUpdateCasesCacheGlobalCount", root, onUpdateCasesCacheGlobalCount_handler )

function ibCreateCaseContentPane( x, y, sx, sy, case_id, parent, bias_x, bias_y )
	local pCaseInfo = WEB_CASES_DATA[ case_id ]
	if not pCaseInfo then return end

	local rows = math.floor( sx / 120 )

    local items_pane, scroll_v    = ibCreateScrollpane( x, y, sx, sy, parent, { scroll_px = -25, bg_color = 0x00FFFFFF } )
    scroll_v:ibData( "sensivity", 0.1 )
    scroll_v:ibData( "alpha", 0.35*255 )

    if next( pCaseInfo.items ) then
        for j, item in pairs( pCaseInfo.items ) do
            if REGISTERED_CASE_ITEMS[ item.id ] then
                CreateCaseItem( item, (bias_x or 0) + 108 * ( ( j - 1 ) % rows ), (bias_y or 0) + 5 + 108 * math.floor( ( j - 1 ) / rows ), items_pane )
            end
        end
    end

    items_pane:AdaptHeightToContents( )

    return items_pane, scroll_v
end

function CreateCaseItem( item, pos_x, pos_y, bg )
    local item_bg       = ibCreateImage( pos_x, pos_y, 96, 96, ":nrp_shop/img/cases/item_bg.png", bg )
    local item_bg_hover = ibCreateImage( 0, 0, 96, 96, ":nrp_shop/img/cases/item_bg_hover.png", item_bg ):ibData( "alpha", 0 )
    ibCreateImage( 16, -9, 65, 29, ":nrp_shop/img/cases/rare.png", item_bg, CONST_RARE_COLORS[ item.rare ] )
    REGISTERED_CASE_ITEMS[ item.id ].uiCreateItem_func( item.id, item.params, item_bg, fonts )

    local description_area  = ibCreateArea( 3, 3, 90, 90, item_bg )
    addEventHandler( "ibOnElementMouseEnter", description_area, function( )
        if isElement( description_box ) then
            destroyElement( Udescription_box )
        end

        item_bg_hover:ibAlphaTo( 255, 350 )

        local description_data = REGISTERED_CASE_ITEMS[ item.id ].uiGetDescriptionData_func( item.id, item.params )
        if description_data then
            local title_len = dxGetTextWidth( description_data.title, 1, ibFonts.bold_15 ) + 30
            local box_s_x = math.max( 170, title_len )
            local box_s_y = 92
            if not description_data.description then
                box_s_x = title_len
                box_s_y = 35
            end

            local pos_x, pos_y = getCursorPosition( )
            pos_x, pos_y = pos_x * _SCREEN_X, pos_y * _SCREEN_Y
    
            description_box = ibCreateImage( pos_x - 5, pos_y - box_s_y - 5, box_s_x, box_s_y, nil, nil, 0xCC000000 )
                :ibData( "alpha", 0 )
                :ibAlphaTo( 255, 350 )
                :ibOnRender( function ( )
                    local cx, cy = getCursorPosition( )
                    cx, cy = cx * _SCREEN_X, cy * _SCREEN_Y
                    description_box:ibBatchData( { px = cx - 5, py = cy - box_s_y - 5 } )
                end )

            ibCreateLabel( 0, 17, box_s_x, 0, description_data.title, description_box ):ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" })
            if description_data.description then
                ibCreateLabel( 0, 30, box_s_x, 0, description_data.description, description_box, 0xffd3d3d3 ):ibBatchData( { font = ibFonts.regular_13, align_x = "center", align_y = "top" })
            end
        end
    end, false )

    addEventHandler( "ibOnElementMouseLeave", description_area, function( )
        if isElement( description_box ) then
            destroyElement( description_box )
        end

        item_bg_hover:ibAlphaTo( 0, 350 )
    end, false )

    return item_bg
end