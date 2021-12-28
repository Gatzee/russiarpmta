-- ShUtils.lua

function Translit( sString )
    local pTranslitSymbols = {
        [ "а" ] = "a";
        [ "б" ] = "b";
        [ "в" ] = "v";
        [ "г" ] = "g";
        [ "д" ] = "d";
        [ "е" ] = "e";
        [ "ё" ] = "yo";
        [ "ж" ] = "zh";
        [ "з" ] = "z";
        [ "и" ] = "i";
        [ "й" ] = "j";
        [ "к" ] = "k";
        [ "л" ] = "l";
        [ "м" ] = "m";
        [ "н" ] = "n";
        [ "о" ] = "o";
        [ "п" ] = "p";
        [ "р" ] = "r";
        [ "с" ] = "s";
        [ "т" ] = "t";
        [ "у" ] = "u";
        [ "ф" ] = "f";
        [ "х" ] = "h";
        [ "ц" ] = "c";
        [ "ч" ] = "ch";
        [ "ш" ] = "sh";
        [ "щ" ] = "sch";
        [ "ъ" ] = "j";
        [ "ы" ] = "i";
        [ "ь" ] = "j";
        [ "э" ] = "e";
        [ "ю" ] = "yu";
        [ "я" ] = "ya";
        [ "А" ] = "A";
        [ "Б" ] = "B";
        [ "В" ] = "V";
        [ "Г" ] = "G";
        [ "Д" ] = "D";
        [ "Е" ] = "E";
        [ "Ё" ] = "Yo";
        [ "Ж" ] = "Zh";
        [ "З" ] = "Z";
        [ "И" ] = "I";
        [ "Й" ] = "J";
        [ "К" ] = "K";
        [ "Л" ] = "L";
        [ "М" ] = "M";
        [ "Н" ] = "N";
        [ "О" ] = "O";
        [ "П" ] = "P";
        [ "Р" ] = "R";
        [ "С" ] = "S";
        [ "Т" ] = "T";
        [ "У" ] = "U";
        [ "Ф" ] = "F";
        [ "Х" ] = "H";
        [ "Ц" ] = "C";
        [ "Ч" ] = "Ch";
        [ "Ш" ] = "Sh";
        [ "Щ" ] = "Sch";
        [ "Ъ" ] = "J";
        [ "Ы" ] = "I";
        [ "Ь" ] = "J";
        [ "Э" ] = "E";
        [ "Ю" ] = "Yu";
        [ "Я" ] = "Ya";

        -- Extra
        [ " " ] = "_";
    };

    local pString = sString;

    local pOutString = {};

    for i = 1, utfLen( pString ) do
        local sChar = utf8.sub( pString, i, i );

        local sTranslitChar = pTranslitSymbols[ sChar ];

        if sTranslitChar then
            table.insert( pOutString, sTranslitChar );
        else
            table.insert( pOutString, sChar );
        end
    end

    return table.concat( pOutString );
end

function rgb2hex( rgb, using_grid )
    local hexadecimal = using_grid and "#" or '0X'

    for key, value in pairs(rgb) do
        local hex = ''

        while(value > 0)do
            local index = math.fmod(value, 16) + 1
            value = math.floor(value / 16)
            hex = string.sub('0123456789ABCDEF', index, index) .. hex
        end

        if(string.len(hex) == 0)then
            hex = '00'

        elseif(string.len(hex) == 1)then
            hex = '0' .. hex
        end

        hexadecimal = hexadecimal .. hex
    end

    return hexadecimal
end

function hex2rgb(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function FindRotation(x1,y1,x2,y2)
  local t = -math.deg(math.atan2(x2-x1,y2-y1))
  if t < 0 then t = t + 360 end;
  return t;
end

function table.copy( obj, seen )
    if type( obj ) ~= 'table' then
        return obj;
    end;

    if seen and seen[ obj ] then
        return seen[ obj ];
    end;

    local s         = seen or {};
    local res       = setmetatable( { }, getmetatable( obj ) );
    s[ obj ]        = res;

    for k, v in pairs( obj ) do
        res[ table.copy(k, s) ] = table.copy( v, s );
    end

    return res;
end

function Clamp( min, a, max )
    return math.max( math.min( a, max ), min );
end

function Lerp( from, to, percent )
    return from + ( to - from ) * Clamp( 0.0, percent, 1.0 );
end

math.clamp = Clamp

function string:RemoveHex()
    return utf8.gsub( self, "#%x%x%x%x%x%x", "" )
end

function format_price( value )
    return tostring(math.floor(value)):reverse():gsub('(%d%d%d)','%1 '):reverse():gsub('^%s', ''):gsub('-%s', '-')
end

function ripairs(tbl)
    local function ripairs_it(t,i)
        i=i-1
        local v=t[i]
        if v==nil then return v end
        return i,v
    end
    return ripairs_it, tbl, #tbl+1
end

-- Функция проверяет, является ли значение числом (не считая числом значения вроде '0x10' и т.п.)
function isnumber( value )
    local number = tonumber(value)
    local str = tostring(number)
    return ( type(number) == "number" and str == tostring(value) )
end

-- local result = plural( 10, "день", "дня", "дней" )
function plural( value, form1, form2, form3 )
    if value % 10 == 1 and value % 100 ~= 11 then
        return form1
    elseif value % 10 >= 2 and value % 10 <= 4 and ( value % 100 < 10 or value % 100 >= 20 ) then
        return form2
    end

    return form3
end

function expanding_random(items, weights)
  local list = {}
  for pos, item in ipairs(items) do
    local n = weights[pos] * 100
    for i = 1, n do table.insert(list, item) end
  end
  return list[math.random(1, #list)]
end

function isAnythingWithinRange( vec_position, distance )
    for i, v in pairs( getElementsByType( "player" ) ) do
        if getDistanceBetweenPoints3D( v.position, vec_position ) <= distance then return true end
    end
    for i, v in pairs( getElementsByType( "vehicle" ) ) do
        if getDistanceBetweenPoints3D( v.position, vec_position ) <= distance then return true end
    end
end

function ConvertSecondsToTime( iSeconds )
    local pData = {};

    pData.second    = math.floor(iSeconds % 60)
    pData.minute    = math.floor(( iSeconds / 60 ) % 60)
    pData.hour      = math.floor(( iSeconds / 60 / 60 ) % 24)
    pData.monthday  = math.floor(iSeconds / 60 / 60 / 24)

    return pData;
end

Vector3.offset = function(self, distance, rotation)
	return Vector3(
		self.x + ( ( math.cos( math.rad(rotation + 90.0) ) ) * distance ),
		self.y + ( ( math.sin( math.rad(rotation + 90.0) ) ) * distance ),
		self.z
	)
end

Vector3.distance = function(self, vector)
    return (self - vector):getLength()
end

Vector3.totable = function( self )
    return { x = self.x, y = self.y, z = self.z }
end

Vector3.AddRandomRange = function( self, range )
    local range = range or 2
    return self + Vector3( 
		math.random( -10 * range, 10 * range ) / 10,
		math.random( -10 * range, 10 * range ) / 10,
		0
    )
end

local sm = {
	moov = 0;
}

local function removeCamHandler()
	if(sm.moov == 1)then
		sm.moov = 0
	end
end

local function camRender()
	if (sm.moov == 1) then
		local x1,y1,z1 = getElementPosition(sm.object1)
		local x2,y2,z2 = getElementPosition(sm.object2)
		setCameraMatrix(x1,y1,z1,x2,y2,z2)
	else
		removeEventHandler("onClientPreRender",root,camRender)
	end
end

function smoothMoveCamera(x1,y1,z1,x1t,y1t,z1t,x2,y2,z2,x2t,y2t,z2t,time)
	if(sm.moov == 1)then return false end
	if not y2 then
		local _x1,_y1,_z1,_x1t,_y1t,_z1t = getCameraMatrix( )
		smoothMoveCamera(_x1,_y1,_z1,_x1t,_y1t,_z1t, x1,y1,z1,x1t,y1t,z1t, x2)
		return
	end

	sm.object1 = createObject(1337,x1,y1,z1)
	setElementCollisionsEnabled(sm.object1, false)
	sm.object2 = createObject(1337,x1t,y1t,z1t)
	setElementCollisionsEnabled(sm.object2, false)
	setElementAlpha(sm.object1,0)
	setElementAlpha(sm.object2,0)
	setObjectScale(sm.object1,0.01)
	setObjectScale(sm.object2,0.01)
	moveObject(sm.object1,time,x2,y2,z2,0,0,0,"InOutQuad")
	moveObject(sm.object2,time,x2t,y2t,z2t,0,0,0,"InOutQuad")
	sm.moov = 1
	setTimer(removeCamHandler,time,1)
	setTimer(destroyElement,time,1,sm.object1)
	setTimer(destroyElement,time,1,sm.object2)
	addEventHandler("onClientPreRender",root,camRender)
	return true
end

function getPlayerWeapons( player )
	local list = { }
	if isElement( player ) then
		for i = 1, 9 do
			local weapon = getPedWeapon( player, i )
            if weapon and weapon ~= 0 then
                local ammo = getPedTotalAmmo( player, i )
				table.insert( list, { weapon, ammo } )
			end
		end
	end
	return list
end

local MONTH_NAMES = {
    [ "января" ]   = 1,
    [ "февраля" ]  = 2,
    [ "марта" ]    = 3,
    [ "апреля" ]   = 4,
    [ "мая" ]      = 5,
    [ "июня" ]     = 6,
    [ "июля" ]     = 7,
    [ "августа" ]  = 8,
    [ "сентября" ] = 9,
    [ "октября" ]  = 10,
    [ "ноября" ]   = 11,
    [ "декабря" ]  = 12,

    [ "january" ]   = 1,
    [ "february" ]  = 2,
    [ "march" ]     = 3,
    [ "april" ]     = 4,
    [ "may" ]       = 5,
    [ "june" ]      = 6,
    [ "july" ]      = 7,
    [ "august" ]    = 8,
    [ "september" ] = 9,
    [ "october" ]   = 10,
    [ "november" ]  = 11,
    [ "december" ]  = 12,
}

function GetTimestamp(year, month, day, hour, minute, second)
    if not (year and month and day and hour and minute and second) then
        return getRealTime().timestamp;
    end

    local t_month = {0,31,59,90,120,151,181,212,243,273,304,334}
    local t_leapyear = {72,76,80,84,88,92,96,00,04,08,12,16,20,24,28,32,36}
    local sum_year = 0

    function get_leapyear( y )
        for key,value in pairs(t_leapyear) do
            if (value + 1900) == y then return 1 end
        end
        for key,value in pairs(t_leapyear) do
            if (value + 2000) == y then return 1 end
        end
        return nil
    end

    if year < 1970 or year > 2038 then
        return nil
    elseif month < 1 or month > 12 then
        return nil
    elseif hour < 0 or hour > 23 then
        return nil
    elseif minute < 0 or minute > 59 then
        return nil
    elseif second < 0 or second > 59 then
        return nil
    end

    if month == 2 then
        if day > 28 and get_leapyear(year) == nil then
            return nil
        elseif day > 29 then
            return nil
        end
    end

    for y = 1971,year do
        sum_year = sum_year + 31536000
        if get_leapyear(y) ~= nil then
            sum_year = sum_year + 86400
        end
    end

    sum_month = (t_month[month]*86400)
    tsp = sum_year + sum_month + ((day-1)*86400) + hour*3600 + minute*60 + second

    return tsp
end

function getTimestampFromString( string, check_other_formats )
    if type( string ) ~= "string" then
        error( "getTimestampFromString expected string got " .. type( string ), 2 )
    end

    local pattern = "^(%d+)[%p%s]+(%d*)([^%d%p%s]*)[%p%s]+(%d+)%s*(%d*):?(%d*):?(%d*)"
    local day, month, month_name, year, time_hours, time_minutes, time_seconds = string:match( pattern )
    if month == "" then
        month = MONTH_NAMES[ utf8.lower( month_name ) ]
    end
    if tonumber( day ) >= 1900 then
        year, day = day, year
    end

    local timestamp = os.time( {
        year  = tonumber( year ),
        month = tonumber( month ),
        day   = tonumber( day ),
        hour  = tonumber( time_hours ) or 0,
        min   = tonumber( time_minutes ) or 0,
        sec   = tonumber( time_seconds ) or 0,
    } )

    -- Учитываем на клиенте разницу в часах с МСК
    if localPlayer then
        timestamp = timestamp + os.time( ) - ( os.time( os.date( "!*t" ) ) + 3 * 60 * 60 )
    end

    return timestamp
end

function getCurrentDayTimestamp( time_hm )
    local time = os.date( "*t" )
    return getTimestampFromString( time.day .. " " .. time.month .. " " .. time.year .. " " .. (time_hm or "00:00") )
end

-- Конвертирует timestamp в читабельную дату
function formatTimestamp( int )
    local int = tonumber(int) or 0 
    return os.date( "%Y-%m-%d %H:%M:%S",  int )
end

function getHumanTimeString( timestamp, short, bCalculated, ignore_time_diff )
    local time_str = ""
    if not timestamp then
        outputDebugString( "getHumanTimeString arg1 == nil", 0 )
        return
    end
    local time_diff = timestamp - ( ignore_time_diff and getRealTime( ).timestamp or getRealTimestamp( ) )

    if bCalculated then
        time_diff = timestamp * 60
    end

    local s1h = 60 * 60
    local s24h = 24 * s1h

    local days, minutes
    local hours = math.floor( time_diff / s1h )

    if hours > 0 and hours <= 24 then
        time_str = hours .. " " .. ( short and "ч." or plural( hours, "час", "часа", "часов" ) )
    elseif hours == 0 then
        minutes = math.max( 1, math.floor( time_diff / 60 ) )
        time_str = minutes .. " " .. ( short and "м." or plural( minutes, "минута", "минуты", "минут" ) )
    elseif hours < 0 then
        return nil
    else
        days = math.floor( time_diff / s24h )
        hours = math.floor( ( time_diff - days * s24h ) / s1h )
        time_str = days .. " " .. ( short and "д." or plural( days, "день", "дня", "дней" ) ) .. " " .. hours .. " " .. ( short and "ч." or plural( hours, "час", "часа", "часов" ) )
    end

    return time_str, time_diff
end

function getTimerString( time, include_hour, ignore_time_diff )
    if time > 1582218140 then
        time = time - ( ignore_time_diff and getRealTime( ).timestamp or getRealTimestamp( ) )
    end
    if time < 0 then
        time = 0
    end

    local h = math.floor( time / 60 / 60 )
    local m = math.floor( time / 60 % 60 )
    local s = math.floor( time % 60 )

    return include_hour and ( "%02d:%02d:%02d" ):format( h, m, s ) or ( "%02d:%02d" ):format( m, s ), time
end

function convertUnixToDate( timestamp, include_time_diff, greenwich_time_zone )
    if include_time_diff and localPlayer then
        timestamp = timestamp - ( localPlayer:getData( "timestamp_diff" ) or 0 )
    end

    return os.date( greenwich_time_zone and "!*t" or "*t", timestamp )
end

function fromColor(color)
	if color then
		local blue = bitExtract(color, 0, 8)
		local green = bitExtract(color, 8, 8)
		local red = bitExtract(color, 16, 8)
		local alpha = bitExtract(color, 24, 8)
		
		return red, green, blue, alpha
	end
end

function table.compare(tab1,tab2)
    if tab1 == tab2 then
        return true
    end
    if type(tab1) == 'table' and type(tab2) == 'table' then
        if table.size(tab1) ~= table.size(tab2) then
            return false
        end
        for index, content in pairs(tab1) do
            if not table.compare(tab2[index],content) then
                return false
            end
        end
        return true
    end
    return false
end

function table.size(data)
    local count = 0
    for _ in pairs(data) do
        count = count + 1
    end

    return count;
end

function FixTableKeys( data, deep )
    if not data then return end
    local new_data = { }
    for k, v in pairs( data ) do
        if deep and type( v ) == "table" then
            new_data[ tonumber( k ) or k ] = FixTableKeys( v, deep )
        else
            new_data[ tonumber( k ) or k ] = v
        end
    end
    return new_data
end

function LoadXMLIntoVector3Positions( xml_path )
    if fileExists( xml_path ) then
        local data = { }
	    local file = xmlLoadFile( xml_path )
		if file then
		    local children = xmlNodeGetChildren( file )
			for i, v in pairs( children ) do
			    local attrs = xmlNodeGetAttributes( v )
				table.insert( data, Vector3( attrs.posX, attrs.posY, attrs.posZ ) )
            end
            return data
        end
    end
end

function LoadXMLIntoArrayXYZPositions( xml_path )
    if fileExists( xml_path ) then
        local data = { }
	    local file = xmlLoadFile( xml_path )
		if file then
		    local children = xmlNodeGetChildren( file )
			for i, v in pairs( children ) do
			    local attrs = xmlNodeGetAttributes( v )
				table.insert( data, { x = attrs.posX, y = attrs.posY, z = attrs.posZ } )
            end
            return data
        end
    end
end

function DestroyTableElements( tbl )
    for i, v in pairs( tbl or { } ) do
        if isElement( v ) then destroyElement( v ) end
        if isTimer( v ) then killTimer( v ) end
        if type( v ) == "table" then
            if v.destroy then
                v:destroy( )
            else
                DestroyTableElements( v )
            end
        end
    end
end

function LoadPathIntoArray( file_path, precision, distance, speed_limit )
    local path = { }

    local file = fileOpen( file_path )
    local contents = fileRead( file, fileGetSize( file ) )
    fileClose( file )
    local lines = split( contents, "\n" )

    for i = 1, #lines, precision or 1 do
        local v = lines[ i ]
        local x, y, z = unpack( split( v, "," ) )
        table.insert( path, { x = tonumber( x ), y = tonumber( y ), z = tonumber( z ), distance = distance, speed_limit = speed_limit } )
    end

    return path
end

function CleanResourceTextures( )
    for i, v in pairs( getElementsByType( "texture", resourceRoot ) ) do
        if isElement( v ) then destroyElement( v ) end
    end
end

function getPositionFromElementAtOffset( element, x, y, z )
	if not x or not y or not z then      
		return x, y, z   
	end        
	local matrix = getElementMatrix ( element )
	local offX = x * matrix[1][1] + y * matrix[2][1] + z * matrix[3][1] + matrix[4][1]
	local offY = x * matrix[1][2] + y * matrix[2][2] + z * matrix[3][2] + matrix[4][2]
	local offZ = x * matrix[1][3] + y * matrix[2][3] + z * matrix[3][3] + matrix[4][3]
	return offX, offY, offZ
end
function splitString(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function getTimestampFromDateTimeString( string, is_utc_timezone )
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, minute, seconds = string:match( pattern )
    
    local timezone_offset = is_utc_timezone and ( os.time( ) - os.time( os.date( "!*t" ) ) ) or 0

    local timestamp = os.time( {
        year  = year,
        month = month,
        day   = day,
        hour  = tonumber( hour ),
        min   = tonumber( minute ),
        sec   = tonumber( seconds ) + timezone_offset,
    } )

    return timestamp
end

function GenerateUniqId( )
    local random = math.random
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end