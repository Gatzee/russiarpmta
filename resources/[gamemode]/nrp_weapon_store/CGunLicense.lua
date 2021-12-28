local sx, sy = 1024, 768
local px, py = (_SCREEN_X - sx) / 2, (_SCREEN_Y - sy) / 2

License = {}
License.ui = {}

local function CreateLicenseCard( npx, npy, pItem, parent )
    local card = ibCreateArea( npx, npy, 470, 250, parent )
    ibCreateImage( 0,  0, card:width( ), card:height( ), "img/license/emblem.png", card )
    ibCreateLabel( 0, 15, 0, 0, pItem.verbose_name, card, COLOR_WHITE, 1, 1, "center", "top", ibFonts.regular_12 ):center_x( )
    ibCreateImage( 0, 0, 0, 0, pItem.image, card ):ibSetRealSize( ):center( )
    ibCreateImage( card:width( ) - 174,  card:height( ) - 130, 174, 130, "img/license/stamp.png", card )
end

function ShowGunLicenseUI( state, pOwner, expiration_time )
    if not localPlayer:SetStateShowDocuments( state, source ) then return end
    
    if state then
        if not isElement( pOwner ) then return end

        showCursor( true )

        local ui = License.ui

        ui.main = ibCreateImage( px, py, sx, sy, "img/main_bg.png" )
        local header_bar = ibCreateImage( 0, 0, sx, 90, "img/header_overlay.png", ui.main )
        local body_area = ibCreateArea( 0, header_bar:ibGetAfterY( ), header_bar:width( ), ui.main:height( ) - header_bar:height( ), ui.main )
        ibCreateLine( 0, 90, body_area:width( ), _, ibApplyAlpha( COLOR_WHITE, 10 ), 1, ui.main )
        ibCreateLabel( 30, 0, 0, 0, "Лицензия на огнестрельное оружие ( " .. pOwner:GetNickName() .." )", header_bar, 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_16 ):center_y( )
        ibCreateLabel( 30, 140, 0, 0, "Список доступного оружия", header_bar, 0xFFFFFFFF, _, _, "left", "bottom", ibFonts.bold_14 )
        ibCreateLine( 30, 156, body_area:width( ) - 30, _, ibApplyAlpha( COLOR_WHITE, 10 ), 1, ui.main )

        ibCreateButton( sx - 60, 30, 30, 30, header_bar, "img/btn_close.png", "img/btn_close_hover.png", "img/btn_close_hover.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end

                ShowGunLicenseUI( false )
                ibClick( )
            end )

        do
            local area = ibCreateArea( 0, 133, 0, 0, ui.main )
            local icon = ibCreateImage( 0, -10, 18, 20, ":nrp_shared/img/icon_timer.png", area )
            local lbl = ibCreateLabel( icon:ibGetAfterX( 8 ), 0, 0, 0, "Время действия:", area, 0xAAFFFFFF, 1, 1, "left", "center", ibFonts.regular_12 )
            local lbl2 = ibCreateLabel( lbl:ibGetAfterX( 8 ), 0, 0, 0, getHumanTimeString(expiration_time), area, 0xAAFFFFFF, 1, 1, "left", "center", ibFonts.regular_12 )
            area:ibData( "px", ui.main:width( ) - lbl2:ibGetAfterX( 30 ) )
        end

        ibCreateLabel( 0, 190, ui.main:width( ), 0, "Вы имеете право хранить, носить и использовать огнестрельное оружие, указанное в следующем списке:", ui.main, COLOR_WHITE, 1, 1, "center", "center", ibFonts.regular_12 )

        local license_area = ibCreateArea( 30, 130, 0, 0, body_area )

        local i = 0
        local npx, npy = 0, 0
        for _, pItem in pairs( GOODS ) do
            if pItem.class == WEAPON or pItem.class == FUTURE then
                i = i + 1
                npx = ( i % 2 ) == 0 and 490 or 0
                npy = ( i ~= 1 ) and ( i % 2 ) ~= 0 and ( i % 2 ) * 270 or npy
                CreateLicenseCard( npx, npy, pItem, license_area )
            end
        end

    else
        for k, v in pairs( License.ui ) do
            if isElement( v ) then
                destroyElement( v )
            end
        end
        showCursor( false )
    end
end

addEvent( "ShowGunLicenseUI", true )
addEventHandler( "ShowGunLicenseUI", root, ShowGunLicenseUI )