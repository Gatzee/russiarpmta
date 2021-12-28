loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SInterior")

local config =
{
    x = -2671.5302, y = 2834.1816, z = 1544.2593,
    keypress = "lalt",
	text = "ALT Взаимодействие",
    radius = 1.5,
    dimension  = 1,
    interior  = 1,
    marker_text = "ФСИН\nИнформационная панель",
}


function onStart_handler()

    local targetPoint = TeleportPoint( config )
    targetPoint.marker:setColor( 0, 100, 255, 40 )
    targetPoint.element:setData( "material", true, false )
    targetPoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.15 } )

    targetPoint.PreJoin = function( targetPoint, player )
        local faction = player:GetFaction()
        return faction == F_FSIN
	end
	targetPoint.PostJoin = function( targetPoint, player )
		triggerClientEvent( player, "onClientOpenFsinInfoMenu", player, generateFsinInfo() )
    end
end
addEventHandler( "onResourceStart", resourceRoot, onStart_handler )

function generateFsinInfo()
    local pps_nsk, pps_gorki, pps_msc = 0, 0, 0
    for _, v in pairs( exports.nrp_jail:GetJailedPlayers() ) do
        if v.data.time_left * 1000 > PRISON_TIME then
            if v.data.jail_id == 1 then
                pps_nsk = pps_nsk + 1
            elseif v.data.jail_id == 2 then
                pps_gorki = pps_gorki + 1
            elseif v.data.jail_id == 3 then
                pps_msc = pps_msc + 1
            end
        end
    end

    local prison_players = 0
    local move_box = 0
    local draw_fence = 0
    local assembly_details = 0

    for _, v in ipairs( getElementsByType("player") ) do
        local data = v:getData( "jailed" )
        if data == "is_prison" then
            prison_players = prison_players + 1
            local quest_info = v:getData("current_quest")
            if quest_info and quest_info.id == "task_jail_1" then
                move_box = move_box + 1
            elseif quest_info and quest_info.id == "task_jail_2" then
                draw_fence = draw_fence + 1
            elseif quest_info and quest_info.id == "task_jail_3" then
                assembly_details = assembly_details + 1
            end
        end
    end

    return
    {
        pps_nsk          = pps_nsk,
        pps_gorki        = pps_gorki,
        pps_msc          = pps_msc,
        prison_count     = prison_players,
        move_box         = move_box,
        draw_fence       = draw_fence,
        assembly_details = assembly_details,
    }

end
