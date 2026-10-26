/obj/structure/criptic/power_gen
	name = "Generator"
	desc = "A portable generator for emergency backup power."
	icon = 'icons/obj/structures/machinery/defenses.dmi'
	icon_state = "generator"
	density = TRUE
	anchored = TRUE

	var/on = FALSE
	var/broken = FALSE

	var/fuel = 0
	var/fuel_max = 150

	var/mob/living/carbon/human/player

	var/minigame_progress = 0
	var/minigame_goal = 30
	var/qte_chance = 10
	var/qte_in_progress = FALSE

	var/list/other_areas = list()
	var/list/area/areas = list()

	maptext_width = 48
	maptext_height = 48
	maptext_y = 29
	maptext_x = 4

/obj/structure/criptic/power_gen/get_examine_text(mob/user)
	. = ..()

	if(broken)
		. += SPAN_RED("It doesn't looking good!")

	. += SPAN_BLUE("It has [fuel]/[fuel_max] fuel inside at this moment.")
	. += SPAN_BLUE("<br>")
	. += SPAN_BLUE("It's connected to:")
	for(var/area/A in areas)
		. += SPAN_GREEN("...[A.name]")

/obj/structure/criptic/power_gen/process()
	if(fuel > 0 && !broken)
		fuel = clamp(fuel - 1, 0, fuel_max)

	if(fuel <= 0 && !broken)
		turn_off()

	if(player)
		if(get_dist(player,src) > 1)
			player = null
			maptext = ""
			STOP_PROCESSING(SSobj,src)

	if(broken && player)
		if(minigame_progress < minigame_goal)
			if(prob(qte_chance) && !qte_in_progress)
				create_qte()
			qte_chance = clamp(qte_chance + 5, 0, 80)
			minigame_progress = clamp(minigame_progress + 1, 0, minigame_goal)
			maptext = SPAN_LANGCHAT("|[minigame_progress]/[minigame_goal]|")

		if(minigame_progress >= minigame_goal)
			broken = FALSE
			player = null
			maptext = ""
			minigame_progress = 0
			STOP_PROCESSING(SSobj,src)

/atom/movable/screen/power_qte
	plane = HUD_PLANE
	layer = HUD_LAYER

	icon = 'core_ru/code/modules/criptid_hunting/effectss.dmi'
	icon_state = "gears"

	screen_loc = "CENTER,CENTER"
	var/obj/structure/criptic/power_gen/connected_gen
	var/mob/fixer

/atom/movable/screen/power_qte/Initialize()
	. = ..()
	transform = matrix(1.5, 1.5, MATRIX_SCALE)*matrix(rand(-96,96), rand(-96,96), MATRIX_TRANSLATE)
	spawn(3 SECONDS)
		end_qte(fixer)

/atom/movable/screen/power_qte/clicked(mob/user)
	if(get_dist(connected_gen,fixer) > 1)
		end_qte(fixer)
		return

	if(!connected_gen.broken)
		end_qte(fixer)
		return

	playsound(fixer.loc, 'sound/items/Ratchet.ogg', 25, 1)
	add_filter("success", 1, list("type" = "outline", "color" = COLOR_GREEN, "size" = 1))
	animate(src, transform = matrix(1.2, MATRIX_SCALE), time = 0.2 SECONDS, easing = SINE_EASING | EASE_IN)
	animate(transform = matrix(1.5, MATRIX_SCALE), time = 0.2 SECONDS, easing = SINE_EASING | EASE_OUT)

	connected_gen.minigame_progress = clamp(connected_gen.minigame_progress + 5, 0, connected_gen.minigame_goal)
	connected_gen.maptext = SPAN_LANGCHAT("|[connected_gen.minigame_progress]/[connected_gen.minigame_goal]|")

	spawn(0.2 SECONDS)
		end_qte(fixer)

/atom/movable/screen/power_qte/proc/end_qte(mob/user)
	connected_gen.qte_in_progress = FALSE
	animate(src, alpha = 0, transform = matrix(0.1, MATRIX_SCALE), time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN)
	sleep(0.5 SECONDS)
	user.client.screen -= src
	qdel(src)

/obj/structure/criptic/power_gen/proc/create_qte()
	var/mob/living/carbon/human/H = player
	qte_chance = 10
	qte_in_progress = TRUE

	var/atom/movable/screen/power_qte/P = new /atom/movable/screen/power_qte()
	P.fixer = H
	P.connected_gen = src
	H.client.screen += P

/obj/structure/criptic/power_gen/attack_hand(mob/user)
	. = ..()

	if(!on)
		if(fuel <= 0)
			balloon_alert(user, "It's empty!", COLOR_WHITE)
			return FALSE

		if(broken)
			balloon_alert(user, "You need to fix it first, using wrench!", COLOR_WHITE)
			return FALSE

		if(do_after(user, 10, INTERRUPT_ALL, BUSY_ICON_BUILD))
			turn_on()
		return TRUE

	if(on)
		if(do_after(user, 10, INTERRUPT_ALL, BUSY_ICON_BUILD))
			turn_off()
		return TRUE

/obj/structure/criptic/power_gen/attackby(obj/item/W, mob/user)
	. = ..()

	if(istype(W,/obj/item/criptic/utility/fuel))
		if(fuel > fuel_max / 2)
			balloon_alert(user, "Looks pretty full for me!", COLOR_WHITE)
			animation_flash_color(W, COLOR_RED)
			return FALSE
		else
			fuel = fuel_max
			var/obj/item/criptic/utility/U = W
			U.pop_out()

			animation_flash_color(U, COLOR_RED)
			sleep(0.5 SECONDS)
			qdel(U)
			return TRUE

	if(HAS_TRAIT(W, TRAIT_TOOL_WRENCH))
		if(!broken)
			balloon_alert(user, "There is nothing to fix!", COLOR_WHITE)
			animation_flash_color(W, COLOR_RED)
			return FALSE
		else
			player = user
			START_PROCESSING(SSobj,src)
			return TRUE

/obj/structure/criptic/power_gen/Initialize()
	. = ..()
	if(length(other_areas))
		for(var/area/A in world)
			if(A.type in other_areas)
				areas += A
	else
		areas += get_area(src)

/obj/structure/criptic/power_gen/proc/turn_on()
	icon_state = "[initial(icon_state)]_on"
	on = TRUE

	for(var/area/A in areas)
		A.requires_power = FALSE
		A.unlimited_power = TRUE
		A.update_power_channels(1, 1, 1)

		for(var/obj/structure/machinery/light/L in A)
			L.update()

	START_PROCESSING(SSobj, src)

/obj/structure/criptic/power_gen/proc/turn_off()
	icon_state = "[initial(icon_state)]"
	on = FALSE

	for(var/area/A in areas)
		A.requires_power = TRUE
		A.unlimited_power = FALSE
		A.update_power_channels(0, 0, 0)

		for(var/obj/structure/machinery/light/L in A)
			L.update()

	STOP_PROCESSING(SSobj, src)

/obj/structure/criptic/power_gen/proc/break_it()
	if(on)
		turn_off()
	broken = TRUE

	animate(src, pixel_x = rand(-2,2), pixel_y = rand(-2,2), time = 3, loop = -1, easing = JUMP_EASING)
	for(var/i in 1 to 4)
		animate(pixel_x = rand(-2,2), pixel_y = rand(-2,2), time = 3, easing = JUMP_EASING)

	playsound(src, 'sound/effects/sparks4.ogg', 60, 1)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(2, 1, src)
	s.start()
