loadstring(exports.interfacer:extend("Interfacer"))()
Extend("ib")
ibUseRealFonts( true )

local item_names =
{
    { id = "pps_msc",          name = "Москва ППС",      },
    { id = "pps_nsk",          name = "НСК ППС",         },
    { id = "pps_gorki",        name = "Горки ППС",       },
    { id = "prison_count",     name = "Тюрьма",          },
    { id = "move_box",         name = "Носят ящики",     },
    { id = "draw_fence",       name = "Красят забор",    },
    { id = "assembly_details", name = "Собирают детали", },
}

function onClientOpenFsinInfoMenu_handler( data )
    if isElement( UI_elements and UI_elements.blackBg ) then
        UI_elements.blackBg:destroy()
        UI_elements = nil
    end

    UI_elements = {}

    UI_elements.blackBg = ibCreateBackground( 0xBF1D252E, nil, true )
    UI_elements.bg = ibCreateImage( 0, 0, 800, 580, "assets/img/bg_info_fsin.png", UI_elements.blackBg ):center():ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )

    ibCreateButton(	748, 25, 24, 24, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            UI_elements.blackBg:destroy()
            UI_elements = nil
            showCursor( false )
            ibClick( )
        end, false )

    UI_elements.scroll_panel, UI_elements.scroll_ver = ibCreateScrollpane( 30, 80, 740, 444, UI_elements.bg, { scroll_px = -20 } )
    UI_elements.scroll_ver
        :ibSetStyle( "slim_nobg" )
        :ibBatchData( { sensivity = 100, absolute = true, color = 0x99ffffff } )
        :UpdateScrollbarVisibility( UI_elements.scroll_panel )

    local py = 0
    for _, v in pairs( item_names ) do
        createItemList( py, v.name, data[ v.id ] )
        py = py + 61
    end

    showCursor( true )
end
addEvent( "onClientOpenFsinInfoMenu", true )
addEventHandler( "onClientOpenFsinInfoMenu", root, onClientOpenFsinInfoMenu_handler )


function createItemList( py, name, value )
    local item_area = ibCreateArea( 0, py, 740, 61, UI_elements.scroll_panel )

    ibCreateLabel( 0, 0, 740, 60, name, item_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_18 )
    ibCreateLabel( 572, 0, 0, 60, "Количество людей:", item_area, 0xFF98A2AD, 1, 1, "left", "center", ibFonts.regular_14 )

    ibCreateImage( 545, 22, 18, 14, "assets/img/people_icon.png", item_area )

    ibCreateLabel( 710, 0, 0, 60, value, item_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_18 )
    ibCreateImage( 0, 60, 740, 1, _, item_area, 0xAA596C80 )
end