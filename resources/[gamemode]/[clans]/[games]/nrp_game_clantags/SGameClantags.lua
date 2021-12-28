loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SInterior" )
Extend( "ShTimelib" )
Extend( "SClans" )
Extend( "SDB" )

-- Теги
TAG_ELEMENTS = { }
TAG_ELEMENTS_LASTRESPRAY = { }

CLANTAG_SPRAY_EXP_REWARD = 50 -- перекраска клантега
CLANTAG_SPRAY_HONOR_REWARD = 25 -- перекраска клантега
CLANTAG_SPRAY_MONEY_REWARD = 500 -- перекраска клантега
CLANTAG_SPRAY_COOLDOWN = 10*60*1000 -- 10 минут

function SaveClantags( async )
    local saving_data = { }
    for i, tag in pairs( TAG_ELEMENTS ) do
        local spray_number = tag:getData( "spray" )
        local spray_owner = tag:getData( "owner" )
        table.insert( saving_data, { spray_number, spray_owner } )
    end
    local json = toJSON( saving_data, true )
    local query_str = DB:prepare( "REPLACE INTO nrp_clans_data_new ( ckey, cvalue ) VALUES ( 'tags', ? )", json )
    if async then
        DB:exec( query_str )
    else
        DB:query( query_str ):poll( -1 )
    end
end
setTimer( SaveClantags, 60 * 1000, 0, true )

function Clans_OnResourceStopHandler()
    SaveClantags()
end
addEventHandler( "onResourceStop", resourceRoot, Clans_OnResourceStopHandler )

function Clans_OnResourceStartHandler()
    local query = DB:query( "SELECT cvalue FROM nrp_clans_data_new WHERE ckey=? LIMIT 1", "tags" )
    local result = query:poll( -1 )
    local clantags = result[1] and result[1].cvalue and fromJSON( result[1].cvalue ) or { }

    for i, v in pairs( TAG_POSITIONS ) do
        local tag = createElement( "clantags" )
        local info = clantags[ i ] or { false, false }
        if info[ 1 ] then setElementData( tag, "spray", info[ 1 ] ) end
        if info[ 2 ] then setElementData( tag, "owner", info[ 2 ], false ) end
        setElementData( tag, "number", i )

        table.insert( TAG_ELEMENTS, tag )
    end
end
addEventHandler( "onResourceStart", resourceRoot, Clans_OnResourceStartHandler )

function Clans_SprayRequestHandler( tag_number )
    local clan_id = client:GetClanID()
    if not clan_id then return end

    if TAG_ELEMENTS_LASTRESPRAY[ tag_number ] and getTickCount() - TAG_ELEMENTS_LASTRESPRAY[ tag_number ] <= CLANTAG_SPRAY_COOLDOWN then
        local iMinutes = ( CLANTAG_SPRAY_COOLDOWN - ( getTickCount() - TAG_ELEMENTS_LASTRESPRAY[ tag_number ] ) ) / 1000 / 60 
        client:ShowError( "Краска свежая, перекрасить можно будет только через "..math.ceil(iMinutes).." минут" )
        return
    end

    local tag = TAG_ELEMENTS[ tag_number ]

    local tag_id = tag:getData( "spray" )
    local owner = tag:getData( "owner" )

    local clan_tag = GetClanData( clan_id, "tag" )
    
    local is_new = false
    if owner == clan_id then
        if tag_id == clan_tag then
            client:ShowInfo( "Этот тег уже наш, не надо тратить балончик" )
            return
        end
    else
        is_new = true
    end
    playSoundFrontEnd( client, 1 )

    tag:setData( "spray", clan_tag )
    tag:setData( "owner", clan_id, false )
    if is_new then
        TAG_ELEMENTS_LASTRESPRAY[ tag_number ] = getTickCount( )
        -- client:GiveMoney( CLANTAG_SPRAY_MONEY_REWARD, "band_game_tag_reward" )
        client:ShowNotification( "Тег перекрашен! +" .. CLANTAG_SPRAY_EXP_REWARD .. " XP и " .. CLANTAG_SPRAY_HONOR_REWARD .. " очков чести" )
        client:AddClanStats( "tags", 1 )
        client:GiveClanEXP( CLANTAG_SPRAY_EXP_REWARD )
        GiveClanHonor( clan_id, CLANTAG_SPRAY_HONOR_REWARD, "graffiti", client, CLANTAG_SPRAY_EXP_REWARD )
        client:AddWanted( "1.7", 1, true )
        client:CompleteDailyQuest( "band_redraw_graffiti" ) 
    end
end
addEvent( "onClanTagSprayRequest", true )
addEventHandler( "onClanTagSprayRequest", root, Clans_SprayRequestHandler )

function Clans_checkSprayHandler( tag_number )
    local clan_id = client:GetClanID()
    if not clan_id then return end
    if TAG_ELEMENTS_LASTRESPRAY[ tag_number ] and getTickCount() - TAG_ELEMENTS_LASTRESPRAY[ tag_number ] <= CLANTAG_SPRAY_COOLDOWN then
        local iMinutes = ( CLANTAG_SPRAY_COOLDOWN - ( getTickCount() - TAG_ELEMENTS_LASTRESPRAY[ tag_number ] ) ) / 1000 / 60 
        client:ShowError( "Краска свежая, перекрасить можно будет только через "..math.ceil(iMinutes).." минут" )
    end
end
addEvent( "checkSpray", true )
addEventHandler( "checkSpray", root, Clans_checkSprayHandler )

-- Очистка клантегов в новом сезоне
function Clans_SprayReset( )
    for i, v in pairs( TAG_ELEMENTS ) do
        v:removeData( "spray")
        v:removeData( "owner")
    end
end
addEvent( "onClansReset", true )
addEventHandler( "onClansReset", root, Clans_SprayReset )