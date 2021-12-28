loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShVehicleConfig" )
Extend( "CVehicle" )

local IGNORED_VEHICLES = {}

local IGNORED_ZONES = 
{
	{
		1238.0509033203,-339.20861816406;
		1256.1643066406,-355.72610473633;
		1286.3391113281,-314.92651367188;
		1341.0208740234,-159.54632568359;
		1299.91796875,-136.47271728516;
		1238.0509033203,-339.20861816406;
	},

	{
		1379.5366210938,-874.15692138672;
		1370.0793457031,-909.62213134766;
		1595.6435546875,-913.46716308594;
		1576.3039550781,-847.51342773438;
	},

	{
		-1151.9616699219,-347.63656616211;
		-1072.5831298828,-388.49411010742;
		-1044.4154052734,17.728645324707;
		-1159.1817626953,6.8108358383179;
		-1151.9616699219,-347.63656616211;
	},
}

local IGNORED_ZONES_REVERSE = {}

for k,v in pairs(IGNORED_ZONES) do
	local col = createColPolygon( unpack(v) )
	IGNORED_ZONES_REVERSE[col] = true
end

local ALLOWED_COL_ELEMENTS = {
	vehicle = true,
	player = true,
}

local VEH_TIMERS = { }

addEventHandler("onClientVehicleCollision", root, function( element )
	if not element or not ALLOWED_COL_ELEMENTS[ getElementType( element ) ] then return end
	if IGNORED_VEHICLES[source] or IGNORED_VEHICLES[element] then return end

	for k,v in pairs(IGNORED_ZONES_REVERSE) do
		if isElementWithinColShape( source, k ) then
			setElementFrozen( source, false )
			return
		end
	end

	local players_in_vehicle = 0
	for _, _ in pairs( getVehicleOccupants( source ) ) do
		players_in_vehicle = players_in_vehicle + 1
	end
	if players_in_vehicle >= 1 then return end

	if IsSpecialVehicle( source.model ) then return end

	local iOwnerID = source:GetOwnerID()

	if iOwnerID then
		local pOwner = GetPlayer(iOwnerID, true)
		if pOwner then
			if getPedOccupiedVehicle( pOwner ) ~= source then
				setElementFrozen( source, true )
				unfreezeAfterTime( source )
				return
			end
		end
	else
		local pOccupants = getVehicleOccupants( source )
		local cnt = 0
		for k,v in pairs(pOccupants) do
			cnt = cnt + 1 
		end

		if cnt <= 0 then
			setElementFrozen( source, true )
			unfreezeAfterTime( source )
			return
		end
	end

	if not getElementData( source, "bStatic" ) then
		setElementFrozen(source, false)
		if isTimer( VEH_TIMERS[ source ] ) then killTimer( VEH_TIMERS[ source ] ) end
		VEH_TIMERS[ source ] = nil
	end
end)

addEventHandler( "onClientVehicleEnter", root, function( pPlayer )
	if IGNORED_VEHICLES[source] then return end
	if isTimer( VEH_TIMERS[ source ] ) then killTimer( VEH_TIMERS[ source ] ) end
	if not getElementData( source, "bStatic" ) then
		setElementFrozen(source, false)
	end
end)

function unfreezeAfterTime( vehicle )
	if isTimer( VEH_TIMERS[ vehicle ] ) then killTimer( VEH_TIMERS[ vehicle ] ) end
	if not getElementData( vehicle, "bStatic" ) then
		VEH_TIMERS[ vehicle ] = Timer( 
			function( vehicle )
				vehicle.frozen = false
				removeEventHandler( "onClientElementDestroy", vehicle, onVehicleDestroy )
			end
		, 1000, 1, vehicle )
		removeEventHandler( "onClientElementDestroy", vehicle, onVehicleDestroy )
		addEventHandler( "onClientElementDestroy", vehicle, onVehicleDestroy )
	end
end

function onVehicleDestroy( )
	if isTimer( VEH_TIMERS[ source ] ) then killTimer( VEH_TIMERS[ source ] ) end
	VEH_TIMERS[ source ] = nil
	IGNORED_VEHICLES[ source ] = nil
end

addEvent("OnClientVehiclePropertiesChanged", true)
addEventHandler("OnClientVehiclePropertiesChanged", root, function( pData )
	if pData.br_vehicle then
		if isTimer( VEH_TIMERS[ source ] ) then killTimer( VEH_TIMERS[ source ] ) end
		setElementFrozen(source, false)
		IGNORED_VEHICLES[source] = true
	end
end)