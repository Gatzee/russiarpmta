loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

ibUseRealFonts( true )

CONST_CASE_SHOW_DURATION = 5000

UPDATE_INTERVAL = 30 * 60 * 1000                    -- полчаса, интервал обновления списка кейсов с сервера

UIe = {}

addEventHandler( "onClientResourceStart", resourceRoot, function( )
    --update case stack
    setTimer( function( )
        if localPlayer:IsInEventLobby( ) or localPlayer:IsInStoryQuest( ) then
            return
        end
        triggerServerEvent( "onPlayerRequestLiveCaseDropInfo", resourceRoot )
    end, UPDATE_INTERVAL, 0 )
end )

addEvent( "onPlayerReceiveLiveCaseDropInfo", true )
addEventHandler( "onPlayerReceiveLiveCaseDropInfo", localPlayer, function ( case_drop_data )
    ShowUI( true, case_drop_data )
end )

function ShowUI( state, case )
    if state then
        ShowUI( false )

        UIe.area = ibCreateDummy( )
        UIe.area:ibBatchData( { py = 10, alpha = 0, disabled = true, priority = 5 } )

        local case_image = ibCreateContentImage( 0, 0, 130, 90, "case", case.case_id, UIe.area ):center_x( )
        local case_owner_label = ibCreateLabel( 0, 107, 0, 0, case.owner .. " выбивает:", UIe.area, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_15 )
            :ibData( "outline", true )
        ibCreateLabel( 0, 128, 0, 0, case.drop_text, UIe.area, 0xFFFFE743, 1, 1, "center", "center", ibFonts.bold_15 )
            :ibData( "outline", true )

        UIe.area
            :center_x( )
            :ibAlphaTo( 255, 512, "InOutQuad" )
            :ibTimer( function( self )
                self:ibAlphaTo( 0, 512 )
                self:ibTimer( function( )
                    ShowUI( false )
                end, 1024, 1 )
            end, CONST_CASE_SHOW_DURATION, 1 )

    else
        DestroyTableElements( UIe )
    end
end