LAST_UPDATE = 1587589200

-- Костыль для открытия нужной вкладки
function SwitchToTabSimulated( tab, subtab, subsubtab )
    if not isElement( UI_elements.bg ) then return end

    local tab = tab or 1

    if type( subtab ) == "string" then
        for i, v in pairs( GLOBAL_TABS[ tab ].tabs ) do
            if v.name == subtab then
                subtab = i
                break
            end
        end
    end

    local subtab, subsubtab = subtab or 1, subsubtab or 1

    UI_elements[ "tab_" .. tab ]:ibTimer( 
        function( self, subtab, subsubtab )
            self:ibSimulateClick( "left", "up" )
                :ibOnClick( function( key, state, is_simulated )
                    if not is_simulated then return end

                    self:ibTimer( function( self, subtab, subsubtab )
                        UI_elements[ "subtab_" .. subtab ]:ibSimulateClick( "left", "up" )
                        self:ibTimer( function( )
							if type( subsubtab ) == "string" then
								for i, name in pairs( SUBSUBTABS ) do
									if name == subsubtab then
										subsubtab = i
									end
								end
							end

                            if isElement( UI_elements[ "subsubtab_" .. subsubtab ] ) then
                                UI_elements[ "subsubtab_" .. subsubtab ]:ibSimulateClick( "left", "up" )
                            else
                                if UI_elements.dropdown then
                                    triggerEvent( "onDropdownMenuOpen", UI_elements.dropdown, subsubtab )
                                end
                            end
                        end, 200, 1 )
                    end, 100, 1, subtab, subsubtab )
                end )
        end
    , 50, 1, subtab, subsubtab )
end

function CreateMoreButton( px, py, parent, fn )
    return 
        ibCreateButton( px, py, 0, 0, parent,
            "img/btn_more.png", "img/btn_more.png", "img/btn_more.png",
            0xFFFFFFFF, 0xEEFFFFFF, 0xCCFFFFFF ):ibSetRealSize( )
        :ibOnClick( fn )
end

function CreateNewMoreButton( px, py, parent, fn )
	return 
		ibCreateButton( px - 9, py - 5, 167, 52, parent,
			"img/btn_more_i.png", "img/btn_more_h.png", "img/btn_more_h.png",
			0xFFFFFFFF, 0xEEFFFFFF, 0xCCFFFFFF ):ibSetRealSize( )
		:ibOnClick( fn )
end

function CreatePointButton( px, py, parent, fn )
    return 
        ibCreateButton( px, py, 0, 0, parent,
            "img/btn_point.png", "img/btn_point.png", "img/btn_point.png",
            0xFFFFFFFF, 0xEEFFFFFF, 0xCCFFFFFF ):ibSetRealSize( )
        :ibOnClick( fn )
end

function CreateSpecialButton( py )
	return CreateMoreButton( 205, py, nil, function( key, state )
		if key ~= "left" or state ~= "up" then return end
		ibClick( )
		ShowInfoUI( false )
		triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "special" )
		SendElasticGameEvent( "f4r_f1_update_click", { link = "special" } )
	end )
end

function CreateNewSpecialButton( py )
	return CreateNewMoreButton( 220, py, nil, function( key, state )
		if key ~= "left" or state ~= "up" then return end
		ibClick( )
		ShowInfoUI( false )
		triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "special" )
		SendElasticGameEvent( "f4r_f1_update_click", { link = "special" } )
	end )
end

function CreateCasesButton( py )
	return CreateMoreButton( 205, py, nil, function( key, state )
		if key ~= "left" or state ~= "up" then return end
		ibClick( )
		ShowInfoUI( false )
		triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "cases" )
		SendElasticGameEvent( "f4r_f1_update_click", { link = "cases" } )
	end )
end

function CreatePremiumButton( py )
	return CreateMoreButton( 205, py, nil, function( key, state )
		if key ~= "left" or state ~= "up" then return end
		ibClick( )
		ShowInfoUI( false )
		triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "premium" )
		SendElasticGameEvent( "f4r_f1_update_click", { link = "premium" } )
	end )
end

function CreateDonateButton( py )
	return CreateMoreButton( 205, py, nil, function( key, state )
		if key ~= "left" or state ~= "up" then return end
		ibClick( )
		ShowInfoUI( false )
		triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate" )
		SendElasticGameEvent( "f4r_f1_update_click", { link = "donate" } )
	end )
end

function CreateServicesButton( py )
	return CreateMoreButton( 205, py, nil, function( key, state )
		if key ~= "left" or state ~= "up" then return end
		ibClick( )
		ShowInfoUI( false )
		triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "services" )
		SendElasticGameEvent( "f4r_f1_update_click", { link = "services" } )
	end )
end

function CreateOffersButton( py )
	return CreateMoreButton( 205, py, nil, function( key, state )
		if key ~= "left" or state ~= "up" then return end
		ibClick( )
		ShowInfoUI( false )
		triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "offers" )
		SendElasticGameEvent( "f4r_f1_update_click", { link = "offers" } )
	end )
end

function CreateShowBattlePassButton( py )
	return CreateMoreButton( 205, py, nil, function( key, state )
		if key ~= "left" or state ~= "up" then return end
		ibClick( )
		ShowInfoUI( false )
		triggerServerEvent( "BP:onPlayerWantShowUI", localPlayer )
	end )
end

function CreateGPSButton( py, positions, is_near )
	return CreatePointButton( 175, py, nil, function( key, state )
		if key ~= "left" or state ~= "up" then return end
		ibClick( )
		ShowInfoUI( false )
		triggerEvent( "ToggleGPS", localPlayer, positions, is_near )
	end )
end

function CreateClothesShopButton( py )
	return CreatePointButton( 175, py, nil, function( key, state )
		if key ~= "left" or state ~= "up" then return end
		ibClick( )
		ShowInfoUI( false )
		triggerEvent( "ToggleGPS", localPlayer, CLOTHES_SHOPS_LIST )
	end )
end

function CreateEagSoundArea( px, py, sx, sy, sound_path, tooltip_text )
	return ibCreateArea( px, py, sx, sy )
		:ibAttachTooltip( tooltip_text )
		:ibOnHover( function( )
			if not isElement( sound ) then
				sound = playSound( sound_path, true )
				sound.volume = 0
			end

			if isElement( sound ) then
				source:ibInterpolate( function( self )
					sound.volume = self.easing_value * 0.25
				end, 500, "Linear" )
			end
		end )
		:ibOnLeave( function( )
			if isElement( sound ) then
				source:ibInterpolate( function( self )
					sound.volume = ( 1 - self.easing_value ) * 0.25
				end, 500, "Linear" )
			end
		end )
		:ibOnDestroy( function( )
			if isElement( sound ) then
				destroyElement( sound )
			end
		end )
end

local VEHICLE_SHOP_POSITIONS = {
	{ x = -1011.702, y = -1475.423, z = 21.773 },
	{ x = -362.323, y = -1741.648, z = 20.917 },
	{ x = 1782.086, y = -628.719, z = 60.852 },
	{ x = 2047.004, y = -806.692, z = 62.649 },
	{ x = 1227.788, y = 2488.171, z = 11.11 },
	{ x = -256.490, y = -1901.199, z = 20.802 },
}
function CreateVehicleShopButton( shop_index, py )
	return CreatePointButton( 175, py, parent, function( key, state )
		if key ~= "left" or state ~= "up" then return end
		ibClick( )
		ShowInfoUI( false )
		triggerEvent( "ToggleGPS", localPlayer, VEHICLE_SHOP_POSITIONS[ shop_index ] )
	end )
end

function GenerateSpecialVehicle( veh_model, py )
	return function( )
		return IsOfferActiveForModel( "special", veh_model ), CreateSpecialButton( py )
	end
end

function GenerateSpecialSkin( skin_model, py )
	return function( )
		return IsOfferActiveForModel( "special", skin_model ), CreateSpecialButton( py )
	end
end

function GenerateSpecialNumber( number_id, py )
	return function( )
		return IsOfferActiveForModel( "special", number_id ), CreateSpecialButton( py or 340 )
	end
end

function CreateFixesList( update_list, fixes_list, parent, start_y )
	local bg = ibCreateArea( 0, start_y, 560, 200, parent )

	ibCreateLabel( 0, 23, 0, 0, "Корректировки", bg, 0xFFFF9759, _, _, "center", "center", ibFonts.bold_18 ):center_x( )

	offset_y = 45
	local lines = split( update_list, "\n" )
	for i, text in pairs( lines ) do
		local offset_x = 25
		if not string.find( text, "◇" ) and not string.find( text, "◈" ) then
			offset_y = offset_y - 10
			offset_x = offset_x + 18
		end

		ibCreateLabel( offset_x, offset_y, 0, 0, text, bg, _, _, _, "left", "top", ibFonts.light_15 )
		offset_y = offset_y + 25
	end

	if fixes_list then
		offset_y = offset_y + 10
		ibCreateLabel( 0, offset_y, 0, 0, "Исправленные баги", bg, 0xFFFF9759, _, _, "center", "center", ibFonts.bold_18 ):center_x( )
		offset_y = offset_y + 25

		local lines = split( fixes_list, "\n" )
		for i, text in pairs( lines ) do
			local offset_x = 25
			if not string.find( text, "◇" ) and not string.find( text, "◈" ) then
				offset_y = offset_y - 10
				offset_x = offset_x + 18
			end

			ibCreateLabel( offset_x, offset_y, 0, 0, text, bg, _, _, _, "left", "top", ibFonts.light_15 )
			offset_y = offset_y + 25
		end
	end

	bg:ibData( "sy", offset_y )

	return bg
end

function CreateSegmentedBlock( px, py, parent, fn_check, fn_create )
    if not fn_check or fn_check( ) then
        return fn_create( px, py, parent )
    end
end

function IsOfferActiveForModel( ... )
    return exports.nrp_shop:IsOfferActiveForModel( ... )
end

function GetCurrentSegment( ... )
    return exports.nrp_shop:GetCurrentSegment( ... )
end

function BuildSegmentedUpdate( folder, segmented_blocks, parent, update_list, fixes_list )
    local debug = false
	
	local blocks_count = #segmented_blocks
	local last_image
	local fixes
    for i, v in ipairs( segmented_blocks ) do
        local vals = { v( ) }
        local condition = vals[ 1 ]
        table.remove( vals, 1 )
		if condition or debug then
			local img = ibCreateUpdateImage( 0, ( last_image and last_image:ibGetAfterY( ) or 0 ), folder, i, parent )
				:ibOnDataChange( function( key, value )
					if key ~= "texture" then return end
					source:ibSetRealSize( )

					if i == blocks_count then
						UpdScroll( fixes or source, parent )
					end
				end )
				:ibSetRealSize( )

            if img then
				if last_image then
					last_image:ibOnDataChange( function( key, value )
						if key ~= "sy" then return end
						img:ibData( "py", source:ibGetAfterY( ) )

						if i == blocks_count then
							UpdScroll( fixes or img, parent )
						end
					end )
				end

                for n, k in pairs( vals ) do
                    k:setParent( img )
                end
            end
            last_image = img or last_image
        else
            for n, k in pairs( vals ) do
                destroyElement( k )
            end
        end
	end

	if update_list then
		fixes = CreateFixesList( update_list, fixes_list, parent, ( last_image and last_image:ibGetAfterY( ) or 0 ) )
		if last_image then
			last_image:ibOnDataChange( function( key, value )
				if key ~= "sy" then return end
				fixes:ibData( "py", source:ibGetAfterY( ) )
				UpdScroll( fixes, parent )
			end )
		end

		last_image = fixes
	end

    return last_image
end

function UpdScroll( img, parent )
	local size = img:ibGetAfterY( )
	parent:ibBatchData( { sx = 560, sy = size } )
	UI_elements.items_pane:ibData( "sy", size )
	UI_elements.contentbar_parent:ibData( "sy", size )

	UI_elements.items_scroll:ibData( 'position', 0 )

	UI_elements.items_pane:AdaptHeightToContents( )
	UI_elements.items_scroll:UpdateScrollbarVisibility( UI_elements.items_pane )
end

-- Для сегментации окна обновления по спешлам или скидкам:
--[[
    IsOfferActiveForModel( "special", id ) -- Спешл
    IsOfferActiveForModel( "discounts", id ) -- Скидки на машины
    local current_segment = GetCurrentSegment( ) -- Текущий сегмент игрока
    CreateSegmentedBlock( 0, 200, parent,
        function( )
            return IsOfferActiveForModel( "special", 580 )  -- Если активна скидка на панамеру
        end,
        function( px, py, parent )
            return ibCreateImage( 0, 0, 0, 0, "img/items/updates/panamera_img.png", parent ):ibSetRealSize( )
        end
    )
]]

local sound = nil

UPDATES = {
	{	"◈ 24.10.2021",
		 start_time = getTimestampFromString( "24 ноября 2021 00:00" ),
		 create_fn = function( parent )
			 local segmented_blocks = {
				 [ 1 ] = function( )
					 return true, CreateCasesButton( 387 ),
					 CreateShowBattlePassButton( 1285 ),
					 CreateNewSpecialButton( 1545 )
				 end,
			 }

			 return BuildSegmentedUpdate( "24_06_21", segmented_blocks, parent, [[
◈ Активация шасси на самолетах изменена на клавишу "H"
◈ Добавлена возможность досрочно закончить фракционные квесты
◈ Добавлена дополнительная навигация для фракционных квестов
◈ Классическая рулетка ВИП, изменены ставки
◈ Ланчи и еда больше не имеет ограничений в количестве хранимых
штук
◈ Увеличено время отображение текста в чате
◈ При покупке машины в F4 теперь дается одна бесплатная эвакуация
◈ Медики МСК. Добавлен план на смену
◈ Изменения в первом квесте "Получить транспорт"
]], [[
◇ Уменьшена зона запрещенной парковки около подвала кланов
в г.НСК
◇ Изменено описание Инвентаря в F1
◇ Исправлено создание лобби классической рулетки в интерьере
стрипклуба
◇ Кубок за победу в гонках больше не пропадет после смены ника
◇ В квесте "Скоростная доставка" исправлены названия подзадач
◇ Анимация переедания больше не активируется, если игрок сидит
в транспорте
◇ Анимации болезни больше не закрывают окна лотереи
◇ Таймер квеста "Незнакомка" не обновляется при создании
лобби гонок
◇ Фиксация сотрудниками ДПС\ППС снова работает на игроков,
сидящих в машине
◇ Исправлены случаи, когда ручной тормоз залипал или
не срабатывал
◇ Сотрудник ДПС больше не может управлять фракционными
авто Мэрии
◇ Исправлено получение статьи, в случаях, когда игрок нападает
на сотрудника фракции вне смены
◇ Исправлено позиционирование винилов в тюнинг салоне
◇ Удалены дублируемые окна наград после выполнения сюжетных
квестов
			]] ):ibGetAfterY( )
		 end
	},
	{	"◇ 17.10.2021",
		 start_time = getTimestampFromString( "17 ноября 2021 00:00" ),
		 create_fn = function( parent )
			 local segmented_blocks = {
				 [ 1 ] = function( )
					 return true, CreateCasesButton( 387 ),
					 CreateCasesButton( 857 ),
					 CreateNewSpecialButton( 1117 )
				 end,
			 }

			 return BuildSegmentedUpdate( "17_10_21", segmented_blocks, parent ):ibGetAfterY( )
		 end
	},
	{	"◈ 10.10.2021",
		 start_time = getTimestampFromString( "10 ноября 2021 00:00" ),
		 create_fn = function( parent )
			 local segmented_blocks = {
				 [ 1 ] = function( )
					 return true, CreateCasesButton( 387 ),
					 CreateMoreButton( 205, 829, parent, function( key, state )
						 if key ~= "left" or state ~= "up" then return end
						 ibClick( )
						 SwitchToTabSimulated( 1, 15, 3 )
					 end ),
					 CreateMoreButton( 205, 1291, parent, function( key, state )
						 if key ~= "left" or state ~= "up" then return end
						 ibClick( )
						 SwitchToTabSimulated( 2, 9, 1 )
					 end ),
					 CreateServicesButton( 2139 ),
					 CreateNewSpecialButton( 2399 )
				 end,
			 }

			 return BuildSegmentedUpdate( "10_10_21", segmented_blocks, parent, [[
◈ Квесты. Убран расход топлива у мопеда во время выполнения
квестов
◈ Скорректирована скорость автомобиля в квесте "Тонкие
переговоры"
◈ Кооперативные работы. В окнах трудоустройства добавлены
ссылки на дискорд
◈ Изменен маркер набора в Армию и ФСИН в GPS
◈ Изменена подвеска автомобиля Ваз 2112
◈ Улучшения окна "Миссия выполнена"
◈ Эвакуаторщик. Управление манипулятором изменено на стрелки
◈ Убраны часы, открывающиеся ранее на клавишу "1"
◈ Добавлено ограничение использования аптечек, если
персонаж получает урон
]], [[
◇ Исправлена возможность стрелять с пассажирского места ТС
находясь в ЗЗ
◇ Убрана опечатка в описании работы автомеханика
◇ Лидерство в клане можно было передать игроку вышедшему
из клана
◇ Акционная цена на премиум после окончания времени действия,
визуально не возвращалась к исходной
◇ Во время гонок больше не отображается худ с характеристиками
персонажа
◇ Исправлены кастомные колеса Subaru Impreza
◇ После самостоятельного увольнения мэра не начинались
выборы нового
◇ Исправлен интерфейс сезонных наград
◇ Исправлена причина некорректного снижение уровня
социального рейтинга
◇ В фоторежиме исправлено отображение информации о бизнесе
◇ Верфь. Скорректировано отображение морского транспорта
◇ Работы. Исправлены ошибки завершения смены
◇ Добавлено отображение звания в трудовой книжке,
после увольнения в оффлайн
◇ Игрок восточного картеля мог заспавнился внутри модели здания
◇ Верфь как бизнес. При снятии продукции уведомления
на телефон поступали от Московской мэрии
◇ Таксист компания. Не заканчивалась смена если игрок
сбивал пассажира
◇ Исправлено отображение баффа на получение опыта
◇ Игрока телепортировало в воздух если отменить анимацию
поцелуя и зайти в интерьер
◇ Сотрудник ЖКХ. Скорректированы маркеры входы в интерьер
◇ Газель. Настроена камера от первого лица
◇ Ежедневное задание. Некорректно отображалась награда в худе
◇ Сотрудники мэрии могли использовать транспорт вне смены
◇ Скорректировано положение метки граффити около
кладоискателя
			]] ):ibGetAfterY( )
		 end
	},
	{	"◇ 03.10.2021",
		start_time = getTimestampFromString( "3 ноября 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true, CreateCasesButton( 387 ),
					CreateShowBattlePassButton( 857 ),
					CreateNewSpecialButton( 1122 )
				end,
			}

			return BuildSegmentedUpdate( "03_10_21", segmented_blocks, parent ):ibGetAfterY( )
		end
	},
	{   "◇ 27.05.2021",
		start_time = getTimestampFromString( "27 мая 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true, CreateCasesButton( 387 ),
					CreateShowBattlePassButton( 791 ),
					CreateNewSpecialButton( 1056 )
				end,
			}

			return BuildSegmentedUpdate( "27_05_21", segmented_blocks, parent ):ibGetAfterY( )
		end
	},
	{   "◈ 20.05.2021",
		start_time = getTimestampFromString( "20 мая 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true, CreateCasesButton( 387 ),
					CreateCasesButton( 857 ),
					CreateMoreButton( 205, 1280, parent, function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
						SwitchToTabSimulated( 1, 14, 7 )
					end ),
					CreateMoreButton( 205, 1703, parent, function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
						SwitchToTabSimulated( 1, 11, 1 )
					end ),
					CreateMoreButton( 205, 2532, parent, function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
						SwitchToTabSimulated( 1, 10, 1 )
					end ),
					CreateSpecialButton( 3220 )
				end,
			}

			return BuildSegmentedUpdate( "20_05_21", segmented_blocks, parent, [[
◈ Квесты. Персонаж теперь телепортируется к НПС в
случае провала задания
◈ Небольшие изменения цен на оружие у барыги
◈ Мэрия. Перезарядка повторного прохождения
учения "объезд" уменьшена
]], [[
◇ Драг рейсинг. Исправлены случаи, когда чат
не закрывался
◇ Сотрудник фракции теперь не может вытащить
персонажа из авто, если находится не на смене
◇ Анимации болезней больше не ломают анимацию
переноса ящика
◇ Возвращено отображение аксессуаров на мотоциклах
◇ Nissan Silvia. Исправлен размер колес
◇ Убрано отображение акций в фоторежиме
◇ Соцретинг отнимался, если персонаж умирал
в воде, исправлено
◇ Офис. Увеличено количество символов для
строки приглашения
◇ "Возможное разоблачение" увеличена зона квеста
◇ Колесо фортуны. Исправлено отображение джекпота
◇ Спецтранспорт. Добавлено уведомление при попытке
эвакуировать разрушенный транспорт
◇ Исправлено изменение характеристик авто после
участия в драг-рейсинге
◇ Актуализирована информация о бонусах
недвижимости в F1
◇ Звук поворотников оставался, если персонаж
умер в машине, исправлено
			]] ):ibGetAfterY( )
		end
	},
	{   "◇ 13.05.2021",
		start_time = getTimestampFromString( "13 мая 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( ) return true, CreateCasesButton( 387 ) end,
				[ 2 ] = function( ) return true, CreateSpecialButton( 470 ) end,
				[ 3 ] = GenerateSpecialVehicle( 6540, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 6635, 361 ),
				[ 5 ] = GenerateSpecialVehicle( 6634, 377 ),
				[ 6 ] = GenerateSpecialNumber( 10 ),
				[ 7 ] = GenerateSpecialNumber( 11 ),
                [ 8 ] = function( )
					return true, CreateSpecialButton( 359 ),
					CreateSpecialButton( 784 ),
					CreateSpecialButton( 1209 ),
					CreateSpecialButton( 1635 ),
					CreateVehicleShopButton( 5, 2040 )
                end,
			}

			return BuildSegmentedUpdate( "13_05_21", segmented_blocks, parent ):ibGetAfterY( )
		end
	},
	{   "◇ 06.05.2021",
		start_time = getTimestampFromString( "6 мая 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true,
					CreateCasesButton( 387 ),
					CreateCasesButton( 858 )
				end,
				[ 2 ] = function( ) return true, CreateSpecialButton( 451 ) end,
				[ 3 ] = GenerateSpecialVehicle( 6539, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 567, 361 ),
				[ 5 ] = GenerateSpecialVehicle( 458, 377 ),
				[ 6 ] = GenerateSpecialNumber( 124 ),
				[ 7 ] = GenerateSpecialNumber( 125 ),
                [ 8 ] = function( )
					return true, CreateSpecialButton( 410 ),
					CreateSpecialButton( 835 ),
					CreateSpecialButton( 1260 )
                end,
			}

			return BuildSegmentedUpdate( "06_05_21", segmented_blocks, parent ):ibGetAfterY( )
		end
	},
	{   "◈ 29.04.2021",
		start_time = getTimestampFromString( "29 апреля 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true, CreateCasesButton( 387 ),
					CreateMoreButton( 205, 1274, parent, function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
						ShowInfoUI( false )
						triggerEvent( "ShowUIQuestsList", localPlayer )
					end ),
					CreateServicesButton( 1698 ),
					CreateMoreButton( 205, 2141, parent, function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
						SwitchToTabSimulated( 1, 5, 1 )
					end ),
					CreateServicesButton( 2583 ),
					CreateMoreButton( 205, 3006, parent, function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
						SwitchToTabSimulated( 1, 18, 1 )
					end ),
					CreateMoreButton( 205, 3468, parent, function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
						SwitchToTabSimulated( 1, 11, 1 )
					end )
				end,
				[ 2 ] = function( )
					return true, CreateSpecialButton( 451 ),
					CreateSpecialButton( 929 )
				end,
				[ 3 ] = GenerateSpecialVehicle( 6595, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 6620, 361 ),
				[ 5 ] = function( )
					return IsOfferActiveForModel( "special", 420 ), CreateSpecialButton( 358 ),
					CreateEagSoundArea( 0, 0, 560, 350, "sfx/camry3.5.mp3", "♪♪♪" )
				end,
				[ 6 ] = GenerateSpecialVehicle( 542, 377 ),
				[ 7 ] = GenerateSpecialNumber( 56 ),
				[ 8 ] = GenerateSpecialNumber( 57 ),
                [ 9 ] = function( )
					return true, CreateSpecialButton( 360 ),
					CreateSpecialButton( 785 ),
					CreateSpecialButton( 1209 ),
					CreateVehicleShopButton( 3, 1632 )
                end,
			}

			return BuildSegmentedUpdate( "29_04_21", segmented_blocks, parent, [[
◈ Обновлен переход с работу на работу
◈ Обновлен интерфейс работы "таксист частник"
◈ Внутренние изменения всех одиночных работ,
убрана функция "устраиваться на работу",
добавлен автовыбор максимально доступного уровня
◈ Обновлены цены для машин из автосалона
◈ В окно парковки добавлено отображение номера авто
◈ Для бизнес офиса добавлена возможность
вывода денег с счета
◈ Летчик компания. Добавлено отображение
сброшенных грузов
◈ Летчик компания. Увеличено время для взлета с полосы
◈ BMW 525i - добавлен внешний тюнинг
◈ Merc C63AMG 6.3AT - добавлен внешний тюнинг
◈ Toyota camry - обновлены модели внешнего тюнинга
◈ BMW m2 - Уменьшена стоимость внешнего тюнинга
◈ Расширены возможности инвентаря внутреннего тюнинга
◈ Метки на карте теперь видят все пассажиры
внутри одной машины
◈ Убрано отображение аксессуаров внутри машины
◈ Дальнобойщик. Обновлена модель кузова для фур
]], [[
◇ Range Rover SVR. Исправлена позиция спойлера
при открытии багажника
◇ DeLorean DMC-12. Исправлены положения
гидравлической подвески
◇ Анимации "Стойки на руках" больше не меняют
расположение персонажа
◇ F1. Заменено изображение для работы "Мусорщик"
◇ С Танка убрана фракционная сирена
◇ Танк. Убрана фракционная сирена
◇ UAZ Patrion. Убрана фракционная сирена
◇ Lamba Urus. Убрана фракционная сирена
◇ Ученик Расследование убийства НСК.
Убрана лишняя обязательная роль
◇ Исправлено отображение стоимости оплаты ЖКХ в телефоне
◇ Кланы. Исправлена ошибка при выдачи скинов за уровень
◇ Колесо фортуны. Обновлена информация в окне подсказки
◇ Учение Сопровождение посла. Исправлены случаи, когда
автомобиль не получал урон
◇ Исправлена модель всех мостов. Игрок больше
не может умереть, перепрыгивая через мост
◇ Мотосалон. Обновлены характеристики мотоциклов
◇ Mercedes-Benz 300SL. улучшена модель авто
◇ BMW m4. Улучшена модель авто
◇ Квест "Тест-драйв" исправлено отображение
спидометра во время гонки
◇ Sea Ray L650 Fly. Исправлено отображение модели с
включенным затенением
◇ Ваз 2115. Добавлена выхлопная труба, исправлена
модель бампера и стекол
◇ Jaguar I-PACE. Исправлен размер стоковых колес
◇ Ваз 2107. Исправлено положение спойлеров
при открытии багажника
◇ Ваз 2107. Исправлено отображение капота с
включенной настройкой "Отблеск машин"
◇ ЗАЗ 968. Исправлен размер стоковых колес
◇ UAZ Hunter. Исправлено отображение стекол с
включённой настройкой "Отблеск машин"
◇ Ваз 2106. Исправлена ширина стоковых колес
◇ Приора. Исправлена модель динамиков в салоне
◇ Квадроцикл. Добавлены поворотники
◇ Исправления физической модели для автомобилей:
Kia Stinger, Буханка, Запорожец, Mercedes GL, Kia Stinger,
Honda Civic, Lincoln town car 1989, Aventador
			]] ):ibGetAfterY( )
		end
	},
	{   "◇ 22.04.2021",
		start_time = getTimestampFromString( "22 апреля 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true,
					CreateCasesButton( 387 ),
					CreateCasesButton( 858 )
				end,
				[ 2 ] = function( ) return true, CreateSpecialButton( 470 ) end,
				[ 3 ] = GenerateSpecialVehicle( 6545, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 6594, 361 ),
				[ 5 ] = GenerateSpecialVehicle( 496, 377 ),
				[ 6 ] = GenerateSpecialNumber( 20 ),
				[ 7 ] = GenerateSpecialNumber( 19 ),
                [ 8 ] = function( )
					return true, CreateSpecialButton( 360 ),
					CreateSpecialButton( 785 ),
					CreateSpecialButton( 1210 )
                end,
			}

			return BuildSegmentedUpdate( "22_04_21", segmented_blocks, parent ):ibGetAfterY( )
		end
	},
	{   "◇ 15.04.2021",
		start_time = getTimestampFromString( "15 апреля 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true,
					CreateCasesButton( 387 ),
					CreateCasesButton( 858 ),
					CreateShowBattlePassButton( 1281 )
				end,
				[ 2 ] = function( ) return true, CreateSpecialButton( 451 ) end,
				[ 3 ] = GenerateSpecialVehicle( 6565, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 6590, 361 ),
				[ 5 ] = GenerateSpecialVehicle( 6588, 377 ),
				[ 6 ] = GenerateSpecialNumber( 99 ),
				[ 7 ] = GenerateSpecialNumber( 100 ),
                [ 8 ] = function( )
					return true, CreateSpecialButton( 360 ),
					CreateSpecialButton( 785 ),
					CreateSpecialButton( 1210 ),
					CreateSpecialButton( 1635 )
                end,
			}

			return BuildSegmentedUpdate( "15_04_21", segmented_blocks, parent ):ibGetAfterY( )
		end
	},
	{   "◈ 08.04.2021",
		start_time = getTimestampFromString( "8 апреля 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true, CreateCasesButton( 387 ),
					CreateCasesButton( 858 ),
					CreateMoreButton( 205, 1720, parent, function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
						ShowInfoUI( false )
						triggerEvent( "socialInteractionShowMenu", localPlayer )
					end ),
					CreateServicesButton( 2144 ),
					CreatePremiumButton( 2642 )
				end,
				[ 2 ] = function( ) return true, CreateSpecialButton( 451 ) end,
				[ 3 ] = GenerateSpecialVehicle( 6561, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 505, 361 ),
				[ 5 ] = GenerateSpecialVehicle( 6544, 377 ),
				[ 6 ] = GenerateSpecialNumber( 91 ),
				[ 7 ] = GenerateSpecialNumber( 92 ),
                [ 8 ] = function( )
					return true, CreateSpecialButton( 360 ),
					CreateSpecialButton( 785 ),
					CreateSpecialButton( 1210 ),
					CreateSpecialButton( 1635 )
                end,
			}

			return BuildSegmentedUpdate( "08_04_21", segmented_blocks, parent, [[
◈  Сотрудник ЖКХ. Уменьшено количество действий для
завершения ремонта
◈  Сотрудник ЖКХ. Уменьшено количество ремонтов
в квартирах с 2 до 1
◈  Увеличено количество бонусов от премиума
◈  Увеличено количество уникальных машин в
автосалоне, доступных с премиумом
]], [[
◇ Сотрудник ЖКХ г.Горки, исправлены случаи когда после выхода
из интерьера персонаж оказывался внутри модели здания
◇ Сотрудники ППС и ДПС больше не могут выдавать
розыски вне смены
◇ Гонки. Исправлено отображение тюнинг кейса
"счастливчик" в наградах
◇ Исправлены случаи, когда было слышно переговоры
по ориентировкам с выключенной рацией
◇ Сотрудники ППС и ДПС снова могут заковывать
в наручники игрока сбежавшего из фсин
◇ Исправлено отображение жетонов в колесе фортуны
при переоткрытии окна
◇ Toyota AE86, изменение характеристик авто
			]] ):ibGetAfterY( )
		end
	},
	{   "◇ 01.04.2021",
		start_time = getTimestampFromString( "1 апреля 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true,
					CreateCasesButton( 387 ),
					CreateCasesButton( 858 )
				end,
				[ 2 ] = function( ) return true, CreateSpecialButton( 451 ) end,
				[ 3 ] = GenerateSpecialVehicle( 6542, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 490, 361 ),
				[ 5 ] = GenerateSpecialVehicle( 6531, 377 ),
				[ 6 ] = GenerateSpecialNumber( 95 ),
				[ 7 ] = GenerateSpecialNumber( 96 ),
                [ 8 ] = function( )
					return true, CreateSpecialButton( 360 ),
					CreateSpecialButton( 785 ),
					CreateSpecialButton( 1210 ),
					CreateSpecialButton( 1635 ),
					CreateVehicleShopButton( 3, 2040 )
                end,
			}

			return BuildSegmentedUpdate( "01_04_21", segmented_blocks, parent ):ibGetAfterY( )
		end
	},
	{   "◈ 25.03.2021",
		start_time = getTimestampFromString( "25 марта 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true, CreateCasesButton( 387 ),
					CreateMoreButton( 205, 1180, parent, function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
						ShowInfoUI( false )
						triggerEvent( "ShowUIQuestsList", localPlayer )
					end ),
					CreateMoreButton( 205, 1584, parent, function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
						SwitchToTabSimulated( 1, 5, 1 )
					end ),
					CreateMoreButton( 205, 2027, parent, function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
					end )
				end,
				[ 2 ] = function( ) return true, CreateSpecialButton( 451 ) end,
				[ 3 ] = GenerateSpecialVehicle( 445, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 6628, 361 ),
				[ 5 ] = GenerateSpecialVehicle( 6535, 377 ),
				[ 6 ] = GenerateSpecialNumber( 122 ),
				[ 7 ] = GenerateSpecialNumber( 123 ),
                [ 8 ] = function( )
					return true, CreateSpecialButton( 360 ),
					CreateSpecialButton( 785 ),
					CreateVehicleShopButton( 5, 1209 )
                end,
			}

			return BuildSegmentedUpdate( "25_03_21", segmented_blocks, parent, [[
◈ На работу "курьер в компании" теперь можно устроиться не
посещая работу "курьер подработка"
◈ Уведомление при выполнении задачи из F4-акции
перенесены в телефон
◈ Заменено уведомление при самостоятельном завершении
смены через окно работы
◈ Для команды respawn добавлена перезарядка 15 минут
◈ Обновление правил сервера (F10)
◈ Изменен звук при заправке электрических авто
]], [[
◇ Изменена управляемость мусоровоза
◇ Исправлены ошибки при удалении записей из
трудовой книжки
◇ Исправлены случаи, когда игрок не мог закрыть инвентарь
находясь в лобби "промышленная рыбалка"
◇ При активации фоторежима таймер весенней акции
теперь не отображается на экране
◇ e39 530d перенесена в салон мерседес
◇ Toyota ae86 привод заменен на задний
◇ Бассейны некоторых коттеджей в Рублево были без воды
◇ Квест "Получить транспорт", телефон больше нельзя
закрыть во время обучения по квесту
◇ Промышленная рыбалка. Сдвинута точка ловли, ранее
задевающая запретную зону аэропорта
◇ Промышленная рыбалка. Находясь внутри корабля больше
нельзя эвакуировать собственный транспорт
◇ Кланы. Бафф от срока в тюрьме больше не распостроняется
на наказания от администрации
◇ Медики. Исправлены случаи когда при лечении не записывалась
рекомендация в мед книжку
◇ Исправлена работа настройки "прозрачность игроков",
доступная в комнатах кинотеатра
◇ Свадебный шоколад теперь восстанавливает 100% здоровья
вместо 100ед
◇ Фракционный вертолет Мэрии МСК теперь можно бесплатно
чинить и заправлять в аэропортах
◇ Мэрия. Персонаж не мог покинуть машину во время
задачи "агитация власти"
			]] ):ibGetAfterY( )
		end
	},
	{   "◇ 18.03.2021",
		start_time = getTimestampFromString( "18 марта 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true,
					CreateCasesButton( 387 ),
					CreateCasesButton( 858 ),
					CreateOffersButton( 1281 ),
					CreateShowBattlePassButton( 1685 )
				end,
				[ 2 ] = function( ) return true, CreateSpecialButton( 448 ) end,
				[ 3 ] = GenerateSpecialVehicle( 6592, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 6604, 361 ),
				[ 5 ] = GenerateSpecialVehicle( 522, 339 ),
				[ 6 ] = GenerateSpecialVehicle( 562, 377 ),
				[ 7 ] = GenerateSpecialNumber( 12 ),
				[ 8 ] = GenerateSpecialNumber( 16 ),
                [ 9 ] = function( )
					return true, CreateSpecialButton( 360 ),
					CreateSpecialButton( 785 ),
					CreateVehicleShopButton( 5, 1190 )
                end,
			}

			return BuildSegmentedUpdate( "18_03_21", segmented_blocks, parent ):ibGetAfterY( )
		end
	},
	{   "◇ 11.03.2021",
		start_time = getTimestampFromString( "11 марта 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true, CreateCasesButton( 387 )
				end,
				[ 2 ] = function( ) return true, CreateSpecialButton( 451 ) end,
				[ 3 ] = GenerateSpecialVehicle( 6629, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 410, 361 ),
				[ 5 ] = GenerateSpecialVehicle( 461, 339 ),
				[ 6 ] = GenerateSpecialVehicle( 535, 377 ),
				[ 7 ] = GenerateSpecialNumber( 46 ),
				[ 8 ] = GenerateSpecialNumber( 31 ),
                [ 9 ] = function( )
					return true, CreateSpecialButton( 360 ),
					CreateSpecialButton( 785 ),
					CreateVehicleShopButton( 2, 1190 )
                end,
			}

			return BuildSegmentedUpdate( "11_03_21", segmented_blocks, parent ):ibGetAfterY( )
		end
	},
	{   "◈ 04.03.2021",
		start_time = getTimestampFromString( "3 марта 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true, CreateCasesButton( 387 ),
					CreateCasesButton( 858 ),
					CreateMoreButton( 205, 1669, parent, function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
						SwitchToTabSimulated( 2, 15, 3 )
					end )
				end,
				[ 2 ] = function( ) return true, CreateSpecialButton( 474 ) end,
				[ 3 ] = GenerateSpecialVehicle( 6630, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 6557, 361 ),
				[ 5 ] = GenerateSpecialVehicle( 506, 377 ),
				[ 6 ] = GenerateSpecialNumber( 81 ),
				[ 7 ] = GenerateSpecialNumber( 82 ),
                [ 8 ] = function( )
					return true, CreateSpecialButton( 360 ),
					CreateSpecialButton( 785 ),
					CreateVehicleShopButton( 3, 1190 )
                end,
			}

			return BuildSegmentedUpdate( "04_03_21", segmented_blocks, parent, [[
◈ Новая модель для McLaren P1
◈ Увеличена арка въезда в локацию работы "инкассатор"
◈ Поиск сокровищ. Удалено 2 точки клада
◈ ДПС МСК. Добавлены двери к входу на территорию парковки
]], [[
◇ Война кланов. Исправлена возможность выходить
за пределы локации
◇ Исправлены случаи, когда мопед мог остаться после
покупки машины
◇ Фикс возможности заспавниться под картой по причине
нестабильного интернета
◇ Кланы. Шишки больше нельзя собирать сразу с двух кустов
◇ Кланы. Анимацию сбора бутылок больше нельзя прервать
◇ ППС МСК. Исправлены неправильно открывающиеся двери
◇ Исправлены случаи, когда скин фракционника оставался
после окончания смены
◇ GPS теперь строит маршруты и к локации московского порта
◇ Cybervaz, исправлено положение вида от первого лица
◇ Исправлены случаи, когда скин невесты мог поменяться
во время церемонии
◇ ФСИН. Добавлено отображение количества
заключенных в КПЗ МСК
◇ Range Rover SVR. Исправлено открытие капота
◇ Toyota AE86. Полная переработка модели
◇ Dodge Charger. Полная переработка модели
◇ BMW M2. Полная переработка модели
◇ Небольшие исправления по моделям авто: BMW X5, Audi RS6,
Mercedes C63AMG, Lexus GS-F, Honda NSX, Jaguar I-Pace
◇ MAZDA 6 MPS. Полная переработка модели
◇ Заз 968. Исправлено открытие капота
◇ Ориентировки. Исправлены случаи когда не обновлялась карта
◇ У уведомления об окончании преследования убраны
лишние кнопки "принять\отмена"
◇ Исправлено положение всех мест спавна закладок
◇ квест "Тонкие переговоры". Исправлены случаи,
когда хаммер застревал в воротах
			]] ):ibGetAfterY( )
		end
	},
	{   "◈ 25.02.2021",
		start_time = getTimestampFromString( "25 февраля 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true, CreateCasesButton( 387 ),
					CreateMoreButton( 205, 829, parent, function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
						SwitchToTabSimulated( 2, 9, 3 )
					end )
				end,
				[ 2 ] = function( ) return true, CreateSpecialButton( 451 ) end,
				[ 3 ] = GenerateSpecialVehicle( 6608, 340 ),
				[ 4 ] = GenerateSpecialVehicle( 6609, 339 ),
				[ 5 ] = GenerateSpecialVehicle( 502, 377 ),
				[ 6 ] = GenerateSpecialNumber( 6 ),
				[ 7 ] = GenerateSpecialNumber( 17 ),
                [ 8 ] = function( )
					return true, CreateSpecialButton( 360 ),
					CreateSpecialButton( 785 ),
					CreateSpecialButton( 1237 ),
					CreateVehicleShopButton( 5, 1661 )
                end,
			}

			return BuildSegmentedUpdate( "25_02_21", segmented_blocks, parent ):ibGetAfterY( )
		end
	},
	{   "◇ 18.02.2021",
		start_time = getTimestampFromString( "18 февраля 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true, CreateCasesButton( 387 ),
					CreateCasesButton( 858 ),
					CreateShowBattlePassButton( 1262 )
				end,
				[ 2 ] = function( ) return true, CreateSpecialButton( 474 ) end,
				[ 3 ] = GenerateSpecialVehicle( 6623, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 6555, 361 ),
				[ 5 ] = GenerateSpecialVehicle( 409, 377 ),
				[ 6 ] = GenerateSpecialNumber( 10 ),
				[ 7 ] = GenerateSpecialNumber( 11 ),
                [ 8 ] = function( )
					return true, CreateSpecialButton( 360 ),
					CreateSpecialButton( 785 ),
					CreateClothesShopButton( 1189 )
                end,
			}

			return BuildSegmentedUpdate( "18_02_21", segmented_blocks, parent ):ibGetAfterY( )
		end
	},
	{   "◈ 11.02.2021",
		start_time = getTimestampFromString( "11 февраля 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true, CreateCasesButton( 387 ),
					CreateMoreButton( 205, 829, parent, function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
						ShowInfoUI( false )
						triggerEvent( "socialInteractionShowMenu", localPlayer )
					end ),
					CreateGPSButton( 1253, { x = -2087.655, y = 489.94, z = 18.401 } )
				end,
				[ 2 ] = function( )
					return true, CreateSpecialButton( 470 )
				end,
				[ 3 ] = GenerateSpecialVehicle( 6624, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 6583, 361 ),
				[ 5 ] = GenerateSpecialVehicle( 580, 377 ),
				[ 6 ] = GenerateSpecialNumber( "plate_1" ),
				[ 7 ] = GenerateSpecialNumber( "plate_2" ),
                [ 8 ] = function( )
					return true, CreateSpecialButton( 360 ),
					CreateSpecialButton( 785 ),
					CreateClothesShopButton( 1211 ),
					CreateVehicleShopButton( 3, 1616 )
                end,
			}

			return BuildSegmentedUpdate( "11_02_21", segmented_blocks, parent, [[
◈ Оптимизация игрового чата
◈ Добавлены бармены в московское казино
◈ Убран дебаф на бег при получении болезни
◈ Уменьшено время лечения болезней
◈ Уменьшено время воскрешения без медкнижки до 90 секунд
◈ Улучшена управляемость Mclaren 720s
◈ Улучшена управляемость Pagani Huayra
◈ Машина эвакуаторщика теперь игнорирует запрещенные парковки
◈ Добавлен запрет на показ документов в ивентах
◈ Во все документы, которые можно показать, добавлено
имя владельца
			]], [[
◇ Персонаж больше не может драться, находясь в наручниках
◇ Квест "Голые риски" исправлены случаи, когда машина NPC
не выезжала в катсцену
◇ Исправлено отображение винилов на низком и среднем
уровне настройки
◇ Исправлено отображение иконок на мини-карте
при включенном GPS
◇ Исправлены случаи, когда отключенный GPS снова включался
◇ Фоторежим. Персонаж больше не делает удар при нажатии ЛКМ
◇ В телефон возвращена информация о госнадбавках фракций
◇ Колесо фортуны. Исправлен отображение таймера
до следующего бесплатного жетона
◇ Блекджек. Исправлены случаи, когда персонаж
находился вне игровой комнаты
◇ Изменено расположение палаток для голосования в мэрию МСК
◇ Уроки танцев. При открытии магазина танцев
маркер больше не отображается
◇ Заболеть "Огнестрельным ранением" больше нельзя,
если урон прошел в бронежилет
			]] ):ibGetAfterY( )
		end
	},
	{   "◇ 04.02.2021",
		start_time = getTimestampFromString( "4 февраля 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true, CreateCasesButton( 387 ),
					CreateCasesButton( 858 )
				end,
				[ 2 ] = function( ) return true, CreateSpecialButton( 455 ) end,
				[ 3 ] = GenerateSpecialVehicle( 6539, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 6593, 359 ),
				[ 5 ] = GenerateSpecialVehicle( 6581, 361 ),
				[ 6 ] = GenerateSpecialNumber( "plate_89" ),
				[ 7 ] = GenerateSpecialNumber( "plate_121" ),
                [ 8 ] = function( )
					return true, CreateSpecialButton( 360 ),
					CreateSpecialButton( 785 ),
					CreateVehicleShopButton( 2, 1198 )
                end,
			}

			return BuildSegmentedUpdate( "04_02_21", segmented_blocks, parent ):ibGetAfterY( )
		end
	},
	{   "◈ 28.01.2021",
		start_time = getTimestampFromString( "28 января 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true, CreateCasesButton( 387 ),
					CreateMoreButton( 205, 813, parent, function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
						ShowInfoUI( false )
						triggerServerEvent( "InitRouletteWindow", localPlayer )
					end ),
					CreateMoreButton( 205, 1260, parent, function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
						ShowInfoUI( false )
						triggerEvent( "ShowUIQuestsList", localPlayer )
					end ),
					CreateGPSButton( 1686, { x = 2535.5012, y = 2579.9140, z = 8.0754 } ),
					CreateGPSButton( 2112, { -119.28, y = 2117.95, z = 21.6 } )
				end,
				[ 2 ] = function( )
					return true, CreateSpecialButton( 451 )
				end,
				[ 3 ] = GenerateSpecialVehicle( 6532, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 6615, 361 ),
				[ 5 ] = GenerateSpecialVehicle( 602, 377 ),
				[ 6 ] = GenerateSpecialNumber( "plate_118" ),
				[ 7 ] = GenerateSpecialNumber( "plate_119" ),
                [ 8 ] = function( )
					return true, CreateSpecialButton( 360 ),
					CreateSpecialButton( 785 ),
					CreateSpecialButton( 1212 ),
					CreateVehicleShopButton( 3, 1617 ),
					CreateVehicleShopButton( 5, 2021 )
                end,
			}

			return BuildSegmentedUpdate( "28_01_21", segmented_blocks, parent, [[
◈ Добавлен новый участок карты - Порт
◈ Обновлена мини-карта
◈ Отключены тусовки, временно
			]], [[
◇ Временные машины из сезонных наград больше не заменяют мопед
◇ Дрифт. Исправлена возможность набирать очки вне трассы
◇ Сезонные награды. Убрано отображение пустой награды
за 30 уровень
◇ Изменена логика выдачи штрафов при передаче ключей от машины
◇ Исправлено некорректное перемещение в офис, если принять
приглашение, находясь в машине
◇ Исправлены случаи, когда заключенный ФСИН перемещался
обратно в КПЗ
◇ Ежедневное задание "Начать смену на работе" теперь
выполняется и с кооперативными работами
◇ Ежедневные задания "Вылечись у врача" теперь
выполняется и при лечении у платного врача
◇ Исправлены случаи, когда фракционный тайзер мог
стрелять пулями
◇ Исправлена бесконечная загрузка при удалении
записи в трудовой книжке
◇ После прохождения квеста "Возврат имущества" броня
больше не сохраняется
◇ Исправлены проблемы с закрытием окна СТО
◇ Убрана возможность абьюза через окно авиашколы
◇ Исправлена возможность бегать при переносе ящиков
◇ Фракционные авто больше нельзя заряжать на электрозаправках
◇ Скрол часов теперь не переключает радио
			]] ):ibGetAfterY( )
		end
	},
	{   "◈ 21.01.2021",
		start_time = getTimestampFromString( "21 января 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true, CreateCasesButton( 387 ),
					CreateCasesButton( 858 )
				end,
				[ 2 ] = function( )
					return true, CreateSpecialButton( 474 )
				end,
				[ 3 ] = GenerateSpecialVehicle( 6617, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 6548, 361 ),
				[ 5 ] = GenerateSpecialVehicle( 429, 362 ),
				[ 6 ] = GenerateSpecialNumber( "plate_118" ),
				[ 7 ] = GenerateSpecialNumber( "plate_119" ),
                [ 8 ] = function( )
					return true, CreateSpecialButton( 360 ),
					CreateSpecialButton( 785 ),
					CreateVehicleShopButton( 3, 1190 )
                end,
			}

			return BuildSegmentedUpdate( "21_01_21", segmented_blocks, parent, [[
◈ Запрещена стрельба при проведении "тусовок"
◈ Небольшая оптимизация работы клиенсткой логики
			]], [[
◇ Окно казино оставалось на экране после смерти
◇ Исправлены случаи, когда невозможно закрыть окно выигрыша
◇ Мопед больше не разгоняется выше разрешенной скорости
◇ Эвакуаторщик. убрана точка спавна машины на закрытой территории
◇ Удалена возможность стрелять из гидры и хантера
◇ Совместные гонки. Исправлена ошибка синхронизации очков в худе
◇ Игрок оставался в наручниках если его сопровождающего увольняют
			]] ):ibGetAfterY( )
		end
	},
	{   "◇ 14.01.2021",
		start_time = getTimestampFromString( "14 января 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true, CreateCasesButton( 387 )
				end,
				[ 2 ] = function( ) return true, CreateSpecialButton( 455 ) end,
				[ 3 ] = GenerateSpecialVehicle( 6540, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 567, 361 ),
				[ 5 ] = GenerateSpecialVehicle( 419, 361 ),
				[ 6 ] = GenerateSpecialNumber( "plate_116" ),
				[ 7 ] = GenerateSpecialNumber( "plate_117" ),
                [ 8 ] = function( )
					return true, CreateSpecialButton( 360 ),
					CreateSpecialButton( 785 )
                end,
			}

			return BuildSegmentedUpdate( "14_01_21", segmented_blocks, parent ):ibGetAfterY( )
		end
	},
	{   "◇ 07.01.2021",
		start_time = getTimestampFromString( "7 января 2021 00:00" ),
		create_fn = function( parent )
			local segmented_blocks = {
				[ 1 ] = function( )
					return true,
					CreateCasesButton( 387 ),
					CreateCasesButton( 858 )
				end,
				[ 2 ] = function( ) return true, CreateSpecialButton( 474 ) end,
				[ 3 ] = GenerateSpecialVehicle( 6601, 362 ),
				[ 4 ] = GenerateSpecialVehicle( 6563, 361 ),
				[ 5 ] = GenerateSpecialNumber( "plate_114" ),
				[ 6 ] = GenerateSpecialNumber( "plate_115" ),
                [ 7 ] = function( )
					return true, CreateSpecialButton( 360 ),
					CreateSpecialButton( 785 )
                end,
			}

			return BuildSegmentedUpdate( "07_01_21", segmented_blocks, parent ):ibGetAfterY( )
		end
	},
}

CONST_MAX_COUNT_UPDATES = 10
UPDATES_LIST = { }

function onPlayerVerifyReadyToSpawn_handler( )
    for i, v in pairs( UPDATES ) do
    	if not v.start_time or v.start_time < getRealTimestamp( ) then
    		if #UPDATES_LIST >= CONST_MAX_COUNT_UPDATES then
    			break
    		end
        
    		table.insert(
    			UPDATES_LIST,
    			{
    				name = v[ 1 ],
    				create_fn = v.create_fn or function( parent )
    					local image = ibCreateImage( 0, 0, 0, 0, "img/items/updates/" .. v[ 2 ] .. ".png", parent ):ibSetRealSize( )
    					return image:ibData( "sy" )
    				end,
    			}
    		)
    	end
    
    	if v.start_time and v.start_time < getRealTimestamp( ) then
    		LAST_UPDATE = math.max( LAST_UPDATE, v.start_time )
    	end
    end

end
addEvent( "onPlayerVerifyReadyToSpawn", true )
addEventHandler( "onPlayerVerifyReadyToSpawn", root, onPlayerVerifyReadyToSpawn_handler )