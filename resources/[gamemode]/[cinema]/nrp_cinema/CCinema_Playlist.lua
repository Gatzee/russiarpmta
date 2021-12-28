PLAYLIST = { }
PLAYLIST_PATH = "playlist.nrp"
PLAYLIST_MAX_SIZE = 30

function onClientResourceStart_playlistHandler( )
    local file = fileExists( PLAYLIST_PATH ) and fileOpen( PLAYLIST_PATH )
    if file then
        local contents = fileRead( file, fileGetSize( file ) )
        local contents_tbl = contents and fromJSON( contents )
        if contents_tbl then
            while #contents_tbl > PLAYLIST_MAX_SIZE do
                table.remove( contents_tbl, #contents_tbl )
            end
            PLAYLIST = contents_tbl
            outputDebugString( "Плейлист загружен из файла: " .. #contents_tbl .. " записей" )
        end
        fileClose( file )
    
    else
        outputDebugString( "Плейлист отсутствует, создаем пустой" )

    end
end
addEventHandler( "onClientResourceStart", resourceRoot, onClientResourceStart_playlistHandler, true, "high+100" )

function SavePlaylist( )
    if fileExists( PLAYLIST_PATH ) then fileDelete( PLAYLIST_PATH ) end
    local file = fileCreate( PLAYLIST_PATH )
    if file then
        while #PLAYLIST > PLAYLIST_MAX_SIZE do
            table.remove( PLAYLIST, #PLAYLIST )
        end
        fileWrite( file, toJSON( PLAYLIST, true ) )
        fileClose( file )
        outputDebugString( "Плейлист сохранен в файл: " .. #PLAYLIST .. " записей" )
    end
end