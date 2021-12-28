loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ib" )

ibUseRealFonts( true )

local UNBIND_TIMER, DOCUMENT_OWNER, open_document

function onDocumentPreShow( state, ... )
    local fn_show_document = _G[ eventName ]
    if state then
        if source == localPlayer then
            fn_show_document( true, source, ... )
        else
            BindOpenKey( source, fn_show_document, ... )
        end
    else
        fn_show_document( )
    end
end

function BindOpenKey( document_owner, fn_show_document, ... )
    UnbindOpenKey( true )

    local args = arg
    open_document = function( )
        UnbindOpenKey( )

        local ignore_distance = localPlayer:GetAccessLevel( ) >= ACCESS_LEVEL_SUPERVISOR
        if not isElement( document_owner ) or ( not ignore_distance and localPlayer:DistanceTo( document_owner ) > 10 ) then
            localPlayer:ShowError( "Ты должен быть рядом с игроком" )
            return
        end

        HideAllDocuments()
        fn_show_document( true, document_owner, unpack( args ) )
    end

    bindKey( "v", "down", open_document )
    DOCUMENT_OWNER = document_owner
    UNBIND_TIMER = setTimer( UnbindOpenKey, 10 * 1000, 1, true )

    localPlayer:ShowInfo( "Нажми V, чтобы посмотреть документ " .. document_owner:GetNickName( ) )
end

function UnbindOpenKey( notify_document_owner )
    if not open_document then return end

    unbindKey( "v", "down", open_document )
    if isTimer( UNBIND_TIMER ) then
        UNBIND_TIMER:destroy( )
        if notify_document_owner and isElement( DOCUMENT_OWNER ) then
            triggerServerEvent( "ShowNotificationShowDocuments", DOCUMENT_OWNER, true )
        end
    end
end

function HideAllDocuments()
    ShowArmyfreeUI( false, localPlayer )
    ShowPassportUI( false, localPlayer )
    ShowMilitaryUI( false, localPlayer )
    ShowFCTicketUI( false, localPlayer )
    ShowUI_PoliceID( false, localPlayer )
    ShowMedbookUI( false, localPlayer )
    ShowFactionHistoryUI( false, localPlayer )
    ShowVehiclePassportUI( false, localPlayer )
    RequestShowGunLicenseUI( false, localPlayer )
end