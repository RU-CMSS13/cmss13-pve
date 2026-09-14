/obj/effect/temp_visual/utility
	duration = 5 SECONDS
	layer = ABOVE_MOB_LAYER

	color = COLOR_GREEN

/obj/effect/temp_visual/utility/Initialize(mapload)
	. = ..()
	animate(src, transform = matrix(0.5, MATRIX_SCALE), time = 1)

	animate(src, 3.5 SECONDS, easing = SINE_EASING|EASE_OUT, pixel_y = 48, transform = matrix().Update(scale_x = 2.5, scale_y = 2.5, rotation = 30))
	spawn(4 SECONDS)
		animate(src, 1 SECONDS, easing = SINE_EASING|EASE_IN, flags = ANIMATION_PARALLEL, alpha = 0, transform = matrix())

/obj/item/criptic/utility
	name = "paranormal equipment"
	desc = "..."

	icon = 'core_ru/code/modules/criptid_hunting/id_items.dmi'
	icon_state = "hunter_badge"

	w_class = SIZE_TINY

/obj/item/criptic/utility/proc/pop_out() //proc that exist specifically to show that you used an item
	var/obj/effect/temp_visual/utility/U = new /obj/effect/temp_visual/utility(get_turf(loc))
	U.icon = icon
	U.icon_state = "[icon_state]"

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
	var/list/mob/living/carbon/xenomorph/criptids = list(/mob/living/carbon/xenomorph/criptic_wendigo, /mob/living/carbon/xenomorph/criptic_wendigo/banshee)

/obj/item/criptic/utility/protective_cross/attack_self(mob/user)
	. = ..()
	if(used)
		animation_flash_color(src, COLOR_RED)
		return FALSE

	if(!used)
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

		sleep(0.5 SECONDS)

		set_light_range(5)
		set_light_power(2)

		for(var/mob/living/carbon/xenomorph/X in range(5,loc))
			if(X.type in criptids)
				playsound(X.loc,"acid_sizzle", 50, 1)

				animation_flash_color(X, COLOR_RED)
				X.apply_damage(600,BRUTE)
				X.emote("roar")

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

/atom/movable/screen/fullscreen/nvg/heal
	alpha = 0

/atom/movable/screen/fullscreen/nvg/heal/Initialize()
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS, BOUNCE_EASING|EASE_IN)

/obj/item/criptic/utility/pills/healing
	name = "healing pills"
	desc = "Restores your body to the full, healed state"

	icon = 'core_ru/code/modules/criptid_hunting/items1.dmi'
	icon_state = "birth1" // why tf this sprite named like that

	w_class = SIZE_TINY

/obj/item/criptic/utility/pills/healing/attack_self(mob/living/carbon/human/user)
	. = ..()
	playsound(loc,'sound/effects/pillbottle.ogg',10,TRUE)
	user.rejuvenate()
	animation_flash_color(src, COLOR_GREEN)
	user.overlay_fullscreen_timer(1 SECONDS, 5, "heal",/atom/movable/screen/fullscreen/nvg/heal)

	sleep(0.5 SECONDS)
	qdel(src)

/obj/item/criptic/utility/pills/healing/attack(mob/living/carbon/human/M, mob/user)
	. = ..()
	playsound(loc,'sound/effects/pillbottle.ogg',10,TRUE)
	M.rejuvenate()
	animation_flash_color(src, COLOR_GREEN)
	M.overlay_fullscreen_timer(1 SECONDS, 5, "heal", /atom/movable/screen/fullscreen/nvg/heal)

	sleep(0.5 SECONDS)
	qdel(src)

/obj/effect/temp_visual/fuel_spark
	duration = 0.5 SECONDS
	icon = 'core_ru/code/modules/criptid_hunting/chemistry_effects.dmi'
	icon_state = "reaction_explode-2"
	layer = ABOVE_MOB_LAYER

/obj/effect/temp_visual/fuel_spark/Initialize(mapload)
	. = ..()
	animate(src, transform = matrix(3, MATRIX_SCALE), time = 5)

/obj/structure/criptic/fuel
	name = "fuel spill"
	desc = "Special fuel which can affect criptids only...yep. Only them!"

	icon = 'core_ru/code/modules/criptid_hunting/effects.dmi'
	icon_state = "fuel"
	var/list/obj/structure/criptic/fuel/connected_fuel = list()

/obj/structure/criptic/fuel/Crossed(O)
	. = ..()

	if(istype(O,/mob/living/carbon/xenomorph) && length(connected_fuel))
		new /obj/effect/temp_visual/fuel_spark(loc)
		spawn(0.5 SECONDS)
			var/datum/reagent/napalm/blue/R = new()
			new /obj/flamer_fire(loc, create_cause_data("active fire", O), R, 2)
		spawn(1.5 SECONDS)
			for(var/obj/structure/criptic/fuel/F in connected_fuel)
				var/datum/reagent/napalm/blue/B = new()
				new /obj/flamer_fire(F.loc, create_cause_data("active fire", O), B, 2)
				qdel(F)
		spawn(2.5 SECONDS)
			qdel(src)

/obj/item/criptic/utility/fuel
	name = "fuel canister"
	desc = "For setting up traps"

	icon = 'core_ru/code/modules/criptid_hunting/items2.dmi'
	icon_state = "gasoline"

	w_class = SIZE_TINY

/obj/item/criptic/utility/fuel/attack_self(mob/user)
	. = ..()

	var/obj/structure/criptic/fuel/F = new /obj/structure/criptic/fuel(get_turf(loc))

	for(var/turf/open/T in orange(1,F))
		if(locate(/obj/structure/criptic/fuel) in T)
			continue
		F.connected_fuel += new /obj/structure/criptic/fuel(T)

	animation_flash_color(src, COLOR_RED)
	sleep(0.5 SECONDS)
	qdel(src)

/obj/structure/blocker/chime/dark
	invisibility = 0
	icon = 'core_ru/code/modules/criptid_hunting/effects.dmi'
	icon_state = "shadow"
	opacity = TRUE

/obj/structure/blocker/chime/dark/initialize_pass_flags(datum/pass_flags_container/PF)
	..()
	if (PF)
		PF.flags_can_pass_front = PASS_MOB_IS_OTHER
		PF.flags_can_pass_behind = PASS_MOB_IS_OTHER

/obj/structure/blocker/chime
	name = "shield"
	icon = 'icons/obj/structures/barricades.dmi'
	icon_state = "folding_0" // for map editing only
	flags_atom = ON_BORDER
	invisibility = INVISIBILITY_MAXIMUM
	throwpass = TRUE
	density = TRUE
	var/obj/item/criptic/utility/chime/linked_shield

/obj/structure/blocker/chime/Initialize(mapload, atom/generator, set_dir)
	. = ..()
	RegisterSignal(generator, COMSIG_PARENT_QDELETING, PROC_REF(collapse))
	linked_shield = generator
	icon_state = null
	dir = set_dir

/obj/structure/blocker/chime/Destroy(force)
	. = ..()
	linked_shield = null

/obj/structure/blocker/chime/proc/collapse()
	SIGNAL_HANDLER
	qdel(src)

/obj/structure/blocker/chime/initialize_pass_flags(datum/pass_flags_container/PF)
	..()
	if (PF)
		PF.flags_can_pass_front = PASS_MOB_IS_HUMAN
		PF.flags_can_pass_behind = PASS_ALL

/obj/structure/blocker/chime/get_projectile_hit_boolean(obj/projectile/P)
	var/is_reversed = (dir in reverse_nearby_direction(P.dir))
	if(!is_reversed)
		return FALSE

	loc.bullet_ping(P)
	return TRUE

/obj/structure/blocker/chime/get_explosion_resistance()
	return 9999

/obj/item/criptic/utility/chime
	name = "spirit chime"
	desc = "Protecting area from criptids..."

	icon = 'core_ru/code/modules/criptid_hunting/spirit_chime.dmi'
	icon_state = "chime"

	w_class = SIZE_TINY
	var/blocker_type = /obj/structure/blocker/chime
	var/field_radius = 7

	light_color = LIGHT_COLOR_HOLY_MAGIC
	light_range = 2
	light_power = 0.5

/obj/item/criptic/utility/chime/attack_self(mob/user)
	. = ..()
	user.drop_held_item(src)

	anchored = TRUE
	set_light_on(1)

	pixel_y = 26
	layer = ABOVE_MOB_LAYER
	alpha = 100

	var/list/box = RANGE_TURFS(field_radius, loc)
	for(var/turf/T as anything in box)
		if(get_dist(T, src) < field_radius)
			continue

		var/angle = Get_Angle(loc, T)
		var/relative_direction = get_dir_p_cardinals(angle)

		var/additional_dir
		switch(relative_direction)
			if (NORTHEAST)
				additional_dir = NORTH
				relative_direction = EAST
			if (SOUTHEAST)
				additional_dir = SOUTH
				relative_direction = EAST
			if (SOUTHWEST)
				additional_dir = SOUTH
				relative_direction = WEST
			if (NORTHWEST)
				additional_dir = NORTH
				relative_direction = WEST

		new blocker_type(T, src, relative_direction)

		if(!additional_dir)
			continue

		new blocker_type(T, src, additional_dir)

/obj/item/criptic/utility/chime/proc/remove_shield()
	playsound(loc, 'sound/effects/corsat_teleporter.ogg', 150)
	icon_state = initial(icon_state)
	spawn(4.5 SECONDS)
		QDEL_IN(src, field_radius * 2 - 1)

/proc/get_dir_p_cardinals(angle)
	switch(angle)
		if (45)
			return NORTHEAST
		if (135)
			return SOUTHEAST
		if (225)
			return SOUTHWEST
		if (315)
			return NORTHWEST
		if (0 to 44)
			return NORTH
		if (46 to 134)
			return EAST
		if (136 to 224)
			return SOUTH
		if (226 to 314)
			return WEST
		else
			return NORTH
