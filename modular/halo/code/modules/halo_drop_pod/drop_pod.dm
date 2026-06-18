GLOBAL_LIST_INIT(blocked_droppod_tiles, typecacheof(list(/turf/open/space/transit, /turf/open/space))) // Don't drop at these tiles.
GLOBAL_LIST_EMPTY(active_droppod_landing_turfs)


/obj/structure/halo_droppod
	name = "\improper M8823 HEV drop pod"
	health = 4000 //Hopefully immune to most things. Probably not.
	icon = 'modular/halo/icons/halo/obj/structures/drop_pod.dmi'
	icon_state = "drop_pod"
	layer = 5.1
	pixel_x = -16
	density = TRUE

// Vars that are important when interacting with the pod as a player
	var/gm_locked = TRUE // whether or not the pod is locked to only be able to be controlled by the gm
	var/locked = FALSE // if the pod is locked and unable to be opened
	var/closed = TRUE
	var/can_launch = TRUE
	var/pod_state = POD_READY
	var/chute_state = CHUTE_READY
	var/start_open

// Vars of importance when launching
	var/landing_scatter = 10 // Scatter from the landing point
	var/time_to_land = 30 SECONDS // time it takes from launching to reach the ground
	var/landing_time = 1 SECONDS
	var/time_to_chute
	var/time_to_thruster
	var/pod_group
	var/target_x = 1
	var/target_y = 1
	var/target_z = 2
	var/turf/planned_landing_turf
	var/list/turf/launch_targets = list()

// other vars
	var/image/occupant_image
	var/image/door_image
	var/overlay_icon_state = "pod_overlay"
	var/door_icon_state = "pod_door"
	var/chute_icon_state = "chute"
	var/occupant_angle = -90
	var/occupant_x = 16
	var/occupant_y = 10
	var/occupant_dir = 2
	var/mob/living/occupant
	var/door_delay = 2 SECONDS
	COOLDOWN_DECLARE(door_cooldown)
	var/datum/turf_reservation/reservation
	var/launch_sequence_active = FALSE
	var/finish_drop_retries = 0

	var/image/pod_overlay
	var/image/rocket_image
	var/obj/structure/drop_pod_chute/chute_obj
	var/obj/item/drop_pod_door/door_obj

/obj/structure/halo_droppod/testpod
	target_x = 75
	target_y = 100

/obj/structure/halo_droppod/start_open
	start_open = TRUE

/obj/item/drop_pod_door
	name = "\improper M8823 HEV pod door"
	icon = 'modular/halo/icons/halo/obj/structures/drop_pod.dmi'
	icon_state = "pod_door"
	layer = 5.8
	anchored = 1
	drop_sound = 'modular/halo/sound/effects/odst_pod/door_clang_1.ogg'

/obj/item/drop_pod_door/launch_impact(hit_atom)
	. = ..()
	playsound(src, 'modular/halo/sound/effects/odst_pod/door_clang_1.ogg')

/obj/structure/drop_pod_chute
	name = "\improper M8823 HEV pod chute"
	icon = 'modular/halo/icons/halo/obj/structures/drop_pod.dmi'
	icon_state = "chute"
	layer = 5.7

/obj/structure/halo_droppod/Initialize()
	. = ..()
	handle_overlays()
	chute_obj = new()
	chute_obj.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE
	vis_contents += chute_obj

	door_obj = new()
	door_obj.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE
	vis_contents += door_obj
	if(start_open)
		open_door()

/obj/structure/halo_droppod/Destroy()
	release_landing_target()
	QDEL_NULL(reservation)
	if(occupant)
		var/mob/living/evicted = occupant
		occupant = null
		evicted.forceMove(get_turf(src))
	return ..()

/obj/structure/halo_droppod/proc/handle_overlays(mob/living/user)
	overlays.Cut()
	pod_overlay = image(src.icon, loc, overlay_icon_state, 5.4)
	overlays += pod_overlay
	var/mob/living/displayed_occupant = sync_occupant_state(FALSE)
	if(displayed_occupant)
		occupant_image = image(displayed_occupant.appearance, loc, layer = 5.2)
		occupant_image.pixel_x = occupant_x
		occupant_image.pixel_y = occupant_y
		occupant_image.dir = occupant_dir
		if(displayed_occupant.body_position == LYING_DOWN)
			occupant_image.transform = displayed_occupant.transform.Turn(occupant_angle)
		overlays += occupant_image

/obj/structure/halo_droppod/proc/sync_occupant_state(update_visuals = TRUE)
	if(occupant && occupant.loc != src)
		occupant = null
		if(update_visuals)
			handle_overlays()
	return occupant

/obj/structure/halo_droppod/proc/get_primary_launch_target()
	return locate(target_x, target_y, target_z)

/obj/structure/halo_droppod/proc/get_launch_target_list()
	. = list()
	for(var/turf/target in launch_targets)
		if(!target)
			continue
		. += target
	if(length(.))
		return
	var/turf/default_target = get_primary_launch_target()
	if(default_target)
		. += default_target

/obj/structure/halo_droppod/proc/set_launch_targets(list/new_targets)
	launch_targets = list()
	if(length(new_targets))
		for(var/atom/target in new_targets)
			var/turf/target_turf = get_turf(target)
			if(!target_turf || (target_turf in launch_targets))
				continue
			launch_targets += target_turf
	if(!length(launch_targets))
		var/turf/default_target = get_primary_launch_target()
		if(default_target)
			launch_targets += default_target
	var/turf/primary_target = length(launch_targets) ? launch_targets[1] : null
	if(primary_target)
		target_x = primary_target.x
		target_y = primary_target.y
		target_z = primary_target.z
	return length(launch_targets)

/obj/structure/halo_droppod/proc/release_landing_target()
	if(!planned_landing_turf)
		return
	GLOB.active_droppod_landing_turfs -= planned_landing_turf
	planned_landing_turf = null

/obj/structure/halo_droppod/proc/set_planned_landing_target(turf/new_target)
	if(planned_landing_turf == new_target)
		return planned_landing_turf
	release_landing_target()
	planned_landing_turf = new_target
	if(planned_landing_turf)
		GLOB.active_droppod_landing_turfs += planned_landing_turf
	return planned_landing_turf

/obj/structure/halo_droppod/proc/can_start_launch()
	sync_occupant_state(FALSE)
	return occupant && can_launch && !launch_sequence_active && pod_state == POD_READY

/obj/structure/halo_droppod/proc/has_reserved_landing_conflict(turf/target, turf/ignore_reserved_turf = null)
	for(var/turf/reserved_turf in GLOB.active_droppod_landing_turfs)
		if(!reserved_turf || reserved_turf == ignore_reserved_turf || reserved_turf.z != target.z)
			continue
		if(get_dist(target, reserved_turf) <= 1)
			return TRUE
	return FALSE

/obj/structure/halo_droppod/proc/has_nearby_pod_conflict(turf/target)
	for(var/obj/structure/halo_droppod/other_pod in range(1, target))
		if(other_pod == src)
			continue
		return TRUE
	return FALSE

/obj/structure/halo_droppod/proc/reset_launch_state(reset_can_launch = FALSE)
	launch_sequence_active = FALSE
	locked = FALSE
	release_landing_target()
	finish_drop_retries = 0
	if(reset_can_launch)
		can_launch = TRUE
	if(pod_state == POD_INFLIGHT)
		pod_state = POD_READY
	QDEL_NULL(reservation)

/obj/structure/halo_droppod/proc/toggle_door(mob/living/user)
	if(pod_state == POD_LANDED)
		return
	if(closed)
		open_door(user)
		return
	if(!closed)
		close_door(user)
		return

/obj/structure/halo_droppod/proc/open_door(mob/living/user)
	if(pod_state == POD_LANDED)
		return
	if(closed)
		if(user)
			visible_message(SPAN_NOTICE("[user] pulls a lever and opens the [src]s door."), SPAN_NOTICE("You pull a lever and open the [src]s door."))
		playsound(src, 'modular/halo/sound/effects/odst_pod/pod_door_open.ogg')
		door_obj.icon_state = "pod_door_open"
		var/open_time = 1 SECONDS
		animate(door_obj, pixel_y = 24, time = open_time, easing = SINE_EASING)
		closed = FALSE
		return

/obj/structure/halo_droppod/proc/close_door(mob/living/user)
	if(pod_state == POD_LANDED)
		return
	if(!closed)
		if(user)
			visible_message(SPAN_NOTICE("[user] pulls a lever and closes the [src]s door."), SPAN_NOTICE("You pull a lever and close the [src]s door."))
		playsound(src, 'modular/halo/sound/effects/odst_pod/pod_door_close.ogg')
		var/close_time = 1 SECONDS
		animate(door_obj, pixel_y = 0, time = close_time, easing = SINE_EASING)
		sleep(close_time+1)
		door_obj.icon_state = "pod_door"
		closed = TRUE
		return

/obj/structure/halo_droppod/proc/enter_pod(mob/living/user)
	if(!door_obj)
		to_chat(user, SPAN_NOTICE("Why would you want to enter it now?"))
		return
	sync_occupant_state(FALSE)
	if(!can_launch || launch_sequence_active || pod_state != POD_READY)
		to_chat(user, SPAN_NOTICE("The pod is not ready for another drop."))
		return
	if(closed)
		to_chat(user, SPAN_NOTICE("You try to enter the pod, but it's closed."))
		return
	if(locked)
		to_chat(user, SPAN_NOTICE("You try to enter the pod, but it's locked."))
		return
	if(occupant)
		to_chat(user, SPAN_NOTICE("There's someone already in the pod."))
		return
	to_chat(user, SPAN_NOTICE("You enter the pod."))
	user.forceMove(src)
	occupant = user
	playsound(src, "droppod_enter")
	addtimer(CALLBACK(src, PROC_REF(close_door), user), 2.5 SECONDS)
	handle_overlays(user)

/obj/structure/halo_droppod/proc/exit_pod(mob/living/user)
	var/mob/living/current_occupant = sync_occupant_state(FALSE)
	if(locked)
		to_chat(user, SPAN_NOTICE("The pod is locked, you can't exit."))
		return
	if(pod_state == POD_INFLIGHT)
		to_chat(user, SPAN_BOLDWARNING("Are you crazy!?"))
		return
	if(closed)
		open_door(user)
	if(!current_occupant)
		return
	var/turf/exit_turf = get_step(src, SOUTH)
	current_occupant.forceMove(get_turf(exit_turf))
	current_occupant.dir = SOUTH
	occupant = null
	locked = FALSE
	to_chat(user, SPAN_NOTICE("You exit the pod."))
	playsound(src, "droppod_enter")
	handle_overlays(user)

/obj/structure/halo_droppod/attack_hand(mob/living/user)
	if(!COOLDOWN_FINISHED(src, door_cooldown))
		return
	sync_occupant_state(FALSE)
	if(locked)
		to_chat(user, SPAN_NOTICE("You try to open the pod, but it's locked."))
		return
	if(occupant)
		to_chat(user, SPAN_NOTICE("You try to open the pod, but it's locked from the inside."))
		return
	toggle_door(user)
	COOLDOWN_START(src, door_cooldown, door_delay)

/obj/structure/halo_droppod/MouseDrop_T(mob/target, mob/user)
	. = ..()
	if(ishuman(target))
		visible_message(SPAN_NOTICE("[user] begins to enter the [src]."), SPAN_NOTICE("You begin to enter the [src]."))
		if(!do_after(user, 3 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_GENERIC, target, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_GENERIC))
			to_chat(user, SPAN_NOTICE("You are interrupted!"))
			return
		enter_pod(target)
	else
		to_chat(user, SPAN_NOTICE("[target] cannot enter the pod."))

// ============== CODE TO DROP ==============

/obj/structure/halo_droppod/return_temperature()
	if(loc)
		return 290

/obj/structure/halo_droppod/proc/set_target(mob/living/user, new_x, new_y, new_z = target_z)
	var/turf/new_target = locate(new_x, new_y, new_z)
	if(!new_target)
		if(user)
			to_chat(user, SPAN_NOTICE("Invalid coordinates!"))
		return FALSE
	set_launch_targets(list(new_target))
	var/mob/notified_user = occupant
	. = checklanding(notified_user, new_target)
	if(notified_user && .)
		to_chat(user, SPAN_NOTICE("Coordinates set!"))

/obj/structure/halo_droppod/proc/checklanding(mob/living/user, optional_turf, turf/ignore_reserved_turf = null)
	var/turf/target = optional_turf ? get_turf(optional_turf) : get_primary_launch_target()
	if(!target)
		if(user)
			to_chat(user, SPAN_NOTICE("Invalid coordinates!"))
		return FALSE
	if(target.density)
		if(user)
			to_chat(user, SPAN_NOTICE("Dense area!"))
		return FALSE
	if(is_type_in_typecache(target, GLOB.blocked_droppod_tiles))
		if(user)
			to_chat(user, SPAN_NOTICE("Hazardous area!"))
		return FALSE
	var/area/targetarea = get_area(target)
	if(!targetarea)
		if(user)
			to_chat(user, SPAN_NOTICE("Invalid area!"))
		return FALSE
	if(targetarea.no_droppod) // Thou shall not pass!
		if(user)
			to_chat(user, SPAN_NOTICE("Invalid area!"))
		return FALSE
	if(targetarea.ceiling > CEILING_METAL)
		if(user)
			to_chat(user, SPAN_NOTICE("Area underground!"))
		return FALSE
	for(var/atom/movable/object in target.contents)
		if(object.density)
			if(user)
				to_chat(user, SPAN_NOTICE("Dense object detected!"))
			return FALSE
	if(has_reserved_landing_conflict(target, ignore_reserved_turf))
		if(user)
			to_chat(user, SPAN_NOTICE("Another pod is already assigned nearby!"))
		return FALSE
	if(has_nearby_pod_conflict(target))
		if(user)
			to_chat(user, SPAN_NOTICE("Another pod is already too close to the landing point!"))
		return FALSE
	return TRUE

/obj/structure/halo_droppod/proc/find_new_target(mob/user, list/candidate_targets = null, turf/ignore_reserved_turf = null)
	var/list/turf/targets_to_check = candidate_targets ? candidate_targets : get_launch_target_list()
	if(!length(targets_to_check))
		if(user)
			to_chat(user, SPAN_WARNING("No landing zones available."))
		return null
	for(var/turf/base_target in targets_to_check)
		if(!base_target)
			continue
		if(checklanding(optional_turf = base_target, ignore_reserved_turf = ignore_reserved_turf))
			return base_target
		var/turf/turf_1 = locate(base_target.x + landing_scatter, base_target.y + landing_scatter, base_target.z)
		var/turf/turf_2 = locate(base_target.x - landing_scatter, base_target.y - landing_scatter, base_target.z)
		if(!turf_1 || !turf_2)
			continue
		var/list/block = block(turf_1, turf_2)
		shuffle_inplace(block)
		for(var/turf/attemptdrop in block)
			if(get_dist(base_target, attemptdrop) > landing_scatter)
				continue
			if(!checklanding(optional_turf = attemptdrop, ignore_reserved_turf = ignore_reserved_turf))
				continue
			return attemptdrop
	if(user)
		to_chat(user, SPAN_WARNING("All landing zones are blocked or occupied."))
	return null

/obj/structure/halo_droppod/proc/start_launch_pod(mob/user)
	var/mob/living/current_occupant = sync_occupant_state(FALSE)
	if(!current_occupant)
		return FALSE
	if(!can_launch || launch_sequence_active)
		return FALSE
	user = current_occupant
	handle_overlays(user)

	// if(!locate(/obj/structure/drop_pod_launcher) in get_turf(src))
	//	if(user)
	//		to_chat(user, SPAN_NOTICE("Error. Cannot launch [src] without a droppod launcher."))
	//	return

	if(pod_state != POD_READY)
		if(user)
			to_chat(user, SPAN_NOTICE("Error. Unable to drop."))
		return FALSE

	var/turf/target = find_new_target(user)
	if(!target)
		return FALSE
	set_planned_landing_target(target)

	launch_sequence_active = TRUE
	can_launch = FALSE
	locked = TRUE

	if(!closed)
		close_door(user)

	current_occupant = sync_occupant_state(FALSE)
	if(!current_occupant)
		reset_launch_state(TRUE)
		return FALSE
	if(current_occupant.loc != src)
		current_occupant.forceMove(src)

	if(user)
		log_game("[key_name(user)] launched pod [src] at [AREACOORD(target)]")

	pod_state = POD_INFLIGHT
	var/random_delay = rand(0, 20)*0.1
	addtimer(CALLBACK(src, PROC_REF(delay_pod), user), random_delay SECONDS)
	return TRUE

/obj/structure/halo_droppod/proc/delay_pod(mob/user)
	if(!launch_sequence_active || pod_state != POD_INFLIGHT)
		return
	if(occupant?.client)
		playsound_client(occupant.client, 'modular/halo/sound/effects/odst_pod/drop_timer.ogg', src, 25)
	addtimer(CALLBACK(src, PROC_REF(launch_pod), user), 3.5 SECONDS)


/obj/structure/halo_droppod/proc/launch_pod(mob/user)
	if(!launch_sequence_active || pod_state != POD_INFLIGHT || reservation)
		return
	var/mob/living/current_occupant = sync_occupant_state(FALSE)
	if(!current_occupant)
		reset_launch_state(TRUE)
		return

	playsound(src, 'sound/effects/escape_pod_launch.ogg', 70)
	sleep(1 SECONDS)
	if(SSticker?.mode)
		if(!(MODE_HAS_TOGGLEABLE_FLAG(MODE_DISABLE_INTRO_BLURB)))
			if(!(SSticker.mode.flags_round_type & MODE_DS_LANDED)) //Launching on first drop.
				SSticker.mode.pod_first_drop(src)
				SSticker.mode.flags_round_type |= MODE_DS_LANDED
	reservation = SSmapping.request_turf_block_reservation(5, 5, 1, reservation_type = /datum/turf_reservation/transit/drop_pod)
	if(!reservation)
		to_chat(user, SPAN_WARNING("Error. No droppod transit corridor available."))
		reset_launch_state(TRUE)
		return
	var/turf/bottom_left_turf = reservation.bottom_left_turfs[1]
	var/turf/top_right_turf = reservation.top_right_turfs[1]
	var/middle_x = bottom_left_turf.x + floor((top_right_turf.x - bottom_left_turf.x) / 2)
	var/middle_y = bottom_left_turf.y + floor((top_right_turf.y - bottom_left_turf.y) / 2)
	var/turf/selectedturf = locate(middle_x, middle_y, bottom_left_turf.z)
	if(!selectedturf)
		to_chat(user, SPAN_WARNING("Error. No droppod transit turf available."))
		reset_launch_state(TRUE)
		return
	forceMove(selectedturf)
	time_to_chute = time_to_land - 12 SECONDS
	if(current_occupant)
		shake_camera(user, time_to_land, 0.1)
	addtimer(CALLBACK(src, PROC_REF(chute_deploy), user), time_to_chute)
	addtimer(CALLBACK(src, PROC_REF(finish_drop), user, selectedturf), time_to_land)

/obj/structure/halo_droppod/proc/chute_deploy(mob/user)
	playsound(src, 'sound/effects/escape_pod_launch.ogg')
	if(occupant)
		shake_camera(user, 3, 3)
	chute_obj.pixel_y = 32
	chute_obj.icon_state = "chute_open"
	time_to_thruster = 6 SECONDS
	addtimer(CALLBACK(src, PROC_REF(thruster_fire), user), time_to_thruster)

/obj/structure/halo_droppod/proc/thruster_fire(mob/user)
	if(occupant)
		shake_camera(user, 3, 3)
	animate(chute_obj, pixel_z = 500, time = 1 SECONDS, easing = LINEAR_EASING)
	sleep(2 SECONDS)
	rocket_image = image(src.icon, loc, "rocket_burn")
	rocket_image.pixel_y = -32
	overlays += rocket_image
	animate(src, pixel_z = 500, time = 4 SECONDS, easing = LINEAR_EASING)
	playsound(src, 'modular/halo/sound/effects/odst_pod/pod_jet.ogg')
	sleep(4 SECONDS)
	qdel(chute_obj)
	handle_overlays(user)


/obj/structure/halo_droppod/proc/finish_drop(mob/user, turf/reservedturf)
	var/turf/targetturf = planned_landing_turf
	if(!targetturf || !checklanding(optional_turf = targetturf, ignore_reserved_turf = planned_landing_turf))
		if(user)
			to_chat(user, SPAN_WARNING("WARNING! TARGET ZONE OCCUPIED! EVADING!"))
		targetturf = find_new_target(user, ignore_reserved_turf = planned_landing_turf)
		if(targetturf)
			set_planned_landing_target(targetturf)
	if(!targetturf)
		finish_drop_retries++
		if(finish_drop_retries >= 30)
			if(user)
				to_chat(user, SPAN_DANGER("CRITICAL! NO LZ FOUND AFTER 30 ATTEMPTS! ABORTING DROP!"))
			if(reservedturf)
				forceMove(reservedturf)
			reset_launch_state(TRUE)
			return
		if(user)
			to_chat(user, SPAN_WARNING("WARNING! NO SAFE LZ AVAILABLE! HOLDING IN TRANSIT! (Attempt [finish_drop_retries]/30)"))
		addtimer(CALLBACK(src, PROC_REF(finish_drop), user, reservedturf), 1 SECONDS)
		return
	finish_drop_retries = 0
	forceMove(targetturf)
	release_landing_target()
	QDEL_NULL(reservation)
	animate(src, pixel_z = initial(pixel_z), time = landing_time, easing = LINEAR_EASING)
	if(occupant)
		shake_camera(user, landing_time, 1)
	addtimer(CALLBACK(src, PROC_REF(do_drop), targetturf, user), landing_time)
	handle_overlays(user)

/obj/structure/halo_droppod/proc/do_drop(turf/targetturf, mob/user)
	var/datum/cause_data/cause_data = create_cause_data("[src]", user)
	explosion(targetturf, light_impact_range = 2, explosion_cause_data = cause_data)
	playsound(targetturf, "droppod_land", 100)
	addtimer(CALLBACK(src, PROC_REF(complete_drop), user), 2 SECONDS)

/obj/structure/halo_droppod/proc/complete_drop(mob/user)
	launch_sequence_active = FALSE
	locked = FALSE
	playsound(src, 'modular/halo/sound/effects/odst_pod/door_kaboom.ogg')
	addtimer(CALLBACK(src, PROC_REF(door_explode), user), 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(exit_pod), user), 4 SECONDS)

/obj/structure/halo_droppod/proc/door_explode(mob/user)
	qdel(door_obj)
	var/obj/item/drop_pod_door/new_door_obj
	new_door_obj = new /obj/item/drop_pod_door(loc)
	new_door_obj.icon_state = "pod_door_open"
	new_door_obj.layer = 3
	new_door_obj.pixel_x = -16
	var/turf/target = get_offset_target_turf(loc, 0, -5)
	var/target_turf = get_turf(target)
	new_door_obj.throw_atom(target_turf, 16, SPEED_FAST, loc, FALSE)
	if(occupant)
		shake_camera(user, 3, 1)
	pod_state = POD_LANDED
	new_door_obj.icon_state = "pod_door_floor"
	sleep(0.8 SECONDS)

	playsound(new_door_obj, 'modular/halo/sound/effects/odst_pod/door_clang_1.ogg')
