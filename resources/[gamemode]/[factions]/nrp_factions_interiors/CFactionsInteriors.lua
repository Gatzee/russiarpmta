loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CInterior" )
Extend( "CPlayer" )
Extend( "ShFactionsInteriors" )

TPOINTS = { }

function onResourceStart_handler()
    for i, conf in pairs( FACTIONS_INTERIORS ) do
        local outside_conf = {
            marker_text = conf.marker_text,
            text = "ALT Взаимодействие",
            x = conf.outside.x,
            y = conf.outside.y,
            z = conf.outside.z,
            dimension = 0,
            interior = 0,
            radius = conf.radius or 2,
            color = { 0, 0, 255, 40 },
        }
        local outside_tpoint = TeleportPoint( outside_conf )
        outside_tpoint.element:setData( "material", true, false )
        outside_tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 0, 255, 255, conf.drop_radius or 1.55 } )
        outside_tpoint.PreJoin = conf.outside_check

        local inside_conf = {
            marker_text = conf.inside_marker_text or "Выход",
            text = "ALT Взаимодействие",
            x = conf.inside.x,
            y = conf.inside.y,
            z = conf.inside.z,
            dimension = conf.inside_dimension,
            interior = conf.inside_interior,
            radius = conf.radius or 2,
            color = { 0, 0, 255, 40 },
        }
        local inside_tpoint = TeleportPoint( inside_conf )
        inside_tpoint.element:setData( "material", true, false )
        inside_tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 0, 255, 255, conf.drop_radius or 1.55 } )
        inside_tpoint.PreJoin = conf.inside_check

        outside_tpoint.PostJoin = function( )
            local position = inside_tpoint.colshape.position
            localPlayer:Teleport( Vector3( position.x, position.y, position.z ), inside_tpoint.dimension, inside_tpoint.interior, 1000 )

            if conf.OnEnter then conf.OnEnter( ) end

            triggerEvent( "onPlayerMoveQuestElements", localPlayer, localPlayer.dimension )
            triggerServerEvent( "onTaxiPrivateFailWaiting", localPlayer, "Пассажир отменил заказ", "Ты зашёл в помещение, заказ в Такси отменен" )
        end

        inside_tpoint.PostJoin = function( )
            local position = outside_tpoint.colshape.position
            localPlayer:Teleport( Vector3( position.x, position.y, position.z ), outside_tpoint.dimension, outside_tpoint.interior, 50 )

            triggerEvent( "onPlayerMoveQuestElements", localPlayer, localPlayer.dimension )
            triggerServerEvent( "onTaxiPrivateFailWaiting", localPlayer, "Пассажир отменил заказ", "Ты зашёл в помещение, заказ в Такси отменен" )
        end
    end
end
addEventHandler( "onClientResourceStart", resourceRoot, onResourceStart_handler )