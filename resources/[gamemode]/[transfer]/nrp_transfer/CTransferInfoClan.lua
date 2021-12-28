local UI

function ShowTransferClanInfoUI( state, conf )
    InitModules( )

    if state then
        ShowTransferClanInfoUI( false )

        UI = { }

        UI.black_bg = ibCreateBackground( _, _, true ):ibData( "priority", 5 )
        UI.bg = ibCreateImage( 0, 0, 0, 0, "img/bg_info_clan.png", UI.black_bg ):ibSetRealSize( ):center( )

        UI.btn_close = ibCreateButton(  UI.bg:width( ) - 24 - 24, 28, 24, 24, UI.bg,
                            ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                            0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowTransferClanInfoUI( false )
            end )

        UI.img_clan_tag = ibCreateImage( 26, 98, 64, 64, ":nrp_clans/img/tags/band/" .. conf.clan_data.tag .. ".png", UI.bg )
        ibCreateLabel( 180, 106, 0, 0, conf.clan_data.name, UI.bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
        ibCreateLabel( 178, 130, 0, 0, conf.clan_data.way, UI.bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
        ibCreateLabel( 170, 154, 0, 0, conf.clan_data.lb_position .. "-е место", UI.bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )

        local function build_stats( name, amount, px, py, parent, font )
            amount = tonumber( amount ) and format_price( amount ) or amount
            font = font or ibFonts.bold_18
            local area = ibCreateArea( px, py, 0, 24, parent )
            local icon = name == "money" and ":nrp_shared/img/money_icon.png" 
                      or name == "honor" and "img/icon_clan_honor.png" 
                      or name == "members" and "img/icon_clan_members.png"
            local img = ibCreateImage( 0, 0, 0, 0, icon, area ):ibSetRealSize( ):ibSetInBoundSize( 24, 24 )
            local lbl = ibCreateLabel( img:ibGetAfterX( 8 ), img:ibGetCenterX( ), 0, 0, amount, area, COLOR_WHITE, _, _, "left", "center", font )

            area:ibData( "sx", lbl:ibGetAfterX( ) )

            return area
        end

        local function build_stats_line( stats, px, py, parent )
            local areas = { }
            table.insert( areas, build_stats( "money", stats.money, px, py, parent ) )
            table.insert( areas, build_stats( "honor", stats.honor, px, py, parent ) )
            table.insert( areas, build_stats( "members", stats.members, px, py, parent ) )

            local npx = px
            for i, v in pairs( areas ) do
                v:ibData( "px", npx )

                npx = npx + v:width( ) + 10

                if i ~= #areas then
                    local divider = ibCreateLabel( npx, v:ibGetCenterY( ), 0, 0, "/", parent, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, _, "center", ibFonts.regular_28 )
                    npx = npx + divider:width( ) + 10
                end
            end
        end

        build_stats_line( conf.clan_data, 50, 218, UI.bg )

        UI.btn_transfer = ibCreateButton( 0, 643, 0, 0, UI.bg, "img/btn_transfer_big.png", "img/btn_transfer_big.png", "img/btn_transfer_big.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibSetRealSize( )
            :center_x( )
            :ibData( "priority", 2 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                ShowTransferClanInfoUI( false )
                ShowTransferInfoUI( true, conf )
            end )

        UI.bg:ibData( "alpha", 0 ):ibData( "py", UI.bg:ibData( "py" ) + 100 ):ibAlphaTo( 255, 300 ):ibMoveTo( _, UI.bg:ibData( "py" ) - 100, 500 )

        showCursor( true )
    else
        DestroyTableElements( UI )
        UI = nil

        showCursor( false )
    end
end