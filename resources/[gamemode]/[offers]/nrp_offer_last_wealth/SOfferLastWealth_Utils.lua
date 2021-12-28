

Player.GetExecutableMulStep = function( self )
    return self:GetPermanentData( CONST_OFFER_NAME .. "exec_mul" ) or 1
end

Player.SetExecutableMulStep = function( self, value )
    return self:SetPermanentData( CONST_OFFER_NAME .. "exec_mul", value and math.min( value, #LEVEL_MULTIPLY ) or nil )
end


Player.GetCurrentMulStep = function( self )
    return self:GetPermanentData( CONST_OFFER_NAME .. "cur_mul" ) or 0
end

Player.SetCurrentMulStep = function( self, value )
    return self:SetPermanentData( CONST_OFFER_NAME .. "cur_mul", value and math.min( value, #LEVEL_MULTIPLY ) or nil )
end


Player.GetMulSteps = function( self )
    return self:GetPermanentData( CONST_OFFER_NAME .. "cur_mul_steps" ) or {}
end

Player.SetMulSteps = function( self, steps )
    return self:SetPermanentData( CONST_OFFER_NAME .. "cur_mul_steps", steps )
end

Player.SetCompletedMulPayment = function( self, value )
    return self:SetPermanentData( CONST_OFFER_NAME .. "_payment_finish", value )
end

Player.GetCompletedMulPayment = function( self, value )
    return self:GetPermanentData( CONST_OFFER_NAME .. "_payment_finish" ) or -1
end

Player.SetOfferNumber = function( self, value )
    return self:SetPermanentData( CONST_OFFER_NAME .. "_number", value )
end

Player.GetOfferNumber = function( self )
    return self:GetPermanentData( CONST_OFFER_NAME .. "_number" ) or 0
end

Player.ResetOfferData = function( self )
    self:SetMulSteps( { } )
    self:SetExecutableMulStep( nil )
    self:SetCurrentMulStep( nil )
    self:SetCompletedMulPayment( nil )
    self:SetPrivateData( "offer_last_wealth_time_left", false )
    self:SetPermanentData( CONST_OFFER_NAME .. "_finish", false )
end

Player.TryCompleteStep = function( self )
    local exec_mul = self:GetExecutableMulStep()
    local level_multiply_data = LEVEL_MULTIPLY[ exec_mul ]

    local completed_steps = 0
    local mul_steps_data = self:GetMulSteps()
    for step_id, step_value in pairs( level_multiply_data.steps ) do
        completed_steps = completed_steps + math.min( step_value.count, (mul_steps_data[ step_id ] or 0) )
    end

    if completed_steps >= level_multiply_data.steps_sum then
        local cur_mul = self:GetCurrentMulStep()
        local exec_mul = self:GetExecutableMulStep()
        self:SetCurrentMulStep( cur_mul + 1 )
        self:SetExecutableMulStep( exec_mul + 1 )

        onLastRichesTaskComplete( self, exec_mul )
    end

    return completed_steps
end

Player.TryAddPartCompleteStep = function( self, step_id, count )
    if not IsOfferActive() then return end
    
    local cur_mul = self:GetCurrentMulStep()
    if cur_mul == #LEVEL_MULTIPLY then return false end

    local changed = false
    local mul_steps_data = self:GetMulSteps()
    
    for k, v in pairs( LEVEL_MULTIPLY ) do
        local steps_mul_data = v.steps[ step_id ]
        if steps_mul_data and steps_mul_data.count > (mul_steps_data[ step_id ] or 0) then
            changed = true
            mul_steps_data[ step_id ] = (mul_steps_data[ step_id ] or 0) + (count or 1)
            break
        end
    end

    if changed then
        self:SetMulSteps( mul_steps_data )
        self:TryCompleteStep()
    end
end


local BATTLE_CASES =
{
    expanse = true,
    lockdown = true,
}

-- srun triggerEvent( "onCasesPurchaseCase", GetPlayer( 1 ), "expanse", nil, 2 )
function onCasesPurchaseCase_handler( case_id, case_type, count )
    source:TryAddPartCompleteStep( "case_" .. case_id, count )
    if BATTLE_CASES[ case_id ] then
        source:TryAddPartCompleteStep( "_any_case_battle", count )
    end
end
addEvent( "onCasesPurchaseCase" )
addEventHandler( "onCasesPurchaseCase", root, onCasesPurchaseCase_handler )

--srun triggerEvent( "onPlayerPremium", GetPlayer( 1 ), 30 )
function onPlayerPremium_handler( duration, cost, client_id )
    if client_id then return end
    source:TryAddPartCompleteStep( "premium_" .. duration )
end
addEvent( "onPlayerPremium" )
addEventHandler( "onPlayerPremium", root, onPlayerPremium_handler )

--srun triggerEvent( "onSpecialOfferPurchase", GetPlayer( 1 ), { model = "pack_50" } )
function onSpecialOfferPurchase_handler( data )
    source:TryAddPartCompleteStep( data.model )
end
addEvent( "onSpecialOfferPurchase" )
addEventHandler( "onSpecialOfferPurchase", root, onSpecialOfferPurchase_handler )

--srun triggerEvent( "onServerPlayerPurchaseBattlePassPremium", GetPlayer( 1 ) )
function onServerPlayerPurchaseBattlePassPremium_handler()
    source:TryAddPartCompleteStep( "premium_battle_pass" )
end
addEvent( "onServerPlayerPurchaseBattlePassPremium" )
addEventHandler( "onServerPlayerPurchaseBattlePassPremium", root, onServerPlayerPurchaseBattlePassPremium_handler )

--srun triggerEvent( "onServerPlayerPurchaseBattlePassBooster", GetPlayer( 1 ) )
function onServerPlayerPurchaseBattlePassBooster_handler()
    source:TryAddPartCompleteStep( "booster_battle_pass" )
end
addEvent( "onServerPlayerPurchaseBattlePassBooster" )
addEventHandler( "onServerPlayerPurchaseBattlePassBooster", root, onServerPlayerPurchaseBattlePassBooster_handler )

--srun triggerEvent( "SDEV2DEV_event_booster_purchase", GetPlayer( 1 ), "may_events" )
function SDEV2DEV_event_booster_purchase_handler( event_id, booster_id )
    if event_id == "may_events" then
        source:TryAddPartCompleteStep( "booster_may_events" )
    end
end
addEvent( "SDEV2DEV_event_booster_purchase" )
addEventHandler( "SDEV2DEV_event_booster_purchase", root, SDEV2DEV_event_booster_purchase_handler )

-- Donate test cmd
-- srun triggerEvent( "onServerPlayerPurchasedDonate", GetPlayer( 1 ), GetPlayer( 1 ), 490 )