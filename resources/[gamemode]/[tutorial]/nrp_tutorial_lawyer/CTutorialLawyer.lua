function onClientPlayerRequestLawyerStart_handler( )
    if not _MODULES_LOADED then
        loadstring( exports.interfacer:extend( "Interfacer" ) )( )
        Extend( "ib" )
        Extend( "CAI" )
        Extend( "CActionTasksUtils" )
        Extend( "CUI" )
        _MODULES_LOADED = true
    end

    CEs = { }

    StartQuestCutscene( )
    setCameraMatrix( 1930.1790771484, 128.37916564941, 632.01763916016, 2029.7305908203, 127.3131942749, 622.61798095703, 0, 70 )

    CEs.bot = CreateAIPed( 199, Vector3( 1939.080078125, 128.51693725586, 631.42828369141 ) )
    CEs.bot.interior = localPlayer.interior
    CEs.bot.dimension = localPlayer.dimension

    SetAIPedMoveByRoute( CEs.bot, {
        { x = 1933.943, y = 128.373, z = 631.428, move_type = 4 },
    }, false, function( )
        CEs.dialog = CreateDialog( {
            { name = "Адвокат", voice_line = "Lawyer_1", text = "Здравствуйте, я смогу договориться по поводу вашего освобождения,\nа пока ожидайте и посмотрите обучающий ролик!" }
        } )
        CEs.dialog:reposition_to_stripes( CEs.stripes )
        CEs.dialog:next( )
        CEs.timer = setTimer( function( )
            CEs.dialog:destroy_with_animation( )

            CEs.bg = ibCreateBackground( 0, _, true ):ibData( "alpha", 0 )

            local video_id = "JXP3BKszQsc"
            local video_duration = 65 * 1000 + 3 * 1000

            local url = URLAppendParameters( "http://ytscraper.gamecluster.nextrp.ru/proxy", {
                url = video_id,
                start = 0,
            } )

            CEs.browser = ibCreateBrowser( 0, 0, CEs.bg:width( ), CEs.bg:height( ), CEs.bg, false, true )
                :ibOnCreated( function( )
                    source:Navigate( url )
                    CEs.bg:ibAlphaTo( 255, 2000 )

                    CEs.timer = setTimer( function( )
                        CEs.browser:destroy( )

                        showCursor( true )
                        CEs.dialog = CreateDialog( {
                            { text = "Используя правила игрового мира вы сможете больше погрузится в него.\nПолный список всех правил находится в меню по клавише F10" },
                            {
                                custom = function( parent )
                                    local area = ibCreateArea( 0, 0, 0, 70, parent ):center_x( )
                                    ibCreateImage( 0, 0, 0, 0, ":nrp_shared/img/btn_fines_ok.png", area ):ibSetRealSize( ):center( )
                                        :ibOnClick( function( key, state )
                                            if key ~= "left" or state ~= "up" then return end
                                            ibClick( )
                                            
                                            CEs.dialog:destroy_with_animation( )
                                            onClientPlayerRequestLawyerStop_handler( )

                                            triggerServerEvent( "onPlayerRequestLawyerStop", resourceRoot )
                                        end )
                                    return area
                                end
                            },
                        } )

                        CEs.dialog:reposition_to_stripes( CEs.stripes )
                        CEs.dialog:next( )

                        CEs.dialog_timer = setTimer( function( )
                            CEs.dialog:next( )
                        end, 10000, 1 )
                    end, video_duration, 1 )
                end )
        end, 7000, 1 )
    end )
end
addEvent( "onClientPlayerRequestLawyerStart", true )
addEventHandler( "onClientPlayerRequestLawyerStart", root, onClientPlayerRequestLawyerStart_handler )

function onClientPlayerRequestLawyerStop_handler( )
    if CEs then
        showCursor( false )
        FinishQuestCutscene( )
        DestroyTableElements( CEs )
        CEs = nil
    end
end
addEvent( "onClientPlayerRequestLawyerStop", true )
addEventHandler( "onClientPlayerRequestLawyerStop", root, onClientPlayerRequestLawyerStop_handler )

function URLAppendParameters( url, parameters )
    local get_str = ""

    local n = 1
    for i, v in pairs( parameters ) do
        local i, v = tostring( i ), tostring( v )
        if n ~= 1 then
            get_str = get_str .. "&"
        else
            get_str = get_str .. "?"
        end
        get_str = get_str .. urlencode( i ) .. "=" .. urlencode( v )
        n = n + 1
    end

    return url .. get_str
end

local char_to_hex = function( c )
    return string.format( "%%%02X", utf8.byte( c ) )
end
function urlencode( url )
    if url == nil then return end
    url = url:gsub( "\n", "\r\n" )
    url = url:gsub( "([^%w ])", char_to_hex )
    url = url:gsub( " ", "+" )
    return url
end