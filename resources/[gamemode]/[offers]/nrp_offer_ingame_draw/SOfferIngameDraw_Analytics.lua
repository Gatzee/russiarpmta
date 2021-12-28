
function onGlobalDrawInparty( player )
    SendElasticGameEvent( player:GetClientID(), "global_draw_inparty", 
    { 
        draw_name   = tostring( OFFER_NAME ),
        current_lvl = tostring( player:GetLevel() ),
    } )
end

function onGlobalDrawTakeTicket( player, ticket_num )
    SendElasticGameEvent( player:GetClientID(), "global_draw_take_ticket", 
    { 
        nickname    = tostring( player:GetNickName() ),
        ticket_num  = tonumber( ticket_num ),
        draw_name   = tostring( OFFER_NAME ),
        current_lvl = tostring( player:GetLevel() ),
    } )
end

function onGlobalDrawContact( player, type_contact, contact )
    SendElasticGameEvent( player:GetClientID(), "global_draw_contact", 
    { 
        type_contact  = tostring( type_contact ),
        contact       = tostring( contact ),
    } )
end