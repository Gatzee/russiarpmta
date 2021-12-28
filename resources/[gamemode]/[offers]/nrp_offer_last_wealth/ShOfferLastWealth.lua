loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )

-- !!! CHANGE WITH NEW ACTION
CONST_OFFER_NUMBER = 1
CONST_OFFER_NAME   = "lw"

CONST_OFFER_DURATION_IN_SEC = 3 * 24 * 60 * 60

CONST_OFFER_START_DATE = getTimestampFromString( "2 мая 2021 00:00" )
CONST_OFFER_END_DATE   = CONST_OFFER_START_DATE + CONST_OFFER_DURATION_IN_SEC

DEFAULT_MULTIPLY_DATA = { value = 1.5, min_payment_sum = 99 }

LEVEL_MULTIPLY =
{
    {
        value = 2,
        name = "Базовая закупка",
        steps =
        {
            booster_may_events = { count = 1, name = "Купить любой бустер\nмайского праздника" },
            _any_case_battle   = { count = 2, name = "Участвовать в битве\nкейсов 2 раза" },
            payment_1_5        = { count = 1, name = "Сделать платёж", value = "x1,5", payment = true },
        },
        min_payment_sum = 490,
    },

    {
        value = 2.5,
        name = "Раскрепощенные затраты",
        steps =
        {
            _any_case_battle    = { count = 15, name = "Участвовать в битве\nкейсов 15 раз" },
            booster_may_events  = { count = 1,  name = "Купить любой бустер\nмайского праздника" },
            payment_2           = { count = 1,  name = "Сделать платёж", value = "x2", payment = true },
            booster_battle_pass = { count = 1,  name = "Купить усиление сезона"  },
            premium_battle_pass = { count = 1,  name = "Купить премиальный\nсезонный билет"  },
        },
        min_payment_sum = 1490,
    },

    {
        value = 2.75,
        name = "Настоящее богатство",
        steps =
        {
            _any_case_battle = { count = 45, name = "Участвовать в битве\nкейсов 45 раз" },
            premium_30       = { count = 1,  name = "Купить премиум на 30 дней"  },
            payment_2_5      = { count = 1,  name = "Сделать платёж", value = "x2,5", payment = true },
        },
        min_payment_sum = 2990,
    },

    {
        value = 3,
        name = "Царская закупка",
        steps =
        {
            pack_50             = { count = 1,  name = "Купить пак \"Оборона\"" },
            premium_battle_pass = { count = 1,  name = "Купить премиальный\nсезонный билет"  },
            _any_case_battle    = { count = 76, name = "Участвовать в битве\nкейсов 76 раз" },
            payment_2_75        = { count = 1,  name = "Сделать платёж", value = "x2,75", payment = true },
        },
        min_payment_sum = 4490,
    },
}

for k, v in pairs( LEVEL_MULTIPLY ) do
    v.steps_sum = 0
    v.task_count = 0
    for step_id, step_data in pairs( v.steps ) do
        v.steps_sum = v.steps_sum + step_data.count
        v.task_count = v.task_count + 1
    end
end