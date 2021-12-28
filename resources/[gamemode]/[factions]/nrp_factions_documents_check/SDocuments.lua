loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )

local REQUEST_TIMEOUTS = { 15, 10, 15 }
local ACTUALITY_EXPIRES_IN = 2 -- Как долго нельзя спрашивать документы с моменты последнего предъявления (минуты)

local pRequestsSent = {}
local pNextRequestAvailable = {}
local pWantedTimer = {}

function OnPlayerTryRequestDocuments( pTarget )
	local iNextRequestAvailable = pNextRequestAvailable[source] or 0
	if iNextRequestAvailable >= getTickCount() then
		source:ShowError( "Нельзя предъявлять требования так часто" )
		return false
	end

	local pData = pRequestsSent[pTarget] or {false, 0, 0, false}

	if pData[4] and pData[4] ~= source then
		-- Если у игрока уже потребовал документы кто-то другой
		source:ShowError( "Кто-то другой уже запросил документы этого гражданина" )
		return false
	end

	if pData[1] then
		if pData[3] >= getTickCount() then
			-- Документы уже спрашивали недавно
			source:ShowError("Этот гражданин уже показывал свои документы")
			return false
		else
			-- Сбрасываем данные
			pData = {false, 0, 0, false}
		end
	end

	pData[4] = source
	pData[2] = math.min( pData[2] + 1, #REQUEST_TIMEOUTS )
	pRequestsSent[pTarget] = pData

	pNextRequestAvailable[source] = getTickCount() + REQUEST_TIMEOUTS[ pData[2] ] * 1000

	outputChatBox("Вы потребовали #22dd22"..pTarget:GetNickName().."#ffffff предъявить Вам документы.", source, 255,255,255, true)
	outputChatBox("Сотрудник полиции #22dd22"..source:GetNickName().."#ffffff просит Вас предъявить документы", pTarget, 255,255,255, true)
	
	triggerEvent( "OnPlayerRequestDocuments", source, pTarget )

	-- Последнее предупреждение
	if pData[2] == 3 then
		outputChatBox("#dd2222ПОСЛЕДНЕЕ ПРЕДУПРЕЖДЕНИЕ. #ddddddНеподчинение будет рассматриваться как нарушение закона.", pTarget, 255,255,255, true)
		pWantedTimer[pTarget] = setTimer( function( pSource, pPlayer )
			if isElement(pPlayer) then
				pPlayer:AddWanted("1.8", _, true)
				pPlayer:ShowInfo( "Вы отказались подчиняться требованиям сотрудника полиции" )
				
				if isElement( pSource ) then
					pSource:ShowInfo( "Гражданин отказался подчиняться, сопроводите его в участок." )
				end
			end 
		end, REQUEST_TIMEOUTS[ pData[2] ]*1000, 1, source, pTarget)
	else
		pWantedTimer[pTarget] = setTimer( function( pSource, pPlayer )
			if isElement(pSource) and isElement(pPlayer) then
				pSource:ShowInfo( "Гражданин проигнорировал Ваше требование, запросите документы снова" )
			end 
		end, REQUEST_TIMEOUTS[ pData[2] ]*1000, 1, source, pTarget)
	end
end
addEvent("OnPlayerTryRequestDocuments", true)
addEventHandler("OnPlayerTryRequestDocuments", root, OnPlayerTryRequestDocuments)

function OnPassportShowRequest_handler( pTarget )
	if isElement(pTarget) then
		triggerClientEvent( pTarget, "OnPlayerReceiveWantedData", source, source:GetWantedData( true ) )

		if pRequestsSent[source] then
			if pTarget == pRequestsSent[source][4] then
				triggerClientEvent( pTarget, "PlayerAction_PassportShowSuccess", source )

				pRequestsSent[source] = {true, 0, getTickCount()+ACTUALITY_EXPIRES_IN*60*1000, false}

				if isTimer(pWantedTimer[source]) then killTimer(pWantedTimer[source]) end
			end
		end
	end
end
addEventHandler( "OnPassportShowRequest", root, OnPassportShowRequest_handler )