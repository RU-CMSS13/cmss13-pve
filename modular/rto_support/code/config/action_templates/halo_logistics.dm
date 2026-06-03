/datum/rto_support_action_template/halo
	scatter = 1
	requires_visibility_zone = FALSE
	altitude_requirement = RTO_SUPPORT_ALTITUDE_HIGH
	allow_closed_turf = FALSE
	category = "support"

/datum/rto_support_action_template/halo/logistics
	parent_type = /datum/rto_support_action_template/halo
	shared_cooldown = 240 SECONDS
	personal_cooldown = 600 SECONDS
	support_pool_cost = 1
	personal_lockout = 6 SECONDS
	category = "logistics"
	icon_state = "ammo"

/datum/rto_support_action_template/halo_rifle_ammo_drop
	parent_type = /datum/rto_support_action_template/halo/logistics
	action_id = "halo_rifle_ammo_drop"
	name = "Боеприпасы винтовочного калибра"
	description = "Сбрасывает смешанный винтовочный ящик для MA5C и MA5B."
	fire_support_path = /datum/fire_support/supply_drop/halo/rifle

/datum/rto_support_action_template/halo_marksman_ammo_drop
	parent_type = /datum/rto_support_action_template/halo/logistics
	action_id = "halo_marksman_ammo_drop"
	name = "Боеприпасы марксмана"
	description = "Сбрасывает магазины для винтовок M392 DMR и BR55."
	fire_support_path = /datum/fire_support/supply_drop/halo/marksman

/datum/rto_support_action_template/halo_pdw_ammo_drop
	parent_type = /datum/rto_support_action_template/halo/logistics
	action_id = "halo_pdw_ammo_drop"
	name = "Боеприпасы пистолетного калибра и средств самообороны"
	description = "Сбрасывает магазины для M7 и пистолетов."
	fire_support_path = /datum/fire_support/supply_drop/halo/pdw

/datum/rto_support_action_template/halo_shotgun_ammo_drop
	parent_type = /datum/rto_support_action_template/halo/logistics
	action_id = "halo_shotgun_ammo_drop"
	name = "Дробовые патроны"
	description = "Сбрасывает ящики с дробью и пулями для дробовиков 8-го калибра."
	fire_support_path = /datum/fire_support/supply_drop/halo/shotgun

/datum/rto_support_action_template/halo_sniper_ammo_drop
	parent_type = /datum/rto_support_action_template/halo/logistics
	action_id = "halo_sniper_ammo_drop"
	name = "Снайперские боеприпасы"
	icon_state = "srs"
	description = "Сбрасывает магазины SRS99 для антиматериальной винтовки."
	fire_support_path = /datum/fire_support/supply_drop/halo/sniper

/datum/rto_support_action_template/halo_spnkr_ammo_drop
	parent_type = /datum/rto_support_action_template/halo/logistics
	action_id = "halo_spnkr_ammo_drop"
	name = "Боеприпасы SPNKr"
	icon_state = "spnkr"
	description = "Сбрасывает сменные ракетные тубусы для M41 SPNKr."
	fire_support_path = /datum/fire_support/supply_drop/halo/spnkr

/datum/rto_support_action_template/halo_grenadier_ammo_drop
	parent_type = /datum/rto_support_action_template/halo/logistics
	action_id = "halo_grenadier_ammo_drop"
	icon_state = "grenade"
	name = "Боеприпасы гренадера"
	description = "Сбрасывает ящик гренадера с 40-мм выстрелами и осколочными гранатами."
	fire_support_path = /datum/fire_support/supply_drop/halo/grenadier

/datum/rto_support_action_template/halo_frontline_ammo_drop
	parent_type = /datum/rto_support_action_template/halo/logistics
	support_pool_cost = 2
	action_id = "halo_frontline_ammo_drop"
	name = "Большой ящик с боеприпасами"
	description = "Сбрасывает большой ящик содержащий все основные магазины и боеприпасы для оружия ККОН."
	fire_support_path = /datum/fire_support/supply_drop/halo/frontline
