--[[local MODEL = 1333

local col = engineLoadCOL( "models/gate.col" )
engineReplaceCOL( col, MODEL )
local txd = engineLoadTXD( "models/gate.txd" )
engineImportTXD( txd, MODEL )
local dff = engineLoadDFF( "models/gate.dff" )
engineReplaceModel( dff, MODEL )]]