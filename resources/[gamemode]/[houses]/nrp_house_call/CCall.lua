loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CPlayer" )
Extend( "ib" )

local house_call_ticks = {}

function onClientPlayerCallHouse_handler( player, id, number )
	if not isElement( player ) then return end
	if confirmation then confirmation:destroy( ) end

	showCursor( true )

	playSound( "files/door_bell.mp3" )

	confirmation = ibConfirm( 
		{
			title = "ЗВОНОК В ДОМОФОН", 
			text = "Впустить игрока "..player:GetNickName( ).." ?",
			fn = function( self ) 
				self:destroy( )
				showCursor( false )
				if not isElement( player ) then return end
				triggerServerEvent( "onPlayerHouseCallConfirm", player, id, number )
			end,

			fn_cancel = function( self ) 
				showCursor( false ) 
			end,
			escape_close = true,
		}
	 )
end
addEvent( "onClientPlayerCallHouse", true )
addEventHandler( "onClientPlayerCallHouse", root, onClientPlayerCallHouse_handler )

function onClientPlayerNeedCallHouse_handler( id, number )
	if confirmation then confirmation:destroy( ) end

	showCursor( true )

	confirmation = ibConfirm( 
		{
			title = "ЗАПЕРТО", 
			text = "Позвонить в дверь?",
			fn = function( self ) 
				self:destroy( )
				showCursor( false )

				if not house_call_ticks[ id ] then
					house_call_ticks[ id ] = {}
				end
				if getTickCount() - ( house_call_ticks[ id ][ number ] or 0 ) < 120000 then
					localPlayer:ShowError( "Позвонить можно раз в 2 мин." )
					return
				end
				house_call_ticks[ id ][ number ] = getTickCount()

				playSound( "files/door_bell.mp3" )
				
				if id == 0 then
					triggerServerEvent( "PlayerWantCallVipHouse", resourceRoot, number )
				else
					triggerServerEvent( "PlayerWantCallApartment", resourceRoot, id, number )
				end
			end,

			fn_cancel = function( self ) 
				showCursor( false ) 
			end,
			escape_close = true,
		}
	 )
end
addEvent( "onClientPlayerNeedCallHouse", true )
addEventHandler( "onClientPlayerNeedCallHouse", root, onClientPlayerNeedCallHouse_handler )