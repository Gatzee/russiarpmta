function ToggleModelsReplace(state)
	if state then
		local txd = engineLoadTXD ( "models/revolver.txd" )
		engineImportTXD( txd, 1339 )
		local dff = engineLoadDFF ( "models/revolver.dff" )
		engineReplaceModel( dff, 1339 )
	else
		engineRestoreModel( 1339 )
	end
end