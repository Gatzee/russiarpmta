function GetNavigationList( )
    return NAVIGATION_LIST
end

function GetLocationsList( category )
    return GPS_FROM_CATEGORY[ category ]
end

function FindClosestLocation( category, x, y, z )
    local list = GPS_FROM_CATEGORY[ category ]
    if not list then return end

    local source_position = x and y and z and Vector3( x, y, z ) or localPlayer.position
    local closest_location
    local min_distance = math.huge

    for k,v in pairs( list ) do
        local distance = ( source_position - Vector3( v ) ).length
        if distance <= min_distance then
            closest_location = v
            min_distance = distance
        end
    end

    return closest_location
end

function onClientResourceStart_handler( )
    NAVIGATION_LIST = {
        { 
            name = "Автосалоны",
            menu = {
                categories = { "carsell_economy", "carsell_normal", "carsell_luxe", "carsell_premium" },
                {
                    category = "carsell_economy",
                    image = "carsell_1",
                    name = "Автосалон эконом класса",
                    gps = { x = -1011.761, y = -1478.894 + 860, z = 21.741 },
                    buttons = { "show_on_map" },
                    desc = [[В этом автосалоне продаются отечественные
произведения “искусства”. Недорогие и неприхотливые.]],
                },
                {
                    category = "carsell_normal",
                    image = "carsell_2",
                    name = "Автосалон среднего класса",
                    gps = { x = -362.385, y = -1752.450 + 860, z = 20.928 },
                    buttons = { "show_on_map" },
                    desc = [[В основном этот автосалон продает машины азиатской
индустрии. Знаменитые японцы знают толк в машинах.]],
                },
                {
                    category = "carsell_luxe",
                    image = "carsell_3",
                    name = "Автосалон класса Люкс",
                    gps = { x = 1792.201, y = -625.773 + 860, z = 60.704 },
                    buttons = { "show_on_map" },
                    desc = [[Автосалон машин представительского класса.
Для любителей роскоши.]],
                },
                {
                    category = "carsell_premium",
                    image = "carsell_4",
                    name = "Автосалон Премиум класса",
                    gps = { x = 2044.341, y = -803.662 + 860, z = 62.621 },
                    buttons = { "show_on_map" },
                    desc = [[Быстрые машины продаются здесь.]],
                },
                {
                    category = "carsell_premium_msk",
                    image = "carsell_6",
                    name = "Московский автосалон Премиум класса",
                    gps = { x = 1242.287, y = 2466.162 + 860, z = 11.046 },
                    buttons = { "show_on_map" },
                    desc = [[Автосалон спорткаров. Самые быстрые машины
продаются здесь.]],
                },
			},
        },
        { 
            name = "Транспорт",
            menu = {
                categories = { "carsell_air", "carsell_boat", "carsell_moto" },
                {
                    category = "carsell_air",
                    image = "air_market",
                    name = "Авиасалон",
                    gps = { 
                        { x = 2386.045, y = -2325.642 + 860, z = 19.517 },
                        { x = -2563.167, y = 485.952 + 860, z = 15.306 },
                    },
                    desc = [[Не хватает воли к перемещению?!
И не хочется слушать, ничего кроме ветра?
Встречай авиатранспорт, вертолеты и самолеты
на любой вкус. А для вызова своей новой техники,
используй приложение в телефоне!
Теперь небо в твоих руках.
]],
                },
                {
                    category = "carsell_boat",
                    image = "boat_market",
                    name = "Верфь",
                    gps = { x = 1474.706, y = -2518.416 + 860, z = 2.170 },
					desc = [[Покупка лодок и яхт возможна на территории
					верфи, заказ техники производится через приложение
					в телефоне. Ваш транспорт пригонят в ближайшей порт.]],
                },
                {
                    category = "carsell_boat",
                    image = "boat_school",
                    name = "Продажа морского транспорта",
                    gps = { x = -427.314, y = 125.858 + 860, z = 2.174 },
                    desc = [[Вы можете продать свой морской транспорт государству
с комиссией в 50%.]],
                },
                {
                    category = "carsell_moto",
                    image = "carsell_5",
                    name = "Мотосалон",
                    gps = { x = -256.490, y = -1901.199 + 860, z = 20.802 },
                    desc = [[Самые быстрые и брутальные мотоциклы только тут.]],
				},
            }
        },
        { 
            name = "Фракции",
            menu = {
                categories = { "urgent_military", "faction_army", "faction_pps", "faction_dps", "faction_medics", "faction_mayor", "faction_fsin" },
                {
                    category = "urgent_military",
                    image = "urgent_military",
                    name = "Срочная служба",
                    gps = { x = -1210.895, y = -1286.844 + 860, z = 21.431 },
					subtext = "Требуется для вступления во фракции",
					desc = [[Начальная ступень для всех фракций! Здесь ты сможешь 
получить военный билет для вступления во фракции: 
Армия, ППС, ДПС, Мэрия. Твоя задача пройти весь путь 
от Рядового до Сержанта. При этом выйти в город ты 
сможешь только при помощи увольнительной. Также 
можно приобрести военный билет в магазине (F4)]],
                },
                {
                    category = "faction_army",
                    image = "armiya",
                    name = "Армия",
                    gps = { x = -2287.980, y = -17.797 + 860, z = 20.094 },
                    level = 4,
                    desc = [[Если тебе по душе армейская жизнь, то тебе сюда!
Здесь ты сможешь почувствовать себя настоящим
солдатом. Но не забывай отыгрывать свою роль,
иначе лидер фракции будет вынужден сделать тебе
выговор. Если ты получишь 3 выговора, то будешь
автоматическии уволен из фракции и твой прогресс
в ней упадет на ноль! Зарплата выдаётся каждые
полчаса, проведённые в форме]],
                },
                {
                    category = "faction_pps",
                    image = "f_pps",
                    name = "ППС",
                    gps = {
                        { x = -356.300, y = -1672.428 + 860, z = 20.757 },
                        { x = 1939.968, y = -739.131 + 860, z = 60.777 },
                        { x = 1229.39, y = 2194.05 + 860, z = 9.69 },
                    },
                    level = 4,
                    desc = [[Эти ребята всегда стоят на страже порядка на улицах
города. Если тебе не нравится хаос, происходящий
на улицах, то у тебя будет возможность ловить и
наказывать преступников! Но не забывай отыгрывать
свою роль, иначе лидер фракции будет вынужден
сделать тебе выговор. Если ты получишь 3 выговора,
то будешь автоматическии уволен из фракции и
твой прогресс в ней упадет на ноль! Зарплата
выдаётся каждые полчаса, проведённые в форме]],
                },
                {
                    category = "faction_dps",
                    image = "f_dps",
                    name = "ДПС",
                    gps = { 
                        { x = 336.734, y = -2034.876 + 860, z = 20.972 },
                        { x = 2232.579, y = -643.037 + 860, z = 60.824 },
                        { x = -1473.2, y = 2546.7 + 860, z = 10.47 },
                    },
                    level = 4,
                    desc = [[Стражи порядка на дорогах в городе.
В твои обязаности будет входить ловля и наказание
нарушителей ПДД. Но не забывай отыгрывать свою роль,
иначе лидер фракции будет вынужден сделать тебе
выговор. Если ты получишь 3 выговора, то будешь
автоматическии уволен из фракции и твой прогресс
в ней упадет на ноль! Зарплата выдаётся каждые
полчаса, проведённые в форме]],
                },
                {
                    category = "faction_medics",
                    image = "f_medics",
                    name = "Медики",
                    gps = {
                        { x = 399.250, y = -2445.291 + 860, z = 22.208 },
                        { x = 1877.856, y = -528.05 + 860, z = 60.791 },
                        { x = 1422.17, y = 2722.03 + 860, z = 9.91 },
                    },
                    level = 4,
                    desc = [[Люди которые давали клятву Гиппократа.
Здесь твоей основной задачей будет - это здоровье
твоего пациента! Ты должен приложить все усилия,
что бы больницы города не были забиты больными!
Но не забывай отыгрывать свою роль, иначе лидер
фракции будет вынужден сделать тебе выговор. Если
ты получишь 3 выговора, то будешь автоматическии
уволен из фракции и твой прогресс в ней упадет
на ноль! Зарплата выдаётся каждые полчаса,
проведённые в форме]],
                },
                {
                    category = "faction_mayor",
                    image = "f_mayor",
                    name = "Мэрия",
                    gps = {
                        { x = -1.143, y = -1696.379 + 860, z = 20.813 },
                        { x = 2269.304, y = -952.022 + 860, z = 60.666 },
                        { x = -119.28,  y = 2117.95 + 860,  z = 21.6 },
                    },
                    level = 4,
					desc = [[Фракция представителей власти, которая
регулирует экономику города и относящихся к нему
объектов. Каждый игрок может стать мэром одного
из городов, для этого ему необходимо выставить
свою кандидатуру и победить на открытых выборах.
Мэр выставляется на трехнедельный срок и может
быть переизбран не более двух раз подряд.
Выборы начинаются с выставления кандидатур
в течение двух дней, после чего в течение 36 часов
идет голосование. Проголосовать за одного из
кандидатов можно в специально отведенных для этого
местах, расположенных на территории городов. 
Также для всех горожан доступно основное
информационное приложение “ГосУслуги”, где
выводится актуальная информация о гос.надбавках,
кандидатах, текущих мэров и их рейтинг.
 
                                      Рейтинг
У мэра есть рейтинг, который отображается у него над
мини-картой и присутствует в приложении “ГосУслуги”.
Этот рейтинг отображает любовь народа к мэру, который
пассивно уменьшается со 100% до 0% за 36 часов.
Если он падает до 0%, то мэр автоматически теряет свою
должность. За каждый факт попадания мэра в тюрьму,
рейтинг власти падает на 25%. Для увеличения рейтинга,
мэру необходимо выполнять учение “Объезд владений”.
Процент увеличения рейтинга за успешное
выполнение учения зависит от финансирования
“Агитации власти” и может быть равен от 25% до 50%.
 
                                Свержение мэра
Если во время выполнения учения “Объезд владений”
мэр будет убит сотрудником любой фракции (от 3-го
ранга) или бандитом, то его рейтинг уменьшится на 50%.]],
                },
                {
                    category = "faction_fsin",
                    image = "f_fsin",
                    name = "ФСИН",
                    gps = { x = -2798.2067, y = 1610.7482 + 860, z = 14.1251 },
                    level = 4,
                    desc = [[Люди которые исполняют наказание заключенных
за их правонарушение. Твоя основная задача здесь
следить за заключенными и не поворачиваться к ним
спиной. Каждый из них может сбежать из под охраны,
так что будь бдителен и всегда наготове.
И главное не забывай отыгрывать свою роль.]],
                },
            }
        },
        { 
            name = "Работы" ,
            menu = {
                sort_fn = function( categories_list, categories_jobs )
                    -- Сортировка работ по соответствию уровню игрока
                    local current_level = localPlayer:GetLevel( )
                    local categories_priorities = { }
                    for category, jobs in pairs( categories_jobs ) do
                        local best_job
                        for i, job in pairs( jobs ) do
                            job._level = job.level
                            if job.companies then
                                for i, level in ipairs( job.companies ) do
                                    if current_level >= level then
                                        job._level = level
                                    else
                                        break
                                    end
                                end
                            end
                            job.priority = current_level >= job._level and job._level or -job._level
                            if current_level >= job._level and ( not best_job or best_job._level < job._level ) then
                                best_job = job
                            end
                        end
                        categories_priorities[ category ] = best_job and best_job._level or -jobs[ 1 ]._level
                        table.sort( jobs, function( a, b )
                            return a.priority > b.priority or a.priority == b.priority and a.category > b.category
                        end )
                    end
                    
                    local all_jobs = categories_jobs[ "all" ]
                    local max_best_job_level = all_jobs[ 1 ]._level
                    if current_level >= max_best_job_level then
                        -- Меняем рекомендованную работу только при смене уровня
                        if not RANDOM_BEST_JOB or RANDOM_BEST_JOB._level ~= max_best_job_level then
                            local possible_best_jobs = { }
                            for i , job in pairs( all_jobs ) do
                                if job._level == max_best_job_level then
                                    job.table_i = i
                                    table.insert( possible_best_jobs, job )
                                    -- Показываем кооп работы в 2 раза чаще
                                    if job.is_coop then
                                        table.insert( possible_best_jobs, job )
                                    end
                                end
                            end
                            math.randomseed( os.time( ) ) -- походу по дефолту при реконнекте устанавливается один и тот же сид
                            RANDOM_BEST_JOB = possible_best_jobs[ math.random( #possible_best_jobs ) ]
                            RANDOM_BEST_JOB.is_best = true
                        end
                    end

                    categories_priorities[ "all" ] = math.huge
                    if RANDOM_BEST_JOB then
                        table.remove( all_jobs, RANDOM_BEST_JOB.table_i )
                        table.insert( all_jobs, 1, RANDOM_BEST_JOB )
                        categories_priorities[ RANDOM_BEST_JOB.category ] = categories_priorities[ RANDOM_BEST_JOB.category ] + 100
                    end
                    table.sort( categories_list, function( a, b )
                        return categories_priorities[ a ] > categories_priorities[ b ]
                            or categories_priorities[ a ] == categories_priorities[ b ] and a > b -- чтобы список категорий и список всех работ сортировались одинаково
                    end )
                end,

                get_name_fn = function( job )
                    local name = job.name
                    if job.companies then
                        local company = job.companies[ 1 ] == job.level and 1
                        for i, level in ipairs( job.companies ) do
                            if localPlayer:GetLevel( ) >= level then
                                company = i
                            else
                                break
                            end
                        end
                        if company then
                            name = name .. ": Компания " .. company
                        end
                    end
                    if job.is_best then
                        name = "Рекомендованная работа\n" .. name
                    end
                    return name
                end,

                get_subtext_fn = function( job )
                    local need_level = job.level
                    if job.companies then
                        for i, level in ipairs( job.companies ) do
                            if localPlayer:GetLevel( ) >= level then
                                need_level = level
                            else
                                break
                            end
                        end
                    end
                    return "Доступно с " .. need_level .. " уровня"
                end,

                categories = { "job_trashman", "job_taxi", "job_farmer", "job_courier", "job_loader", "job_trucker", "job_driver", "job_pilot", "job_mechanic", "job_parkemp", "job_woodcut", "job_hcs", "job_towtrucker", "job_inkas", "job_delivery_cars", "job_industrial_fish", "job_hajack_cars", },
                {
                    category = "job_trashman",
                    image = "trashman",
                    name = "Мусорщик",
                    gps = { x = 2268.71, y = 521.05 + 860, z = 16.79 },
                    level = 4,
                    companies = { 4, 6, 8 },
                    is_coop = true,
                    desc = [[На данной кооперативной работе необходимо делать 
мир чище, а именно заниматься сбором мусора 
и перевозкой его на свалку.
На время смены в данной работе выдаются временные 
права категории С.]],
                },
                {
                    category = "job_delivery_cars",
                    image = "delivery_cars",
                    name = "Доставка транспорта",
                    gps = { x = 312.27, y = 985.74 + 860, z = 20.78 },
                    level = 16,
                    companies = { 16, 20, 24 },
                    is_coop = true,
                    desc = [[На данной работе необходимо доставлять лучшие машины
клиентам, которые не любят долго ждать.
А значит, нужно будет ехать быстро и аккуратно.    
На данной работе можно работать только вдвоём, 
где один из специалистов является координатором, 
а второй - водителем.
По окончанию доставки машины, координатор должен 
забрать своего напарника на вертолете. 
Из-за чего требуются права пилота вертолета.]],
                },
                {
                    category = "job_industrial_fish",
                    image = "industrial_fishing",
                    name = "Промышленная рыбалка",
                    gps = { x = -2065.4414, y = 2843.9982 + 860, z = 3.3932 },
                    level = 19,
                    companies = { 19, 22, 25 },
                    is_coop = true,
                    desc = [[На данной работе необходимо вылавливать рыбу в 
промышленных масштабах и доставлять ее в порт. 
Для работы требуется 4 человека, где каждый 
игрок будет выполнять свои действия: 
Штурман — управляет кораблем, а также занимается 
его обслуживанием. Штурману требуется морские права; 
Координатор — координирует остальных специалистов, 
а именно указывает маршрут и скопления рыб, 
используя эхолокацию; 
Рыболовы —  забрасывают сети и разгружают трюм, 
используя манипуляторы корабля.]],
                },
                {
                    category = "job_hajack_cars",
                    image = "hijack_cars",
                    name = "Угон авто",
                    gps = { x = -1069.94, y = 768.25 + 860, z = 19.39 },
                    level = 12,
                    companies = { 12, 17, 23 },
                    is_coop = true,
                    desc = [[На данной работе необходимо угонять машины.
Тачки сразу будут уходить в продажу, поэтому привозить
их нужно в целости.
Работать можно только вдвоём, где один из специалистов 
является Водителем, а второй - Мастером. 
Оба специалиста должны иметь отрицательный 
социальный рейтинг]],
                },
                {
                    category = "job_taxi",
                    image = "taxi_2",
                    name = "Таксист Частник",
                    gps = { 
                        { x = 466.777, y = -2211.947 + 860, z = 20.590 },
                        { x = 1774.570, y =  -517.005 + 860, z = 60.593 },
                    },
                    level = 6,
                    desc = [[Развитие такси не стоит на месте, теперь доступен
новый отдел - таксист частник. Ожидай заказа от других
игроков и доставь их куда им нужно. ]],
                },
                {
                    category = "job_taxi",
                    image = "taxi_1",
                    name = "Таксист",
                    gps = {
                        { x = 467.674, y = -2223.847 + 860, z =  20.7481 },
                        { x = 1785.641, y = -518.468 + 860, z = 60.719 },
                    },
                    level = 12,
                    companies = { 12, 14, 17 },
                    desc = [[В городе кроме тебя есть еще много граждан и всем
им так же нужно ездить по своим делам. Компания
"Таксопарк" предоставляет тебе транспорт в аренду.
Все, что нужно сделать — просто устроиться к ним
на работу.]],
                },
                {
                    category = "job_farmer",
                    image = "farmer_1",
                    name = "Фермер",
                    gps = { 
                        { x = -1292.417, y = -260.013 + 860, z = 28.732 },
                        { x = -1123.400, y = -427.4 + 860, z = 21.300 },
                    },
                    level = 3,
                    companies = { 6, 9, 11 },
                    desc = [[Работа фермера представляет собой выращивание
злаковых и кукурузы, их сбор и продажу. Теперь можно
не только наслаждаться просторами полей и птичьем
пением, но и зарабатывать!]],
                },
                {
                    category = "job_courier",
                    image = "courier_1",
                    name = "Курьер: Подработка",
                    gps = { 
                        { x = -862.5679, y = -1734.5719 + 860, z =  20.993 },
                        { x = 2056.598, y = -636.342 + 860, z = 60.641 },
                    },
                    level = 2,
                    desc = [[Отдел кадров для всех профессий Курьера. Устройство
на работу курьером производится на Почте. Потом с
Почты тебя направят на работу в соответствии с твоим
уровнем. Работа Курьером заключается в доставке
посылок по городу. Зарплату тебе платят на месте,
после того, как ты доставил посылку.]],
                },
                {
                    category = "job_courier",
                    image = "courier_2",
                    name = "Курьер",
                    gps = { x = 311.043, y = -2788.131 + 860, z = 21.029 },
                    level = 4,
                    companies = { 4, 7, 10 },
                    desc = [[Почта России перешла на уровень выше и теперь
развозит свои посылки на Газелях. Работникам
выделяются Газели для развоза посылок, поэтому
поспеши, пока все не расхватали. Прокачивай свои
навыки курьера и сможешь доставлять посылки на
топовой газели.]],
                },
                {
                    category = "job_trucker",
                    image = "trucker_1",
                    name = "Дальнобойщик",
                    gps = { 
                        { x = 2416.068, y = -1775.272 + 860, z = 73.919 },
                        { x = -2951.630, y = -782.335 + 860, z = 18.526 },
                    },
                    level = 10,
                    companies = { 10, 16, 24 },
                    desc = [[Крупному складу требуются опытные
водители грузовиков, наличие прав категории С
обязательно!]],
                },
                {
                    category = "job_loader",
                    image = "loader_1",
                    name = "Грузчик: Подработка",
                    gps = { 
                        { x = -1495.205, y = -1492.810 + 860, z =  21.850 },
                        { x = 2491.983, y = -1713.512 + 860, z = 74.053 },
                    },
                    level = 2,
                    desc = [[Отдел кадров для всех профессий Грузчика. Устройство
на работу грузчиком всегда производится на Заводе.
Далее с Завода тебя направят на работу в соответствии
с твоим уровнем. Работа Грузчиком заключается в
разгрузке Газелей на заводе. Зарплату тебе платят
за каждую перенесенную коробку.]],
                },
                {
                    category = "job_loader",
                    image = "loader_2",
                    name = "Грузчик",
                    gps = { x = -803.673, y = -1157.338 + 860, z = 15.790 },
                    level = 5,
                    companies = { 5, 8, 10 },
                    desc = [[В порт нужны грузчики для сортировки товара и
развозки коробок на Погрузчике. С каждым новым
уровнем тебе будут доверять более ценные товары.]],
                },
                {
                    category = "job_driver",
                    image = "driver_1",
                    name = "Водитель автобуса",
                    gps = {
                        { x = -1258.238, y = -1816.753 + 860, z = 20.871 },
                    },
					level = 13,
                    companies = { 13, 15, 16 },
					desc = [[Работая водителем автобуса, тебе необходимо ездить по
указанным маршрутам, останавливаться на остановках.
По окончанию маршрута ты будешь получать зарплату.]],
                },
                {
                    category = "job_pilot",
                    image = "air_school",
                    name = "Лётчик",
                    gps = { x = -2525.043, y = 258.465 + 860, z = 16.370 },
                    level = 18,
                    companies = { 18, 20, 22 },
                    desc = [[Работа лётчика представляет собой перевозку 
грузов по воздуху. Зарабатывай и  наслаждайся 
ощущением свободы и простора от необъятного неба.

Для идеального сброса груза необходимо вовремя нажать 
кнопку сбора груза. Каждый идеальный сброс
увеличивает доход.]],
                },
                {
                    category = "job_mechanic",
                    image = "mechanic",
                    name = "Автомеханик",
                    gps = { x = 1497.2316, y = 867.5745 + 860, z = 16.1673 },
                    level = 6,
                    companies = { 6, 8, 11 },
                    desc = [[Когда звук гонок греет душу и моторной масло течет 
вместо крови, то работа автомеханика идеальное место, 
где надо обслуживать “болиды” для гонок.]],
                },
                {
                    category = "job_parkemp",
                    image = "park_employee",
                    name = "Сотрудник парка",
                    gps = { x = 2093.4291, y = 922.6384 + 860, z = 16.3870 },
                    level = 4,
                    companies = { 4, 7, 9 },
                    desc = [[Наслаждаться просторами и уникальными постройками,
можно не просто так, а за деньги. Обслуживай парк, 
поддерживай его в идеальном состоянии 
и получай зарплату.]],
                },
                {
                    category = "job_woodcut",
                    image = "woodcutter",
                    name = "Дровосек",
                    gps = { x = 1947.2537, y = 290.9189 + 860, z = 16.6167 },
                    level = 19,
                    companies = { 19, 21, 23 },
                    desc = [[Усталость от шумных улиц городов начала доходить
до предела, теперь можно отдохнуть не только на свежем
воздухе, но в лесу и при этом получать зарплату. Руби
деревья, занимайся их обработкой и зарабатывай!]],
                },
                {
                    category = "job_inkas",
                    image = "incasator",
                    name = "Инкассатор",
                    gps = { x = -728.519, y = 2152.910 + 860, z = 20.1 },
                    level = 18,
                    companies = { 18, 21, 25 },
                    is_coop = true,
                    desc = [[На данной работе необходимо заниматься сбором и
перевозкой денежных средств с предельной 
осторожностью, так как есть шанс нападения. 
На такой случай у водителя есть тревожная кнопка, 
которая вызывает сотрудников ППС, а у охраны 
имеется оружие.

Для ограбления инкассации необходимо убить охраника, 
когда он переносит мешок с деньгами.

Начать работу можно только с положительным 
социальным рейтингом.]],
                },
                {
                    category = "job_hcs",
                    image = "hcs",
                    name = "Сотрудник ЖКХ",
                    gps = {
                        { x = 353.148, y = -1627.886 + 860, z = 20.788 },
                        { x = 2269.980, y = -1134.943 + 860, z = 60.761 },
                    },
                    level = 12,
                    companies = { 12, 14, 17 },
					desc = [[Поддерживай дома города в идеальном состоянии,
							за достойную оплату]],
                },
                {
                    category = "job_towtrucker",
                    image = "towtrucker",
                    name = "Эвакуаторщик",
                    gps = { x = -1012.78, y = -758.33 + 860, z = 23 },
                    level = 13,
                    companies = { 13, 15, 17 },
                    is_coop = true,
                    desc = [[На данной работе необходимо заниматься
эвакуированием автомобилей и доставкой
их на парковку. 
А также взаимодействовать с сотрудниками ДПС.
И главное, при работе с напарником,
ваша зарплата будет выше на 25%,
а процесс работы более комфортным.]],
                },
            }
        },
        { 
            name = "Бизнесы",
            menu = {
                categories = { 
                    "businesses_general", 
                    "businesses_sell",
                    "businesses_center", 
                    "business_flowers", 
                    "business_hotel", 
                    "business_hypermarket",
                    "business_ipshop", 
                    "business_smallshop", 
                    "business_shop",
                    "business_repairstore",
                    "business_drugstore",
                    "business_gasstation",
                    "business_carsell",
                    "business_tradecentre",
                    "business_circus",
                    "business_school",
                    "business_catering",
                    "business_tuning",
                    "business_cinema",
                    "business_bank",
                    "business_apart_hotel_gorki",
                    "business_apart_hotel_msk", 
                    "business_apart_hotel_nsk",  
                    "business_bus_depot",  
                    "business_construction",
                    "business_grk_airport",
                    "business_hotel_gorki",
                    "business_hotel_ukraine",
                    "business_moskovsky_port",
                    "business_nsk_airport",
                    "business_oter_marriott",
                    "business_plant",
                    "business_private_dump",
                    "business_private_parking",
                    "business_private_warehouse",
                    "business_strip_club",
                    "business_transport_service",
                    "business_tuning_common",
                    "business_railway_station",
                    "business_shipyard",
                    "business_workshop",
                    "business_clothing_store",
                    "business_moscow_central_bank",
                    "business_gun_shop",
                    "business_tretyakov_gallery",
                    "business_sawmill",
                },

                {
                    category = "businesses_general",
                    image = "business_1",
                    name = "Бизнесы",
                    buttons = { "businesses_find_own" },
                    desc = [[Когда устал работать на государство и хочется заняться
своим делом,  то самым лучшим решением станет
покупка бизнеса. Закупай продукцию, зарабатывай
деньги, поднимай свой капитал!
Максимальное кол-во бизнесов 2.]],
                },
                {
                    category = "businesses_sell",
                    image = "business_2",
                    name = "Биржа",
                    gps = exports.nrp_businesses:GetLocations( ),
                    desc = [[Когда решил продать свой бизнес или купить уже
действующий, то поможет биржа. За свои услуги берет 5%.]],
                },
                {
                    category = "businesses_center",
                    image = "businesses_center",
                    name = "Бизнес - Центр",
                    gps = {
                        { x = 397.312, y = -1434.875 + 860, z = 22.477 },
                        { x = 2059.91, y = 2452.3 + 860, z = 8.07 },
                        { x = 2195.05, y = 2637.26 + 860, z = 8.07 },
                        { x = 2134.72, y = 2602.62 + 860, z = 8.31 },
                    },
                    desc = [[Здесь можно приобрести офис, уникальный скин и нанять
секретаршу, которая упростит работу со всеми бизнесами. 
Все покупки доступны в уникальном магазине 
приложения Forbs.]],
                },
                {
                    category = "business_flowers",
                    image = "business_flowers",
                    name = "Магазины цветов",
                    gps = GetBusinessesByClass( "flowers" ),
                    desc = [[Занимаются продажей цветов]],
                },
                {
                    category = "business_hotel",
                    image = "business_hotel_nsk",
                    name = "Гостиницы",
                    gps = GetBusinessesByClass( "hotel", "castle" ),
                    desc = [[Занимаются арендой номеров]],
                },
                {
                    category = "business_hypermarket",
                    image = "business_hypermarket",
                    name = "Гипермаркеты",
                    gps = GetBusinessesByClass( "hypermarket" ),
                    desc = [[Занимаются сдачей площадей в аренду]],
                },
                {
                    category = "business_ipshop",
                    image = "business_ipshop",
                    name = "Магазины ИП",
                    gps = GetBusinessesByClass( "market" ),
                    desc = [[Занимаются продажей товаров]],
                },
                {
                    category = "business_smallshop",
                    image = "business_smallshop",
                    name = "Ларьки",
                    gps = GetBusinessesByClass( "smallshop" ),
                    desc = [[Занимаются продажей журналов]],
                },
                {
                    category = "business_shop",
                    image = "business_shop",
                    name = "Магазины продуктов",
                    gps = GetBusinessesByClass( "shop" ),
                    desc = [[Занимаются продажей продуктов питания]],
                },
                {
                    category = "business_repairstore",
                    image = "business_repairstore",
                    name = "СТО",
                    gps = GetBusinessesByClass( "repairstore" ),
                    desc = [[Занимаются ремонтом транспорта]],
                },
                {
                    category = "business_drugstore",
                    image = "business_drugstore",
                    name = "Аптеки",
                    gps = GetBusinessesByClass( "drugstore" ),
                    desc = [[Занимаются продажей лекарств]],
                },
                {
                    category = "business_gasstation",
                    image = "business_gasstation",
                    name = "Заправки",
                    gps = GetBusinessesByClass( "gasstation" ),
                    desc = [[Занимаются продажей топлива]],
                },
                {
                    category = "business_carsell",
                    image = "business_carsell",
                    name = "Автосалоны",
                    gps = GetBusinessesByClass( "carsell" ),
                    desc = [[Занимаются продажей и обслуживанием автомобилей]],
                },
                {
                    category = "business_tradecentre",
                    image = "business_tradecentre",
                    name = "Торговые Центры",
                    gps = GetBusinessesByClass( "tradecentre" ),
                    desc = [[Занимаются сдачей площадей в аренду]],
                },
                {
                    category = "business_circus",
                    image = "business_circus",
                    name = "Цирк Шапито",
                    gps = GetBusinessesByClass( "circus" ),
                    desc = [[Занимается показом представлений]]
                },

                {
                    category = "business_catering",
                    image = "business_catering",
                    name = "Общественное питание",
                    gps = GetBusinessesByClass( "catering" ),
                    desc = [[Занимается продажей блюд]]
                },

                {
                    category = "business_school",
                    image = "business_school",
                    name = "Обучение",
                    gps = GetBusinessesByClass( "school" ),
                    desc = [[Занимается обучением]]
                },

                {
                    category = "business_tuning",
                    image = "business_tuning",
                    name = "Тюнинг",
                    gps = GetBusinessesByClass( "tuning", _, true ),
                    desc = [[Занимается доработкой транспортных средств]]
                },

                {
                    category = "business_cinema",
                    image = "business_cinema",
                    name = "Кинотеатр",
                    gps = GetBusinessesByClass( "cinema" ),
                    desc = [[Занимается показом фильмов]]
                },

                {
                    category = "business_bank",
                    image = "business_bank",
                    name = "Банк",
                    gps = GetBusinessesByClass( "bank" ),
                    desc = [[Занимается валютными операциями]]
                },

                -- Новые (25.03)
                {
                    category = "business_tuning_common",
                    image = "business_tuning_common",
                    name = "Тюнинг стандартный",
                    gps = GetBusinessesByClass( "tuning_common", _, true ),
                    desc = [[Занимается доработкой транспортных средств]]
                },

                {
                    category = "business_construction",
                    image = "business_construction",
                    name = "Стройка",
                    gps = GetBusinessesByClass( "construction" ),
                    desc = [[Занимается строительством жилых домов]]
                },

                {
                    category = "business_plant",
                    image = "business_plant",
                    name = "Завод",
                    gps = GetBusinessesByClass( "plant" ),
                    desc = [[Занимается производством сырья]]
                },

                {
                    category = "business_bus_depot",
                    image = "business_bus_depot",
                    name = "Автобусный парк",
                    gps = GetBusinessesByClass( "bus_depot", _, true ),
                    desc = [[Занимается обслуживанием и хранением общественного транспорта]]
                },

                {
                    category = "business_hotel_gorki",
                    image = "business_hotel_gorki",
                    name = "Отель Горки",
                    gps = GetBusinessesByClass( "hotel_gorki", _, true ),
                    desc = [[Занимается сдачей номеров]]
                },

                {
                    category = "business_oter_marriott",
                    image = "business_oter_marriott",
                    name = "Отель Марриотт",
                    gps = GetBusinessesByClass( "oter_marriott", _, true ),
                    desc = [[Занимается сдачей номеров]]
                },

                {
                    category = "business_apart_hotel_gorki",
                    image = "business_apart_hotel_gorki",
                    name = "Апарт Отель Горки",
                    gps = GetBusinessesByClass( "apart_hotel_gorki", _, true ),
                    desc = [[Занимается сдачей номеров]]
                },

                {
                    category = "business_apart_hotel_nsk",
                    image = "business_apart_hotel_nsk",
                    name = "Апарт Отель НСК",
                    gps = GetBusinessesByClass( "apart_hotel_nsk", _, true ),
                    desc = [[Занимается сдачей номеров]]
                },

                {
                    category = "business_apart_hotel_msk",
                    image = "business_apart_hotel_msk",
                    name = "Аппарт Отель МСК",
                    gps = GetBusinessesByClass( "apart_hotel_msk", _, true ),
                    desc = [[Занимается сдачей номеров]]
                },

                {
                    category = "business_private_dump",
                    image = "business_private_dump",
                    name = "Частная свалка",
                    gps = GetBusinessesByClass( "private_dump", _, true ),
                    desc = [[Занимается сбором и хранением отходов]]
                },

                {
                    category = "business_strip_club",
                    image = "business_strip_club",
                    name = "Стрип клуб",
                    gps = GetBusinessesByClass( "strip_club", _, true ),
                    desc = [[Занимается взрослым развлечением]]
                },

                {
                    category = "business_transport_service",
                    image = "business_transport_service",
                    name = "Транспортный сервис",
                    gps = GetBusinessesByClass( "transport_service", _, true ),
                    desc = [[Занимается транспортным обслуживанием]]
                },

                {
                    category = "business_private_warehouse",
                    image = "business_private_warehouse",
                    name = "Частный склад",
                    gps = GetBusinessesByClass( "private_warehouse", _, true ),
                    desc = [[Занимается хранением товаров]]
                },

                {
                    category = "business_hotel_ukraine",
                    image = "business_hotel_ukraine",
                    name = "Гостиница Украина",
                    gps = GetBusinessesByClass( "hotel_ukraine", _, true ),
                    desc = [[Занимается сдачей номеров]]
                },

                {
                    category = "business_nsk_airport",
                    image = "business_nsk_airport",
                    name = "Аэропорт НСК",
                    gps = GetBusinessesByClass( "nsk_airport", _, true ),
                    desc = [[Занимается воздушной перевозкой]]
                },

                {
                    category = "business_grk_airport",
                    image = "business_grk_airport",
                    name = "Аэропорт ГРК",
                    gps = GetBusinessesByClass( "grk_airport", _, true ),
                    desc = [[Занимается воздушной перевозкой]]
                },

                {
                    category = "business_moskovsky_port",
                    image = "business_moskovsky_port",
                    name = "Московский Порт",
                    gps = GetBusinessesByClass( "moskovsky_port", _, true ),
                    desc = [[Занимается погрузкой кораблей]]
                },

                {
                    category = "business_private_parking",
                    image = "business_private_parking",
                    name = "Частная парковка",
                    gps = GetBusinessesByClass( "private_parking", _, true ),
                    desc = [[Занимается сдачей парковочных мест]]
                },

                -- Новые (29.04.21)
                {
                    category = "business_railway_station",
                    image = "business_railway_station",
                    name = "Вокзал",
                    gps = GetBusinessesByClass( "railway_station", _, true ),
                    desc = [[Занимается транспортировкой грузов]]
                },

                {
                    category = "business_shipyard",
                    image = "business_shipyard",
                    name = "Верфь",
                    gps = GetBusinessesByClass( "shipyard", _, true ),
                    desc = [[Занимается обслуживанием морской техники]]
                },

                {
                    category = "business_workshop",
                    image = "business_workshop",
                    name = "Мастерская",
                    gps = GetBusinessesByClass( "workshop", _, true ),
                    desc = [[Занимается обслуживанием морской техники]]
                },

                {
                    category = "business_clothing_store",
                    image = "business_clothing_store",
                    name = "Магазин одежды",
                    gps = GetBusinessesByClass( "clothing_store", _, true ),
                    desc = [[Занимается продажей одежды]]
                },

                {
                    category = "business_moscow_central_bank",
                    image = "business_moscow_central_bank",
                    name = "Московский центральный банк",
                    gps = GetBusinessesByClass( "moscow_central_bank", _, true ),
                    desc = [[Занимается регулированием и финансированием банков]]
                },

                {
                    category = "business_gun_shop",
                    image = "business_gun_shop",
                    name = "Оружейный магазин",
                    gps = GetBusinessesByClass( "gun_shop", _, true ),
                    desc = [[Занимается продажей оружия]]
                },

                {
                    category = "business_tretyakov_gallery",
                    image = "business_tretyakov_gallery",
                    name = "Третьяковская галерея",
                    gps = GetBusinessesByClass( "tretyakov_gallery", _, true ),
                    desc = [[Занимается продажей искусства]]
                },

                {
                    category = "business_sawmill",
                    image = "business_sawmill",
                    name = "Лесопилка",
                    gps = GetBusinessesByClass( "sawmill", _, true ),
                    desc = [[Занимается обработкой древесины]]
                },
            }
        },
        { 
            name = "Кланы",
            menu = {
                categories = { "clan_base", "hash_laboratory", "cartel_1", "cartel_2" },
                {
                    category = "clan_base",
                    image = "clan_base",
                    name = "Кланы",
                    gps = {
                        { x = 1989.057, y = -914.865 + 860, z = 57.23 },
                        { x = -205.543, y = -1828.477 + 860, z = 17.591 },
                        { x = -47.152, y = 552.215 + 860, z = 17.467 },
                    },
                    level = 6,
                    desc = [[
Вы можете создать свою преступную группировку и 
заниматься нелегальной деятельностью вместе со 
своими соратниками. Показать всем, кто главный 
в городе, и побороться за право стать Картелем.]],
                },
                {
                    category = "hash_laboratory",
                    image = "hash_laboratory",
                    name = "Лаборатория",
                    gps = {
                        { x = -2743.32, y = -1829.24 + 860, z = 22.27 },
                        { x = 1991.53, y = 1111.21 + 860, z = 16.39 },
                    },
                    level = 6,
                    desc = [[
Необходимое здание для сбора ресурсов 
производств кланов и картелей.]],
                },
                {
                    category = "cartel_1",
                    image = "cartel_1",
                    name = "Западный Картель",
                    gps = { x = -1983.305, y = 656.233 + 860, z = 18.485 },
                    level = 6,
                    desc = [[
Вы можете побороться с другими кланами за право 
стать Картелем, самой влиятельной группировкой 
в городе. Вы сможете оказывать давление на другие 
кланы и запрашивать с них налог. 
Картели имеют все привилегии в городе и могут 
влиять на то, как будут развиваться другие кланы.]],
                },
                {
                    category = "cartel_2",
                    image = "cartel_2",
                    name = "Восточный Картель",
                    gps = { x = 1939.502, y = -2224.937 + 860, z = 32.41 },
                    level = 6,
                    desc = [[
Вы можете побороться с другими кланами за право 
стать Картелем, самой влиятельной группировкой 
в городе. Вы сможете оказывать давление на другие 
кланы и запрашивать с них налог. 
Картели имеют все привилегии в городе и могут 
влиять на то, как будут развиваться другие кланы.]],
                },
            }
        },
        { 
            name = "Автошкола",
            menu = {
                categories = { "ground_vehicles", "air_vehicles", "boat_vehicles" },
                {
                    id = "driving_school",
                    category = "ground_vehicles",
                    image = "drivingschool_1",
                    name = "Автошкола",
                    gps = {
                        { x = 410.614, y = -2081.233 + 860, z = 21.853 },
                        { x = 2145.19, y = -877.77 + 860, z = 62.62 },
                        { x = -690.48, y = 2604.09 + 860, z = 17.91 },
                    },
                    desc = [[Место, где ты начинаешь свой путь водителя.
Права — это неотъемлимая часть в жизни
любого игрока. Пройди обучение в автошколе,
сдай практический экзамен и вперед.
Не забывай соблюдать правила.]],
                },
                {
                    id = "flying_school",
                    category = "air_vehicles",
                    image = "air_school",
                    name = "Авиашкола",
                    gps = {
                        { x = 2298.066, y = -2346.41 + 860, z = 21.763 },
                        { x = -2514.907, y = 380.412 + 860, z = 16.023 },
                    },
                    desc = [[У каждого человека своя страсть.
У каждого - своя склонность. Но только немногие готовы
устремится вверх и покорить своей воле необъятное небо.
Теперь каждый может стать - пилотом!]],
                },
                {
                    category = "boat_vehicles",
                    image = "boat_school",
                    name = "Морская школа",
                    gps = { x = 1464.884, y = -2521.656 + 860, z = 2.17 },
					desc = [[Здесь можно научиться не только управлять морскими
					судами, но и получить разрешение на управление ими]],
                },
            }
        },
        { 
            name = "Магазин Одежды",
            menu = {
                {
                    id = "boutique",
                    image = "boutique_1",
                    name = "Магазин одежды",
                    gps = CLOTHES_SHOPS_LIST,
					desc = [[В этом магазине огромный выбор скинов и аксессуаров. 
Который можно примерить, а после приобрести. 
Настройка аксессуаров осуществляется в ручном варианте. 

При покупке или получении все скины и аксессуары 
складываются в инвентарь магазина, а также в гардероб 
твоего дома.]],
                }
            }
        },
        { 
            name = "Заправки",
            menu = {
                {
                    id = "gasstation",
                    image = "gasstation_1",
                    name = "Заправки",
                    gps = GetGPSCoords_Table( 1, "gas" ),
                    area = 50,
                    max_distance = 2000,
                    desc = [[Топливо для твоего транспорта. Никогда не давай
датчику бензина опускаться до нуля, иначе придется
бежать на заправку за канистрой, а потом заново
бежать к машине.]],
                },
                {
                    id = "gasstation",
                    image = "gasstation_2",
                    name = "Электро-заправки",
                    gps = GetGPSCoords_Table( 1, "electro" ),
                    area = 50,
                    max_distance = 2000,
                    desc = [[Зарядка для твоего электро — кара. Всегда следи 
за датчиком энергии, если он опуститься до нуля, 
то спасут только аккумуляторы.]],
                },
            },
        },
        { 
            name = "Автосервис",
            menu = {
                categories = { "ground_vehicles", "air_vehicles", "boat_vehicles" },
                {
                    id = "repairstore",
                    category = "ground_vehicles",
                    image = "repairstore_1",
                    name = "Автосервис",
                    gps = GetGPSCoords_Table( 2 ),
                    desc = [[Если вдруг ты повредил свою машину, она
может потерять привлекательный внешний
вид или былую мощь! В автосервисе ты можешь
отремонтировать свою машину. В автосервисе
даже есть возможность сбросить пробег
машины до нуля, если вдруг она стала часто
ломаться.]],
                },
                {
                    category = "air_vehicles",
                    image = "air_workshop",
                    name = "Обслуживание авиации",
                    gps = exports.nrp_airplane_repair:GetLocations( ),
                    desc = [[Ремонт и заправка воздушного транспорта]],
                },
                {
                    category = "boat_vehicles",
                    image = "boat_workshop",
                    name = "Обслуживание судов",
                    gps = exports.nrp_boat_repair:GetLocations( ),
                    desc = [[Ремонт и заправка водного транспорта]],
                },
            },
        },
        { 
            name = "Фастфуд",
            menu = {
                {
                    id = "food",
                    image = "food_1",
                    name = "Фастфуд",
                    gps = exports.nrp_player_hunger:GetLocations( ),
                    desc = [[Еда — это энергия для твоего персонажа. Если твоя
полоска "Сытости" упадет до нуля — твой персонаж
начнет терять здоровье и вскоре умрет от голода.]],
                },
            },
        },
        { 
            name = "Недвижимость",
            menu = {
                {
                    buttons = { "apartments_find_nearest", "apartments_find_own" },
                    image = "apartments_1",
                    name = "Недвижимость",
                    gps = "apartments",
                    desc = [[У каждой недвижимости есть гараж для машин,
гардероб для хранения одежды и аксессуаров,
а также кровать для отдыха.
 
Количество мест для машин в гараже зависит от типа 
недвижимости и его класса:
деревенский дом - 2 места,
квартира 1 класса - 1 места,
квартира 2 класса - 2 места,
квартира 3 класса - 3 места,
квартира 4 класса - 8 мест,
коттедж 1 класса - 3 места,
коттедж 2 класса - 4 места,
коттедж 3 класса - 5 мест,
коттедж 4 класса - 6 мест,
коттедж 5 класса - 7 мест,
коттедж 6 класса - 8 мест,
вилла 1 класса - 8 мест,
вилла 2 класса - 9 мест,
вилла 3 класса - 10 мест.
 
Деревенский дом имеет ограниченный функционал,
а именно отсутствует приготовление еды и гардероб
 
Ты должен каждый день оплачивать недвижимость.
Если вдруг у тебя появится долг хотя бы в
один день, то ты не сможешь воспользоваться 
автопарковкой и гардеробом. Если долг будет 
больше 14 дней, то недвижимость будет продана
государству, а за квартиру ты получишь 40%.
Твои машины будут заблокированы на время,
пока ты не купишь себе недвижимость с нужным
количеством мест в гараже.
 
Квартплату можно оплатить как на один день,
так и на несколько дней вперед. При этом у
тебя есть возможность понизить стоимость
ежедневной квартплаты.]],
                },
            },
        },

        { 
            name = "Продажа недвижимости",
            menu = {
                {
                    id = "house_sale",
                    image = "house_sale",
                    name = "Продать недвижимость",
                    gps = {
                        { x = 1.5400, y = -1696.4583 + 860, z = 21.763 },
                        { x = 2270.9521, y = -950.9911 + 860, z = 61.3023 },
                    },
                    desc = [[Здесь можно приобрести или продать свою
недвижимость]],
                },
            },
        },
        
        { 
            name = "Продажа авто",
            menu = {
                categories = { "cartrade_econom", "cartrade_lux", "govsell" },
                {
                    category = "cartrade_econom",
                    name = "Б/У рынок эконом-класса",
                    image = "cartrade_2_econom",
                    gps = GetGPSCoords_Table( 8, nil, function( data )
                        return data.carsale_id == "carsale_gorki" and data.create_blip
                    end ),
                    level = 5,
                    desc = [[Совершай сделки с другими игроками.
На этом рынке доступны сделки с A, B и M классами
транспорта. Покупай, перепродавай и снова покупай.
Но помни, что государство всегда берет процент
за перепродажу!]],
                },
                {
                    category = "cartrade_lux",
                    name = "Б/У рынок среднего и люкс класса",
                    image = "cartrade_2_lux",
                    gps = GetGPSCoords_Table( 8, nil, function( data )
                        return data.carsale_id == "carsale_mo" and data.create_blip
                    end ),
                    level = 5,
                    desc = [[Совершай сделки с другими игроками.
На этом рынке доступны сделки с C, D и S классами
транспорта. Покупай, перепродавай и снова покупай.
Но помни, что государство всегда берет процент
за перепродажу!]],
                },
                {
                    category = "govsell",
                    name = "Продажа государству",
                    image = "cartrade_1",
                    gps = GetGPSCoords_Table( 4, "sell", 
                        function( data )
                            return not data.accepted_special_types
                        end
					),
					desc = [[Ты можешь продать свой транспорт государству. Но 
стоимость продажи будет составлять 50% от стоимости 
транспорта.]],
                },
            },
        },
        { 
            name = "Тюнинг",
            menu = {
                {
                    id = "tuning",
                    name = "Тюнинг Авто",
                    image = "tuning_1",
                    gps = GetGPSCoords_Table( 3 ),
                    desc = [[Настала пора к переменам! Настал день, когда твоим
ощущениям стало чего — то не хватать. А жажда начала
увеличиваться. Тогда возьми и переверни свой мир!
Добавь в него азарта, замени двигатель, установи
трубонаддув, прочипуй свою тачку. Вдохни в неё
новый мир! И утоли свою жажду скорости!]],
                },
            },
        },
        { 
            name = "Аптека",
            menu = {
                {
                    name = "Аптека",
                    image = "business_drugstore",
                    gps = exports.nrp_drugstore:GetLocations( ),
                    desc = [[
Если вдруг тебе стало плохо, то всегда можно
подлечиться в аптеке]],
                },
            },
        },
        { 
            name = "Гонки",
            menu = {
                categories = { "race_time", "race_drift", "race_drag" },
                {
                    id = "races",
                    image = "race_basis",
                    name = "",
                    area = 50,
                    max_distance = 2000,
                    desc = [[Для участия в гонках, необходимо 
в телефоне открыть приложение "Гонки". Далее выбрать
доступный режим. Каждый режим имеет свой лидерборд 
разбитый по классам машин, а топ 3 игрока в режимах 
дрифт и круг на время, раз в 2-х недельный сезон, будут
получать уникальную награду в зависимости от занятой 
позиции. Для выхода из гонки необходимо удерживать 
клавишу “F”]],
                },

                {
                    category = "race_time",
                    name = "Гонки: Круг на время",
                    image = "race_basis",
                    desc = [[В круге на время может участвовать
от 1 до 4 игроков в одном заезде. Основная задача
проехать круг за самое быстрое время в своем классе.
При этом машина может повреждаться об физические
элементы трассы. Но соперники между собой
не имеют взаимодействия.]],
                },
        
                {
                    category = "race_drift",
                    name = "Гонки: Дрифт",
                    image = "race_drift_time",
                    desc = [[В дрифте может участвовать от 1 до 4 игроков в одном
заезде. Основная задача зарабатывать очки, отправляя
машину в занос. Также есть множитель очков, который 
увеличивает скорость их набора. Для увеличения 
множителя необходимо переводить угол заноса 
на противоположную сторону. Машины с передним 
приводом не могут участвовать в гонках данного 
типа.]],
                },

                {
                    category = "race_drag",
                    name = "Гонки: Драг-рейсинг",
                    image = "race_drag",
                    desc = [[Правила гонки:
• В драг-рейсинге всегда участвует только два игрока.
• Инициатор гонки указывает ставку и предлагает участие
  конкретному игроку.
• Если соперник стоит рядом с вами, то вы можете сделать
  “вызов” на гонку через радиальное меню. [ Tab ]
• При вызове вы и ваш соперник должны находиться 
  в машине.
• Для участия в гонке машины должны быть одного класса.                  
• Вы можете участвовать в гонке только на своей машине.
                   
Управление:
• В каждой гонке ручное переключение передач.
• Переключение на передачу вверх кнопка: [ стрелка вверх ]
• Переключение передачи вниз кнопка: [ стрелка вниз ] ]]
                }
            },
        },
        { 
            name = "Развлечения",
            menu = {
                categories = { "cinema", "casino", "fight_club", "dancing_school", "strip_club" },
				{
                    category = "strip_club",
                    name = "Стрип клуб",
                    image = "strip_club",
                    gps = { x = 196.3409, y = -333.94865 + 860, z = 21.1126 },
                    desc = [[
Развлечения на все вкусы:
• Головокружительные танцы
• Сочная музыка
• "Горячие" напитки.

Вход платный]],
                },
				{
                    category = "cinema",
                    name = "Кинотеатр",
                    image = "cinema_1",
                    gps = { 
                        { x = 256.37, y = -2214.344 + 860, z = 21.796 },
                        { x = 2249.917, y = -504.796 + 860, z = 62.415 },
                        { x = 1317.850, y = 2171.738 + 860, z = 9.130 },
                    },
                    desc = [[После тяжелого рабочего, можно расслабляться
по-другому. Заказывай любое видео в YouTube.
А все зрители кинозала составят тебе компанию.]],
                },
                {
                    category = "casino",
                    name = "Казино",
                    image = "casino_1",
                    gps = {
                        { x = 706.599,  y = -208.847 + 860, z = 21.036 },
                        { x = 2535.501, y = 2579.914 + 860, z = 8.075  },
                    },
                    desc = [[Испытай свою удачу!]],
                },

                {
                    id = "fc",
                    category = "fight_club",
                    name = "Бойцовский клуб",
                    image = "fight_club",
                    gps = { x = 35.96176, y = -1270.341, z = 20.5974 },
                    desc = [[Испытай себя на прочность. В самом правильном
месте — Бойцовском клубе.]],
                },
                {
                    category = "dancing_school",
                    name = "Школа танцев",
                    image = "dancing_school",
                    gps = {
                        { x = 258.235, y = -2286.959 + 860, z = 20.796 },
                        { x = 2431.125, y = -605.5 + 860, z = 62 },
                        { x = 1859.723, y = 963.75 + 860, z = 17.386 },
                        { x = 1486.1500244141, y = 2309.8898925781 + 860, z = 9.2575988769531 },
                    },
                    desc = [[
Дополни персонажа эмоциями.
Изучи движения в нашей Школе танцев
и сопровождай общение своим самовыражением.
Для активации движения используй второе
радиальное меню.]],
                },
            },
        },
        { 
            name = "Хобби",
            menu = {
                categories = { "fishing", "hunting", "digging" },
                {
                    category = "fishing",
                    name = "Рыболовный магазин",
                    gps = {
                        { x = -1916.338, y = 489.903 + 860, z = 20.5 },
                        { x = 2167.226, y = -1194.258 + 860, z = 60.4 },
                        { x = -544.835, y = 2241.622 + 860, z = 15.84 },
                    },
                    level = 4,
                    image = "hobby_fishingstore",
                    desc = [[Магазины в которых ты можешь приобрести новые
удочки, наживки, а так же продать свою добычу.]],
                },

                {
                    category = "fishing",
                    name = "Рыбалка",
                    gps = {
                        { x = -1671.607, y = -735.669 + 860, z = 8 },
                        { x = 1057.93, y = -1151.953 + 860, z = 9 },
                        { x = 2599.944, y = -2225.28 + 860, z = 7 },
                        { x = 498.416, y = 2933.016 + 860, z = 0 },
                    },
                    level = 4,
                    image = "hobby_fishing",
                    desc = [[Теперь ты можешь не только отдыхать на свежем
воздухе, но и заработать, лови рыбу и продавай ее.
Главное, чтоб было побольше места в рюкзаке.  С 6 до 7
и с 11 до 12 можно поймать Белугу, за которую платят
50 000 рублей.]],
                },

                {
                    category = "hunting",
                    name = "Охотничий магазин",
                    gps = {
                        { x = 2173.287, y = -1199.241 + 860, z = 60.682 },
                    },
                    level = 5,
                    image = "hobby_huntingstore",
                    desc = [[Магазины в которых ты можешь приобрести новые
ружья, патроны, а так же продать свою добычу.]],
                },

                {
                    category = "hunting",
                    name = "Охотничьи угодья",
                    gps = {
                        { x = 1895.472, y = -2428.798 + 860, z = 25.119 },
                    },
                    level = 5,
                    image = "hobby_hunting",
                    desc = [[Когда нравится выслеживать добычу и стрелять прямо
в яблочко, то соедини эти два занятия охотой. Главное,
чтоб было побольше места в рюкзаке. С 13 до 14 и
с 23 до 00 можно найти Белого Оленя, за которого платят
50 000 рублей.]],
                },

                {
                    category = "digging",
                    name = "Лавка кладоискателя",
                    gps = {
                        { x = -2087.655, y = 489.94 + 860, z = 18.401 },
                    },
                    level = 6,
                    image = "hobby_diggingstore",
                    desc = [[Магазины в которых ты можешь приобрести новые
лопаты, карты сокровищ, а так же продать свою добычу.]],
                },

                {
                    category = "digging",
                    name = "Поиск сокровищ",
                    level = 6,
                    image = "hobby_digging",
                    desc = [[Теперь ты можешь не только отдыхать на свежем 
воздухе, но и находить сокровища. 
Главное чтоб было побольше места в рюкзаке. 
С каждым новым, найденным кладом, 
растет шанс найти самую дорогую находку, 
которая стоит 75 000 рублей]],
                },
            },
        },
        { 
            name = "Штрафы",
            menu = {
                categories = { "fines" },
                {
                    category = "fines",
                    image = "fines",
                    name = "Штрафы",
                    desc = [[- Новые функции в приложении "Госуслуги": Оплата 
штрафов и жалобы на гос. служащих;

- Жалобы, написанные на сотрудников ДПС и ППС видят 
лидеры их фракций. Написать жалобу может любой игрок 
в приложении “Госуслуги";

- Фракции ДПС и ППС теперь могут сами выдавать больше 
статей в ручном режиме используя радиальное меню;

- Служебный транспорт не получает штрафов за 
превышение скорости;

- Добавлен круиз-контроль, который ограничивает 
ускорение. Включается и выключается через 
радиальное меню, а также дополнительно 
отмечается под спидометром.

- Если игрок получит штрафов на 60.000 рублей 
по ПДД, его машина конфискуется пока он 
не выплатит всю задолженность;

- Оплатить штраф в размере больше 60.000 рублей 
можно только в отделе ДПС и ППС около 
окна регистрации;

- Если у вас набралось штрафов на 60 000 рублей 
и более, но вы не в состоянии оплатить, то 
можете самостоятельно прийти в отдел ППС 
и сдаться властям. Все штрафы пропадут 
после окончания срока в тюрьме; 

- Для самостоятельной сдачи властям, есть кнопка 
в окне оплаты штрафов внутри здания ППС/ДПС 
около информационного окна;

- Если транспорт перевернулся и владелец 
не эвакуирует его в течение 2 минут, 
то получит соответствующую статью;

- Увеличен размер штрафов у рабочего транспорта;
]],
                },
            },
        },
        { 
            name = "Сим-карты",
            menu = {
                {
                    id = "simshops",
                    name = "Сим-карты",
                    image = "sim-carts",
                    gps = exports.nrp_sim_shop:GetSIMShopPositions( ),
                    desc = [[Для звонков и смс на любом расстоянии необходима
сим карта. Общайся без ограничений в расстоянии.]],
                },
            },
        },
        { 
            name = "Свадьба",
            menu = {
                categories = { "wedding" },
                {
                    category = "wedding",
                    image = "wedding",
                    name = "Свадьба",
                    gps = { x = 179.96, y = -1693.46 + 860, z = 22.7 },
                    desc = [[
Свадьба, это возможность не только совместной игры,
но и получения достойных бонусов, которые 
сделают игру приятнее и интереснее.

Все детали по бракосочетанию можно узнать
у батюшки в церкви.]],
                },
            },
        },
        {
            name = "Магазин Оружия",
            menu = {
                {
                    id = "gunshop",
                    image = "weapon_store",
                    name = "Оружейный магазин",
                    gps = {
                        { x = 172.112, y = -2130.621 + 860, z = 22.021 },
                        { x = -84.85, y = 2512.88 + 860, z = 21.61, },
                    },
                    desc = [[
В магазине оружия продается неавтоматическое,
огнестрельное оружие. Для его покупки необходимо
приобрести лицензию, которая располагается
в ассортименте магазина. Также есть дополнительные
условия для покупки лицензии на оружие, а именно:
- Уровень персонажа 6 и выше;
- Социальный рейтинг должен быть положительным.
]],
                }
            }
        },
        {
            name = "Опасные задания",
            menu = {
                {
                    id = "coop_quests",
                    image = "coop_quests",
                    name = "Опасные задания",
                    gps = {
                        { x = 488.800, y = 2192.781 + 860, z = 15.207 },
                        { x = -44.421, y = 2584.076 + 860, z = 21.607 },
                        { x = -649.25, y = 2136.030 + 860, z = 20.120 },
                    },
                    desc = [[
На опасных заданиях тебе предстоит столкновение с 
конкурентами - закупись в оружейном магазине, найди 
или пригласи напарника и вступай в схватку с 
противниками! Задания выбираются случайно. 
Исполнители в конце задания получают валюту, 
которую можно менять на ценные предметы.
]],
                }
            }
        },
        {
            name = "Инвентарь 2.0",
            menu = {
                {
                    id = "inventory",
                    image = "inventory",
                    name = "Инвентарь 2.0",
                    desc = [[
• Рюкзак персонажа ограничен переносимым весом. 
 
• При перегрузке персонаж не может быстро бежать. 
Если перегрузка увеличивается в 2 раза, 
то при перемещении тратится энергия
 
• Предметы из рюкзака персонажа можно переложить 
в багажник машины или в ящик недвижимости.
 
• У каждой машины и недвижимости свое место хранения  
предметов. Размеры для хранения, также зависят от  
вида имущества.
  
• Также добавлена панель быстрого доступа, 
которая ускорят использование предметов. 
Убрать предметы из панели можно по кн ПКМ.
 
• Для увелечения вместимости можно 
воспользоваться соответствующими услугами.
]],
                },
            },
        },
    }

    table.sort( NAVIGATION_LIST, function( a, b ) return a.name < b.name end )


    Extend( "ib" )
    ibUseRealFonts( true )

    GLOBAL_TABS = {
        [ 1 ] = { 
            name = "Навигация", 
        },
        [ 2 ] = { 
            name = "Информация",
        },
        [ 3 ] = { 
            name = "Обновления",
            tabs = UPDATES_LIST,
        },
    }

    GLOBAL_TABS[ 1 ].tabs = table.copy( NAVIGATION_LIST )
    for i, v in pairs( GLOBAL_TABS[ 1 ].tabs ) do
        local has_gps = v.buttons
        
        if v.menu then
            for n, t in ipairs( v.menu ) do
                if t.desc then t.desc = nil end
                if t.gps then has_gps = true end
            end
        end

        if not has_gps then
            table.remove( GLOBAL_TABS[ 1 ].tabs, i )
            i = i - 1
        end
    end

    GLOBAL_TABS[ 2 ].tabs = table.copy( NAVIGATION_LIST )

    table.insert( 
        GLOBAL_TABS[ 2 ].tabs, 1, 
        { 
            name = "Клавиши управления",
            create_fn = function( parent )
                local sections = {
                    {
                        name = "Основные",
                        scroll = 0,
                    },
                    {
                        name = "Коммуникация",
                        scroll = 890,
                    },
                    {
                        name = "Бой",
                        scroll = 1310,
                    },
                    {
                        name = "Гонки",
                        scroll = 1590,
                    },
                    {
                        name = "Бойцовский Клуб",
                        scroll = 1940,
                    },
                }

                local function scroll_to( pixels )
                    local pixels = pixels or 0
                    UI_elements.items_scroll:ibData( "position", math.min( 1, pixels / parent:height( ) ) )
                end

                local main_nav, dropdown_nav = { }, { }

                local temp_elements = { }

                -- Дефолтные значения меню навигации
                local npx_default, npy_default = 30, 23
                local navbar_sy, navbar_padding = 45, 14

                -- Текущие значения для подсчёта
                local npx = npx_default
                local font = ibFonts.semibold_12

                -- Подсчёт какие вкладки должны быть в навбаре, какие в дроп-меню
                for i, v in pairs( sections ) do
                    local name = v.name
                    local width = dxGetTextWidth( name, 1, font )
                    npx = npx + math.floor( width ) + 30

                    if npx <= 30 + 450 then
                        table.insert( main_nav, v )
                    else
                        table.insert( dropdown_nav, v )
                    end
                end

                -- Панель навигации - верхняя часть без учета дроп-меню
                local npx, npy = npx_default, npy_default
                local elements = { }
                local detect_sx_additional, detect_sy_absolute = 15, 30

                local line_element

                for i, v in pairs( main_nav ) do
                    local name = v.name

                    local current_npx = npx

                    local default_alpha = 200
                    local label = ibCreateLabel( npx, npy, 0, 0, name, parent, 0xffffffff, _, _, "left", "center", font ):ibData( "disabled", true ):ibData( "alpha", default_alpha )
                    local bg = ibCreateImage( npx - detect_sx_additional / 2, npy - detect_sy_absolute / 2, label:width( ) + detect_sx_additional, detect_sy_absolute, _, parent, 0 )
                    :ibBatchData( { priority = -1 } )
                    :ibOnClick( function( key, state, is_simulated )
                        if key ~= "left" or state ~= "up" then return end
                        if not is_simulated then ibClick( ) end
                        --SwitchNavigationTab( i, is_simulated )
                        scroll_to( v.scroll )
                        for i, v in pairs( elements ) do
                            if v.label ~= label then
                                v.label:ibAlphaTo( default_alpha, 150 )
                            end
                        end

                        local move_duration, alpha_duration = 200, 200
                        if isElement( line_element ) then
                            line_element:ibMoveTo( current_npx, _, move_duration ):ibResizeTo( label:width( ), _, move_duration )
                        else
                            if not is_navbar_empty then
                                line_element = ibCreateImage( current_npx, 42, label:width( ), 3, _, parent, 0xfffb9769 ):ibData( "alpha", 0 ):ibAlphaTo( 255, alpha_duration )
                            end
                        end
                        label:ibAlphaTo( 255, 150 )
                    end )
                    :ibOnHover( function( )
                        label:ibAlphaTo( 255, 150 )
                    end )
                    :ibOnLeave( function( )
                        if current_tab ~= i then
                            label:ibAlphaTo( default_alpha, 150 )
                        end
                    end )

                    temp_elements[ "subsubtab_" .. i ] = bg

                    table.insert( elements, { label = label, bg = bg } )
                    npx = npx + math.floor( label:width( ) ) + 30
                end

                -- Прячем панель если там всего 1 вкладка
                if is_navbar_empty then
                    for i, v in pairs( elements ) do
                        for name, element in pairs( v ) do
                            element:ibData( "visible", false )
                        end
                    end 
                
                -- Добавляем линию в ином случае
                else
                    ibCreateImage( 30, navbar_sy - 1, 500, 1, _, parent, 0x30ffffff )
                end

                -- Если есть элементы выпадающего списка, добавляем
                if #dropdown_nav > 0 then
                    local default_alpha = 200
                    local btn = ibCreateImage( 500, navbar_sy / 2 - 15, 30, 30, _, parent, 0 ):ibData( "alpha", default_alpha )
                    ibCreateImage( 0, 0, 18, 6, "img/icon_dots.png", btn ):center( ):ibData( "disabled", true )

                    temp_elements[ "dropdown" ] = btn
                    addEvent( "onDropdownMenuOpen", true )
                    addEventHandler( "onDropdownMenuOpen", btn, function( item_num )
                        ibClick( )
                        SwitchNavigationTab( item_num )
                    end )

                    btn:ibOnHover( function( )
                        btn:ibAlphaTo( 255, 250 )
                    end )
                    :ibOnLeave( function( )
                        btn:ibAlphaTo( default_alpha, 250 )
                    end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        if isElement( temp_elements.dropdown_bg ) then destroyElement( temp_elements.dropdown_bg ) return end

                        ibClick( )

                        local nsx, nsy = 200, 45
                        local npx, npy = 15, 5
                        local y_offset = 30
                        temp_elements.dropdown_bg = ibCreateArea( math.floor( 530 - nsx - 6 ), math.floor( btn:ibData( "py" ) + y_offset ), nsx, #dropdown_nav * nsy, parent ):ibData( "alpha", 0 )

                        ibCreateImage( nsx - 4 - 10, 0, 10, 5, "img/icon_triangle.png", temp_elements.dropdown_bg )
                        
                        for i, v in pairs( dropdown_nav ) do
                            local name = CATEGORIES_NAMES[ v ] or v

                            local bg = ibCreateImage( 0, npy, nsx, nsy, _, temp_elements.dropdown_bg, 0xff58819f )
                            local bg_hover

                            -- Если это первый элемент, у него нет линии сверху, поэтому сдвиг не нужен
                            if i == 1 then
                                bg_hover = ibCreateImage( 0, npy, nsx, nsy, _, temp_elements.dropdown_bg, 0xff6c8ea9 ):ibBatchData( { alpha = 0, disabled = true } )
                            else
                                bg_hover = ibCreateImage( 0, npy - 1, nsx, nsy + 1, _, temp_elements.dropdown_bg, 0xff6c8ea9 ):ibBatchData( { alpha = 0, disabled = true } )
                            end

                            local item_num = #main_nav + i

                            if item_num == current_tab then
                                ibCreateImage( nsx - 3, npy + nsy / 2 - 13 / 2, 3, 13, _, temp_elements.dropdown_bg, 0xfffb9769 ):ibData( "priority", 5 )
                            end

                            bg:ibData( "priority", -1 )
                            :ibOnClick( function( key, state )
                                if key ~= "left" or state ~= "up" then return end
                                ibClick( )
                                --SwitchNavigationTab( item_num )
                                scroll_to( v.scroll )
                                if isElement( line_element ) then destroyElement( line_element ) end
                                if isElement( temp_elements.dropdown_bg ) then destroyElement( temp_elements.dropdown_bg ) end
                            end )
                            :ibOnHover( function( )
                                bg_hover:ibAlphaTo( 255, 150 )
                            end )
                            :ibOnLeave( function( )
                                bg_hover:ibAlphaTo( 0, 150 )
                            end )

                            local label = ibCreateLabel( npx, npy, 0, nsy, v.name, temp_elements.dropdown_bg, 0xffffffff, _, _, "left", "center", font ):ibData( "disabled", true )
                            
                            -- Не нужна линия у последнего элемента списка
                            if i ~= #dropdown_nav then
                                local line = ibCreateImage( 0, npy + nsy - 1, nsx, 1, _, temp_elements.dropdown_bg, 0x30000000 ):ibData( "priority", 2 )
                                table.insert( elements, { label = label, bg = bg, bg_hover = bg_hover, line = line } )
                            end

                            temp_elements[ "subsubtab_" .. item_num ] = btn

                            npy = npy + nsy
                        end

                        local function HandleClickAnywhere( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            if isElement( temp_elements.dropdown_bg ) then
                                temp_elements.dropdown_bg:ibTimer( function( self ) self:destroy( ) end, 50, 1 )
                            end
                        end
                        addEventHandler( "onClientClick", root, HandleClickAnywhere, true, "low-1000000" )

                        temp_elements.dropdown_bg:ibOnDestroy( function( )
                            removeEventHandler( "onClientClick", root, HandleClickAnywhere )
                        end )

                        temp_elements.dropdown_bg:ibAlphaTo( 255, 200 )
                    
                    end )
                end
                temp_elements[ "subsubtab_1" ]:ibTimer( function( self ) self:ibSimulateClick( "left", "up" ) end, 50, 1 )

                local image = ibCreateImage( 0, 48, 0, 0, "img/items/info/keyboard.png", parent ):ibSetRealSize( )
                return image:ibData( "py" ) + image:height( )
            end,
        }
    )

    if localPlayer:getData( "_ig" ) or exports.nrp_shop:IsSpecialOffersSynced( ) then
        onClientPlayerSyncOffersFinish_handler( )
    end

    GPS_FROM_CATEGORY = { }

    for i, page in pairs( NAVIGATION_LIST ) do
        if page.menu then
            for k, v in pairs( page.menu ) do
                if type( v ) == "table" and ( v.category or v.id ) and v.gps then
                    local category = v.id or v.category
                    if GPS_FROM_CATEGORY[ category ] then
                        if #v.gps >= 1 then
                            for _, location in pairs( v.gps ) do
                                table.insert( GPS_FROM_CATEGORY[ category ], location )
                            end
                        else
                            table.insert( GPS_FROM_CATEGORY[ category ], v.gps )
                        end
                    else
                        GPS_FROM_CATEGORY[ category ] = #v.gps >= 1 and table.copy( v.gps ) or { v.gps }
                    end
                end
            end
        end
    end
end
addEventHandler( "onClientResourceStart", resourceRoot, onClientResourceStart_handler )