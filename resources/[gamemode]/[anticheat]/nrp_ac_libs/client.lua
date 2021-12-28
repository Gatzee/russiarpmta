loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )

HACK_LIBS = {
	[ "version.dll" ] = "",
}

addEvent( "AC_LIBS_RECIEVE_DATA", true )
addEventHandler( "AC_LIBS_RECIEVE_DATA", root, function( data )
	HACK_LIBS = data or HACK_LIBS

	local ac_data = getClientACData()
	for lib, hash in pairs( ac_data.libs ) do
		if HACK_LIBS[ lib ] and ( HACK_LIBS[ lib ] == "" or hash == HACK_LIBS[ lib ] ) then
			triggerServerEvent( "AC_LIBS_DETECT", resourceRoot, md5( lib ), hash )
			return
		end
	end

	if HACK_LIBS.hash_list then
		for lib, hash in pairs( ac_data.libs ) do
			if HACK_LIBS.hash_list[ hash ] then
				triggerServerEvent( "AC_LIBS_DETECT", resourceRoot, md5( string.lower( lib ) ), hash )
				return
			end
		end
	end

	if ac_data.files then
		ShowGachi( "AC_FILES_DETECT" )
		return
	end

	if ac_data.version then
		ShowGachi( "AC_VERSION_DLL_FILE_DETECT" )
		return
	end
end )

function ShowGachi( event_name )
	ibCreateBrowser( 0, 0, _SCREEN_X, _SCREEN_Y, _, false, true )
		:ibOnCreated( function( )
			source:Navigate( "https://www.youtube.com/watch?v=J7udlTnDzm8" )
		end ):ibData( "priority", 1000 )

	ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y ):ibData( "priority", 1001 )

	localPlayer.dimension = 666

	setTimer( function( )
		localPlayer.frozen = true
		setFPSLimit( 25 )
	end, 500, 0 )

	setTimer( function( )
		triggerServerEvent( event_name, resourceRoot )
	end, 5 * 1000, 1 )
end