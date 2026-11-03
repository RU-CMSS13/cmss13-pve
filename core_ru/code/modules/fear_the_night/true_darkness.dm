/atom/movable/screen/fullscreen/true_darkness_damage
	icon_state = "xeno_painoverlay4"
	layer = FULLSCREEN_PAIN_LAYER
	color = COLOR_BLACK

/obj/effect/temp_visual/healing
	duration = 0.5 SECONDS
	icon = 'core_ru/code/modules/criptid_hunting/chaplainRitual.dmi'
	icon_state = "sprite-heal-spell"
	layer = 3

/mob/living/carbon/human
	var/fear_the_night = FALSE
	var/sanity_max = 100
	var/sanity_current = 100

	var/sanity_warning_shown = FALSE
	var/light_debugger_on = FALSE

/mob/living/carbon/human/proc/do_sanity_check()
	set waitfor = 0

	var/total_light = 0
	var/checked_tiles = 0
	for(var/turf/open/nearby in view(1, src.loc))
		var/tile_light = nearby.get_lumcount() + (nearby.dynamic_lumcount / 2)
		if(tile_light > 0)
			total_light += tile_light
			checked_tiles++

	var/average_light = checked_tiles > 0 ? (total_light / checked_tiles) : 0

	// Дебаг
	if(light_debugger_on)
		to_chat(src, "Avg light: [average_light] across [checked_tiles] tiles")

	if(sanity_current > 0 && average_light <= 0.20)
		if(!sanity_warning_shown)
			sanity_warning_shown = TRUE
			show_blurb(src, 5, "Darkness slowly consumes you...", null, "EAST-7,NORTH-8.5", "center", COLOR_GRAY, null, null, 1)
		sanity_current = clamp(sanity_current - 1, 0, sanity_max)
		overlay_fullscreen_timer(2 SECONDS, 10, "darkness", /atom/movable/screen/fullscreen/true_darkness_damage)

	if(sanity_current < sanity_max && average_light >= 0.5)
		if(sanity_warning_shown)
			sanity_warning_shown = FALSE
			show_blurb(src, 5, "Warm light...finally...", null, "EAST-7,NORTH-8.5", "center", LIGHT_COLOR_CANDLE, null, null, 1)
		sanity_current = clamp(sanity_current + 2, 0, sanity_max)
		new /obj/effect/temp_visual/healing(get_turf(src))

	if(sanity_current <= 0)
		apply_effect(20, DAZE)
		make_jittery(300)
		sleep(30)
		emote("scream")
		show_blurb(GLOB.player_list, 10, "ANOTHER SOUL BEEN CLAIMED", null, "EAST-7,NORTH-3", "center", COLOR_RED, null, null, 1)

		for(var/obj/item/current_item in src)
			drop_inv_item_to_loc(current_item, loc, FALSE, TRUE)

		var/mob/new_body = new /mob/living/carbon/xenomorph/criptic_wendigo/banshee(get_turf(src))
		if(client)
			new_body.ckey = ckey
		sleep(5)
		qdel(src)
	return TRUE

/mob/living/carbon/human/Life()
	if(stat != DEAD && fear_the_night)
		do_sanity_check()

	..()

/turf/proc/make_lights_flickery()
	for(var/obj/structure/machinery/light/light in orange(20,src))
		if(prob(70))
			light.flicker(rand(5,15))

/turf/proc/disable_manufactured_lights()
	var/list/atom/disabling_list = list()
	for(var/mob/living/carbon/human/H in orange(20,src))
		for(var/atom/A in H)
			if(istype(A,/obj/item/clothing/suit/marine) || istype(A,/obj/item/clothing/suit/storage/marine) || istype(A,/obj/item/clothing/head/hardhat) || istype(A,/obj/item/device/flashlight))
				disabling_list |= A

	for(var/atom/A in orange(20,src))
		if(!istype(A,/obj/item))
			continue
		if(istype(A,/obj/item/clothing/suit/marine) || istype(A,/obj/item/clothing/suit/storage/marine) || istype(A,/obj/item/clothing/head/hardhat) || istype(A,/obj/item/device/flashlight))
			disabling_list |= A

	for(var/obj/item/device/flashlight/F in disabling_list)
		if(!F.on)
			continue
		if(istype(F,/obj/item/device/flashlight/flare))
			var/obj/item/device/flashlight/flare/flare = F
			flare.fuel = 0

		else
			F.turn_off_light()
			F.unusable = TRUE
			addtimer(CALLBACK(F, TYPE_PROC_REF(/obj/item/device/flashlight, reset_workstate)), 10 SECONDS)

	for(var/obj/item/I in disabling_list)
		if(istype(I,/obj/item/clothing/suit/marine) || istype(I,/obj/item/clothing/suit/storage/marine) || istype(I,/obj/item/clothing/head/hardhat))
			var/obj/item/clothing/C = I
			C.power_amount = 0
			C.unusable = TRUE
			addtimer(CALLBACK(C, TYPE_PROC_REF(/obj/item/clothing, reset_workstate)), 5 SECONDS)

/obj/item/clothing
	var/unusable = FALSE

/obj/item/clothing/proc/reset_workstate()
	unusable = FALSE

/obj/item/device/flashlight
	var/unusable = FALSE

/obj/item/device/flashlight/proc/reset_workstate()
	unusable = FALSE

