loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SDB" )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "SUtils" )

COMMAND_ACCESS_LEVELS = {
    [ 'respawn' ] = 0,
    [ 'suicide' ] = 0,

    [ 'admins' ] =      { ACCESS_LEVEL_INTERN, "/admins - Список админов онлайн" },
    [ 'inv' ] =         { ACCESS_LEVEL_INTERN, "/inv - Стать невидимым" },
    [ 'global' ] =      { ACCESS_LEVEL_GAME_MASTER, "/global <текст> - Глобальное сообщение в чат" },
    [ 'alarm' ] =       { ACCESS_LEVEL_GAME_MASTER, "/alarm <текст> - Отправить уведомление в телефон всем игрокам" },
    [ 'commands' ] =    { ACCESS_LEVEL_INTERN, "/commands - Список доступных команд" },
    [ 'reviving' ] =      { ACCESS_LEVEL_INTERN, "/reviving <id> - Возрадить игрока" },


    [ 'pkick' ] =       { ACCESS_LEVEL_INTERN, "/pkick <id> <причина> - Кик игрока с сервера" },
    [ 'pmute' ] =       { ACCESS_LEVEL_INTERN, "/pmute <id> <причина> - Дать мут игроку" },
    [ 'punmute' ] =     { ACCESS_LEVEL_INTERN, "/punmute <id> - Снять мут с игрока" },
    [ "fixveh" ] =      { ACCESS_LEVEL_HELPER, "/fixveh <vid> - Починить машину" },
    [ "flip" ] =        { ACCESS_LEVEL_HELPER, "/flip <vid> - Перевернуть машину на колеса" },
    [ "get" ] =         { ACCESS_LEVEL_INTERN, "/get <id> - Телепортировать игрока к себе" },
    [ "pwarp" ] =       { ACCESS_LEVEL_INTERN, "/pwarp <id> - Телепортироваться к игроку" },
    [ "vget" ] =        { ACCESS_LEVEL_INTERN, "/vget <vid> - Телепортировать машину к себе" },
    [ "vgoto" ] =       { ACCESS_LEVEL_GAME_MASTER, "/vgoto <vid> - Телепортироваться к машине" },
    [ "setfuel" ] =     { ACCESS_LEVEL_HELPER, "/setfuel <vid> <топливо> - Установить топливо машине (в литрах)" },
    [ 'pfreeze' ] =         { ACCESS_LEVEL_MODERATOR, "/pfreeze <id> - Заморозить игрока" },
    [ 'punfreeze' ] =       { ACCESS_LEVEL_MODERATOR, "/punfreeze <id> - Разморозить игрока" },
    [ 'jailoffline' ] =     { ACCESS_LEVEL_INTERN, "/jailoffline <uid> <время> <причина> - Посадить игрока в КПЗ оффлайн" },
    [ 'jail' ] =            { ACCESS_LEVEL_INTERN, "/jail <id> <время> <причина> - Посадить игрока в КПЗ на N минут" },
    [ 'unjail' ] =          { ACCESS_LEVEL_INTERN, "/unjail <id> - Вытащить игрока из тюрьмы" },
    [ 'vtempsetcolor' ] =   { ACCESS_LEVEL_SUPERVISOR, "/vtempsetcolor <vid> <r> <g> <b> - Цвет временной машины" },
    [ 'tempnickname' ] =    { ACCESS_LEVEL_MODERATOR, "/tempnickname <id> <имя> <фамилия> - Временное имя игроку" },
    [ 'tempskin' ] =        { ACCESS_LEVEL_MODERATOR, "/tempskin <id> <скин> - Временный скин игроку" },
    [ 'sethp' ] =           { ACCESS_LEVEL_MODERATOR, "/sethp <id> <число> - Установить хп игрока на нужный уровень" },


    [ 'pban' ] =                { ACCESS_LEVEL_MODERATOR, "/pban <id> <время> <причина> - Забанить игрока" },
    [ 'pbanoffline' ] =         { ACCESS_LEVEL_MODERATOR, "/pbanoffline <uid> <время> <причина> - Забанить игрока оффлайн" },
    [ 'punban' ] =              { ACCESS_LEVEL_SUPERVISOR, "/punban <uid> - Снять бан с игрока" },
    [ 'setnickname' ] =         { ACCESS_LEVEL_MODERATOR, "/setnickname <id> <имя> <фамилия> - Сменить ник игроку" },

    [ 'setfaction' ] =          { ACCESS_LEVEL_SENIOR_MODERATOR, "/setfaction <id> <фракция> - Установить игрока во фракцию + дать военник" },
    [ 'setfactionlevel' ] =     { ACCESS_LEVEL_SENIOR_MODERATOR, "/setfactionlevel <id> <ранг> - Установить ранг во фракции (" .. FACTION_OWNER_LEVEL .. " для лидера)" },
    [ 'offsetfaction' ] =       { ACCESS_LEVEL_SENIOR_MODERATOR, "/offsetfaction <uid> <фракция> - Установить игрока во фракцию (оффлайн)" },
    [ 'offsetfactionlevel' ] =  { ACCESS_LEVEL_SENIOR_MODERATOR, "/offsetfactionlevel <uid> <ранг> - Установить ранг во фракции (оффлайн)" },

	[ 'setmayor' ] =            { ACCESS_LEVEL_SUPERVISOR, "/setmayor <мэрия> <id> - Назначить игрока Мэром города (7 - Новороссийск, 8 - Горки, 13 - МСК)" },
    [ 'removemayor' ] =         { ACCESS_LEVEL_SUPERVISOR, "/removemayor <мэрия> <причина> - Снять мэра города (7 - Новороссийск, 8 - Горки, 13 - МСК)" },
    [ 'reseteconomy' ] =        { ACCESS_LEVEL_SUPERVISOR, "/reseteconomy <мэрия> - Сбросить настройки экономики (7 - Новороссийск, 8 - Горки, 13 - МСК)" },
    [ 'startvoting' ] =         { ACCESS_LEVEL_SUPERVISOR, "/startvoting <мэрия> - Начать досрочные выборы (7 - Новороссийск, 8 - Горки, 13 - МСК)" },

    [ 'weapongive' ] =          { ACCESS_LEVEL_MODERATOR, "/weapongive <id> <ID оружия> <патроны> - Выдать оружие" },
    [ 'weapontake' ] =          { ACCESS_LEVEL_MODERATOR, "/weapontake <id> <ID оружия> <патроны> - Отобрать оружие" },
    [ 'takeallweapons' ] =      { ACCESS_LEVEL_MODERATOR, "/takeallweapons <id> - Отобрать всё оружие" },

    [ "setrating" ] =      { ACCESS_LEVEL_SUPERVISOR, "/setrating <id> <кол-во> <причина> - Изменить социальный рейтинг игрока" },

    [ 'givehelper' ] =      { ACCESS_LEVEL_SUPERVISOR, "/givehelper <id> - Дать права хелпера" },
    [ 'takehelper' ] =      { ACCESS_LEVEL_SUPERVISOR, "/takehelper <id> - Забрать права хелпера" },
    [ 'givemoderator' ] =   { ACCESS_LEVEL_SUPERVISOR, "/givemoderator <id> - Дать права модератора" },
    [ 'takemoderator' ] =   { ACCESS_LEVEL_SUPERVISOR, "/takemoderator <id> - Забрать права модератора" },
    [ 'camhack' ]  =        { ACCESS_LEVEL_HEAD_ADMIN, "/camhack <id> - Дать/забрать права на использование F5 игроку" },
    [ 'giveexp' ] =         { ACCESS_LEVEL_SUPERVISOR, "/giveexp <id> <опыт> - Выдать опыт игроку" },
    [ 'giveclanexp' ] =     { ACCESS_LEVEL_SUPERVISOR, "/giveclanexp <id> <опыт> - Выдать ранговый опыт в клане игроку" },
    [ 'license' ] =         { ACCESS_LEVEL_SUPERVISOR, "/license <id> <права> - Выдать права игроку (1 - авто, 4 - автобус)" },
    [ 'takelicense' ] =     { ACCESS_LEVEL_SUPERVISOR, "/takelicense <id> <права> - Снять права игроку (1 - авто, 4 - автобус)" },
    [ 'givemoney' ] =       { ACCESS_LEVEL_SUPERVISOR, "/givemoney <id> <деньги> - Выдать деньги игроку" },
    [ 'takemoney' ] =       { ACCESS_LEVEL_SUPERVISOR, "/takemoney <id> <деньги> - Снять деньги игроку" },
    [ 'takedonate' ] =      { ACCESS_LEVEL_SUPERVISOR, "/takedonate <id> <донат> - Снять донат игроку" },
    [ 'givedonate' ] =      { ACCESS_LEVEL_SUPERVISOR, "/givedonate <id> <донат> - Выдать донат игроку" },
    [ "vdelete" ] =         { ACCESS_LEVEL_SUPERVISOR, "/vdelete <vid> - Удалить временную машину" },
    [ "veh" ] =             { ACCESS_LEVEL_SUPERVISOR, "/veh <vmodel> - Заспавнить временную машину" },
    [ "vpermanentadd" ] =   { ACCESS_LEVEL_HEAD_ADMIN, "/vpermanentadd <vmodel> <uid> - Создать постоянную машину для игрока" },
    [ "vpermanentremove" ] ={ ACCESS_LEVEL_SUPERVISOR, "/vpermanentremove <vid> <uid> - Удалить постоянную машину игрока" },
    [ "skin" ] =            { ACCESS_LEVEL_SUPERVISOR, "/skin <id> <скин> - Установить игроку скин" },
    [ "setlevel" ] =        { ACCESS_LEVEL_SUPERVISOR, "/setlevel <id> <уровень> <причина> - Изменить уровень игрока на указанный" },
    [ 'adminshide' ] =      { ACCESS_LEVEL_SUPERVISOR, "/adminshide - Спрятаться из списка админов" },

    [ 'toprison' ] =        { ACCESS_LEVEL_HELPER, "/toprison <id> - Перевести из КПЗ в колонию" },
    [ 'freeprison' ] =      { ACCESS_LEVEL_HELPER, "/freeprison <id> - Освободить из колонии" },
    [ "vsetflag" ] =        ACCESS_LEVEL_DEVELOPER,
    [ "vsetowner" ] =       ACCESS_LEVEL_DEVELOPER,
    [ "setnumberscolor" ] = ACCESS_LEVEL_DEVELOPER,
    [ "vsetcolor" ] =       ACCESS_LEVEL_DEVELOPER,
    --[ "setfuelloss" ] =     ACCESS_LEVEL_DEVELOPER,
    [ "vlock" ] =           ACCESS_LEVEL_DEVELOPER,
    [ "setstatic" ] =       ACCESS_LEVEL_DEVELOPER,
    [ "vdamageproof" ] =    ACCESS_LEVEL_DEVELOPER,

}

ERRCODE_WRONG_SYNTAX = 1
ERRCODE_DAILY_LIMITS = 2

ERR_NO_ACCESS = "Ошибка: недостаточно прав"

function GetAllowedCommands( )
	local data = MariaGet( "admin_commands" )
	return data and fromJSON( data ) or { }
end

Player.HasCommandAccess = function( self, command )
    local required_access_level = COMMAND_ACCESS_LEVELS[ command ]
    if type( required_access_level ) == "table" then
        required_access_level = required_access_level[ 1 ]
    end

    -- Особый доступ к командам
    local commands_allowed = GetAllowedCommands( )
    local commands_allowed_player = commands_allowed[ self:GetClientID( ) ]
    if type( commands_allowed_player ) == "table" and commands_allowed_player[ command ] then
        if self:GetAccessLevel( ) > 0 then
            return true
        end
    end

    -- Общий доступ к командам
    return self:GetAccessLevel() >= ( required_access_level or 0 )
end


_addCommandHandler = addCommandHandler
function addCommandHandler( cmd, fn )
    if not COMMAND_ACCESS_LEVELS[ cmd ] then
        outputDebugString( "Не установлены права для команды: " .. tostring( cmd ) .. ", команда отключена", 2 )
        return
    end
    local fn_wrap = function( player, command , ... )
        if not player:HasCommandAccess( command ) then player:outputChat( ERR_NO_ACCESS, 255, 0, 0 ) return end
        local result = fn( player, command, ... )
        if result == ERRCODE_WRONG_SYNTAX then
            local cmd_info = COMMAND_ACCESS_LEVELS[ command ]
            if type( cmd_info ) == "table" and cmd_info[ 2 ] then
                player:outputChat( "Синтаксис: " .. cmd_info[ 2 ], 255, 0, 0 )
            end
        elseif result == ERRCODE_DAILY_LIMITS then
            player:outputChat( "Вы исчерпали свой лимит на использование этой команды", 255, 0, 0 )
        end
    end
    return _addCommandHandler( cmd, fn_wrap )
end