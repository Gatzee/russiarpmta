-- Server --

EVENT_PATTERNS_SERVER = {
    start                         = "$id_start",
    stop                          = "$id_stop",
    step_next                     = "$id_next",
    call_client_function_callback = "$id_call_server_fn",
    call_server_function_callback = "$id_call_client_fn",
}

FN_PATTERNS_CONVERSION_SERVER = {
    start = "StartActionTask",
    stop  = "StopActionTask",

    call_client_function          = "CallClientFunction",
    call_server_function_callback = "CallServerFunction_callback",

    step_next  = "NextStep",
    step_start = "StartStep",
}

-- Client --

EVENT_PATTERNS_CLIENT = {
    start = "$id_start",
    stop  = "$id_stop",

    step_cleanup = "$id_step_cleanup",
    step_setup   = "$id_step_setup",

    call_client_function_callback = "$id_call_server_fn",
    call_server_function_callback = "$id_call_client_fn",
}

FN_PATTERNS_CONVERSION_CLIENT = {
    start = "StartActionTask",
    stop  = "StopActionTask",

    call_server_function          = "CallServerFunction",
    call_client_function_callback = "CallClientFunction_callback",

    step_cleanup = "CleanupStep",
    step_setup   = "SetupStep",
}