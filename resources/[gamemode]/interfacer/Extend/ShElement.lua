Element.GetFaction = function(self)
	return self:getData("m_eFaction")
end

Element.GetRPBOXJob = function(self)
	return self:getData("m_iJob")
end

Element.DistanceTo = function(self, element)
	return (self.position - element.position):getLength()
end