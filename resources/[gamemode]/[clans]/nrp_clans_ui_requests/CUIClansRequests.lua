loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "ib" )

function ShowInviteWindow_handler( info )
    if confirmation then confirmation:destroy() end
    showCursor( true )
    confirmation = ibConfirm(
        {
            title = "Приглашение в клан", 
            text = ( "%s приглашает тебя в клан `%s`" ):format( source:GetNickName( ), info.name ),
            fn_cancel = function( self ) 
                showCursor( false ) 
            end,
            fn = function( self ) 
                self:destroy()
                showCursor( false )
                triggerServerEvent( "onPlayerWantJoinClan", localPlayer, info.clan_id, true )
            end,
            escape_close = true,
        }
    )
end
addEvent( "ShowInviteWindow", true )
addEventHandler( "ShowInviteWindow", root, ShowInviteWindow_handler )