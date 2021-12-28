loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SDB" )

local cases_list = { bronze = true, silver = true, gold = true }

-- Отмечаем что он новый юзер если завершил туториал
function onPlayerFinishTutorialGlobally_handler( )
    source:SetPermanentData( "cases50_ready", true )
end
addEvent( "onPlayerFinishTutorialGlobally" )
addEventHandler( "onPlayerFinishTutorialGlobally", root, onPlayerFinishTutorialGlobally_handler )

function onCasesPurchaseCase_handler( case_id, case_type, count, cost, is_case_discount, discount_id )
    local player = client or source

    -- Купил по скидке - завершаем и отправляем в аналитику
    if is_case_discount and discount_id == "cases50" then
        player:SetPermanentData( "cases50_finish", nil )
        player:SetPermanentData( "cases50_ready", nil )
        triggerEvent( "onCasesDiscountsRefreshRequest", source )

        triggerEvent( "onCases50Purchase", player, case_id, count, cost )
        return
    end

    -- Если игрок не может получать скидку
    if not player:GetPermanentData( "cases50_ready" ) or discount_id then return end

    -- Готовим игрока к показу скидки
    if cases_list[ case_id ] then
        player:SetPermanentData( "cases50_case_temp", case_id )
    end
end
addEvent( "onCasesPurchaseCase" )
addEventHandler( "onCasesPurchaseCase", root, onCasesPurchaseCase_handler )
addEvent( "onCasesOpenCase" )
addEventHandler( "onCasesOpenCase", root, onCasesPurchaseCase_handler )

-- Показываем окно только после того, как чел взял предмет из кейса или обменял на опыт
-- и только если нет других скидок
function onPlayerFinishDoingCasesStuff( )
    local case_id = source:GetPermanentData( "cases50_case_temp" )
    if case_id and not exports.nrp_shop:GetPlayerCasesDiscounts( source ) then
        local duration = 24 * 60 * 60

        source:SetBatchPermanentData( { cases50_case = case_id, cases50_finish = getRealTime( ).timestamp + duration } )
        triggerEvent( "onCasesDiscountsRefreshRequest", source )

        triggerClientEvent( source, "ShowCases50", resourceRoot, true, { case_id = case_id, duration = duration } )
        triggerEvent( "onCases50ShowFirst", source )

        source:SetPermanentData( "cases50_case_temp", nil )
    end
end
addEvent( "onCasesTakeItem" )
addEventHandler( "onCasesTakeItem", root, onPlayerFinishDoingCasesStuff )
addEvent( "onCasesSellItem" )
addEventHandler( "onCasesSellItem", root, onPlayerFinishDoingCasesStuff )
addEvent( "onPlayerReadyToPlay" )
addEventHandler( "onPlayerReadyToPlay", root, onPlayerFinishDoingCasesStuff )