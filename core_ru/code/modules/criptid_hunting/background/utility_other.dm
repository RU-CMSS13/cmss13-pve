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
	pop_out()
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

/mob/living/carbon/xenomorph
	var/signal_marked = FALSE

/mob/living/carbon/xenomorph/proc/place_tracker()
	balloon_alert(src, "Something were attached to your spine!", COLOR_WHITE)
	signal_marked = TRUE
	addtimer(CALLBACK(src, PROC_REF(remove_tracker)), 5 MINUTES)

/mob/living/carbon/xenomorph/proc/remove_tracker()
	signal_marked = FALSE

/datum/ammo/flare/signal/on_hit_mob(mob/M, obj/projectile/P)
	CAN_BE_REDEFINED(TRUE)

	if(iscarbonsizexeno(M))
		var/mob/living/carbon/xenomorph/target = M

		if(target.the_big_bad && !target.signal_marked)
			target.place_tracker()
			return
	..()

/obj/item/criptic/utility/tracker
	name = "tracker"
	desc = "For your topography shenanigans"

	icon = 'core_ru/code/modules/criptid_hunting/items3.dmi'
	icon_state = "tag"

	w_class = SIZE_TINY
	var/mob/living/carbon/xenomorph/monitoring

/obj/item/criptic/utility/tracker/Initialize(mapload, ...)
	. = ..()
	START_PROCESSING(SSobj,src)

/obj/item/criptic/utility/tracker/process()
	if(icon_state == "tag")
		for(var/mob/living/carbon/xenomorph/X in world)
			if(X.the_big_bad && X.signal_marked)
				icon_state = "tag_active"
				monitoring = X
				if(ishuman(loc))
					balloon_alert(loc, "New creature signature loaded into your tracker!", COLOR_WHITE)

	if(monitoring)
		if(!monitoring.signal_marked)
			monitoring = null
			icon_state = "tag"
		if(!monitoring.stat == DEAD)
			monitoring = null
			icon_state = "tag"

	if((!monitoring || isnull(monitoring)) && icon_state == "tag_active")
		monitoring = null
		icon_state = "tag"

/obj/item/criptic/utility/tracker/attack_self(mob/user)
	. = ..()
	var/obj/item/map/tactical/map = user.get_inactive_hand()
	if(!istype(map) || !map.is_open_for(user))
		balloon_alert(user, "You need an open tactical map in your other hand to locate the creature!", COLOR_WHITE)
		animation_flash_color(src, COLOR_RED)
		return
	if(!monitoring)
		balloon_alert(user, "There is no info on the tracker to reveal!", COLOR_WHITE)
		animation_flash_color(src, COLOR_RED)
		return
	if(user.action_busy)
		return

	if(!do_after(user, 5 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_GENERIC))
		return
	if(user.get_inactive_hand() != map || !map.is_open_for(user))
		return

	balloon_alert(user, "New point appeared on your map!", COLOR_WHITE)

	var/turf/xeno_turf = get_turf(monitoring)
	var/turf/guess = locate( \
		clamp(xeno_turf.x + rand(-2, 2), 1, world.maxx), \
		clamp(xeno_turf.y + rand(-2, 2), 1, world.maxy), \
		xeno_turf.z)
	map.tacmap.add_timed_marker(guess, 4, COLOR_DARK_RED, 1 MINUTES)
