Extend( "CPlayer" )
Extend( "CInterior" )
Extend( "ib" )
Extend( "ShClans" )
Extend( "ShUtils" )

PLAYER_DISEASES = { }
ANIMATION_SKIP = false

local POINT_TREAT = {
    { x = 1938.660, y = 310.763, z = 659.966, interior = 1, dimension = 1 },
    { x = 444.332, y = -1600.25, z = 1019.968, interior = 1, dimension = 1 }, 
    { x = -1986.804, y = 1987.314, z = 1797.890 - 1, interior = 2, dimension = 2 }, 
}

local disease_stage_notification = {
    { text = "У вас начались симптомы заболевания. Вам стоит обратиться к врачу" },
    { text = "Болезнь прогрессирует. Обратитесь к врачу" },
    { text = "Вы серьезно больны! Обратитесь к врачу" },
}

function onBuyTreatment( )
    if localPlayer:getData( "current_quest" ) then
        localPlayer:ShowInfo( "Заверши текущую задачу!" )
        return
    end

    if not localPlayer:HasDisease( ) then
        localPlayer:ShowInfo( "Вы не больны!" )
        return
    end

    showCursor( true )
    ibConfirm(
        {
            title = "ПЛАТНЫЙ ВРАЧ", 
            text = "Ты хочешь оплатить услуги врача за",
            cost = 20000,
            cost_is_soft = true,
            fn = function( self )
                triggerServerEvent( "onPlayerBuyTreat", localPlayer )
                self:destroy()
                showCursor( false )
            end,
            fn_cancel = function( )
                showCursor( false )
            end,
            escape_close = true,
        }
    )
end

local function createPointBuyTreat( config )
    local point = TeleportPoint( 
		{ 
			x = config.x, y = config.y, z = config.z + 1, 
			interior = config.interior, dimension = config.dimension,
			radius = 1.5, 
			color = { 255, 121, 38, 50 },
			keypress = "lalt", 
			text = "ALT Взаимодействие",
			PostJoin = onBuyTreatment,
			marker_text = "Платный Врач",
		} 
    )
    
    point.element:setData( "material", true, false )
	point:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 121, 38, 255, 1.15 } )
end

for _, config in pairs( POINT_TREAT ) do
    createPointBuyTreat( config )
end

local function ShowDiseaseStageInfo( stage )
    local pNotification = 
    {
        title = "Больница",
        msg = "Обратиться в ближайшую поликлинику можно по адресу:",
        special = "diseases_notification",
        position = {
            { x = 399.250, y = -2445.291, z = 22.208 },
            { x = 1877.856, y = -528.05, z = 60.791 },
            { x = 1422.17, y = 2722.03, z = 9.91 },
        }
    }

    localPlayer:PhoneNotification( pNotification )

    if not ANIMATION_SKIP or not disease_stage_notification[ stage ] then return end
    localPlayer:ShowInfo( disease_stage_notification[ stage ].text )
end

local function ShowDiseaseInfoDelayed( stage )
    setTimer( ShowDiseaseStageInfo, 2000, 1, stage )
end

local function PrepareToShowDiseaseInfo( )
    ShowDiseaseInfoDelayed( 1 )
    removeEventHandler( "onClientRestore", root, ShowDiseaseInfoDelayed )
    addEventHandler( "onClientRestore", root, ShowDiseaseInfoDelayed )
end

addEventHandler( "onClientMinimize", root, function( )
    removeEventHandler( "onClientRestore", root, ShowDiseaseInfoDelayed )
end )

function onClientPlayerUpdateDiseases_handler( data, value )
    if type( data ) == "number" then
        local old_stage = PLAYER_DISEASES[ data ]
        PLAYER_DISEASES[ data ] = value and value > 0 and value or nil

        if value == 1 and ( old_stage or 0 ) == 0 then
            PrepareToShowDiseaseInfo( )
        elseif value and value > 0 and ( old_stage or 0 ) > value then
            triggerEvent( "onClientSetTreatingTimer", localPlayer, TREATING_COOLDOWN )
        elseif value > 1 then 
            ShowDiseaseInfoDelayed( value )
        end
    else
        PLAYER_DISEASES = data
        PrepareToShowDiseaseInfo( )
    end

    local max_health = 100
    local max_calories = 100
    local max_stamina = 100
    DISEASE_STAGE = false

    for disease_id, stage in pairs( PLAYER_DISEASES ) do
        local debuffs_by_stage = DISEASES_INFO[ disease_id ].debuffs
        local debuffs = debuffs_by_stage and debuffs_by_stage[ stage ]
        if debuffs then
            if debuffs.max_health then
                max_health = math.min( debuffs.max_health, max_health )
            end
            if debuffs.max_calories then
                max_calories = math.min( debuffs.max_calories, max_calories )
            end
            if debuffs.max_stamina then
                max_stamina = math.min( debuffs.max_stamina, max_stamina )
            end
        end

        DISEASE_STAGE = stage
    end

    localPlayer:SetBuff( "max_health", max_health - 100, "disease" )
    localPlayer:SetBuff( "max_calories", max_calories - 100, "disease" )
    localPlayer:SetBuff( "max_stamina", max_stamina - 100, "disease" )

    localPlayer:setData( "has_disease", next( PLAYER_DISEASES ) and true, false )
    localPlayer:setData( "disease_stage", DISEASE_STAGE, false )
    localPlayer:setData( "diseases", PLAYER_DISEASES, false )
end
addEvent( "onClientPlayerUpdateDiseases", true )
addEventHandler( "onClientPlayerUpdateDiseases", localPlayer, onClientPlayerUpdateDiseases_handler, true, "high" )