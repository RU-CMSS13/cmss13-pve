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
	pop_out()
	playsound(loc,'sound/effects/pillbottle.ogg',10,TRUE)
	user.rejuvenate()
	animation_flash_color(src, COLOR_GREEN)
	user.overlay_fullscreen_timer(1 SECONDS, 5, "heal",/atom/movable/screen/fullscreen/nvg/heal)

	sleep(0.5 SECONDS)
	qdel(src)

/obj/item/criptic/utility/pills/healing/attack(mob/living/carbon/human/M, mob/user)
	. = ..()
	pop_out()
	playsound(loc,'sound/effects/pillbottle.ogg',10,TRUE)
	M.rejuvenate()
	animation_flash_color(src, COLOR_GREEN)
	M.overlay_fullscreen_timer(1 SECONDS, 5, "heal", /atom/movable/screen/fullscreen/nvg/heal)

	sleep(0.5 SECONDS)
	qdel(src)

/obj/item/criptic/utility/cigarette
	name = "cig"
	desc = "Keeps you in check"

	icon = 'core_ru/code/modules/criptid_hunting/ms_cigarettes.dmi'
	icon_state = "cig"

	w_class = SIZE_TINY
	var/list/ignore_them = list()

/obj/item/criptic/utility/cigarette/Initialize(mapload, ...)
	. = ..()
	ignore_them += typesof(/obj/item/storage,/obj/structure/flora,/obj/structure/window,/obj/structure/window_frame,/obj/structure/machinery/door,
							/obj/structure/machinery/light,/obj/structure/machinery/door_control,/obj/structure/sign,/obj/structure/surface,/obj/structure/bed,
							/obj/structure/platform,/obj/structure/platform_decoration,/obj/structure/stairs,/obj/structure/closet)

/obj/item/criptic/utility/cigarette/attack_self(mob/user)
	. = ..()
	var/list/atom/possible_points = list()
	var/list/nearby_clues = list()

	for(var/obj/structure/criptic/clue/C in range(15, get_turf(user)))
		if(C.revealed)
			continue
		nearby_clues += C

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.sanity_current >= H.sanity_max && !length(nearby_clues))
			balloon_alert(H, "Not sure if i really need it right now...", COLOR_WHITE)
			animation_flash_color(src, COLOR_RED)
			return FALSE

		show_blurb(H, 15, "I feel...slightly better", null, "WEST+6:22,2:14", "center", LIGHT_COLOR_CANDLE, null, null, 1)
		H.sanity_current = clamp(H.sanity_current + 15, 0, H.sanity_max)
		new /obj/effect/temp_visual/healing(get_turf(src))

	if(length(nearby_clues))
		for(var/atom/A in view(user.loc))
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if((A in H.revealed_hints) || (A in H.naturally_hinted))
					continue
			if(A.uv_scannable && !A.uv_scanned)
				possible_points += A

		if(!length(possible_points))
			for(var/obj/O in view(user.loc))
				if(O.type in ignore_them)
					continue
				if(!istype(O.loc,/turf/open))
					continue
				if(!O.mouse_opacity)
					continue
				possible_points += O

		if(!length(possible_points))
			for(var/turf/open/T in view(user.loc))
				if(locate(/obj/structure/stairs) in T)
					continue
				possible_points += T

		var/atom/new_clue = pick(possible_points)
		focus_on_something(new_clue,user,3 SECONDS)

		if(!new_clue.uv_scannable)
			new_clue.uv_scannable = TRUE
			new_clue.uv_slogan = "Seems interesting..."
			new_clue.uv_onfind = "It might lead us to the next evidence..."

			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.hint_visibility = 7
				H.show_hint(new_clue,"trail", 1, new_clue.uv_slogan)
				H.naturally_hinted |= new_clue

				addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/human, reset_cigbuff)), 10 SECONDS)
				addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/human, remove_from_order), new_clue), 1 MINUTES)

	pop_out()
	animation_flash_color(src, COLOR_GREEN)
	sleep(0.5 SECONDS)
	qdel(src)

/mob/living/carbon/human/proc/reset_cigbuff()
	hint_visibility = 1

/obj/item/criptic/utility/cig_pack
	name = "cigpack"
	desc = "For your goodies"

	icon = 'core_ru/code/modules/criptid_hunting/ms_cigarettes.dmi'
	icon_state = "full"

	w_class = SIZE_SMALL
	var/list/obj/item/criptic/utility/cigarette/cigarettes = list()
	var/max_slots = 5

/obj/item/criptic/utility/cig_pack/Initialize(mapload, ...)
	. = ..()

	for(var/amount in 0 to rand(1,max_slots))
		cigarettes += new /obj/item/criptic/utility/cigarette(src)

/obj/item/criptic/utility/cig_pack/attackby(obj/item/W, mob/user)
	. = ..()

	if(istype(W,/obj/item/criptic/utility/cigarette))
		if(length(cigarettes) < max_slots)
			cigarettes += W
			user.drop_held_item(W)

			W.forceMove(src)
			if(icon_state != "full")
				icon_state = "full"
		else
			animation_flash_color(W, COLOR_RED)
			balloon_alert(user, "Pack is full!", COLOR_WHITE)
		return TRUE

/obj/item/criptic/utility/cig_pack/attack_self(mob/user)
	. = ..()
	if(length(cigarettes))
		var/cig_to_remove = pick(cigarettes)
		cigarettes -= cig_to_remove
		user.put_in_hands(cig_to_remove)

		animate(src, time = 3, easing = SINE_EASING|EASE_OUT, transform = matrix(10, MATRIX_ROTATE))
		sleep(3)
		animate(src, time = 3, easing = SINE_EASING|EASE_IN, transform = matrix())

		if(!length(cigarettes))
			icon_state = "empty"
		return TRUE

	animation_flash_color(src, COLOR_RED)
	balloon_alert(user, "Pack is empty!", COLOR_WHITE)
