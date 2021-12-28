loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )

if not localPlayer then
    Extend( "SPlayer" )
    Extend( "SVehicle" )
end

SHIFT_PLAN_TASKS =
{
	[ "shift_call" ] = 
	{
		id = "shift_call",
		factions = 
		{
			[ F_POLICE_PPS_NSK ] = true,
			[ F_POLICE_DPS_NSK ] = true,
			[ F_MEDIC ] = true,
			[ F_MEDIC_MSK ] = true,
			[ F_POLICE_PPS_GORKI ] = true,
			[ F_POLICE_DPS_GORKI ] = true,
			[ F_POLICE_PPS_MSK ] = true,
			[ F_POLICE_DPS_MSK ] = true,
		},
		text = "10 приездов на вызов за смену",
		need_number_exec = 10,
		reward = 5000,
	},

	[ "complete_quest" ] = 
	{
		id = "complete_quest",
		factions = 
		{
			[ F_POLICE_PPS_NSK ] = true,
			[ F_POLICE_DPS_NSK ] = true,
			[ F_MEDIC ] = true,
			[ F_MEDIC_MSK ] = true,
			[ F_POLICE_PPS_GORKI ] = true,
			[ F_POLICE_DPS_GORKI ] = true,
			[ F_POLICE_PPS_MSK ] = true,
			[ F_POLICE_DPS_MSK ] = true,
		},
		text = "5 выполненных квестов за смену",
		need_number_exec = 5,
		reward = 7500,
	},

	[ "participation_study" ] = 
	{
		id = "participation_study",
		factions = 
		{
			[ F_POLICE_PPS_NSK ] = true,
			[ F_POLICE_DPS_NSK ] = true,
			[ F_MEDIC ] = true,
			[ F_MEDIC_MSK ] = true,
			[ F_POLICE_PPS_GORKI ] = true,
			[ F_POLICE_DPS_GORKI ] = true,
			[ F_POLICE_PPS_MSK ] = true,
			[ F_POLICE_DPS_MSK ] = true,
		},
		text = "3 участия в учении за смену",
		need_number_exec = 3,
		reward = 10000,
	},

	[ "reviving" ] = 
	{
		id = "reviving",
		factions = 
		{
			[ F_MEDIC ] = true,
			[ F_MEDIC_MSK ] = true,
		},
		text = "5 оживленных игроков",
		need_number_exec = 5,
		reward = 5000,
	},

	[ "treating" ] = 
	{
		id = "treating",
		factions = 
		{
			[ F_MEDIC ] = true,
			[ F_MEDIC_MSK ] = true,
		},
		text = "5 вылеченных игроков",
		need_number_exec = 5,
		reward = 5000,
	},
}

function GetShiftPlanList()
    return SHIFT_PLAN_TASKS
end