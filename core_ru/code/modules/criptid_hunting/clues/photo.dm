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
