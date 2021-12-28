local UI_elements = { }
local px, py, sx, sy
local conf = { }

function ShowMovielistUI_handler( state, cnf )
    if state then
        ShowMovielistUI_handler( false )

        conf = cnf or { }

        UI_elements.bg_texture = dxCreateTexture( "img/bg.png" )
        local x, y = guiGetScreenSize( )
        sx, sy = dxGetMaterialSize( UI_elements.bg_texture )
        px, py = x / 2 - sx / 2, y / 2 - sy / 2

        UI_elements.black_bg = ibCreateBackground( 0x99000000, ShowMovielistUI_handler, true, true )
        UI_elements.bg = ibCreateImage( px, py + 100, sx, sy, UI_elements.bg_texture, UI_elements.black_bg ):ibData( "alpha", 0 )

        UI_elements.lbl_title = ibCreateLabel( 30, 35, 0, 0, "Сейчас в зале проходит", UI_elements.bg, _, _, _, "left", "center", ibFonts.bold_24 )

        UI_elements.btn_close
            = ibCreateButton(   sx - 24 - 24, 24, 22, 22, UI_elements.bg,
                                ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowMovielistUI_handler( false )
            end )

        ibCreateLabel( 30, 95, 0, 0, "Наименование видео", UI_elements.bg, 0xff8192a1, _, _, _, _, ibFonts.regular_12 )
        ibCreateLabel( sx - 30, 95, 0, 0, "Номер зала", UI_elements.bg, 0xff8192a1, _, _, "right", _, ibFonts.regular_12 )

        UI_elements.rt, UI_elements.sc = ibCreateScrollpane( 0, 120, sx, 480, UI_elements.bg, { scroll_px = -20 } )
        UI_elements.sc
            :ibSetStyle( "slim_nobg" )
            :ibBatchData( { sensivity = 100, absolute = true, color = 0x99ffffff } )
            :UpdateScrollbarVisibility( UI_elements.rt )


        UI_elements.bg:ibAlphaTo( 255, 500 ):ibMoveTo( px, py, 700 )

        showCursor( true )

        UpdateMovielist( conf )
    else
        DestroyTableElements( UI_elements )
        showCursor( false )
        conf = nil
    end
end
addEvent( "ShowMovielistUI", true )
addEventHandler( "ShowMovielistUI", root, ShowMovielistUI_handler )

function UpdateMovielist( conf )
    if not isElement( UI_elements.rt ) then return end
    local list = conf.list

    -- Удаляем старое
    DestroyTableElements( getElementChildren( UI_elements.rt ) )

    -- Добавляем новые
    local npx, npy = 0, 0
    local nsx, nsy = sx, 100
    local is_black = true
    for i, data in pairs( list ) do
        local name = data.name

        -- Всё потому что мне впадлу
        local v = data.video

        local bg = ibCreateImage( npx, npy, nsx, nsy, _, UI_elements.rt, is_black and 0x30000000 or 0 )     
        
        -- Название зала
        ibCreateLabel( sx - 30, nsy / 2, 0, 0, name, bg, _, _, _, "right", "center", ibFonts.bold_16 )

        if not v then
            ibCreateLabel( 30, nsy / 2, 0, 0, "Зал свободен", bg, _, _, _, "left", "center", ibFonts.bold_16 )
        else
            -- Название видео с кастомным переносом
            local line_num = 1
            local x_pos = 0
            local max_width = 300
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
            local image = ibCreateImage( 30, 10, 140, 80, image_path, bg )

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
        end

        is_black = not is_black
        npy = npy + nsy
    end


    UI_elements.rt:AdaptHeightToContents( )

    UI_elements.timer_refresh = setTimer( triggerServerEvent, 5000, 1, "onCinemaUpdateMovielistRequest", resourceRoot, conf.dimension )
end
addEvent( "UpdateMovielist", true )
addEventHandler( "UpdateMovielist", root, UpdateMovielist )