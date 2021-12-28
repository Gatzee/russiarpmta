Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

ibUseRealFonts( true )

UI_elements = {}
SLOT_MACHINE_INTERFACE = {}

function OnSlotMachineMarkerTriggered_handler( casino_id, game_id, data )
	UI_elements.casino_id = casino_id
	ShowSlotMachineStatsMenu( true, casino_id, game_id, data )
	triggerServerEvent( "onServerSlotMachinePreStart", resourceRoot, casino_id, game_id )
end
addEvent( "onSlotMachineMarkerTriggered", true )
addEventHandler( "onSlotMachineMarkerTriggered", root, OnSlotMachineMarkerTriggered_handler )

function StartSlotMachineGame( game_id )
	ShowInterface_Handler( true, game_id )
	UI_elements.game_statement = { running = false, bet = BETS[ UI_elements.casino_id ][ 1 ], autoplay = false }
end

function PreInvokePlay( )
	if UI_elements.game_statement.running then return end
	UI_elements.game_statement.running = true
	
	UI_elements.game_statement.bet = GetCurrentBetIndex()
	if localPlayer:GetMoney( ) - BETS[ UI_elements.casino_id ][ UI_elements.game_statement.bet ] < 0 then 
		UI_elements.game_statement.autoplay = false
		UI_elements.game_statement.running = false
		localPlayer:ShowError( "Недостаточно денег" ) 
		return false
	end
	
	if isElement( UI_elements.dummy ) then
		destroyElement( UI_elements.dummy )
	end

	triggerServerEvent( "onServerCasinoSlotMachinePlay" , resourceRoot, UI_elements.game_statement.bet )
end

function InvokePlay( game_id, result_items, winning_amount )
	RemoveOldPanels( )

	local conf = { game_string_id = CASINO_GAME_STRING_IDS[ game_id ] }
	CreateNewPanels( conf, result_items )

	local combination_coeff, combination_data = CalculateCombinationsCoefficient( game_id, result_items )
	local winning_slots = GetWinningSlots( result_items, combination_data )

	StartAnimation( )
	StartLazyLoading( conf )
	StartSpinSound( )
	UI_elements.black_bg:ibTimer( OnScrollFinished, 3700, 1, conf, winning_amount, combination_coeff, winning_slots )
end
addEvent( "onCasinoSlotMachineGenerated", true )
addEventHandler( "onCasinoSlotMachineGenerated", resourceRoot, InvokePlay )

function GetWinningSlots( result_items, combination_data )
	local result = {}
	for k, v in pairs( result_items ) do
		if v.id == combination_data.id then
			table.insert( result, k )
			if #result == combination_data.count then break end
		else
			result = {}
		end
	end	
	return result
end

function GetCurrentBetIndex()
	if not UI_elements.bet then return end
	
	local text = string.gsub( UI_elements.bet:ibData( "text" ), "%s+", "" )
	local bet = tonumber( text )
	for i, v in pairs( BETS[ UI_elements.casino_id ] ) do 
		if bet == v then return i, v end
	end
end

function CreateNewPanels( conf, results_row )
	for i = 1, 5 do 
		table.insert( UI_elements.rows_of_panels, i, CreateItemsPane( conf, i - 1, results_row[ i ] ) )
	end
end

function RemoveOldPanels( )
	for i = 1, 5 do 
		destroyElement( UI_elements.rows_of_panels[ i ].items_pane )
		UI_elements.rows_of_panels[ i ] = nil
	end
end

function StartLazyLoading( conf )
	for i = 1, 5 do 
		UI_elements.rows_of_panels[ i ].itemCounter = 4
		--lazy loading
		UI_elements.rows_of_panels[ i ].items_pane:ibTimer( function( self )
			local itemCount = UI_elements.rows_of_panels[ i ].itemCounter
			for j = itemCount, itemCount + 3 do
				local item_id = math.random( 1, #REGISTERED_ITEMS )
				--Если предмет сгенерился успешно, и номер ряда не равен нашему уже существующему исходящему, то рендерим новый предмет
				if item_id and j ~= 98 then
					table.insert( UI_elements.rows_of_panels[ i ].items, CreateScrollItem( conf,  item_id, 0, (j * 198) * cfY, self ) )
				end
				--был бы callback у таймера, можно было бы засунуть это туда
				if j == 99 then self:AdaptHeightToContents( ) end
			end
			UI_elements.rows_of_panels[ i ].itemCounter = itemCount + 4
		end, 80, 24 )
		
		--lazy unloading?
		UI_elements.rows_of_panels[ i ].items_pane:ibTimer( function( self )
			local children = self:getChildren( )
			--Удаляем второй элемент из-за того что всегда первым будет наша исходная комбинация
			destroyElement( children[ 2 ] )
		end, 81, 97 )
	end
end

function StartAnimation( )
	for i = 1, 5 do
		local duration = 3000 + ( i - 1 ) * 500
		UI_elements.rows_of_panels[ i ].scroll_v:ibScrollTo( 0.9975, duration, "Linear" )
		UI_elements.rows_of_panels[ i ].scroll_v:ibTimer( StartSlotSound, duration - 50, 1 )
	end
end

function OnScrollFinished( self, conf, winning_amount, combination_coeff, winning_slots )
	if combination_coeff then
		UI_elements.dummy = ibCreateArea( 0, 0, 0, 0, UI_elements.black_bg )
		UI_elements.dummy:ibTimer( function()
			for k, v in pairs( winning_slots ) do
				for j = 1, 2 do 
					UI_elements.rows_of_panels[ v ].item:ibTimer( function( self )
						self:ibAlphaTo(	j % 2 ==0 and 255 or 100, 500 )
					end, (j - 1) * 500, 1 )
				end
			end
		end, 1000, 0 )

		UI_elements.btn_autoplay:ibTimer( function()
			if combination_coeff >= 3 then
				OffAutoPlayUI()
				UI_elements.game_statement.autoplay = false 
			end

			ShowSuccess( nil, nil, true, winning_amount )
		end, 1500, 1)
	end

	UI_elements.window:ibTimer( function()
		UI_elements.game_statement.running = false
		StopSpinSound()
	end, 1500, 1 )

	if UI_elements.game_statement.autoplay then
		UI_elements.black_bg:ibTimer( function()
			if not UI_elements.game_statement.autoplay then return end
			PreInvokePlay()
		end, 2000, 1 )
	end
end

function CreateScrollItem( conf, item_id, pos_x, pos_y, bg )
	local item = ibCreateImage( pos_x, pos_y, 0, 0, "img/games/" .. conf.game_string_id .. "/machine/variations/" .. item_id .. ".png", bg )
	:ibSetRealSize()
	item:ibBatchData( { sx = item:ibData("sx") * cfX, sy = item:ibData("sy") * cfY } )
	return item
end

function CreateItemsPane( conf, column_id, generated_item )
	local row = {}
	row.items = {}

	row.items_pane, row.scroll_v = ibCreateScrollpane( column_id * 197 * cfX, 0, 178 * cfX, 485 * cfY, UI_elements.scoll_pane_background )

	row.item = CreateScrollItem( conf, generated_item.id, 0, (98 * 198) * cfY, row.items_pane )
	for i = 0, 3 do
		local item_id = math.random( 1, #REGISTERED_ITEMS )
		table.insert( row.items, CreateScrollItem( conf, item_id, 0, i * 198 * cfY, row.items_pane ) )
	end
	
	row.items_pane:AdaptHeightToContents( )
	row.scroll_v:ibBatchData( { position = 0.00215, sensivity = 0, visible = false } )
	
	return row
end