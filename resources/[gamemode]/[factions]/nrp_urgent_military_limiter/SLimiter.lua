loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )

function onMilitaryVacationLeaveCheck_handler()
    local player = client
    if player:IsOnUrgentMilitary() then
        if not player:IsUrgentMilitaryVacation() then
            player:EnterOnUrgentMilitaryBase()
            player:ShowError( "Куда собрался, боец?" )
        end
    end
end
addEvent( "onMilitaryVacationLeaveCheck", true )
addEventHandler( "onMilitaryVacationLeaveCheck", root, onMilitaryVacationLeaveCheck_handler )

function onUrgentMilitaryDamageWarn_handler()
    if client:IsOnUrgentMilitary() then
        client:Jail( _, _, 5 * 60, "ДМ на срочной службе" )
    end
end
addEvent( "onUrgentMilitaryDamageWarn", true )
addEventHandler( "onUrgentMilitaryDamageWarn", resourceRoot, onUrgentMilitaryDamageWarn_handler )