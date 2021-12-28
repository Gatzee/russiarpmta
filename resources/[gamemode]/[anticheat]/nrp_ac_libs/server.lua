loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

function onPlayerReadyToPlay_handler( )
	triggerClientEvent( source, "AC_LIBS_RECIEVE_DATA", resourceRoot, AC_HACK_LIBS )
end
addEvent( "onPlayerReadyToPlay", true )
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )

function AC_LIBS_DETECT_handler( lib, hash )
	if AC_HACK_LIBS_KICK and AC_HACK_LIBS_KICK[ hash ] then
		WriteLog( "lib_ac", "[Античит] %s был кикнут за использование сторонней библиотеки / %s / %s", client, lib, hash )
		triggerEvent( "DetectPlayerAC", client, "22" )
	else
		WriteLog( "lib_ac", "[Античит] %s использует сторонние библиотеки / %s / %s", client, lib, hash )
	end
end
addEvent( "AC_LIBS_DETECT", true )
addEventHandler( "AC_LIBS_DETECT", resourceRoot, AC_LIBS_DETECT_handler )

function AC_FILES_DETECT_handler( )
	triggerEvent( "DetectPlayerAC", client, "23" )
end
addEvent( "AC_FILES_DETECT", true )
addEventHandler( "AC_FILES_DETECT", resourceRoot, AC_FILES_DETECT_handler )

function AC_VERSION_DLL_FILE_DETECT_handler( )
	triggerEvent( "DetectPlayerAC", client, "24" )
end
addEvent( "AC_VERSION_DLL_FILE_DETECT", true )
addEventHandler( "AC_VERSION_DLL_FILE_DETECT", resourceRoot, AC_VERSION_DLL_FILE_DETECT_handler )