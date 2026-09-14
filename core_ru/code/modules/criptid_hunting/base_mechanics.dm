/// Runs Scale, Turn, and Translate if supplied parameters, then multiplies by others if set.
/matrix/proc/Update(scale_x, scale_y, rotation, offset_x, offset_y, list/others)
	var/x_null = isnull(scale_x)
	var/y_null = isnull(scale_y)
	if (!x_null || !y_null)
		Scale(x_null ? 1 : scale_x, y_null ? 1 : scale_y)
	if (!isnull(rotation))
		Turn(rotation)
	if (offset_x || offset_y)
		Translate(offset_x || 0, offset_y || 0)
	if (islist(others))
		for (var/other in others)
			Multiply(other)
	else if (others)
		Multiply(others)
	return src

/atom
	var/uv_scannable = FALSE
	var/uv_scanned = FALSE

/image/hint
/mob/living/carbon/human
	var/list/revealed_hints = list()
	var/list/naturally_hinted = list()
	var/hint_visibility = 1

/mob/living/carbon/human/Life()

	if(ishuman(src) && client)
		for(var/atom/A as anything in revealed_hints)
			if((get_dist(src, A) > hint_visibility) && (A in naturally_hinted))
				hide_hint(A)

		for(var/atom/A in range(hint_visibility,src))
			if(!(A in revealed_hints) && A.uv_scannable && !A.uv_scanned)
				show_hint(A)
				naturally_hinted += A

	. = ..()

/mob/living/carbon/human/proc/show_hint(atom/A)
	if(!client || (A in revealed_hints))
		return

	var/image/hint/new_hint = new /image/hint('core_ru/code/modules/criptid_hunting/disciplines.dmi', A, "auspex", layer = HUD_LAYER)

	new_hint.alpha = 0
	new_hint.pixel_x = pixel_x + 5
	new_hint.pixel_y = pixel_y + 5
	new_hint.plane = HUD_PLANE

	animate(new_hint, alpha = 255, pixel_x = A.pixel_x+8, pixel_y = A.pixel_y+12, time = 0.3 SECONDS, easing = SINE_EASING|EASE_OUT)

	client.images += new_hint
	revealed_hints[A] = new_hint

/mob/living/carbon/human/proc/hide_hint(atom/A)
	if(!client || !(A in revealed_hints))
		return

	var/image/hint/the_hint = revealed_hints[A]

	animate(the_hint, alpha = 0, pixel_x = A.pixel_x, pixel_y = A.pixel_y, time = 0.3 SECONDS, easing = SINE_EASING|EASE_IN)

	spawn(0.3 SECONDS)
		if(client)
			client.images -= the_hint
		revealed_hints -= A

/obj/structure/criptic/mission_controller
	icon = 'icons/landmarks.dmi'
	icon_state = "x2"

	var/busy_now = FALSE

	var/current_clues_found = 0
	var/needed_amount = 0

	var/mission_name = "The Hunt" // also for GM purposes
	var/automatic_messaging_delay = 300

/obj/structure/criptic/mission_controller/proc/show_mission_name()
	show_blurb(GLOB.player_list, 30, "[mission_name]", null, "center", "center", color, null, null, 1)

/obj/structure/criptic/mission_controller/proc/show_current_progress()
	if(!busy_now)
		busy_now = TRUE
		addtimer(CALLBACK(src, PROC_REF(unbusy)), 30)
		show_blurb(GLOB.player_list, 45, "Clues Found: | [current_clues_found]/[needed_amount] |", null, "EAST-1,NORTH-2", "right", COLOR_GRAY, null, null, 1)
		spawn(15)
			show_blurb(GLOB.player_list, 35, "Hunt Timer: | <span class='langchat' style='color:#ff0000'>[duration2text()]</span> |", null, "EAST-1,NORTH-3", "right", COLOR_GRAY, null, null, 1)

		if(current_clues_found >= needed_amount)
			spawn(30)
				show_blurb(GLOB.player_list, 35, "WIPE OUT THE STAIN", null, "EAST-1,NORTH-5", "right", COLOR_RED, null, null, 1)
		return TRUE
	else
		return FALSE

/obj/structure/criptic/mission_controller/proc/unbusy()
	busy_now = FALSE

/obj/structure/criptic/mission_controller/proc/start_the_hunt()
	for(var/obj/structure/criptic/clue/C in world)
		needed_amount += 1

	show_mission_name()
	show_current_progress()

	START_PROCESSING(SSobj,src)

/obj/structure/criptic/mission_controller/process()
	if(automatic_messaging_delay <= 0)
		automatic_messaging_delay = 300
		show_current_progress()

	else
		automatic_messaging_delay -= 1

/obj/structure/criptic/clue
	var/revealed = FALSE

	icon = 'core_ru/code/modules/criptid_hunting/effects.dmi'
	icon_state = "nothing"
	var/icon_state_found = "blackgoo"

/obj/structure/criptic/clue/proc/reveal_itself()
	revealed = TRUE
	icon_state = "[icon_state_found]"

/obj/structure/criptic/clue/uv/reveal_itself()
	for(var/obj/structure/criptic/mission_controller/M in world)
		M.current_clues_found += 1
		M.show_current_progress()

	revealed = TRUE
	alpha = 0
	icon_state = "[icon_state_found]"
	animate(src, alpha = 100, time = 1 SECONDS, easing = SINE_EASING | EASE_IN)

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

/obj/structure/criptic/clue/photo
	icon = 'core_ru/code/modules/criptid_hunting/effects_newer.dmi'
	icon_state_found = "static"
	mouse_opacity = FALSE

/obj/structure/criptic/clue/photo/reveal_itself()
	for(var/obj/structure/criptic/mission_controller/M in world)
		M.current_clues_found += 1
		M.show_current_progress()

	revealed = TRUE
	alpha = 0
	icon_state = "[icon_state_found]"
	animate(src, alpha = 100, time = 1 SECONDS, easing = SINE_EASING | EASE_IN)

/obj/structure/criptic/clue/sound_clue
	icon = 'core_ru/code/modules/criptid_hunting/effects_newer.dmi'
	icon_state_found = "void_chill_oh_fuck"
	mouse_opacity = FALSE
	var/hinted = FALSE
	var/mob/living/carbon/human/connected
	var/remove_hint_after = 0

/obj/structure/criptic/clue/sound_clue/process()
	if(hinted && remove_hint_after > 0)
		remove_hint_after -= 1

	if(hinted && remove_hint_after <= 0)
		if(src in connected.revealed_hints)
			connected.hide_hint(src)
		hinted = FALSE
		STOP_PROCESSING(SSobj,src)

/obj/structure/criptic/clue/sound_clue/reveal_itself()
	var/list/creepyasssounds = list('sound/effects/ghost.ogg', 'sound/effects/ghost2.ogg', 'sound/effects/Heart Beat.ogg', 'sound/effects/screech.ogg',\
		'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg', 'sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg',\
		'sound/hallucinations/growl3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg',\
		'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',\
		'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg', 'sound/hallucinations/wail.ogg')
	playsound(loc, pick(creepyasssounds), 25, 1)

	for(var/obj/structure/criptic/mission_controller/M in world)
		M.current_clues_found += 1
		M.show_current_progress()

	revealed = TRUE
	alpha = 0
	icon_state = "[icon_state_found]"
	animate(src, alpha = 100, time = 1 SECONDS, easing = SINE_EASING | EASE_IN)

/obj/item/criptic/instrument
	name = "paranormal phone"
	desc = "Can detect abnormalities nearby while active"

	var/activated = FALSE
	var/passive_searching = FALSE
	var/list/clue_type_to_reveal = list(/obj/structure/criptic/clue)

	icon = 'core_ru/code/modules/criptid_hunting/phone.dmi'

	icon_state = "phone_old"
	var/icon_state_on = "phone_old_on"

	w_class = SIZE_SMALL
	flags_equip_slot = SLOT_WAIST | SLOT_SUIT_STORE

/obj/item/criptic/instrument/dropped(mob/user)
	if(passive_searching && activated)
		activated = FALSE
		icon_state = "[initial(icon_state)]"

		STOP_PROCESSING(SSobj,src)
		set_light_on(activated)
	. = ..()

/obj/item/criptic/instrument/attack_self(mob/user)
	. = ..()
	if(passive_searching && !activated)
		activated = TRUE
		icon_state = "[icon_state_on]"
		set_light_on(activated)
		START_PROCESSING(SSobj,src)
		return TRUE

	if(passive_searching && activated)
		activated = FALSE
		icon_state = "[initial(icon_state)]"
		set_light_on(activated)
		revert_instrument_effect()
		STOP_PROCESSING(SSobj,src)
		return TRUE

/obj/item/criptic/instrument/afterattack(atom/target, mob/living/carbon/human/user, proximity_flag, click_parameters)
	. = ..()

	if(istype(target, /turf/open))
		for(var/obj/structure/criptic/clue/C in target)
			if(!(C.type in clue_type_to_reveal))
				continue
			if(C.revealed)
				continue

			if(do_after(user, 20, INTERRUPT_ALL, BUSY_ICON_GENERIC))
				if(C in user.revealed_hints)
					user.hide_hint(C)
				C.reveal_itself()

/obj/item/criptic/instrument/process()
	check_for_condition()

	if(!activated)
		revert_instrument_effect()
		STOP_PROCESSING(SSobj,src)

/obj/item/criptic/instrument/proc/check_for_condition()
	return TRUE

/obj/item/criptic/instrument/proc/revert_instrument_effect()
	return TRUE

/obj/effect/temp_visual/phone_scanning
	duration = 0.5 SECONDS
	icon = 'core_ru/code/modules/criptid_hunting/effectss.dmi'
	icon_state = "ka-start"
	layer = 3
	alpha = 50

	color = COLOR_CYAN

/obj/effect/temp_visual/phone_scanning/Initialize(mapload)
	. = ..()
	animate(src, transform = matrix(5, MATRIX_SCALE), time = 3)

/obj/item/criptic/instrument/phone
	passive_searching = TRUE
	var/clue_cooldown = 10
	var/cooldown_active = FALSE

	light_color = COLOR_CYAN
	light_range = 1
	light_power = 1

	var/weeds_nearby = FALSE

/obj/item/criptic/instrument/phone/proc/buzzed()
	set waitfor = FALSE
	add_filter("buzzed", 1, list("type" = "outline", "color" = COLOR_RED, "size" = 1))
	sleep(1 SECONDS)
	remove_filter("buzzed")
	sleep(1 SECONDS)
	add_filter("buzzed", 1, list("type" = "outline", "color" = COLOR_RED, "size" = 1))
	sleep(1 SECONDS)
	remove_filter("buzzed")

/obj/item/criptic/instrument/phone/check_for_condition()
	set waitfor = FALSE
	new /obj/effect/temp_visual/phone_scanning(get_turf(loc))

	if(clue_cooldown <= 0 && cooldown_active)
		clue_cooldown = 10
		cooldown_active = FALSE
		remove_filter("activated")

	var/list/signatures = list()
	if(cooldown_active && clue_cooldown > 0)
		clue_cooldown -= 1
		return TRUE

	if(!(locate(/obj/effect/alien/weeds) in range(7,get_turf(loc))) && weeds_nearby)
		weeds_nearby = FALSE
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			show_blurb(H, 15, "Disruption are gone...for now", null, "WEST+6:22,2:14", "center", COLOR_LIGHT_GREEN, null, null, 1)
		return TRUE

	if((locate(/obj/effect/alien/weeds) in range(7,get_turf(loc))) && !weeds_nearby)
		weeds_nearby = TRUE
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			show_blurb(H, 15, "Something disrupts the signal...", null, "WEST+6:22,2:14", "center", COLOR_DARK_RED, null, null, 1)

		buzzed()
		return TRUE

	if(!weeds_nearby)

		for(var/obj/structure/criptic/clue/C in range(7,get_turf(loc)))
			if(!C.revealed)
				signatures += C

		if(length(signatures))
			playsound(loc, 'sound/machines/telephone/phone_busy.ogg', 30, 1)
			animation_flash_color(src, COLOR_CYAN)
			add_filter("activated", 1, list("type" = "outline", "color" = COLOR_CYAN, "size" = 1))

			animate(src, 3, easing = SINE_EASING|EASE_OUT, transform = matrix(10, MATRIX_ROTATE), time = 5)
			sleep(3)
			animate(src, 3, easing = SINE_EASING|EASE_IN, transform = matrix())

			if(ishuman(loc))
				var/mob/living/carbon/human/H = loc
				show_blurb(H, 15, "Phone detected something", null, "WEST+6:22,2:14", "center", COLOR_GRAY, null, null, 1)

			cooldown_active = TRUE

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

	animate(src, transform = matrix(splatter_size, MATRIX_SCALE), time = 1)
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
				H.show_hint(C)

/obj/item/criptic/instrument/uv_lamp/revert_instrument_effect()
	if(last_holder)
		for(var/atom/A as anything in last_holder.revealed_hints)
			last_holder.hide_hint(A)
		last_holder = null

/atom/movable/screen/fullscreen/flash/camera
	alpha = 0

/atom/movable/screen/fullscreen/flash/camera/Initialize()
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS, BOUNCE_EASING|EASE_IN)

/obj/item/criptic/instrument/camera
	name = "paranormal camera"
	desc = "Can reveal lost souls on use"

	clue_type_to_reveal = list(/obj/structure/criptic/clue/photo)

	icon = 'core_ru/code/modules/criptid_hunting/camera.dmi'

	icon_state = "camera_off"
	icon_state_on = "camera"
	var/cooldown_for_photo = 1 MINUTES

/obj/item/criptic/instrument/camera/attack_self(mob/user)
	. = ..()

	if(activated)
		animation_flash_color(src, COLOR_RED)
		return FALSE

	if(!activated)
		check_for_condition()
		return TRUE

/obj/item/criptic/instrument/camera/check_for_condition()
	addtimer(CALLBACK(src, PROC_REF(revert_instrument_effect)), cooldown_for_photo)
	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 15, 1)
	activated = TRUE
	for(var/obj/structure/criptic/clue/C in view(loc))
		if(!(C.type in clue_type_to_reveal))
			continue
		if(C.revealed)
			continue

		C.reveal_itself()

	animation_flash_color(src, COLOR_WHITE)
	add_filter("activated", 1, list("type" = "outline", "color" = COLOR_RED, "size" = 1))

	for(var/mob/living/carbon/human/H in view(loc))
		H.overlay_fullscreen_timer(1 SECONDS, 5, "flash",/atom/movable/screen/fullscreen/flash/camera)

/obj/item/criptic/instrument/camera/revert_instrument_effect()
	activated = FALSE
	remove_filter("activated")
	return TRUE

/obj/effect/temp_visual/laptop_scanning
	duration = 0.5 SECONDS
	icon = 'core_ru/code/modules/criptid_hunting/effectss.dmi'
	icon_state = "push"
	layer = 3
	alpha = 50

	color = COLOR_GREEN

/obj/effect/temp_visual/laptop_scanning/Initialize(mapload)
	. = ..()
	animate(src, transform = matrix(5, MATRIX_SCALE), time = 3)

/obj/item/criptic/instrument/sound_device
	name = "paranormal laptop"
	desc = "Can detect abnormal sounds nearby"

	passive_searching = TRUE
	clue_type_to_reveal = list(/obj/structure/criptic/clue/sound_clue)

	icon = 'core_ru/code/modules/criptid_hunting/items2.dmi'

	icon_state = "comp0"
	icon_state_on = "comp2"

	w_class = SIZE_SMALL
	light_color = COLOR_GREEN
	light_range = 1
	light_power = 1

	var/mob/living/carbon/human/last_holder

/obj/item/criptic/instrument/sound_device/check_for_condition()

	if(ishuman(loc))

		var/mob/living/carbon/human/H = loc
		last_holder = H
		var/obj/effect/temp_visual/laptop_scanning/L = new /obj/effect/temp_visual/laptop_scanning(get_turf(H))
		L.dir = H.dir

		switch(H.dir)
			if(NORTH)
				animate(L, pixel_x = 0, pixel_y = 96, time = 0.3 SECONDS, easing = SINE_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
			if(SOUTH)
				animate(L, pixel_x = 0, pixel_y = -96, time = 0.3 SECONDS, easing = SINE_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
			if(EAST)
				animate(L, pixel_x = 96, pixel_y = 0, time = 0.3 SECONDS, easing = SINE_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
			if(WEST)
				animate(L, pixel_x = -96, pixel_y = 0, time = 0.3 SECONDS, easing = SINE_EASING|EASE_IN, flags = ANIMATION_PARALLEL)

		var/turf/T = get_ranged_target_turf(H,H.dir,6)
		var/list/turf/open_turfs = get_line(get_turf(H),T,0)
		for(var/turf/open/O in open_turfs)
			for(var/obj/structure/criptic/clue/C in O)
				if(!(C.type in clue_type_to_reveal))
					continue
				if(C.revealed)
					continue
				if(!(C in H.revealed_hints))
					if(istype(C,/obj/structure/criptic/clue/sound_clue))
						var/obj/structure/criptic/clue/sound_clue/S = C
						S.hinted = TRUE
						S.connected = H
						S.remove_hint_after += 10
						START_PROCESSING(SSobj,S)
					H.show_hint(C)

/obj/item/criptic/instrument/sound_device/revert_instrument_effect()
	if(last_holder)
		for(var/atom/A as anything in last_holder.revealed_hints)
			last_holder.hide_hint(A)
		last_holder = null

/obj/structure/criptic/ritual
	name = "ritual circle"
	desc = "Used for ritual performing"

	icon = 'core_ru/code/modules/criptid_hunting/64x64.dmi'

	icon_state = "baali"
	pixel_x = -16
	pixel_y = -16

	alpha = 0

/obj/structure/criptic/ritual/proc/begin_the_ritual()
	set waitfor = FALSE
	animate(src, alpha = 255, time = 15 SECONDS, easing = SINE_EASING | EASE_IN)
	show_blurb(GLOB.player_list, 20, "GOOD HUNTER DOESN'T KNOW LOVE", null, "center", "center", COLOR_RED, null, null, 1)

	set_light_range(1)
	set_light_power(0.5)

	sleep(5 SECONDS)

	show_blurb(GLOB.player_list, 10, "FINISH THE JOB", null, "center", "center", COLOR_RED, null, null, 1)

	set_light_range(3)
	set_light_power(1)

	sleep(5 SECONDS)

	show_blurb(GLOB.player_list, 20, "WIPE OUT THE STAIN", null, "center", "center", COLOR_RED, null, null, 1)

	set_light_range(5)
	set_light_power(2)

/obj/item/criptic/instrument/book
	name = "book"
	desc = "Used for ritual performing"

	icon = 'core_ru/code/modules/criptid_hunting/books.dmi'

	icon_state = "arcane"
	icon_state_on = "bookofnod-1"

	var/blocker_type = /obj/structure/blocker/chime/dark
	var/arena_radius = 12

/obj/item/criptic/instrument/book/attack_self(mob/user)
	. = ..()

	var/obj/structure/criptic/mission_controller/M = locate(/obj/structure/criptic/mission_controller) in world
	var/mob/living/carbon/xenomorph/criptic_wendigo/W = locate(/mob/living/carbon/xenomorph/criptic_wendigo) in world
	if(M.current_clues_found >= M.needed_amount)
		icon_state = "[icon_state_on]"

		user.anchored = TRUE
		var/obj/structure/criptic/ritual/R = new /obj/structure/criptic/ritual(get_turf(loc))
		R.begin_the_ritual()

		if(do_after(user, 15 SECONDS, INTERRUPT_ALL, BUSY_ICON_GENERIC))
			W.forceMove(get_turf(src))
			user.anchored = FALSE

			var/list/box = RANGE_TURFS(arena_radius, loc)
			for(var/turf/T as anything in box)
				if(get_dist(T, src) < arena_radius)
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
		return TRUE
	else
		var/mob/living/carbon/human/H = loc
		animation_flash_color(src, COLOR_RED)
		show_blurb(H, 15, "We need more info before we can call the trial", null, "WEST+6:22,2:14", "center", COLOR_DARK_RED, null, null, 1)
		return TRUE

////////////////////////////////////////

/datum/equipment_preset/contractor/duty/hunter
	name = "Paranormal Hunter (Standard)"
	paygrades = list(PAY_SHORT_VAI_S = JOB_PLAYTIME_TIER_0)
	role_comm_title = "Merc"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "VAIPO Mercenary"
	rank = JOB_CONTRACTOR_ST
	skills = /datum/skills/contractor
	faction = FACTION_CONTRACTOR

/datum/equipment_preset/contractor/duty/hunter/load_gear(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new headset_type, WEAR_L_EAR)

	var/random_gear = rand(0,4)
	switch(random_gear)
		if(0)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/under/tshirt/w_br(new_human), WEAR_BODY)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(new_human), WEAR_FEET)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(new_human), WEAR_EYES)
		if(1)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/under/tshirt/gray_blu(new_human), WEAR_BODY)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/rmc, WEAR_FEET)
		if(2)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/under/tshirt/r_bla(new_human), WEAR_BODY)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)
		if(3)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket/trainee(new_human), WEAR_BODY)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(new_human), WEAR_FEET)
		if(4)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/under/colonist/boilersuit/cyan(new_human), WEAR_BODY)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine/knife(new_human), WEAR_FEET)

	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/holobadge/cord, WEAR_ACCESSORY)

	var/random_vest = rand(0,1)
	switch(random_vest)
		if(0)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/light/vest, WEAR_JACKET)
			new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/range, WEAR_IN_JACKET)
		if(1)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest/hybrisa/civilian_vest, WEAR_JACKET)

	var/random_hat = rand(0,3)
	switch(random_hat)
		if(0)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine, WEAR_HEAD)
		if(1)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/weyyu/black, WEAR_HEAD)
		if(2)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/boonie, WEAR_HEAD)
		if(3)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/head/cowboy, WEAR_HEAD)

	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran, WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full, WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/lightpack, WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/softpack/regular, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/fancy/cigarettes/wypacket, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/lighter/zippo, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre,WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/crowbar/tactical, WEAR_IN_BACK)
