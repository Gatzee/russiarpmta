function ShowMedbookUI( state, source, ... )
    triggerEvent( "onShowMedbookUI", source, state, ... )
end

addEvent( "ShowMedbookUI", true )
addEventHandler( "ShowMedbookUI", root, onDocumentPreShow )