local KEY_ACTIONS = {}

function OnAddKeyAction( parent, key, priority )
    table.insert( KEY_ACTIONS, 
    {
        parent = parent,
        key = key or "escape",
        priority = priority or #KEY_ACTIONS + 1
    })

    table.sort( KEY_ACTIONS, function( a, b )
        return a.priority > b.priority
    end )
end
addEvent( "OnAddKeyAction", true )
addEventHandler( "OnAddKeyAction", root, OnAddKeyAction )


function OnRemoveKeyAction_handler( parent )
    for k, v in pairs( KEY_ACTIONS ) do
        if v.parent == parent then
            table.remove( KEY_ACTIONS, k )
        end
    end
end
addEvent( "OnRemoveKeyAction", true )
addEventHandler( "OnRemoveKeyAction", root, OnRemoveKeyAction_handler )

function OnClientKey_handler( key, state )
    if not state then return end

    for k, v in ipairs( KEY_ACTIONS ) do
        if v.key == key then
            cancelEvent()
            triggerEvent( "OnAddKeyActionCallback", resourceRoot, v.parent )
            break
        end
    end
end
addEventHandler( "onClientKey", root, OnClientKey_handler )
