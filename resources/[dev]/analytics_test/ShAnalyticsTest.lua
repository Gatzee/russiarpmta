EVENTS_PARAMS = {
    unique_cars_auction_showfirst = { },

    unique_cars_auction_bet = {
        lot_id = "string",
        bet_sum = "number",
        bet_paid = "number",
        bet_num = "number",
        currency = "string",
    },

    unique_cars_auction_finish = {
        lot_id = "string",
        bet_sum = "number",
        is_bet_won = "string",
        currency = "string",
    },

    danilych_sale_purchase = {
        current_lvl = "number",
        cost        = "number",
        quantity    = "number",
        spend_sum   = "number",
        currency    = "string",
    },

    danilych_sale_showfirst = { },

    business_upgrade = {
        type = "string",
        id = "string",
        cost = "number",
        business_level = "number",
        day = "number",
    },

    business_purchase = {
        type = "string",
        id = "string",
        stock = "string",
        cost = "number",
        day = "number",
        business_level = "number",
        business_progress = "number",
    },

    wholesale_case_show_first = { },

    wholesale_case_purchase = {
        id          = "string",
        case_type   = "string",
        count       = "number",
        currency    = "string",
        spend_sum   = "number",
    },

    inventory_put = {
        type = "string",
        vehicle_id = "string",
        mortage_id = "string",
        item_id = "string",
        item_name = "string",
        items_type = "string",
    },

    fullrp_invite_showfirst = { },
    fullrp_invite_get = {
        code        = "string",
    },
    fullrp_invite_use = {
        code        = "string",
    },

    coop_quest_complete = {
        id          = "string",
        is_afk      = "string",
        is_win      = "string",
        is_draw     = "string",
        reward_sum  = "number",
        currency    = "string",
        death_sum   = "number",
        kill_sum    = "number",
    },

    coop_quest_purchase = {
        id          = "string",
        cost        = "number",
        quantity    = "number",
        type        = "string",
        class       = "string",
        spend_sum   = "number",
        currency    = "string",
    },

    ind_wof_offer_show = { },
    ind_wof_offer_purchase = {
        id        = "string",
        cost      = "number",
        quantity  = "number",
        spend_sum = "number",
        currency  = "string",
    },

    ind_access_soft_offer_show = { },
    ind_access_soft_offer_purchase = {
        id        = "string",
        cost      = "number",
        quantity  = "number",
        spend_sum = "number",
        currency  = "string",
    },

    ind_soft_car_offer_show = { },
    ind_soft_car_offer_purchase = {
        id        = "string",
        cost      = "number",
        quantity  = "number",
        spend_sum = "number",
        currency  = "string",
    },
    
    bp_ticket_offer_show = {
        id        = "string",
    },

    bp_ticket_offer_purchase = {
        id        = "string",
        name      = "string",
        cost      = "number",
        quantity  = "number",
        spend_sum = "number",
        currency  = "string",
    },

    bp_reward_donate_pack_offer_show = {
        id        = "string",
    },

    bp_reward_donate_pack_offer_purchase = {
        id        = "string",
        name      = "string",
        segment   = "number",
        cost      = "number",
        hard_sum  = "number",
        quantity  = "number",
        spend_sum = "number",
        currency  = "string",
    },

    clan_shop_purchase = {
        current_lvl_clan = "number",
        clan_id = "number",
        clan_name = "string",
        cart_items = "string",
    },

    clan_huckster_purchase  = {
        current_lvl_clan = "number",
        clan_id = "number",
        clan_name = "string",
        cart_items = "string",
    },

    march_offer_show_first = { },

    updated_case_showfirst = { },

    updated_case_purchase = 
    {
        id          = "string",
        name        = "string",
        cost        = "number",
        quantity    = "number",
        currency    = "string",
        spend_sum   = "number",
        points_sum  = "number",
    },

    updated_case_reward = 
    {
        id          = "string",
        cost        = "number",
        name        = "string",
        points_sum  = "number",
    },

    march_offer_offer_purchase = {
        id        = "string",
        name      = "string",
        cost      = "number",
        quantity  = "number",
        spend_sum = "number",
        currency  = "string",
    },

    clan_develop_theme_purchase = {
        clan_id   = "number",
        clan_name = "string",
        theme_id  = "string",
        lvl_num   = "number",
        buff_id   = "string",
        buff_name = "string",
        buff_cost = "number",
        currency  = "string",
    },

    clan_develop_product_purchase = {
        clan_id         = "number",
        clan_name       = "string",
        product_type    = "string",
        product_lvl_num = "number",
        cost            = "number",
        currency        = "string",
    },

    clan_develop_theme_change = {
        clan_id      = "number" ,
        clan_name    = "string" ,
        theme_id_old = "string" ,
        theme_id_new = "string" ,
        cost         = "number" ,
        currency     = "string" ,
    },

    clan_develop_production = {
        clan_id         = "number" ,
        clan_name       = "string" ,
        product_type    = "string" ,
        product_lvl_num = "number" ,
        product_grade   = "string" ,
    },

    clan_daily_batch_complete = {
        clan_id            = "number" ,
        clan_name          = "string" ,
        product_type       = "string" ,
        product_lvl_num    = "number" ,
        grade_batch_num    = "number" ,
        batch_num          = "number" ,
        receive_sum        = "number" ,
        currency           = "string" ,
    },

    clan_daily_receive_all = {
        client_id          = "nil",
        clan_id            = "number" ,
        clan_name          = "string" ,
        product_type       = "string" ,
        product_lvl_num    = "number" ,
        grade_batch_num    = "number" ,
        batch_num          = "number" ,
        point_num          = "number" ,
        receive_sum        = "number" ,
        currency           = "string" ,
    },

    bosow_sale_purchase = {
        current_lvl = "number",
        cost        = "number",
        quantity    = "number",
        spend_sum   = "number",
        currency    = "string",
    },

    bosow_sale_showfirst = { },

    newyear_case_pack_offer_first = {
        id        = "string",
    },

    newyear_case_pack_offer_purchase = {
        id        = "string",
        name      = "string",
        cost      = "number",
        quantity  = "number",
        spend_sum = "number",
        currency  = "string",
    },

    premium_discount_case_first = { },

    [ "3d_prem_give_offer_take" ] = {
        id_sale = "string",
    },

    [ "3d_prem_give_offer_show" ] = {
        id_sale = "string",
    },

    [ "3d_prem_give_offer_purchase" ] = {
        id_sale         = "string",
        prem_type       = "string",
        prem_cost       = "number",
        quantity        = "number",
        spend_sum       = "number",
        currency        = "string",
    },

    extension48_prem_offer_show = {
        id_sale         = "string",
    },

    extension48_prem_offer_purchase = {
        id_sale         = "string",
        prem_type       = "string",
        prem_cost       = "number",
        quantity        = "number",
        spend_sum       = "number",
        currency        = "string",
    },

    faster_prem_offer_show = {
        id_sale         = "string",
    },

    faster_prem_offer_purchase = {
        id_sale         = "string",
        prem_type       = "string",
        prem_cost       = "number",
        quantity        = "number",
        spend_sum       = "number",
        currency        = "string",
    },

    prem_nopurchase_offer_show = {
        id_sale         = "string",
    },

    prem_nopurchase_offer_purcahse = {
        id_sale         = "string",
        pack_name       = "string",
        prem_pack_cost  = "number",
        quantity        = "number",
        spend_sum       = "number",
        currency        = "string",
    },

    premium_share_offer_show = {
        id_sale         = "string",
    },

    premium_share_offer_purchase = {
        id_sale         = "string",
        vehicle_class   = "string",
        pack_name       = "string",
        pack_cost       = "number",
        quantity        = "number",
        spend_sum       = "number",
        currency        = "string",
    },

    industrial_fishing_job_start = {
        search_duration  = "number",
        lobby_id         = "number",
        job_role         = "string",
        players_quantity = "number",
        is_lobby_creator = "string",
    },

    industrial_fishing_job_finish = {
        lobby_id           = "number",
        players_quantity   = "number",
        job_duration       = "number",
        container_quantity = "number",
        receive_sum        = "number",
        currency           = "string",
        exp_sum            = "number",
        finish_reason      = "string",
    },

    industrial_fishing_job_start = {
        search_duration  = "number",
        lobby_id         = "number",
        job_role         = "string",
        players_quantity = "number",
        is_lobby_creator = "string",
    },

    hijack_cars_job_start = {
        search_duration  = "number",
        lobby_id         = "number",
        job_role         = "string",
        players_quantity = "number",
        is_lobby_creator = "string",
    },

    hijack_cars_job_finish = {
        lobby_id      = "number",
        receive_sum   = "number",
        current_lvl   = "number",
        currency      = "string",
        exp_sum       = "number",
        vehicle_count = "number",
        players_num   = "number",
        job_duration  = "number",
        finish_reason = "string",
    },

    hijack_cars_job_voyage = {
        lobby_id         = "number",
        current_lvl      = "number",
        vehicle_id       = "string",
        vehicle_name     = "string",
        vehicle_class    = "string",
        players_quantity = "number",
        job_role         = "string",
        job_duration     = "number",
        receive_sum      = "number",
        currency         = "string",
        exp_sum          = "number",
    },

    trashman_job_start = {
        search_duration  = "number",
        lobby_id         = "number",
        job_role         = "string",
        players_quantity = "number",
        is_lobby_creator = "string",
    },

    trashman_job_finish_voyage = {
        lobby_id         = "number",
        players_quantity = "number",
        job_duration     = "number",
        receive_sum      = "number",
        currency         = "string",
        exp_sum          = "number",
    },

    trashman_job_finish  = {
        lobby_id         = "number",
        players_quantity = "number",
        job_duration     = "number",
        receive_sum      = "number",
        currency         = "string",
        exp_sum          = "number",
        finish_reason    = "string",
        bag_quantity     = "number",
    },

    f4_case_purchase = {
        cost_case   = "number",
        cost        = "number",
        count       = "number",
        name        = "string",
        case_type   = "string",
        is_discount = "string",
        discount_id = "string",
    },

    first_case_purchase = {
        name              = "string",
        case_type         = "string",
        paid_before       = "string",
        count             = "number",
        cost              = "number",
        time_from_install = "number",
        time_in_game      = "number",
    },

    party_youtuber_invite = {
        invited_client_id   = "string",
        id_youtuber         = "string",
        name_party          = "string",
    },

    party_youtuber_invite_accepted = {
        invited_client_id   = "string",
        id_youtuber         = "string",
        name_party          = "string",
        is_accepted         = "string",
    },

    party_youtuber_request = {
        request_client_id   = "string",
        id_youtuber         = "string",
        name_party          = "string",
    },

    party_youtuber_request_accepted = {
        request_client_id   = "string",
        id_youtuber         = "string",
        name_party          = "string",
        is_accepted         = "string",
    },

    party_youtuber_join = {
        join_client_id      = "string",
        id_youtuber         = "string",
        name_party          = "string",
        id_gathering        = "string",
    },

    party_youtuber_leave = {
        leave_client_id     = "string",
        id_youtuber         = "string",
        name_party          = "string",
        leave_type          = "string",
    },

    party_youtuber_draw = {
        id_youtuber         = "string",
        name_party          = "string",
        id_gathering        = "string",
        count_members       = "number",
        winner_client_id    = "string",
        id_reward           = "string",
        name_reward         = "string",
    },

    party_youtuber_event = {
        id_youtuber             = "string",
        name_party              = "string",
        id_gathering            = "string",
        count_members_unique    = "number",
        count_members_begin     = "number",
        count_members_end       = "number",
        duration                = "number"
    },

    party_youtuber_notif = {
        id_youtuber             = "string",
        name_party              = "string",
        count_members           = "number",
        gathering_time_length   = "string",
        id_gathering            = "string",
    },

    test_comfort_start_offer_purchase = {
        pack_cost   = "number",
        currency    = "string",
        pack_id     = "number",
        pack_name   = "string",
    },

    test_comfort_start_offer_is_test  = {
        test_group = "string",
    },

    test_comfort_start_offer_show_first  = {
        -- empty event
    },

    battle_pass_take_reward = {
        id_reward   = "string",
        type_reward = "string",
        name_reward = "string",
        type_line   = "string",
        quantity    = "number",
        receive_sum = "number",
        currency    = "string",
    },
    
    battle_pass_level_up = {
        level_num   = "number",
        season_num  = "number",
        stage_num   = "number",
        total_boost = "number",
        is_bought   = "string",
    },
    
    battle_pass_task_complited = {
        season_num  = "number",
        num_task    = "number",
        id_task     = "string",
        name_task   = "string",
        reward_type = "string",
        quantity    = "number",
        total_boost = "number",
        is_levelup  = "string",
        level_num   = "number",
        skip_sum    = "number",
        is_skipped  = "string",
    },
    
    battle_pass_purchase = {
        id_item     = "string",
        season_num  = "number",
        quantity    = "number",
        spend_sum   = "number",
        currency    = "string",
        discount    = "number",
    },
    
    casino_lottery_purchase = {
        lottery_id         = "string" ,
        lottery_type       = "string" ,
        lottery_theme_name = "string" ,
        lottery_name       = "string" ,
        lottery_cost       = "number" ,
        quantity           = "number" ,
        currency           = "string" ,
    },

    casino_lottery_reward = {
        lottery_id         = "string" ,
        lottery_name       = "string" ,
        lottery_type       = "string" ,
        lottery_theme_name = "string" ,
        reward_name        = "string" ,
        reward_cost        = "number" ,
        quantity           = "number" ,
        reward_type        = "string" ,
        point_num          = "number" ,
    },

    casino_lottery_progress_reward = {
        lottery_id  = "string",
        season_num  = "number" ,
        reward_name = "string" ,
        reward_cost = "number" ,
        quantity    = "number" ,
        reward_num  = "number" ,
    },
    
    f4_case_open = { },

    f4_case_item_take = { },

    tuning_case_item_sell = {
        item_id         = "number",
        item_name       = "string",
        item_type       = "string",
        item_class      = "string",
        item_category   = "number",
        item_cost       = "number",
        receive         = "number",
        quantity        = "number",
        currency        = "string",
    },

    tuning_case_part_install = {
        item_id         = "number",
        item_name       = "string",
        item_type       = "string",
        item_category   = "number",
        vehicle_id      = "number",
        vehicle_name    = "string",
        vehicle_slot    = "string",
    },

    tuning_case_item_take = {
        item_id         = "number",
        item_name       = "string",
        item_type       = "string",
        item_category   = "number",
        case_name       = "string",
        case_class      = "string",
        case_type       = "string",
    },

    tuning_case_open = {
        case_id         = "number",
        case_name       = "string",
        case_class      = "string",
        case_type       = "string",
    },

    tuning_case_purchase = {
        case_id         = "number",
        case_name       = "string",
        case_class      = "string",
        case_type       = "string",
        vehicle_id      = "number",
        vehicle_name    = "string",
        case_cost       = "number",
        quantity        = "number",
        spend_sum       = "number",
        currency        = "string",
    },

    bounty_hunters_purchase_order_faction = {
        cost        = "number",
        currency    = "string",
    },

    bounty_hunters_gps = {
        type_name   = "string",
        cost        = "number",
        currency    = "string",
    },

    bounty_hunters_faction_reward = {
        faction_name    = "string",
        faction_id      = "number",
        officer_id      = "number",
        officer_name    = "string",
        officer_rank    = "number",
        reward_count    = "number",
        currency        = "string",
    },

    bounty_hunters_clan_reward = {
        clan_id     = "number",
        cost        = "number",
        currency    = "string",
    },

    bounty_hunters_time_end = {
        type        = "string",
        cost        = "number",
        currency    = "string",
        id_order    = "number",
        name_order  = "string",
    },

    bounty_hunters_order = {
        type        = "string",
        cost        = "number",
        currency    = "string",
        id_order    = "number",
        name_order  = "string",
    },

    in_game_income = {
        sum                     = "number",
        source_class            = "string",
        source_class_type       = "string",
        currency                = "string",
    },

    in_game_outcome = {
        sum                     = "number",
        source_class            = "string",
        source_class_type       = "string",
        currency                = "string",
    },

    give_like = {
        target_user_id          = "string",
        target_user_name        = "string",
        target_user_rating      = "number",
    },

    give_dislike = {
        target_user_id          = "string",
        target_user_name        = "string",
        target_user_rating      = "number",
    },

    rating_give_donate = {
        type                    = "string",
        cost                    = "number",
        currency                = "string",
        old_rating              = "number",
        new_rating              = "number",
    },

    car_status_change = {
        car_vin_id                  = "number",
        vehicle_damage_status       = "string",
        vehicle_id                  = "number",
        vehicle_name                = "string",
        tt_change_hrs               = "number",
        capital_repair_num          = "number",
        mileage_total               = "number",
        mileage_from_lp             = "number",
        dmg_total                   = "number",
        dmg_from_lp                 = "number",
        days_from_lp                = "number",
        vehicle_hrs_in_game         = "number",
        vehicle_first_purchase_date = "number",
    },

    car_capital_repair_purchase = {
        car_name            = "string",
        car_id              = "number",
        capital_repair_cost = "number",
        distance            = "number",
        sales_num           = "number",
        days_from_lp        = "number",
    },

    car_number_purchase = {
        number_class   = "number",
        number_name    = "string",
        from_f4        = "string",
        purchase_count = "string"
    },

    car_trade_sell = {
        model                    = "number",
        cost                     = "number",
        car_damage_status        = "string",
        car_capital_repair_count = "number",
        car_market               = "string",
    },

    car_trade_purchase = {
        model                    = "number",
        cost                     = "number",
        car_damage_status        = "string",
        car_capital_repair_count = "number",
        car_market               = "string",
    },

    num_change_purchase = {
        cost   = "number",
        currency    = "string",
        current_region = "number",
        new_region = "number",
    },

    kb_season_finish =
    {
        season_num  = "number",
        final_place = "number",
    },
    
    retention_goal_test_a = {
        is_test = "string",
    },

    retention_goal_complete_test = {
        goal_id   = "string",
        goal_name = "string",
        reward    = "number",
    },

    prem_offer_48hrs_purchase = {
        is_first_prem = "string",
        cost = "number",
    },

    prem_offer_48hrs_show_first = { },

    casino_offer1_48hrs_showfirst = {
        casino_games_num = "number",
    },

    casino_offer1_48hrs_purchase = {
        casino_games_num = "number",
    },

    casino_offer1_present_get = {
        day_num = "number",
    },

    casino_offer1_presen_lost = {
        day_num = "number",
    },

    retention_goal_show = {
        goal_id   = "string",
        goal_name = "string",
    },

    retention_goal_complete = {
        goal_id          = "string",
        goal_name        = "string",
        reward_sum       = "number",
        currency         = "string",
        time_to_complete = "number",
        goal_num         = "number",
        test_group       = "string",
    },

    content_soft_sale_purchase = {
        item_id   = "number",
        cost      = "number",
        segment   = "number",
        item_type = "string",
        item_name = "string",
        currency  = "string",
    },

    gov_sale = {
        type = "string",
        name = "string",
        id   = "number",
        cost = "number",
    },

    vinyl_case_window_show = {},

    vinyl_case_purchase = 
    { 
        cost = "number",
        count = "number",
        name = "string",
        type = "string",
    },

    vinyl_case_open = 
    { 
        cost = "number",
        car_class = "number",
        item_id = "string",
    },

    vinyl_case_get_item =  
    { 
        cost = "number",
        car_class = "number",
        item_id = "string",
    },

    vinyl_item_sold = 
    { 
        cost = "number",
        item_class = "number",
        item_id = "string",
    },

    vinyl_item_installation =
    { 
        cost = "number",
        item_class = "number",
        item_id = "string",
        car_id = "number",
    },

    retargeting_offer_enter  = {
        user_segment = "number",
    },

    retargeting_offer_purchase = {
        offer_type = "string",
        user_segment = "number",
        cost = "number",
    },

    event_join = {
        event_id = "string",
        join_num = "number",
    },

    event_winner = {
        event_id = "string",
        victory_num = "number",
        event_last = "number",
        event_prize = "number",
    },

    hw_item_purchase = {
        item_id = "string",
        item_name = "string",
        item_type = "string",
        item_cost = "number",
    },

    hw_booster_purchase = {
        booster_name = "string",
        booster_cost = "number",
        currency = "string",
    },

    phone_ring_pur =
    {
        currency = "string",
        cost     = "number", 
        type     = "string",
        ring_id  = "string",
    },
    phone_img_purchase =
    {
        currency = "string",
        cost     = "number", 
        img_id   = "string",
    },
    phone_call = 
    { 
        cost = "number",
        duration = "number", 
        currency  = "string",
        tarification_id = "number",
    },
    phone_num_purchase =
    { 
        num_type = "string",
        num = "number", 
        cost = "number",
        tarification_id = "number",
    },
    phone_num_drop =
    { 
        num_type = "string",
        num = "number", 
        reason  = "string",
    },
    phone_message =
    { 
        cost = "number",
        currency  = "string",
        tarification_id = "number",
    },
    

    mortage_purchase = 
    {
        mortage_type = "string",
        mortage_group = "number",
        mortage_id = "number",
        is_first_owner = "string",
        days_since_last_owner = "number",
        mortage_cost = "number",
        currency = "string",
        mortage_daily_service_cost = "number",
        mortage_purchase_type = "string",
    },

    counter_purchase = 
    {
        mortage_type = "string",
        mortage_group = "number",
        mortage_id = "number",
        counter_cost = "number",
        currency = "string",
        discount_sum = "number",
        new_mortage_daily_service_cost = "number",
    },

    mortage_loss = 
    {
        mortage_type = "string",
        mortage_group = "number",
        mortage_id = "number",
        loss_reason = "string",
        sum = "number",
        owned_days = "number", 
    },
    next_hb_event =
    { 
        event_step = "number",
        present_get  = "number",
        currency = "string",
    },

    move_offer_showfirst = { },

    move_offer_first_accept = { 
        source = "string",
    },

    move_offer_final_accept = { },

    move_offer_info_show = { 
        new_hard_sum = "number",
        new_soft_sum = "number",
    },

    move_offer_new_server_login_first = { 
        final_hard_sum = "number",
        final_soft_sum = "number",
    },

    fuel_purchase = { 
        cost         = "number",
        amount       = "number",
        vehicle_name = "string",
        vehicle_id   = "number",
    },

    repair_purchase = { 
        cost           = "number",
        vehicle_name   = "string",
        vehicle_id     = "number",
    },

    vehicle_evacuation = { 
        cost         = "number",
        vehicle_name = "string",
        vehicle_id   = "number",
    },

    lite_start_costs_test = {
        is_test = "string",
    }, 

    faction_join = {
        name                    = "string",
        time_from_install       = "number",
        time_in_game            = "number",
        join_num                = "number",
        count                   = "number",
    },

    faction_left = {
        name                    = "string",
        faction_id              = "number",
        rank_num                = "number",
        time_from_install       = "number",
        time_since_join         = "number",
        time_since_join_in_game = "number",
        count_member            = "number",
        reason                  = "string",
    },

    faction_day_off = {
        faction_id      = "number",
        days_off_count  = "number",
    },

    faction_day_off_deny = {
        faction_id              = "number",
        days_off_passed_count   = "number",
        days_off_count          = "number",
    },

    quest_start = {
        name         = "string",
        id           = "string",
        try_num      = "number",
        current_lvl  = "number",
    },

    quest_finish = {
        name               = "string",
        id                 = "string",
        reward_id          = "string",
        reward_sum_soft    = "number",
        reward_sum_hard    = "number",
        reward_sum_exp     = "number",
        current_lvl        = "number",
        try_num            = "number",
        time_to_finish     = "number",
        finish_reason      = "string",
        finish_reason_text = "string",
    },

    quest_fail = {
        name         = "string",
        id           = "string",
        try_num      = "number",
        time_in_game = "number",
        time_to_fail = "number",
    },

    quest_complete = {
        name             = "string",
        id               = "string",
        try_num          = "number",
        time_in_game     = "number",
        time_to_complete = "number",
        test_group       = "string",
    },

    daily_quest_complete = {
        num                = "number",
        daily_quest_id     = "number",
        daily_quest_name   = "string",
        test_group         = "string",
        reward_sum         = "number",
        currency           = "string",
    },

    daily_present_get = {
        daily_num      = "number",
        present_choice = "number",
        prem           = "string",
        test_group     = "string",
    },

    global_event_start = {
        event_id		= "string",
        lobby_id		= "string",
        lobby_type		= "string",
    },

    global_event_participation = {
		event_id					= "string",
		lobby_id				    = "string",
        lobby_type					= "string",
		is_winner			        = "string",
		is_booster			        = "string",
		is_alive		            = "string",
		match_start			        = "number",
        match_finish	            = "number",
        reward_sum                  = "number",
    },

    global_event_item_purchase = {
		event_id			= "string",
		item_id				= "string",
		item_name			= "string",
		item_type			= "string",
        item_cost		    = "number",
        currency		    = "string",
        item_quantity		= "number",
        spend_sum		    = "number",
    },

    global_event_booster_purchase = {
		event_id			= "string",
		booster_id   		= "string",
		booster_name		= "string",
        booster_cost	    = "number",
        currency		    = "string",
        booster_qauntity	= "number",
        spend_sum		    = "number",
    },

    daily_quest_up_casino = {
		is_test = "string",
    },

    quest_casino_complete = {
		game_id		= "number",
		game_name	= "string",
		bet_sum	    = "number",
        currency	= "string",
        winner		= "string",
        new_balance	= "number",
    },

    police_car_mark = {
		officer_rank			= "string",
		car_name				= "string",
		car_id					= "number",
        car_marks_today_num		= "number",
        car_marks_total_count 	= "number",
    },

    call_ride = {
		faction_name		    = "string",
		faction_id			    = "number",
		officer_name			= "string",
		officer_rank			= "string",
        call_ride_today_num		= "number",
        call_ride_today_count	= "number",
        call_ride_total_count 	= "number",
    },

    call_ride_reward = {
		faction_name		    = "string",
		faction_id			    = "number",
		officer_name			= "string",
		officer_rank			= "string",
        reward_id		        = "string",
        reward_count	        = "number",
        t_from_last_in_game 	= "number",
    },

    faction_quest_complete = {
		faction_name		        = "string",
		faction_id			        = "number",
		officer_name			    = "string",
		officer_rank			    = "string",
        quest_id		            = "string",
        quest_complete_today_count	= "number",
        quest_complete_total_count 	= "number",
        t_to_complete_sec           = "number",
    },

    faction_quest_fail = {
		faction_name		= "string",
		faction_id			= "number",
		officer_name		= "string",
		officer_rank		= "string",
        quest_id		    = "string",
        t_to_fail_sec	    = "number",
    },

    quest_series_reward = {
		faction_name		    = "string",
		faction_id			    = "number",
		officer_name		    = "string",
		officer_rank		    = "string",
        reward_id		        = "string",
        reward_count	        = "number",
        t_from_last_in_game	    = "number",
        quest_1_id              = "string",
        quest_2_id              = "string",
        quest_3_id              = "string",
        quest_4_id              = "string",
        quest_5_id              = "string",
    },

    exercise_reward = {
		faction_name		    = "string",
		faction_id			    = "number",
		officer_name		    = "string",
		officer_rank		    = "string",
        reward_id		        = "string",
        reward_count	        = "number",
        t_from_last_in_game	    = "number",
        exercise_1_id           = "string",
        exercise_2_id           = "string",
        exercise_3_id           = "string",
    },

    businesses_offer = {
		player_group_id = "number",
    },

    business_offer_purchase = {
		player_group_id	= "number",
		business_type	= "string",
		business_id	    = "string",
        cost			= "number",
        currency		= "string",
    },
    [ "11d_offer_x2_is_test" ] = {
		is_test		= "string",
    },

    [ "11d_offer_x2_show_first" ] = {
    },

    [ "11d_offer_x2_purchase" ] = {
		cost		= "number",
    },

    strip_dance_purchase = {
		is_podium  = "string",
		is_private = "string",
        model_num  = "number",
        cost       = "number",
        currency   = "string",
    },

    strip_drink_purchase = {
		name	 = "string",
		cost	 = "number",
		currency = "string",
    },

    marry_offer = {
        step = "number",
        count = "number",
    },

    f4_service_purchase = {
        item = "string",
        cost = "number"
    },

    divorce_make = {
		count = "number",
    },

    gift_purchase = {
        id =        "number",
        name =      "string",
        cost =      "number",
        currency =  "string",
    },

    --------------------------------------------------------

    admin_salary_income = {
        admin_name = "string",
        access_level = "number",
        position_name = "string",
        sum = "number",
        currency = "string",
    },
    
    admin_salary_income_take = {
        sum = "number",
        currency = "string",
    },
    
    admin_achive_reward = {
        admin_name = "string",
        achievement_num = "number",
        sum = "number",
        currency = "string",
    },
    
    admins_event_join = {
        player_name = "string",
        admin_event_name = "string",
    },
    
    admins_event_activate = {
        admin_name = "string",
        admin_event_name = "string",
        max_count = "number",
    },
    
    admins_event_reward_give = {
        admin_name = "string",
        sum = "number",
        currency = "string",
        target_player_client_id = "string",
    },
    
    admin_event_reward_take = {
        player_name = "string",
        sum = "number",
        currency = "string",
    },
    
    admin_duty_end = {
        duration_time = "number",
    },
    
    player_admin_report_rate = {
        admin_client_id = "string",
        admin_name = "string",
        rating = "number",
    },
    
    admin_report_close = {
        admin_name = "string",
    },

    lobby_race_enter = {
        race_type = "string",
		count     = "number",
		car_id    = "number",
        car_name  = "string",
        car_class = "number",
    },

    race_finish = { 
        racers_num  = "number", 
        prize_cost  = "number", 
        prize_name  = "string",
        car_id      = "number", 
        car_name    = "string",
        car_class   = "number", 
        is_winner   = "string",
        race_time   = "number",
        position    = "number",
        count_point = "number",
        race_type   = "string",
    },

    race_start = {
        racers_num = "number",
        car_id     = "number",
        car_name   = "string",
    	car_class  = "number",
    	race_type  = "string",
    },

    sessons_race_win = { 
        id          = "number",
        name        = "string",
        reward_id   = "string",
        reward_cost = "number",
        currency    = "string",
        car_id      = "number",
        car_name    = "string",
        car_class   = "number",
        race_type   = "string",
    },

    drag_racing_finish = {
        car_id          = "number",
        car_name        = "string",
        car_class       = "number",
        race_duration   = "number",
        bet_amount      = "number",
        win_sum         = "number",
        prize_name      = "string",
        finish_place    = "number",
        drag_count      = "number",
        drag_call_count = "number",
        drag_take_count = "number",
    },

    drag_racing_start =
    {
        car_id          = "number",
        car_class       = "number",
        car_name        = "string",
        bet_amount      = "number",
        drag_count      = "number",
        drag_call_count = "number",
        drag_take_count = "number",
    },

    tuning_cart_items = {
        items = "string",
    },

    f4_special_purchase = { 
        item_id = "string",
        cost    = "number",
        segment = "number",
        item_type = "string",
        item_name = "string",
        currency  = "string",
    },

    --------------------------------------------------------
    
    ill_get = {
        ill_id = "number",
        ill_name = "string",
    },
    
    ill_stage_up = {
        ill_id = "number",
        ill_name = "string",
        ill_stage = "number",
    },
    
    ill_stage_down = {
        ill_id = "number",
        ill_name = "string",
        ill_stage = "number",
    },



    mortage_status = {
        mortage_id_1_total_count = "number",
        mortage_id_1_total_cost  = "number",
        mortage_id_1_free_count  = "number",
        mortage_id_1_free_cost   = "number",

        mortage_id_2_total_count = "number",
        mortage_id_2_total_cost  = "number",
        mortage_id_2_free_count  = "number",
        mortage_id_2_free_cost   = "number",

        mortage_id_3_total_count = "number",
        mortage_id_3_total_cost  = "number",
        mortage_id_3_free_count  = "number",
        mortage_id_3_free_cost   = "number",

        mortage_id_4_total_count = "number",
        mortage_id_4_total_cost  = "number",
        mortage_id_4_free_count  = "number",
        mortage_id_4_free_cost   = "number",

        mortage_id_5_total_count = "number",
        mortage_id_5_total_cost  = "number",
        mortage_id_5_free_count  = "number",
        mortage_id_5_free_cost   = "number",

        mortage_id_6_total_count = "number",
        mortage_id_6_total_cost  = "number",
        mortage_id_6_free_count  = "number",
        mortage_id_6_free_cost   = "number",

        mortage_id_7_total_count = "number",
        mortage_id_7_total_cost  = "number",
        mortage_id_7_free_count  = "number",
        mortage_id_7_free_cost   = "number",

        mortage_id_8_total_count = "number",
        mortage_id_8_total_cost  = "number",
        mortage_id_8_free_count  = "number",
        mortage_id_8_free_cost   = "number",

        mortage_id_9_total_count = "number",
        mortage_id_9_total_cost  = "number",
        mortage_id_9_free_count  = "number",
        mortage_id_9_free_cost   = "number",

        mortage_id_10_total_count = "number",
        mortage_id_10_total_cost  = "number",
        mortage_id_10_free_count  = "number",
        mortage_id_10_free_cost   = "number",

        mortage_id_11_total_count = "number",
        mortage_id_11_total_cost  = "number",
        mortage_id_11_free_count  = "number",
        mortage_id_11_free_cost   = "number",

        mortage_id_12_total_count = "number",
        mortage_id_12_total_cost  = "number",
        mortage_id_12_free_count  = "number",
        mortage_id_12_free_cost   = "number",
	},
	
	
	--Offers

	show_offer_convert_donate = { 
		cost   		= "number",
		name        = "string",
		place       = "string",
	},
	offer_convert_donate = { 
		cost    	= "number",
		name        = "string",
		place       = "string",
	},
	show_offer_give_donate = {
		name 		= "string",
		place 		= "string",
	},
	offer_give_donate = {
		name 		= "string",
		place 		= "string",
	},
	show_offer_slot = { 
		name        = "string",
	},
	click_slot_purchase = { 
		name        = "string",
	},

    case_notification_show = { },
    business_shop_office_purchase =
    {
        cost = "number",
        type  = "string",
        lose = "string",
    },
    business_shop_item_purchase =
    {
        cost = "number",
        type  = "string",
    },

    ----

    whale_offer_show_first = { },

    whale_offer_purchase = {
        vehicle_id = "number",
        vehicle_name = "string",
        vehicle_cost = "number",
        quantity = "number",
        currency  = "string",
        spend_sum  = "number",
        stage_num = "number",
    },


    --------------------------------------------------------

    gun_shop_purchase = {
        client_id        = "string",
        cart_total_cost  = "number",
        currency         = "string",
        cart_items_total = "number",
        cart_items       = "string"
    },

    --------------------------------------------------------
    
    clan_creation = {
        clan_id       = "number",
        clan_name     = "string",
        clan_type     = "string",
        logo_id       = "number",
        clan_location = "string",
        creation_cost = "number",
    },
    
    clan_join = {
        clan_id            = "number",
        clan_name          = "string",
        clan_creation_date = "number",
        clan_money         = "number",
        clan_join_status   = "string",
        clan_honor_points  = "number",
        clan_lb_points     = "number",
        clan_lb_position   = "number",
        self_join          = "string",
    },
    
    clan_leave = {
        clan_id      = "number",
        clan_name    = "string",
        leave_status = "number",
        clan_rank    = "number",
        clan_role    = "number",
    },
    
    clan_money_income = {
        clan_id            = "number",
        clan_name          = "string",
        clan_members_num   = "number",
        income_sum         = "number",
        clan_money         = "number",
    },
    
    clan_points = {
        clan_rank        = "number",
        clan_rank_exp    = "number",
        clan_id          = "number",
        clan_name        = "string",
        clan_lb_points   = "number",
        clan_lb_position = "number",
        season_num       = "number",
        points_income    = "number",
        points_lb_income = "number",
        points_type      = "string",
        event_name       = "string",
    },
    
    clan_money_spend = {
        clan_id          = "number",
        clan_name        = "string",
        clan_members_num = "number",
        spend_sum        = "number",
        spend_type       = "string",
        item_name        = "string",
    },
    
    clan_match_end = {
        client_id         = "nil",
        clan_id           = "number",
        clan_name         = "string",
        match_type        = "string",
        match_win         = "string",
        match_duration    = "number",
        clan_money_reward = "number",
        clan_honor_reward = "number",
        clan_kill_count   = "number",
        clan_death_count  = "number",
        outmap_death      = "number",
        leave_count       = "number",
    },
    
    clan_event_start = {
        clan_id            = "number",
        clan_name          = "string",
        clan_members_count = "number",
        teleported_from    = "number",
        reg_duration       = "number",
        reg_cancel_count   = "number",
    },
    
    clan_tax_request = {
        client_id             = "nil",
        clan_id               = "number",
        clan_name             = "string",
        tax_decision_duration = "number",
        tax_decision          = "number",
        cartel_id             = "number",
        cartel_clan_name      = "string",
        tax_sum               = "number",
        clan_money_before     = "number",
        clan_money_after      = "number",
        cartel_money_before   = "number",
        cartel_money_after    = "number",
    },
    
    cartel_clan_money_war = {
        client_id             = "nil",
        clan_id               = "number",
        clan_name             = "string",
        clan_money            = "number",
        cartel_id             = "number",
        cartel_clan_name      = "string",
    },

    cartel_clan_money_war_end = {
        client_id           = "nil",
        clan_id             = "number",
        clan_name           = "string",
        cartel_id           = "number",
        cartel_clan_name    = "string",
        cartel_win          = "string",
        tax_sum             = "number",
        clan_money_before   = "number",
        clan_money_after    = "number",
        cartel_money_before = "number",
        cartel_money_after  = "number",
        match_score         = "string",
        match_duration      = "number",
        leave_count         = "number",
    },

    cartel_house_war_end = {
        client_id           = "nil",
        clan_id             = "number",
        clan_name           = "string",
        cartel_id           = "number",
        cartel_clan_name    = "string",
        cartel_win          = "string",
        match_score         = "string",
        match_duration      = "number",
        leave_count         = "number",
        reg_count_cartel    = "number",
        reg_count_clan      = "number",
    },

    clan_lb_season_track = {
        client_id          = "nil",
        clan_id            = "number",
        clan_name          = "string",
        clan_money         = "number",
        clan_honor_points  = "number",
        clan_lb_points     = "number",
        clan_lb_position   = "number",
        clan_member_limit  = "number",
        clan_member_count  = "number",
        season_num         = "number",
        clan_join_count    = "number",
        clan_leave_count   = "number",
        clan_creation_date = "number",
    },

    car_notpay_offer_show_first = {},

    car_notpay_offer_purchase =
    {
        vehicle_id    = "number",
        vehicle_name  = "string",
        vehicle_cost  = "number",
        vehicle_class = "number",
        currency      = "string",
        quantity      = "number",
        spend_sum     = "number",
    },

	--------------------------------------------------------
	
	[ "64hr_no_case_purchase_24hr_offer_is_test" ] = {
        test_group_name  = "string",
	},
	
	[ "64hr_no_case_pack_offer_show_first" ] = { },

	[ "64hr_no_case_pack_offer_purchase" ] = {
        pack_id		= "number",
        pack_name	= "string",
        cost_pack	= "number",
        spend_sum   = "number",
        quantity    = "number",
        currency	= "string",
	},
	
	[ "64hr_no_case_gift_offer_show_first" ] = { },

	[ "64hr_no_case_gift_offer_open" ] = { },
	
	----------------------------------------------------------
	--В кавычках делаем ключ, ибо нельзя чтобы переменная начиналась с цифр
    [ "3rd_payment_offer_show_first" ] =  { },

    [ "3rd_payment_offer_purchase" ] = 
    {
		pack_id 	= "number",
		pack_name 	= "string",
        pack_cost 	= "number",
        quantity    = "number",
        spend_sum   = "number",
		currency 	= "string",
	},

	--------------------------------------------------------

    ac_job_time = {
        task_id             = "string",
        time_to_complete    = "number",
        current_lvl         = "number",
    },  
    
    promocode_enter = 
    {
        promocode_id   = "string",
        promocode_type = "string",
        reward_id      = "string",
        receive_sum    = "number",
        currency       = "string",
    },

    towtrucker_job_start = 
    {
        lobby_id         = "number",
        current_lvl      = "number",
        job_role         = "string",
        is_lobby_creator = "string",
        players_quantity = "number",
        search_duration  = "number",
    },
    
    towtrucker_job_finish =
    {
        lobby_id     = "number",
        players_num  = "number",
        job_duration = "number",
        cars_num     = "number",
        receive_sum  = "number",
        currency     = "string",
        exp_sum      = "number",
    },

    towtrucker_job_voyage =
    {
        lobby_id         = "number",
        current_lvl      = "number",
        players_quantity = "number",
        job_duration     = "number",
        evac_type        = "string",
        receive_sum      = "number",
        currency         = "string",
        exp_sum          = "number",
    },

    trucker_job_start =
    {
        company_num  = "number",
        shift_id     = "string",
        current_lvl  = "number",
        type_trucker = "string",
    },

    trucker_job_finish_voyage =
    {
        shift_id     = "string",
        company_num  = "number",
        current_lvl  = "number",
        job_duration = "number",
        receive_sum  = "number",
        currency     = "string",
        exp_sum      = "number",
    },

    trucker_job_finish =
    {
        shift_id       = "string",
        current_lvl    = "number",
        company_num    = "number",
        type_trucker   = "string",
        job_duration   = "number",
        receive_sum    = "number",
        currency       = "string",
        exp_sum        = "number",
        finish_reason  = "string",
        is_voyage_fail = "string",
    },

    incasator_job_start =
    {
        lobby_id         = "number",
        current_lvl      = "number",
        job_role         = "string",
        is_lobby_creator = "string",
        players_quantity = "number",
        search_duration  = "number",
    },

    incasator_job_finish =
    {
        lobby_id         = "number",
        current_lvl      = "number",
        players_quantity = "number",
        job_duration     = "number",
        bag_quantity     = "number",
        receive_sum      = "number",
        currency         = "string",
        finish_reason    = "string",
        exp_sum          = "number",
    },

    incasator_job_finish_voyage =
    {
        lobby_id         = "number",
        current_lvl      = "number",
        players_quantity = "number",
        job_duration     = "number",
        receive_sum      = "number",
        currency         = "string",
        exp_sum          = "number",
    },

    incasator_job_call_police = 
    {
        lobby_id    = "number",
        current_lvl = "number",
    },

    incasator_job_police_accepted = 
    {
        lobby_id    = "number",
        current_lvl = "number",
    },

    incasator_job_not_protect = 
    {
        lobby_id    = "number",
        current_lvl = "number",
    },

    incasator_job_damage_protect =
    {
        lobby_id    = "number",
        current_lvl = "number",
        player_id   = "string",
        gun_id      = "number",
        gun_name    = "string",
        is_dead     = "string",
    },
    
    delivery_cars_job_start = 
    {
        lobby_id         = "number",
        current_lvl      = "number",
        job_role         = "string",
        is_lobby_creator = "string",
        players_quantity = "number",
        search_duration  = "number",
    },

    delivery_cars_job_voyage =
    {
        lobby_id         = "number",
        current_lvl      = "number",
        vehicle_id       = "number",
        vehicle_name     = "string",
        vehicle_class    = "number",
        players_quantity = "number",
        count_speak      = "number",
        count_sms        = "number",
        job_role         = "string",
        job_duration     = "number",
        receive_sum      = "number",
        currency         = "string",
        exp_sum          = "number",
    },

    delivery_cars_job_finish =
    {
        lobby_id      = "number",
        current_lvl   = "number",
        job_duration  = "number",
        vehicle_count = "number",
        finish_reason = "string",
        receive_sum   = "number",
        currency      = "string",
        exp_sum       = "number",
    },

    job_start = 
    {
        id           = "string",
        name         = "string",
        current_lvl  = "number",
    },

    job_voyage =
    {
        id           = "string",
        name         = "string",
        current_lvl  = "number",
        job_duration = "number",
        receive_sum  = "number",
        currency     = "string",
        exp_sum      = "number",
    },

    job_finish =
    {
        id            = "string",
        name          = "string",
        current_lvl   = "number",
        receive_sum   = "number",
        currency      = "string",
        exp_sum       = "number",
        job_duration  = "number",
        finish_reason = "string",
    },

    f4_premium_purchase =
    {
        duration  = "number",
        cost      = "number",
        gift      = "string",
        is_exten = "string",
    },

	-- F4 Research
	f4r_f4_key_press = { },
	f4r_f4_tab_click = { tab = "string" },
	f4r_f4_main_icon_click = { main_icon = "string" },
	f4r_f4_main_slider_click = { main_slider = "string" },
	f4r_f4_3points_click = { },
	f4r_f4_currency_link_click = { },
	f4r_f4_3points_menu_click = { menu = "string" },
	f4r_f1_update_click = { link = "string" },
	f4r_phone_wof_icon_click = { },
	f4r_auto_showroom_slot_purchase_button_click = { },
	f4r_not_enough_slots_window_click = { },
	f4r_popup_click = { link = "string", source = "string" },
	f4r_wof_icon_click = { icon = "string" },
	f4r_wof_tab_click = { tab = "string" },
	f4r_f4_wof_spin_purchase_button_click = { wof_class = "string" },
	f4r_f4_wof_spin_button_click = { wof_class = "string" },
	f4r_f4_wof_spin_success = { wof_class = "string" },
	f4r_f4_refferals_details_click = { },
	f4r_f4_refferals_code_activate_button_click = { },
	f4r_f4_refferals_code_activate_success = { },
	f4r_f4_refferals_reward_button_click = { },
	f4r_f4_refferals_reward_take_success = { },
	f4r_f4_services_purchase_button_click = { service = "string" },
	f4r_f4_services_purchase = { service = "string" },
	f4r_f4_cases_case_click = { },
	f4r_f4_cases_purchase_button_click = { },
	f4r_f4_cases_purchase = { },
	f4r_f4_unique_auto_details_click = { },
	f4r_f4_unique_auto_purchase_button_click = { },
	f4r_f4_unique_auto_confirmation_ok_click = { },
	f4r_f4_unique_auto_purchase = { },
	f4r_f4_unique_auto_accessory_purchase_button_click = { },
	f4r_f4_unique_auto_accessory_choose_auto_click = { },
	f4r_f4_unique_auto_accessory_confirmation_ok_click = { },
	f4r_f4_unique_auto_accessory_purchase = { },
	f4r_f4_unique_accessory_purchase_button_click = { },
	f4r_f4_unique_accessory_confirmation_ok_click = { },
	f4r_f4_unique_accessory_purchase = { },
	f4r_f4_premium_choose_icon_click = { },
	f4r_f4_premium_purchase_button_click = { },
	f4r_f4_premium_purchase = { },
	f4r_f4_premium_present_icon_click = { },
	f4r_f4_premium_present_button_click = { },
	f4r_f4_promo_mark_on_map_click = { },
	f4r_f4_currency_deposit_button_click = { button = "string", hard = "number" },
	f4r_f4_currency_deposit_success = { },
	f4r_f4_currency_exchange_button_click = { },
    f4r_currency_deposit_button_click = { from = "string" },
    
    license_gun_offer_show_first = {},

    license_gun_offer_purchase = 
    {
        license_cost = "number",
        quantity     = "number",
        spend_sum    = "number",
        currency     = "string",
    },
    
    tuning_neon_purchase = {
        id_neon = "string",
        name_neon = "string",
        cost_neon = "number",
        quantity = "number",
        spend_sum = "number",
        currency = "string",
    },

    tuning_neon_sell = {
        id_neon = "string",
        name_neon = "string",
        cost_neon = "number",
        quantity = "number",
        receive_sum = "number",
        currency = "string",
    },

    health_care_purchase = {
        cost = "number",
        currency = "string",
        ill_id = "string",
        ill_name = "string",
    },

    double_mayhem_purchase = {
        pack_id      = "string",
        pack_cost    = "number",
        is_take_gift = "string",
        id_reward    = "string",
        reward_cost  = "number",
        currency     = "string",
    },


    casino_slot_chicago_start =
    {
        casino_name  = "string",
		unic_game_id = "string",
		current_lvl  = "number",
		game_type    = "string",
    },

    casino_slot_chicago_leave =
    {
    	unic_game_id 	= "string",
		current_lvl 	= "number",
		bet_sum 		= "number",
		reward_sum 		= "number",
		lost_sum 	  	= "number",
		lost_count_bet 	= "number",
		win_count_bet  	= "number",
		currency 		= "string",
		game_duration 	= "number",
		leave_reason 	= "string",
    },

    casino_slot_valhalla_start =
    {
        casino_name  = "string",
		unic_game_id = "string",
		current_lvl  = "number",
		game_type    = "string",
    },

    casino_slot_valhalla_leave =
    {
    	unic_game_id 	= "string",
		current_lvl 	= "number",
		bet_sum 		= "number",
		reward_sum 		= "number",
		lost_sum 	  	= "number",
		lost_count_bet 	= "number",
		win_count_bet  	= "number",
		currency 		= "string",
		game_duration 	= "number",
		leave_reason 	= "string",
    },

    casino_slot_gold_skull_start =
    {
        casino_name  = "string",
		unic_game_id = "string",
		current_lvl  = "number",
		game_type    = "string",
    },

    casino_slot_gold_skull_leave =
    {
    	unic_game_id 	= "string",
		current_lvl 	= "number",
		bet_sum 		= "number",
		reward_sum 		= "number",
		lost_sum 	  	= "number",
		lost_count_bet 	= "number",
		win_count_bet  	= "number",
		currency 		= "string",
		game_duration 	= "number",
		leave_reason 	= "string",
    },

    casino_bone_start =
    {
        casino_name  = "string",
        unic_game_id = "string",
        current_lvl  = "number",
        game_type    = "string",
    },

    casino_bone_leave =
    {
        unic_game_id    = "string",
        current_lvl     = "number",
        player_quantity = "number",
        commision_sum   = "number",
        bet_sum         = "number",
        reward_sum      = "number",
        currency        = "string",
        is_create       = "string",
        is_win          = "string",
        game_duration   = "number",
        leave_reason    = "string",
    },

    casino_rusroulette_start =
    {
        casino_name  = "string",
        unic_game_id = "string",
        current_lvl  = "number",
        game_type    = "string",
    },

    casino_rusroulette_leave =
    {
        unic_game_id    = "string",
        current_lvl     = "number",
        player_quantity = "number",
        commision_sum   = "number",
        bet_sum         = "number",
        reward_sum      = "number",
        currency        = "string",
        is_create       = "string",
        is_win          = "string",
        game_duration   = "number",
        leave_reason    = "string",
    },

    casino_blackjack_start =
    {
        casino_name  = "string",
        unic_game_id = "string",
        current_lvl  = "number",
        game_type    = "string",
    },

    casino_blackjack_leave =
    {
        unic_game_id    = "string",
        current_lvl     = "number",
        player_quantity = "number",
        bet_sum         = "number",
        reward_sum      = "number",
        lost_sum        = "number",
        lost_count_bet  = "number",
        win_count_bet   = "number",
        currency        = "string",
        game_duration   = "number",
        leave_reason    = "string",
    },

    casino_roulette_start =
    {
        casino_name  = "string",
        unic_game_id = "string",
        current_lvl  = "number",
        game_type    = "string",
        type         = "string",
        currency     = "string",
    },

    casino_roulette_leave =
    {
        unic_game_id    = "string",
        current_lvl     = "number",
        player_quantity = "number",
        bet_sum         = "number",
        reward_sum      = "number",
        lost_sum        = "number",
        lost_count_bet  = "number",
        win_count_bet   = "number",
        currency        = "string",
        game_duration   = "number",
        leave_reason    = "string",
    },
    flag_change_purchase =
    {
        cost          = "number",
        currency      = "string",
        vehicle_id    = "number",
        vehicle_class = "string",
        vehicle_name  = "string",
        current_flag  = "string",
        new_flag      = "string",
    },

    last_riches_hard_purchase =
    {
        multiplier_num  = "number",
        spend_sum       = "number",
        give_hard_sum   = "number",
        currency        = "string",
        task_count      = "number",
        task_compliting = "number",
        task_id         = "string",
    },

    last_riches_task_complete =
    {
        step_num       = "number",
        multiplier_num = "number",
        task_id        = "string",
    },

    assembly_vehicle_take =
    {
        part_name    = "string",
        place_name   = "string",
        part_num     = "number",
    },

    assembly_vehicle_finish =
    {
        vehicle_id    = "string",
        vehicle_name  = "string",
        vehicle_cost  = "number",
    },

    assembly_vehicle_purchase =
    {
        part_count    = "number",
        spend_sum     = "number",
    },

    fc_win = {
        commision_sum = "number",
        reward_sum    = "number",
        currency      = "string",
    },

    fc_tournament_win = {
        reward_sum = "number",
        currency   = "string",
    },

    fc_bet = {
        bet_sum    = "number",
        fighter_id = "string",
        is_win     = "string",
        reward_sum = "number",
        currency   = "string",
    },

    christmas_auction_showfirst = {},

    christmas_auction_bet =
    {
        bet_sum    = "number",
        bet_num    = "number",
        bet_paid   = "number",
        currency   = "string",
    },

    christmas_auction_finish =
    {
        bet_sum    = "number",
        is_bet_won = "string",
        currency   = "string",
    },
    last_riches_hard_purchase =
    {
        multiplier_num  = "number",
        spend_sum       = "number",
        give_hard_sum   = "number",
        currency        = "string",
        task_count      = "number",
        task_compliting = "number",
        task_id         = "string",
    },

    last_riches_task_complete =
    {
        step_num       = "number",
        multiplier_num = "number",
        task_id        = "string",
    },


    global_draw_inparty =
    {
        draw_name   = "string",
        current_lvl = "number",
    },

    global_draw_take_ticket =
    {
        nickname    = "string",
        draw_name   = "string",
        ticket_num  = "number",
        current_lvl = "number",
    },

    global_draw_contact = 
    {
        type_contact = "string",
        contact      = "string",
    },

    valentine_day_offer_show_first = { },

    valentine_day_segment_change =
    {
        segment_num = "number",
    },

    valentine_day_offer_purchase =
    {
        id          = "string",
        name        = "string",
        cost        = "number",
        currency    = "string",
        spend_sum   = "number",
        quantity    = "number",
        reward      = "string",
        segment_num = "number",
    },

    skin_15offer_show_first = { },

    skin_15offer_offer_purchase = {
        skin_id     = "number",
        skin_name   = "string",
        skin_cost   = "number",
        quantity    = "number",
        currency    = "string",
        spend_sum   = "number",
    },

    mortage_20_offer_first = { },

    mortage_20_offer_purchase = {
        mortage_id     	= "number",
        mortage_group   = "number",
        mortage_type    = "string",
        mortage_cost    = "number",
        quantity        = "number",
        spend           = "number",
        spend_sum       = "number",
        currency 		= "string",
    },

    first_weapon_offer_show_first = { },

    first_weapon_offer_purchase = {
        id          = "string",
        name        = "string",
        cost        = "number",
        currency    = "string",
        quantity    = "number",
        spend_sum   = "number",
    },

    wof_purchase =
    {
        type      = "string",
        cost      = "number",
        quantity  = "number",
        spend_sum = "number",
        currency  = "string",
    },

    wof_reward =
    {
        type        = "string",
        type_reward = "string",
        name_reward = "string",
        id_reward   = "string",
        bonus_coef  = "number",
        quantity    = "number",
        receive_sum = "number",
        currency    = "string",
        points_num  = "number",
    },

    wof_progression_reward =
    {
        type        = "string",
        name_reward = "string",
        id_reward   = "string",
        type_reward = "string",
    },

    wof_progression =
    {
        type           = "string",
        points_num     = "number",
        points_receive = "number",
    },

    offer_pack_gun_segment_change = {
        segment_num = "number",
    },

    offer_pack_gun_showfirst = { },

    achievement_complete = {
        achieve_id      = "string",
        achieve_name    = "string",
        achieve_lvl     = "number",
        reward_id       = "nil",
        reward_cost     = "number",
        currency        = "string",
    },

    achievement_share = {
        achieve_count   = "number",
        player_id       = "string",
    },

    achievement_look = {
        achieve_count   = "number",
        player_id       = "string",
    },

    more_donate_pack_offer_show_first = { },

    locked_donate_pack_offer_show_first = { },

    limited_donate_pack_offer_show_first = { },

    more_donate_pack_offer_purchase = {
        id          = "string",
        name        = "string",
        cost        = "number",
        hard_sum    = "number",
        currency    = "string",
        quantity    = "number",
        spend_sum   = "number",
    },

    locked_donate_pack_offer_purchase = {
        id          = "string",
        name        = "string",
        cost        = "number",
        hard_sum    = "number",
        currency    = "string",
        quantity    = "number",
        spend_sum   = "number",
    },

    limited_donate_pack_offer_purchase = {
        id          = "string",
        name        = "string",
        cost        = "number",
        hard_sum    = "number",
        currency    = "string",
        quantity    = "number",
        spend_sum   = "number",
    },

    defender_day_offer_show_first = { },

    defender_day_segment_change =
    {
        segment_num = "number",
    },

    defender_day_offer_purchase =
    {
        id          = "string",
        name        = "string",
        cost        = "number",
        currency    = "string",
        spend_sum   = "number",
        quantity    = "number",
        reward      = "string",
        segment_num = "number",
    },

    donate_offer_discount_showfirst = { },

    donate_offer_discount_purchase = 
    { 
        id            = "string",
        cost          = "number",
        value_sum     = "number",
        currency      = "string",
        discount_data = "string",
    },

    mortage_offer_show_first = { },

    mortage_offer_purchase = {
        mortage_type    = "string",
        mortage_id      = "number",
        cost            = "number",
        currency        = "string",
    },

    faction_income = {
        faction_id      = "string",
        rank_num        = "number",
        exp_sum         = "number",
        receive_sum     = "number",
        currency        = "string",
    },

    faction_quest_take = {
        faction_id      = "string",
        quest_id        = "string",
        rank_num        = "number",
    },

    faction_quest_finish = {
        faction_id      = "string",
        quest_id        = "string",
        rank_num        = "number",
        exp_sum         = "number",
        is_complete     = "string",
    },

    fast_offer_show_first = {
        name        = "string",
    },

    fast_offer_purchase = {
        id          = "string",
        cost        = "number",
        currency    = "string",
        reward      = "string",
    },

    offer_piggy_bank_showfirst = { },

    offer_piggy_bank_purchase = {
        sum_soft    = "number",
        cost        = "number",
        quantity    = "number",
        currency    = "string",
    },

    tuning_kit_show_first = { },

    tuning_kit_purchase = {
        id          = "number",
        name        = "string",
        cost        = "number",
        currency    = "string",
        true_cost   = "number",
        items       = "string",
    },
}
