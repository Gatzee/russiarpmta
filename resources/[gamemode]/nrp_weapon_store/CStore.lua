Extend( "CPlayer" )
Extend( "ib" )
Extend( "CAI" )
Extend( "CInterior" )
Extend( "ShUtils" )
Extend( "CActionTasksUtils" )

Store = {}
Store.ui = {}
Store.cart_items = {}

Store.dealer_config = {
    x = 0,
    y = 0,
    z = 0,
    start_point = Vector3( 149.925, -1275.848, 1169.24 ),
    end_point = Vector3( 149.935, -1266.167, 1169.24 ),
    move_type = 4,
    distance = 0.3,
    speed_limit = 1,
    end_callback = {
        func = function( )
            Store.dealer_config.start_point, Store.dealer_config.end_point = Store.dealer_config.end_point, Store.dealer_config.start_point

            -- поворот к игроку
            local direction = localPlayer.position - Store.dealer.position
            local pos = Store.dealer.position + direction:getNormalized( )
            AddAIPedPatternInQueue( Store.dealer, AI_PED_PATTERN_MOVE_TO_POINT, { x = pos.x, y = pos.y, z = pos.z, move_type = 4 }, math.random(500, 1500 ) )

            MoveDealer( )
        end,
        args = {},
    }
}

STORE_MARKERS =
{
    [1] = {
        ["entrance"] = {
            x = 172.112,
            y = -2130.621 + 860,
            z = 22.021,
            radius = 2,
            interior = 0,
            dimension = 0,
            marker_text = "Оружейный магазин",
            text = "ALT Взаимодействие",
            color = { 0, 150, 255, 50 }
        },
        ["exit"] =  {
            x = 142.61,
            y = -1270.59,
            z = 1169.238,
            radius = 1.5,
            interior = 1,
            dimension = 1,
            marker_text = "Выход",
            text = "ALT Взаимодействие",
            color = { 0, 150, 255, 50 }
        },
        ["shop"] = {
            x = 147.397,
            y = -1275.243,
            z = 1169.238,
            radius = 1.2,
            interior = 1,
            dimension = 1,
            marker_text = "Продавец оружия",
            text = "ALT Взаимодействие",
            color = { 0, 150, 255, 50 }
        },
    },
}

local entrance_marker, shop_marker, exit_marker

function OnClientResourceStart( )
    for config_id, config in pairs( STORE_MARKERS ) do
        CreateWeaponStore( config_id, config )
    end
end
addEventHandler( "onClientResourceStart", resourceRoot, OnClientResourceStart )

function CreateWeaponStore( config_id, config )
    -- entrance
    entrance_marker = TeleportPoint( config.entrance )
    entrance_marker:SetImage( "img/marker_weapon.png" )
    entrance_marker.element:setData( "material", true, false )
    entrance_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.45 } )

    entrance_marker.PreJoin = function( self, player )
        return true
    end
    entrance_marker.PostJoin = function( self )
        if localPlayer:GetBlockInteriorInteraction() then
			localPlayer:ShowInfo( "Вы не можете войти во время задания" )
			return false
        end
        
        localPlayer:Teleport( Vector3( config.exit.x, config.exit.y, config.exit.z ), config.exit.dimension, config.exit.interior, 1000 )
        triggerServerEvent( "SwitchPosition", resourceRoot )
        localPlayer:CompleteDailyQuest( "np_visit_weapon_store" )
        OnPlayerEnterWeaponStore( config_id )
    end
    entrance_marker.PostLeave = function( self )
        triggerEvent( "ShowWeaponStoreUI", localPlayer, false )
    end

    entrance_marker.elements = { }
    entrance_marker.elements.blip = Blip( entrance_marker.x, entrance_marker.y, entrance_marker.z, 0, 2, 255, 0, 0, 255, 0, 300 )
    entrance_marker.elements.blip:setData( "extra_blip", 68, false )

    -- exit
    exit_marker = TeleportPoint( config.exit )
    exit_marker.element:setData( "material", true, false )
    exit_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.15 } )
    exit_marker.PreJoin = function( self, player )
        return true
    end
    exit_marker.PostJoin = function( self )
        localPlayer:Teleport( Vector3( config.entrance.x, config.entrance.y, config.entrance.z ), config.entrance.dimension, config.entrance.interior, 50 )
        triggerServerEvent( "SwitchPosition", resourceRoot )
        OnPlayerExitWeaponStore( )
    end
    exit_marker.PostLeave = function( self )
        triggerEvent( "ShowWeaponStoreUI", localPlayer, false )
    end
end

function InitStore( dimension )
    Store.dealer = CreateAIPed( 90, Store.dealer_config.start_point, 90 )
    Store.dealer.dimension = dimension
    Store.dealer.interior = 1
    Store.dealer.walkingStyle = 54
    SetUndamagable( Store.dealer, true )
    MoveDealer( )
end

function MoveDealer( )
    if not isElement( Store.dealer ) then return end

    setPedAnimation( Store.dealer, nil )

    Store.dealer_config.x = Store.dealer_config.end_point.x
    Store.dealer_config.y = Store.dealer_config.end_point.y
    Store.dealer_config.z = Store.dealer_config.end_point.z
    AddAIPedPatternInQueue( Store.dealer, AI_PED_PATTERN_MOVE_TO_POINT, Store.dealer_config, math.random( 5000, 12000 ) )
end

function OnPlayerEnterWeaponStore( config_id )

    if type( config_id ) ~= "number" or not STORE_MARKERS[ config_id ] then return end

    local config = STORE_MARKERS[ config_id ]

    -- shop
    shop_marker = TeleportPoint( config.shop )
    shop_marker.element:setData( "material", true, false )
    shop_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 0.86 } )

    shop_marker.PreJoin = function( self, player )
        return true
    end
    shop_marker.PostJoin = function( self )
        ShowUI_WeaponStore( true )
    end
    shop_marker.PostLeave = function( self )
        triggerEvent( "ShowWeaponStoreUI", localPlayer, false )
    end

    InitStore( localPlayer.dimension )
end

function OnPlayerExitWeaponStore( )
	if shop_marker and isElement( shop_marker.element ) then
		shop_marker:destroy( )
        shop_marker = nil
	end

	if isElement( Store.dealer ) then
        ClearAIPed( Store.dealer )
		destroyElement( Store.dealer )
        Store.dealer = nil
	end
end
