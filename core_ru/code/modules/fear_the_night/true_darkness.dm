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

/mob/living/carbon/human/proc/do_sanity_check()
	set waitfor = 0

	var/turf/T = get_turf(src)
	var/total_light = T.get_lumcount() + T.dynamic_lumcount
	if(sanity_current > 0 && total_light <= 0.1)
		if(!sanity_warning_shown)
			sanity_warning_shown = TRUE
			show_blurb(src, 5, "Darkness slowly consumes you...", null, "EAST-7,NORTH-8.5", "center", COLOR_GRAY, null, null, 1)
		sanity_current = clamp(sanity_current - 1, 0, sanity_max)
		overlay_fullscreen_timer(2 SECONDS, 10, "darkness", /atom/movable/screen/fullscreen/true_darkness_damage)

	if(sanity_current < sanity_max && total_light >= 0.3)
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

/mob/living/carbon/human/Life()
	if(stat != DEAD && fear_the_night)
		do_sanity_check()

	..()
