/datum/rto_support_action_template/halo/command
	parent_type = /datum/rto_support_action_template/halo
	shared_cooldown = 240 SECONDS
	personal_cooldown = 600 SECONDS
	support_pool_cost = 1
	personal_lockout = 8 SECONDS
	category = "command"
	icon_state = "flare"

/datum/rto_support_action_template/halo_signal_drop
	parent_type = /datum/rto_support_action_template/halo/command
	action_id = "halo_signal_drop"
	name = "Сигнальный комплект"
	icon_state = "flare"
	description = "Сбрасывает сигнальное снаряжение для обозначения зоны посадки и координации боя."
	fire_support_path = /datum/fire_support/supply_drop/halo/signal

/datum/rto_support_action_template/halo_recon_drop
	parent_type = /datum/rto_support_action_template/halo/command
	action_id = "halo_recon_drop"
	name = "Разведывательный комплект"
	description = "Сбрасывает монокуляры, детектор движения, тактическую карту и боевой фонарь."
	fire_support_path = /datum/fire_support/supply_drop/halo/recon

/datum/rto_support_action_template/halo_rto_command_drop
	parent_type = /datum/rto_support_action_template/halo/command
	action_id = "halo_rto_command_drop"
	name = "Командный комплект RTO"
	description = "Сбрасывает командное снаряжение для координации RTO и JTAC."
	fire_support_path = /datum/fire_support/supply_drop/halo/rto_command
