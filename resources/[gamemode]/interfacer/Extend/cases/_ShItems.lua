Import( "Globals" )

local server_number = localPlayer and ( localPlayer:getData( "_srv" ) and localPlayer:getData( "_srv" )[1]  or 1 ) or SERVER_NUMBER

CONST_GET_CASES_URL = server_number > 100 and "https://pyapi.devhost.nextrp.ru/v1.0/get_cases/" or "https://pyapi.gamecluster.nextrp.ru/v1.0/get_cases/"

REGISTERED_CASE_ITEMS = { }

Import( "cases/ShWofCoin.lua" )
Import( "cases/Sh_AssemblDetail.lua" )
Import( "cases/ShAccessory.lua" )
Import( "cases/ShBox.lua" )
Import( "cases/ShCarEvac.lua" )
Import( "cases/ShDance.lua" )
Import( "cases/ShExp.lua" )
Import( "cases/ShFirstaid.lua" )
Import( "cases/ShFuelcan.lua" )
Import( "cases/ShGunLicense.lua" )
Import( "cases/ShHard.lua" )
Import( "cases/ShJailkeys.lua" )
Import( "cases/ShLunchbox.lua" )
Import( "cases/ShPhoneImg.lua" )
Import( "cases/ShPremium.lua" )
Import( "cases/ShRepairbox.lua" )
Import( "cases/ShSkin.lua" )
Import( "cases/ShSoft.lua" )
Import( "cases/ShTaxi.lua" )
Import( "cases/ShTuningCase.lua" )
Import( "cases/ShVehicle.lua" )
Import( "cases/ShVehicleLicense.lua" )
Import( "cases/ShVehicleSlot.lua" )
Import( "cases/ShVinyl.lua" )
Import( "cases/ShWeapon.lua" ) 