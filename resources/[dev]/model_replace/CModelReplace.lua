PATH = "models.conf"
REPLACED_MODELS = { }

function onClientResourceStart_handler( )
    -- Дефолтный пример если нет файла
    if not fileExists( PATH ) then
        local file = fileCreate( PATH )
        fileWrite( file, [[model=123;dff=dir/1.dff;txd=dir/1.txd;col=dir/1.col
model=234;dff=dir/2.dff;txd=dir/2.txd;col=dir/2.col]] )
        fileClose( file )
        return
    end

    local file = fileOpen( PATH )
    local contents = fileRead( file, fileGetSize( file ) )
    local lines = split( contents, "\n" )

    local success, line_count = 0, 0
    for line_num, line in pairs( lines ) do
        line = line:gsub( "#(.*)$", "" ):gsub( "\r", "" )

        local no_spaces = line:gsub( " ", "" )
        if utf8.len( no_spaces ) > 0 then
            iprint( "Replaced to", line )
            local result = ParseLine( line, line_num )
            success = result and success + 1 or success
            line_count = line_count + 1
        end
    end

    fileClose( file )

    outputChatBox( "Модели заменены: " .. success .. "/" .. line_count, 255, 255, 0 )
end
addEventHandler( "onClientResourceStart", resourceRoot, onClientResourceStart_handler )

function ReloadAll( )
    for i, v in pairs( REPLACED_MODELS ) do
        CleanModel( i )
    end

    onClientResourceStart_handler( )
end
addCommandHandler( "reload", ReloadAll )

function CleanModel( model )
    engineRestoreCOL( model )
    engineRestoreModel( model )
    if REPLACED_MODELS[ model ] then
        for i, v in pairs( REPLACED_MODELS[ model ] ) do
            if isElement( v ) then destroyElement( v ) end
        end
        REPLACED_MODELS[ model ] = nil
    end
end

function ParseLine( line, line_num )
    local sections = split( line, ";" )
    local paths = { }

    for n, section_info in pairs( sections ) do
        local section_type, section_path = unpack( split( section_info, "=" ) )
        paths[ section_type ] = section_path
    end

    if not paths.model then
        outputChatBox( "Не указана ID модели, строка " .. line_num, 255, 0, 0 )
        return
    end

    REPLACED_MODELS[ paths.model ] = { }

    -- Подгрузка COL
    if paths.col then
        local col = engineLoadCOL( paths.col )
        local result = engineReplaceCOL( col, paths.model )

        if not col or not result then
            outputChatBox( "Ошибка замены COL файла, строка " .. line_num, 255, 0, 0 )
            CleanModel( paths.model )
            return
        end
        REPLACED_MODELS[ paths.model ].col = col
    end

    -- Подгрузка TXD
    if paths.txd then
        local txd = engineLoadTXD( paths.txd )
        local result = engineImportTXD( txd, paths.model )

        if not txd or not result then
            outputChatBox( "Ошибка замены TXD файла, строка " .. line_num, 255, 0, 0 )
            CleanModel( paths.model )
            return
        end
        REPLACED_MODELS[ paths.model ].txd = txd
    end

    -- Подгрузка DFF
    if paths.dff then
        local dff = engineLoadDFF( paths.dff )
        local result = engineReplaceModel( dff, paths.model )

        if not dff or not result then
            outputChatBox( "Ошибка замены DFF файла, строка " .. line_num, 255, 0, 0 )
            CleanModel( paths.model )
            return
        end
        REPLACED_MODELS[ paths.model ].dff = dff
    end

    outputChatBox( "Успешная замена модели " .. paths.model .. ", строка " .. line_num, 0, 255, 0 )
    return true
end