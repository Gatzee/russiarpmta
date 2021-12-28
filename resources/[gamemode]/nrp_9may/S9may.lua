loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShUtils" )
Extend( "SPlayer" )
Extend( "SInterior" )

local RIBBONS_COUNT = 9

PLAYERS_RIBBONS = { }
RIBBONS_POSITIONS = LoadXMLIntoArrayXYZPositions( "packages_0.map" )

if fileExists( "ribbons.nrp" ) then
    local file = fileOpen( "ribbons.nrp" )
    local file_contents = fileRead( file, fileGetSize( file ) )
    PLAYERS_RIBBONS = file_contents and fromJSON( file_contents ) or { }
    fileClose( file )
end

function onPlayerCompleteLogin_handler( player )
	local player = isElement( player ) and player or source

	local user_id = "uid" .. player:GetUserID()
	local inventory_ribbons_count = player:InventoryGetItemCount( IN_9MAY_RIBBON )
	local current_ribbons = PLAYERS_RIBBONS[ user_id ]

	if not current_ribbons then
		local possible_locations = table.copy( RIBBONS_POSITIONS )
		local new_ribbons = { }
		for i = 1, ( RIBBONS_COUNT - inventory_ribbons_count ) do
			local random_number = math.random( 1, #possible_locations )
			local random_position = possible_locations[ random_number ]
			table.remove( possible_locations, random_number )
			table.insert( new_ribbons, random_position )
		end
		PLAYERS_RIBBONS[ user_id ] = new_ribbons
		current_ribbons = new_ribbons
	end

	if inventory_ribbons_count >= RIBBONS_COUNT then
		ParseRibbons( player, true )
		current_ribbons = { }
	end

	if next( current_ribbons ) then
		player:triggerEvent( "On9mayRibbonsLoad", player, current_ribbons )
	end

	if player:GetPermanentData( "9may_quest_timer" ) then
		Timer( TimerQuest_handler, 60000, 0, player )
	end
end
addEvent( "onInventoryInitializationFinished" )
addEventHandler( "onInventoryInitializationFinished", root, onPlayerCompleteLogin_handler )

local CONST_TIME_TO_LEFT_REWARD = 300
local CONST_TIMES_TO_INFO = {
	[60] = "Награда прибудет через";
	[120] = "Награда прибудет через";
	[180] = "Награда прибудет через";
	[240] = "Награда прибудет через";
	[270] = "Награда уже рядом, осталось";
	[CONST_TIME_TO_LEFT_REWARD] = true;
}

function TimerQuest_handler( player )
	if not isElement( player ) or not player:IsInGame( ) then
		killTimer( sourceTimer )
		return
	end

	times = player:GetPermanentData( "9may_quest_timer" )
	if not times then
		killTimer( sourceTimer )
		return
	end

	player:SetPermanentData( "9may_quest_timer", times + 1 )

	if CONST_TIMES_TO_INFO[ times ] then
		local time_left = CONST_TIME_TO_LEFT_REWARD - times - 1
	
		local quests_data = player:GetQuestsData()
		local text = ( quests_data.completed and quests_data.completed[ "sokolov_9may" ] and "" or ", но сначала выполни задание" )

		if time_left <= 0 then
			player:SetPermanentData( "9may_quest_timer", nil )
			killTimer( sourceTimer )

			triggerClientEvent( player, "OnClientReceivePhoneNotification", root, {
				title = "Соколов";
				msg = "Твоя награда пришла, жду тебя у военкомата" .. text;
			} )

			return
		end

		local hours = string.format( "%02d", math.floor( time_left / 60 ) )
		local minutes = string.format( "%02d", math.floor( ( time_left - hours * 60 ) ) )

		triggerClientEvent( player, "OnClientReceivePhoneNotification", root, {
			title = "Соколов";
			msg = CONST_TIMES_TO_INFO[ times ] ..
			" ".. hours .." ч. и ".. minutes .." м." .. text;
		} )
	end
end

function On9mayLetterFind_handler( position )
	if not client then return end

    local user_id = "uid" .. client:GetUserID()
    table.remove( PLAYERS_RIBBONS[ user_id ], position )
	client:InventoryAddItem( IN_9MAY_RIBBON, nil, 1 )

	ParseRibbons( client )
end
addEvent( "On9mayLetterFind", true )
addEventHandler( "On9mayLetterFind", root, On9mayLetterFind_handler )

function ParseRibbons( player, force )
    local user_id = "uid" .. player:GetUserID()
	if #PLAYERS_RIBBONS[ user_id ] == 0 or force then
		player:InfoWindow( "Ты собрал все ленточки! Вернись к Соколову и передай их ему!" )
		PLAYERS_RIBBONS[ user_id ] = { }
        return true
    end
end

function onResourceStart_handler()
    Timer(
        function()
            for i, v in pairs( getElementsByType( "player" ) ) do
                if v:IsInGame() then
                    onPlayerCompleteLogin_handler( v )
                end
            end
        end
    , 1000, 1 )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function onResourceStop_handler()
    if fileExists( "ribbons.nrp" ) then fileDelete( "ribbons.nrp" ) end
    local file = fileCreate( "ribbons.nrp" )
    fileWrite( file, toJSON( PLAYERS_RIBBONS, true ) )
    fileClose( file )
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_handler )


local marker = { x = -1239.366, y = -404.905, z = 21.501 }
marker.color = { 0, 0, 0, 0 }
marker.keypress = false
marker.radius = 8
marker.PreJoin = function( self, player )
	local current_quest = player:getData( "current_quest" )
	if current_quest then
		return false
	end

	if not player:GetPermanentData( "9may_quest_info" ) then
		player:SetPermanentData( "9may_quest_info", true )
		player:InfoWindow( "Здравия желаю. В этот праздник у нас есть традиция, принеси мне ".. RIBBONS_COUNT .." георгевских ленточек и получишь доступ к уникальному квесту с большой наградой!" )
	end

	local quests_data = player:GetQuestsData()
	local inventory_ribbons_count = player:InventoryGetItemCount( IN_9MAY_RIBBON )
	if inventory_ribbons_count == 0 then
		local user_id = "uid" .. player:GetUserID()
		local current_ribbons = PLAYERS_RIBBONS[ user_id ]
		if PLAYERS_RIBBONS[ user_id ] then
			if player:GetPermanentData( "9may_quest" ) then
				if quests_data.completed and quests_data.completed[ "sokolov_9may" ] then
					if player:GetPermanentData( "9may_quest_timer" ) then
						local time_left = CONST_TIME_TO_LEFT_REWARD - player:GetPermanentData( "9may_quest_timer" )
						local hours = string.format( "%02d", math.floor( time_left / 60 ) )
						local minutes = string.format( "%02d", math.floor( ( time_left - hours * 60 ) ) )

						player:ShowInfo( "Твоя награда появится у Соколова через ".. hours .." ч. и ".. minutes .." м." )
						triggerEvent( "On9mayQuestCompliteTimeTask", player )
					else
						player:SetPermanentData( "9may_quest", false )
						player:GiveMoney( 100000, "Quest.9may" )
						player:InfoWindow( "Вот твоя награда!" )
						triggerEvent( "On9mayQuestGetReawrd", player )
					end
				else
					triggerEvent( "PlayeStartQuest_sokolov_9may", player )
				end

				return false
			end
		end
		
		return false
	end
	if inventory_ribbons_count < RIBBONS_COUNT then
		local user_id = "uid" .. player:GetUserID()
		if not next( PLAYERS_RIBBONS[ user_id ] ) then
			PLAYERS_RIBBONS[ user_id ] = nil
			onPlayerCompleteLogin_handler( player )
		end

		return false, "Осталось собрать еще ".. ( RIBBONS_COUNT - inventory_ribbons_count ) .." шт."
	end
	return true
end
marker.PostJoin = function( self, player )
	player:InventoryRemoveItem( IN_9MAY_RIBBON )
	player:SetPermanentData( "9may_quest", true )
	player:SetPermanentData( "9may_quest_timer", 0 )

	triggerEvent( "On9mayQuestCompliteFindTask", player )

	Timer( TimerQuest_handler, 60000, 0, player )

	triggerEvent( "PlayeStartQuest_sokolov_9may", player )
end

local tpoint = TeleportPoint( marker )
tpoint.marker:setColor( unpack( marker.color ) )