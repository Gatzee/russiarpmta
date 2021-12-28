addEventHandler( "onResourceStart", getRootElement(),
    function ()
		outputDebugString("START RESOURCE BUS CREATOR");
    end
);

g_vecLines = {};

addEvent( "onRefreshBusLines", true )
addEventHandler("onRefreshBusLines", getRootElement(), function( aVectors )
	g_vecLines = aVectors
end)


function createBusLine ( source, _, is_bus_stop )
	if ( source ) then
		local m_bool = is_bus_stop == "true" or false;
		local m_vehPostion = Vector3(getElementPosition(getPedOccupiedVehicle(source)));
		local m_pData = {};
		table.insert(m_pData, m_vehPostion.x)
		table.insert(m_pData, m_vehPostion.y)
		table.insert(m_pData, m_vehPostion.z)
		table.insert(m_pData, m_bool)
		table.insert(g_vecLines, m_pData)
		triggerClientEvent(source, "onRefreshBusLines", source, g_vecLines)
	end
end
addCommandHandler ( "rpb_b_add", createBusLine )

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function removeBusLine ( source )
	if ( source ) then
		local iCount = tablelength(g_vecLines);
		table.remove(g_vecLines, iCount)
		triggerClientEvent(source, "onRefreshBusLines", source, g_vecLines)
	end
end
addCommandHandler ( "rpb_b_remove", removeBusLine )