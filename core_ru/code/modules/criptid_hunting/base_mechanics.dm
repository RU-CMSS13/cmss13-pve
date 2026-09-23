/atom/movable/screen/fullscreen/crt/criptic
	icon_state = "crt"
	layer = FULLSCREEN_LAYER
	blend_mode = BLEND_OVERLAY
	alpha = 200

/atom
	var/uv_scannable = FALSE
	var/uv_scanned = FALSE

	var/uv_slogan = "..."
	var/uv_onfind = "..."

/image/hint
/mob/living/carbon/human
	var/list/revealed_hints = list()
	var/list/naturally_hinted = list()
	var/list/brush_list = list()
	var/hint_visibility = 1
	var/brushable_radius = 7

/mob/living/carbon/human/Life()

	if(ishuman(src) && client)
		for(var/atom/A as anything in revealed_hints)
			if((get_dist(src, A) > hint_visibility) && (A in naturally_hinted))
				hide_hint(A)
			if((get_dist(src, A) > brushable_radius) && (A in brush_list))
				hide_hint(A)

		for(var/atom/A in range(hint_visibility,src))
			if(!(A in revealed_hints) && A.uv_scannable && !A.uv_scanned)
				show_hint(A,"trail", 1, A.uv_slogan)
				naturally_hinted += A

		for(var/obj/structure/criptic/clue/item/C in range(brushable_radius,src))
			if(!(C in revealed_hints) && !C.revealed && C.covered)
				show_hint(C, C.clue_icon_state)
				brush_list += C

	. = ..()

/mob/living/carbon/human/proc/show_hint(atom/A, icon_to_show = "auspex", show_maptext = 0, maptext_text = "...")
	if(!client || (A in revealed_hints))
		return

	var/image/hint/new_hint = new /image/hint('core_ru/code/modules/criptid_hunting/disciplines.dmi', A, "[icon_to_show]", layer = HUD_LAYER)

	new_hint.alpha = 0
	new_hint.pixel_x = pixel_x + 5
	new_hint.pixel_y = pixel_y + 5
	new_hint.plane = HUD_PLANE

	new_hint.maptext_width = 480
	new_hint.maptext_height = 480
	new_hint.maptext_y = 15

	animate(new_hint, alpha = 255, pixel_x = A.pixel_x+8, pixel_y = A.pixel_y+12, time = 0.3 SECONDS, easing = SINE_EASING|EASE_OUT)

	if(show_maptext)
		new_hint.show_cluetext(maptext_text, null, "center", COLOR_GRAY, 1)

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

	var/weakness = "Salt"
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

/atom/movable/screen/exit_button
	name = "EXIT"
	desc = "EXIT"

	plane = HUD_PLANE
	layer = HUD_LAYER

	icon = 'icons/mob/hud/actions.dmi'
	icon_state = "hologram_exit"

	screen_loc = "CENTER-6,CENTER"
	var/obj/structure/criptic/clue/attached_to

/atom/movable/screen/exit_button/Initialize(mapload, ...)
	. = ..()

	overlays += image('icons/mob/hud/actions.dmi', "template", layer = src.layer - 0.1)

/atom/movable/screen/exit_button/clicked(mob/user)
	attached_to.busy = FALSE

	animate(src, alpha = 0, time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN, flags = ANIMATION_PARALLEL)
	for(var/atom/movable/screen/dirt/D in attached_to.cover)
		animate(D, alpha = 0, time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN, flags = ANIMATION_PARALLEL)

	animate(attached_to.connected_image, alpha = 0, time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN, flags = ANIMATION_PARALLEL)

	sleep(0.5 SECONDS)

	user.client.screen -= src
	alpha = 255

	user.client.screen -= attached_to.cover
	user.client.screen -= attached_to.connected_image

	user.clear_fullscreen("background")

	for(var/atom/movable/screen/dirt/D in attached_to.cover)
		D.alpha = 255
	attached_to.connected_image.alpha = 255

	user.client.mouse_pointer_icon = initial(user.client.mouse_pointer_icon)
	REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, INTERACTION_TRAIT)

/atom/movable/screen/dirt
	plane = HUD_PLANE
	layer = HUD_LAYER

	icon = 'icons/turf/floors/auto_strata_grass.dmi'
	icon_state = "grass_0_mud"

	screen_loc = "CENTER,CENTER"

/atom/movable/screen/dirt/Initialize()
	. = ..()
	transform = matrix(3, 3, MATRIX_SCALE)*matrix(rand(-96,96), rand(-96,96), MATRIX_TRANSLATE)

/atom/movable/screen/dirt/clicked(mob/user)
	var/mob/living/carbon/human/H = user
	var/obj/item/criptic/instrument/held_item = H.get_held_item()

	if(istype(held_item,/obj/item/criptic/instrument/brush))
		animate(src, alpha = 0, transform = matrix(0.1, MATRIX_SCALE), time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN)
		sleep(0.5 SECONDS)
		H.client.screen -= src
		qdel(src)

/atom/movable/screen/connected_representation
	plane = HUD_PLANE
	layer = 18.9

	screen_loc = "CENTER,CENTER"
	var/obj/structure/criptic/clue/attached_to

/atom/movable/screen/connected_representation/Initialize()
	. = ..()
	transform = matrix(2, 2, MATRIX_SCALE)*matrix(rand(-64,64), rand(-64,64), MATRIX_TRANSLATE)

/atom/movable/screen/connected_representation/clicked(mob/user)
	var/mob/living/carbon/human/H = user

	animate(src, alpha = 0, transform = matrix(0.5, MATRIX_SCALE)*matrix(0, -96, MATRIX_TRANSLATE), time = 0.5 SECONDS, easing = BOUNCE_EASING | EASE_OUT, flags = ANIMATION_PARALLEL)
	for(var/atom/movable/screen/dirt/D in attached_to.cover)
		animate(D, alpha = 0, transform = matrix(3, MATRIX_SCALE)*matrix(0, -72, MATRIX_TRANSLATE), time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN, flags = ANIMATION_PARALLEL)

	animate(attached_to.exit, alpha = 0, transform = matrix(0, -64, MATRIX_TRANSLATE), time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN, flags = ANIMATION_PARALLEL)
	sleep(0.5 SECONDS)

	attached_to.busy = FALSE
	H.client.screen -= src

	H.client.screen -= attached_to.cover
	H.client.screen -= attached_to.exit

	H.clear_fullscreen("background")

	if(attached_to in H.revealed_hints)
		H.hide_hint(attached_to)
	attached_to.reveal_itself()
	attached_to.covered = FALSE

	H.client.mouse_pointer_icon = initial(H.client.mouse_pointer_icon)
	REMOVE_TRAIT(H, TRAIT_IMMOBILIZED, INTERACTION_TRAIT)

/obj/structure/criptic/clue
	var/revealed = FALSE
	var/covered = FALSE

	icon = 'core_ru/code/modules/criptid_hunting/effects.dmi'
	icon_state = "nothing"
	var/icon_state_found = "blackgoo"
	var/clue_icon_state = "auspex"

	var/list/atom/movable/screen/cover = list()
	var/atom/movable/screen/connected_representation/connected_image
	var/atom/movable/screen/exit_button/exit

	var/busy = FALSE

/obj/structure/criptic/clue/Initialize(mapload, ...)
	. = ..()

	if(covered)
		generate_cover()
		clue_icon_state = "animalism"

/obj/structure/criptic/clue/proc/generate_cover()
	if(!covered)
		covered = TRUE

	if(length(cover))
		for(var/atom/movable/screen/dirt/D in cover)
			cover -= D
			qdel(D)

	var/amount_of_dirt = rand(16,24)
	for(var/i in 0 to amount_of_dirt)
		cover += new /atom/movable/screen/dirt()

	exit = new /atom/movable/screen/exit_button()
	exit.attached_to = src

	connected_image = new /atom/movable/screen/connected_representation()
	connected_image.icon = icon
	connected_image.icon_state = icon_state_found
	connected_image.attached_to = src
	connected_image.name = name
	connected_image.desc = desc

/obj/structure/criptic/clue/proc/start_arch_minigame(mob/user)
	busy = TRUE
	ADD_TRAIT(user, TRAIT_IMMOBILIZED, INTERACTION_TRAIT)

	user.overlay_fullscreen("background",/atom/movable/screen/fullscreen/crt/criptic)

	user.client.screen += exit
	user.client.screen += connected_image
	user.client.screen += cover

	user.client.mouse_pointer_icon = 'core_ru/code/modules/criptid_hunting/misc.dmi'

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

			if(!C.covered && do_after(user, 20, INTERRUPT_ALL, BUSY_ICON_GENERIC))
				if(C in user.revealed_hints)
					user.hide_hint(C)
				C.reveal_itself()
				return TRUE
			if(C.covered && !C.busy && istype(src,/obj/item/criptic/instrument/brush))
				C.start_arch_minigame(user)
				return TRUE

/obj/item/criptic/instrument/process()
	check_for_condition()

	if(!activated)
		revert_instrument_effect()
		STOP_PROCESSING(SSobj,src)

/obj/item/criptic/instrument/proc/check_for_condition()
	return TRUE

/obj/item/criptic/instrument/proc/revert_instrument_effect()
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
	var/warning_cooldown = 10
	var/warning_cooldown_active = FALSE
	var/clue_cooldown = 10
	var/cooldown_active = FALSE

	light_color = COLOR_CYAN
	light_range = 1
	light_power = 1

	clue_type_to_reveal = list()
	var/weeds_nearby = FALSE
	var/altmode = FALSE

/obj/item/criptic/instrument/phone/clicked(mob/user, list/mods)
	if(mods[ALT_CLICK])
		if(!CAN_PICKUP(user, src))
			return ..()
		altmode = !altmode
		if(altmode)
			light_color = COLOR_GREEN
		if(!altmode)
			light_color = COLOR_CYAN
		return TRUE
	return ..()

/obj/item/criptic/instrument/phone/proc/buzzed()
	set waitfor = FALSE
	add_filter("buzzed", 1, list("type" = "outline", "color" = COLOR_RED, "size" = 1))
	sleep(1 SECONDS)
	remove_filter("buzzed")
	sleep(1 SECONDS)
	add_filter("buzzed", 1, list("type" = "outline", "color" = COLOR_RED, "size" = 1))
	sleep(1 SECONDS)
	remove_filter("buzzed")

/obj/item/criptic/instrument/phone/proc/narrow_scan()
	if(warning_cooldown <= 0 && warning_cooldown_active)
		warning_cooldown = 10
		warning_cooldown_active = FALSE

	if(ishuman(loc))

		var/mob/living/carbon/human/H = loc
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

		var/turf/T = get_ranged_target_turf(H,H.dir,7)
		var/list/turf/open_turfs = get_line(get_turf(H),T,0)

		var/obj/effect/alien/weeds/closest_weeds
		var/nearest_range = 10

		for(var/turf/open/O in open_turfs)
			for(var/obj/effect/alien/weeds/W in O)
				var/dist_between = get_dist(W,H)
				if(dist_between < nearest_range)
					nearest_range = dist_between
					closest_weeds = W

		if(closest_weeds)
			open_turfs.Cut()
			open_turfs = get_line(get_turf(H),get_turf(closest_weeds),0)

			if(warning_cooldown_active && warning_cooldown > 0)
				warning_cooldown -= 1
			else
				warning_cooldown_active = TRUE
				show_blurb(H, 15, "Seems like the signal will not go very far in this direction...", null, "WEST+6:22,2:14", "center", COLOR_DARK_RED, null, null, 1)

		var/list/clues = list()
		for(var/turf/open/O in open_turfs)
			for(var/obj/structure/criptic/clue/C in O)
				if(C.revealed)
					continue
				clues += C

		if(length(clues))
			animation_flash_color(src, COLOR_GREEN)
			add_filter("activated2", 1, list("type" = "outline", "color" = COLOR_GREEN, "size" = 1))

			animate(src, time = 3, easing = SINE_EASING|EASE_OUT, transform = matrix(10, MATRIX_ROTATE))
			sleep(3)
			animate(src, time = 3, easing = SINE_EASING|EASE_IN, transform = matrix())
			remove_filter("activated2")

			for(var/turf/open/O in open_turfs)
				animation_flash_color(O, COLOR_GREEN)

/obj/item/criptic/instrument/phone/proc/passive_scan()
	new /obj/effect/temp_visual/phone_scanning(get_turf(loc))

	if(clue_cooldown <= 0 && cooldown_active)
		clue_cooldown = 10
		cooldown_active = FALSE
		remove_filter("activated")

	var/list/signatures = list()
	if(cooldown_active && clue_cooldown > 0)
		clue_cooldown -= 1
		return TRUE

	if(!(locate(/obj/effect/alien/weeds) in range(10,get_turf(loc))) && weeds_nearby)
		weeds_nearby = FALSE
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			show_blurb(H, 15, "Disruption are gone...for now", null, "WEST+6:22,2:14", "center", COLOR_LIGHT_GREEN, null, null, 1)
		return TRUE

	if((locate(/obj/effect/alien/weeds) in range(10,get_turf(loc))) && !weeds_nearby)
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

			animate(src, time = 3, easing = SINE_EASING|EASE_OUT, transform = matrix(10, MATRIX_ROTATE))
			sleep(3)
			animate(src, time = 3, easing = SINE_EASING|EASE_IN, transform = matrix())

			if(ishuman(loc))
				var/mob/living/carbon/human/H = loc
				show_blurb(H, 15, "Phone detected something", null, "WEST+6:22,2:14", "center", COLOR_GRAY, null, null, 1)

			cooldown_active = TRUE

/obj/item/criptic/instrument/phone/check_for_condition()
	set waitfor = FALSE
	if(altmode)
		narrow_scan()
	else
		passive_scan()

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
	if(M.current_clues_found >= M.needed_amount && !activated)
		icon_state = "[icon_state_on]"
		activated = TRUE

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
