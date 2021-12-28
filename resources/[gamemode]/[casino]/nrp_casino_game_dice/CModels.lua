function ToggleModelsReplace(state)
	if state then
		local txd = engineLoadTXD ( "models/cube.txd" )
		engineImportTXD( txd, 1339 )
		local dff = engineLoadDFF ( "models/cube.dff" )
		engineReplaceModel( dff, 1339 )
	else
		engineRestoreModel( 1339 )
	end
end