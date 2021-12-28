Extend("SPlayer")
Extend("SVehicle")

local CASE_COLOR_BY_POSITION = 
{
    [ 2 ] = 1, -- low
    [ 4 ] = 1, -- middle-1
    [ 5 ] = 2, -- high
    [ 6 ] = 2, -- middle-2
}

local CASE_TYPES_BY_POSITION = 
{
    [ 2 ] = "low",
    [ 4 ] = "middle1",
    [ 6 ] = "middle2",
    [ 5 ] = "high",
}

local CONST_CASE_DISCOUNTS = 
{
    [99] = { 69, 35 },
    [149] = { 99, 35 },
    [159] = { 109, 35 },
    [179] = { 129, 35 },
    [199] = { 149, 35 },
    [249] = { 169, 35 },
    [299] = { 209, 35 },
    [349] = { 249, 35 },
    [499] = { 399, 35 },
    [599] = { 479, 35 },
    [649] = { 519, 35 },
    [699] = { 559, 35 },
    [999] = { 699, 35 },
    [1499] = { 1049, 35 },
}

local CASES_DATA
local DISCOUNT_CASES
local CURRENT_DISCOUNT

local CONST_GET_DATA_URL = SERVER_NUMBER > 100 and "https://pyapi.devhost.nextrp.ru/v1.0/get_f4_data/" or "https://pyapi.gamecluster.nextrp.ru/v1.0/get_f4_data/"

function OnResourceStart()
	triggerEvent( "onSpecialDataRequest", root, "wholesome_case_discount" )
end
addEventHandler("onResourceStart", resourceRoot, OnResourceStart)

function GetDiscountCases( )
    return DISCOUNT_CASES
end

function GetActiveCasesData( include_versus, include_limited )
    local cases_list = exports.nrp_shop:GetCasesInfo()
    local current_date = getRealTimestamp( )
    local output = { }

    for k, v in pairs( cases_list ) do
        local is_versus = v.versus
        local is_limited = v.temp_start_count or v.count
        local is_in_time = v.temp_start and v.temp_start <= current_date and v.temp_end and v.temp_end >= current_date
        local is_const = CONST_CASES_LIST[ v.id ]

        if is_const or ( not is_versus or include_versus ) and ( not is_limited or include_limited ) and is_in_time and v.position > 0 then
            table.insert( output, v )
        end
    end

    return output
end

function GetCaseDiscount( cost )
    if CONST_CASE_DISCOUNTS[ cost ] then
        return unpack( CONST_CASE_DISCOUNTS[ cost ] )
    else
        return math.floor( cost*0.8 ), 20
    end
end

function GetCaseColor( case )
    return CASE_COLOR_BY_POSITION[ case.position ] or 1
end

function FormatCaseData( data )
    local new_cost, discount = GetCaseDiscount( data.cost )
    local new_data = { }

    new_data.id = data.id
    new_data.case_id = data.id
    new_data.color = GetCaseColor( data )
    new_data.old_cost = data.cost
    new_data.cost = new_cost
    new_data.discount = discount

    return new_data
end

function UpdateDiscountCases( limited_case )
    local active_cases = GetActiveCasesData( )
    DISCOUNT_CASES = { }

    for k,v in pairs( active_cases ) do
        local formatted = FormatCaseData( v )
        table.insert( DISCOUNT_CASES, formatted )
    end

    if limited_case then
        limited_case.color = 3
        table.insert( DISCOUNT_CASES, limited_case )
    end
end

function UpdateDiscounts( data )
    if not data or #data <= 0 then
        OnCasesDiscountEnd( )
        return 
    end

    local discount_data = data[1]

    UpdateDiscountCases( )

    discount_data.start_ts = getTimestampFromString( discount_data.startTime )
    discount_data.finish_ts = getTimestampFromString( discount_data.endTime )
    discount_data.cases = DISCOUNT_CASES
    discount_data.cases_reverse = {}

    for i, case in pairs( discount_data.cases ) do
        discount_data.cases_reverse[ case.case_id ] = case
    end

    OnCasesDiscountStart( discount_data )
end

function SyncDiscountData( player )
    local pClientData = false

    if CURRENT_DISCOUNT then
        pClientData = 
        {
            start_ts = CURRENT_DISCOUNT.start_ts,
            finish_ts = CURRENT_DISCOUNT.finish_ts,
            cases = DISCOUNT_CASES,
        }

        pClientData = toJSON( pClientData )
    end

    triggerClientEvent( player, "OnWholesomeCaseDiscountDataReceived", resourceRoot, pClientData )
end

function onSpecialDataUpdate_handler( key, data )
    if not key or key ~= "wholesome_case_discount" then return end
    UpdateDiscounts( data )
end
addEventHandler( "onSpecialDataUpdate", root, onSpecialDataUpdate_handler, _, "high" )

function OnResourceStop()
    for i, player in pairs( GetPlayersInGame() ) do
        if player:getData( "wholesome_case_discount" ) then
            player:SetPrivateData( "wholesome_case_discount", false )
        end
    end
end
addEventHandler("onResourceStop", resourceRoot, OnResourceStop)

function OnPlayerReadyToPlay( player )
    local player = isElement( player ) and player or source
    if not player:HasFinishedTutorial( ) then return end

    if CURRENT_DISCOUNT then
        SyncDiscountData( player )

        local iLastParticipatedDiscountID = player:GetPermanentData( "last_wholesome_case_discount_id" )

        if iLastParticipatedDiscountID ~= CURRENT_DISCOUNT.start_ts then
            player:SetPermanentData( "last_wholesome_case_discount_id", CURRENT_DISCOUNT.start_ts )
        end

        local iLastDiscountShown = player:GetPermanentData( "last_wholesome_case_discount_shown" ) or 0
        if iLastDiscountShown ~= CURRENT_DISCOUNT.start_ts then
            player:SetPermanentData( "last_wholesome_case_discount_shown", CURRENT_DISCOUNT.start_ts )
            SendElasticGameEvent( player:GetClientID( ), "wholesale_case_show_first" )
        end

        triggerClientEvent( player, "ShowUI_WholesomeCaseDiscountOnLogin", resourceRoot )
    else
        player:SetPrivateData( "wholesome_case_discount", false )
    end
end
addEventHandler( "onPlayerReadyToPlay", root, OnPlayerReadyToPlay, _, "low" )

function OnCasesDiscountStart( discount_data )
    if CURRENT_DISCOUNT then return end

    local pAllCasesData = exports.nrp_shop:GetCasesInfo()
    CASES_DATA = { }

	CURRENT_DISCOUNT = discount_data

	local iDiff = CURRENT_DISCOUNT.finish_ts - getRealTimestamp()
	setTimer(OnCasesDiscountEnd, iDiff*1000, 1)

    for k,v in pairs( pAllCasesData ) do
        if CURRENT_DISCOUNT.cases_reverse[ k ] then
            CASES_DATA[ k ] = v
        end
    end

    -- TODO remove timer
    setTimer(function()
        for i, player in pairs( GetPlayersInGame() ) do
            OnPlayerReadyToPlay( player )
        end
    end, 1000, 1)
end

function OnCasesDiscountEnd()
	CURRENT_DISCOUNT = nil

    for i, player in pairs( GetPlayersInGame() ) do
        OnPlayerReadyToPlay( player )
    end
end

function OnClientRequestDiscountData( )
    SyncDiscountData( client )
end
addEvent( "OnClientRequestDiscountData", true)
addEventHandler( "OnClientRequestDiscountData", resourceRoot, OnClientRequestDiscountData )

function OnPlayerBoughtCaseOnWholesomeCase( player, case_id, count )
    local case_data, total_cost = GetCaseWholesomeCaseDiscountData( case_id, count )
    if not case_data then return end

    local case_info = CASES_DATA[ case_id ]

    SendElasticGameEvent( player:GetClientID( ), "wholesale_case_purchase", {
        id = tostring( case_id ),
        case_type = GetCaseType( case_id ),
        count = count,
        currency = "hard",
        spend_sum = total_cost,
    } )
end
addEvent("OnPlayerBoughtCaseOnWholesomeCase", false)
addEventHandler("OnPlayerBoughtCaseOnWholesomeCase", resourceRoot, OnPlayerBoughtCaseOnWholesomeCase)

function GetWholesomeCaseDiscountData()
    return CURRENT_DISCOUNT or false
end

function GetCaseWholesomeCaseDiscountData( case_id, amount )
    local pDiscountData = GetWholesomeCaseDiscountData()

    if pDiscountData then
        local case_data = pDiscountData.cases_reverse and pDiscountData.cases_reverse[ case_id ] and table.copy( pDiscountData.cases_reverse[ case_id ] )

        local total_cost = GetCaseDiscountCostForAmount( case_data.old_cost, amount )
        case_data.cost = math.floor( total_cost / amount )

        return case_data, total_cost
    end
end

function GetCaseType( case_id )
    local case_info = CASES_DATA[ case_id ]
    return CASE_TYPES_BY_POSITION[ case_info.position ] or "const"
end

function GetDiscountCases( )
    return DISCOUNT_CASES
end