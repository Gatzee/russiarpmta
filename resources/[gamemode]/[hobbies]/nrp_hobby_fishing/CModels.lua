local col_path = "files/models/F_rod.col"
local txd_path = "files/models/f_rod.txd"

local models_list = 
{
	[677] = "F_rod1.dff",
	[678] = "F_rod2.dff",
	[679] = "F_rod3.dff",
	[682] = "F_rod4.dff",
	[692] = "F_rod5.dff",
	[754] = "F_rod6.dff",
	[755] = "F_rodP.dff",
}

for k,v in pairs(models_list) do
	local txd = engineLoadTXD( txd_path )
	local dff = engineLoadDFF( "files/models/"..v, k )
	local col = engineLoadCOL( col_path, k )
	engineImportTXD( txd, k )
	engineReplaceModel( dff, k )
	engineReplaceCOL( col, k )
end