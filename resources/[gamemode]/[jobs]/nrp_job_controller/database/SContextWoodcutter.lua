Extend("SDB")

CONST_STOCK_MAX_VALUE = 99
STOCKS =
{
    --Кладет 1 компания, забирает 2
	[ "stock_1_bunch_1" ] = 0,
    
    --Кладёт 2 компания, забирает 3
	[ "stock_2_bunch_1" ] = 0,
}

function InitializeDatabase()
	DB:createTable( "nrp_woodcutter_stock",
	{
		{ Field = "stock_name",	 Type = "varchar(32)",		Null = "NO", Key = "PRI", },
        { Field = "stock_value", Type = "int(11) unsigned",	Null = "NO", Key = "",    },
	})

	for k, v in pairs( STOCKS ) do
		DB:exec( "INSERT IGNORE INTO nrp_woodcutter_stock ( stock_name, stock_value ) VALUES( ?, ? )", k, v )
	end

    onWoodcutterLoadStocks()
    --Автосохранение каждые 60 секунд
    setTimer( onWoodcutterSaveStocks, 60 * 1000, 0 )
    --Автоинкремент значений склада каждые 2 минуты
    setTimer( onWoodcutterAutoincrementStockValues, 2 * 60 * 1000, 0 )
end

function onWoodcutterLoadStocks()
	DB:queryAsync( function( qh )
		local result = qh:poll( -1 )
		for k, v in pairs( result ) do
			STOCKS[ v.stock_name ] = v.stock_value
		end
	end, {  }, "SELECT * FROM nrp_woodcutter_stock" )
end

--Cохранение склада каждые
function onWoodcutterSaveStocks()
	for k, v in pairs( STOCKS ) do
		DB:exec( "UPDATE nrp_woodcutter_stock SET stock_value = ? WHERE stock_name = ?", v, k )
	end
end

--Автоинкремент значений склада каждые
function onWoodcutterAutoincrementStockValues()
    for k, v in pairs( STOCKS ) do
        if v < CONST_STOCK_MAX_VALUE then
            STOCKS[ k ] = v + 1
        end
    end
    local players = GetWoodcutters()
    triggerClientEvent( players, "onWoodcutterRefreshStockValue", root, STOCKS )
end

function LoadWoodcutterStocks( player )
    triggerClientEvent( player, "onWoodcutterRefreshStockValue", player, STOCKS )
end

--Получение значения со склада
function onWoodcutterGetStockValue_handler( stock_name, player )
    triggerClientEvent( client, "onWoodcutterRefreshStockValue", client, stock_name, STOCKS[ stock_name ] )
end
addEvent( "onWoodcutterGetStockValue", true )
addEventHandler( "onWoodcutterGetStockValue", root, onWoodcutterGetStockValue_handler )

--Добавление на склад
function onWoodcutterAddStockValue_handler( stock_name, value )
    if STOCKS[ stock_name ] + value < CONST_STOCK_MAX_VALUE then
        STOCKS[ stock_name ] = STOCKS[ stock_name ] + value
    end
    RefreshStock( stock_name )
end
addEvent( "onWoodcutterAddStockValue", true )
addEventHandler( "onWoodcutterAddStockValue", root, onWoodcutterAddStockValue_handler )

--Получение со склада
function onWoodcutterGetFromStock_handler( stock_name, value )
    if STOCKS[ stock_name ] - value > 0 then
        STOCKS[ stock_name ] = STOCKS[ stock_name ] - value
    end
    RefreshStock( stock_name )
end
addEvent( "onWoodcutterGetFromStock", true )
addEventHandler( "onWoodcutterGetFromStock", root, onWoodcutterGetFromStock_handler )

--Обновление склада
function RefreshStock( stock_name )
    local players = GetWoodcutters()
    triggerClientEvent( players, "onWoodcutterRefreshStockValue", root, stock_name, STOCKS[ stock_name ] )
end

--Получение дровосеков на смене
function GetWoodcutters()
    local target_players = {}
    for k, v in pairs( getElementsByType( "player" ) ) do
        if v:GetJobClass( ) == JOB_CLASS_WOODCUTTER and v:GetShiftActive() then
            table.insert( target_players, v )
        end
    end
    return target_players
end

addEventHandler( "onResourceStart", resourceRoot, function()
    InitializeDatabase()
end )

addEventHandler( "onResourceStop", resourceRoot, function()
    onWoodcutterSaveStocks()
end )

addCommandHandler("resetWood", function()
    for k, v in pairs( STOCKS ) do
        STOCKS[ k ] = 0
    end
    local players = GetWoodcutters()
    triggerClientEvent( players, "onWoodcutterRefreshStockValue", root, STOCKS )
end )