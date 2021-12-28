HUD_CONFIGS.wanted = {
    elements = { },
    independent = true, -- Не управлять позицией худа
    create = function( self )
        local x, y = guiGetScreenSize( )

        local bg = ibCreateArea( 20, y - 340, 0, 0 )
        
        ibUseRealFonts( true )

        ibCreateLabel( 0, 0, 0, 0, "Вы в розыске! #ffffffСтатьи:", bg, 0xffff6363, _, _, _, _, ibFonts.regular_14 )
            :ibData( "colored", true )
            :ibData( "outline", 1 )

        local values = getElementData( localPlayer, "wanted_data" ) or { }
        local used_names = { }
		
		local npx = 0
        for i, v in pairs( values ) do
            local name = v[ 1 ]
            if not used_names[ name ] then
                local bgn = ibCreateArea( npx, 25, 40, 26, bg )

                ibCreateImage( 0, 0, 2, 26, _, bgn, 0xffff3b3b )
                local bg_drawable = ibCreateImage( 2, 0, 38, 26, _, bgn, ibApplyAlpha( 0xff2a323c, 85 ) )

                ibCreateLabel( 0, 0, 0, 0, name, bg_drawable, COLOR_WHITE, _, _, "center", "center", ibFonts.bold_14 ):center( )
                
                npx = npx + 48
                used_names[ name ] = true
            end
        end

        ibUseRealFonts( false )

        table.insert( self.elements, bg )
        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}

function IsCanShowWanted()
    if localPlayer:getData( "in_race" ) then
        return false
    elseif localPlayer:getData( "photo_mode" ) then
        return false
    end
    return true
end

function CheckWanted_handler( key, old, new )
    if not key or key == "wanted_data" then
        RemoveHUDBlock( "wanted" )

        local values = getElementData( localPlayer, "wanted_data" ) or { }
		if values and #values > 0 and IsCanShowWanted() then
            AddHUDBlock( "wanted" )
        end
    elseif key == "hide_wanted" then
        if new then
            RemoveHUDBlock( "wanted" )
        else
            local values = getElementData( localPlayer, "wanted_data" ) or { }
		    if values and #values > 0 then
                AddHUDBlock( "wanted" )
            end
        end
	end
end
addEventHandler( "onClientElementDataChange", localPlayer, CheckWanted_handler )

function onClientShowWanted_handler()
    local values = getElementData( localPlayer, "wanted_data" ) or { }
	if values and #values > 0 then
        AddHUDBlock( "wanted" )
    end
end
addEvent( "onClientShowWanted", true )
addEventHandler( "onClientShowWanted", root, onClientShowWanted_handler )

function Wanted_onStart( )
    CheckWanted_handler( )
end
addEventHandler( "onClientResourceStart", resourceRoot, Wanted_onStart )