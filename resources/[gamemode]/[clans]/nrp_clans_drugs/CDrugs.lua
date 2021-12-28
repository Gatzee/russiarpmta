--[[DRUGS = {
	{
		name = "Снилс",
		regeneration = 5,
		regeneration_freq = 5,
		damage_mul = 0.95,
		price = 6000,
		duration = 60,
	},
	{
		name = "Марья Ивановна",
		regeneration = 6,
		regeneration_freq = 5,
		damage_mul = 0.9,
		price = 10600,
		duration = 60,
	},
	{
		name = "Пакетик Шлака",
		regeneration = 5,
		regeneration_freq = 7,
		damage_mul = 0.85,
		price = 15200,
		duration = 60,
	},
}
}]]

loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "Globals" )
Extend( "ShClans" )

function IsOnDrugs()
    return IS_ON_DRUGS
end

function SetOnDrugs( num )
    if not num then
        ResetOnDrugs()
    end
    
    if num and DRUGS[ num ] then
        if IS_ON_DRUGS then
            localPlayer:ShowError( "Притормози, ты и так под кайфом" )
            return
        else
            local cooldown = localPlayer:GetClanUpgradeLevel( CLAN_UPGRADE_DISEASE_RESISTANCE ) == 4 and 60 * 1000 or 5 * 60 * 1000
            if DRUG_USAGE_TICK and getTickCount() - DRUG_USAGE_TICK <= cooldown then
                localPlayer:ShowError( "Ты же не хочешь передозировки? Подожди немного!" )
                return
            end
        end

        ResetOnDrugs()

        local drug_conf = DRUGS[ num ]
        local duration = drug_conf.duration * ( 1 + localPlayer:GetClanBuffValue( CLAN_UPGRADE_DRUGS_TIME ) / 100 )
        
        REGENERATION_TIMER = setTimer( Regenerate, math.floor( drug_conf.regeneration_freq * 1000 ), 0, num )
        DRUGS_STATE_TIMER = setTimer( ResetOnDrugs, math.floor( duration * 1000 ), 1 )

        addEventHandler( "onClientPlayerDamage", localPlayer, SuppressDamage, true, "low-10000" )
        addEventHandler( "onClientPlayerWasted", localPlayer, ResetOnDrugs )
        addEventHandler( "ShowDeathCountdown", localPlayer, ResetOnDrugs )
        

        IS_ON_DRUGS = drug_conf
        DRUG_USAGE_TICK = getTickCount()

        --setCameraGoggleEffect( "thermalvision", false )
        setSkyGradient( math.random( 255 ), math.random( 255 ), math.random( 255 ), math.random( 255 ), math.random( 255 ), math.random( 255 ) )
        setCameraShakeLevel( math.random( 15, 30 ) )

        triggerEvent( "onClientPlayerUseDrugs", localPlayer )
        triggerServerEvent( "onPlayerChangeDrugIntexiation", localPlayer, num, duration )

        return IS_ON_DRUGS
    end
end

function ResetOnDrugs()
    if isTimer( REGENERATION_TIMER ) then killTimer( REGENERATION_TIMER ) end
    REGENERATION_TIMER = nil
    if isTimer( DRUGS_STATE_TIMER ) then killTimer( DRUGS_STATE_TIMER ) end
    DRUGS_STATE_TIMER = nil
    removeEventHandler( "onClientPlayerDamage", localPlayer, SuppressDamage, true, "low-10000" )
    removeEventHandler( "onClientPlayerWasted", localPlayer, ResetOnDrugs )
    removeEventHandler( "ShowDeathCountdown", localPlayer, ResetOnDrugs )
    --setCameraGoggleEffect( "normal", false )
    resetSkyGradient()
    setCameraShakeLevel( 0 )
    IS_ON_DRUGS = nil
end

function Regenerate( num )
    local drug_conf = DRUGS[ num ]
    local add_hp = drug_conf.regeneration * ( 1 + localPlayer:GetClanBuffValue( CLAN_UPGRADE_HEALING ) / 100 )
    localPlayer:SetHP( localPlayer.health + add_hp )
end

function SuppressDamage( _, _, _, loss )
    local drug_conf = IS_ON_DRUGS
    localPlayer:SetHP( localPlayer.health + ( 1 - loss * drug_conf.damage_mul ) )
end