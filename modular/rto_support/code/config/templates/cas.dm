/datum/rto_support_template/cas
	template_id = "cas"
	allowed_support_profiles = list("uscm", "odst")
	name = "Штурмовая авиация"
	support_resource_mode = RTO_SUPPORT_RESOURCE_MODE_CHARGES
	support_pool_capacity = 3
	support_pool_starting_charges = 3
	support_pool_recharge_interval = 240 SECONDS
	support_pool_recharge_amount = 1
	support_pool_auto_recharge = TRUE
	support_package_lockout = 10 SECONDS
	description = "Авиационный пакет с общими 3 зарядами для повторных заходов и одного дорогого ракетного удара."
	role_summary = "Пушечный и лазерный заходы стоят 1 заряд. Ракетный заход тратит весь пакет и лучше держать для ценных целей."
	targeting_summary = "Сначала разверните сектор, затем наводите авиаудары через него. Повторная постановка сектора остаётся короткой."
	restriction_summary = "Требуется открытое небо. Пакет восстанавливается заметно медленнее миномётов, а каждый вызов ненадолго ставит на паузу весь пакет."
	visibility_zone_type = "Воздушный коридор"
	visibility_zone_radius = 5
	visibility_zone_duration = 60 SECONDS
	visibility_zone_cooldown = 3 SECONDS
	category = "support"
	action_template_types = list(
		/datum/rto_support_action_template/cas_gun_run,
		/datum/rto_support_action_template/cas_laser_run,
		/datum/rto_support_action_template/cas_rocket_barrage,
	)
	visibility_altitude_requirement = RTO_SUPPORT_ALTITUDE_HIGH
