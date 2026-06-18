/obj/structure/closet/secure_closet/marine_personal/unsc/spawn_gear()
	new /obj/item/clothing/under/marine(src)
	new /obj/item/clothing/shoes/marine/knife(src)
	new /obj/item/device/radio/headset/almayer/marine/solardevils/unsc(src)

/obj/structure/closet/secure_closet/marine_personal/unsc/rifleman
	job = JOB_SQUAD_MARINE_UNSC
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-rm"
	icon_closed = "secure-rm"
	icon_locked = "secure1-rm"
	icon_opened = "secureopen-rm"
	icon_broken = "securebroken-rm"
	icon_off = "secureoff-rm"

/obj/structure/closet/secure_closet/marine_personal/unsc/specialist
	job = JOB_SQUAD_SPECIALIST_UNSC
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-spec"
	icon_closed = "secure-spec"
	icon_locked = "secure1-spec"
	icon_opened = "secureopen-spec"
	icon_broken = "securebroken-spec"
	icon_off = "secureoff-spec"

/obj/structure/closet/secure_closet/marine_personal/unsc/corpsman
	job = JOB_SQUAD_MEDIC_UNSC
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-med"
	icon_closed = "secure-med"
	icon_locked = "secure1-med"
	icon_opened = "secureopen-med"
	icon_broken = "securebroken-med"
	icon_off = "secureoff-med"

/obj/structure/closet/secure_closet/marine_personal/unsc/team_leader
	job = JOB_SQUAD_TEAM_LEADER_UNSC
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-ftl"
	icon_closed = "secure-ftl"
	icon_locked = "secure1-ftl"
	icon_opened = "secureopen-ftl"
	icon_broken = "securebroken-ftl"
	icon_off = "secureoff-ftl"

/obj/structure/closet/secure_closet/marine_personal/unsc/squad_leader
	job = JOB_SQUAD_LEADER_UNSC
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-sl"
	icon_closed = "secure-sl"
	icon_locked = "secure1-sl"
	icon_opened = "secureopen-sl"
	icon_broken = "securebroken-sl"
	icon_off = "secureoff-sl"

/obj/structure/closet/secure_closet/marine_personal/unsc/platoon_commander
	job = JOB_SO_UNSC
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-so"
	icon_closed = "secure-so"
	icon_locked = "secure1-so"
	icon_opened = "secureopen-so"
	icon_broken = "securebroken-so"
	icon_off = "secureoff-so"

/obj/structure/closet/secure_closet/marine_personal/unsc/platoon_commander/spawn_gear()
	new /obj/item/clothing/under/marine(src)
	new /obj/item/clothing/under/marine/crew/command(src)
	new /obj/item/clothing/under/marine/officer/boiler(src)
	new /obj/item/clothing/head/cmcap/bridge(src)
	new /obj/item/clothing/suit/storage/jacket/marine/service(src)
	new /obj/item/clothing/under/marine/officer/bridge(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/clothing/head/marine/peaked/service(src)
	new /obj/item/clothing/suit/storage/jacket/marine/dress/officer/bomber(src)
	new /obj/item/clothing/shoes/marine/knife(src)
	new /obj/item/device/radio/headset/almayer/marine/solardevils/pltco/unsc(src)
	new /obj/item/clothing/head/helmet/marine/unsc/motion(src)

/obj/structure/closet/secure_closet/marine_personal/unsc/rto
	job = JOB_SQUAD_RTO_UNSC
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-rto"
	icon_closed = "secure-rto"
	icon_locked = "secure1-rto"
	icon_opened = "secureopen-rto"
	icon_broken = "securebroken-rto"
	icon_off = "secureoff-rto"

/obj/structure/closet/secure_closet/marine_personal/unsc/rto/spawn_gear()
	..()
	need_check_content = TRUE
	new /obj/item/storage/pouch/sling/rto/halo/unsc(src)
	new /obj/item/storage/box/flare/signal(src)
	new /obj/item/storage/box/flare/signal(src)
