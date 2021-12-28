PROPERTIES = {
	"weapon_range",
	"target_range",
	"accuracy",
	"damage",
	"maximum_clip_ammo",
	"move_speed",

	"anim_loop_start",
	"anim_loop_stop",
	"anim_loop_bullet_fire",
	"anim2_loop_start",
	"anim2_loop_stop",
	"anim2_loop_bullet_fire",
	"anim_breakout_time",
}
FLAGS = {
	flag_aim_no_auto 		= 0x000001 ,
	flag_aim_arm 			= 0x000002 ,
	flag_aim_1st_person 	= 0x000004 ,
	flag_aim_free 			= 0x000008 ,

	flag_move_and_aim 		= 0x000010 ,
	flag_move_and_shoot 	= 0x000020 ,

	flag_type_throw 		= 0x000100 ,
	flag_type_heavy 		= 0x000200 ,
	flag_type_constant 		= 0x000400 ,
	flag_type_dual 			= 0x000800 ,

	flag_anim_reload 		= 0x001000 ,
	flag_anim_crouch		= 0x002000 ,
	flag_anim_reload_loop 	= 0x004000 ,
	flag_anim_reload_long 	= 0x008000 ,

	flag_shot_slows 		= 0x010000 ,
	flag_shot_rand_speed 	= 0x020000 ,
	flag_shot_anim_abrupt 	= 0x040000 ,
	flag_shot_expands 		= 0x080000 ,
}