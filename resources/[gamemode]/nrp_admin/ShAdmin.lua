MAX_WORKED_TIME_IN_DAY = 8 * 60 * 60 + 240

ADMIN_PAYOUT_INFO = {
	[ ACCESS_LEVEL_INTERN ] =			{ value = 26, period = "hour" },
	[ ACCESS_LEVEL_HELPER ] =			{ value = 50, period = "hour" },
	[ ACCESS_LEVEL_SENIOR_HELPER ] =	{ value = 56, period = "hour" },
	[ ACCESS_LEVEL_MODERATOR ] =		{ value = 62, period = "hour" },
	[ ACCESS_LEVEL_SENIOR_MODERATOR ] =	{ value = 68, period = "hour" },
	[ ACCESS_LEVEL_ADMIN ] =			{ value = 75, period = "hour" },
	[ ACCESS_LEVEL_SENIOR_ADMIN ] =		{ value = 81, period = "hour" },
	[ ACCESS_LEVEL_GAME_MASTER ] =		{ value = 87, period = "hour" },
}

CONST_MAX_REWARDS_SUM = 300000
CONST_MAX_PLAYER_REWARD = 50000

enum "eTasksTypes" {
	"ADMIN_TASK_WORKED_TIME",
	"ADMIN_TASK_REPORTS",
}

TASKS_INFO = {
	{ 
		type = ADMIN_TASK_WORKED_TIME,
		text = "Отработать 4 часа за сутки", 
		need_value = 4 * 60 * 60,
		need_period = "day",
		reward = 10, 
		reset_period = "month",
	},
	{ 
		type = ADMIN_TASK_WORKED_TIME,
		text = "Отработать 7 часов за сутки", 
		need_value = 7 * 60 * 60,
		need_period = "day",
		reward = 10, 
		reset_period = "month",
	},
	{ 
		type = ADMIN_TASK_WORKED_TIME,
		text = "Отработать 28 часов за неделю", 
		need_value = 28 * 60 * 60,
		need_period = "week",
		reward = 100, 
		reset_period = "month",
	},
	{ 
		type = ADMIN_TASK_WORKED_TIME,
		text = "Отработать 56 часов за неделю", 
		need_value = 56 * 60 * 60,
		need_period = "week",
		reward = 100, 
		reset_period = "month",
	},
	{ 
		type = ADMIN_TASK_WORKED_TIME,
		text = "Отработать 120 часов за месяц", 
		need_value = 120 * 60 * 60,
		need_period = "month",
		reward = 300, 
		reset_period = "month",
	},
	{ 
		type = ADMIN_TASK_WORKED_TIME,
		text = "Отработать 240 часов за месяц", 
		need_value = 240 * 60 * 60,
		need_period = "month",
		reward = 300, 
		reset_period = "month",
	},
	{ 
		type = ADMIN_TASK_REPORTS,
		text = "Ответить на 50 репортов за сутки", 
		need_value = 50,
		need_period = "day",
		reward = 50, 
		reset_period = "week+2h",
	},
	{ 
		type = ADMIN_TASK_REPORTS,
		text = "Ответить на 100 репортов за сутки", 
		need_value = 100,
		need_period = "day",
		reward = 100, 
		reset_period = "week+2h",
	},
	{ 
		type = ADMIN_TASK_REPORTS,
		text = "Ответить на 350 репортов за неделю", 
		need_value = 350,
		need_period = "week",
		reward = 300, 
		reset_period = "week+2h",
	},
	{ 
		type = ADMIN_TASK_REPORTS,
		text = "Ответить на 700 репортов за неделю", 
		need_value = 700,
		need_period = "week",
		reward = 300, 
		reset_period = "week+2h",
	},
}