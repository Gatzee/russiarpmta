loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SDB" )

addEvent( "onDatabaseConnectionsRefresh" )
addEvent( "onAllDatabasesFinishEstablishingConnections" )

CONNECTION_CONFS = {
    -- MariaDB
    {
        name = "БД сервера",
        alias = "DB",
        host = get( "mysql.host" ),
        port = get( "mysql.port" ),
        user = get( "mysql.user" ),
        pass = get( "mysql.password" ),
        db = get( "mysql.dbname" ),
        engine = get( "mysql.engine" ),
        multi_statements = true,
    },

    -- Общая MariaDB
    {
        name = "БД общая",
        alias = "CommonDB",
        host = "nextrp-production.c71whlxpqfvl.eu-west-3.rds.amazonaws.com",
        port = 3306,
        user = "nextrpcommon",
        pass = "GS<^X]{~#@w9WD>3",
        db = "nextrpcommon",
        engine = get( "mysql.engine" ),
        multi_statements = true,
    },

    -- API
    {
        name = "БД API",
        alias = "APIDB",
        host = "nextrp-production.c71whlxpqfvl.eu-west-3.rds.amazonaws.com",
        port = 3306,
        user = "api",
        pass = "6AfeqOminaMuB3Wa86Pok7LoPOD5LA",
        db = "api",
        engine = get( "mysql.engine" ),
        multi_statements = true,
    },
}

CONST_CONNECTION_POOL_SIZE = 20 -- Количество подключений на 1 базу данных
CONNECTION_POOL_NUM = 1 -- Счетчик подключений для равномерного размазывания коннектов по ресурсам
CONNECTION_POOL = { } -- Общий пул всех коннектов по алиасам

CONST_REQUIRED_READY_TIMES = 3 -- Количество успешных проверок соединений к базе подряд, чтобы считать, что можем запускать остальные ресурсы

function GetActiveConnections( )
    local connections = { }
    for alias, connection_list in pairs( CONNECTION_POOL ) do
        connections[ alias ] = CONNECTION_POOL[ alias ][ 1 + ( CONNECTION_POOL_NUM % CONST_CONNECTION_POOL_SIZE ) ]
    end

    CONNECTION_POOL_NUM = CONNECTION_POOL_NUM + 1

    return connections
end

function getActiveConnectionsInPool( alias )
    local connections = { }
    for i, connection in pairs( CONNECTION_POOL[ alias ] or { } ) do
        if isElement( connection ) then
            table.insert( connections, connection )
        end
    end
    return connections
end

function RefreshConnections( alias_array )
    local dropped = 0

    for alias, connection_list in pairs( CONNECTION_POOL ) do
        if not alias_array or alias_array[ alias ] then
            for i, connection in pairs( connection_list ) do
                if isElement( connection ) then
                    destroyElement( connection )
                    dropped = dropped + 1
                end
            end
        end
    end

    if dropped > 0 then
        iprint( "Dropped ".. dropped .. " connections, restoring..." )
        EstablishConnections( )
    end
end

function EstablishConnections( )
    local pools_changed = { }
    
    for i, v in pairs( CONNECTION_CONFS ) do
        local active_connections = getActiveConnectionsInPool( v.alias )
        local unconnected = CONST_CONNECTION_POOL_SIZE - #active_connections
        if unconnected > 0 then
            for i = 1, unconnected do
                local db = dbConnect( "mysql", ( "dbname=%s;host=%s;port=%s;charset=%s" ):format( v.db, v.host, v.port, "utf8" ), v.user, v.pass, "autoreconnect=1;batch=0;log=1;multi_statements=" .. ( v.multi_statements and "1" or "0" ) )
                if db then
                    db:exec( "SET NAMES utf8" )
                    db:exec( "SET lc_time_names = 'ru_RU'" )
                    if type( v.connected ) == "table" then
                        for i, req in pairs( v.connected ) do
                            db:exec( req )
                        end
                    end

                    table.insert( active_connections, db )

                    iprint( "Connection established!", v.alias, db )
                    
                    pools_changed[ v.alias ] = true 
                end
            end
            iprint( "Added new connections to pool", v.alias, unconnected )
        end

        CONNECTION_POOL[ v.alias ] = active_connections
    end

    if next( pools_changed ) then
        -- Поддержка SDB в текущем ресурсе
        for alias, connection in pairs( GetActiveConnections( ) ) do
            _G[ alias ] = connection
        end

        iprint( "Requesting connections pool update..." )

        triggerEvent( "onDatabaseConnectionsRefresh", root )

        iprint( "Finish connections pool update!" )
    end
end

addEventHandler( "onResourceStart", resourceRoot, function( )
    EstablishConnections( )
    setTimer( EstablishConnections, 1000, 0 )

    local COUNT_SUCCESSFUL_CONNECTIONS = 0

    START_RESOURCES_TIMER = setTimer( function( )
        for i, v in pairs( CONNECTION_CONFS ) do
            local count = #getActiveConnectionsInPool( v.alias )
            if count < CONST_CONNECTION_POOL_SIZE then
                iprint( "Connection pool of " .. v.alias .. " is not ready - waiting for " .. ( CONST_CONNECTION_POOL_SIZE - count ) .. " unready connections..." )
                COUNT_SUCCESSFUL_CONNECTIONS = 0
                return
            end
        end

        COUNT_SUCCESSFUL_CONNECTIONS = COUNT_SUCCESSFUL_CONNECTIONS + 1

        iprint( "Ready sequence of connections: " .. COUNT_SUCCESSFUL_CONNECTIONS )

        if COUNT_SUCCESSFUL_CONNECTIONS >= CONST_REQUIRED_READY_TIMES then
            if isTimer( START_RESOURCES_TIMER ) then killTimer( START_RESOURCES_TIMER ) end
            START_RESOURCES_TIMER = nil

            setTimer( function( )
                iprint( "All databases established connections! Starting..." )
                triggerEvent( "onAllDatabasesFinishEstablishingConnections", root )
            end, 1000, 1 )
        end
    end, 1000, 0 )
end, true, "high" )
