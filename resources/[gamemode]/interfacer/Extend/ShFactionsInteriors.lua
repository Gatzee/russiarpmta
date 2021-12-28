FACTIONS_INTERIORS = {
    {
        marker_text = "Полиция\nг.Новороссийск",
        outside = Vector3( -356.7, -1666.3 + 860, 22.3 ),
        inside = Vector3( -363.4, -797.5, 1061.4 ),
        inside_interior = 1,
        inside_dimension = 1,

        OnEnter = function()
            localPlayer:CompleteDailyQuest( "np_visit_pps" )
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
        marker_text = "Полиция г.Горки",
        outside = Vector3( 1945.0, -735.52 + 860, 60.77 ),
        inside = Vector3( 1954.62, 123.98, 631.38 ),
        inside_interior = 1,
        inside_dimension = 1,

        OnEnter = function()
            localPlayer:CompleteDailyQuest( "np_visit_pps" )
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
        marker_text = "ДПС г.Новороссийск",
        outside = Vector3( 336.147, -2039.766 + 860, 21.819 ),
        inside = Vector3( 337.7, -1187 , 1021.6 ),
        inside_interior = 1,
        inside_dimension = 1,

        OnEnter = function()
            localPlayer:CompleteDailyQuest( "np_visit_dps" )
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
        marker_text = "ДПС г.Новороссийск",
        outside = Vector3( 344.742, -2055.1 + 860, 20.982 ),
        inside = Vector3( 321.242, -1169.022, 1025.975 ),
        inside_marker_text = "Выход на стоянку",
        radius = 1.8,
        inside_interior = 1,
        inside_dimension = 1,
        inside_check = function( self, player )
            if player:GetFaction() ~= F_POLICE_DPS_NSK then
                return false, "Этот выход только для сотрудников ДПС"
            end
            return true
        end,
        outside_check = function( self, player )
            if player:GetFaction() ~= F_POLICE_DPS_NSK then
                return false, "Этот вход только для сотрудников ДПС"
            end
            return true
        end,
    },

    {
        marker_text = "ДПС г.Горки",
        outside = Vector3( 2233.9365, -642.1792 + 860, 60.8238 ),
        inside = Vector3( 2194.84, 214.30, 601.00 ),
        inside_interior = 1,
        inside_dimension = 1,

        OnEnter = function()
            localPlayer:CompleteDailyQuest( "np_visit_dps" )
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
        marker_text = "ФСИН \nАдминистративное здание",
        outside = Vector3( -2799.8103, 1608.2893 + 860, 14.5670 ),
        inside  = Vector3( -2660.3198, 2833.1152, 1540.4663 ),
        inside_interior = 1,
        inside_dimension = 1,

        outside_check = function( self, player )
            if localPlayer:getData( "jailed" ) then
                return false
            end
            if player:GetBlockInteriorInteraction() then
                player:ShowInfo( "Вы не можете войти во время задания" )
                return false
            end
            return true
        end,
    },

    {
        marker_text = "ФСИН \nЦех 1",
        outside = Vector3( -2798.7717, 1933.5070 + 860, 15.5955 ),
        inside  = Vector3( -2664.8, 2923.1, 1571.3 ),
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
        marker_text = "ФСИН \nЦех 2",
        outside = Vector3( -2645.2295, 1923.5717 + 860, 15.3731 ),
        inside  = Vector3( -2664.8, 2923.1, 1571.3 ),
        inside_interior = 1,
        inside_dimension = 2,

        outside_check = function( self, player )
            if player:GetBlockInteriorInteraction() then
                player:ShowInfo( "Вы не можете войти во время задания" )
                return false
            end
            return true
        end,

    },

    {
        marker_text = "ФСИН \nТюрьма 1",
        outside = Vector3( -2501.6325, 1865.4399 + 860, 15.7148 ),
        inside  = Vector3( -2689.1955, 2620.5263, 1618.4262 ),
        inside_interior = 1,
        inside_dimension = 1,
        radius = 1,
        drop_radius = 0.8,

        outside_check = function( self, player )
            local faction = player:GetFaction()
            if faction ~= F_FSIN or localPlayer:getData( "jailed" ) then
                return false
            end
            return true
        end,

    },

    {
        marker_text = "ФСИН \nТюрьма 2",
        outside = Vector3( -2394.9899, 1738.2614 + 860, 15.7189 ),
        inside  = Vector3( -2689.1955, 2620.5263, 1618.4262 ),
        inside_interior = 1,
        inside_dimension = 2,
        radius = 1,
        drop_radius = 0.8,

        outside_check = function( self, player )
            local faction = player:GetFaction()
            if faction ~= F_FSIN or localPlayer:getData( "jailed" ) then
                return false
            end
            return true
        end,

    },

    {
        marker_text = "ФСИН \nТюрьма 3",
        outside = Vector3( -2465.3684, 1613.7587 + 860, 15.8214 ),
        inside  = Vector3( -2689.1955, 2620.5263, 1618.4262 ),
        inside_interior = 1,
        inside_dimension = 3,
        radius = 1,
        drop_radius = 0.8,

        outside_check = function( self, player )
            local faction = player:GetFaction()
            if faction ~= F_FSIN or localPlayer:getData( "jailed" ) then
                return false
            end
            return true
        end,

    },
}