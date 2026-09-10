/image/hint
/mob/living/carbon/human
	var/list/revealed_hints = list()

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

	for(var/obj/structure/criptic/clue/C in range(5,get_turf(loc)))
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
	light_power = 0.7

	var/mob/living/carbon/human/last_holder

/obj/item/criptic/instrument/uv_lamp/check_for_condition()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		last_holder = H

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
	var/list/atom/hintlist = list()

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
					if(!(C in hintlist))
						hintlist += C
					H.show_hint(C)

		addtimer(CALLBACK(src, PROC_REF(remove_hints)), 10 SECONDS)

/obj/item/criptic/instrument/sound_device/proc/remove_hints()
	if(last_holder)
		for(var/atom/A as anything in hintlist)
			if(A in last_holder.revealed_hints)
				last_holder.hide_hint(A)
		last_holder = null
	hintlist.Cut()

/obj/item/criptic/instrument/sound_device/revert_instrument_effect()
	if(last_holder)
		for(var/atom/A as anything in last_holder.revealed_hints)
			last_holder.hide_hint(A)
		last_holder = null
	hintlist.Cut()
