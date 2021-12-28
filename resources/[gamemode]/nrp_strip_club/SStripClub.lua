loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SDB" )

STRIP_CLUB_COLSHAPE = nil
START_RESOURCE_TIMESTAMP = nil

addEventHandler( "onResourceStart", resourceRoot, function()
    CreatePodiumBankDatabase()
    STRIP_CLUB_COLSHAPE = createColCuboid( STRIP_CLUB_ZONE.position, STRIP_CLUB_ZONE.size )
    START_RESOURCE_TIMESTAMP = getRealTimestamp()
    
    InitPayLeadersTv()
end )

-- Получение игроков внутри стрипклуба
function GetPlayersInStripClub()
    return getElementsWithinColShape( STRIP_CLUB_COLSHAPE, "player" )
end

-- Запрос на вход в стрип клуб
function onServerPlayerWantEnterStripClub_handler( strip_id )
    if not isElement( client ) then return end

    local can_join, message = client:CanJoinToEvent({ event_type = "club" })
    if not can_join then 
        client:ShowError( message )
        return 
    end

    if client:TakePlayerPrice( ENTER_PRICE, "soft", "enter_strip_club" ) then  
        local strip_data = STRIP_DATA[ strip_id ]
        client:Teleport( strip_data.inside_position, strip_data.insdie_dim, strip_data.inside_int, 1000 )
        
        local podium_dance_data = IsDanceProcess() and PODIUM_DANCE_DATA or false
        triggerClientEvent( client, "onClientPlayerEnterStripClub", resourceRoot, strip_id, PAY_LEADESRS, podium_dance_data, START_RESOURCE_TIMESTAMP )
        setElementData( client, "in_strip_club", strip_id, false )

        triggerEvent( "onPlayerSomeDo", client, "enter_stip_club" ) -- achievements

        client:CompleteDailyQuest( "np_visit_stripclub" )

        client:SetPrivateData( "casino_id", CASINO_THREE_AXE )
    else
        localPlayer:ShowError( "У вас недостаточно средств для входа в стрип клуб")
    end
end
addEvent( "onServerPlayerWantEnterStripClub", true )
addEventHandler( "onServerPlayerWantEnterStripClub", root, onServerPlayerWantEnterStripClub_handler )

-- Выход из стрип клуба
function onServerPlayerWantLeaveStripClub_handler( strip_id )
    if STRIP_DATA[ strip_id ] then
        local strip_data = STRIP_DATA[ strip_id ]
        client:Teleport( Vector3( strip_data.x, strip_data.y, strip_data.z ), strip_data.dimension, strip_data.interior )
        triggerClientEvent( client, "SwitchPosition", resourceRoot )
    end
    removeElementData( client, "in_strip_club" )

    client:SetPrivateData( "casino_id", false )
end
addEvent( "onServerPlayerWantLeaveStripClub", true )
addEventHandler( "onServerPlayerWantLeaveStripClub", resourceRoot, onServerPlayerWantLeaveStripClub_handler )

-- Потеря сознания от алкоголя, спавним игрока на парковке
function onServerPlayerLostConsciousness_handler()
    local strip_id = getElementData( client, "in_strip_club")
    local strip_data = STRIP_DATA[ strip_id ]    
    local position = Vector3( strip_data.woke_up_position.x, strip_data.woke_up_position.y, strip_data.woke_up_position.z ):AddRandomRange( 6 )

    client:Teleport( position, 0, 0 )
    removeElementData( client, "in_strip_club" )

    triggerEvent( "onPlayerSomeDo", client, "maximum_intoxication" ) -- achievements
    
    triggerClientEvent( client, "onClientPlayerWokeUp", resourceRoot, strip_id, position.x, position.y, position.z )
end
addEvent( "onServerPlayerLostConsciousness", true )
addEventHandler( "onServerPlayerLostConsciousness", root, onServerPlayerLostConsciousness_handler )

function onPlayerLeftGame()
    if isElementWithinColShape( source, STRIP_CLUB_COLSHAPE ) then
        source.position = Vector3( 187.5126, -333.1531, 20.2034 ) + Vector3( math.random(-2 , 2), math.random(-2, 2), 0 )
        source.dimension = 0
        source.interior = 0
    end
end
addEvent( "onPlayerPreLogout", true )
addEventHandler( "onPlayerPreLogout", root, onPlayerLeftGame )

addEventHandler( "onPlayerWasted", root, function()
    if getElementData( source, "in_strip_club" ) then
        setElementData( source, "in_strip_club", nil, false )
    end
end )

--------------------------
-- Утилиты
--------------------------

Player.TakePlayerPrice = function( self, price, currency, product )
    if currency == "soft" then
		return self:TakeMoney( price, product )
	elseif currency == "hard" then
        return self:TakeDonate( price, product, "NRPDszx5x" )
	end
end

Player.OnBoughtService = function( self, price, currency )
    local pay_money = self:GetPermanentData( "pay_strip_money" ) or 0
    if currency == "soft" then
		pay_money = pay_money + price
	elseif currency == "hard" then
        pay_money = pay_money + ( price * 1000 )
    end
    self:SetPermanentData( "pay_strip_money", pay_money )
    RefreshPayLeaders( self )
end