/mob/living/carbon/human
	var/atom/movable/screen/health_horror/health_horror
	var/health_horror_current = 3

/mob/living/carbon/human/Life()
	CAN_BE_REDEFINED(TRUE)
	if(ishuman(src) && client)
		if(health_horror && !(health_horror in client.screen))
			client.screen += health_horror

	. = ..()

/mob/living/carbon/human/proc/create_health()
	health_horror = new /atom/movable/screen/health_horror(src)
	if(ishuman(src) && client)
		client.screen += health_horror

/atom/movable/screen/health_horror
	name = "health"
	desc = "health"
	mouse_opacity = FALSE

	plane = HUD_PLANE
	layer = HUD_LAYER

	icon = 'core_ru/code/modules/criptid_hunting/health.dmi'
	icon_state = "health_3"

	screen_loc = "CENTER-0.8,CENTER+6.4"

/atom/movable/screen/health_horror/proc/change_it(new_health = 3)
	icon_state = "health_[new_health]"
	animate(src, transform = matrix(2, 0, MATRIX_TRANSLATE), time = 0.5, easing = EASE_IN)
	animate(transform = matrix(-2, 0, MATRIX_TRANSLATE), time = 1)
	animate(transform = matrix(0, 0, MATRIX_TRANSLATE), time = 0.3, easing = EASE_OUT)

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

	if(user.health_horror_current <= 1)
		balloon_alert(user, "Seems the damage is too severe...", COLOR_WHITE)
		animation_flash_color(src, COLOR_RED)
		return FALSE

	pop_out()
	playsound(loc,'sound/effects/pillbottle.ogg',10,TRUE)
	user.rejuvenate()
	animation_flash_color(src, COLOR_GREEN)
	user.overlay_fullscreen_timer(1 SECONDS, 5, "heal",/atom/movable/screen/fullscreen/nvg/heal)
	user.health_horror_current -= 1
	if(user.client)
		user.health_horror.change_it(user.health_horror_current)

	sleep(0.5 SECONDS)
	qdel(src)

/obj/item/criptic/utility/pills/healing/attack(mob/living/carbon/human/M, mob/user)
	. = ..()
	if(M.health_horror_current <= 1)
		balloon_alert(user, "Seems the damage is too severe...", COLOR_WHITE)
		animation_flash_color(src, COLOR_RED)
		return FALSE

	pop_out()
	playsound(loc,'sound/effects/pillbottle.ogg',10,TRUE)
	M.rejuvenate()
	animation_flash_color(src, COLOR_GREEN)
	M.overlay_fullscreen_timer(1 SECONDS, 5, "heal", /atom/movable/screen/fullscreen/nvg/heal)
	M.health_horror_current -= 1
	if(M.client)
		M.health_horror.change_it(M.health_horror_current)

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

	for(var/amount in 1 to rand(2,max_slots))
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

/atom/movable/screen/temperature/value
	name = "temperature"
	desc = "temperature"
	mouse_opacity = FALSE

	plane = HUD_PLANE
	layer = HUD_LAYER

	icon = 'core_ru/code/modules/criptid_hunting/temperature_value.dmi'
	icon_state = "value"

	screen_loc = "CENTER+1,CENTER-6"
	var/atom/movable/screen/temperature/arrow/arrow
	var/obj/item/criptic/utility/temp_meter/meter

/atom/movable/screen/temperature/value/Initialize(mapload, ...)
	. = ..()
	arrow = new /atom/movable/screen/temperature/arrow(src)
	arrow.layer = layer + 0.1

/atom/movable/screen/temperature/value/proc/show_it(mob/player)
	alpha = 0
	arrow.alpha = 0

	screen_loc = "CENTER+1,CENTER-7"
	arrow.screen_loc = "CENTER+1,CENTER-7"

	if(arrow in player.client.screen)
		player.client.screen -= arrow
	if(src in player.client.screen)
		player.client.screen -= src

	player.client.screen += src
	player.client.screen += arrow

	animate(src, alpha = 255, transform = matrix(0, 64, MATRIX_TRANSLATE), time = 0.5 SECONDS, easing = SINE_EASING | EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(arrow, alpha = 255, transform = matrix(0, 64, MATRIX_TRANSLATE), time = 0.5 SECONDS, easing = SINE_EASING | EASE_OUT, flags = ANIMATION_PARALLEL)

/atom/movable/screen/temperature/value/proc/hide_it(mob/player)
	animate(src, alpha = 0, transform = matrix(0, 0, MATRIX_TRANSLATE), time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN, flags = ANIMATION_PARALLEL)
	animate(arrow, alpha = 0, transform = matrix(0, 0, MATRIX_TRANSLATE), time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN, flags = ANIMATION_PARALLEL)
	sleep(0.5 SECONDS)
	player.client.screen -= src
	player.client.screen -= arrow
	screen_loc = "CENTER+1,CENTER-6"
	arrow.screen_loc = "CENTER+1,CENTER-6"

/atom/movable/screen/temperature/arrow
	name = "temperature"
	desc = "temperature"
	mouse_opacity = FALSE

	plane = HUD_PLANE
	layer = HUD_LAYER

	icon = 'core_ru/code/modules/criptid_hunting/temperature_value.dmi'
	icon_state = "arrow"

	screen_loc = "CENTER+1,CENTER-6"

/atom/movable/screen/temperature/arrow/proc/adjust_value(value = 0)
	animate(src, transform = matrix(10 * -value, MATRIX_ROTATE)*matrix(0, 64, MATRIX_TRANSLATE), time = 0.5 SECONDS, easing = SINE_EASING | EASE_OUT, flags = ANIMATION_PARALLEL)

/obj/item/criptic/utility/temp_meter
	name = "temperature meter"
	desc = "For checking your surroundings"

	icon = 'core_ru/code/modules/criptid_hunting/items3.dmi'
	icon_state = "temp_meter"

	w_class = SIZE_SMALL
	var/atom/movable/screen/temperature/value/value
	var/mob/living/current_user

/obj/item/criptic/utility/temp_meter/Initialize(mapload, ...)
	. = ..()

	value = new /atom/movable/screen/temperature/value(src)

/obj/item/criptic/utility/temp_meter/dropped(mob/user)
	if(current_user)
		icon_state = "temp_meter"
		value.hide_it(current_user)
		current_user = null
		remove_filter("active")
		STOP_PROCESSING(SSobj,src)

	. = ..()

/obj/item/criptic/utility/temp_meter/attack_self(mob/user)
	. = ..()
	if(current_user == user && icon_state == "temp_meter_active")
		icon_state = "temp_meter"
		value.hide_it(user)
		current_user = null
		remove_filter("active")
		STOP_PROCESSING(SSobj,src)
		return TRUE

	add_filter("active", 1, list("type" = "outline", "color" = COLOR_GREEN, "size" = 1))
	icon_state = "temp_meter_active"
	current_user = user
	value.show_it(user)
	START_PROCESSING(SSobj,src)

/obj/item/criptic/utility/temp_meter/process()
	var/list/nearby_clues = list()

	for(var/obj/structure/criptic/clue/C in range(10, get_turf(loc)))
		if(C.revealed)
			continue
		if(!C.cold)
			continue
		nearby_clues += C

	if(!length(nearby_clues))
		value.arrow.adjust_value(0)

	else
		var/clue_to_check = pick(nearby_clues)
		var/value_to_show = 0

		switch(get_dist(get_turf(clue_to_check),get_turf(loc)))
			if(-INFINITY to 1)
				value_to_show = 18
			if(2 to 4)
				value_to_show = 12
			if(5 to 7)
				value_to_show = 9
			if(8 to 10)
				value_to_show = 6

		value.arrow.adjust_value(value_to_show)

/datum/reagent/medical/adrenaline_concentrated_nodamage
	name = "Concentrated B-Adrenaline"
	id = "adrenaline_concentrated_nodamage"
	description = "A natural muscle and heart stimulant that is in a high concerntration mixed with exteme amount of healing compounds. Useful for restarting the heart and preventing unconciousness but in this concentrated form it will cause minor suffocation. Overdosing may stress the heart and cause tissue damage."
	reagent_state = LIQUID
	color = "#FFE702" // Yellow-ish
	overdose = LOWM_REAGENTS_OVERDOSE
	overdose_critical = LOWM_REAGENTS_OVERDOSE_CRITICAL
	custom_metabolism = AMOUNT_PER_TIME(1, 10 SECONDS)
	chemclass = CHEM_CLASS_COMMON
	properties = list(PROPERTY_PAINKILLING = 10, PROPERTY_ELECTROGENETIC = 6, PROPERTY_OXYGENATING = 3, PROPERTY_REVITALIZING = 1, PROPERTY_INTRAVENOUS = 1, PROPERTY_DEFIBRILLATING = 1)
	flags = REAGENT_TYPE_MEDICAL | REAGENT_SCANNABLE

/obj/item/criptic/utility/pills/drug
	name = "pills"
	desc = "Keeps you in check"

	icon = 'core_ru/code/modules/criptid_hunting/medical.dmi'
	icon_state = "pillb"

	w_class = SIZE_TINY

	var/list/chemicals_to_inject = list(
		"oxycodone" = 20,
		"bicaridine" = 30,
		"kelotane" = 30,
		"meralyne" = 15,
		"dermaline" = 15,
		"inaprovaline" = 30,
		"adrenaline_concentrated_nodamage" = 10,
		"ultrazine" = 10
	)

/obj/item/criptic/utility/pills/drug/Initialize(mapload, ...)
	. = ..()
	icon_state = "pill[pick("b","d","g")]"

/obj/item/criptic/utility/pills/drug/attack_self(mob/living/carbon/human/user)
	. = ..()
	pop_out()
	playsound(loc,'sound/effects/pillbottle.ogg',10,TRUE)
	user.restore_blood()

	for(var/chemical in chemicals_to_inject)
		user.reagents.add_reagent(chemical, chemicals_to_inject[chemical])

	animation_flash_color(src, COLOR_GREEN)
	sleep(0.5 SECONDS)
	qdel(src)

/obj/item/criptic/utility/pills/drug/attack(mob/living/carbon/human/M, mob/user)
	. = ..()
	pop_out()
	playsound(loc,'sound/effects/pillbottle.ogg',10,TRUE)

	M.restore_blood()
	for(var/chemical in chemicals_to_inject)
		M.reagents.add_reagent(chemical, chemicals_to_inject[chemical])

	animation_flash_color(src, COLOR_GREEN)
	sleep(0.5 SECONDS)
	qdel(src)

/obj/item/criptic/utility/drug_storage
	name = "pill storage"
	desc = "For your goodies"

	icon = 'core_ru/code/modules/criptid_hunting/medical.dmi'
	icon_state = "ifak"

	w_class = SIZE_SMALL
	var/list/obj/item/criptic/utility/pills/drug/drugs = list()
	var/max_slots = 5

/obj/item/criptic/utility/drug_storage/Initialize(mapload, ...)
	. = ..()

	for(var/amount in 1 to max_slots)
		drugs += new /obj/item/criptic/utility/pills/drug(src)

/obj/item/criptic/utility/drug_storage/attackby(obj/item/W, mob/user)
	. = ..()

	if(istype(W,/obj/item/criptic/utility/pills/drug))
		if(length(drugs) < max_slots)
			if(length(drugs) <= 0)
				icon_state = "ifak_empty"
			else
				icon_state = "ifak_open"
			drugs += W
			user.drop_held_item(W)
			W.forceMove(src)

			sleep(3)
			if(length(drugs))
				icon_state = "ifak_open"
			sleep(5)

			icon_state = "ifak"
		else
			animation_flash_color(W, COLOR_RED)
			balloon_alert(user, "Storage is full!", COLOR_WHITE)
		return TRUE

/obj/item/criptic/utility/drug_storage/attack_self(mob/user)
	. = ..()
	if(length(drugs))
		var/pill_to_remove = pick(drugs)
		icon_state = "ifak_open"
		drugs -= pill_to_remove
		user.put_in_hands(pill_to_remove)

		animate(src, time = 3, easing = SINE_EASING|EASE_OUT, transform = matrix(10, MATRIX_ROTATE))
		sleep(3)
		if(!length(drugs))
			icon_state = "ifak_empty"
		animate(src, time = 3, easing = SINE_EASING|EASE_IN, transform = matrix())

		sleep(5)
		icon_state = "ifak"
		return TRUE

	animation_flash_color(src, COLOR_RED)
	balloon_alert(user, "Storage is empty!", COLOR_WHITE)
