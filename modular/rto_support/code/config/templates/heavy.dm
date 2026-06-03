/datum/rto_support_template/heavy
	template_id = "heavy"
	allowed_support_profiles = list("uscm", "odst")
	name = "Тяжелый удар"
	support_resource_mode = RTO_SUPPORT_RESOURCE_MODE_CHARGES
	support_pool_capacity = 3
	support_pool_starting_charges = 3
	support_pool_recharge_interval = 300 SECONDS
	support_pool_recharge_amount = 1
	support_pool_auto_recharge = TRUE
	support_package_lockout = 14 SECONDS
	description = "Редкий тяжёлый пакет с общими 3 зарядами для точечного ракетного удара и полного напалмового захода."
	role_summary = "Ракетный удар стоит 1 заряд. Напалм тратит все 3 и требует самой длинной подготовки перед следующим вызовом."
	targeting_summary = "Сначала разверните сектор удара, затем подтверждайте цель внутри него. Повторная постановка сектора остаётся короткой."
	restriction_summary = "Требуется открытое небо. Тяжёлая поддержка восстанавливается дольше всех и рассчитана на решающие вызовы, а не на постоянное давление."
	visibility_zone_type = "Окно удара"
	visibility_zone_radius = 4
	visibility_zone_duration = 80 SECONDS
	visibility_zone_cooldown = 3 SECONDS
	category = "support"
	action_template_types = list(
		/datum/rto_support_action_template/heavy_missile,
		/datum/rto_support_action_template/heavy_napalm,
	)
	visibility_altitude_requirement = RTO_SUPPORT_ALTITUDE_HIGH
