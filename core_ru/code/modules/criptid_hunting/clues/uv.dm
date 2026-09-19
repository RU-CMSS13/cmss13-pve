/obj/structure/criptic/clue/uv/plasm
	mouse_opacity = FALSE

/obj/structure/criptic/clue/uv/runes
	icon = 'core_ru/code/modules/criptid_hunting/glyphs.dmi'
	icon_state_found = "black_spiral_dancers"
	mouse_opacity = FALSE

	light_color = "#ff8411"

/obj/structure/criptic/clue/uv/runes/Initialize(mapload, ...)
	. = ..()
	icon_state_found = pick("black_spiral_dancers","garou","howl","war_against_wyrm")

/obj/structure/criptic/clue/uv/runes/reveal_itself()
	. = ..()
	add_filter("firerune", 1, list("type" = "outline", "color" = "#ff8411", "size" = 1))
	set_light_range(1)

/obj/effect/temp_visual/uv_trail
	duration = 1 MINUTES
	icon = 'icons/effects/blood.dmi'
	icon_state = "csplatter1"
	layer = 2.52
	alpha = 0

	var/found = FALSE
	var/time_to_fade = 5

/obj/effect/temp_visual/uv_trail/Initialize(mapload)
	. = ..()
	icon_state = "csplatter[rand(1,6)]"
	var/splatter_size = pick(0.3,0.6,1)

	SetTransform(splatter_size)
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)

	add_filter("highlight", 1, list("type" = "outline", "color" = "#b417b9", "size" = 1))
	START_PROCESSING(SSobj,src)

/obj/effect/temp_visual/uv_trail/process()
	if(alpha > 0 && !found)
		found = TRUE

	if(found && time_to_fade > 0)
		time_to_fade -= 1

	if(found && time_to_fade <= 0)
		found = FALSE
		time_to_fade = 5
		animate(src, alpha = 00, time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN)

/obj/item/criptic/instrument/uv_lamp
	name = "UV lamp"
	desc = "Can reveal hidden runes and ectoplasm"

	passive_searching = TRUE
	clue_type_to_reveal = list(/obj/structure/criptic/clue/uv,/obj/structure/criptic/clue/uv/plasm,/obj/structure/criptic/clue/uv/runes)

	icon = 'core_ru/code/modules/criptid_hunting/lighting.dmi'

	icon_state = "seclite"
	icon_state_on = "seclite-on"

	light_color = COLOR_STRONG_VIOLET
	light_range = 4
	light_power = 2

	var/mob/living/carbon/human/last_holder
	var/list/trail_excludes = list()

/obj/item/criptic/instrument/uv_lamp/Initialize(mapload, ...)
	. = ..()
	trail_excludes += typesof(/obj/structure/window_frame,/obj/structure/machinery/door)

/obj/item/criptic/instrument/uv_lamp/afterattack(atom/A, mob/living/carbon/human/user, proximity_flag, click_parameters)
	if(A.uv_scannable && !A.uv_scanned)
		if(do_after(user, 50, INTERRUPT_ALL, BUSY_ICON_GENERIC))
			A.uv_scanned = TRUE
			show_blurb(user, 20, "[A.uv_onfind]", null, "CENTER,CENTER+1", "center", COLOR_GRAY, null, null, 1)
			user.hide_hint(A)
			create_path(A)
		return TRUE

	. = ..()

/obj/item/criptic/instrument/uv_lamp/proc/create_path(atom/target)
	var/list/connected_clues = list()
	for(var/obj/structure/criptic/clue/C in range(14, get_turf(target)))
		if(C.revealed)
			continue
		connected_clues += C

	if(!length(connected_clues))
		return

	var/obj/structure/criptic/clue/trail_to_follow = pick(connected_clues)
	var/turf/start = get_turf(target)
	var/turf/end = get_turf(trail_to_follow)

	if(!start || !end)
		return

	var/list/turf/queue = list(start)
	var/list/turf/parents = list()
	parents[start] = null
	var/turf/current
	var/found = FALSE

	while(length(queue))
		current = queue[1]
		queue.Cut(1, 2)

		if(current == end)
			found = TRUE
			break

		var/list/turf/neighbors = list(
			get_step(current, NORTH),
			get_step(current, SOUTH),
			get_step(current, EAST),
			get_step(current, WEST)
		)

		for(var/turf/next in neighbors)
			if(!next || (next in parents))
				continue
			if(!is_turf_passable(next))
				continue

			parents[next] = current
			queue += next

	if(!found)
		return

	var/list/turf/path = list()
	current = end
	while(current)
		path.Insert(1, current)
		current = parents[current]

	for(var/turf/T in path)
		if(prob(80))
			new /obj/effect/temp_visual/uv_trail(T)

/obj/item/criptic/instrument/uv_lamp/proc/is_turf_passable(turf/T)
	if(!T)
		return FALSE
	if(T.density)
		return FALSE
	if(!istype(T, /turf/open))
		return FALSE

	for(var/obj/O in T)
		if(O.density && !(O.type in trail_excludes))
			return FALSE

	return TRUE

/obj/item/criptic/instrument/uv_lamp/check_for_condition()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		last_holder = H

/// TRAIL

		for(var/obj/effect/temp_visual/uv_trail/trail in range(2,get_turf(H)))
			if(trail.alpha < 100)
				animate(trail, alpha = 100, time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN)

/// TRAIL

		for(var/obj/structure/criptic/clue/C in H.revealed_hints)
			if(get_dist(C,H) > 3)
				H.hide_hint(C)

		for(var/obj/structure/criptic/clue/C in range(2,get_turf(H)))
			if(!(C.type in clue_type_to_reveal))
				continue
			if(C.revealed)
				continue
			if(!(C in H.revealed_hints))
				H.show_hint(C, C.clue_icon_state)

/obj/item/criptic/instrument/uv_lamp/revert_instrument_effect()
	if(last_holder)
		for(var/atom/A as anything in last_holder.revealed_hints)
			last_holder.hide_hint(A)
		last_holder = null
