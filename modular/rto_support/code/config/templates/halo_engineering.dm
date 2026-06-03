/datum/rto_support_template/halo_engineering
	parent_type = /datum/rto_support_template/halo
	template_id = "halo_engineering"
	name = "Инженерия UNSC"
	description = "Пакет инженерной поддержки UNSC для ремонта, укреплений и пролома."
	role_summary = "Вызывает инженерные ящики с инструментами, укреплениями, подрывными средствами и обслуживанием техники."
	targeting_summary = "Сектор не нужен: отметьте открытую точку посадки через RTO-бинокль."
	restriction_summary = "Доступен только RTO сил UNSC. Инженерные сбросы требуют открытого неба и дольше готовятся к следующему вызову."
	action_template_types = list(
		/datum/rto_support_action_template/halo_fortification_drop,
		/datum/rto_support_action_template/halo_breaching_drop,
		/datum/rto_support_action_template/halo_field_service_drop,
	)
