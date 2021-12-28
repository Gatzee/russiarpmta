function SyncSingleElementData_handler( key, value )
	setElementData( localPlayer, key, value, false )
end
addEvent( "_sdata", true )
addEventHandler( "_sdata", root, SyncSingleElementData_handler )

function SyncBatchElementData_handler( list )
	for i, v in pairs( list ) do
		setElementData( localPlayer, i, v, false )
	end
end
addEvent( "_bdata", true )
addEventHandler( "_bdata", root, SyncBatchElementData_handler )
