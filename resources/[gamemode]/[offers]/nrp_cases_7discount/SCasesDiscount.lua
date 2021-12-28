Extend("SPlayer")
Extend("SVehicle")
Extend("rewards/Server")

local CASE_COLOR_BY_POSITION = 
{
    [ 2 ] = 1, -- low
    [ 4 ] = 1, -- middle-1
    [ 5 ] = 2, -- high
    [ 6 ] = 2, -- middle-2
}

local CONST_CASE_DISCOUNTS = 
{
    [99] = { 69, 30 },
    [149] = { 99, 30 },
    [159] = { 109, 30 },
    [179] = { 129, 30 },
    [199] = { 149, 20 },
    [249] = { 169, 30 },
    [299] = { 209, 30 },
    [349] = { 249, 30 },
    [499] = { 399, 20 },
    [599] = { 479, 20 },
    [649] = { 519, 20 },
    [699] = { 559, 20 },
    [999] = { 699, 30 },
    [1499] = { 1049, 30 },
}

local CASES_DATA
local DISCOUNT_CASES
local CURRENT_DISCOUNT

local CONST_GET_DATA_URL = SERVER_NUMBER > 100 and "https://pyapi.devhost.nextrp.ru/v1.0/get_f4_data/" or "https://pyapi.gamecluster.nextrp.ru/v1.0/get_f4_data/"

function OnResourceStart()
	triggerEvent( "onSpecialDataRequest", root, "7cases_discount" )
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
        local is_limited = v.temp_start_count
        local is_in_time = v.temp_start and v.temp_start <= current_date and v.temp_end and v.temp_end >= current_date
        local is_const = CONST_CASES_LIST[ v.id ]

        if is_const or ( not is_versus or include_versus ) and ( not is_limited or include_limited ) and is_in_time then
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
    new_data.points = math.floor( data.cost / 20 )
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
        limited_case.points = math.floor( limited_case.cost / 20 ) * 2
        table.insert( DISCOUNT_CASES, limited_case )
    end
end

function UpdateDiscounts( data )
    if not data or #data <= 0 then
        OnCasesDiscountEnd( )
        return 
    end

    local discount_data = data[1]

    UpdateDiscountCases( discount_data.limited_case )

    discount_data.start_ts = getTimestampFromString( discount_data.startTime )
    discount_data.finish_ts = getTimestampFromString( discount_data.endTime )
    discount_data.cases = DISCOUNT_CASES
    discount_data.cases_reverse = {}
    discount_data.rewards = table.copy( CONST_REWARDS_BY_WEEK[ discount_data.balance_week ] )

    for i, case in pairs( discount_data.cases ) do
        discount_data.cases_reverse[ case.case_id ] = case
    end

    if not CheckRewardsTable( discount_data.rewards ) then
        iprint("[7Cases] Ошибка формата наград для текущей акции.")
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
            rewards = CURRENT_DISCOUNT.rewards,
        }

        pClientData = toJSON( pClientData )
    end

    triggerClientEvent( player, "On7CasesDiscountDataReceived", resourceRoot, pClientData )
end

function onSpecialDataUpdate_handler( key, data )
    if not key or key ~= "7cases_discount" then return end
    UpdateDiscounts( data )
end
addEventHandler( "onSpecialDataUpdate", root, onSpecialDataUpdate_handler, _, "high" )

function OnResourceStop()
    for i, player in pairs( GetPlayersInGame() ) do
        if player:getData( "7cases_discounts" ) then
            player:SetPrivateData( "7cases_discounts", false )
        end
    end
end
addEventHandler("onResourceStop", resourceRoot, OnResourceStop)

function OnPlayerReadyToPlay( player )
    local player = isElement( player ) and player or source
    if not player:HasFinishedTutorial( ) then return end

    if CURRENT_DISCOUNT then
        SyncDiscountData( player )

        local iLastParticipatedDiscountID = player:GetPermanentData( "last_7cases_discount_id" )
        player:Set7CasesPoints( iLastParticipatedDiscountID and iLastParticipatedDiscountID == CURRENT_DISCOUNT.start_ts and player:Get7CasesPoints() or 0 )

        if iLastParticipatedDiscountID ~= CURRENT_DISCOUNT.start_ts then
            player:SetPermanentData( "last_7cases_discount_rewards", {} )
            player:SetPermanentData( "last_7cases_discount_id", CURRENT_DISCOUNT.start_ts )
        end

        player:Check7CasesRewards()

        local iLastDiscountShown = player:GetPermanentData( "last_7cases_shown" ) or 0
        if iLastDiscountShown ~= CURRENT_DISCOUNT.start_ts then
            player:SetPermanentData( "last_7cases_shown", CURRENT_DISCOUNT.start_ts )
            SendElasticGameEvent( player:GetClientID( ), "updated_case_showfirst" )
        end

        triggerClientEvent( player, "ShowUI_7CasesDiscountOnLogin", resourceRoot )
    else
        player:SetPrivateData( "7cases_discounts", false )
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

    for i, player in pairs( GetPlayersInGame() ) do
        OnPlayerReadyToPlay( player )
    end
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

function OnPlayerBoughtCaseOn7Cases( player, case_id, count )
    local pCaseData = GetCase7CasesDiscountData( case_id )
    if not pCaseData then return end

    local pCaseInfo = CASES_DATA[ case_id ]

    player:Give7CasesPoints( pCaseData.points * count )

    SendElasticGameEvent( player:GetClientID( ), "updated_case_purchase", {
        id = tostring( case_id ),
        name = pCaseInfo.id,
        cost = pCaseData.cost,
        quantity = count,
        currency = "hard",
        spend_sum = pCaseData.cost*count,
        points_sum = player:Get7CasesPoints(),
    } )
end
addEvent("OnPlayerBoughtCaseOn7Cases", false)
addEventHandler("OnPlayerBoughtCaseOn7Cases", resourceRoot, OnPlayerBoughtCaseOn7Cases)

function PlayerWantReceive7CasesReward( args )
    client:Give7CasesReward( args )
end
addEvent("PlayerWantReceive7CasesReward", true)
addEventHandler("PlayerWantReceive7CasesReward", resourceRoot, PlayerWantReceive7CasesReward)

Player.Get7CasesPoints = function( self )
    return self:GetPermanentData( "7cases_points" ) and tonumber( self:GetPermanentData( "7cases_points" ) ) or 0
end

Player.Give7CasesPoints = function( self, value )
    if not value or not tonumber( value ) then return end
    self:Set7CasesPoints( self:Get7CasesPoints() + value )
    self:Check7CasesRewards(  )

    return true
end

Player.Set7CasesPoints = function( self, value, ignore_sync )
    if not value or not tonumber( value ) then return end

    self:SetPermanentData( "7cases_points", value )

    if not ignore_sync then
        self:SetPrivateData( "7cases_points", value )
    end

    return true
end

Player.Check7CasesRewards = function( self )
    if not CURRENT_DISCOUNT then return end

    local iPoints = self:Get7CasesPoints()
    local pRewards = self:GetPermanentData( "last_7cases_discount_rewards" ) or {}

    for k,v in pairs( CURRENT_DISCOUNT.rewards ) do
        if iPoints >= v.points then
            if not pRewards[k] then
                triggerClientEvent( self, "Show7CasesReward", resourceRoot, k )
                break
            end
        end
    end
end

Player.Give7CasesReward = function( self, data )
    if not CURRENT_DISCOUNT then return end

    local iPoints = self:Get7CasesPoints()
    local pRewards = self:GetPermanentData( "last_7cases_discount_rewards" ) or {}

    for k,v in pairs( CURRENT_DISCOUNT.rewards ) do
        if iPoints >= v.points then
            if not pRewards[k] then
                local data = data or { }

                if data.exchange_to then
                    if data.exchange_to == "soft" then
                        self:GiveMoney( item.exchange.soft, "reward_item_exchange" )
                    elseif data.exchange_to == "exp" then
                        self:GiveExp( item.exchange.exp, "reward_item_exchange" )
                    end
                else
                    self:Reward( v, data )
                end

                pRewards[ k ] = true
                self:SetPermanentData( "last_7cases_discount_rewards", pRewards )

                SendElasticGameEvent( self:GetClientID( ), "updated_case_reward", {
                    id = tostring( k ),
                    cost = v.cost,
                    name = v.name,
                    points_sum = iPoints,
                } )
                break
            end
        end
    end

    self:Check7CasesRewards() 
end

function Get7CasesDiscountData()
    return CURRENT_DISCOUNT or false
end

function GetCase7CasesDiscountData( case_id )
    local pDiscountData = Get7CasesDiscountData()

    if pDiscountData then
        return pDiscountData.cases_reverse and pDiscountData.cases_reverse[ case_id ]
    end
end

