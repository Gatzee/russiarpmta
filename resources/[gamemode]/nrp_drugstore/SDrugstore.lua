Extend( "SPlayer" )

function onPlayerMedsPurchase_handler( id, coef )
    local player = client

    local med = MEDS_LIST[ id ]
    if not med then return end

    local cost = math.floor( med.cost * ( coef or 1 ) )

    if player.health >= ( player:getData( "max_health" ) or 100 ) then
        player:ErrorWindow( "Ты уже здоров!" )
        return
    end
    
    if cost > player:GetMoney() then
        player:ErrorWindow( "Недостаточно средств!" )
        return
    end

    player:CompleteDailyQuest( "buy_medicine" )

    player:TakeMoney( cost, "med_purchase" )
    player:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy_product.wav" )
    player:SetHP( player.health + med.health )
    player:ShowInfo( "Спасибо за покупку!" )

    triggerEvent( "onPlayerDrugstorePurchase", player, cost, id, med.name )

    -- Retention task "pharmacy5"
    triggerEvent( "onFirstaidUse", player )
end
addEvent( "onPlayerMedsPurchase", true )
addEventHandler( "onPlayerMedsPurchase", root, onPlayerMedsPurchase_handler )