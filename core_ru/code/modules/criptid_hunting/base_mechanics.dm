/image/hint
/mob/living/carbon/human
	var/list/revealed_hints = list()

/mob/living/carbon/human/proc/show_hint(atom/A)
	if(!client || (A in revealed_hints))
		return

	var/image/hint/new_hint = new /image/hint('core_ru/code/modules/criptid_hunting/disciplines.dmi', A, "auspex-on", layer = HUD_PLANE)

	new_hint.alpha = 0
	new_hint.pixel_x = pixel_x + 5
	new_hint.pixel_y = pixel_y + 5
	new_hint.plane = HUD_PLANE

	animate(new_hint, alpha = 255, pixel_x = src.pixel_x, pixel_y = src.pixel_y, time = 0.3 SECONDS, easing = SINE_EASING|EASE_OUT)

	client.images += new_hint
	revealed_hints[A] = new_hint

/mob/living/carbon/human/proc/hide_hint(atom/A)
	if(!client || !(A in revealed_hints))
		return

	var/image/hint/the_hint = revealed_hints[A]

	animate(the_hint, alpha = 0, pixel_x = src.pixel_x, pixel_y = src.pixel_y - 10, time = 0.3 SECONDS, easing = SINE_EASING|EASE_IN)

	spawn(0.3 SECONDS)
		if(client)
			client.images -= the_hint
		revealed_hints -= A

/obj/structure/criptic/mission_controller
	icon = 'icons/landmarks.dmi'
	icon_state = "x2"

	var/current_clues_found = 0
	var/needed_amount = 0

	var/mission_name = "Охота" // also for GM purposes
	var/automatic_messaging_delay = 300

/obj/structure/criptic/mission_controller/proc/show_mission_name()
	show_blurb(GLOB.player_list, 30, "[mission_name]", null, "center", "center", color, null, null, 1)

/obj/structure/criptic/mission_controller/proc/show_current_progress()
	show_blurb(GLOB.player_list, 40, "Необходимых доказательств найдено: [current_clues_found]/[needed_amount]", null, "WEST+0:6,NORTH-1", "WEST+0:6,NORTH-1", COLOR_GRAY, null, null, 1)
	spawn(15)
		show_blurb(GLOB.player_list, 25, "Охота длится: <span class='langchat' style='color:#ff0000'>[duration2text()]</span>", null, "WEST+0:6,NORTH-2", "WEST+0:6,NORTH-2", COLOR_GRAY, null, null, 1)

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
	icon_state = "blackgoo"

/obj/structure/criptic/clue/proc/reveal_itself()
	revealed = TRUE

/obj/structure/criptic/clue/uv/plasm
	alpha = 0
	mouse_opacity = FALSE

/obj/structure/criptic/clue/uv/plasm/reveal_itself()
	for(var/obj/structure/criptic/mission_controller/M in world)
		M.current_clues_found += 1

	revealed = TRUE
	animate(alpha = 100, time = 1 SECONDS, easing = SINE_EASING | EASE_IN)

/obj/structure/criptic/clue/uv/runes
	icon = 'core_ru/code/modules/criptid_hunting/vampire_clans.dmi'
	icon_state = "tremere"
	alpha = 0
	mouse_opacity = FALSE

/obj/structure/criptic/clue/uv/runes/reveal_itself()
	for(var/obj/structure/criptic/mission_controller/M in world)
		M.current_clues_found += 1

	revealed = TRUE
	animate(alpha = 100, time = 1 SECONDS, easing = SINE_EASING | EASE_IN)

/obj/item/criptic/instrument
	name = "paranormal phone"
	desc = "Can detect abnormalities nearby while active"

	var/activated = FALSE
	var/passive_searching = FALSE
	var/list/clue_type_to_reveal = list(/obj/structure/criptic/clue)

	icon = 'core_ru/code/modules/criptid_hunting/phone.dmi'

	icon_state = "phone_old"
	var/icon_state_on = "phone_old_on"

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

			if(do_after(user, 10, INTERRUPT_ALL, BUSY_ICON_GENERIC))
				if(C in user.revealed_hints)
					user.hide_hint(C)
				C.reveal_itself()


/obj/item/criptic/instrument/process()
	check_for_condition()

	if(!activated)
		revert_instrument_effect()
		STOP_PROCESSING(SSobj,src)

/obj/item/criptic/instrument/proc/check_for_condition()
	return

/obj/item/criptic/instrument/proc/revert_instrument_effect()
	return

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

	var/list/signatures = list()
	if(cooldown_active && clue_cooldown > 0)
		clue_cooldown -= 1
		return

	for(var/obj/structure/criptic/clue/C in range(3,get_turf(loc)))
		if(!C.revealed)
			signatures += C

	if(length(signatures))
		playsound(loc, 'sound/machines/telephone/phone_busy.ogg', 30, 1)

		animate(src, 3, easing = SINE_EASING|EASE_OUT, transform = matrix(10, MATRIX_ROTATE), time = 5)
		sleep(3)
		animate(src, 3, easing = SINE_EASING|EASE_IN, transform = matrix())

		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			show_blurb(H, 15, "Телефон что-то засёк", null, "WEST+6:13,2:8", "WEST+6:13,2:8", COLOR_GRAY, null, null, 1)

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
	light_range = 3
	light_power = 0.7

	var/mob/living/carbon/human/last_holder

/obj/item/criptic/instrument/uv_lamp/check_for_condition()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		last_holder = H

		for(var/obj/structure/criptic/clue/C in H.revealed_hints)
			if(get_dist(C,H) > 2)
				H.show_hint(C)

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
