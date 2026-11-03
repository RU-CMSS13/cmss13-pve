/obj/item/criptic/utility/protective_cross
	name = "protection cross"
	desc = "Used to scare of some of the entities"

	light_color = LIGHT_COLOR_HOLY_MAGIC
	light_range = 3
	light_power = 1

	var/usage_cooldown = 1 MINUTES
	var/used = FALSE

	var/total_uses = 0
	var/total_uses_allowed = 5
	var/list/mob/living/carbon/xenomorph/criptids = list(/mob/living/carbon/xenomorph/criptic_wendigo, /mob/living/carbon/xenomorph/criptic_wendigo/werewolf, /mob/living/carbon/xenomorph/criptic_wendigo/banshee)

/obj/item/criptic/utility/protective_cross/attack_self(mob/user)
	. = ..()
	if(used)
		animation_flash_color(src, COLOR_RED)
		return FALSE

	if(!used)
		pop_out()

		used = TRUE
		addtimer(CALLBACK(src, PROC_REF(reset_cross)), usage_cooldown)
		playsound(loc,'sound/voice/holy_chorus.ogg', 25, 1)
		set_light_on(1)

		for(var/mob/living/carbon/xenomorph/X in range(2,loc))
			if(X.type in criptids)
				playsound(X.loc,"acid_sizzle", 50, 1)

				animation_flash_color(X, COLOR_RED)
				X.apply_damage(200,BRUTE)

				var/datum/action/xeno_action/onclick/lurker_invisibility/lurker_invis_action = get_action(X, /datum/action/xeno_action/onclick/lurker_invisibility)
				if (lurker_invis_action)
					lurker_invis_action.invisibility_off()
				X.forceMove(get_step(X,reverse_direction(X.dir)))

				X.apply_damage(600,BURN)
				X.emote("roar")

				X.adjust_fire_stacks(20)
				X.IgniteMob()

		sleep(0.5 SECONDS)

		set_light_range(6)
		set_light_power(2)

		for(var/mob/living/carbon/xenomorph/X in range(5,loc))
			if(X.type in criptids)
				playsound(X.loc,"acid_sizzle", 50, 1)

				var/datum/action/xeno_action/onclick/lurker_invisibility/lurker_invis_action = get_action(X, /datum/action/xeno_action/onclick/lurker_invisibility)
				if (lurker_invis_action)
					lurker_invis_action.invisibility_off()
				var/throwtarget = get_edge_target_turf(X, reverse_direction(X.dir))
				X.throw_atom(throwtarget, 5, SPEED_AVERAGE, user, TRUE)

		sleep(0.5 SECONDS)

		set_light_range(2)
		set_light_power(0.5)
		set_light_on(0)

		add_filter("cross1", 1, list("type" = "outline", "color" = "#ff8411", "size" = 1))
		add_filter("cross2", 1, list("type" = "blur", "size" = 0.7))

		total_uses += 1
		if(total_uses >= total_uses_allowed)
			animate(src, alpha = 00, time = 1 SECONDS, easing = SINE_EASING | EASE_IN)
			sleep(1.2 SECONDS)
			qdel(src)

/obj/item/criptic/utility/protective_cross/proc/reset_cross()
	used = FALSE
	remove_filter("cross1")
	remove_filter("cross2")

/obj/effect/temp_visual/fuel_spark
	duration = 0.5 SECONDS
	icon = 'core_ru/code/modules/criptid_hunting/chemistry_effects.dmi'
	icon_state = "reaction_explode-2"
	layer = ABOVE_MOB_LAYER

	light_on = TRUE
	light_power = 2
	light_range = 2
	light_color = LIGHT_COLOR_FIRE

/obj/effect/temp_visual/fuel_spark/Initialize(mapload)
	. = ..()
	animate(src, transform = matrix(3, MATRIX_SCALE), time = 5)

/obj/structure/criptic/fuel
	name = "fuel spill"
	desc = "Special fuel which can affect criptids only...yep. Only them!"

	icon = 'core_ru/code/modules/criptid_hunting/effects.dmi'
	icon_state = "fuel"
	var/list/obj/structure/criptic/fuel/fuel_nearby = list()
	var/obj/structure/criptic/fuel/fuel_center

	var/combusted = FALSE

/obj/structure/criptic/fuel/proc/triggered(O)
	combusted = TRUE
	if(!fuel_center)
		new /obj/effect/temp_visual/fuel_spark(loc)
	var/datum/reagent/napalm/blue/R = new()
	new /obj/flamer_fire(loc, create_cause_data("active fire", O), R, 1)
	spawn(1 SECONDS)
		if(length(fuel_nearby))
			for(var/obj/structure/criptic/fuel/F in fuel_nearby)
				F.triggered()
	qdel(src)

/obj/structure/criptic/fuel/Crossed(O)
	. = ..()

	if(istype(O,/mob/living/carbon/xenomorph))
		if(fuel_center && !fuel_center.combusted)
			triggered(O)
			fuel_center.triggered(O)
			return TRUE

		if(!combusted)
			triggered(O)
			return TRUE

/obj/item/criptic/utility/fuel
	name = "fuel canister"
	desc = "For setting up traps"

	icon = 'core_ru/code/modules/criptid_hunting/items2.dmi'
	icon_state = "gasoline"

	w_class = SIZE_TINY

/obj/item/criptic/utility/fuel/attack_self(mob/user)
	. = ..()
	pop_out()
	var/obj/structure/criptic/fuel/F = new /obj/structure/criptic/fuel(get_turf(loc))

	for(var/turf/open/T in orange(1,F))
		if(locate(/obj/structure/criptic/fuel) in T)
			continue
		var/obj/structure/criptic/fuel/fuel = new /obj/structure/criptic/fuel(T)
		fuel.fuel_center = F
		F.fuel_nearby += fuel

	animation_flash_color(src, COLOR_RED)
	sleep(0.5 SECONDS)
	qdel(src)
