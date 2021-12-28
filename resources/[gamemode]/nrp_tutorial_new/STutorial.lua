


function onPlayerStartRegisterRequest_handler()
    iprint("Tutorial triggered for "..getPlayerName(source))
    triggerClientEvent(source, 'ShowUIRegister', source)
end
addEvent('onPlayerStartRegisterRequest', true)
addEventHandler('onPlayerStartRegisterRequest', root, onPlayerStartRegisterRequest_handler)


function PlayerEnterRegisterData_handler(data)
    iprint(data.nickname..' почти зарегался')
    triggerEvent('onAsyncRegisterProcess', client, client, data)
end
addEvent('PlayerEnterRegisterData', true)
addEventHandler('PlayerEnterRegisterData', root, PlayerEnterRegisterData_handler)

function onPlayerRegister_handler(player)
    triggerClientEvent('PlayerRegisterCompleted', player)
end
addEvent('onPlayerRegister', true)
addEventHandler('onPlayerRegister', root, onPlayerRegister_handler)




