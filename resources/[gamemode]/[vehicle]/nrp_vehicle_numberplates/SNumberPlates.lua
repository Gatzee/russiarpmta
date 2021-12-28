loadstring(exports.interfacer:extend("Interfacer"))()
Extend("ShUtils")
Extend("SDB")
Extend("SVehicle")
Extend("SPlayer")
Extend("ShVehicleConfig")

local pCharString = {"а","в","е","к","м","н","о","р","с","т","у","х"}
local pNumberString = {"0","9","8","7","6","5","4","3","2","1"}

local pTypeConstructions = 
{
	-- Обычный автомобильный
	[PLATE_TYPE_AUTO] = 
	{
		{"char", 1},
		{"num", 3},
		{"char", 2},
		{"reg", 1},
	},

	-- Военный
	[PLATE_TYPE_ARMY] = 
	{
		{"num", 4},
		{"char", 2},
		{"reg", 1},
	},

	-- Полицейский
	[PLATE_TYPE_POLICE] = 
	{
		{"char", 1},
		{"num", 4},
		{"reg", 1},
	},

	-- Такси
	[PLATE_TYPE_TAXI] = 
	{
		{"char", 2},
		{"num", 3},
		{"reg", 1},
	},

	-- Мото
	[PLATE_TYPE_MOTO] = 
	{
		{"num", 6},
		{"reg", 1},
	},
}

local pNumberLenWORegion = {}


UNIQUE_COMBINATIONS_LIST = { 
	["амр"] = true, 
	["екх"] = true,
	["кот"] = true, 
	["вор"] = true,
	["оса"] = true, 
	["хер"] = true, 
	["ааа"] = true, 
	["ммм"] = true, 
	["ооо"] = true, 
	["рмр"] = true, 
	["аоо"] = true, 
	["моо"] = true, 
	["амм"] = true, 
	["скр"] = true, 
}

local flags_analytics = {
    [ "RU" ] = "RUS",
    [ "UK" ] = "UKR",
    [ "KZ" ] = "KZ",
    [ "GE" ] = "GEO",
    [ "CH" ] = "CH",
}

-- Новые прописывать сюда не нужно, т.к. стоимость теперь сохраняется в пермадату numberplate_cost
SPECIAL_NUMBERS_COSTS = {
	[ "КАРАНТИН" ] = 690,
	[ "ВИРУС" ] = 990,
	[ "ШУЕ" ] = 490,
	[ "UNO" ] = 990,
	[ "РОШАН" ] = 590,
	[ "ДУМЕР" ] = 690,
	[ "ХТО" ] = 990,
	[ "ЛАПЕНКО" ] = 490,
	[ "ПОБЕДА" ] = 1390,
	[ "ДЕД" ] = 690,
	[ "БАНДИТ" ] = 990,
	[ "КАРАТЕЛЬ" ] = 690,
	[ "ВАЙБ" ] = 990,
	[ "ПОПРАВКИ" ] = 490,
	[ "удАЛЕНКА" ] = 690,
	[ "ПЕЧЕНЕГ" ] = 490,
	[ "СОНИК" ] = 990,
	[ "ХАЕА-12" ] = 490,
	[ "СТИНКИ" ] = 990,
	[ "БРО" ] = 490,
	[ "ФЛЕКС" ] = 490,
	[ "ГИГАЧАД" ] = 990,
	[ "РИКАРДА" ] = 990,
	[ "ЧЕКАННЫЙ" ] = 490,
	[ "ЛУТИНГ" ] = 990,
	[ "СПАСИБО" ] = 490,
	[ "ОБНУЛЯТЬ" ] = 990,
	[ "МОЯ" ] = 490,
	[ "ХАРДБАСС" ] = 990,
	[ "ГУРГЕН" ] = 490,
	[ "ТАНК" ] = 490,
	[ "ARMANI" ] = 990,
	[ "DODGE" ] = 490,
	[ "DRifT" ] = 990,
	[ "ПАНК" ] = 490,
	[ "УБИЙЦА" ] = 990,
	[ "КЛАССИКА" ] = 490,
	[ "МАРСЕЛЬ" ] = 990,
	[ "СКОРОСТЬ" ] = 490,
	[ "ОМОН" ] = 990,
	[ "ЛОКДАУН" ] = 490,
	[ "ВОР" ] = 990,
	[ "СМЕРТЬ" ] = 490,
	[ "РИК" ] = 990,
	[ "МОРТИ" ] = 490,
	[ "ЕКХ" ] = 990,
	[ "БРАТВА" ] = 490,
	[ "ВЛАСТЬ" ] = 990,
	[ "ФБР" ] = 490,
	[ "АМР" ] = 990,
	[ "КОРОЛЬ" ] = 490,
	[ "БАТЯ" ] = 990,
	[ "ВОИН" ] = 490,
	[ "ОПАСНЫЙ" ] = 990,
	[ "ОТЕЦ" ] = 490,
	[ "СВЯТОЙ" ] = 990,
	[ "ЛЮТЫЙ" ] = 990,
	[ "ДАБСТЕП" ] = 490,
	[ "ДЕМОН" ] = 990,
	[ "МОСКВА" ] = 490,
	[ "НЕМЕЦ" ] = 990,
	[ "ВОЛЧОК" ] = 490,
	[ "СТАРИНА" ] = 990,
	[ "РОВНЫЙ" ] = 490,
	[ "ПИТБУЛЬ" ] = 990,
	[ "ПРЕДАТЕЛЬ" ] = 490,
	[ "ДЕДМОРОЗ" ] = 990,
	[ "БЫК" ] = 490,
}

CHECK_FUNCTIONS_LIST =
{
	-- Количество повторов разных символов
	total_repeats = function( str )
		local chars = GetCharacters( str )

		local pChars = {}
		local iTotalRepeats = 0

		for i, v in pairs(chars) do
			if pChars[v] then
				iTotalRepeats = iTotalRepeats + 1
			else
				pChars[v] = true
			end
		end

		return iTotalRepeats
	end,

	-- Количество повторов одного символа
	repeats = function( str )
		local chars = GetCharacters( str )

		local pCharsAmount = {}
		local iMaxRepeats = 0

		for i, v in pairs(chars) do
			pCharsAmount[ v ] = ( pCharsAmount[v] or 0 ) + 1

			if iMaxRepeats < pCharsAmount[ v ] then
				iMaxRepeats = pCharsAmount[ v ]
			end
		end

		return iMaxRepeats
	end,

	-- Зеркалность номера
	mirror = function( str )
		local chars, numbers = GetParts( str )

		return chars == utf8.reverse( chars ) or numbers == utf8.reverse( numbers )
	end,

	-- Кратность сотне
	round = function( str )
		local chars, numbers = GetParts( str )
		numbers = tonumber(numbers)

		return numbers/100 == math.floor( numbers/100 )
	end,

	-- Первая десятка
	first_ten = function( str )
		local chars, numbers = GetParts( str )
		numbers = tonumber(numbers)

		return numbers < 10
	end,

	-- Содержание особой комбинации символов
	unique = function( str )
		local chars, numbers = GetParts( str )

		return UNIQUE_COMBINATIONS_LIST[chars]
	end,
}

NUMBERS_LIST = {}
NUMBERS_BY_CATEGORY = { {}, {}, {}, {}, {} }

addEventHandler("onResourceStart", resourceRoot, function()
	for k,v in pairs(NUMBER_TYPE_CONFIG) do
		local iConditionsAmount = 0

		for i, condition in pairs( v.conditions ) do
			iConditionsAmount = iConditionsAmount + 1
		end

		v.conditions_amount = iConditionsAmount
	end

	for k,v in pairs( pTypeConstructions ) do
		local iLenWORegion = 0

		for i, part in pairs(v) do
			if part[1] ~= "reg" then
				iLenWORegion = iLenWORegion + part[2]
			end
		end

		pNumberLenWORegion[k] = iLenWORegion
	end

	local function LoadNumbersList( query )
		if not query then return end

		local result = query:poll( 0 )
	    if result then
	        for k,v in pairs(result) do
	        	if v.owner_pid and not tonumber(v.owner_pid) and v.number_plate and v.number_plate ~= "" then
	        		NUMBERS_LIST[ v.number_plate ] = true
	        	end
	        end
	    end

	    FillNumbersList()
	end
	DB:queryAsync(LoadNumbersList, {}, "SELECT number_plate, owner_pid FROM nrp_vehicles WHERE owner_pid IS NOT NULL")
end)

function FillNumbersList()
	local bFail = true
	local iRepeats = 0

	local iStart = getTickCount()

	for category, list in pairs(NUMBERS_BY_CATEGORY) do
		repeat
			local sNumber = GenerateNumberPlateByCategory( category )

			table.insert(list, sNumber)
		until
			#list >= 30
	end

	--[[
	repeat 
		local sNumber = GenerateRandomNumberPlate( 1 )
		local iType = GetNumberType( sNumber )

		if #NUMBERS_BY_CATEGORY[iType] < 30 then
			table.insert( NUMBERS_BY_CATEGORY[iType], sNumber )
		end

		bFail = false

		for k,v in pairs( NUMBERS_BY_CATEGORY ) do
			if #v < 30 then
				bFail = true
				break
			end
		end

		iRepeats = iRepeats + 1
	until
		bFail == false
	]]
end

function OnPlayerRequestNumbersList( sSearch )
	local pListToSend = {}

	if sSearch then
		local sSearch = utf8.lower(sSearch)

		local chars, numbers = GetCharacters( sSearch, true )

		local bBadRequest = false

		if #chars > 3 or #numbers > 3 then
			bBadRequest = true
		end

		if not bBadRequest then
			for i, char in pairs(chars) do
				local bFound = false
				for k, v in pairs( pCharString ) do
					if char == v then
						bFound = true
					end
				end

				if not bFound then
					bBadRequest = true
					break
				end
			end
		end

		local list = not bBadRequest and FindNumberPlates( sSearch ) or {}
		
		for k, v in pairs( list ) do
			local iType = GetNumberType(v)
			if not pListToSend[iType] then pListToSend[iType] = {} end

			table.insert( pListToSend[iType], v )
		end
	else
		for k, v in pairs( NUMBERS_BY_CATEGORY ) do
			local list = table.copy(v)

			if not pListToSend[k] then pListToSend[k] = {} end

			for i = 1, 2 do
				local iRandom = math.random( #list )

				table.insert( pListToSend[k], list[iRandom] )
				table.remove( list, iRandom )
			end
		end
	end

	triggerClientEvent( client, "OnClientNumbersListReceive", client, pListToSend )
end
addEvent("OnPlayerRequestNumbersList", true)
addEventHandler("OnPlayerRequestNumbersList", root, OnPlayerRequestNumbersList)

function OnPlayerTryBuyNumberPlate( pVehicle, sNumber, pPlayer, cost )
	local pPlayer = client or source or pPlayer

	local iType = GetNumberType( sNumber )

	local pNumber = split( sNumber, ":" )
	local bSpecial = tonumber(pNumber[1]) == PLATE_TYPE_SPECIAL

	if not NUMBERS_LIST[sNumber] or bSpecial then
		local sFullNumber = pVehicle:GetNumberPlate( false, true )
		local sOldNumber = pVehicle:GetNumberPlate()
		local pOldNumber = split( sFullNumber, ":" )
		local sColor = ""

		if bSpecial then
			if pOldNumber[2] == pNumber[2] then
				pPlayer:ShowError("На автомобиле уже установлен данный номер!")
				return false
			end

			if pPlayer:GetDonate() >= cost then
				pPlayer:TakeDonate( cost, "f4_special", "numberplate" )
				pPlayer:InfoWindow( "Номер успешно установлен" )
			else
				pPlayer:ShowError("Недостаточно средств")
				return false
			end 
		end

		if #pOldNumber >= 3 then
			sColor = pOldNumber[1] .. ":"
		end

		if sOldNumber then
			SetNumberLocked( sOldNumber, false )
		end

		pVehicle:SetNumberPlate( sColor .. sNumber )
		pVehicle:SetPermanentData( "numberplate_cost", bSpecial and cost * 1000 or nil )

		SetNumberLocked( sNumber, true )

		local iPurchaseCount = pPlayer:GetPermanentData( "purchased_numbers_count" ) or 0
		pPlayer:SetPermanentData( "purchased_numbers_count", iPurchaseCount + 1 )

		triggerEvent( "onPlayerBuyNumberPlate", pPlayer, iType, sNumber, bSpecial, iPurchaseCount )

		return true
	else
		-- Возврат средств списанных тюнингом в случае, если номер оказался занятым на момент покупки
		pPlayer:GiveMoney( NUMBER_TYPE_CONFIG[iType].cost, "NUMBERS_REFUND: "..sNumber )
		
		return false
	end
end
addEvent("OnPlayerTryBuyNumberPlate", true)
addEventHandler("OnPlayerTryBuyNumberPlate", root, OnPlayerTryBuyNumberPlate)

function OnVehicleChangeNumberPlate( sNumber, cost )
	local pVehicle = source
	local sFullNumber = pVehicle:GetNumberPlate( false, true )
	local sOldNumber = pVehicle:GetNumberPlate()
	local pOldNumber = split( sFullNumber, ":" )
	local sColor = ""

	if #pOldNumber >= 3 then
		sColor = pOldNumber[1] .. ":"
	end

	if sOldNumber then
		SetNumberLocked( sOldNumber, false )
	end

	pVehicle:SetNumberPlate( sColor .. sNumber )
	pVehicle:SetPermanentData( "numberplate_cost", cost or nil )

	SetNumberLocked( sNumber, true )
end
addEvent( "OnVehicleChangeNumberPlate" )
addEventHandler( "OnVehicleChangeNumberPlate", root, OnVehicleChangeNumberPlate )

function SetNumberLocked( sNumber, bState )
	NUMBERS_LIST[sNumber] = bState

	if bState then
		local iType = GetNumberType( sNumber )

		for i, v in pairs(NUMBERS_BY_CATEGORY[iType]) do
			if v == sNumber then
				table.remove( NUMBERS_BY_CATEGORY[iType], k )
				FillNumbersList()

				break
			end
		end
	end

	return true
end

function GetNumberType( sNumber )
	local pNumber = split( sNumber, ":" )
	local iPlateType = tonumber( pNumber[1] )

	if iPlateType == PLATE_TYPE_SPECIAL then
		return NUMBER_TYPE_UNIQUE
	elseif iPlateType == PLATE_TYPE_MOTO then
		return NUMBER_TYPE_REGULAR
	end

	local pTypeConstruction = pTypeConstructions[ iPlateType ]

	local sNumber = utf8.sub( pNumber[2], 1, pNumberLenWORegion[ iPlateType ] )

	local iNumberType = NUMBER_TYPE_UNIQUE

	for i = NUMBER_TYPE_UNIQUE, NUMBER_TYPE_REGULAR, -1 do
		iNumberType = i

		local iConditionsPassed = 0

		for k, v in pairs( NUMBER_TYPE_CONFIG[ i ].conditions ) do
			local result = CHECK_FUNCTIONS_LIST[ k ]( sNumber )

			if type(v) == "table" then
				if result >= v[1] and result <= v[2] then
					iConditionsPassed = iConditionsPassed + 1
				else
					break
				end
			else
				if result == v then
					iConditionsPassed = iConditionsPassed + 1
				else
					break
				end
			end
		end

		if NUMBER_TYPE_CONFIG[ i ].conditions_amount >= 1 and iConditionsPassed >= NUMBER_TYPE_CONFIG[ i ].conditions_amount then
			iNumberType = i
			break
		end

		if NUMBER_TYPE_CONFIG[ i ].selective_conditions then
			local iConditionHit = false

			for k,v in pairs( NUMBER_TYPE_CONFIG[ i ].selective_conditions ) do
				local result = CHECK_FUNCTIONS_LIST[ k ]( sNumber )

				if type(v) == "table" then
					if result >= v[1] and result <= v[2] then
						iConditionHit = true
						break
					end
				else
					if result == v then
						iConditionHit = true
						break
					end
				end
			end

			if iConditionHit then
				iNumberType = i
				break
			end
		end
	end

	return iNumberType
end

function GetNumberCost( sNumber )
	local pNumber = split( sNumber, ":" )
	local sPlateText = utf8.sub( pNumber[2], 1, utf8.len( pNumber[2] ) - 2 )
	local cost = SPECIAL_NUMBERS_COSTS[ sPlateText ]
	return cost and cost * 1000 or nil
end

function GetVehicleNumberCost( veh )
	local cost = veh:GetPermanentData( "numberplate_cost" )
	if not cost then
		local sNumberPlate = veh:GetNumberPlate()
		local iPlateCost = sNumberPlate and GetNumberCost( sNumberPlate )
		if iPlateCost then
			cost = iPlateCost
		else
			local iPlateType = sNumberPlate and GetNumberType( sNumberPlate ) or 1
			if iPlateType then
				cost = NUMBER_TYPE_CONFIG[ iPlateType ].cost or 0
			end
		end
	end

	return cost or 0
end

-- Utils

-- Разбитие на символы
function GetCharacters( str, by_type )
	if by_type then
		local chars, numbers = {}, {}

		for i = 1, utfLen( str ) do
			local symbol = utf8.sub( str, i, i )
			
			if tonumber(symbol) then
				table.insert(numbers, symbol)
			else
				table.insert(chars, symbol)
			end
		end

		return chars, numbers
	else
		local chars = {}

		for i = 1, utfLen( str ) do
			table.insert(chars, utf8.sub( str, i, i ))
		end

		return chars
	end
end

-- Разбитие на цифры и буквы
function GetParts( str )
	local chars, numbers = "", ""

	for i = 1, utfLen( str ) do
		local symbol = utf8.sub( str, i, i )
		
		if tonumber(symbol) then
			numbers = numbers..symbol
		else
			chars = chars..symbol
		end
	end

	return chars, numbers
end

function GenerateNumberPlateByPart( sPart, iType, iRepeat, iReg, bRegSearch )
	local iType = iType or 1
	local iRepeat = iRepeat or 0
	local iReg = iReg or 99

	local pSymbols = {}

	local sLastChar = nil

	local pConstruction = pTypeConstructions[iType]

	local chars, numbers = GetCharacters( sPart, true )

	local iSymbol = 1

	for key, part in pairs( pConstruction ) do
		for i = 1, part[2] do
			if part[1] == "char" then
				local _, sChar = next(chars)
				if sChar then
					pSymbols[iSymbol] = sChar
					table.remove(chars, 1)
				else
					pSymbols[iSymbol] = pCharString[math.random(1,#pCharString)]
				end
			elseif part[1] == "num" then
				local _, sChar = next(numbers)
				if sChar then
					pSymbols[iSymbol] = sChar
					table.remove(numbers, 1)
				else
					pSymbols[iSymbol] = pNumberString[math.random(1,#pNumberString)]
				end
			elseif part[1] == "reg" then
				pSymbols[iSymbol] = iReg
			end

			iSymbol = iSymbol + 1
		end
	end

	local sText = iType..":"..table.concat(pSymbols, "")

	if NUMBERS_LIST[sText] then
		iRepeat = iRepeat + 1

		if utf8.len(sPart) >= pNumberLenWORegion[ iType ] then
			if not bRegSearch and iReg > 10 then
				iRepeat = 0
				iReg = iReg - 1
				return GenerateNumberPlateByPart( sPart, iType, iRepeat, iReg, bRegSearch )
			else
				return false
			end
		end

		if iRepeat < 200 then
			return GenerateNumberPlateByPart( sPart, iType, iRepeat, iReg, bRegSearch )
		else
			if not bRegSearch and iReg > 10 then
				iRepeat = 0
				iReg = iReg - 1
				return GenerateNumberPlateByPart( sPart, iType, iRepeat, iReg, bRegSearch )
			else
				return false
			end
		end
	end

	if not bRegSearch and string.find(sText, "000") then
		iRepeat = iRepeat + 1
		return GenerateNumberPlateByPart( sPart, iType, iRepeat, iReg, bRegSearch )
	end

	return sText
end

function GenerateNumberPlateByCategory( iCategory, iType, iRepeat, iReg )
	local iType = iType or 1
	local iRepeat = iRepeat or 0
	local iReg = iReg or 99

	local sText = ""
	local sLastChar = nil

	for key, part in pairs(pTypeConstructions[iType]) do
		for i=1, part[2] do
			local char = ""

			if part[1] == "char" then
				char = pCharString[math.random(1,#pCharString)]
				sLastChar = char
			elseif part[1] == "num" then
				char = pNumberString[math.random(1,#pNumberString)]

				sLastNum = char
			elseif part[1] == "reg" then
				char = iReg
			end

			sText = sText..char
		end
	end

	sText = iType..":"..sText

	local iResultCategory = GetNumberType( sText )
	if iResultCategory ~= iCategory then
		iRepeat = iRepeat + 1
		return GenerateNumberPlateByCategory( iCategory, iType, iRepeat, iReg )
	end

	local bAlreadyInList = false
	for k,v in pairs(NUMBERS_BY_CATEGORY[iCategory]) do
		if v == sText then
			bAlreadyInList = true
			break
		end
	end

	if NUMBERS_LIST[sText] or bAlreadyInList then
		iRepeat = iRepeat + 1
		if iRepeat < 200 then
			return GenerateNumberPlateByCategory( iCategory, iType, iRepeat, iReg )
		else
			if iReg > 10 then
				iRepeat = 0
				iReg = iReg - 1
				return GenerateNumberPlateByCategory( iCategory, iType, iRepeat, iReg )
			else
				return sText
			end
		end
	end

	if string.find(sText, "000") then
		iRepeat = iRepeat + 1
		return GenerateNumberPlateByCategory( iCategory, iType, iRepeat, iReg )
	end

	return sText
end

function FindNumberPlates( sPart )
	local pGeneratedNumbers, pGeneratedNumbersList = {}, {}
	local iRepeats, iNumbers = 0, 0

	repeat 
		local sNumber = GenerateNumberPlateByPart( sPart )

		if sNumber then
			if not pGeneratedNumbers[sNumber] then
				pGeneratedNumbers[sNumber] = true
				table.insert(pGeneratedNumbersList, sNumber)
				iNumbers = iNumbers + 1
			else
				iRepeats = iRepeats + 1
			end
		else
			iRepeats = iRepeats + 1
		end
	until
		iNumbers >= 6 or iRepeats >= 200

	-- Сортировка в порядке возрастания ценности
	table.sort( pGeneratedNumbersList, function( a, b ) return GetNumberType( a ) < GetNumberType( b ) end )

	return pGeneratedNumbersList
end

function GenerateRandomNumberPlate( iType, iRepeat, iReg )
	local iType = iType or 1
	local iRepeat = iRepeat or 0
	local iReg = iReg or 99

	local sText = ""
	local sLastChar = nil

	for key, part in pairs(pTypeConstructions[iType]) do
		for i=1, part[2] do
			local char = ""

			if part[1] == "char" then
				char = pCharString[math.random(1,#pCharString)]
				sLastChar = char
			elseif part[1] == "num" then
				char = pNumberString[math.random(1,#pNumberString)]

				sLastNum = char
			elseif part[1] == "reg" then
				char = iReg
			end

			sText = sText..char
		end
	end

	sText = iType..":"..sText

	if NUMBERS_LIST[sText] then
		iRepeat = iRepeat + 1
		if iRepeat < 200 then
			return GenerateRandomNumberPlate( iType, iRepeat, iReg )
		else
			if iReg > 10 then
				iRepeat = 0
				iReg = iReg - 1
				return GenerateRandomNumberPlate( iType, iRepeat, iReg )
			else
				return sText
			end
		end
	end

	if string.find(sText, "000") then
		iRepeat = iRepeat + 1
		return GenerateRandomNumberPlate( iType, iRepeat, iReg )
	end

	return sText
end

function OnPlayerRequestRegionsList( pVehicle )
	if not isElement(pVehicle) then return end

	local sNumber = pVehicle:GetNumberPlate()
	local pNumber = split( sNumber, ":" )

	local sNumber, sReg = string.sub( pNumber[2], 1, -3 ), string.sub( pNumber[2], -2 )

	local pList = {}

	for i = 1, 99 do
		local sRequestedNumber = pNumber[1]..":"..sNumber..string.format( "%02d", i )

		if NUMBERS_LIST[ sRequestedNumber ] then
			pList[i] = true
		end
	end

	triggerClientEvent( client, "OnClientReceiveRegionsList", client, pList )
end
addEvent("OnPlayerRequestRegionsList", true)
addEventHandler("OnPlayerRequestRegionsList", root, OnPlayerRequestRegionsList)

function OnPlayerTryBuyNumberRegion( pVehicle, iRegion )
	if not isElement( pVehicle ) then return end

	local sOldNumber = pVehicle:GetNumberPlate( nil, true )
	local pNumber = split( sOldNumber, ":" )
	local count_parts = #pNumber
	local numberWithRegion = pNumber[ count_parts ]
	local sNumber = string.sub( numberWithRegion, 1, - 3 )
	local sReg = string.sub( numberWithRegion, - 2 )
	local sRequestedNumber = pNumber[ count_parts - 1 ] .. ":" .. sNumber .. iRegion
	local color = pNumber[ count_parts - 2 ]
	local is_flag_old = not tonumber( sReg )
	local is_flag_new = not tonumber( iRegion )

	if NUMBERS_LIST[ sRequestedNumber ] then
		client:ShowError("Такой номер уже занят")
		return
	end

	local cost, is_discount_acitve = client:GetCostService( is_flag_new and 9 or 7 )

	if client:TakeDonate( cost, is_flag_new and "service" or "f4_service", is_flag_new and "flag_change" or "region" ) then
		if is_discount_acitve then 
			client:TakeSpecialCouponDiscount( coupon_discount_value, "special_services" ) 
			triggerEvent( "onPlayerRequestDonateMenu", client, "services" )
		end
		
		pVehicle:SetNumberPlate( sRequestedNumber )

		if color then
			pVehicle:ApplyNumberPlateColor( color )
		end

		SetNumberLocked( sOldNumber, false )
		SetNumberLocked( sRequestedNumber, true )

		triggerClientEvent( client, "onClientPlayerBuyNumberPlateRegion", client )

		if is_flag_new then
			SendElasticGameEvent( client:GetClientID( ), "flag_change_purchase", 
				{
					cost = cost,
					currency = "hard",
					vehicle_id = pVehicle.model,
					vehicle_class = VEHICLE_CLASSES_NAMES[ pVehicle:GetTier( ) ],
					vehicle_name = GetVehicleNameFromModel( pVehicle.model, pVehicle:GetVariant( ) ),
					current_flag = is_flag_old and flags_analytics[ sReg ] or "region",
					new_flag = flags_analytics[ iRegion ]
				}
			)
		else
			triggerEvent( "onPlayerBuyNumberPlateRegion", client, cost, sReg, iRegion )
			SendElasticGameEvent( client:GetClientID( ), "f4r_f4_services_purchase", { service = "change_region" } )
		end
	else
		triggerClientEvent( client, "onShopNotEnoughHard", client, "Region change", "onPlayerRequestDonateMenu", "donate" )
	end
end
addEvent("OnPlayerTryBuyNumberRegion", true)
addEventHandler("OnPlayerTryBuyNumberRegion", root, OnPlayerTryBuyNumberRegion)