function ShowUI( state, data )
	if state then
		ShowUI( false )
		showCursor( true )
		confirmation = ibConfirm(
			{
				title = "ПРОДАЖА ГОСУДАРСТВУ", 
				text = ( "Вы действительно хотите продать государству\n%s за %s р.?" ):format( GetVehicleNameFromModel( data.vehicle.model ), format_price( data.cost ) ),
				fn = function( self ) 
					self:destroy()
					if not data.is_inventory_empty then
						ConfirmInventoryReset( data )
					else
						RequestVehicleSell( data )
					end
				end,
				fn_cancel = function( self )
					showCursor( false )
					self:destroy()
				end,
				escape_close = true,
			}
		)

	else
		if confirmation then showCursor( false ) confirmation:destroy() end
	end
end
addEvent( "CarsellToGovernment_ShowUI", true )
addEventHandler( "CarsellToGovernment_ShowUI", root, ShowUI )

function ConfirmInventoryReset( data )
	if confirmation then confirmation:destroy( ) end
	confirmation = ibConfirm(
		{
			title = "ПРОДАЖА ГОСУДАРСТВУ",
			text = "Предметы в багажнике будут уничтожены",
			fn = function( self )
				self:destroy( )
				RequestVehicleSell( data )
			end,
			escape_close = true,
		}
	)
end

function RequestVehicleSell( data )
	showCursor( false )
	triggerServerEvent( "onCarsellToGovernmentVehicleSell", localPlayer, data.vehicle )
end