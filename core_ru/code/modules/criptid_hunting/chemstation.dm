/atom/movable/screen/exit_button_flowers
	name = "EXIT"
	desc = "EXIT"

	plane = HUD_PLANE
	layer = HUD_LAYER

	icon = 'icons/mob/hud/actions.dmi'
	icon_state = "hologram_exit"

	screen_loc = "CENTER-6,CENTER"
	var/obj/structure/criptic/flowers_bush/attached_to

/atom/movable/screen/exit_button_flowers/Initialize(mapload, ...)
	. = ..()

	overlays += image('icons/mob/hud/actions.dmi', "template", layer = src.layer - 0.1)

/atom/movable/screen/exit_button_flowers/clicked(mob/user)
	attached_to.stop_minigame(user)

/atom/movable/screen/flowers_root
	name = "root"
	desc = "root"

	plane = HUD_PLANE
	layer = HUD_LAYER

	icon = 'core_ru/code/modules/criptid_hunting/lines2.dmi'
	icon_state = "data"

	screen_loc = "CENTER,CENTER"
	var/atom/movable/screen/flowers/flower = null

/atom/movable/screen/flowers_root/Initialize(mapload, ...)
	. = ..()
	SetTransform(null, 2, 4)

/atom/movable/screen/flowers_root/clicked(mob/user)
	animate(src, transform = matrix(2, 4, MATRIX_SCALE)*matrix(10, 0, MATRIX_TRANSLATE), time = 1, easing = EASE_IN)
	animate(transform = matrix(2, 4, MATRIX_SCALE)*matrix(-10, 0, MATRIX_TRANSLATE), time = 1.5)
	animate(transform = matrix(2, 4, MATRIX_SCALE)*matrix(0, 0, MATRIX_TRANSLATE), time = 0.6, easing = EASE_OUT)

	sleep(3)
	flower.roots -= src
	user.client.screen -= src
	qdel(src)

/atom/movable/screen/flowers
	name = "flowers"
	desc = "flowers"

	plane = HUD_PLANE
	layer = HUD_LAYER

	icon = 'core_ru/code/modules/criptid_hunting/96x96.dmi'
	icon_state = "sakuratree"

	screen_loc = "CENTER-0.5,CENTER+3"
	var/list/atom/movable/screen/flowers_root/roots = list()
	var/obj/structure/criptic/flowers_bush/bush = null
	var/roots_offset = 0
	color = COLOR_BLACK

/atom/movable/screen/flowers/Initialize(mapload, ...)
	. = ..()
	SetTransform(6)
	for(var/i in 0 to 2)
		var/atom/movable/screen/flowers_root/F = new /atom/movable/screen/flowers_root(src)
		F.layer = layer + 0.1
		F.flower = src
		roots += F
		if(roots_offset > 0)
			F.screen_loc = "CENTER,CENTER+[roots_offset]"
		roots_offset += 1.5

	var/mutable_appearance/underlayer_base = mutable_appearance('core_ru/code/modules/criptid_hunting/96x96.dmi', icon_state = "sakuratree", layer = src.layer - 0.1, plane = src.plane, alpha = 255, appearance_flags = NONE)
	underlayer_base.filters += list("type" = "outline", "size" = 1, "color" = COLOR_WHITE)
	var/image/underlayer = image(underlayer_base)

	underlayer.appearance_flags = RESET_TRANSFORM|RESET_ALPHA|RESET_COLOR
	var/matrix/under = matrix()
	under.Scale(6, 6)
	underlayer.transform = under

	overlays += underlayer

/atom/movable/screen/flowers/clicked(mob/user)
	if(length(roots))
		animation_flash_color(src, COLOR_RED)
		animate(src, transform = matrix(6, MATRIX_SCALE)*matrix(0, 10, MATRIX_TRANSLATE), time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN, flags = ANIMATION_PARALLEL)
		animate(transform = matrix(6, MATRIX_SCALE)*matrix(0, 0, MATRIX_TRANSLATE), time = 0.2 SECONDS, easing = BOUNCE_EASING | EASE_OUT)
		show_blurb(user, 5, "Cut all the roots first!", null, "CENTER,CENTER-2", "center", COLOR_WHITE, null, null, 1)
		return FALSE

	else
		animate(src, transform = matrix(6, MATRIX_SCALE)*matrix(0, 10, MATRIX_TRANSLATE), time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN)
		animate(transform = matrix(6, MATRIX_SCALE)*matrix(0, 0, MATRIX_TRANSLATE), time = 0.2 SECONDS, easing = BOUNCE_EASING | EASE_OUT)
		sleep(10)
		animate(src, alpha = 0, transform = matrix(6, MATRIX_SCALE)*matrix(0, 96, MATRIX_TRANSLATE), time = 1 SECONDS, easing = SINE_EASING | EASE_IN)
		sleep(10)
		bush.end_minigame(user)
		return TRUE

/obj/structure/criptic/flowers_bush
	name = "flowers"
	desc = "Can be used as herb."
	icon = 'core_ru/code/modules/criptid_hunting/plants_herb.dmi'
	icon_state = "Houttuynia-G4"

	anchored = TRUE
	var/atom/movable/screen/flowers/minigame = null
	var/atom/movable/screen/exit_button_flowers/exit
	var/busy = FALSE

/obj/structure/criptic/flowers_bush/Initialize(mapload, ...)
	. = ..()
	minigame = new /atom/movable/screen/flowers(src)
	minigame.bush = src

	exit = new /atom/movable/screen/exit_button_flowers(src)
	exit.attached_to = src

/obj/structure/criptic/flowers_bush/attack_hand(mob/user)
	balloon_alert(user, "Cut it before harvesting!", COLOR_WHITE)
	return FALSE

/obj/structure/criptic/flowers_bush/attackby(obj/item/W, mob/user)
	. = ..()

	if(istype(W,/obj/item/weapon/knife/marine) && !busy)
		start_minigame(user)
		return TRUE

/obj/structure/criptic/flowers_bush/proc/start_minigame(mob/user)
	busy = TRUE
	user.client.mouse_pointer_icon = 'core_ru/code/modules/criptid_hunting/knife_mouse.dmi'
	user.overlay_fullscreen("background",/atom/movable/screen/fullscreen/crt/criptic)

	user.client.screen += minigame.roots
	user.client.screen += minigame
	user.client.screen += exit
	ADD_TRAIT(user, TRAIT_IMMOBILIZED, INTERACTION_TRAIT)
	return TRUE

/obj/structure/criptic/flowers_bush/proc/end_minigame(mob/user)
	animate(src, pixel_x = pixel_x - 1, pixel_y = pixel_y, time = 0.5, easing = EASE_IN)
	animate(pixel_x = pixel_x + 1, pixel_y = pixel_y, time = 1)
	animate(pixel_x = initial(pixel_x), pixel_y = initial(pixel_y), time = 0.3, easing = EASE_OUT)

	user.client.mouse_pointer_icon = initial(user.client.mouse_pointer_icon)
	user.clear_fullscreen("background")

	user.client.screen -= minigame
	user.client.screen -= exit
	qdel(minigame)
	qdel(exit)
	REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, INTERACTION_TRAIT)
	new /obj/item/criptic/flower(get_turf(src))
	qdel(src)

/obj/structure/criptic/flowers_bush/proc/stop_minigame(mob/user)
	busy = FALSE
	user.client.mouse_pointer_icon = initial(user.client.mouse_pointer_icon)
	user.clear_fullscreen("background")

	user.client.screen -= minigame.roots
	user.client.screen -= minigame
	user.client.screen -= exit
	REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, INTERACTION_TRAIT)
	return TRUE

/obj/item/criptic/flower
	name = "flowers"
	desc = "Can be used as herb."
	icon = 'core_ru/code/modules/criptid_hunting/misc.dmi'
	icon_state = "rosa_1"

	w_class = SIZE_MEDIUM

/obj/item/criptic/flower/Initialize(mapload, ...)
	. = ..()
	icon_state = pick("rosa_1","salvia_1","calendula_1","matricaria_1")

/obj/item/criptic/flower/attackby(obj/item/W, mob/user)
	. = ..()

	if(istype(W,/obj/item/criptic/utility/basket))
		var/obj/item/criptic/utility/basket/basket = W
		if(length(basket.flowers) < basket.max_slots)
			basket.flowers += src
			forceMove(basket)
			basket.icon_state = "handbasket_full"
		else
			animation_flash_color(W, COLOR_RED)
			balloon_alert(user, "Basket is full!", COLOR_WHITE)
		return TRUE

/obj/structure/criptic/chemstation
	name = "chemical station"
	desc = "You can reveal criptid weakness there!"

	icon = 'core_ru/code/modules/criptid_hunting/workbenches.dmi'

	icon_state = "chemicalset"
	var/obj/structure/criptic/mission_controller/MC
	var/used = FALSE
	var/type_to_display = "None"

	var/research_progress = 0
	var/research_needed = 5
	var/list/scanned = list()
	var/filled_vials = 0

/obj/structure/criptic/chemstation/Initialize(mapload, ...)
	. = ..()

	MC = locate(/obj/structure/criptic/mission_controller) in world
	type_to_display = MC.weakness

/obj/structure/criptic/chemstation/MouseEntered(location, control, params)
	. = ..()

	var/mob/living/L = usr
	if(get_dist(L,src) < 2 && used)
		maptext_y = pixel_y + 20
		maptext_x = pixel_x - 5
		maptext = SPAN_LANGCHAT("[type_to_display]")

/obj/structure/criptic/chemstation/MouseExited(location, control, params)
	. = ..()

	if(maptext)
		maptext = ""

/obj/structure/criptic/chemstation/attack_hand(mob/user)
	. = ..()
	if(used)
		return FALSE

	if(research_progress < research_needed)
		balloon_alert(user, "You need more info to perform this research!", COLOR_WHITE)
		return FALSE

	for(var/i in 0 to 10)
		new /obj/effect/temp_visual/working_progress(get_turf(src))

	if(do_after(user, 4 SECONDS, INTERRUPT_ALL, BUSY_ICON_BUILD))
		used = TRUE
		type_to_display = MC.weakness
		balloon_alert(user, "Possibly weak to: [type_to_display]", COLOR_WHITE)
		switch(type_to_display)
			if("Salt")
				add_filter("salt", 1, list("type" = "outline", "color" = "#c2c2c2", "size" = 1))
			if("Silver")
				add_filter("silver", 1, list("type" = "outline", "color" = "#c50d0d", "size" = 1))
			if("UV")
				add_filter("uv", 1, list("type" = "outline", "color" = "#6f0091", "size" = 1))
	return TRUE

/obj/structure/criptic/chemstation/attackby(obj/item/W, mob/user)
	. = ..()
	if(istype(W,/obj/item/criptic/clue_item) && (W in scanned))
		animation_flash_color(W, COLOR_RED)
		balloon_alert(user, "[W] already scanned!", COLOR_WHITE)
		return FALSE

	if(istype(W,/obj/item/criptic/clue_item) && !(W in scanned) && research_progress < research_needed)
		if(do_after(user, 2 SECONDS, INTERRUPT_ALL, BUSY_ICON_GENERIC))
			scanned += W
			if(istype(W,/obj/item/criptic/clue_item/criptid_cloth))
				research_progress = research_needed
			else
				research_progress += 1
			balloon_alert(user, "[research_progress] out of [research_needed] samples collected!", COLOR_WHITE)
			return TRUE

	if(istype(W,/obj/item/criptic/utility/basket))
		var/obj/item/criptic/utility/basket/B = W
		if(!length(B.flowers))
			balloon_alert(user, "Basket is empty!", COLOR_WHITE)
			animation_flash_color(B, COLOR_RED)
			return FALSE
		if(length(B.flowers) >= 3)
			for(var/amount in 1 to 3)
				var/flower_to_remove = pick(B.flowers)
				B.flowers -= flower_to_remove
				qdel(flower_to_remove)
			for(var/i in 0 to 10)
				new /obj/effect/temp_visual/working_progress(get_turf(src))

			if(do_after(user, 4 SECONDS, INTERRUPT_ALL, BUSY_ICON_BUILD))
				if(!length(B.flowers))
					B.icon_state = "handbasket"
				filled_vials += 1
				balloon_alert(user, "One vial were created! Now it's total of: [filled_vials]", COLOR_WHITE)
				return TRUE
		return FALSE

	if(istype(W,/obj/item/criptic/utility/pills/stress_reducing))
		var/obj/item/criptic/utility/pills/stress_reducing/S = W
		if(filled_vials <= 0)
			balloon_alert(user, "There is nothing to extract!", COLOR_WHITE)
			return FALSE
		if(S.can_be_used)
			balloon_alert(user, "It's already full!", COLOR_WHITE)
			animation_flash_color(S, COLOR_RED)
			return FALSE

		if(do_after(user, 2 SECONDS, INTERRUPT_ALL, BUSY_ICON_BUILD))
			filled_vials -= 1
			balloon_alert(user, "One vial were used! Now it's down to: [filled_vials]", COLOR_WHITE)
			S.can_be_used = TRUE
			S.icon_state = "pilltin"
			animation_flash_color(S, COLOR_GREEN)
			return TRUE
		return FALSE
