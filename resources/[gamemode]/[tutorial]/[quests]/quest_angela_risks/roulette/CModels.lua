function ToggleRouletteModelsReplace(state)
	if state then
		local txd = engineLoadTXD ( ":nrp_casino_game_roulette/models/revolver.txd" )
		engineImportTXD( txd, 1339 )
		local dff = engineLoadDFF ( ":nrp_casino_game_roulette/models/revolver.dff" )
		engineReplaceModel( dff, 1339 )
	else
		engineRestoreModel( 1339 )
	end
end