--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_main.lua
*
*	Original File by lil_Toady
*
**************************************]]

aAdminForm = nil
aLastCheck = 0
aCurrentVehicle = 429
aCurrentWeapon = 30
aCurrentAmmo = 90
aCurrentSlap = 20
aPlayers = {}
aBans = {}
aLastSync = 0
aResources = {}

local serverPassword = 'None'

function guiComboBoxAdjustHeight ( combobox, itemcount )
    if getElementType ( combobox ) ~= "gui-combobox" or type ( itemcount ) ~= "number" then error ( "Invalid arguments @ 'guiComboBoxAdjustHeight'", 2 ) end
    local width = guiGetSize ( combobox, false )
    return guiSetSize ( combobox, width, ( itemcount * 20 ) + 20, false )
end

function aAdminMenu ()
	if ( aAdminForm == nil ) then
		local x, y = guiGetScreenSize()
		aAdminForm	= guiCreateWindow(223, 84, 960, 600, "Devolper-Panel NEXTRP", false)
		guiWindowSetSizable ( aAdminForm, false )

		aTabPanel			= guiCreateTabPanel (9, 25, 941, 565, false, aAdminForm )
		aTab1 = {}
		aTab1.Tab			= guiCreateTab ( "Players", aTabPanel, "players" )
		aTab1.PlayerListSearch 	= guiCreateEdit (20, 20, 205, 25, "", false, aTab1.Tab )
		aTab1.HideColorCodes= guiCreateCheckBox ( 0.037, 0.94, 0.20, 0.04, "Hide color codes", false, true, aTab1.Tab )
		aTab1.HideSensitiveData= guiCreateCheckBox ( 0.25, 0.94, 0.23, 0.04, "Hide sensitive data", false, true, aTab1.Tab )

		aTab1.PlayerList		= guiCreateGridList ( 20, 60, 205, 445, false, aTab1.Tab )
						  guiGridListAddColumn( aTab1.PlayerList, "Имя", 0.85 )
						  guiGridListSetSortingEnabled ( aTab1.PlayerList, false )
						  for id, player in ipairs ( getElementsByType ( "player" ) ) do guiGridListSetItemPlayerName ( aTab1.PlayerList, guiGridListAddRow ( aTab1.PlayerList ), 1, getPlayerName ( player ), false, false ) end
		aTab1.Kick			= guiCreateButton ( 0.71, 0.125, 0.13, 0.04, "Kick", true, aTab1.Tab, "kick" )
		aTab1.Ban			= guiCreateButton ( 0.85, 0.125, 0.13, 0.04, "Ban", true, aTab1.Tab, "ban" )
		aTab1.Mute			= guiCreateButton ( 0.71, 0.170, 0.13, 0.04, "Mute", true, aTab1.Tab, "mute" )
		aTab1.Freeze		= guiCreateButton ( 0.85, 0.170, 0.13, 0.04, "Freeze", true, aTab1.Tab, "freeze" )
		aTab1.Spectate		= guiCreateButton ( 0.71, 0.215, 0.13, 0.04, "Spectate", true, aTab1.Tab, "spectate" )
		aTab1.Slap		= guiCreateList ( 0.85, 0.215, 0.13, 0.04, 0.40, "Slap! "..aCurrentSlap..'  _', true, aTab1.Tab, "slap" )

		local slaps = {}
		for i = 0, 10 do
			table.insert(slaps, {text = tostring(i * 10), data = i * 10})
		end

		guiListSetColumns(aTab1.Slap, {{text = '', width = 0.8}})
		guiListSetItems(aTab1.Slap, slaps)
		guiListSetCallBack(aTab1.Slap, function(selectedData, selectedText)
			local slap = tonumber(selectedData)
			if slap then
				aCurrentSlap = slap
				guiSetText(aTab1.Slap, "Slap! "..slap..'  _')
				if (aSpectator.Slap) then 
					guiSetText(aSpectator.Slap, "Slap! "..slap.."hp")
				end
			end
		end)

		aTab1.Nick			= guiCreateButton ( 0.71, 0.260, 0.13, 0.04, "Set Nick", true, aTab1.Tab )
		aTab1.Shout			= guiCreateButton ( 0.85, 0.260, 0.13, 0.04, "Shout!", true, aTab1.Tab, "shout" )
		aTab1.Admin			= guiCreateButton ( 0.71, 0.305, 0.27, 0.04, "Give admin rights", true, aTab1.Tab, "setgroup" )

		local y = 0.03		-- Start y coord
		local A = 0.045		-- Large line gap
		local B = 0.035		-- Small line gap

						     guiCreateHeader ( 0.25, y, 0.20, 0.04, "Player:", true, aTab1.Tab )
y=y+A   aTab1.Name			= guiCreateLabel ( 0.26, y, 0.435, 0.035, "Name: N/A", true, aTab1.Tab )
y=y+A   aTab1.IP			= guiCreateLabel ( 0.26, y, 0.30, 0.035, "IP: N/A", true, aTab1.Tab )
		aTab1.CountryCode	= guiCreateLabel ( 0.45, y, 0.04, 0.035, "", true, aTab1.Tab )
		aTab1.Flag	  = guiCreateStaticImage ( 0.40, y, 0.025806, 0.021154, "client\\images\\empty.png", true, aTab1.Tab )
y=y+A   aTab1.Serial		= guiCreateLabel ( 0.26, y, 0.435, 0.035, "Serial: N/A", true, aTab1.Tab )
y=y+B   aTab1.Version		= guiCreateLabel ( 0.26, y, 0.435, 0.035, "Version: N/A", true, aTab1.Tab )
y=y+B   aTab1.Accountname	= guiCreateLabel ( 0.26, y, 0.435, 0.035, "Account Name: N/A", true, aTab1.Tab )
y=y+B   aTab1.Groups		= guiCreateLabel ( 0.26, y, 0.435, 0.035, "Groups: N/A", true, aTab1.Tab )


		B = 0.040
y=y+A  				         guiCreateHeader ( 0.25, y, 0.20, 0.04, "Game:", true, aTab1.Tab )
y=y+A   aTab1.Health		= guiCreateLabel ( 0.26, y, 0.20, 0.04, "Health: 0%", true, aTab1.Tab )
		aTab1.Armour		= guiCreateLabel ( 0.45, y, 0.20, 0.04, "Armour: 0%", true, aTab1.Tab )
y=y+B   aTab1.Skin			= guiCreateLabel ( 0.26, y, 0.20, 0.04, "Skin: N/A", true, aTab1.Tab )
		aTab1.Team			= guiCreateLabel ( 0.45, y, 0.20, 0.04, "Team: None", true, aTab1.Tab )
y=y+B   aTab1.Weapon		= guiCreateLabel ( 0.26, y, 0.35, 0.04, "Weapon: N/A", true, aTab1.Tab )
y=y+B   aTab1.Ping			= guiCreateLabel ( 0.26, y, 0.20, 0.04, "Ping: 0", true, aTab1.Tab )
		aTab1.Money			= guiCreateLabel ( 0.45, y, 0.20, 0.04, "Money: 0", true, aTab1.Tab )
y=y+B   aTab1.Area			= guiCreateLabel ( 0.26, y, 0.44, 0.04, "Area: Unknown", true, aTab1.Tab )
y=y+B   aTab1.Position		= guiCreateLabel ( 0.26, y, 0.44, 0.04, "Position: 0, 0, 0", true, aTab1.Tab )
y=y+B   aTab1.Dimension		= guiCreateLabel ( 0.26, y, 0.20, 0.04, "Dimension: 0", true, aTab1.Tab )
		aTab1.Interior		= guiCreateLabel ( 0.45, y, 0.20, 0.04, "Interior: 0", true, aTab1.Tab )

y=y+A  				         guiCreateHeader ( 0.25, y, 0.20, 0.04, "Vehicle:", true, aTab1.Tab )
y=y+A  aTab1.Vehicle		= guiCreateLabel ( 0.26, y, 0.35, 0.04, "Vehicle: N/A", true, aTab1.Tab )
y=y+B  aTab1.VehicleHealth	= guiCreateLabel ( 0.26, y, 0.25, 0.04, "Vehicle Health: 0%", true, aTab1.Tab )

		aTab1.SetHealth		= guiCreateButton ( 0.71, 0.395, 0.13, 0.04, "Set Health", true, aTab1.Tab, "sethealth" )
		aTab1.SetArmour		= guiCreateButton ( 0.85, 0.395, 0.13, 0.04, "Set Armour", true, aTab1.Tab, "setarmour" )
		aTab1.SetSkin		= guiCreateButton ( 0.71, 0.440, 0.13, 0.04, "Set Skin", true, aTab1.Tab, "setskin" )
		aTab1.SetTeam		= guiCreateButton ( 0.85, 0.440, 0.13, 0.04, "Set Team", true, aTab1.Tab, "setteam" )
		aTab1.SetDimension	= guiCreateButton ( 0.71, 0.755, 0.13, 0.04, "Set Dimens.", true, aTab1.Tab, "setdimension" )
		aTab1.SetInterior		= guiCreateButton ( 0.85, 0.755, 0.13, 0.04, "Set Interior", true, aTab1.Tab, "setinterior" )
		aTab1.GiveWeapon		= guiCreateList ( 0.71, 0.485, 0.27, 0.04, 0.48, "Give: "..getWeaponNameFromID ( aCurrentWeapon ), true, aTab1.Tab, "giveweapon" )

		local weapons = {}
		for i = 1, 46 do
			local weapName = getWeaponNameFromID(i)
			if weapName then
				table.insert(weapons, {text = weapName, data = i})
			end
		end

		local shortNames = {
			["Combat Shotgun"] = "Combat SG", 
			["Rocket Launcher"] = "R. Launcher", 
			["Rocket Launcher HS"] = "R. Launcher HS"
		}
		guiListSetColumns(aTab1.GiveWeapon, {{text = '', width = 0.8}})
		guiListSetItems(aTab1.GiveWeapon, weapons)
		guiListSetCallBack(aTab1.GiveWeapon, function(selectedData, selectedText)
			local weaponID = tonumber(selectedData)
			if weaponID then
				aCurrentWeapon = weaponID
				guiSetText(aTab1.GiveWeapon, "Give: " .. (shortNames[selectedText] or selectedText))
			end
		end)


		aTab1.SetMoney		= guiCreateButton ( 0.71, 0.530, 0.13, 0.04, "Set Money", true, aTab1.Tab, "setmoney" )
		aTab1.SetStats		= guiCreateButton ( 0.85, 0.530, 0.13, 0.04, "Set Stats", true, aTab1.Tab, "setstat" )
		aTab1.JetPack		= guiCreateButton ( 0.71, 0.575, 0.27, 0.04, "Give JetPack", true, aTab1.Tab, "jetpack" )
		aTab1.Warp			= guiCreateButton ( 0.71, 0.620, 0.27, 0.04, "Warp to player", true, aTab1.Tab, "warp" )
		aTab1.WarpTo		= guiCreateButton ( 0.71, 0.665, 0.27, 0.04, "Warp player to..", true, aTab1.Tab, "warp" )
		aTab1.VehicleFix		= guiCreateButton ( 0.71, 0.84, 0.13, 0.04, "Fix", true, aTab1.Tab, "repair" )
		aTab1.VehicleDestroy	= guiCreateButton ( 0.71, 0.89, 0.13, 0.04, "Destroy", true, aTab1.Tab, "destroyvehicle" )
		aTab1.VehicleBlow		= guiCreateButton ( 0.85, 0.84, 0.13, 0.04, "Blow", true, aTab1.Tab, "blowvehicle" )
		aTab1.VehicleCustomize 	= guiCreateButton ( 0.85, 0.89, 0.13, 0.04, "Customize", true, aTab1.Tab, "customize" )
		aTab1.GiveVehicle = guiCreateList( 0.71, 0.710, 0.27, 0.04, 0.275, "Give: "..getVehicleNameFromModel ( aCurrentVehicle ), true, aTab1.Tab, 'givevehicle')
		
		local vehicles = {}
		for i = 400, 611 do
			local vehName = getVehicleNameFromModel(i)
			if vehName then
				table.insert(vehicles, {text = vehName, data = i})
			end
		end

		table.sort(vehicles, function(a, b) return a.text < b.text end)

		guiListSetColumns(aTab1.GiveVehicle, {{text = '', width = 0.8}})
		guiListSetItems(aTab1.GiveVehicle, vehicles)
		guiListSetCallBack(aTab1.GiveVehicle, function(selectedData, selectedText)
			local modelID = tonumber(selectedData)
			if modelID then
				aCurrentVehicle = modelID
				guiSetText ( aTab1.GiveVehicle, "Give: "..selectedText )
			end
		end)

		aTab2 = {}
		aTab2.Tab			= guiCreateTab ( "Resources", aTabPanel, "resources" )
		aTab2.ManageACL		= guiCreateButton ( 0.75, 0.02, 0.23, 0.04, "Manage ACL", true, aTab2.Tab )
		aTab2.ResourceListSearch = guiCreateEdit ( 0.03, 0.05, 0.31, 0.04, "", true, aTab2.Tab )
						  guiCreateStaticImage ( 0.34, 0.05, 0.035, 0.04, "client\\images\\search.png", true, aTab2.Tab )
		aTab2.ResourceList	= guiCreateGridList ( 0.03, 0.10, 0.35, 0.80, true, aTab2.Tab )
						  guiGridListAddColumn( aTab2.ResourceList, "Resource", 0.55 )
						  guiGridListAddColumn( aTab2.ResourceList, "", 0.05 )
						  guiGridListAddColumn( aTab2.ResourceList, "State", 0.35 )
						  guiGridListAddColumn( aTab2.ResourceList, "Full Name", 0.6 )
						  guiGridListAddColumn( aTab2.ResourceList, "Author", 0.4 )
						  guiGridListAddColumn( aTab2.ResourceList, "Version", 0.2 )
		aTab2.ResourceInclMaps	= guiCreateCheckBox ( 0.03, 0.91, 0.15, 0.04, "Include Maps", false, true, aTab2.Tab )
		aTab2.ResourceRefresh	= guiCreateButton ( 0.20, 0.915, 0.18, 0.04, "Refresh list", true, aTab2.Tab, "listresources" )
		aTab2.ResourceStart	= guiCreateButton ( 0.40, 0.10, 0.20, 0.04, "Start", true, aTab2.Tab, "start" )
		aTab2.ResourceRestart	= guiCreateButton ( 0.40, 0.15, 0.20, 0.04, "Restart", true, aTab2.Tab, "restart" )
		aTab2.ResourceStop	= guiCreateButton ( 0.40, 0.20, 0.20, 0.04, "Stop", true, aTab2.Tab, "stop" )
		aTab2.ResourcesStopAll	= guiCreateButton ( 0.40, 0.25, 0.20, 0.04, "Stop All Resources", true, aTab2.Tab, "stopall" )
		--aModules			= guiCreateTabPanel ( 0.40, 0.25, 0.57, 0.38, true, aTab2.Tab ) --What's that for?
							guiCreateHeader(0.40, 0.3, 0.3, 0.04, "Resource Informations:", true, aTab2.Tab)
		aTab2.ResourceName			= guiCreateLabel ( 0.41, 0.35, 0.6, 0.03, "Full Name: ", true, aTab2.Tab )
		aTab2.ResourceAuthor		= guiCreateLabel ( 0.41, 0.4, 0.6, 0.03, "Author: ", true, aTab2.Tab )
		aTab2.ResourceVersion		= guiCreateLabel ( 0.41, 0.45, 0.6, 0.03, "Version: ", true, aTab2.Tab )

		aTab3 = {}
		aTab3.Tab			= guiCreateTab ( "Server", aTabPanel, "server" )
		aTab3.Server		= guiCreateLabel ( 0.05, 0.05, 0.70, 0.05, "Server: Unknown", true, aTab3.Tab )
		aTab3.Password		= guiCreateLabel ( 0.05, 0.10, 0.40, 0.05, "Password: None", true, aTab3.Tab )
		aTab3.GameType		= guiCreateLabel ( 0.05, 0.15, 0.40, 0.05, "Game Type: None", true, aTab3.Tab )
		aTab3.MapName		= guiCreateLabel ( 0.05, 0.20, 0.40, 0.05, "Map Name: None", true, aTab3.Tab )
		aTab3.Players		= guiCreateLabel ( 0.05, 0.25, 0.20, 0.05, "Players: 0/0", true, aTab3.Tab )
		aTab3.SetPassword		= guiCreateButton ( 0.80, 0.05, 0.18, 0.04, "Set Password", true, aTab3.Tab, "setpassword" )
		aTab3.ResetPassword	= guiCreateButton ( 0.80, 0.10, 0.18, 0.04, "Reset Password", true, aTab3.Tab, "setpassword" )
		aTab3.SetGameType		= guiCreateButton ( 0.80, 0.15, 0.18, 0.04, "Set Game Type", true, aTab3.Tab, "setgame" )
		aTab3.SetMapName		= guiCreateButton ( 0.80, 0.20, 0.18, 0.04, "Set Map Name", true, aTab3.Tab, "setmap" )
		aTab3.SetWelcome		= guiCreateButton ( 0.80, 0.25, 0.18, 0.04, "Welcome Message", true, aTab3.Tab, "setwelcome" )
		aTab3.Shutdown		= guiCreateButton ( 0.80, 0.3, 0.18, 0.04, "Shutdown", true, aTab3.Tab, "shutdown" )
						  guiCreateStaticImage ( 0.05, 0.32, 0.50, 0.0025, "client\\images\\dot.png", true, aTab3.Tab )
		aTab3.WeatherCurrent	= guiCreateLabel ( 0.05, 0.35, 0.45, 0.05, "Current Weather: "..getWeather().." ("..getWeatherNameFromID ( getWeather() )..")", true, aTab3.Tab )
		aTab3.WeatherDec		= guiCreateButton ( 0.05, 0.40, 0.035, 0.04, "<", true, aTab3.Tab )
		aTab3.Weather		= guiCreateEdit ( 0.095, 0.40, 0.35, 0.04, getWeather().." ("..getWeatherNameFromID ( getWeather() )..")", true, aTab3.Tab )
		aTab3.WeatherInc		= guiCreateButton ( 0.45, 0.40, 0.035, 0.04, ">", true, aTab3.Tab )
						  guiEditSetReadOnly ( aTab3.Weather, true )
		aTab3.WeatherSet		= guiCreateButton ( 0.50, 0.40, 0.10, 0.04, "Set", true, aTab3.Tab, "setweather" )
		aTab3.WeatherBlend	= guiCreateButton ( 0.61, 0.40, 0.15, 0.04, "Set Blended", true, aTab3.Tab, "blendweather" )

						  local th, tm = getTime()
		aTab3.TimeCurrent		= guiCreateLabel ( 0.05, 0.45, 0.25, 0.04, "Time: "..th..":"..tm, true, aTab3.Tab )
		aTab3.TimeH			= guiCreateEdit ( 0.35, 0.45, 0.055, 0.04, "12", true, aTab3.Tab )
		aTab3.TimeM			= guiCreateEdit ( 0.425, 0.45, 0.055, 0.04, "00", true, aTab3.Tab )
						  guiCreateLabel ( 0.415, 0.45, 0.05, 0.04, ":", true, aTab3.Tab )
						  guiEditSetMaxLength ( aTab3.TimeH, 2 )
						  guiEditSetMaxLength ( aTab3.TimeM, 2 )
		aTab3.TimeSet		= guiCreateButton ( 0.50, 0.45, 0.10, 0.04, "Set", true, aTab3.Tab, "settime" )
						  guiCreateLabel ( 0.63, 0.45, 0.12, 0.04, "( 0-23:0-59 )", true, aTab3.Tab )

		aTab3.GravityCurrent	= guiCreateLabel ( 0.05, 0.50, 0.28, 0.04, "Gravitation: "..string.sub ( getGravity(), 0, 6 ), true, aTab3.Tab )
		aTab3.Gravity		= guiCreateEdit ( 0.35, 0.50, 0.135, 0.04, "0.008", true, aTab3.Tab )
		aTab3.GravitySet		= guiCreateButton ( 0.50, 0.50, 0.10, 0.04, "Set", true, aTab3.Tab, "setgravity" )

		aTab3.SpeedCurrent	= guiCreateLabel ( 0.05, 0.55, 0.30, 0.04, "Game Speed: "..getGameSpeed(), true, aTab3.Tab )
		aTab3.Speed			= guiCreateEdit ( 0.35, 0.55, 0.135, 0.04, "1", true, aTab3.Tab )
		aTab3.SpeedSet		= guiCreateButton ( 0.50, 0.55, 0.10, 0.04, "Set", true, aTab3.Tab, "setgamespeed" )
						  guiCreateLabel ( 0.63, 0.55, 0.09, 0.04, "( 0-10 )", true, aTab3.Tab )

		aTab3.WavesCurrent	= guiCreateLabel ( 0.05, 0.60, 0.25, 0.04, "Wave Height: "..getWaveHeight(), true, aTab3.Tab )
		aTab3.Waves			= guiCreateEdit ( 0.35, 0.60, 0.135, 0.04, "0", true, aTab3.Tab )
		aTab3.WavesSet		= guiCreateButton ( 0.50, 0.60, 0.10, 0.04, "Set", true, aTab3.Tab, "setwaveheight" )
					 	 guiCreateLabel ( 0.63, 0.60, 0.09, 0.04, "( 0-100 )", true, aTab3.Tab )

		aTab3.FPSCurrent	= guiCreateLabel ( 0.05, 0.65, 0.25, 0.04, "FPS Limit: 38", true, aTab3.Tab )
		aTab3.FPS			= guiCreateEdit ( 0.35, 0.65, 0.135, 0.04, "38", true, aTab3.Tab )
		aTab3.FPSSet		= guiCreateButton ( 0.50, 0.65, 0.10, 0.04, "Set", true, aTab3.Tab, "setfpslimit" )
					 	 guiCreateLabel ( 0.63, 0.65, 0.1, 0.04, "( 25-100 )", true, aTab3.Tab )

		addEventHandler ( "aClientAdminChat", _root, aClientAdminChat )
		addEventHandler ( "aClientSync", _root, aClientSync )
		addEventHandler ( "aClientResourceStart", _root, aClientResourceStart )
		addEventHandler ( "aClientResourceStop", _root, aClientResourceStop )
		addEventHandler ( "aClientPlayerJoin", _root, aClientPlayerJoin )
		addEventHandler ( "onClientPlayerQuit", _root, aClientPlayerQuit )
		addEventHandler ( "onClientGUIClick", aAdminForm, aClientClick )
		addEventHandler ( "onClientGUIScroll", aAdminForm, aClientScroll )
		addEventHandler ( "onClientGUIDoubleClick", aAdminForm, aClientDoubleClick )
		addEventHandler ( "onClientGUIAccepted", aAdminForm, aClientGUIAccepted )
		addEventHandler ( "onClientGUIChanged", aAdminForm, aClientGUIChanged )
		addEventHandler ( "onClientRender", _root, aClientRender )
		addEventHandler ( "onClientPlayerChangeNick", _root, aClientPlayerChangeNick )
		addEventHandler ( "onClientResourceStop", _root, aMainSaveSettings )
		addEventHandler ( "onClientGUITabSwitched", aTabPanel, aClientGUITabSwitched )

		bindKey ( "arrow_d", "down", aPlayerListScroll, 1 )
		bindKey ( "arrow_u", "down", aPlayerListScroll, -1 )

		triggerServerEvent ( "aSync", localPlayer, "players" )
		if ( hasPermissionTo ( "command.listmessages" ) ) then triggerServerEvent ( "aSync", localPlayer, "messages" ) end
		triggerServerEvent ( "aSync", localPlayer, "server" )
		triggerEvent ( "onAdminInitialize", resourceRoot )
		showCursor ( true )

		if getVersion().sortable and getVersion().sortable < "1.0.4-9.02436" then
			guiSetText ( aAdminForm, "Warning - Admin Panel not compatible with server version" )
			guiLabelSetHorizontalAlign ( guiCreateLabel ( 0.30, 0.11, 0.4, 0.04, "Upgrade server or downgrade Admin Panel", true, aAdminForm ), "center" )
		end

		setHideSensitiveData(aGetSetting('currentHideSensitiveDataState'))
		setHideColorCodes(aGetSetting('currentHideColorCodesState'))
	end
	guiSetVisible ( aAdminForm, true )
	showCursor ( true )
	-- If the camera target was on another player, select him in the player list
	local element = getCameraTarget()
	if element and getElementType(element)=="vehicle" then
		element = getVehicleController(element)
	end
	if element and getElementType(element)=="player" and element ~= localPlayer then
		for row=0,guiGridListGetRowCount( aTab1.PlayerList )-1 do
			if ( guiGridListGetItemPlayerName ( aTab1.PlayerList, row, 1 ) == getPlayerName ( element ) ) then
				guiGridListSetSelectedItem ( aTab1.PlayerList, row, 1 )
				break
			end
		end
	end
    guiSetInputMode ( "no_binds_when_editing" )
end

function aAdminMenuClose ( destroy )
	if ( destroy ) then
		aMainSaveSettings ()
		aPlayers = {}
		aWeathers = {}
		aBans = {}
		removeEventHandler ( "aClientLog", _root, aClientLog )
		removeEventHandler ( "aClientAdminChat", _root, aClientAdminChat )
		removeEventHandler ( "aClientSync", _root, aClientSync )
		removeEventHandler ( "aClientResourceStart", _root, aClientResourceStart )
		removeEventHandler ( "aClientResourceStop", _root, aClientResourceStop )
		removeEventHandler ( "aClientPlayerJoin", _root, aClientPlayerJoin )
		removeEventHandler ( "onClientPlayerQuit", _root, aClientPlayerQuit )
		removeEventHandler ( "onClientGUIClick", aAdminForm, aClientClick )
		removeEventHandler ( "onClientGUIScroll", aAdminForm, aClientScroll )
		removeEventHandler ( "onClientGUIDoubleClick", aAdminForm, aClientDoubleClick )
		removeEventHandler ( "onClientGUIAccepted", aAdminForm, aClientGUIAccepted )
		removeEventHandler ( "onClientGUIChanged", aAdminForm, aClientGUIChanged )
		removeEventHandler ( "onClientRender", _root, aClientRender )
		removeEventHandler ( "onClientPlayerChangeNick", _root, aClientPlayerChangeNick )
		removeEventHandler ( "onClientResourceStop", _root, aMainSaveSettings )
		unbindKey ( "arrow_d", "down", aPlayerListScroll )
		unbindKey ( "arrow_u", "down", aPlayerListScroll )
		destroyElement ( aAdminForm )
		aAdminForm = nil
	else
		guiSetVisible ( aAdminForm, false )
	end
	showCursor ( false )
    guiSetInputMode ( "allow_binds")
end

function aMainSaveSettings ()
	aSetSetting ( "currentWeapon", aCurrentWeapon )
	aSetSetting ( "currentAmmo", aCurrentAmmo )
	aSetSetting ( "currentVehicle", aCurrentVehicle )
	aSetSetting ( "currentSlap", aCurrentSlap )
end

function aAdminRefresh ()
	if ( guiGridListGetSelectedItem ( aTab1.PlayerList ) ~= -1 ) then
		local player = getPlayerFromName ( guiGridListGetItemPlayerName ( aTab1.PlayerList, guiGridListGetSelectedItem( aTab1.PlayerList ), 1 ) )
		if ( player and aPlayers[player] ) then
			local playerName = aPlayers[player]["name"]
			
			if isColorCodeHidden() then
				playerName = removeColorCoding(playerName)
			else
				if playerName:find('#%x%x%x%x%x%x') then
					playerName = playerName .. (' (%s)'):format(removeColorCoding(playerName))
				end
			end

			guiSetText ( aTab1.Name, "Name: ".. playerName)
			guiSetText ( aTab1.Mute, iif ( aPlayers[player]["mute"], "Unmute", "Mute" ) )
			guiSetText ( aTab1.Freeze, iif ( aPlayers[player]["freeze"], "Unfreeze", "Freeze" ) )
			guiSetText ( aTab1.Version, "Version: "..( aPlayers[player]["version"] or "" ) )
			guiSetText ( aTab1.Accountname, "Account Name: "..getSensitiveText( aPlayers[player]["accountname"] or "" ) )
			guiSetText ( aTab1.Groups, "Groups: "..( aPlayers[player]["groups"] or "None" ) )
			if ( isPedDead ( player ) ) then guiSetText ( aTab1.Health, "Health: Dead" )
			else guiSetText ( aTab1.Health, "Health: "..math.ceil ( getElementHealth ( player ) ).."%" ) end
			guiSetText ( aTab1.Armour, "Armour: "..math.ceil ( getPedArmor ( player ) ).."%" )
			guiSetText ( aTab1.Skin, "Skin: "..iif ( getElementModel ( player ), getElementModel ( player ), "N/A" ) )
			if ( getPlayerTeam ( player ) ) then guiSetText ( aTab1.Team, "Team: "..getTeamName ( getPlayerTeam ( player ) ) )
			else guiSetText ( aTab1.Team, "Team: None" ) end
			guiSetText ( aTab1.Ping, "Ping: "..getPlayerPing ( player ) )
			guiSetText ( aTab1.Money, "Money: "..( aPlayers[player]["money"] or 0 ) )
			if ( getElementDimension ( player ) ) then guiSetText ( aTab1.Dimension, "Dimension: "..getElementDimension ( player ) ) end
			if ( getElementInterior ( player ) ) then guiSetText ( aTab1.Interior, "Interior: "..getElementInterior ( player ) ) end
			guiSetText ( aTab1.JetPack, iif ( doesPedHaveJetPack ( player ), "Remove JetPack", "Give JetPack" ) )
			if ( getPedWeapon ( player ) ) then guiSetText ( aTab1.Weapon, "Weapon: "..getWeaponNameFromID ( getPedWeapon ( player ) ).." (ID: "..getPedWeapon ( player )..")" ) end
			
			local x, y, z = getElementPosition ( player )
			local zoneName = getZoneName ( x, y, z, false )
			local cityName = getZoneName ( x, y, z, true )
			
			guiSetText ( aTab1.Area, "Area: "..getSensitiveText( iif ( zoneName == cityName, zoneName, zoneName.." ("..cityName..")" ) ) )

			x = getSensitiveText('%.3f'):format(x)
			y = getSensitiveText('%.3f'):format(y)
			z = getSensitiveText('%.3f'):format(z)

			guiSetText(aTab1.Position, ( "Position: %s, %s, %s" ):format(x, y, z))

			local vehicle = getPedOccupiedVehicle ( player )
			if ( vehicle ) then
				guiSetText ( aTab1.Vehicle, "Vehicle: "..getVehicleName ( vehicle ).." (ID: "..getElementModel ( vehicle )..")" )
				guiSetText ( aTab1.VehicleHealth, "Vehicle Health: "..math.ceil ( getElementHealth ( vehicle ) ).."%" )
			else
				guiSetText ( aTab1.Vehicle, "Vehicle: Foot" )
				guiSetText ( aTab1.VehicleHealth, "Vehicle Health: 0%" )
			end
			if ( aPlayers[player]["admin"] ) then
				guiSetText(aTab1.Admin, "Revoke admin rights")
			else
				guiSetText(aTab1.Admin, "Give admin rights")
			end
			return player
		end
	end
end

function aClientSync ( type, table, data )
	if ( type == "player" and aPlayers[source] ) then
		for type, data in pairs ( table ) do
			aPlayers[source][type] = data
		end
	elseif ( type == "players" ) then
		aPlayers = table
	elseif ( type == "resources" ) then
		local bInclMaps = guiCheckBoxGetSelected ( aTab2.ResourceInclMaps )
		aResources = table
		for id, resource in ipairs(table) do
			if bInclMaps or resource["type"] ~= "map" then
				local row = guiGridListAddRow ( aTab2.ResourceList )
				guiGridListSetItemText ( aTab2.ResourceList, row, 1, resource["name"], false, false )
				guiGridListSetItemText ( aTab2.ResourceList, row, 2, resource["numsettings"] > 0 and tostring(resource["numsettings"]) or "", false, false )
				guiGridListSetItemText ( aTab2.ResourceList, row, 3, resource["state"], false, false )
				guiGridListSetItemText ( aTab2.ResourceList, row, 4, resource["fullName"], false, false )
				guiGridListSetItemText ( aTab2.ResourceList, row, 5, resource["author"], false, false )
				guiGridListSetItemText ( aTab2.ResourceList, row, 6, resource["version"], false, false )
			end
		end
	elseif ( type == "loggedout" ) then
		aAdminDestroy()
	elseif ( type == "server" ) then
		serverPassword = table["password"] or "None"
		guiSetText ( aTab3.Server, "Server: "..table["name"] )
		guiSetText ( aTab3.Players, "Players: "..#getElementsByType ( "player" ).."/"..table["players"] )
		guiSetText ( aTab3.Password, "Password: "..getSensitiveText( serverPassword ) )
		guiSetText ( aTab3.GameType, "Game Type: "..( table["game"] or "None" ) )
		guiSetText ( aTab3.MapName, "Map Name: "..( table["map"] or "None" ) )
		guiSetText ( aTab3.FPSCurrent, "FPS Limit: "..( table["fps"] or "N/A" ) )
		guiSetText ( aTab3.FPS, table["fps"] or "38" )
	end
end

function getNeededTagType (tagType,ban)
end


function aClientGUITabSwitched( selectedTab )
	if getElementParent( selectedTab ) == aTabPanel then
		if selectedTab == aTab2.Tab then
			if guiGridListGetRowCount( aTab2.ResourceList ) == 0 then
				if ( hasPermissionTo ( "command.listresources" ) ) then
					triggerServerEvent ( "aSync", localPlayer, "resources" )
				end
			end
		end
	end
end

function aClientResourceStart ( resource )
	local id = 0
	while ( id <= guiGridListGetRowCount( aTab2.ResourceList ) ) do
		if ( guiGridListGetItemText ( aTab2.ResourceList, id, 1 ) == resource ) then
			guiGridListSetItemText ( aTab2.ResourceList, id, 3, "running", false, false )
		end
		id = id + 1
	end
end

function aClientResourceStop ( resource )
	local id = 0
	while ( id <= guiGridListGetRowCount( aTab2.ResourceList ) ) do
		if ( guiGridListGetItemText ( aTab2.ResourceList, id, 1 ) == resource ) then
			guiGridListSetItemText ( aTab2.ResourceList, id, 3, "loaded", false, false )
		end
		id = id + 1
	end
end

function aClientPlayerJoin ( ip, accountname, serial, admin, country )
	if ip == false and serial == false then
		-- Update country only
		if aPlayers[source] then
			aPlayers[source]["country"] = country
		end
		return
	end
	aPlayers[source] = {}
	aPlayers[source]["name"] = getPlayerName ( source )
	aPlayers[source]["IP"] = ip
	aPlayers[source]["accountname"] = accountname or "N/A"
	aPlayers[source]["serial"] = serial
	aPlayers[source]["country"] = country
	aPlayers[source]["acdetected"] = "..."
	aPlayers[source]["d3d9dll"] = ""
	aPlayers[source]["imgmodsnum"] = ""
	local row = guiGridListAddRow ( aTab1.PlayerList )
	guiGridListSetItemPlayerName ( aTab1.PlayerList, row, 1, getPlayerName ( source ), false, false )
	if ( aSpectator.PlayerList ) then
		local row = guiGridListAddRow ( aSpectator.PlayerList )
		guiGridListSetItemPlayerName ( aSpectator.PlayerList, row, 1, getPlayerName ( source ), false, false )
	end
end

function aClientPlayerQuit ()
	local id = 0
	while ( id <= guiGridListGetRowCount( aTab1.PlayerList ) ) do
		if ( guiGridListGetItemPlayerName ( aTab1.PlayerList, id, 1 ) == getPlayerName ( source ) ) then
			guiGridListRemoveRow ( aTab1.PlayerList, id )
		end
		id = id + 1
	end
	if ( aPlayers[source] and aPlayers[source]["admin"] ) then
		local id = 0
		while ( id <= guiGridListGetRowCount( aTab5.AdminPlayers ) ) do
			if ( guiGridListGetItemPlayerName ( aTab5.AdminPlayers, id, 1 ) == getPlayerName ( source ) ) then
				guiGridListRemoveRow ( aTab5.AdminPlayers, id )
			end
			id = id + 1
		end
	end
	if ( aSpectator.PlayerList ) then
		local id = 0
		while ( id <= guiGridListGetRowCount( aSpectator.PlayerList ) ) do
			if ( guiGridListGetItemPlayerName ( aSpectator.PlayerList, id, 1 ) == getPlayerName ( source ) ) then
				guiGridListRemoveRow ( aSpectator.PlayerList, id )
			end
			id = id + 1
		end
	end
	aPlayers[source] = nil
end

function aPlayerListScroll ( key, state, inc )
	if ( not guiGetVisible ( aAdminForm ) ) then return end
	local max = guiGridListGetRowCount ( aTab1.PlayerList )
	if ( max <= 0 ) then return end
	local current = guiGridListGetSelectedItem ( aTab1.PlayerList )
	local next = current + inc
	max = max - 1
	if ( current == -1 ) then
		guiGridListSetSelectedItem ( aTab1.PlayerList, 0, 1 )
	elseif ( next > max ) then return
	elseif ( next < 0 ) then return
	else
		guiGridListSetSelectedItem ( aTab1.PlayerList, next, 1 )
	end
	local oldsource = source
	source = aTab1.PlayerList;
	aClientClick ( "left" )
	source = oldsource
end

function aClientPlayerChangeNick ( oldNick, newNick )
	local lists = { aTab1.PlayerList, aSpectator.PlayerList }
	for _,gridlist in ipairs(lists) do
		for row=0,guiGridListGetRowCount(gridlist)-1 do
			if ( guiGridListGetItemPlayerName ( gridlist, row, 1 ) == oldNick ) then
				guiGridListSetItemPlayerName ( gridlist, row, 1, newNick, false, false )
				aPlayers[source]["name"] = newNick
			end
		end
	end
end

function aClientAdminChat ( message )
	local chat = guiGetText ( aTab5.AdminChat )
	guiSetText ( aTab5.AdminChat, (chat ~= "\n" and chat or "")..getPlayerName ( source )..": "..message )
	guiSetProperty ( aTab5.AdminChat, "CaratIndex", tostring ( string.len ( chat ) ) )
	if ( not isSensitiveDataHidden() and ( guiCheckBoxGetSelected ( aTab6.AdminChatOutput ) ) ) then outputChatBox ( "ADMIN CHAT> "..getPlayerName ( source )..": "..message, 255, 0, 0 ) end
	if ( ( guiCheckBoxGetSelected ( aTab5.AdminChatSound ) ) and ( source ~= localPlayer ) ) then playSoundFrontEnd ( 13 ) end
end

function aSetCurrentAmmo ( ammo )
	ammo = tonumber ( ammo )
	if ( ( ammo ) and ( ammo > 0 ) and ( ammo < 10000 ) ) then
		aCurrentAmmo = ammo
		return
	end
	outputChatBox ( "Invalid ammo value", 255, 0, 0 )
end

function aClientGUIAccepted ( element )
	if ( element == aTab5.AdminText ) then
		local message = guiGetText ( aTab5.AdminText )
		if ( ( message ) and ( message ~= "" ) ) then
			if ( gettok ( message, 1, 32 ) == "/clear" ) then guiSetText ( aTab5.AdminChat, "" )
			else triggerServerEvent ( "aAdminChat", localPlayer, message ) end
			guiSetText ( aTab5.AdminText, "" )
		end
	end
end

function aClientGUIChanged ()
	if ( source == aTab1.PlayerListSearch ) then
		guiGridListClear ( aTab1.PlayerList )
		local text = guiGetText ( source )
		if ( text == "" ) then
			for id, player in ipairs ( getElementsByType ( "player" ) ) do
				guiGridListSetItemPlayerName ( aTab1.PlayerList, guiGridListAddRow ( aTab1.PlayerList ), 1, getPlayerName ( player ), false, false )
			end
		else
			for id, player in ipairs ( getElementsByType ( "player" ) ) do
				if ( string.find ( string.upper ( getPlayerName ( player ) ), string.upper ( text ), 1, true ) ) then
					guiGridListSetItemPlayerName ( aTab1.PlayerList, guiGridListAddRow ( aTab1.PlayerList ), 1, getPlayerName ( player ), false, false )
				end
			end
		end
	elseif ( source == aTab2.ResourceListSearch ) then
		local bInclMaps = guiCheckBoxGetSelected ( aTab2.ResourceInclMaps )
		guiGridListClear ( aTab2.ResourceList )
		local text = string.lower(guiGetText(source))
		if ( text == "" ) then
			for id, resource in ipairs(aResources) do
				if bInclMaps or resource["type"] ~= "map" then
					local row = guiGridListAddRow ( aTab2.ResourceList )
					guiGridListSetItemText ( aTab2.ResourceList, row, 1, resource["name"], false, false )
					guiGridListSetItemText ( aTab2.ResourceList, row, 2, resource["numsettings"] > 0 and tostring(resource["numsettings"]) or "", false, false )
					guiGridListSetItemText ( aTab2.ResourceList, row, 3, resource["state"], false, false )
					guiGridListSetItemText ( aTab2.ResourceList, row, 4, resource["fullName"], false, false )
					guiGridListSetItemText ( aTab2.ResourceList, row, 5, resource["author"], false, false )
					guiGridListSetItemText ( aTab2.ResourceList, row, 6, resource["version"], false, false )
				end
			end
		else
			for id, resource in ipairs(aResources) do
				if bInclMaps or resource["type"] ~= "map" then
					if string.find(string.lower(resource.name), text, 1, true) then
						local row = guiGridListAddRow ( aTab2.ResourceList )
						guiGridListSetItemText ( aTab2.ResourceList, row, 1, resource["name"], false, false )
						guiGridListSetItemText ( aTab2.ResourceList, row, 2, resource["numsettings"] > 0 and tostring(resource["numsettings"]) or "", false, false )
						guiGridListSetItemText ( aTab2.ResourceList, row, 3, resource["state"], false, false )
						guiGridListSetItemText ( aTab2.ResourceList, row, 4, resource["fullName"], false, false )
						guiGridListSetItemText ( aTab2.ResourceList, row, 5, resource["author"], false, false )
						guiGridListSetItemText ( aTab2.ResourceList, row, 6, resource["version"], false, false )
					end
				end
			end
		end
	end
end

function aClientScroll ( element )
	if ( source == aTab6.MouseSense ) then
		guiSetText ( aTab6.MouseSenseCur, "Cursor sensivity: ("..string.sub ( guiScrollBarGetScrollPosition ( source ) / 50, 0, 4 )..")" )
	end
end

function aClientDoubleClick ( button )
	if ( source == aTab2.ResourceList ) then
		if ( guiGridListGetSelectedItem ( aTab2.ResourceList ) ~= -1 ) then
			aManageSettings ( guiGridListGetItemText ( aTab2.ResourceList, guiGridListGetSelectedItem( aTab2.ResourceList ), 1 ) )
		end
	end
end

function aClientClick ( button )
	if ( button == "left" ) then
		-- TAB 1, PLAYERS
		if ( getElementParent ( source ) == aTab1.Tab ) then
			if ( source == aTab1.PlayerListSearch ) then

			elseif ( source == aTab1.HideColorCodes ) then
				setHideColorCodes ( guiCheckBoxGetSelected ( aTab1.HideColorCodes ) )
			elseif ( source == aTab1.AnonAdmin ) then
				setAnonAdmin( guiCheckBoxGetSelected ( aTab1.AnonAdmin ) )
			elseif ( source == aTab1.HideSensitiveData ) then
				setHideSensitiveData( guiCheckBoxGetSelected ( aTab1.HideSensitiveData ) )
			elseif ( getElementType ( source ) == "gui-button" )  then
				if ( guiGridListGetSelectedItem ( aTab1.PlayerList ) == -1 ) then
					aMessageBox ( "error", "No player selected!" )
				else
					local name = guiGridListGetItemPlayerName ( aTab1.PlayerList, guiGridListGetSelectedItem( aTab1.PlayerList ), 1 )
					local player = getPlayerFromName ( name )
					if ( source == aTab1.Kick ) then aInputBox ( "Kick player "..removeColorCoding(name), "Enter the kick reason", "", "kickPlayer", player )
					elseif ( source == aTab1.Ban ) then aBanInputBox ( player )
					elseif ( source == aTab1.Slap ) then triggerServerEvent ( "aPlayer", localPlayer, player, "slap", aCurrentSlap )
					elseif ( source == aTab1.Mute ) then if not aPlayers[player]["mute"] then aMuteInputBox ( player ) else aMessageBox ( "question", "Are you sure to unmute "..removeColorCoding(name).."?", "unmute", player ) end
					elseif ( source == aTab1.Freeze ) then triggerServerEvent ( "aPlayer", localPlayer, player, "freeze" )
					elseif ( source == aTab1.Spectate ) then aSpectate ( player )
					elseif ( source == aTab1.Nick ) then aInputBox ( "Set Nick", "Enter the new nick of the player", name, "setNick", player )
					elseif ( source == aTab1.Shout ) then aInputBox ( "Shout", "Enter text to be shown on player's screen", "", "shout", player )
					elseif ( source == aTab1.SetHealth ) then aInputBox ( "Set Health", "Enter the health value", "100", "setHealth", player )
					elseif ( source == aTab1.SetArmour ) then aInputBox ( "Set Armour", "Enter the armour value", "100", "setArmor", player )
					elseif ( source == aTab1.SetTeam ) then aPlayerTeam ( player )
					elseif ( source == aTab1.SetSkin ) then aPlayerSkin ( player )
					elseif ( source == aTab1.SetInterior ) then aPlayerInterior ( player )
					elseif ( source == aTab1.JetPack ) then triggerServerEvent ( "aPlayer", localPlayer, player, "jetpack" )
					elseif ( source == aTab1.SetMoney ) then aInputBox ( "Set Money", "Enter the money value", "0", "setMoney", player )
					elseif ( source == aTab1.SetStats ) then aPlayerStats ( player )
					elseif ( source == aTab1.SetDimension ) then aInputBox ( "Dimension ID Required", "Enter Dimension ID between 0 and 65535", "0", "setDimension", player)
					elseif ( source == aTab1.GiveVehicle ) then triggerServerEvent ( "aPlayer", localPlayer, player, "givevehicle", aCurrentVehicle )
					elseif ( source == aTab1.GiveWeapon ) then triggerServerEvent ( "aPlayer", localPlayer, player, "giveweapon", aCurrentWeapon, aCurrentAmmo )
					elseif ( source == aTab1.Warp ) then triggerServerEvent ( "aPlayer", localPlayer, player, "warp" )
					elseif ( source == aTab1.WarpTo ) then aPlayerWarp ( player )
					elseif ( source == aTab1.VehicleFix ) then triggerServerEvent ( "aVehicle", localPlayer, player, "repair" )
					elseif ( source == aTab1.VehicleBlow ) then triggerServerEvent ( "aVehicle", localPlayer, player, "blowvehicle" )
					elseif ( source == aTab1.VehicleDestroy ) then triggerServerEvent ( "aVehicle", localPlayer, player, "destroyvehicle" )
					elseif ( source == aTab1.VehicleCustomize ) then aVehicleCustomize ( player )
					elseif ( source == aTab1.Admin ) then
						if ( aPlayers[player]["admin"] ) then aMessageBox ( "warning", "Revoke admin rights from "..name.."?", "revokeAdmin", player )
						else aMessageBox ( "warning", "Give admin rights to "..name.."?", "giveAdmin", player ) end
					end
				end
			elseif ( source == aTab1.PlayerList ) then
				aAdminReloadInfos()
			end
		-- TAB 2, RESOURCES
		elseif ( getElementParent ( source ) == aTab2.Tab ) then
			if ( source == aTab2.ResourceListSearch ) then

			elseif ( ( source == aTab2.ResourceStart ) or ( source == aTab2.ResourceRestart ) or ( source == aTab2.ResourceStop ) or ( source == aTab2.ResourceDelete ) or ( source == aTab2.ResourceSettings ) ) then
				if ( guiGridListGetSelectedItem ( aTab2.ResourceList ) == -1 ) then
					aMessageBox ( "error", "No resource selected!" )
				else
					if ( source == aTab2.ResourceStart ) then triggerServerEvent ( "aResource", localPlayer, guiGridListGetItemText ( aTab2.ResourceList, guiGridListGetSelectedItem( aTab2.ResourceList ), 1 ), "start" )
					elseif ( source == aTab2.ResourceRestart ) then triggerServerEvent ( "aResource", localPlayer, guiGridListGetItemText ( aTab2.ResourceList, guiGridListGetSelectedItem( aTab2.ResourceList ), 1 ), "restart" )
					elseif ( source == aTab2.ResourceStop ) then triggerServerEvent ( "aResource", localPlayer, guiGridListGetItemText ( aTab2.ResourceList, guiGridListGetSelectedItem( aTab2.ResourceList ), 1 ), "stop" )
					elseif ( source == aTab2.ResourceDelete ) then aMessageBox ( "warning", "Are you sure you want to stop and delete resource '" .. guiGridListGetItemText ( aTab2.ResourceList, guiGridListGetSelectedItem( aTab2.ResourceList ), 1 ) .. "' ?", "stopDelete", guiGridListGetItemText ( aTab2.ResourceList, guiGridListGetSelectedItem( aTab2.ResourceList ), 1 ) )
					elseif ( source == aTab2.ResourceSettings ) then aManageSettings ( guiGridListGetItemText ( aTab2.ResourceList, guiGridListGetSelectedItem( aTab2.ResourceList ) ) )
					end
				end
			elseif ( source == aTab2.ResourcesStopAll ) then aMessageBox ( "warning", "Are you sure you want to stop all resources? This will also stop 'admin' resource.", "stopAll" )
			elseif ( source == aTab2.ResourceList ) then
				if ( guiGridListGetSelectedItem ( aTab2.ResourceList ) ~= -1 ) then
					guiSetText(aTab2.ResourceName, "Full Name: " .. guiGridListGetItemText(aTab2.ResourceList, guiGridListGetSelectedItem ( aTab2.ResourceList ), 4))
					guiSetText(aTab2.ResourceAuthor, "Author: " .. guiGridListGetItemText(aTab2.ResourceList, guiGridListGetSelectedItem ( aTab2.ResourceList ), 5))
					guiSetText(aTab2.ResourceVersion, "Version: " .. guiGridListGetItemText(aTab2.ResourceList, guiGridListGetSelectedItem ( aTab2.ResourceList ), 6))
				end
			elseif ( source == aTab2.ManageACL ) then
				aManageACL()
			elseif ( source == aTab2.ResourceRefresh or source == aTab2.ResourceInclMaps ) then
				guiGridListClear ( aTab2.ResourceList )
				triggerServerEvent ( "aSync", localPlayer, "resources" )
			elseif ( source == aTab2.ExecuteClient ) then
				if ( ( guiGetText ( aTab2.Command ) ) and ( guiGetText ( aTab2.Command ) ~= "" ) ) then aExecute ( guiGetText ( aTab2.Command ), true ) end
			elseif ( source == aTab2.ExecuteServer ) then
				if ( ( guiGetText ( aTab2.Command ) ) and ( guiGetText ( aTab2.Command ) ~= "" ) ) then triggerServerEvent ( "aExecute", localPlayer, guiGetText ( aTab2.Command ), true ) end
			elseif ( source == aTab2.Command ) then

				guiSetVisible ( aTab2.ExecuteAdvanced, false )
			elseif ( source == aTab2.ExecuteAdvanced ) then
				guiSetVisible ( aTab2.ExecuteAdvanced, false )
			end
		-- TAB 3, WORLD
		elseif ( getElementParent ( source ) == aTab3.Tab ) then
			if ( source == aTab3.SetGameType ) then aInputBox ( "Game Type", "Enter game type:", "", "setGameType" )
			elseif ( source == aTab3.SetMapName ) then aInputBox ( "Map Name", "Enter map name:", "", "setMapName" )
			elseif ( source == aTab3.SetWelcome ) then aInputBox ( "Welcome Message", "Enter the server welcome message:", "", "setWelcome" )
			elseif ( source == aTab3.SetPassword ) then aInputBox ( "Server password", "Enter server password: (32 characters max)", "", "setServerPassword" )
			elseif ( source == aTab3.Shutdown ) then aInputBox ( "Shutdown the server", "Enter shutdown reason:", "", "serverShutdown" )
			elseif ( source == aTab3.ResetPassword ) then triggerServerEvent ( "aServer", localPlayer, "setpassword", "" )
			elseif ( ( source == aTab3.WeatherInc ) or ( source == aTab3.WeatherDec ) ) then
				local id = tonumber ( gettok ( guiGetText ( aTab3.Weather ), 1, 32 ) )
				if ( id ) then
					if ( ( source == aTab3.WeatherInc ) and ( id < _weathers_max ) ) then guiSetText ( aTab3.Weather, ( id + 1 ).." ("..getWeatherNameFromID ( id + 1 )..")" )
					elseif ( ( source == aTab3.WeatherDec ) and ( id > 0 ) ) then guiSetText ( aTab3.Weather, ( id - 1 ).." ("..getWeatherNameFromID ( id - 1 )..")" ) end
				else
					guiSetText ( aTab3.Weather, ( 14 ).." ("..getWeatherNameFromID ( 14 )..")" )
				end
			elseif ( source == aTab3.WeatherSet ) then triggerServerEvent ( "aServer", localPlayer, "setweather", gettok ( guiGetText ( aTab3.Weather ), 1, 32 ) )
			elseif ( source == aTab3.WeatherBlend ) then triggerServerEvent ( "aServer", localPlayer, "blendweather", gettok ( guiGetText ( aTab3.Weather ), 1, 32 ) )
			elseif ( source == aTab3.TimeSet ) then triggerServerEvent ( "aServer", localPlayer, "settime", guiGetText ( aTab3.TimeH ), guiGetText ( aTab3.TimeM ) )
			elseif ( ( source == aTab3.SpeedInc ) or ( source == aTab3.SpeedDec ) ) then
				local value = tonumber ( guiGetText ( aTab3.Speed ) )
				if ( value ) then
					if ( ( source == aTab3.SpeedInc ) and ( value < 10 ) ) then guiSetText ( aTab3.Speed, tostring ( value + 1 ) )
					elseif ( ( source == aTab3.SpeedDec ) and ( value > 0 ) ) then guiSetText ( aTab3.Speed, tostring ( value - 1 ) ) end
				else
					guiSetText ( aTab3.Speed, "1" )
				end
			elseif ( source == aTab3.SpeedSet ) then triggerServerEvent ( "aServer", localPlayer, "setgamespeed", guiGetText ( aTab3.Speed ) )
			elseif ( source == aTab3.GravitySet ) then triggerServerEvent ( "aServer", localPlayer, "setgravity", guiGetText ( aTab3.Gravity ) )
			elseif ( source == aTab3.WavesSet ) then triggerServerEvent ( "aServer", localPlayer, "setwaveheight", guiGetText ( aTab3.Waves ) )
			elseif ( source == aTab3.FPSSet ) then
			triggerServerEvent ( "aServer", localPlayer, "setfpslimit", guiGetText ( aTab3.FPS ) )
			triggerServerEvent ( "aSync", localPlayer, "server" )
			end
		end
	elseif ( button == "right" ) then
		if ( source == aTab1.GiveWeapon ) then aInputBox ( "Weapon Ammo", "Ammo value from 1 to 9999", "100", "setCurrentAmmo" )
		end
	end
end

function aClientRender ()
	if ( guiGetVisible ( aAdminForm ) ) then
		if ( getTickCount() >= aLastCheck ) then
			aAdminRefresh ()
			local th, tm = getTime()
			guiSetText ( aTab3.Players, "Players: "..#getElementsByType ( "player" ).."/"..gettok ( guiGetText ( aTab3.Players ), 2, 47 ) )
			guiSetText ( aTab3.TimeCurrent,	string.format("Time: %02d:%02d", th, tm ) )
			guiSetText ( aTab3.GravityCurrent, "Gravitation: "..string.sub ( getGravity(), 0, 6 ) )
			guiSetText ( aTab3.SpeedCurrent, "Game Speed: "..getGameSpeed() )
			guiSetText ( aTab3.WeatherCurrent, "Weather: "..getWeather().." ("..getWeatherNameFromID ( getWeather() )..")" )
			if ( ( refreshTime ) and ( refreshTime >= 20 ) ) then aLastCheck = getTickCount() + refreshTime
			else aLastCheck = getTickCount() + 50 end
		end
		if ( getTickCount() >= aLastSync ) then
			triggerServerEvent ( "aSync", localPlayer, "admins" )
			aLastSync = getTickCount() + 15000
		end
	end
end

function aAdminReloadInfos()
	if ( guiGridListGetSelectedItem( aTab1.PlayerList ) ~= -1 ) then
		local player = aAdminRefresh ()
		if ( player ) then
			triggerServerEvent ( "aSync", localPlayer, "player", player )
				local playerName = aPlayers[player]["name"]
			
				if isColorCodeHidden() then
					playerName = removeColorCoding(playerName)
				else
					if playerName:find('#%x%x%x%x%x%x') then
						playerName = playerName .. (' (%s)'):format(removeColorCoding(playerName))
					end
				end		

				outputConsole(' ')
				outputConsole(('Name: %s'):format(playerName))
				outputConsole(('IP: %s'):format(aPlayers[player]["IP"]))
				outputConsole(('Serial: %s'):format(aPlayers[player]["serial"]))
				outputConsole(('Account Name: %s'):format(aPlayers[player]["accountname"]))
				outputConsole(('D3D9.DLL: %s'):format(aPlayers[player]["d3d9dll"]))
				outputConsole(' ')
			end
			guiSetText ( aTab1.IP, "IP: "..getSensitiveText( aPlayers[player]["IP"] ) )
			guiSetText ( aTab1.Serial, "Serial: "..getSensitiveText( aPlayers[player]["serial"] ) )
			guiSetText ( aTab1.Accountname, "Account Name: "..getSensitiveText( aPlayers[player]["accountname"] ) )
			local countryCode = aPlayers[player]["country"]
			loadFlagImage ( aTab1.Flag, countryCode )
			if not countryCode then
				guiSetText ( aTab1.CountryCode, "" )
			else
				local x, y = guiGetPosition ( aTab1.IP, false )
				local width = guiLabelGetTextExtent ( aTab1.IP )
				guiSetPosition ( aTab1.Flag, x + width + 7, y + 4, false )
				guiSetPosition ( aTab1.CountryCode, x + width + 30, y, false )
				guiSetText ( aTab1.CountryCode, tostring( countryCode ) )
			end
			guiSetText ( aTab1.Version, "Version: " .. ( aPlayers[player]["version"] or "" ) )
	else
		guiSetText ( aTab1.Name, "Name: N/A" )
		guiSetText ( aTab1.IP, "IP: N/A" )
		guiSetText ( aTab1.Serial, "Serial: N/A" )
		guiSetText ( aTab1.Version, "Version: N/A" )
		guiSetText ( aTab1.Accountname, "Account Name: N/A" )
		guiSetText ( aTab1.Groups, "Groups: N/A" )
		guiSetText ( aTab1.Mute, "Mute" )
		guiSetText ( aTab1.Freeze, "Freeze" )
		guiSetText ( aTab1.Admin, "Give admin rights" )
		guiSetText ( aTab1.Health, "Health: 0%" )
		guiSetText ( aTab1.Armour, "Armour: 0%" )
		guiSetText ( aTab1.Skin, "Skin: N/A" )
		guiSetText ( aTab1.Team, "Team: None" )
		guiSetText ( aTab1.Ping, "Ping: 0" )
		guiSetText ( aTab1.Money, "Money: 0" )
		guiSetText ( aTab1.Dimension, "Dimension: 0" )
		guiSetText ( aTab1.Interior, "Interior: 0" )
		guiSetText ( aTab1.JetPack, "Give JetPack" )
		guiSetText ( aTab1.Weapon, "Weapon: N/A" )
		guiSetText ( aTab1.Area, "Area: Unknown" )
		guiSetText ( aTab1.Position, "Position: 0, 0, 0" )
		guiSetText ( aTab1.Vehicle, "Vehicle: N/A" )
		guiSetText ( aTab1.VehicleHealth, "Vehicle Health: 0%" )
		guiStaticImageLoadImage ( aTab1.Flag, "client\\images\\empty.png" )
		guiSetText ( aTab1.CountryCode, "" )
	end
	guiSetText ( aTab3.Password, "Password: "..getSensitiveText( serverPassword ) )
end

function updateColorCodes()
end

function guiGridListSetItemPlayerName( gridlist, row, col, name )
	guiGridListSetItemText( gridlist, row, col, isColorCodeHidden() and removeColorCoding(name) or name, false, false )
	guiGridListSetItemData( gridlist, row, col, name )
end

function guiGridListGetItemPlayerName( gridlist, row, col )
	return guiGridListGetItemData( gridlist, row, col ) or guiGridListGetItemText( gridlist, row, col )
end

-- remove color coding from string
function removeColorCoding( name )
	return type(name)=='string' and string.gsub ( name, '#%x%x%x%x%x%x', '' ) or name
end

-- Unix to date
--dependency:
function Check(funcname, ...)
    local arg = {...}

    if (type(funcname) ~= "string") then
        error("Argument type mismatch at 'Check' ('funcname'). Expected 'string', got '"..type(funcname).."'.", 2)
    end
    if (#arg % 3 > 0) then
        error("Argument number mismatch at 'Check'. Expected #arg % 3 to be 0, but it is "..(#arg % 3)..".", 2)
    end

    for i=1, #arg-2, 3 do
        if (type(arg[i]) ~= "string" and type(arg[i]) ~= "table") then
            error("Argument type mismatch at 'Check' (arg #"..i.."). Expected 'string' or 'table', got '"..type(arg[i]).."'.", 2)
        elseif (type(arg[i+2]) ~= "string") then
            error("Argument type mismatch at 'Check' (arg #"..(i+2).."). Expected 'string', got '"..type(arg[i+2]).."'.", 2)
        end

        if (type(arg[i]) == "table") then
            local aType = type(arg[i+1])
            for _, pType in next, arg[i] do
                if (aType == pType) then
                    aType = nil
                    break
                end
            end
            if (aType) then
                error("Argument type mismatch at '"..funcname.."' ('"..arg[i+2].."'). Expected '"..table.concat(arg[i], "' or '").."', got '"..aType.."'.", 3)
            end
        elseif (type(arg[i+1]) ~= arg[i]) then
            error("Argument type mismatch at '"..funcname.."' ('"..arg[i+2].."'). Expected '"..arg[i].."', got '"..type(arg[i+1]).."'.", 3)
        end
    end
end

local gWeekDays = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
function FormatDate(format, escaper, timestamp)
	Check("FormatDate", "string", format, "format", {"nil","string"}, escaper, "escaper", {"nil","string"}, timestamp, "timestamp")

	escaper = (escaper or "'"):sub(1, 1)
	local time = getRealTime(timestamp)
	local formattedDate = ""
	local escaped = false

	time.year = time.year + 1900
	time.month = time.month + 1

	local datetime = { d = ("%02d"):format(time.monthday), h = ("%02d"):format(time.hour), i = ("%02d"):format(time.minute), m = ("%02d"):format(time.month), s = ("%02d"):format(time.second), w = gWeekDays[time.weekday+1]:sub(1, 2), W = gWeekDays[time.weekday+1], y = tostring(time.year):sub(-2), Y = time.year }

	for char in format:gmatch(".") do
		if (char == escaper) then escaped = not escaped
		else formattedDate = formattedDate..(not escaped and datetime[char] or char) end
	end

	return formattedDate
end

-- sensitive data
function isSensitiveDataHidden()
	return isElement(aTab1.HideSensitiveData) and guiCheckBoxGetSelected(aTab1.HideSensitiveData)
end

function setHideSensitiveData( bOn )
	guiCheckBoxSetSelected ( aTab1.HideSensitiveData, bOn )
	aSetSetting ( "currentHideSensitiveDataState", bOn )
	aAdminReloadInfos()
end

function getSensitiveText(text)
	if isSensitiveDataHidden() then
		return ('*'):rep(utf8.len(text))
	end
	return text
end

-- hide color codes
function isColorCodeHidden()
	return guiCheckBoxGetSelected ( aTab1.HideColorCodes )
end

function setHideColorCodes( bOn )
	guiCheckBoxSetSelected ( aTab1.HideColorCodes, bOn )
	aSetSetting ( "currentHideColorCodesState", bOn )
	updateColorCodes()
	aAdminReloadInfos()
end

function loadFlagImage( guiStaticImage, countryCode )
	if countryCode then
		local flagFilename = "client\\images\\flags\\"..tostring ( countryCode )..".png"
		if getVersion().sortable and getVersion().sortable > "1.1.0" then
			-- 1.1
			if fileExists( flagFilename ) then
				if guiStaticImageLoadImage ( guiStaticImage, flagFilename ) then
					return
				end
			end
		else
			-- 1.0
			guiStaticImageLoadImage ( guiStaticImage, "client\\images\\empty.png" )
			guiStaticImageLoadImage ( guiStaticImage, flagFilename )
			return
		end
	end
	guiStaticImageLoadImage ( guiStaticImage, "client\\images\\empty.png" )
end
