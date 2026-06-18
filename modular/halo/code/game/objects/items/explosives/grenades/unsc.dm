// Grenades

/obj/item/explosive/grenade/high_explosive/m15/unsc
	name = "M9 fragmentation grenade"
	desc = "Штатная осколочная граната ККОН. 190 граммов состава L надёжно засыпают осколками радиус до 15 метров."
	desc_lore = "Ходят слухи, что с каждым новым назначением дизайн осколочной гранаты M9 снова чем-то отличается от тех, что держали в руках раньше."
	icon = 'modular/halo/icons/halo/obj/items/weapons/grenades.dmi'
	icon_state = "m9"
	item_state = "m9"
	falloff_mode = EXPLOSION_FALLOFF_SHAPE_EXPONENTIAL_HALF

/obj/item/explosive/grenade/high_explosive/m15/unsc/launchable
	name = "40mm explosive grenade"
	desc = "40-мм фугасная граната. Её нельзя привести в боевое положение вручную - она должна быть заряжена в подствольный гранатомёт винтовки."
	icon = 'modular/halo/icons/halo/obj/items/weapons/grenades.dmi'
	icon_state = "he_40mm"
	item_state = "he_40mm"
	caliber = "40mm"
	explosion_power = 80
	explosion_falloff = 40
	shrapnel_count = 0
	hand_throwable = FALSE
	has_arm_sound = FALSE
	dangerous = FALSE
	dual_purpose = TRUE
	underslug_launchable = TRUE

/obj/item/explosive/grenade/smokebomb/unsc
	name = "\improper M45 smoke grenade"
	desc = "Дымовая граната баночного типа, обычно используемая для сигнализации или маскировки."
	icon = 'modular/halo/icons/halo/obj/items/weapons/grenades.dmi'
	icon_state = "smonk"
	item_state = "smonk"
	det_time = 30
	throw_speed = SPEED_FAST
	caliber = "non-standard"
	underslug_launchable = FALSE
	dual_purpose = FALSE
	throw_range = 6
	arm_sound = 'sound/weapons/pinpull.ogg'
	spent_case = /obj/item/trash/grenade/unsc_smoke

/obj/item/explosive/grenade/high_explosive/pmc/unsc
	name = "\improper M47 blast grenade"
	desc = "Мощная фугасная граната, предназначенная для использования с оборонительных позиций."
	icon = 'modular/halo/icons/halo/obj/items/weapons/grenades.dmi'
	icon_state = "defensive_grenade"
	item_state = "defensive_grenade"
	explosion_power = 90
	explosion_falloff = 8
	falloff_mode = EXPLOSION_FALLOFF_SHAPE_EXPONENTIAL

/obj/item/explosive/grenade/incendiary/unsc
	name = "\improper TH-61 thermite grenade"
	desc = "Зажигательно-фугасная граната, предназначенная в первую очередь для уничтожения техники, но столь же эффективная и против органических целей."
	icon = 'modular/halo/icons/halo/obj/items/weapons/grenades.dmi'
	icon_state = "thermite_grenade"
	item_state = "thermite_grenade"
	caliber = "non-standard"
	underslug_launchable = FALSE
	dual_purpose = FALSE
	arm_sound = 'sound/weapons/pinpull.ogg'
	flame_level = 20
	burn_level = 60
	flameshape = FLAMESHAPE_STAR
	radius = 1
	fire_type = FIRE_VARIANT_DEFAULT

/obj/item/explosive/grenade/incendiary/unsc/prime(mob/living/user)
	set waitfor = 0
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flame_radius), cause_data, radius, get_turf(src), flame_level, burn_level, flameshape, null, fire_type)
	playsound(src.loc, 'modular/halo/sound/weapons/gun_firebomb.ogg', 35, 1, 4)
	qdel(src)

// Spent grenade cases
/obj/item/trash/grenade/unsc_smoke
	name = "spent M45 smoke grenade"
	desc = "Использованная дымовая граната. Теперь это мусор."
	icon = 'modular/halo/icons/halo/obj/items/weapons/grenades.dmi'
	icon_state = "smonk_spent"
