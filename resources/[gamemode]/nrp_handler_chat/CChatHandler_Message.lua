
function create_message( sender, message, channel_id, color, faction_prefix )
    
    if sender and sender:getType() == "player" then
        message, color, channel_id = generate_message_by_channel( sender, message, color, channel_id, faction_prefix )
        sender = sender:GetNickName()
    else
        sender = ""
    end
    
    local ready_message, string_count = split_string_by_words( message, 45 )
    local ready_message_other_channel, string_count_other_channel = get_message_to_other_channels( channel_id, message )

    return 
    {
        channel_id = channel_id,
        sender = sender,
        message = ready_message,
        message_other_channel = ready_message_other_channel,
        string_count = string_count,
        string_count_other_channel = string_count_other_channel,
        color = color,
        time = getTickCount(),
    }
end

function get_message_to_other_channels( channel_id, message )
    if not VISIBLE_CHAT_DATA[ channel_id ] then return "", 0 end
    local prefix = "[" .. VISIBLE_CHAT_DATA[ channel_id ].name .. "]"
    local ready_message, string_count = split_string_by_words( prefix .. " " .. message, 45 )
    return ready_message, string_count
end

function generate_message_by_channel( sender, message, color, channel_id, faction_prefix )
    if channel_id == CHAT_TYPE_NORMAL then
        message = sender:GetNickName() .. ": " .. message
        color = 0xFFFFFFFF
    elseif channel_id == CHAT_TYPE_ME then
        channel_id = CHAT_TYPE_NORMAL
        message = "* " .. sender:GetNickName() .. " " .. message
        color = 0xFFAA8EBF
    elseif channel_id == CHAT_TYPE_FACTION then
        message = faction_prefix .. " " .. sender:GetNickName() .. ": " .. message
        color = 0xFF00C3FF
    elseif channel_id == CHAT_TYPE_LOCALOOC then
        channel_id = CHAT_TYPE_NORMAL
        message = sender:GetNickName() .. ": (( " .. message .. " ))"
        color = 0xFFC4FFFF
    elseif channel_id == CHAT_TYPE_ADMIN then
        message = sender:GetNickName() .. " [" .. faction_prefix .. "]: " .. message
        color = 0xFF00C4FF
    elseif channel_id == CHAT_TYPE_DO then
        channel_id = CHAT_TYPE_NORMAL
        message = "( " .. sender:GetNickName() .. " ) ** " .. message .. " **"
        color = 0xFF78AAE6
    elseif channel_id == CHAT_TYPE_TRY then
        channel_id = CHAT_TYPE_NORMAL
        message = "*** " .. sender:GetNickName() .. message
        color = 0xFF6496D2
    elseif channel_id == CHAT_TYPE_CLAN then
        message = sender:GetNickName() .. ": " .. message
        color = tocolor( 0, 255, 255, 255 )
    elseif channel_id == CHAT_TYPE_ALLFACTION then
        message = faction_prefix .. " " .. sender:GetNickName() .. ": " .. message
        color = 0xFFF0F000
    elseif channel_id == CHAT_TYPE_TRADE then
        message = sender:GetNickName() .. ": " .. message
        color = 0xFFFFFFFF
    elseif channel_id == CHAT_TYPE_REPORT then
        message = sender:GetNickName() .. ": " .. message
        color = 0xFFFFFFFF
    elseif channel_id == CHAT_TYPE_OFFGAME then
        message = sender:GetNickName() .. ": " .. message
        color = 0xFFFFFFFF
    elseif channel_id == CHAT_TYPE_MEGAPHONE then
        channel_id = CHAT_TYPE_NORMAL
        message = "[ " .. faction_prefix  .. " ]: " .. message
        color = 0xFFFFFFFF
    elseif channel_id == CHAT_TYPE_JOB then
        message = sender:GetNickName() .. ": " .. message
        color = 0xFF32D8D8
    else
        message = "[ СМС ] " .. sender:GetNickName() .. ": " .. message
    end
    
    if sender == localPlayer then color = 0xFF9EDEFF end

    return message, color, channel_id
end

function split_string_by_words( str, val )
    local max_line_lenght = val
    local string_count = 1
    local result_string = ""
    for _, w in pairs( split( str, " " ) ) do
        local len = utf8.len( w )
        if len > val then
            result_string, string_count = split_string_by_parts( str, 52 )
            break
        end
        
        len = utf8.len( result_string .. w )
        if len <= max_line_lenght then
            result_string = result_string .. w .. " "
        else
            result_string = result_string .. "\n" .. w .. " "
            string_count = string_count + 1
            max_line_lenght = max_line_lenght + val
        end
    end

    return result_string, string_count
end

function split_string_by_parts( str1, val1 )
    local length = utf8.len( str1 )
    local lastPart = length % val1
    local fullParts = ( length - lastPart ) / val1

    local result = {}
    for i = 1, fullParts do
        table.insert( result, utf8.sub( str1, 1 + ( i - 1 ) * val1, i * val1 ) )
    end
    if lastPart > 0 then
        table.insert( result, utf8.sub( str1, 1 + fullParts * val1, length ) )
    end
    
    local string_count = 0
    local string_result = ""
    for k, v in pairs( result ) do
        if v ~= "" and k > 1 then
            if utf8.len( v ) > 3 then
                string_result = string_result .. "\n" .. utf8.gsub( v, "^%s*(.-)%s*$", "%1" )
                string_count = string_count + 1
            else
                string_result = string_result .. v
            end
        else
            string_result = string_result .. v
            string_count = string_count + 1 
        end
    end

    return string_result, string_count
end