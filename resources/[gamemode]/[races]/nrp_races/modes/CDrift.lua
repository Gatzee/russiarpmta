MODES[ RACE_TYPE_DRIFT ] = 
{
    id = RACE_TYPE_DRIFT,
    countdown_text = { "Дрифтуй", "Не врезайся", "Побеждай", },
    name = RACE_TYPES_DATA[ RACE_TYPE_DRIFT ].name,
    tabs = 
    { 
        {
            name = "Лобби",
            create_content = function( parent )
                local fields =
                {
                    { size_x = 134, name = "Позиция", },
                    { size_x = 372, name = "Имя персонажа", },
                    { size_x = 306, name = "Награда", },
                    { size_x = 182, name = "Очки/Время/Победы", },
                }
                
                ibCreateButton( 860, 20, 134, 16, parent, "files/img/mode_selector/btn_create_lobby.png", "files/img/mode_selector/btn_create_lobby.png", "files/img/mode_selector/btn_create_lobby.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFFCCCCCC )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "down" then return end
                    ibClick()
                    triggerEvent( "ShowPhoneUI", localPlayer, false )
                    triggerServerEvent( "RC:onServerPlayerTryStartRace", resourceRoot, UI_elements.current_item.id )
                    ShowLobbyCreateUI( false )
                end )

                ibCreateLabel( 30, 15, 0, 0, "Трасса “Олимпийский парк”", parent, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_18 )
                ibCreateImage( 30, 53, 964, 273, "files/img/mode_selector/track.png", parent )
                ibCreateLabel( 30, 341, 0, 0, "Таблица лидеров", parent, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_18 )
                
                local function RefreshLeaderBoard( vehicle_class )
                    if isElement( UI_elements.leader_board ) then
                        destroyElement( UI_elements.leader_board )
                    end
                    if #UI_elements.records_data[ UI_elements.current_item.id ][ vehicle_class ] == 0 then
                        UI_elements.leader_board = ibCreateLabel( 0, 424, 1024, 211, "В этом сезоне ещё нет заездов на автомобилях данного класса", parent, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_14 )
                        return
                    end

                    local px = 30
                    UI_elements.leader_board = ibCreateArea( 0, 424, 1024, 211, parent )
                    for k, v in ipairs( fields ) do
                        ibCreateLabel( px, 0, v.size_x, 31, v.name, UI_elements.leader_board, 0xFF7E8D9D, 1, 1, "left", "center", ibFonts.regular_12 )
                        px = px + v.size_x
                    end

                    local py = 0
                    UI_elements.tab_scrollpane, UI_elements.tab_scrollbar = ibCreateScrollpane( 0, 31, 1024, 180, UI_elements.leader_board )
                    for k, v in ipairs( UI_elements.records_data[ UI_elements.current_item.id ][ vehicle_class ] ) do
                        if k > 3 then break end
                        local container = ibCreateImage( 0, py, 1024, 50, _, UI_elements.tab_scrollpane, k % 2 == 0 and 0x00000000 or 0xFF415469 )
                        ibCreateLabel( 51, 0, 0, 50, k, container, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 )
                        ibCreateLabel( 164, 0, 0, 50, v.nickname, container, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 )
                        if k <= 3 then
                            ibCreateImage( 546, 10, 27, 30, "files/img/mode_selector/place_" .. k .. ".png", container )
                        else
                            ibCreateLabel( 546, 10, 27, 52, "-", container, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_16 )
                        end
                        ibCreateLabel( 842, 0, 0, 50, MODES[ UI_elements.current_item.id ].prepare_points( v[ UI_elements.race_type_points ] ), container, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 )
                        py = py + 50
                    end

                    UI_elements.tab_scrollpane:AdaptHeightToContents()
                    UI_elements.tab_scrollbar:UpdateScrollbarVisibility( UI_elements.tab_scrollpane )
                end
                
                local px, py = 30, 383
                for k, v in ipairs( RACE_VEHICLE_CLASSES_NAMES ) do
                    if k <= 5 then
                        UI_elements[ "class_" .. k .. "_btn" ] = ibCreateImage( px, py, 82, 32, "files/img/mode_selector/btn_class.png", parent )
                                :ibOnHover( function( )
                            if UI_elements.leader_board_class ~= k then
                                UI_elements[ "class_" .. k .. "_btn" ]:ibData( "texture", "files/img/mode_selector/btn_class_hover.png" )
                            end
                        end )
                                :ibOnLeave( function( )
                            if UI_elements.leader_board_class ~= k then
                                UI_elements[ "class_" .. k .. "_btn" ]:ibData( "texture", "files/img/mode_selector/btn_class.png" )
                            end
                        end )
                                :ibOnClick( function( button, state )
                            if button ~= "left" or state ~= "down" then return end
                            ibClick()
                            if UI_elements.leader_board_class ~= k then
                                UI_elements[ "class_" .. UI_elements.leader_board_class .. "_btn" ]:ibData( "texture", "files/img/mode_selector/btn_class.png" )

                                RefreshLeaderBoard( k )
                                UI_elements.leader_board_class = k
                                UI_elements[ "class_" .. k .. "_btn" ]:ibData( "texture", "files/img/mode_selector/btn_class_hover.png" )
                            end
                        end )
                        ibCreateLabel( 0, 0, 82, 32, "КЛАСС " .. v, UI_elements[ "class_" .. k .. "_btn" ], 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_12 ):ibData( "disabled", true )
                        px = px + 102
                    end
                end

                RefreshLeaderBoard( 1 )
                UI_elements.leader_board_class = 1
                UI_elements[ "class_" .. UI_elements.leader_board_class .. "_btn" ]:ibData( "texture", "files/img/mode_selector/btn_class_hover.png" )

                return parent
            end,
        }, 
        {
            name = "Статистика",
            create_content = function( parent )

                local function RefreshStatsList( vehicle_class )
                    if isElement( UI_elements.leader_board ) then
                        destroyElement( UI_elements.leader_board )
                    end
                    
                    local is_empty = true
                    for race_type, race_data in pairs( RACE_TYPES_DATA ) do
                        if #UI_elements.player_stats[ race_type ][ vehicle_class ] ~= 0 then
                            is_empty = false
                            break
                        end
                    end
                    
                    if is_empty then
                        UI_elements.leader_board = ibCreateLabel( 0, 52, 1024, 583, "У вас ещё нет заездов на автомобилях данного класса", parent, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_14 )
                        :ibData( "disabled", true )
                        return
                    end

                    local fields =
                    {
                        { size_x = 259, name = "Тип гонки", },
                        { size_x = 219, name = "Позиция", },
                        { size_x = 335, name = "Автомобиль", },
                        { size_x = 0,   name = "Очки/Время/Победы", },
                    }

                    UI_elements.leader_board = ibCreateArea( 0, 60, 1024, 211, parent )
                    local px = 30
                    for k, v in ipairs( fields ) do
                        ibCreateLabel( px, 0, v.size_x, 31, v.name, UI_elements.leader_board, 0xFF7E8D9D, 1, 1, "left", "center", ibFonts.regular_12 )
                        px = px + v.size_x
                    end
                    UI_elements.tab_scrollpane, UI_elements.tab_scrollbar = ibCreateScrollpane( 0, 39, 1024, 578, UI_elements.leader_board )

                    local py = 0
                    for race_type, race_data in pairs( RACE_TYPES_DATA ) do
                        for k, v in ipairs( UI_elements.player_stats[ race_type ][ vehicle_class ] ) do
                            local container = ibCreateImage( 0, py, 1024, 50, _, UI_elements.tab_scrollpane, k % 2 == 0 and 0x00000000 or 0xFF415469 )
                            ibCreateImage( 33, 10, 0, 0, "files/img/mode_selector/" .. RACE_TYPES_DATA[ race_type ].type .. "_icon.png", container )
                            :ibSetRealSize()
                            ibCreateLabel( 88,  0, 0,  50, RACE_TYPES_DATA[ race_type ].name, container, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_14 )
                            
                            if v.place <= 3 then
                                ibCreateImage( 301, 10, 27, 30, "files/img/mode_selector/place_" .. v.place .. ".png", container )
                            else
                                ibCreateLabel( 289, 0, 50, 52, v.place, container, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_16 )
                            end 
                            
                            ibCreateLabel( 508, 0, 0,  50, VEHICLE_CONFIG[ v.model ].model, container, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_14 )
                            ibCreateLabel( 843, 0, 0,  50, MODES[ race_type ].prepare_points( v.points ), container, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 )
                            py = py + 50
                        end
                    end

                    UI_elements.tab_scrollpane:AdaptHeightToContents()
                    UI_elements.tab_scrollbar:UpdateScrollbarVisibility( UI_elements.tab_scrollpane )
                end

                local px, py = 30, 20
                for k, v in ipairs( RACE_VEHICLE_CLASSES_NAMES ) do
                    UI_elements[ "class_" .. k .. "_btn" ] = ibCreateImage( px, py, 82, 32, "files/img/mode_selector/btn_class.png", parent )
                    :ibOnHover( function( )
                        if UI_elements.leader_board_class ~= k then
                            UI_elements[ "class_" .. k .. "_btn" ]:ibData( "texture", "files/img/mode_selector/btn_class_hover.png" )
                        end
                    end )
                    :ibOnLeave( function( )
                        if UI_elements.leader_board_class ~= k then
                            UI_elements[ "class_" .. k .. "_btn" ]:ibData( "texture", "files/img/mode_selector/btn_class.png" )
                        end
                    end )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "down" then return end
                        ibClick()
                        if UI_elements.leader_board_class ~= k then
                            UI_elements[ "class_" .. UI_elements.leader_board_class .. "_btn" ]:ibData( "texture", "files/img/mode_selector/btn_class.png" )

                            RefreshStatsList( k )
                            UI_elements.leader_board_class = k
                            UI_elements[ "class_" .. k .. "_btn" ]:ibData( "texture", "files/img/mode_selector/btn_class_hover.png" )
                        end
                    end )
                    ibCreateLabel( 0, 0, 82, 32, "КЛАСС " .. v, UI_elements[ "class_" .. k .. "_btn" ], 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_12 )
                    :ibData( "disabled", true )
                    px = px + 102
                end

                RefreshStatsList( 1 )
                UI_elements.leader_board_class = 1
                UI_elements[ "class_" .. UI_elements.leader_board_class .. "_btn" ]:ibData( "texture", "files/img/mode_selector/btn_class_hover.png" )

                return parent
            end,
        }, 
        {
            name = "Таблица лидеров",
            create_content = function( parent )
                local function RefreshLeaderBoard( vehicle_class )
                    if isElement( UI_elements.leader_board ) then
                        destroyElement( UI_elements.leader_board )
                    end

                    if #UI_elements.records_data[ UI_elements.current_item.id ][ vehicle_class ] == 0 then
                        UI_elements.leader_board = ibCreateLabel( 0, 60, 1024, 583, "В этом сезоне ещё нет заездов на автомобилях данного класса", parent, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_14 )
                        return
                    end

                    local fields =
                    {
                        { size_x = 99,  name = "Лого", },
                        { size_x = 230, name = "Ник персонажа", },
                        { size_x = 180, name = "Позиция" },
                        { size_x = 335, name = "Автомобиль", },
                        { size_x = 0,   name = "Очки/Время/Победы", },
                    }

                    local px = 30
                    UI_elements.leader_board = ibCreateArea( 0, 60, 1024, 211, parent )
                    for k, v in ipairs( fields ) do
                        ibCreateLabel( px, 0, v.size_x, 31, v.name, UI_elements.leader_board, 0xFF7E8D9D, 1, 1, "left", "center", ibFonts.regular_12 )
                        px = px + v.size_x
                    end
                        
                    local py = 0
                    UI_elements.tab_scrollpane, UI_elements.tab_scrollbar = ibCreateScrollpane( 0, 39, 1024, 578, UI_elements.leader_board )
                    for k, v in ipairs( UI_elements.records_data[ UI_elements.current_item.id ][ vehicle_class ] ) do
                        local container = ibCreateImage( 0, py, 1024, 50, _, UI_elements.tab_scrollpane, k % 2 == 0 and 0x00000000 or 0xFF415469 )
                        ibCreateImage( 30, 9, 34, 34, (v.clan_id and (":nrp_clans/img/tags/band/" .. v.clan_id) or "files/img/mode_selector/wheel_icon") .. ".png", container )  
                        ibCreateLabel( 129, 0, 0, 50, v.nickname, container, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_14 )
                        if k <= 3 then
                            ibCreateImage( 371, 10, 27, 30, "files/img/mode_selector/place_" .. k .. ".png", container )
                        else
                            ibCreateLabel( 359, 10, 50, 52, k, container, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_16 )
                        end                        
                        ibCreateLabel( 538, 0, 0, 50, VEHICLE_CONFIG[ v.model ].model, container, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_14 )
                        ibCreateLabel( 873, 0, 0, 50, MODES[ UI_elements.current_item.id ].prepare_points( v[ UI_elements.race_type_points ] ), container, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_14 )
                        py = py + 50
                    end

                    UI_elements.tab_scrollpane:AdaptHeightToContents()
                    UI_elements.tab_scrollbar:UpdateScrollbarVisibility( UI_elements.tab_scrollpane )
                end

                local px, py = 30, 20
                for k, v in ipairs( RACE_VEHICLE_CLASSES_NAMES ) do
                    UI_elements[ "class_" .. k .. "_btn" ] = ibCreateImage( px, py, 82, 32, "files/img/mode_selector/btn_class.png", parent )
                    :ibOnHover( function( )
                        if UI_elements.leader_board_class ~= k then
                            UI_elements[ "class_" .. k .. "_btn" ]:ibData( "texture", "files/img/mode_selector/btn_class_hover.png" )
                        end
                    end )
                    :ibOnLeave( function( )
                        if UI_elements.leader_board_class ~= k then
                            UI_elements[ "class_" .. k .. "_btn" ]:ibData( "texture", "files/img/mode_selector/btn_class.png" )
                        end
                    end )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "down" then return end
                        ibClick()
                        if UI_elements.leader_board_class ~= k then
                            UI_elements[ "class_" .. UI_elements.leader_board_class .. "_btn" ]:ibData( "texture", "files/img/mode_selector/btn_class.png" )

                            RefreshLeaderBoard( k )
                            UI_elements.leader_board_class = k
                            UI_elements[ "class_" .. k .. "_btn" ]:ibData( "texture", "files/img/mode_selector/btn_class_hover.png" )
                        end
                    end )
                    ibCreateLabel( 0, 0, 82, 32, "КЛАСС " .. v, UI_elements[ "class_" .. k .. "_btn" ], 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_12 )
                    :ibData( "disabled", true )
                    px = px + 102
                end

                RefreshLeaderBoard( 1 )
                UI_elements.leader_board_class = 1
                UI_elements[ "class_" .. UI_elements.leader_board_class .. "_btn" ]:ibData( "texture", "files/img/mode_selector/btn_class_hover.png" )

                return parent
            end,
        },
        {
            name = "Награды",
            create_content = function( parent )
                local bg = ibCreateImage( 0, 0, 1024, 606, "files/img/mode_selector/bg_reward.png", parent )
                :ibData( "blend_mode", "modulate_add" )
                :ibData( "blend_mode_after", "blend" )
                
                local img = ibCreateImage( 372, 20, 22, 24, ":nrp_shop/img/icon_timer.png", bg )
				local time_desc_label = ibCreateLabel( img:ibGetAfterX( 10 ), img:ibGetCenterY( ), 0, 0, "До конца сезона:", bg, ibApplyAlpha( COLOR_WHITE, 95 ), _, _, "left", "center", ibFonts.regular_14 )
				local time_label = ibCreateLabel( time_desc_label:ibGetAfterX( 5 ), time_desc_label:ibGetCenterY( ), 0, 0, "", bg, ibApplyAlpha( COLOR_WHITE, 95 ), _, _, "left", "center", ibFonts.bold_14 )
				local function UpdateTime( )
					time_label:ibData( "text", getHumanTimeString( UI_elements.season_end ) )
                end
				UpdateTime( )
				time_label:ibTimer( UpdateTime, 500, 0 )

                local px, py = 0, 350
                local icon_sx, icon_sy = 0, 0
                for k, v in pairs( { 2, 1, 3 } ) do
                    local reward_name = ""
                    local reward_img = ""
                    local reward_content = false
                    local reward_sx, reward_sy
                    local reward = SEASON_REWARD[ UI_elements.season_number ][ UI_elements.current_item.id ][ v ][ 1 ]
                    if reward.type == "vinil" then
                        reward_name = "Уникальный винил"
                        reward_img = ":nrp_vinyls/img/" .. reward.value .. ".dds"
                        icon_sx, icon_sy = 200, 94
                    elseif reward.type == "accessories" then
                        reward_name = CONST_ACCESSORIES_INFO[ reward.value ].name
                        reward_img = reward.value
                        reward_content = "accessory"
                        reward_sx, reward_sy = 90, 90
                        icon_sx, icon_sy = 80, 80
                    elseif reward.type == "vinil_case" then
                        reward_name = "Винил кейс \"" .. CASES_NAME[ "vinyl_" .. reward.value ] .. "\""
                        reward_img = "vinyl_" .. reward.value
                        reward_content = "case"
                        reward_sx, reward_sy = 372, 252
                        icon_sx, icon_sy = 202, 149
                    elseif reward.type == "tuning_case" then
                        reward_name = "Тюнинг кейс \"" .. CASES_NAME[ "tuning_" .. reward.value ] .. "\""
                        reward_img = "tuning_" .. reward.value
                        reward_content = "case"
                        reward_sx, reward_sy = 372, 252
                        icon_sx, icon_sy = 248, 140
                    end
                    
                    local cpx = px + ( 350 - icon_sx ) / 2
                    local case_area = ibCreateArea( cpx, py, icon_sx, icon_sy, parent )
                    local case = reward_content and ibCreateContentImage( 0, 0, reward_sx, reward_sy, reward_content, reward_img, case_area ) or ibCreateImage( 0, 0, icon_sx, icon_sy, reward_img, case_area )

                    if reward_content then
                        case:ibSetInBoundSize( icon_sx, icon_sy )
                    end

                    case:center( )

                    local sx, sy = case:ibData( "sx" ), case:ibData( "sy" )
                    ibCreateLabel( case_area:ibData( "px" ), py + sy, icon_sx, 40, reward_name, parent, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.regular_16 )

                    ibCreateImage( px + 72, py + 200, 27, 30, "files/img/mode_selector/place_" .. v .. ".png", parent )
                    ibCreateLabel( px + 106, py + 200, 0, 30, "Статус никнейма", parent, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.regular_14 )

                    px = px + 340
                end

                return parent
            end,
        }, 
    },
    create_content = function( parent )
        UI_elements.current_tab_id = 1

        local px = 30
        for k, v in ipairs( UI_elements.current_item.tabs ) do
            local sx = dxGetTextWidth( v.name, 1, ibFonts.bold_16 )
            UI_elements[ "tab_area_" .. k ] = ibCreateArea( px, 15, sx, 25, parent )
            :ibOnHover( function( )
                if k ~= UI_elements.current_tab_id then
                    UI_elements[ "tab_" .. k .. "_name" ]:ibData( "color", 0xFFFFFFFF )
                end
            end )
            :ibOnLeave( function( )
                if k ~= UI_elements.current_tab_id then
                    UI_elements[ "tab_" .. k .. "_name" ]:ibData( "color", 0xFFC1C7CD )
                end
            end )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                ibClick()
                if UI_elements.current_tab_id ~= k then
                    ChangeItemTab( k )
                end
            end )

            UI_elements[ "tab_" .. k .. "_name" ] = ibCreateLabel( 0, 0, sx, 22, v.name, UI_elements[ "tab_area_" .. k ], 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 )
            :ibData( "disabled", true )
            if k ~= UI_elements.current_tab_id then
                UI_elements[ "tab_" .. k .. "_name" ]:ibData( "color", 0xFFC1C7CD )
            end

            px = px + sx + 29 
        end

        ibCreateImage( 30, 52, 964, 1, _, parent, 0x0FC1C7CD )
        UI_elements.tab_caret = ibCreateImage( 30, 49, 52, 4, _, parent, 0xFFFF965D )
        
        UI_elements.current_tab = ibCreateArea( 0, 53, 1024, 635, parent )
        UI_elements.current_item.tabs[ UI_elements.current_tab_id ].create_content( UI_elements.current_tab )

        return parent
    end,

    detect_wrong_size = true,
    detect_damage = false,
    limit_time = 60 * 5,
    callback_limit_time = function()
        DestroyDrift()
        CreateUIStartTimer( { "Подсчёт очков" }, 5000 )
        triggerServerEvent( "RC:OnPlayerCheckpoint", resourceRoot, localPlayer, CLIENT_VAR_drift_total_score, true )
    end,

    text_points = "Очки",
	prepare_points = function( value )
		return format_price( value ) .. " очков"
    end,
    leader_boards = true,
}

CONST_MAX_DRIFT_MUL = 9
CONST_TIME_TO_DRIFT_IDLE_WAIT = 1000

CLIENT_VAR_tick = 0
CLIENT_VAR_drift_score = 0
CLIENT_VAR_drift_mp = 0
CLIENT_VAR_drift_mp_time = 0
CLIENT_VAR_drift_chain = 1
CLIENT_VAR_drift_side = nil
CLIENT_VAR_drift_chain_tick = 0
CLIENT_VAR_drift_ilde_tick = 0
CONST_TIME_TO_ZONE_EXIT = 10

CLIENT_VAR_drift_total_score = 0

function InitializeDrift()
    CLIENT_is_drift_start = true
    CLIENT_VAR_tick = 0
    CLIENT_VAR_drift_score = 0
    CLIENT_VAR_drift_total_score = 0
    CLIENT_VAR_drift_mp = 0
    CLIENT_VAR_drift_mp_time = 0
    CLIENT_VAR_drift_chain = 1
    CLIENT_VAR_drift_side = nil
    CLIENT_VAR_drift_chain_tick = 0
    CLIENT_VAR_drift_ilde_tick = 0

    CreateUIDrift( CONST_MAX_DRIFT_MUL )
    setCameraClip( true, false )
    addEventHandler( "onClientRender", root, OnDriftRenderHandler )
    addEventHandler( "onClientVehicleCollision", localPlayer.vehicle, onClientVehicleCollision_handler )

    AddZoneTrack()
end

function DestroyDrift()
    CLIENT_is_drift_start = false
    removeEventHandler( "onClientVehicleCollision", localPlayer.vehicle, onClientVehicleCollision_handler )
    removeEventHandler( "onClientRender", root, OnDriftRenderHandler )
    setCameraClip( true, true )
    if isElement( UI_elements.drift_bg ) then
        destroyElement( UI_elements.drift_bg )
    end

    DestroyZoneTrack()
end

function onClientVehicleCollision_handler()
    CLIENT_EndDrift( true )
end

function CreateUIDrift( max_mul )
	UI_elements.drift_bg = ibCreateArea( 0, 100, 0, 0 ):center_x( )

	UI_elements.drift_points_mul_bg = ibCreateImage( 0, 0, 72, 72, "files/img/drift/drift_bg.png", UI_elements.drift_bg ):center( )

	UI_elements.drift_points_mul = { }
	for i = 1, max_mul do
		UI_elements.drift_points_mul[ i ] = ibCreateImage( 0, 0, 72, 72, "files/img/drift/drift_mul.png", UI_elements.drift_points_mul_bg, ibApplyAlpha( 0xffff965d, 50 ) ):ibData( "rotation", ( i - 1 ) * 30 )
	end
	UI_elements.drift_points_mul[ 1 ]:ibData( "color", ibApplyAlpha( 0xffff965d, 100 ) )

	UI_elements.drift_points_mul_lbl = ibCreateLabel( 0, 0, 0, 0, "x1", UI_elements.drift_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_24 )
	:center_y( )
	:ibData( "outline", true )

    UI_elements.drift_total_points = ibCreateLabel( UI_elements.drift_points_mul_bg:ibGetBeforeX( -20 ), 0, 0, 0, "0", UI_elements.drift_bg, COLOR_WHITE, 1, 1, "right", "center", ibFonts.bold_15 )
	:center_y( -10 )
	:ibData( "outline", true )

    UI_elements.drift_total_points_info = ibCreateLabel( UI_elements.drift_total_points:ibGetBeforeX( -5 ), 0, 0, 0, "TOTAL:", UI_elements.drift_bg, COLOR_WHITE, 1, 1, "right", "center", ibFonts.regular_12 )
	:center_y( -10 )
	:ibData( "outline", true )

    UI_elements.drift_current_points = ibCreateLabel( UI_elements.drift_points_mul_bg:ibGetBeforeX( -20 ), 0, 0, 0, "+0", UI_elements.drift_bg, COLOR_WHITE, 1, 1, "right", "center", ibFonts.bold_26 )
	:center_y( 10 )
    :ibData( "outline", true )
end

function UpdateUIDrift_total( drift_total_points )
	UI_elements.drift_total_points:ibData( "text", format_price( drift_total_points ) )
	:ibInterpolate( function( self )
		if not isElement( self.element ) then return end
		self.easing_value = 1 + 0.2 * self.easing_value
		self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
	end, 350, "SineCurve" )
	
    UI_elements.drift_total_points_info:ibData( "px", UI_elements.drift_total_points:ibGetBeforeX( -5 ) )

    local temp = {}
    for k, v in pairs( UI_elements.stats_nick ) do
        table.insert( temp, {
            nickname = UI_elements.stats_nick[ k ]:ibData( "text" ),
            value = tonumber( UI_elements.stats_value[ k ]:ibData( "value" ) ) or 0,
        } )
    end
    
    if #temp > 1 then
        table.sort( temp, function( a, b )
            return a.value > b.value
        end )
    end

    local player_nick = localPlayer:GetNickName()
    for k, v in ipairs( temp ) do
        UI_elements.stats_nick[ k ]:ibData( "text", v.nickname )
        UI_elements.stats_value[ k ]:ibData( "text", MODES[ RACE_DATA.race_type ].prepare_points( player_nick == v.nickname and drift_total_points or v.value ) )
    end

end

function UpdateUIDrift_current( drift_current_points )
	UI_elements.drift_current_points:ibData( "text", "+".. format_price( drift_current_points ) )
end

function UpdateUIDrift_mul( drift_points_mul )
	UI_elements.drift_points_mul_lbl:ibData( "text", "x".. drift_points_mul )
	:ibInterpolate( function( self )
		if not isElement( self.element ) then return end
		self.easing_value = 1 + 0.2 * self.easing_value
		self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
	end, 350, "SineCurve" )

	for i, mul_img in pairs( UI_elements.drift_points_mul ) do
		mul_img:ibData( "color", ibApplyAlpha( 0xffff965d, i > drift_points_mul and 50 or 100 ) )
	end
end

function UpdateUIDrift_state( state )
	if isElement( UI_elements.drift_state_lbl ) then
		destroyElement( UI_elements.drift_state_lbl )
	end

	UI_elements.drift_state_lbl = ibCreateLabel( UI_elements.drift_points_mul_bg:ibGetAfterX( 20 ), 0, 0, 0, ( state and "ВЫПОЛНЕНО" or "НЕУДАЧА" ), UI_elements.drift_bg, ( state and COLOR_WHITE or 0xFFFF4E4E ), 1, 1, "left", "center", ibFonts.bold_14 )
	:center_y( )
	:ibData( "outline", true )
	:ibData( "alpha", 0 )
	:ibAlphaTo( 255, 250 )
	:ibTimer( ibAlphaTo, 1000, 1, 0, 250 )
	:ibTimer( destroyElement, 1500, 1 )
end

function OnDriftRenderHandler( )
    if not localPlayer.vehicle then return end
    
	CLIENT_VAR_tick = getTickCount( )
	local angle, velocity, side = CLIENT_CalculateDriftData( )
	if side then
		if side ~= CLIENT_VAR_drift_side then
			if ( CLIENT_VAR_tick - CLIENT_VAR_drift_chain_tick ) >= 1300 then
				if CLIENT_VAR_drift_chain < CONST_MAX_DRIFT_MUL then
					CLIENT_VAR_drift_chain = CLIENT_VAR_drift_chain + 1
					CLIENT_VAR_drift_chain_tick = CLIENT_VAR_tick

					UpdateUIDrift_mul( CLIENT_VAR_drift_chain )
				end

                CLIENT_VAR_drift_side = side
                UpdateUIDrift_state( true )
			end
		end
	end

	local is_idle = ( CLIENT_VAR_tick - ( CLIENT_VAR_drift_ilde_tick ) ) > CONST_TIME_TO_DRIFT_IDLE_WAIT
	if is_idle and CLIENT_VAR_drift_score ~= 0 then
		CLIENT_EndDrift( )
		CLIENT_VAR_drift_score = 0
	else
		if angle ~= 0 then
			local tmp = math.floor( math.abs( angle ) ^ 0.7 * math.abs( velocity ) * CLIENT_VAR_drift_mp )
			if tmp > 0 then
				CLIENT_VAR_drift_score = CLIENT_VAR_drift_score + tmp
				UpdateUIDrift_current( CLIENT_VAR_drift_score )

				CLIENT_VAR_drift_ilde_tick = CLIENT_VAR_tick
			end
		end
    end
    
end

function CLIENT_CalculateDriftData( )
	local vehicle = localPlayer.vehicle

	local vx, vy, vz = getElementVelocity( vehicle )
	local modV = math.sqrt( vx * vx + vy * vy )

	if not isVehicleOnGround( vehicle ) or UI_elements.wrong_way then
		return 0
    end
    
	local rz = vehicle.rotation.z
	local sn, cs = math.sin( math.rad( rz ) ), math.cos( math.rad(rz ) )

	local timediff = CLIENT_VAR_tick - CLIENT_VAR_drift_mp_time
	if CLIENT_VAR_drift_mp > 1 and modV <= 0.3 and timediff > CONST_TIME_TO_DRIFT_IDLE_WAIT then
		CLIENT_VAR_drift_mp = math.max( CLIENT_VAR_drift_mp - 1, 1 )
		CLIENT_VAR_drift_mp_time = CLIENT_VAR_tick

	elseif timediff > 1500 then
		local temp = 1 + math.min( CLIENT_VAR_drift_chain / 2, 10 )
		if temp > CLIENT_VAR_drift_mp then
			CLIENT_VAR_drift_mp = temp
			CLIENT_VAR_drift_mp_time = CLIENT_VAR_tick
		end
	end

	if modV <= 0.15 then
		return 0
	end

	local velocity = vehicle.velocity
	local forward = vehicle.matrix.forward

	local divisor = ( velocity.length * forward.length )
	local cosine = velocity:dot( forward ) / ( divisor ~= 0 and divisor or 1 )

	local angle = math.deg( math.acos( cosine ) )
	if angle < 15 or angle > 75 then
		return 0
	end

	local right = vehicle.matrix.right
	return angle, modV, ( velocity:dot(right) >= 0 and "left" or "right" )
end


local CONST_GAME_ZONE_EXIT = {
	1458.161, 1631.061,
	1439.597, 1660.265,
	1404.279, 1735.820,
	1612.499, 1866.476,
	1643.867, 1818.931,
	1709.444, 1861.462,
	1722.054, 1908.740,
	1676.098, 1920.720,
	1670.674, 1940.169,
	1674.473, 1956.966,
	1685.293, 2006.961,
	1684.031, 2053.999,
	1673.093, 2092.622,
	1623.093, 2222.757,
	1604.972, 2311.808,
	1598.189, 2382.575,
	1605.060, 2429.830,
	1621.005, 2469.613,
	1636.537, 2498.326,
	1660.907, 2501.528,
	1753.570, 2467.733,
	1778.494, 2461.179,
	1821.240, 2470.921,
	1830.272, 2481.894,
	1859.969, 2635.324,
	1948.187, 2646.123,
	1973.081, 2639.653,
	2087.715, 2581.379,
	2070.271, 2551.291,
	1961.117, 2375.779,
	1866.971, 2412.902,
	1821.540, 2418.272,
	1785.931, 2404.906,
	1762.929, 2383.605,
	1747.637, 2352.198,
	1746.995, 2308.511,
	1771.910, 2264.489,
	1846.530, 2204.301,
	1846.298, 2192.351,
	1841.527, 2167.017,
	1754.639, 1859.183,
	1731.474, 1821.313,
	1706.693, 1801.667,
	1708.148, 1799.763,
	1505.930, 1671.723,
	1506.073, 1668.653,
	1467.371, 1635.229,
	1458.161, 1631.061,
}

local CONST_GAME_ZONE_ENTER = {
	1468.347, 1665.669,
	1454.745, 1667.781,
	1446.810, 1688.621,
	1445.193, 1705.563,
	1435.595, 1733.794,
	1490.742, 1768.603,
	1495.144, 1776.608,
	1589.576, 1833.896,
	1600.374, 1835.211,
	1603.507, 1842.169,
	1605.751, 1842.134,
	1635.397, 1793.628,
	1714.096, 1840.926,
	1731.736, 1859.615,
	1746.065, 1920.060,
	1693.682, 1934.299,
	1687.031, 1939.909,
	1694.279, 1964.196,
	1700.444, 1988.934,
	1703.176, 2013.270,
	1698.937, 2030.784,
	1697.896, 2051.737,
	1691.860, 2080.771,
	1630.747, 2247.726,
	1612.890, 2361.146,
	1623.237, 2439.744,
	1641.710, 2480.462,
	1650.404, 2487.013,
	1664.352, 2487.016,
	1759.651, 2449.893,
	1789.870, 2435.373,
	1834.366, 2437.467,
	1869.149, 2612.480,
	1884.220, 2625.692,
	1941.351, 2632.136,
	1973.521, 2624.996,
	2053.881, 2583.641,
	2060.936, 2562.600,
	2048.192, 2540.080,
	1980.813, 2431.583,
	1961.170, 2401.705,
	1938.670, 2398.167,
	1845.427, 2435.633,
	1832.998, 2431.771,
	1817.434, 2430.421,
	1789.645, 2423.279,
	1771.164, 2409.671,
	1755.240, 2395.390,
	1739.604, 2371.590,
	1728.641, 2332.993,
	1734.293, 2285.883,
	1765.890, 2251.965,
	1825.828, 2205.460,
	1831.409, 2201.414,
	1833.732, 2198.286,
	1833.699, 2189.838,
	1830.302, 2171.031,
	1805.167, 2083.534,
	1798.374, 2076.033,
	1782.889, 2021.368,
	1782.201, 2002.519,
	1745.200, 1873.420,
	1726.104, 1836.412,
	1709.157, 1824.344,
	1697.167, 1809.273,
	1468.347, 1665.669,
}

function CLIENT_EndDrift( failed )
	if not failed then
		CLIENT_VAR_drift_total_score = CLIENT_VAR_drift_total_score + CLIENT_VAR_drift_score
		UpdateUIDrift_total( CLIENT_VAR_drift_total_score )
	end

	CLIENT_VAR_drift_chain = 1
	CLIENT_VAR_drift_score = 0
	CLIENT_VAR_drift_chain_tick = 0
	CLIENT_VAR_drift_side = nil

	UpdateUIDrift_current( CLIENT_VAR_drift_score )
    UpdateUIDrift_mul( CLIENT_VAR_drift_chain )
    
    if failed then
		UpdateUIDrift_state( not failed )
	end
end

local function CLIENT_PlayerExitFromGameZone( element, dim )
	if not dim then return end

	if element == localPlayer then
		if isTimer( CLIENT_VAR_game_zone_exit_timer ) then
			killTimer( CLIENT_VAR_game_zone_exit_timer )
		end

        CLIENT_VAR_game_zone_exit_timer = Timer( function( )
            triggerServerEvent( "RC:OnPlayerRequestLeaveLobby", resourceRoot, localPlayer, true, RACE_STATE_LOSE, "Вы покинули зону состязания" )
		end, CONST_TIME_TO_ZONE_EXIT * 1000, 1 )

		CreateUIZoneExit( CONST_TIME_TO_ZONE_EXIT )
	end
end

local function CLIENT_PlayerEnterToGameZone( element, dim )
	if not dim then return end

	if element == localPlayer then
		if isTimer( CLIENT_VAR_game_zone_exit_timer ) then
			killTimer( CLIENT_VAR_game_zone_exit_timer )
			CLIENT_VAR_game_zone_exit_timer = false
		end

		DeleteUIZoneExit( )
	end
end

function AddZoneTrack()
    CLIENT_VAR_exit_zone_colshape = ColShape.Polygon( unpack( CONST_GAME_ZONE_EXIT ) )
	CLIENT_VAR_exit_zone_colshape.dimension = localPlayer.dimension
	addEventHandler( "onClientColShapeLeave", CLIENT_VAR_exit_zone_colshape, CLIENT_PlayerExitFromGameZone )
	addEventHandler( "onClientColShapeHit", CLIENT_VAR_exit_zone_colshape, CLIENT_PlayerEnterToGameZone )

	CLIENT_VAR_enter_zone_colshape = ColShape.Polygon( unpack( CONST_GAME_ZONE_ENTER ) )
	CLIENT_VAR_enter_zone_colshape.dimension = localPlayer.dimension
	addEventHandler( "onClientColShapeHit", CLIENT_VAR_enter_zone_colshape, CLIENT_PlayerExitFromGameZone )
	addEventHandler( "onClientColShapeLeave", CLIENT_VAR_enter_zone_colshape, CLIENT_PlayerEnterToGameZone )
end

function DestroyZoneTrack()
    if isElement( CLIENT_VAR_exit_zone_colshape ) then
        destroyElement( CLIENT_VAR_exit_zone_colshape )
        destroyElement( CLIENT_VAR_enter_zone_colshape )
    end
    CLIENT_PlayerEnterToGameZone( localPlayer, true )
end