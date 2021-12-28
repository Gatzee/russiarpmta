function ShowViphouseControlUI_handler( conf )
    conf.is_viphouse = true
    local house_config = VIP_HOUSES_REVERSE[ conf.hid ]
    conf.cost = house_config.cost
    conf.days = conf.paid_days or 0
    conf.paid_upgrade = 0
    local daily_cost = house_config.daily_cost * ( conf.metering_factor or 1 )
    local services = conf.services
    for i, v in pairs( services ) do
        if v.purchased then
            daily_cost = daily_cost - services[ i ].reduction
            conf.paid_upgrade = i
        end
    end
    conf.cost_day = daily_cost
    triggerEvent( "ShowUIControl", resourceRoot, conf )
end
addEvent( "ShowViphouseControlUI", true )
addEventHandler( "ShowViphouseControlUI", root, ShowViphouseControlUI_handler )


function onPlayerAskAccessToVillage_handler( id, guest_name, guest_id )
    InitModules( )
    ibWindowSound( )
    showCursor( true )
    ibConfirm( {
        title = "ЗАПРОС",
        text = "Игрок "..guest_name.." просит доступ к вилле " .. tostring( id ),
        fn = function ( self )
            self:destroy( )
            ibClick( )
            showCursor( false )
            triggerServerEvent( "onCheckCanGuestAccessToVillage", resourceRoot, id, true, guest_id  )
        end,
        fn_cancel = function ( self )
            self:destroy( )
            ibClick( )
            showCursor( false )
            triggerServerEvent( "onCheckCanGuestAccessToVillage", resourceRoot, id, false, guest_id  )
        end,
    } )
end
addEvent( "onPlayerAskAccessToVillage", true )
addEventHandler( "onPlayerAskAccessToVillage", resourceRoot, onPlayerAskAccessToVillage_handler )
