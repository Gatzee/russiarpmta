local txd_path = "files/models/shovels.txd"

local models_list = 
{
	[1219] = "shovel_1.dff",
	[1220] = "shovel_2.dff",
	[1221] = "shovel_3.dff",
}

for k,v in pairs(models_list) do
	local txd = engineLoadTXD( txd_path )
	local dff = engineLoadDFF( "files/models/"..v, k )
	engineImportTXD( txd, k )
	engineReplaceModel( dff, k )
end

engineLoadIFP( "files/animations.ifp", "DIGGING" )