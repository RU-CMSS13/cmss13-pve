/proc/screen_loc2pixels(params, view_range = 7, max_range = view_range)
	RETURN_TYPE(/list)

	var/list/screen_loc = splittext(params2list(params)["screen-loc"], ",")
	screen_loc = splittext(screen_loc[1], ":") + splittext(screen_loc[2], ":")

	var/list/view_size = getviewsize(view_range)

	var/screen_pixel_x = text2num(screen_loc[1]) * 32 + text2num(screen_loc[2]) - view_size[1] * 16 - 32
	var/screen_pixel_y = text2num(screen_loc[3]) * 32 + text2num(screen_loc[4]) - view_size[2] * 16 - 32

	if(max_range)
		var/limit = max_range * 32
		screen_pixel_x = clamp(screen_pixel_x, -limit, limit)
		screen_pixel_y = clamp(screen_pixel_y, -limit, limit)

	return list(screen_pixel_x, screen_pixel_y)

/client
	var/atom/movable/screen/sound_clue/connected_sound

	var/next_proximity_sound = 0
	var/proximity_radius = 100
	var/proximity_beep = 'sound/items/taperecorder/taperecorder_hiss_mid.ogg'

/client/MouseMove(object, location, control, params)
	. = ..()

	if(connected_sound)
		var/list/coords = screen_loc2pixels(params)
		connected_sound.set_screenpos(coords[1],coords[2])

		if(abs(connected_sound.x_off) < 10 && abs(connected_sound.y_off) < 10)
			connected_sound.connected_clue.reveal_itself(usr)

	var/mob/living/carbon/human/H = usr
	var/obj/item/criptic/instrument/held_item = H.get_held_item()

	if(istype(held_item,/obj/item/criptic/instrument/sound_device))
		var/obj/item/criptic/instrument/sound_device/S = held_item
		if(S.busy)
			if(world.time < next_proximity_sound)
				return

			var/list/coords = screen_loc2pixels(params)

			var/closest = INFINITY
			for(var/atom/movable/screen/sound_clue/SC in screen)
				if(SC.connected_clue.revealed)
					continue

				var/dx = coords[1] - SC.x_off
				var/dy = coords[2] - SC.y_off
				var/d = sqrt(dx*dx + dy*dy)
				if(d < closest)
					closest = d

			if(closest >= proximity_radius)
				return

			// louder + higher pitched as the cursor gets closer
			var/t = 1 - closest / proximity_radius          // 0 far .. 1 on top
			var/beep_vol  = round(20 + 80 * t)
			playsound_client(src, proximity_beep, beep_vol)
			next_proximity_sound = world.time + 3           // ~0.3 s debounce

/atom/movable/screen/exit_button_sound
	name = "EXIT"
	desc = "EXIT"

	plane = HUD_PLANE
	layer = HUD_LAYER

	icon = 'icons/mob/hud/actions.dmi'
	icon_state = "hologram_exit"

	screen_loc = "CENTER-6,CENTER"
	var/obj/item/criptic/instrument/sound_device/attached_to

/atom/movable/screen/exit_button_sound/Initialize(mapload, ...)
	. = ..()

	overlays += image('icons/mob/hud/actions.dmi', "template", layer = src.layer - 0.1)

/atom/movable/screen/exit_button_sound/clicked(mob/user)
	attached_to.stop_minigame(user)

/atom/movable/screen/sound_clue
	name = "clue"
	desc = "Drag it to the center"
	icon = 'core_ru/code/modules/criptid_hunting/effects.dmi'
	icon_state = "speaker"
	plane = HUD_PLANE
	layer = 18.9

	alpha = 0

	var/x_off
	var/y_off

	screen_loc = "CENTER,CENTER"
	var/obj/structure/criptic/clue/sound_clue/connected_clue

/atom/movable/screen/sound_clue/Initialize()
	. = ..()
	set_screenpos(rand(-200,200), rand(-200,200))

/atom/movable/screen/sound_clue/MouseEntered(location, control, params)
	. = ..()
	if(alpha == 0)
		animate(src, alpha = 255, time = 1 SECONDS, easing = SINE_EASING | EASE_IN)

/atom/movable/screen/sound_clue/clicked(mob/user)
	var/mob/living/carbon/human/H = user
	var/obj/item/criptic/instrument/held_item = H.get_held_item()

	if(istype(held_item,/obj/item/criptic/instrument/sound_device) && !H.client.connected_sound)
		add_filter("clue", 1, list("type" = "outline", "size" = 1, "color" = COLOR_CYAN))
		animate(src, transform = matrix(0.7, MATRIX_SCALE), time = 0.2 SECONDS, easing = SINE_EASING | EASE_IN)
		animate(transform = matrix(1, MATRIX_SCALE), time = 0.2 SECONDS, easing = SINE_EASING | EASE_OUT)
		H.client.connected_sound = src
		return TRUE
	else
		usr.client.connected_sound = null
		remove_filter("clue")

/atom/movable/screen/sound_clue/proc/update_screen_loc()
	var/tile_size = world.icon_size
	var/tx = round(x_off / tile_size)
	var/px = x_off - tx * tile_size
	var/ty = round(y_off / tile_size)
	var/py = y_off - ty * tile_size
	screen_loc = "CENTER+[tx]:[px], CENTER+[ty]:[py]"

/// Set a new position and refresh
/atom/movable/screen/sound_clue/proc/set_screenpos(px_off, py_off)
	x_off = px_off
	y_off = py_off
	update_screen_loc()

/obj/item/criptic/clue_item/sound_disc
	name = "sound disc"
	desc = "Contains some weird noises."
	icon = 'core_ru/code/modules/criptid_hunting/keycards.dmi'
	icon_state = "keycard_common"

	w_class = SIZE_TINY

/obj/structure/criptic/clue/sound_clue
	icon = 'core_ru/code/modules/criptid_hunting/effects_newer.dmi'
	icon_state_found = "void_chill_oh_fuck"
	mouse_opacity = FALSE
	var/mob/living/carbon/human/connected

	var/atom/movable/screen/sound_clue/representation

/obj/structure/criptic/clue/sound_clue/Initialize(mapload, ...)
	. = ..()
	representation = new /atom/movable/screen/sound_clue()
	representation.connected_clue = src

/obj/structure/criptic/clue/sound_clue/reveal_itself(mob/user)
	var/list/creepyasssounds = list('sound/effects/ghost.ogg', 'sound/effects/ghost2.ogg', 'sound/effects/Heart Beat.ogg', 'sound/effects/screech.ogg',\
		'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg', 'sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg',\
		'sound/hallucinations/growl3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg',\
		'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',\
		'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg', 'sound/hallucinations/wail.ogg')
	playsound(loc, pick(creepyasssounds), 25, 1)

	for(var/obj/structure/criptic/mission_controller/M in world)
		M.current_clues_found += 1
		M.show_current_progress()

	user.client.screen -= representation
	user.client.connected_sound = null

	var/obj/item/criptic/instrument/sound_device/S = locate(/obj/item/criptic/instrument/sound_device) in user
	animate(S.device_rep, time = 3, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_PARALLEL, transform = matrix(10, MATRIX_ROTATE)*matrix(0, -10, MATRIX_TRANSLATE))
	S.device_rep.add_filter("collected", 1, list("type" = "outline", "color" = COLOR_CYAN, "size" = 1))
	animation_flash_color(S.device_rep, COLOR_GREEN)
	spawn(5)
		S.device_rep.remove_filter("collected")
		animate(S.device_rep, time = 3, easing = SINE_EASING|EASE_IN, transform = matrix())
		S.device_rep.SetTransform(1.5)

	var/obj/item/criptic/clue_item/sound_disc/disc = new /obj/item/criptic/clue_item/sound_disc(get_turf(user))

	user.put_in_hands(disc)

	revealed = TRUE
	alpha = 0
	icon_state = "[icon_state_found]"
	animate(src, alpha = 100, time = 1 SECONDS, easing = SINE_EASING | EASE_IN)

/atom/movable/screen/audio_device
	name = "spirit box"
	desc = "So called center"

	icon = 'core_ru/code/modules/criptid_hunting/keycards.dmi'

	icon_state = "holotape_blue_signal"
	plane = HUD_PLANE
	layer = 18.9

	screen_loc = "CENTER,CENTER"
	var/obj/item/criptic/instrument/sound_device/attached_to

/atom/movable/screen/audio_device/Initialize(mapload, ...)
	. = ..()

	SetTransform(1.5)

/obj/item/criptic/instrument/sound_device
	name = "spirit box"
	desc = "Can detect abnormal sounds nearby"

	passive_searching = TRUE
	clue_type_to_reveal = list(/obj/structure/criptic/clue/sound_clue)

	icon = 'core_ru/code/modules/criptid_hunting/keycards.dmi'

	icon_state = "holotape_blue"
	icon_state_on = "holotape_blue_on"

	w_class = SIZE_SMALL
	light_color = COLOR_CYAN
	light_range = 1
	light_power = 1

	var/atom/movable/screen/audio_device/device_rep
	var/atom/movable/screen/exit_button_sound/exit_search
	var/list/clues_nearby = list()
	var/list/clues_rep = list()

	var/busy = FALSE

/obj/item/criptic/instrument/sound_device/clicked(mob/user, list/mods)
	if(mods[ALT_CLICK])
		if(!CAN_PICKUP(user, src))
			return ..()
		if(length(clues_nearby) && !busy)
			start_minigame(user)
			return TRUE
		if(busy)
			stop_minigame(user)
			return TRUE
	return ..()

/obj/item/criptic/instrument/sound_device/Initialize(mapload, ...)
	. = ..()
	device_rep = new /atom/movable/screen/audio_device()
	exit_search = new /atom/movable/screen/exit_button_sound()
	exit_search.attached_to = src
	device_rep.attached_to = src

/obj/item/criptic/instrument/sound_device/proc/start_minigame(mob/user)
	busy = TRUE
	device_rep.icon_state = icon_state
	user.client.mouse_pointer_icon = 'core_ru/code/modules/criptid_hunting/keycards.dmi'
	user.overlay_fullscreen("background",/atom/movable/screen/fullscreen/crt/criptic)

	user.client.screen += device_rep
	user.client.screen += exit_search
	user.client.screen += clues_rep
	ADD_TRAIT(user, TRAIT_IMMOBILIZED, INTERACTION_TRAIT)

/obj/item/criptic/instrument/sound_device/proc/stop_minigame(mob/user)
	busy = FALSE
	user.client.mouse_pointer_icon = initial(user.client.mouse_pointer_icon)
	user.clear_fullscreen("background")

	user.client.screen -= device_rep
	user.client.screen -= exit_search
	user.client.screen -= clues_rep
	REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, INTERACTION_TRAIT)

/obj/item/criptic/instrument/sound_device/check_for_condition()
	for(var/obj/structure/criptic/clue/sound_clue/S in clues_nearby)
		if(get_dist(S,loc) > 7)
			clues_nearby -= S
			clues_rep -= S.representation

		if(S.revealed)
			clues_nearby -= S
			clues_rep -= S.representation

	for(var/obj/structure/criptic/clue/sound_clue/SC in range(7,get_turf(loc)))
		if(SC.revealed)
			continue
		if(SC in clues_nearby)
			continue
		clues_nearby += SC
		clues_rep += SC.representation

		SC.representation.alpha = 0
		SC.representation.set_screenpos(rand(-200,200), rand(-200,200))

	if(length(clues_nearby))
		icon_state = "holotape_blue_signal"

	if(!length(clues_nearby) && icon_state != "holotape_blue_on")
		icon_state = icon_state_on
		device_rep.icon_state = icon_state

/obj/item/criptic/instrument/sound_device/revert_instrument_effect()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		stop_minigame(H)

	clues_rep.Cut()
	clues_nearby.Cut()

/obj/item/criptic/instrument/sound_device/dropped(mob/user)
	stop_minigame(user)

	clues_rep.Cut()
	clues_nearby.Cut()
	. = ..()
