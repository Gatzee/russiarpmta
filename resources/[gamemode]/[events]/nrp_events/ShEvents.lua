loadstring( exports.interfacer:extend( "Interfacer" ) )( )

REGISTERED_EVENTS = { }

AddCustomServerEventHandler = function( self, name, handler )
	local event_name = self.event_id .."_".. name

	self.events[ event_name ] = function( lobby_id, ... )
		if not client then return end
		if self.lobby_id ~= lobby_id then return end

		handler( self, ... )
	end;

	addEvent( event_name, true )
	addEventHandler( event_name, resourceRoot, self.events[ event_name ] )
end

RemoveCustomServerEventHandler = function( self, name )
	local event_name = self.event_id .."_".. name
	if self.events[ event_name ] then
		removeEventHandler( event_name, resourceRoot, self.events[ event_name ] )
		self.events[ event_name ] = nil
	end
end

TriggerCustomServerEvent = function( name, ... )
	triggerServerEvent( CURRENT_EVENT_ID .."_".. name, resourceRoot, CURRENT_EVENT_LOBBY_ID, ... )
end