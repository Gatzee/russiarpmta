loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SPlayer")

function onPlayerOpenedAccessToDailyQuests_handler( player )
end
addEvent( "onPlayerOpenedAccessToDailyQuests", true )
addEventHandler( "onPlayerOpenedAccessToDailyQuests", root, onPlayerOpenedAccessToDailyQuests_handler )