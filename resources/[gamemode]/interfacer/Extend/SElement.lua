Element.SetFaction = function(self, faction)
	return self:setData("m_eFaction", faction)
end

Element.PlaySound = function(self, ...)
	return exports.nrp_handler_sound:SoundCreateSource(self, ...)
end

Element.StopSound = function(self, ...)
	return exports.nrp_handler_sound:SoundDestroySource(self, ...)
end

Element.ShowNotification = function( self, text )
	triggerClientEvent( "ShowInfo", self, text )
end