local UI_Browser

function ShowFormWindow( state, url )
    if state then
        ShowFormWindow( false )

        if loading then loading:destroy( ) loading = nil end
        loading = ibLoading( { parent = UI and UI.bg, priority = 10 } )
        loading:ibData( "alpha", 0 ):ibAlphaTo( 255, 200 )

        UI_Browser = { }

        local x, y = guiGetScreenSize( )
        local margin = 50
        local px, py, sx, sy = margin, margin, x - margin * 2, y - margin * 2
        local navigate = 0

        UI_Browser.black_bg = ibCreateBackground( 0xaa000000, _, true ):ibAlphaTo( 255, 200 )
        UI_Browser.browser = ibCreateBrowser( px, py + 100, sx, sy, UI_Browser.black_bg, false, false ):ibData( "alpha", 0 )
        :ibOnCreated( function( )
            source:Navigate( url )
        end )
        :ibOnDocumentReady( function( )
            if loading then loading:destroy( ) loading = nil end

            source:ibData( "focused", true )
            source:ibMoveTo( px, py, 500 ):ibAlphaTo( 255, 300 )
        end )
        :ibOnNavigate( function( )
            navigate = navigate + 1

            local current_url = UI_Browser.browser:ibData( "browser" ).url
            if navigate >= 3 and current_url:find("viewform[?]") then
                UI_Browser.black_bg:ibBatchData( { disabled = true, alpha = 0 } )
                triggerServerEvent( "onPlayerAnswerForm", resourceRoot )
            end
        end )

        ibCreateButton( sx - 24 - 30, 25, 24, 24, UI_Browser.browser, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFF000000, 0xFF333333, 0xFF555555 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowFormWindow( false )
        end )

        showCursor( true )
    else
        if loading then loading:destroy( ) loading = nil end

        DestroyTableElements( UI_Browser )
        UI_Browser = nil

        if not IsOneWindow( ) then
            showCursor( false )
        end
    end
end

function IsFormWindowOpen( )
    return UI_Browser ~= nil
end