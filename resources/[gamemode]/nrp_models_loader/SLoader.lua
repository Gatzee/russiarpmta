local SECRET_KEY = "rBLOBZvRAQQQqZjMJVfoRVXPOVaiMp59wX0uua6Sm1"

addEvent( "PlayerReadyLoadModels", true )
addEventHandler( "PlayerReadyLoadModels", resourceRoot, function( )
	if not client then return end

	triggerClientEvent( client, "StartLoadModels", resourceRoot, SECRET_KEY )
end )

-- addCommandHandler ( "encrypt_file", function( )
-- 	local models = { 40, 227 }

-- 	for _, model in pairs( models ) do
-- 		local hFile = fileOpen( "files/".. model .."/model.dff" )
-- 		if hFile then
-- 			local dff_buffer = fileRead( hFile, fileGetSize( hFile ) )

-- 			fileSetPos( hFile, 0 )
-- 			fileWrite( hFile, encodeString( "tea", dff_buffer, { key = SECRET_KEY } ) )
-- 			fileFlush( hFile )

-- 			fileClose( hFile )

-- 			iprint( true )
-- 		end
-- 	end
-- end )