loadstring(exports.interfacer:extend("Interfacer"))()
Extend("ShUtils")
Extend("Globals")

LINES = {}
STOPS = {}

addEventHandler( "onClientResourceStart", getRootElement(),
    function ()
        addEventHandler("onClientRender", root, refreshLines);
    end
);


function record_start()
	record_pause()
	addEventHandler("onClientRender", root, renderRecord)
end
addCommandHandler("rs", record_start)


function record_pause()
	removeEventHandler("onClientRender", root, renderRecord)
end
addCommandHandler("rp", record_pause)

function record_del(_, n)
	record_pause()
	local n = tonumber(n) or 1
	for i=1, n do
		local pos = #LINES
		table.remove(LINES, pos)
		STOPS[pos] = nil
	end
end
addCommandHandler("rd", record_del)

function record_clear()
	record_pause()
	LINES = {}
	STOPS = {}
end
addCommandHandler("rc", record_clear)

LAST_IS_STOP = nil
function renderRecord()
	local last_position = LINES[#LINES]
	if not localPlayer.vehicle then return end
	dxDrawText( "Текущая длина: " .. #LINES .. " м.", 0, 0 )
	local position = localPlayer.vehicle.position
	local is_stop = localPlayer.vehicle.velocity:getLength() <= 0.001
	if last_position then
		local distance = last_position:distance(position)
		if distance < 1.5 then 
			if LAST_IS_STOP and is_stop or not is_stop then
				return 
			end
		end
	end
	LAST_IS_STOP = is_stop
	table.insert(LINES, position)
	if is_stop then 
		--STOPS[#LINES] = true 
		--iprint("ОСТАНОВКА НА ТОЧКЕ: ", #LINES)
	end
end

function record_bus_stop()
	STOPS[#LINES] = not STOPS[#LINES]
	--iprint("ОСТАНОВКА НА ТОЧКЕ: ", #LINES, STOPS[#LINES])
end
addCommandHandler("rstop", record_bus_stop)


function refreshBusLines ( aVectors )
	LINES = aVectors;
end
addEvent("onRefreshBusLines", true)
addEventHandler("onRefreshBusLines", getRootElement(), refreshBusLines)

function refreshLines ( )
	for key,value in pairs(LINES) do
		local pStartData	= LINES[ key ];
		local pEndData		= LINES[ key + 1 ];

		if pStartData and pEndData then
			local color = STOPS[key] and 0xffff0000 or 0xff00ff00
			dxDrawLine3D ( pStartData, pEndData, color, 25);
		end
	end
end

function exportBusLines( _, ...)
	local name = table.concat( { ... }, " " )
	if utf8.len( name ) <= 0 then
		outputChatBox( "Ошибка: /rexport <название>", 255, 0, 0 )
		return
	end
	local name = name .. ".txt"
	local fileHandle = fileCreate(name)            
	if fileHandle then
		fileFlush(fileHandle)	
		for key,value in pairs(LINES) do
			if STOPS[key] then
				fileWrite(fileHandle, table.concat({ value.x, ",", value.y, ",", value.z, ",true\n"}, '') )
			else
				fileWrite(fileHandle, table.concat({ value.x .. "," .. value.y .. "," .. value.z .. "\n" }, '') )
			end
		end
		fileClose(fileHandle)                             
	end
	outputChatBox( "Экспортировано в файл: " .. name, 255, 0, 0 )
end
addCommandHandler("rexport", exportBusLines)

function importBusLines()
	local hFile = fileOpen("data.txt")             -- attempt to open the file
	if hFile then                                  -- check if it was successfully opened
		local text = ""
		local buffer
		while not fileIsEOF(hFile) do              -- as long as we're not at the end of the file...
			buffer = fileRead(hFile, 500)          -- ... read the next 500 bytes...
			text = text .. buffer
		end
		fileClose(hFile)                           -- close the file once we're done with it

		LINES = {}

		for l in string.gmatch(text, "[^\n]+") do
			local pData = {}
			local x, y, z = string.match(l, '.*Vector3%((.*),(.*),(.*)%).*')
			pData[1] = tonumber(x)
			pData[2] = tonumber(y)
			pData[3] = tonumber(z)
			if string.find(l, "m_bStop") then
				pData[4] = true
			end

			table.insert( LINES, pData )
		end

		triggerServerEvent( "onRefreshBusLines", getRootElement(), LINES)
	else
		outputConsole("Unable to open data.txt")
	end 
end
addCommandHandler("rpb_import", importBusLines)

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end