loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "CPlayer" )
Extend( "ShUtils" )
Extend( "CChat" )
Extend( "ib" )

ibUseRealFonts( true )

local UI_elements = {}
local scX, scY = guiGetScreenSize()

IS_REPORT_OPEN = false
local edit_press = false
local reason_select_press = false

local select_reason = 1
local reasons = 
{
    { name = "Нарушение РП",         },
    { name = "Техническая проблема", },
    { name = "Баг",                  },
    { name = "Читерство",            },
    { name = "Другое",               },
}

function CreateReportWindow( cmd )
    if IS_REPORT_OPEN then return end

    ibInterfaceSound()
    guiSetInputMode( "no_binds" )
    localPlayer:ShowChat( false )
    IS_REPORT_OPEN = true
    
    UI_elements.black_bg = ibCreateBackground( 0xaa000000, CloseReportWindow, _, true )
    UI_elements.bg = ibCreateImage( ( scX - 800 )/2, (scY - 580) / 2 , 800, 580, "img/bg_container.png", UI_elements.black_bg, 0xFFFFFFFF )
    UI_elements.btn_close = ibCreateButton(  748, 26, 24, 24, UI_elements.bg,":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
    :ibOnClick( function( button, state )
        if button == "left" and state == "down" then
            CloseReportWindow()
        end
    end )

    UI_elements.btn_send = ibCreateButton(  325, 506, 150, 44, UI_elements.bg,"img/btn_send.png", "img/btn_send_hovered.png", "img/btn_send_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
    :ibOnClick( function( button, state )
        if button == "left" and state == "down" then
            
            local report_name = UI_elements.edit_report_name:ibData( "text" )
            local report_naem_size = utf8.len( utf8.gsub( report_name, " ", "" ) or "" )
            if not edit_press or report_name == "" or report_naem_size < 5 then
                localPlayer:ShowError( "Минимальная длина названия репорта 5 символов!" )
                return
            elseif report_naem_size > 48 then
                localPlayer:ShowError( "Максимальная длина названия репорта 48 символов!" )
                return
            end

            local report_content = UI_elements.memo_conent:ibData( "text" )
            local content_size = utf8.len( utf8.gsub( report_content, " ", "" ) or "" )
            if content_size <= 16 then
                localPlayer:ShowError( "Ваше сообщение должно быть длиннее 16 символов", 0xFFFF0000 )
                return
            elseif content_size > 200 then
                localPlayer:ShowError( "Максимальная длина сообщения 200 символов!", 0xFFFF0000 )
                return
            end

            triggerServerEvent( "onServerReceivePlayerReport", localPlayer, report_name, reasons[ select_reason ].name, report_content )
            CloseReportWindow()

        end
    end )

    UI_elements.edit_report_name = ibCreateEdit( 49, 125, 698, 38, "Например: Игрок с ником “НИКНЕЙМ” нарушает правила ПДД", UI_elements.bg, 0xFF848B92, 0x00000000, 0xFF848B92 ):ibData("font", ibFonts.regular_12 )
    :ibOnClick( function( button, state )
        UI_elements.memo_conent:ibData( "blur", true )
        if button == "left" and state == "down" then
            if not edit_press then
                UI_elements.edit_report_name:ibBatchData( { text = "", color = 0xFFFFFFFF, caret_position = 0 } )
                edit_press = true
            end
        end
    end )

    UI_elements.btn_reason = ibCreateButton(  30, 209, 740, 40, UI_elements.bg,"img/btn_reason.png", "img/btn_reason_hovered.png", "img/btn_reason_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
    :ibOnClick( function( button, state )
        if button == "left" and state == "down" and not reason_select_press then
            reason_select_press = true
            OpenDropdownReasonList()
        end
    end )
    UI_elements.btn_reason_title = ibCreateLabel( 20, 0, 200, 40, "Нарушение РП", UI_elements.btn_reason, 0xFFFFFFFF, 1, 1, "left", "center" ):ibBatchData( { font = ibFonts.regular_12, disabled = true } )

    UI_elements.memo_conent = ibCreateWebMemo( 31, 298, 738, 191, "", UI_elements.bg, 0xFFFFFFFF, 0 )
    :ibData( "focusable", true )
    :ibData( "focused", true )

    addEventHandler("onClientKey", root, IgnoreKeys)
    showCursor( true )
end
addEvent( "onClientOpenReportWindow", true )
addEventHandler( "onClientOpenReportWindow", root, CreateReportWindow )
addCommandHandler( "report", CreateReportWindow )

function CloseReportWindow()
    if isElement(UI_elements and UI_elements.black_bg) then
        destroyElement( UI_elements.black_bg )
    end
    reason_select_press = false
    IS_REPORT_OPEN = false
    edit_press = false
    select_reason = 1
    showCursor( false )
    guiSetInputMode( "no_binds_when_editing" )
    localPlayer:ShowChat( true )
    removeEventHandler("onClientKey", root, IgnoreKeys)
end

addEventHandler( "onClientResourceStart", resourceRoot, function()
    if localPlayer:IsInGame() then
        localPlayer:ShowChat( true )
    end
end )

function OpenDropdownReasonList()
    local py = 209
    for k, v in pairs( reasons ) do
        UI_elements[ "reason_" .. k ] = ibCreateArea( 30, py, 740, 41, UI_elements.bg )
        local button
        if k == 1 then
            button = ibCreateButton(  0, 0, 740, 40, UI_elements[ "reason_" .. k ],"img/btn_item_start.png", "img/btn_item_start_hovered.png", "img/btn_item_start_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        elseif k == #reasons then
            button = ibCreateButton(  0, 0, 740, 40, UI_elements[ "reason_" .. k ],"img/btn_item_end.png", "img/btn_item_end_hovered.png", "img/btn_item_end_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        else
            button = ibCreateButton(  0, 0, 740, 40, UI_elements[ "reason_" .. k ],"img/btn_item.png", "img/btn_item_hovered.png", "img/btn_item_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        end
        button:ibOnClick(function( button, state )
            if button == "left" and state == "down" then
                CloseDropdownReasonList( k )
            end
        end )
        ibCreateLabel( 20, 0, 720, 40, v.name, button, 0xFFFFFFFF, 1, 1, "left", "center" ):ibBatchData( { font = ibFonts.regular_12, disabled = true } )
        ibCreateImage( 0, 41, 740, 1, _, UI_elements[ "reason_" .. k ], 0xFF3D4F63 )
        py = py + 41
    end
end

function CloseDropdownReasonList( new_reason )
    select_reason = new_reason
    reason_select_press = false
    UI_elements.btn_reason_title:ibData( "text", reasons[ select_reason ].name )
    for k, v in pairs( reasons ) do
        UI_elements[ "reason_" .. k ]:destroy()
    end
end

function IgnoreKeys()
    cancelEvent()
end