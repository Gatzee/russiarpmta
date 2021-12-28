local UI_elements = { }
local px, py, sx, sy
local conf = { }

function ShowPlaylistUI_handler( state, cnf )
    if state then
        ShowPlaylistUI_handler( false )

        for i, v in pairs( cnf or { } ) do
            conf[ i ] = v
        end

        UI_elements.bg_texture = dxCreateTexture( "img/bg.png" )
        local x, y = guiGetScreenSize( )
        sx, sy = dxGetMaterialSize( UI_elements.bg_texture )
        px, py = x / 2 - sx / 2, y / 2 - sy / 2

        UI_elements.black_bg = ibCreateBackground( 0x99000000, ShowPlaylistUI_handler, true, true )
        UI_elements.bg = ibCreateImage( px, py + 100, sx, sy, UI_elements.bg_texture, UI_elements.black_bg ):ibData( "alpha", 0 )

        UI_elements.lbl_title = ibCreateLabel( 400, 35, 0, 0, "Плейлист", UI_elements.bg, _, _, _, "center", "center", ibFonts.bold_24 )

        UI_elements.btn_close
            = ibCreateButton(   sx - 24 - 24, 24, 22, 22, UI_elements.bg,
                                ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowPlaylistUI_handler( false )
            end )

        UI_elements.btn_back
            = ibCreateButton(   30, 28, 109, 17, UI_elements.bg, 
                                "img/btn_back.png", "img/btn_back.png", "img/btn_back.png", 
                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "down" then return end
                ibClick( )
                ShowPlaylistUI_handler( false )

                if CURRENT_ROOM then
                    triggerServerEvent( "onCinemaRequestRoomInformation", resourceRoot, CURRENT_ROOM )
                end
            end )

        UI_elements.bg_edit_search
            = ibCreateImage( 30, 102, 740, 30, "img/edit_search.png", UI_elements.bg )

        UI_elements.edit_search = ibCreateEdit( 70, 102, 660, 30, "", UI_elements.bg, 0xffffffff, 0x00000000, 0xffffffff )
            :ibBatchData( { font = ibFonts.bold_14 } )
            :ibOnDataChange( function( key, value )
                if key == "text" then
                    if utf8.len( value ) <= 0 then
                        Search( value, 1 )
                        UI_elements.edit_search:ibData( "caret_position", 0 )
                    else
                        if isTimer( UI_elements.search_timer ) then killTimer( UI_elements.search_timer ) end
                        UI_elements.search_timer = setTimer( Search, 1000, 1, value, 1 )
                    end
                
                elseif key == "focused" then
                    UI_elements.bg_edit_search:ibData( "texture", value and "img/edit_search_active.png" or "img/edit_search.png" )

                end
            end )

        ibCreateLabel( 200, 170, 0, 0, "Наименование видео", UI_elements.bg, 0xff8192a1, _, _, _, _, ibFonts.regular_12 )
        ibCreateLabel( 485, 170, 0, 0, "Стоимость", UI_elements.bg, 0xff8192a1, _, _, _, _, ibFonts.regular_12 )

        UI_elements.rt, UI_elements.sc = ibCreateScrollpane( 0, 190, sx, 300, UI_elements.bg, { scroll_px = -20 } )
        UI_elements.sc
            :ibSetStyle( "slim_nobg" )
            :ibBatchData( { sensivity = 100, absolute = true, color = 0x99ffffff } )
            :UpdateScrollbarVisibility( UI_elements.rt )

        -- Нижние кнопки
        CreateBottomButtons( )

        UI_elements.bg:ibAlphaTo( 255, 500 ):ibMoveTo( px, py, 700 )

        -- Дефолтный поиск / показ плейлиста
        UI_elements.edit_search:ibData( "text", "" )

        showCursor( true )
    else
        DestroyTableElements( UI_elements )
        showCursor( false )
    end
end
addEvent( "ShowPlaylistUI", true )
addEventHandler( "ShowPlaylistUI", root, ShowPlaylistUI_handler )

function CreateBottomButtons( )
    if not isElement( UI_elements.bg ) then return end

    DestroyTableElements( { UI_elements.btn_playlist_clear, UI_elements.btn_queue_join, UI_elements.btn_queue_leave } )

    local btn_playlist_clear
        = ibCreateButton(   158, 523, 226, 35, UI_elements.bg,  
                            "img/btn_playlist_clear.png", "img/btn_playlist_clear.png", "img/btn_playlist_clear.png",
                            0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )

            if IsInQueue( ) then
                localPlayer:ErrorWindow( "Ты сейчас в очереди воспроизведения! Покинь очередь чтобы очистить плейлист" )
                return
            end

            if #PLAYLIST <= 0 then
                localPlayer:ErrorWindow( "Твой плейлист и так пуст! :(" )
                return
            end

            if confirmation then confirmation:destroy( ) end
            confirmation = ibConfirm(
                {
                    title = "ОЧИСТКА ПЛЕЙЛИСТА", 
                    text = "Ты действительно хочешь очистить весь плейлист?\nДанное действие нельзя отменить" ,
                    fn = function( self )
                        PLAYLIST = { }
                        SavePlaylist( )
                        UI_elements.edit_search:ibData( "text", "" )
                        self:destroy()
                    end,
                    escape_close = true,
                }
            )
        end )
    UI_elements.btn_playlist_clear = btn_playlist_clear

    -- Если не в очереди, позволяем встать в очередь
    if not conf.in_queue then
        local btn_queue_join
            = ibCreateButton(   414, 523, 226, 35, UI_elements.bg,  
                                "img/btn_queue_join.png", "img/btn_queue_join.png", "img/btn_queue_join.png",
                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                local suitable_video = FindSuitableVideoForPlaylist( conf.is_vip )

                if #PLAYLIST == 0 then
                    localPlayer:ErrorWindow( "Твой плейлист пуст!" )
                    return
                
                elseif not suitable_video then
                    localPlayer:ErrorWindow( "В плейлисте нет подходящего видео для этого зала!" )
                    return

                end

                
                triggerServerEvent( "onCinemaJoinQueueRequest", resourceRoot, CURRENT_ROOM, suitable_video )
            end )
        UI_elements.btn_queue_join = btn_queue_join

    -- Если уже в очереди, возможность выйти
    else
        local btn_queue_leave
            = ibCreateButton(   414, 523, 226, 35, UI_elements.bg,  
                                "img/btn_queue_leave.png", "img/btn_queue_leave.png", "img/btn_queue_leave.png",
                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                triggerServerEvent( "onCinemaLeaveQueueRequest", resourceRoot, CURRENT_ROOM )
            end )
        UI_elements.btn_queue_leave = btn_queue_leave

    end
end

function onCinemaUpdateInQueueRequest_handler( in_queue )
    --iprint( "Rvc in queue", in_queue, getTickCount( ) )
    conf.in_queue = in_queue
    CreateBottomButtons( )
end
addEvent( "onCinemaUpdateInQueueRequest", true )
addEventHandler( "onCinemaUpdateInQueueRequest", root, onCinemaUpdateInQueueRequest_handler )

function IsInQueue( )
    return conf.in_queue
end

function Search( str, page )
    --iprint( "Search start", conf.is_vip, str, page )

    if not isElement( UI_elements.rt ) then return end
    local edit_text = UI_elements.edit_search:ibData( "text" )
    if str ~= edit_text then return end

    DestroyTableElements( getElementChildren( UI_elements.rt ) )

    ibCreateLabel( sx / 2, 120, 0, 0, "Загрузка...", UI_elements.rt, 0xaaffffff, _, _, "center", "center", ibFonts.bold_20 )
    
    local function BuildInterfaceList( list, is_playlist )
        if not isElement( UI_elements.rt ) then return end

        local edit_text = UI_elements.edit_search:ibData( "text" )
        if str ~= edit_text then return end

        -- Удаляем старые видео
        DestroyTableElements( getElementChildren( UI_elements.rt ) )

        -- Добавляем новые
        local npx, npy = 0, 0
        local nsx, nsy = sx, 100
        local is_black = true
        for i, v in pairs( list ) do
            if v.duration_seconds <= VIP_DURATION then
                local bg = ibCreateImage( npx, npy, nsx, nsy, _, UI_elements.rt, is_black and 0x30000000 or 0 )            

                -- Название видео с кастомным переносом
                local line_num = 1
                local x_pos = 0
                local max_width = 195
                local spacing_width = dxGetTextWidth( " ", 1, ibFonts.bold_14 )

                local label_area = ibCreateArea( 200, 22, 0, 0, bg )

                local last_label

                for i, word in ipairs( split( v.title, " " ) ) do
                    local width = dxGetTextWidth( word, 1, ibFonts.bold_14 )
                    local next_x_pos = x_pos + spacing_width + width
                    local was_changed = false

                    if next_x_pos > max_width then
                        x_pos = 0
                        line_num = line_num + 1
                        was_changed = true

                    end

                    if line_num > 2 then
                        if last_label then last_label:ibData( "text", last_label:ibData( "text" ) .. "..." ) end
                        break
                    else
                        last_label = ibCreateLabel( x_pos, ( line_num - 1 ) * 17, 0, 0, word .. " ", label_area, _, _, _, "left", "center", ibFonts.bold_14 )

                        if not was_changed then
                            x_pos = next_x_pos
                        else
                            x_pos = width + spacing_width
                        end
                    end
                end

                -- Общий сдвиг для информации
                local offset = 50
                if line_num <= 1 then
                    label_area:ibData( "py", label_area:ibData( "py" ) + 8 )
                    offset = 44
                end

                -- Всякая хуета
                ibCreateLabel( 200, offset, 0, 0, "Автор видео: #ffffff" .. ( v.uploader or "Игорь Бойко" ), bg, 0xffdcdcdc, _, _, _, _, ibFonts.regular_12 )
                    :ibData( "colored", true )
                ibCreateLabel( 200, offset + 18, 0, 0, "Длительность: #ffffff" .. ( GetReadableDuration( v.duration_seconds ) ), bg, 0xffdcdcdc, _, _, _, _, ibFonts.regular_12 )
                    :ibData( "colored", true )

                local thumbnail = "http://i1.ytimg.com/vi/" .. v.url .. "/mqdefault.jpg"
                local cache_path = "cache/" .. hash( "md5", v.url ) .. ".jpg"
                local file_exists = fileExists( cache_path )

                local image_path = file_exists and cache_path or "img/nothumb.png"
                local image
                    = ibCreateImage( 30, 10, 140, 80, image_path, bg )
                    :ibAttachTooltip( "Нажми чтобы просмотреть" )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "down" then return end
                        local bg = ibCreateImage( 0, 0, sx, sy, _, UI_elements.bg, 0xcc000000 )

                        local width = 650
                        local nsx, nsy = width, math.floor( width / 16 * 9 )
                        local npx, npy = sx / 2 - nsx / 2, sy / 2 - nsy / 2

                        local url = URLAppendParameters( PROXY_URL, { url = v.url } )

                        ibCreateBrowser( npx, npy, nsx, nsy, bg, false, false )
                            :ibOnCreated( function( )
                                source:Navigate( url )
                            end )

                        ibCreateButton(   npx + nsx - 22, npy - 22 - 2, 22, 22, bg,
                                                ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                            :ibOnClick( function( key, state )
                                if key ~= "left" or state ~= "up" then return end
                                ibClick( )
                                if isElement( bg ) then destroyElement( bg ) end
                            end )
                    end )

                if not file_exists then
                    fetchRemote( thumbnail, function( data, err )
                        if err == 0 then
                            if isElement( bg ) then
                                local file = fileCreate( cache_path )
                                fileWrite( file, data )
                                fileClose( file )

                                image:ibData( "texture", cache_path )
                            end
                        end
                    end )
                end

                -- Стоимость
                local lbl = ibCreateLabel( 485, 50, 0, 0, format_price( GetVideoCost( v, conf.is_vip ) ), bg, _, _, _, "left", "center", ibFonts.bold_18 )
                local img = ibCreateImage( lbl:ibGetAfterX( 10 ), lbl:ibGetCenterY( -12 ), 24, 24, ":nrp_shared/img/money_icon.png", bg )

                if conf.is_vip then
                    ibCreateImage( img:ibGetAfterX( 10 ), img:ibGetCenterY( -7 ), 30, 15, "img/icon_vip.png", bg )
                end

                -- Ищем есть ли видео в плейлисте
                local video_in_playlist = false
                for k, n in pairs( PLAYLIST ) do
                    if v.url == n.url then
                        video_in_playlist = true
                        break
                    end
                end

                -- Кнопка добавления видео в плейлист
                if not video_in_playlist then
                    ibCreateButton( nsx - 130 - 30, 34, 130, 32, bg,  
                                    "img/btn_add_big.png", "img/btn_add_big.png", "img/btn_add_big.png",
                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                        :ibAttachTooltip( "Обязательно проверь видео с помощью предпросмотра!" )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "down" then return end
                            ibClick( )

                            if #PLAYLIST < PLAYLIST_MAX_SIZE then
                                table.insert( PLAYLIST, v )

                                -- Если изменилось первое видео в списке, оповещаем сервер об изменении
                                if #PLAYLIST == 1 and IsInQueue( ) then
                                    triggerServerEvent( "onCinemaUpdateQueuedVideo", resourceRoot, v )
                                end

                                -- Сохраняем плейлист
                                SavePlaylist( )

                                -- Возвращаемся к пустому поиску
                                UI_elements.edit_search:ibData( "text", "" )
                            else
                                localPlayer:ShowError( "В плейлисте может быть не больше, чем " .. PLAYLIST_MAX_SIZE .. " видео!" )
                            end
                        end )

                -- Кнопка удаления видео из плейлиста
                else
                    ibCreateButton(   nsx - 130 - 30, 34, 130, 32, bg,  
                                            "img/btn_delete.png", "img/btn_delete.png", "img/btn_delete.png",
                                            0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "down" then return end
                            ibClick( )

                            local is_first_video = i == 1

                            -- Если обновляется первое видео в списке и оно единственное
                            if is_first_video and #PLAYLIST == 1 and IsInQueue( ) then
                                localPlayer:ErrorWindow( "Ты должен покинуть очередь чтобы удалить последнее видео из плейлиста!" )
                                return
                            end

                            -- Удаляем
                            table.remove( PLAYLIST, i )

                            -- Сообщаем видео о новом видео в очереди
                            if is_first_video and IsInQueue( ) then
                                triggerServerEvent( "onCinemaUpdateQueuedVideo", resourceRoot, PLAYLIST[ 1 ] )
                            end

                            -- Сохраняем плейлист
                            SavePlaylist( )

                            -- Обновляем визуальный плейлист если открыто окно
                            UI_elements.edit_search:ibData( "text", "" )
                        end )

                end

                if not IsVideoSuitableForRoom( v, conf.is_vip ) then
                    bg:ibData( "alpha", 100 )
                    ibCreateImage( npx, npy, nsx, nsy, _, UI_elements.rt, 0x77000000 )
                        :ibAttachTooltip( "Данное видео не соответствует разрешенной длительности в этом зале" )
                end

                is_black = not is_black
                npy = npy + nsy
            end
        end

        if #list <= 0 then
            ibCreateLabel( sx / 2, 120, 0, 0, is_playlist and "Твой плейлист пуст" or "Видео по данному запросу не найдены", UI_elements.rt, 0xaaffffff, _, _, "center", "center", ibFonts.bold_20 )
        end

        UI_elements.rt:AdaptHeightToContents( )
        UI_elements.sc
            :ibData( "position", 0 )
            :UpdateScrollbarVisibility( UI_elements.rt )
    end

    if str and utf8.len( str ) > 0 then
        GetYoutubeList( str, page, BuildInterfaceList )
    else
        BuildInterfaceList( PLAYLIST, true )
    end
end

-- Если началось видео, которое у игрока первое в списке, то кладем заново в конец списка
function onCinemaRejoinQueueRequest_handler( url, room_num, is_vip )
    -- Удаление видео из плейлиста после начала
    for i, v in pairs( PLAYLIST ) do
        if v.url == url then
            table.remove( PLAYLIST, i )
            SavePlaylist( )

            -- Обновляем визуальный плейлист если открыто окно
            if isElement( UI_elements.edit_search ) then
                local edit_text = UI_elements.edit_search:ibData( "text" )
                if utf8.len( edit_text ) <= 0 then UI_elements.edit_search:ibData( "text", "" ) end
            end

            outputDebugString( "Видео запущено и удалено из плейлиста (" .. url .. ")" )
            break
        end
    end

    local suitable_video = FindSuitableVideoForPlaylist( is_vip )

    -- Если еще в этой комнате и в очереди, то отправляем следующее видео на показ
    -- Если это не то же самое видео, конечно
    if room_num and suitable_video and IsInQueue( ) == room_num and suitable_video.url ~= url then
        triggerServerEvent( "onCinemaJoinQueueRequest", resourceRoot, room_num, suitable_video )

    else
        conf.in_queue = false
        CreateBottomButtons( )
    end
end
addEvent( "onCinemaRejoinQueueRequest", true )
addEventHandler( "onCinemaRejoinQueueRequest", root, onCinemaRejoinQueueRequest_handler )

function FindSuitableVideoForPlaylist( is_vip )
    local duration = is_vip and VIP_DURATION or NORMAL_DURATION
    for i, v in ipairs( PLAYLIST ) do
        if v.duration_seconds <= duration then
            return v, i
        end
    end
end

function IsVideoSuitableForRoom( video, is_vip )
    local duration = is_vip and VIP_DURATION or NORMAL_DURATION
    return video.duration_seconds <= duration
end