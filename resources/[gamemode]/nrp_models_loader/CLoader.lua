local MODELS_LIST = {
	1455,
	408,
	-- Скины
	283,
	40,
	227,
}

triggerServerEvent( "PlayerReadyLoadModels", resourceRoot )

addEvent( "StartLoadModels", true )
addEventHandler( "StartLoadModels", resourceRoot, function( SECRET_KEY )
	for _, model in pairs( MODELS_LIST ) do
		local hFile = fileOpen( "files/".. model .."/model.dff", true )
		if hFile then
			local dff_buffer = fileRead( hFile, fileGetSize( hFile ) )
			fileClose( hFile )

			dff_buffer = decodeString( "tea", dff_buffer, { key = SECRET_KEY } )

			if fileExists( "files/".. model .."/model.col" ) then
				local col = engineLoadCOL( "files/".. model .."/model.col" )
				engineReplaceCOL( col, model )
			end

			local txd = engineLoadTXD ( "files/".. model .."/model.txd" )
			engineImportTXD ( txd, model )
			local dff = engineLoadDFF ( dff_buffer )
			engineReplaceModel ( dff, model )
		end
	end
end )