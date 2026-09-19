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
					H.show_hint(C, C.clue_icon_state)

/obj/item/criptic/instrument/sound_device/revert_instrument_effect()
	if(last_holder)
		for(var/atom/A as anything in last_holder.revealed_hints)
			last_holder.hide_hint(A)
		last_holder = null
