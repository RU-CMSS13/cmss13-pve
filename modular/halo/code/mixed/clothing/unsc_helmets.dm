/obj/item/clothing/head/helmet/marine/unsc
	name = "\improper CH252 helmet"
	desc = "Штатный шлем корпуса морской пехоты ККОН. Различные точки крепления позволяют устанавливать на него дополнительное оборудование."
	icon = 'modular/halo/icons/halo/obj/items/clothing/hats/hats_by_faction/hat_unsc.dmi'
	icon_state = "helmet"
	item_state = "helmet"
	flags_atom = NO_SNOW_TYPE|NO_NAME_OVERRIDE
	built_in_visors = null
	start_down_visor_type = null
	item_icons = list(
		WEAR_HEAD = 'modular/halo/icons/halo/mob/humans/onmob/clothing/hats/hats_by_faction/hat_unsc.dmi',
	)

// SS220 EDIT START — /motion subtypes ported from CM-PVE-HALO PR #146 (visr-nvg)
// These types are required by unsc_dark_was_the_night and unsc_dark_was_the_night_odst maps.
// Motion sensor component is added ONLY to /motion subtypes, matching visr-nvg design.

/obj/item/clothing/head/helmet/marine/unsc/motion
	name = "\improper CH252-M helmet"
	desc = "Улучшенный шлем корпуса морской пехоты ККОН со встроенным датчиком движения. Различные точки крепления позволяют устанавливать на него дополнительное оборудование."

/obj/item/clothing/head/helmet/marine/unsc/motion/Initialize(mapload, list/new_protection)
	. = ..()
	AddComponent(/datum/component/halo_motion_sensor_manager)

/obj/item/clothing/head/helmet/marine/unsc/oni/motion
	name = "\improper ONI CH252-M helmet"
	desc = "Улучшенный шлем корпуса морской пехоты ККОН со встроенным датчиком движения. Этот вариант используется силами безопасности ONI и отличается чёрной цветовой схемой."

/obj/item/clothing/head/helmet/marine/unsc/oni/motion/Initialize(mapload, list/new_protection)
	. = ..()
	AddComponent(/datum/component/halo_motion_sensor_manager)

// SS220 EDIT END

// SS220 EDIT - START
// USCM /motion шлем — портирован из CM-PVE-HALO PR #146 (visr-nvg)
/obj/item/clothing/head/helmet/marine/motion
	name = "\improper M10-M helmet"
	desc = "A standard-issue USCM M10 helmet with an integrated motion sensor. Has a built-in camera and HUD."
	icon_state = "helmet"
	item_state = "helmet"
	flags_inventory = COVEREYES|COVERMOUTH|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	flags_cold_protection = BODY_FLAG_HEAD
	flags_heat_protection = BODY_FLAG_HEAD
	min_cold_protection_temperature = HELMET_MIN_COLD_PROT
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROT
	siemens_coefficient = 0.9
	anti_hug = 6

/obj/item/clothing/head/helmet/marine/motion/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/halo_motion_sensor_manager)
// SS220 EDIT - END

/obj/item/clothing/head/helmet/marine/unsc/pilot
	name = "\improper FH252 helmet"
	desc = "Типичный шлем большинства пилотов ККОН благодаря полностью закрытой конструкции. Особенно ценится в боевых условиях, когда кабина может оказаться разгерметизированной."
	icon_state = "pilot"
	item_state = "pilot"
	flags_atom = ALLOWINTERNALS|NO_SNOW_TYPE|NO_NAME_OVERRIDE|BLOCKGASEFFECT|ALLOWREBREATH|ALLOWCPR

/obj/item/clothing/head/helmet/marine/unsc/police
	name = "\improper police CH252 helmet"
	desc = "Штатный шлем корпуса морской пехоты ККОН, этот вариант выдаётся местной полиции и силам безопасности по колониям."
	icon_state = "police"
	item_state = "police"

/obj/item/clothing/head/helmet/marine/unsc/insurrection
	icon_state = "insurgent"
	item_state = "insurgent"

/obj/item/clothing/head/helmet/marine/unsc/oni
	name = "\improper ONI CH252 helmet"
	desc = "Штатный шлем корпуса морской пехоты ККОН. Этот вариант используется силами безопасности ONI."
	icon_state = "oni"
	item_state = "oni"

/obj/item/clothing/head/helmet/marine/unsc/odst
	name = "\improper CH381 ODST helmet"
	desc = "Культовый шлем, разработанный для бойцов Orbital Drop Shock Troopers корпуса морской пехоты ККОН."
	built_in_visors = list(new /obj/item/device/helmet_visor/night_vision/halo/unsc)
	icon_state = "odst"
	item_state = "odst"
	flags_inventory = COVEREYES|COVERMOUTH|BLOCKSHARPOBJ|BLOCKGASEFFECT
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK|HIDEALLHAIR
	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	armor_internaldamage = CLOTHING_ARMOR_HIGH

// SS220 EDIT — /motion subtype ported from CM-PVE-HALO PR #146 (visr-nvg)
// Required by unsc_dark_was_the_night_odst map.
// Motion sensor component is added ONLY to /motion subtypes, matching visr-nvg design.

/obj/item/clothing/head/helmet/marine/unsc/odst/motion
	name = "\improper CH381-M ODST helmet"
	desc = "Культовый шлем, разработанный для бойцов Orbital Drop Shock Troopers корпуса морской пехоты ККОН. Усовершенствованная версия со встроенным датчиком движения."

/obj/item/clothing/head/helmet/marine/unsc/odst/motion/Initialize(mapload, list/new_protection)
	. = ..()
	AddComponent(/datum/component/halo_motion_sensor_manager)
