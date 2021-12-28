function setHealth ()

	for i,veh in ipairs(getElementsByType("vehicle")) do

	local health = getElementHealth(veh)/8

		if health < 30 then

			setElementHealth( veh, 38*8 )

		end

	end

end

addEventHandler("onClientRender",root,setHealth)