local pHobbiesList = 
{
    fishing = 
    {
        icon = "img/hobby_fishing.png",
        title = "Рыбалка",
        hint = "Достать/убрать удочку ",
        key = { "img/icon_alt.png", 45, 17 }
    },

    hunting = 
    {
        icon = "img/hobby_hunting.png",
        title = "Охота",
        hint = "Достать/убрать ружье ",
        key = { "img/icon_h.png", 35, 17 }
    },

    digging = 
    {
        icon = "img/hobby_digging.png",
        title = "Поиск сокровищ",
        hint = "Достать/убрать лопату ",
        key = { "img/icon_h.png", 35, 17 }
    },
}

HUD_CONFIGS.hobbies = {
    elements = { },

    create = function( self, hobby_id )
        local pHobby = pHobbiesList[hobby_id]

        local bg = ibCreateImage( 0, 0, 340, 80, "img/bg_hobbies.png", bg ) 
        self.elements.bg = bg

        if pHobby.icon then
            ibCreateImage( 15, 8, 64, 64, pHobby.icon, bg )
        end

        ibCreateLabel( 98, 4, 0, 50, pHobby.title, bg, 0xFFFFFFFF, 1, 1, "left", "center"):ibData("font", ibFonts.bold_16  )
        local hint = ibCreateLabel( 98, 45, 0, 17, pHobby.hint, bg, 0xFFFFFFFF, 1, 1, "left", "center"):ibData("font", ibFonts.regular_10)
        ibCreateImage( hint:ibData("px")+hint:width()+5, 45, pHobby.key[2], pHobby.key[3], pHobby.key[1], bg )
        
        return bg
    end,

    destroy = function( self )
        local to_destroy = { self.elements.bg }
        DestroyTableElements( to_destroy )
        
        self.elements = { }
    end,
}

function ShowHobbiesInfo_handler( hobby_id )
	AddHUDBlock( "hobbies", hobby_id )
end
addEvent( "ShowHobbiesInfo", true )
addEventHandler( "ShowHobbiesInfo", root, ShowHobbiesInfo_handler )

function HideHobbiesInfo_handler( )
    RemoveHUDBlock( "hobbies" )
end
addEvent( "HideHobbiesInfo", true )
addEventHandler( "HideHobbiesInfo", root, HideHobbiesInfo_handler )