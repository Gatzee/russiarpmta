function ShowFactionHistoryUI( state, source, info )
    triggerEvent( "onShowFactionHistoryUI", source, state, info )
end

addEvent( "ShowFactionHistoryUI", true )
addEventHandler( "ShowFactionHistoryUI", root, onDocumentPreShow )