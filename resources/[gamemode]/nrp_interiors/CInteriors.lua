loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CInterior" )
Extend( "CPlayer" )
Extend( "ShClothesShops" )

INTERIORS = {
    {
        OnLoad = function( self )
            self.element:setData( "material", true, false )
    	    self:SetDropImage( { ":nrp_shared/img/dropimage.png", self.color[ 1 ], self.color[ 2 ], self.color[ 3 ], 255, 1.55 } )
        end,
        marker_text = "Мэрия\nг.Горки",
        outside = Vector3( 2271.094, -951.064, 61.308 ),
        inside = Vector3( 2269.01, -78.3, 670.99 ),
        inside_interior = 1,
        inside_dimension = 1,

        OnEnter = function()
            localPlayer:CompleteDailyQuest( "np_visit_mayor" )
            triggerServerEvent( "onPlayerLocationEnter", localPlayer, "government_gorki" )
        end,

        outside_check = function( self, player )
			if player:GetBlockInteriorInteraction() then
				player:ShowInfo( "Вы не можете войти во время задания" )
				return false
			end
			return true
		end,
    },

    {
        OnLoad = function( self )
            self.element:setData( "material", true, false )
    	    self:SetDropImage( { ":nrp_shared/img/dropimage.png", self.color[ 1 ], self.color[ 2 ], self.color[ 3 ], 255, 1.55 } )
        end,
        marker_text = "Мэрия\nг.Новороссийск",
        outside = Vector3( 1.300, -1696.367, 21.696 ),
        inside = Vector3( -40.936, -875.974, 1047.537 ),
        inside_interior = 1,
        inside_dimension = 1,

        OnEnter = function()
            localPlayer:CompleteDailyQuest( "np_visit_mayor" )
            triggerServerEvent( "onPlayerLocationEnter", localPlayer, "government_nsk" )
        end,

        outside_check = function( self, player )
			if player:GetBlockInteriorInteraction() then
				player:ShowInfo( "Вы не можете войти во время задания" )
				return false
			end
			return true
		end,
    },

    {
        OnLoad = function( self )
            self.element:setData( "material", true, false )
            self:SetDropImage( { ":nrp_shared/img/dropimage.png", self.color[ 1 ], self.color[ 2 ], self.color[ 3 ], 255, 1.55 } )
        end,
        marker_text = "Региональный Банк\nг.Новороссийск",
        outside = Vector3( 275.47, -1727.92, 20.7 ),
        inside = Vector3( 2298.807, 333.343, 640.999 ),
        inside_interior = 1,
        inside_dimension = 1,

        outside_check = function( self, player )
			if player:GetBlockInteriorInteraction() then
				player:ShowInfo( "Вы не можете войти во время задания" )
				return false
			end
			return true
		end,
    },

    {
        OnLoad = function( self )
            self.element:setData( "material", true, false )
    	    self:SetDropImage( { ":nrp_shared/img/dropimage.png", self.color[ 1 ], self.color[ 2 ], self.color[ 3 ], 255, 1.55 } )
        end,
        marker_text = "Военкомат",
        outside = Vector3( -1210.808, -1283.679, 21.502 ),
        inside = Vector3( -1269.338, -393.9159, 1292.1307 ),
        inside_interior = 1,
        inside_dimension = 1,

        outside_check = function( self, player )
			if player:GetBlockInteriorInteraction() then
				player:ShowInfo( "Вы не можете войти во время задания" )
				return false
			end
			return true
		end,
    },

    -- Школа танцев, г. НСК
    {
        marker_text = "Школа Танцев",
        outside = Vector3( 258.235, -2286.959, 20.796 ),
        inside = Vector3( -227.9, -389.9, 1338.6 ),
        inside_interior = 1,
        inside_dimension = 1,

        OnLoad = function( self )
            self.marker:setColor( 245, 128, 200, 10 )
            self.text = "ALT Взаимодействие"
            self:SetDropImage( { ":nrp_shared/img/dropimage.png", 245, 128, 200, 255, 1.5 } )
            self.elements = { }
            self.elements.blip = createBlipAttachedTo( self.marker, 48, 2, 255, 255, 255, 255, 0, 200 )
        end,

        OnEnter = function()
            localPlayer:CompleteDailyQuest( "np_visit_dance_school" )
        end,

        outside_check = function( self, player )
			if player:GetBlockInteriorInteraction() then
				player:ShowInfo( "Вы не можете войти во время задания" )
				return false
			end
			return true
		end,
    },

    -- Школа танцев, г. Горки
    {
        marker_text = "Школа Танцев",
        outside = Vector3( 2431.125, -605.5, 62 ),
        inside = Vector3( -227.9, -389.9, 1338.6 ),
        inside_interior = 1,
        inside_dimension = 2,

        OnLoad = function( self )
            self.marker:setColor( 245, 128, 245, 10 )
            self.text = "ALT Взаимодействие"
            self:SetDropImage( { ":nrp_shared/img/dropimage.png", 245, 128, 245, 255, 1.5 } )
            self.elements = { }
            self.elements.blip = createBlipAttachedTo( self.marker, 48, 2, 255, 255, 255, 255, 0, 200 )
        end,

        OnEnter = function()
            localPlayer:CompleteDailyQuest( "np_visit_dance_school" )
        end,

        outside_check = function( self, player )
			if player:GetBlockInteriorInteraction() then
				player:ShowInfo( "Вы не можете войти во время задания" )
				return false
			end
			return true
		end,
    },

    -- Школа танцев, Олимпийский Парк
    {
        marker_text = "Школа Танцев",
        outside = Vector3( 1859.723, 963.75, 17.386 ),
        inside = Vector3( -227.9, -389.9, 1338.6 ),
        inside_interior = 1,
        inside_dimension = 3,

        OnLoad = function( self )
            self.marker:setColor( 245, 128, 245, 10 )
            self.text = "ALT Взаимодействие"
            self:SetDropImage( { ":nrp_shared/img/dropimage.png", 245, 128, 245, 255, 1.5 } )
            self.elements = { }
            self.elements.blip = createBlipAttachedTo( self.marker, 48, 2, 255, 255, 255, 255, 0, 200 )
        end,

        OnEnter = function()
            localPlayer:CompleteDailyQuest( "np_visit_dance_school" )
        end,

        outside_check = function( self, player )
			if player:GetBlockInteriorInteraction() then
				player:ShowInfo( "Вы не можете войти во время задания" )
				return false
			end
			return true
		end,
    },
}

-- add clothes shops -- TODO: add coords of others systems (anti copy-past)
for idx, position in pairs( CLOTHES_SHOPS_LIST ) do
    table.insert( INTERIORS, {
        marker_text = "Магазин Одежды",
        outside = Vector3( position ),
        inside = Vector3( -230.3, -389.5, 1360.3 ),
        inside_interior = 1,
        inside_dimension = idx,

        OnLoad = function( self )
            self.marker:setColor( 128, 245, 128, 10 )
            self.text = "ALT Взаимодействие"
            self:SetImage( ":nrp_clothes_shop/images/marker.png" )
            self.element:setData( "material", true, false )
            self:SetDropImage( { ":nrp_shared/img/dropimage.png", 128, 245, 128, 255, 1.5 } )
            self.elements = { }
            self.elements.blip = createBlipAttachedTo( self.marker, 45, 2, 255, 255, 255, 255, 0, 200 )
        end,

        OnEnter = function()
            localPlayer:CompleteDailyQuest( "np_visit_cloth_shop" )
            localPlayer:CompleteDailyQuest( "np_view_cloth_shop" )
        end,

        outside_check = function( self, player )
            if player:GetBlockInteriorInteraction() then
                player:ShowInfo( "Вы не можете войти во время задания" )
                return false
            end
            return true
        end,
    } )
end

function GetMarkerConfigFor( conf, position, mtype )
    if mtype == "outside" then
        local outside_conf = {
            marker_text = conf.marker_text,
            text        = "ALT Взаимодействие",
            x           = position.x,
            y           = position.y + 860,
            z           = position.z,
            dimension   = conf.dimension or 0,
            interior    = conf.interior or 0,
            radius      = conf.radius or 2,
            color       = conf.color or { 0, 120, 255, 40 },
            OnLoad      = conf.OnLoad,
        }
        return outside_conf
    

    elseif mtype == "inside" then
        local inside_conf = {
            marker_text = conf.inside_marker_text or "Выход",
            text        = "ALT Взаимодействие",
            x           = position.x,
            y           = position.y,
            z           = position.z,
            dimension   = conf.inside_dimension,
            interior    = conf.inside_interior,
            radius      = 2,
            color       = { 0, 120, 255, 40 },
        }
        return inside_conf
    end
end

function onResourceStart_handler( )
    for i, conf in pairs( INTERIORS ) do
         -- Поддержка нескольких входов в интерьер
        local outside_tpoints = { }
        if type( conf.outside ) == "table" then
            for i, v in pairs( conf.outside ) do
                table.insert( outside_tpoints, TeleportPoint( GetMarkerConfigFor( conf, v, "outside" ) ) )
            end
        else
            table.insert( outside_tpoints, TeleportPoint( GetMarkerConfigFor( conf, conf.outside, "outside" ) ) )
        end

        -- Выход из интеьрера
        local inside_tpoint = TeleportPoint( GetMarkerConfigFor( conf, conf.inside, "inside" ) )
        inside_tpoint.element:setData( "material", true, false )
    	inside_tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", inside_tpoint.color[ 1 ], inside_tpoint.color[ 2 ], inside_tpoint.color[ 3 ], 255, 1.55 } )
        inside_tpoint.PreJoin = conf.inside_check

        for i, v in pairs( outside_tpoints ) do
            v.PreJoin = conf.outside_check
            v.PostJoin = function( )
                local position = inside_tpoint.colshape.position
                if #outside_tpoints > 1 then
                    localPlayer:setData( "enter_index", i, false )
                end

                localPlayer:Teleport( Vector3( position.x, position.y, position.z ), inside_tpoint.dimension, inside_tpoint.interior, 1000 )

                if conf.OnEnter then conf.OnEnter() end

                triggerServerEvent( "onTaxiPrivateFailWaiting", localPlayer, "Пассажир отменил заказ", "Ты зашёл в помещение, заказ в Такси отменен" )
            end
        end

        inside_tpoint.PostJoin = function( self )
            local enter_index = localPlayer:getData( "enter_index" )
            if enter_index then localPlayer:setData( "enter_index", false, false ) end
            local outside_tpoint = outside_tpoints[ enter_index and enter_index or 1 ]
            local position = outside_tpoint.colshape.position

            localPlayer:Teleport( Vector3( position.x, position.y, position.z ), outside_tpoint.dimension, outside_tpoint.interior, 50 )

            triggerServerEvent( "onTaxiPrivateFailWaiting", localPlayer, "Пассажир отменил заказ", "Ты зашёл в помещение, заказ в Такси отменен" )
        end
    end
end
addEventHandler( "onClientResourceStart", resourceRoot, onResourceStart_handler )