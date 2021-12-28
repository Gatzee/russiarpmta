
MERGE_CHANNELS = {}
VISIBLE_CHAT_DATA = {
    [ CHAT_TYPE_NORMAL ]     = { id = 1, name = "Общий",              },
    [ CHAT_TYPE_TRADE ]      = { id = 2, name = "Торговый",           },
    [ CHAT_TYPE_OFFGAME ]    = { id = 3, name = "Внеигровой",         },
    [ CHAT_TYPE_ADMIN ]      = { id = 4, name = "Админ",              },
    [ CHAT_TYPE_FACTION ]    = { id = 5, name = "Фракции",            },
    [ CHAT_TYPE_ALLFACTION ] = { id = 6, name = "Объявления фракций", },
    [ CHAT_TYPE_CLAN ]       = { id = 7, name = "Клан",               },
    [ CHAT_TYPE_JOB ]        = { id = 8, name = "Рабочий",            },
}

local FILE_PATH_MERGE_SETTING = "setting_3.nrp"

local AVAILABLE_MERGE_CHAT_LIST =
{
    CHAT_TYPE_NORMAL,
    CHAT_TYPE_TRADE,
    CHAT_TYPE_OFFGAME,
	CHAT_TYPE_ADMIN,
    CHAT_TYPE_FACTION,
    CHAT_TYPE_ALLFACTION,
	CHAT_TYPE_CLAN,
	CHAT_TYPE_JOB,
}

function ShowMenuSetting( state )
    if state then
        if isElement( UI_elements.bg_setting ) then return end

        UI_elements.ticks = 0
        UI_elements.timeout = 255

        UI_elements.bg_setting = ibCreateImage( 480, 100, 350, 370, "img/bg_setting.png" ):ibBatchData( { alpha = 0, priority = -11 } )

        ibCreateButton( 350 - 33, 13, 14, 14, UI_elements.bg_setting, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                ibClick()

                ShowMenuSetting( false )
            end )

        UI_elements.scrollpane, UI_elements.scrollbar = ibCreateScrollpane( 20, 60, 310, 280, UI_elements.bg_setting, { scroll_px = 5 } )
        UI_elements.scrollbar:ibSetStyle( "slim_nobg" )

        local py = 0
        for _, v in ipairs( AVAILABLE_MERGE_CHAT_LIST ) do
            if REVERSE_CHAT_CHANNELS[ v ] then
                UI_elements[ "setting_btn" .. v ] = ibCreateImage( 0, py, 310, 40, false, UI_elements.scrollpane, ibApplyAlpha( 0xFF1C2229, 60 ) )
                    :ibOnHover( function()
                        source:ibData("color", ibApplyAlpha( 0xFF1C2229, 100 ) )
                    end )
                    :ibOnLeave( function()
                        source:ibData("color", ibApplyAlpha( 0xFF1C2229, 60 ) )
                    end )
                    :ibOnClick( function( button, state )
                        if button ~= "left" or state ~= "down" then return end

                        local ticks = getTickCount()
                        if ticks < UI_elements.ticks then return end
                        UI_elements.ticks = ticks + UI_elements.timeout
    
                        source:ibData("color", ibApplyAlpha( 0xFF1C2229, 100 ) )
                        ShowDropdownListSetting( not isElement( UI_elements[ "setting_rt" .. v ] ), v )
                        ibClick()
                    end )
            
                UI_elements[ "arrow" .. v ] = ibCreateImage( 282, 14, 8, 12, "img/arrow.png", UI_elements[ "setting_btn" .. v ] ):ibData( "disabled", true )
                ibCreateLabel( 15, 0, 0, 40, CHAT_CHANNELS_NAME[ v ], UI_elements[ "setting_btn" .. v ], 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.regular_14 ):ibData( "disabled", true )
            
                py = py + 50
            end
        end

        UI_elements.scrollpane:AdaptHeightToContents()
        UI_elements.scrollbar:UpdateScrollbarVisibility( UI_elements.scrollpane )

        UI_elements.bg_setting:ibAlphaTo( 255, 150 )

    elseif isElement( UI_elements and UI_elements.bg_setting ) then
        destroyElement( UI_elements.bg_setting )
        SaveMergeSetting()
    end
end

function ShowDropdownListSetting( state, channel_id )
    local channel_data = VISIBLE_CHAT_DATA[ channel_id ]
    if state then
        UI_elements[ "setting_rt" .. channel_id ] = ibCreateRenderTarget( 0,  UI_elements[ "setting_btn" .. channel_id ]:ibGetAfterY(), 310, 190, UI_elements.scrollpane )
        UI_elements[ "setting_area" .. channel_id ] = ibCreateArea( 0, -310, 310, 135, UI_elements[ "setting_rt" .. channel_id ])

        local py = 0
        local iter = 1
        for k, v in pairs( MERGE_CHANNELS[ channel_id ] ) do
            if REVERSE_CHAT_CHANNELS[ k ] then
                local line = ibCreateImage( 0, py, 310, 26, _, UI_elements[ "setting_area" .. channel_id ], ibApplyAlpha( 0xFF1C2229, 40 ) )
                local check_box = ibCreateCheckBox( 277, 6, "img/rectangle.png", "img/check.png", line, v.merge, function()
                    v.merge = not v.merge
                end )        
            
                ibCreateLabel( 20, 0, 0, 27, iter .. ". " .. VISIBLE_CHAT_DATA[ k ].name, line, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.regular_12 )
                if k > 1 then ibCreateImage( 0, py - 1, 310, 1, _, UI_elements[ "setting_area" .. channel_id ], 0xFF1C2229 ) end
            
                py = py + 27
                iter = iter + 1
            end
        end

        local offset = (24 * iter)
        for k, v in pairs( MERGE_CHANNELS ) do
            if isElement( UI_elements[ "setting_btn" .. k ] ) and VISIBLE_CHAT_DATA[ k ].id > channel_data.id  then
                UI_elements[ "setting_btn" .. k ]:ibMoveTo( _, UI_elements[ "setting_btn" .. k ]:ibData( "py" ) + offset, 250 )
                if isElement( UI_elements[ "setting_rt" .. k ] ) then
                    UI_elements[ "setting_rt" .. k ]:ibMoveTo( _, UI_elements[ "setting_rt" .. k ]:ibData( "py" ) + offset, 250 )
                end
            end
        end

        UI_elements[ "arrow" .. channel_id ]:ibInterpolate( function( self )
            self.element:ibData( "rotation", 90 * self.progress )
            UI_elements[ "setting_area" .. channel_id ]:ibData( "py", -310 + ( self.progress * 310 ) )
        end, 250, "Linear" )

        UI_elements[ "setting_btn" .. channel_id ]:ibTimer( function()
            UI_elements.scrollpane:AdaptHeightToContents()
            UI_elements.scrollbar:UpdateScrollbarVisibility( UI_elements.scrollpane )
        end, 250, 1 )

        UI_elements[ "setting_rt" .. channel_id ]:ibData( "iter", iter )
    else
        UI_elements[ "setting_btn" .. channel_id ]:ibData("color", ibApplyAlpha( 0xFF1C2229, 60 ) )

        UI_elements[ "arrow" .. channel_id ]:ibInterpolate( function( self )
            if not isElement( UI_elements[ "setting_area" .. channel_id ] ) then return end

            self.element:ibData( "rotation", 90 - (90 * self.progress) )
            UI_elements[ "setting_area" .. channel_id ]:ibData( "py", ( self.progress * -310 ) )
        end, 250, "Linear" )

        local offset = (24 * UI_elements[ "setting_rt" .. channel_id ]:ibData("iter"))
        for k, v in pairs( MERGE_CHANNELS ) do
            if isElement( UI_elements[ "setting_btn" .. k ] ) and VISIBLE_CHAT_DATA[ k ].id > channel_data.id  then
                UI_elements[ "setting_btn" .. k ]:ibMoveTo( _, UI_elements[ "setting_btn" .. k ]:ibData( "py" ) - offset, 250 )
                if isElement( UI_elements[ "setting_rt" .. k ] ) then
                    UI_elements[ "setting_rt" .. k ]:ibMoveTo( _, UI_elements[ "setting_rt" .. k ]:ibData( "py" ) - offset, 250 )
                end
            end
        end

        UI_elements[ "setting_btn" .. channel_id ]:ibTimer( function()
            UI_elements[ "setting_rt" .. channel_id ]:destroy()

            UI_elements.scrollpane:AdaptHeightToContents()
            UI_elements.scrollbar:UpdateScrollbarVisibility( UI_elements.scrollpane ):ibData( "position", 0.7 )
        end, 250, 1 )
    end
end

function LoadMergeSetting()
    local file = nil
    if fileExists( FILE_PATH_MERGE_SETTING ) then
        file = fileOpen( FILE_PATH_MERGE_SETTING )
        
        local file_size = fileGetSize( file )
        local file_text = fileRead( file, file_size )

        MERGE_CHANNELS = FixTableKeys( fromJSON( file_text ), true )
    else
        file = fileCreate( FILE_PATH_MERGE_SETTING )
        
        for k, v in pairs( AVAILABLE_MERGE_CHAT_LIST ) do
            MERGE_CHANNELS[ v ] = CreateMergeModel( v )
        end

        fileWrite( file, toJSON( MERGE_CHANNELS ) )
    end
    fileClose( file )
end

function SaveMergeSetting()
    if fileExists( FILE_PATH_MERGE_SETTING ) then fileDelete( FILE_PATH_MERGE_SETTING ) end
    
    local file = fileCreate( FILE_PATH_MERGE_SETTING )
    fileWrite( file, toJSON( MERGE_CHANNELS ) )
    
    fileClose( file )
end

local merged_data =
{
    [ CHAT_TYPE_FACTION ] = 
    {
        [ CHAT_TYPE_ALLFACTION ] = true,
    },
}

function CreateMergeModel( channel_id )
    local merge_channels = {}
    for k, v in ipairs( AVAILABLE_MERGE_CHAT_LIST ) do
        if v ~= channel_id then
            table.insert( merge_channels, v, { merge = (channel_id == CHAT_TYPE_NORMAL or (merged_data[ channel_id ] and merged_data[ channel_id ][ v ])) and true or false } )
        end
    end
    return merge_channels
end

function ibCreateCheckBox( x, y, rectangle_texture, check_texture, parent, state, callback )
    local self = {}

    self.state = state
    self.callback = callback
    self.area = ibCreateImage( x, y, 0, 0, rectangle_texture, parent ):ibSetRealSize()

    self.check = ibCreateImage( 0, 0, 0, 0, check_texture, self.area ):ibSetRealSize()

    local area_sx, area_sy = self.area:ibGetTextureSize( )
    local check_sx, check_sy = self.check:ibGetTextureSize( )
    self.check:ibBatchData( { px = (area_sx - check_sx) / 2, py = (area_sy - check_sy) / 2, disabled = true, alpha = self.state and 255 or 0  } )

    self.area:ibOnClick( function( button, state )
        if button ~= "left" or state ~= "down" then return end
        ibClick()
        self.callback()
        self.state = not self.state
        if self.state then
            self.check:ibData( "alpha", 255 )
        else
            self.check:ibData( "alpha", 0 )
        end
    end )

    return self.area
end