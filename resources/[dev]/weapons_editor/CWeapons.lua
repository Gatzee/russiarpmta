loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "Globals" )
Extend( "CPlayer" )

local UI = { }

--Храним это тут, а не при передаче в функцию, для того чтобы потом сравнивать какие данные были изменены(чтобы не отправлять всю таблицу назад)
local weaponProperties = {}
local weaponFlags = {}
local selectedSkill
local selectedWeapon
function cursor( )
	showCursor( not isCursorShowing() )
end

function createScrollpane( properties )
	if not UI.bg then return end
	if UI.scrollpane and isElement( UI.scrollpane ) then destroyElement( UI.scrollbar ) destroyElement( UI.scrollpane ) end

	UI.scrollpane, UI.scrollbar = ibCreateScrollpane( 10, 70, 380, 320, UI.bg, { scroll_px = -2, bg_color = 0xFF315168 } )
	UI.scrollbar:ibSetStyle( "slim_nobg" )

	ibCreateImage( 0, 0, 165, 40, nil, UI.scrollpane, 0xFF315168 )
	ibCreateLabel( 0, 0, 165, 40, "Название", UI.scrollpane, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )

	ibCreateImage( 175, 0, 200, 40, nil, UI.scrollpane, 0xFF315168 )
	ibCreateLabel( 175, 0, 200, 40, "Значение", UI.scrollpane, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )

	local iterator = 1
	for i, v in pairs( weaponProperties ) do 
		local y =  iterator * 50


		ibCreateImage( 0, y, 165, 40, nil, UI.scrollpane, 0xFF315168 )
		ibCreateLabel( 0, y, 165, 40, i, UI.scrollpane, 0xFFFFFFFF, _, _, "center", "center", ibFonts.regular_10 )
		
		ibCreateImage( 175, y, 200, 40, nil, UI.scrollpane, 0xFF315168 )
		UI[ i ] = ibCreateEdit( 180, y, 165, 40, v, UI.scrollpane, 0xFFFFFFFF, 0xFF315168, 0xFFFFFFFF ):ibData( "id", i )

		iterator = iterator + 1
	end

	if next( weaponFlags ) then
		ibCreateLabel( 0, iterator * 50, 380, 40, "Флаги", UI.scrollpane, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_15 )
		iterator = iterator + 1
	end
	local emptyFunction = function() return true end
	for i,v in pairs( weaponFlags ) do 
		local y = iterator * 50

		ibCreateImage( 0, y, 270, 40, nil, UI.scrollpane, 0xFF315168 )
		ibCreateLabel( 10, y, 260, 40, i, UI.scrollpane, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 )
		
		UI[ i ] = ibCreateSlider( 190 , y + 5, UI.scrollpane, emptyFunction, v )

		iterator = iterator + 1
	end

	UI.scrollpane:AdaptHeightToContents()
	UI.scrollbar:UpdateScrollbarVisibility( UI.scrollpane )
end
function onWindowClose()
	if UI.windowSelect and isElement( UI.windowSelect ) then destroyElement( UI.windowSelect ) return end 
	destroyElement( UI.bg ) 
	showCursor( false ) 
end
function applyChanges()
	if not next( weaponProperties ) or not next( weaponFlags ) then return end
	local sendProperties = {}
	local sendFlags = {}

	for i,v in pairs( weaponProperties ) do 
		local currentValue = UI[ i ]:ibData( "text" )
		if v ~= currentValue then sendProperties[ i ] = currentValue end

	end
	iprint(sendProperties)
	for i,v in pairs( weaponFlags ) do 
		local currentValue = UI[ i ]:ibData( "active" )
		if v ~= currentValue then sendFlags[ i ] = currentValue end
	end
	triggerServerEvent( "onWeaponStatsEdit", localPlayer, selectedWeapon, selectedSkill, sendProperties, sendFlags )
end
function onSkillSelect( button, state )
	if button == "left" and state == "down" then

		selectedSkill = source:ibData( "text" )
		outputDebugString(selectedSkill)
		if UI.needToSelectSkillLabel and isElement( UI.needToSelectSkillLabel ) then destroyElement( UI.needToSelectSkillLabel ) return end 
	end
end
function ToggleWeaponSelect()
	if UI.windowSelect and isElement( UI.windowSelect ) then destroyElement( UI.windowSelect ) return end 

	UI.windowSelect = ibCreateImage( UI.bg:ibGetAfterX( 35 ), 0, 300, 500, nil, nil, 0xFF385B74 ):center_y()

	UI.wpnHeader_bg = ibCreateImage( 0, 0, 300, 60, nil, UI.windowSelect, 0xFF315168 )
	ibCreateLabel( 0, 0, 300, 60, "Выбор оружия", UI.wpnHeader_bg, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_15 )
	UI.wpnHorizontal_line = ibCreateImage( 0, 61, 300, 1, nil, UI.wpnHeader_bg, 0xFF476378 )

	UI.wpnScrollpane, UI.wpnScrollbar = ibCreateScrollpane( 10, 70, 280, 320, UI.windowSelect, { scroll_px = -2, bg_color = 0xFF315168 } )
	UI.wpnScrollbar:ibSetStyle( "slim_nobg" )

	ibCreateImage( 0, 0, 280, 40, nil, UI.wpnScrollpane, 0xFF315168 )
	ibCreateLabel( 0, 0, 280, 40, "ID - Название", UI.wpnScrollpane, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )

	local iterator = 1
	selectedSkill = nil
	for i, v in pairs( WEAPONS_LIST ) do 
		local y =  iterator * 50
		
		ibCreateImage( 0, y, 280, 40, nil, UI.wpnScrollpane, 0xFF315168 )
		ibCreateLabel( 0, y, 280, 40, i.." - "..v.Name, UI.wpnScrollpane, 0xFFFFFFFF, _, _, "center", "center", ibFonts.regular_10 ):ibData( "id", i )
			:ibOnClick( function( button, state )
				if button == "left" and state == "down" then

					ibClick()
					if not selectedSkill then localPlayer:ShowWarning( "Сначала нужно выбрать скилл" )  return end
					local weaponID = source:ibData( "id" )
					selectedWeapon = weaponID
					triggerServerEvent( "onWeaponEditorRequest", localPlayer, weaponID, selectedSkill )
					onWindowClose()
				end
			end )
		iterator = iterator + 1
	end

	UI.wpnScrollpane:AdaptHeightToContents()
	UI.wpnScrollbar:UpdateScrollbarVisibility( UI.wpnScrollpane )

	UI.needToSelectSkillLabel = ibCreateLabel( 0, 390, 300, 60, "Нужно выбрать скилл", UI.windowSelect, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_12 )

	UI.btnSkillPoor = ibCreateArea( 10, 435, 60, 40, UI.windowSelect )
	ibCreateImage( 0, 0, 60, 40, nil, UI.btnSkillPoor, 0xFF315168 )
	ibCreateLabel( 0, 0, 60, 40, "poor", UI.btnSkillPoor, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 ):ibOnClick( onSkillSelect )

	UI.btnSkillStd = ibCreateArea( 120, 435, 60, 40, UI.windowSelect )
	ibCreateImage( 0, 0, 60, 40, nil, UI.btnSkillStd, 0xFF315168 )
	ibCreateLabel( 0, 0, 60, 40, "std", UI.btnSkillStd, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 ):ibOnClick( onSkillSelect )

	UI.btnSkillPro = ibCreateArea( 230, 435, 60, 40, UI.windowSelect )
	ibCreateImage( 0, 0, 60, 40, nil, UI.btnSkillPro, 0xFF315168 )
	ibCreateLabel( 0, 0, 60, 40, "pro", UI.btnSkillPro, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 ):ibOnClick( onSkillSelect )
	
end
addCommandHandler( "weapons", function( ) 
	--Если меню уже отображается, то закрываем его
	if UI.bg and isElement( UI.bg ) then onWindowClose() return end 

	showCursor( true )

	UI.bg = ibCreateImage( 0, 0, 400, 500, nil, nil, 0xFF385B74 ):center( )
	--<Header>
	UI.header_bg = ibCreateImage( 0, 0, 400, 60, nil, UI.bg, 0xFF315168 )
	ibCreateLabel( 0, 0, 400, 60, "Редактор оружия", UI.header_bg, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_15 )
	UI.horizontal_line = ibCreateImage( 0, 61, 400, 1, nil, UI.header_bg, 0xFF476378 )
	--</Header>

	createScrollpane( )

	--<Buttons>
	UI.btnExit = ibCreateArea( 10, 435, 100, 40, UI.bg )
	ibCreateImage( 0, 0, 100, 40, nil, UI.btnExit, 0xFF315168 )
	ibCreateLabel( 0, 0, 100, 40, "Выход", UI.btnExit, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )
		:ibOnClick( function( button, state )
			if button == "left" and state == "down" then

				ibClick()
				onWindowClose()
			end
		end )

	UI.btnSelect = ibCreateArea( 130, 435, 140, 40, UI.bg )
	ibCreateImage( 0, 0, 140, 40, nil, UI.btnSelect, 0xFF315168 )
	ibCreateLabel( 0, 0, 140, 40, "Выбрать оружие", UI.btnSelect, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )
		:ibOnClick( function( button, state )
			if button == "left" and state == "down" then

				ibClick()
				ToggleWeaponSelect()
			end
		end )

	UI.btnApply = ibCreateArea( 290, 435, 100, 40, UI.bg )
	ibCreateImage( 0, 0, 100, 40, nil, UI.btnApply, 0xFF315168 )
	ibCreateLabel( 0, 0, 100, 40, "Применить", UI.btnApply, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 )
		:ibOnClick( function( button, state )
			if button == "left" and state == "down" then

				ibClick()
				applyChanges()
			end
		end )
	--</Buttons>
end )

addEvent( "onWeaponEditorResponse", true )
addEventHandler( "onWeaponEditorResponse", root, function( propertiesTable, flagsTable )  
	if not UI.bg then return end

	weaponProperties = propertiesTable
	weaponFlags = flagsTable

	createScrollpane()
end )