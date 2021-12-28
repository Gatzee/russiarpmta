loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "Globals" )
Extend( "ShUtils" )

START_GIVEAWAY_DATE = getTimestampFromString( "30 января 2020 00:00" )
END_GIVEAWAY_DATE = getTimestampFromString( "6 февраля 2020 23:59" )

DURATIONS = {
    default = 10,
    payer = 20,
}

PAYERS = { }

function LoadCSV( )
    local file = fileOpen( "csv/list.csv" )
    local contents = fileRead( file, fileGetSize( file ) )
    fileClose( file )

    local lines = split( contents, "\n" )
    for i = 2, #lines do
        local v = lines[ i ]
        PAYERS[ v ] = true
    end
end

function onResourceStart_handler( )
    LoadCSV( )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function onPlayerCompleteLogin_handler( )
    local ts = getRealTime( ).timestamp
    if ts < START_GIVEAWAY_DATE or ts > END_GIVEAWAY_DATE then return end

    -- Только старым игрокам кому не выдавали еще
    if source:GetPermanentData( "reg_date" ) <= START_GIVEAWAY_DATE and not source:GetPermanentData( "comp_given" ) then
        source:SetPermanentData( "comp_given", true )

        local duration_type = PAYERS[ source:GetClientID( ) ] and "payer" or "default"
        local duration = DURATIONS[ duration_type ]

        source:GivePremiumExpirationTime( duration )
        source:PhoneNotification( { title = "Компенсация", msg = "Ты получил " .. duration .. " д. бесплатного премиума в качестве компенсации за ежедневные награды!" } )
    end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )