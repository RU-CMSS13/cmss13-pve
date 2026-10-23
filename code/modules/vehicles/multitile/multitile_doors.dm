/*
	Vehicle doors

	A door covers one or more of the vehicle's entrances. The base sprite shows the doorway open,
	the closed door is drawn over it as an overlay.

	A passenger can stand in the doorway: the mob stands on the hull tile behind the door entrance,
	is drawn inside the doorway, moves with the vehicle and can shoot or throw things outside without
	leaving it. Attacks on the vehicle coming from the door side hit the mob instead.
*/

/datum/vehicle_door
	var/name = "door"
	var/obj/vehicle/multitile/vehicle
	/// Keys of the vehicle's entrances list this door covers
	var/list/entrance_ids = list()
	/// Entrance whose hull tile the doorway occupant stands on
	var/doorway_entrance
	var/open = FALSE
	/// Overlay drawn over the open doorway of the base sprite while the door is closed
	var/closed_icon_state = "door_closed"
	/// The mob standing in the doorway
	var/mob/living/carbon/human/occupant
	/// Pixel offsets of the occupant by vehicle dir, so the mob is drawn inside the doorway
	var/list/occupant_offsets = list(
		"1" = list(0, 0),
		"2" = list(0, 0),
		"4" = list(0, 0),
		"8" = list(0, 0),
	)
	/// Vehicle dirs in which the door is on the far side of the hull, so the occupant is drawn behind it
	var/occupant_behind_dirs = NONE
	/// The occupant sprite is shrunk to fit the doorway
	var/occupant_scale = 0.75
	/// Chance for the occupant to be flung out when the vehicle crashes, reduced by each endurance skill level
	var/eject_chance = 60
	var/eject_chance_per_endurance = 10
	var/eject_chance_min = 10
	/// Layer of the occupant before they stood in the doorway
	var/occupant_old_layer
	/// Set while the door itself moves the occupant, so the move isn't taken as stepping out
	var/moving_occupant = FALSE
	/// How long it takes to step into the doorway or back inside
	var/transition_time = 1 SECONDS
	/// Set while the occupant waits to get back inside
	var/occupant_going_inside = FALSE
	/// How far a shoved occupant stumbles away from the door
	var/shove_distance = 1

/datum/vehicle_door/New(obj/vehicle/multitile/new_vehicle)
	. = ..()
	vehicle = new_vehicle
	RegisterSignal(vehicle, COMSIG_MOVABLE_MOVED, PROC_REF(on_vehicle_moved))

/datum/vehicle_door/Destroy()
	if(occupant)
		release_occupant()
	vehicle = null
	return ..()

/datum/vehicle_door/proc/get_entrance_turf(entrance_id)
	var/list/coords = vehicle.entrances[entrance_id]
	if(!coords)
		return null
	return locate(vehicle.x + coords[1], vehicle.y + coords[2], vehicle.z)

/// The hull tile right behind the doorway entrance
/datum/vehicle_door/proc/get_doorway_turf()
	var/list/coords = vehicle.entrances[doorway_entrance]
	if(!coords)
		return null
	var/min_x = vehicle.bound_x / world.icon_size
	var/min_y = vehicle.bound_y / world.icon_size
	var/max_x = min_x + vehicle.bound_width / world.icon_size - 1
	var/max_y = min_y + vehicle.bound_height / world.icon_size - 1
	return locate(vehicle.x + clamp(coords[1], min_x, max_x), vehicle.y + clamp(coords[2], min_y, max_y), vehicle.z)

/// The direction from the doorway to the outside
/datum/vehicle_door/proc/get_outward_dir()
	return get_dir(get_doorway_turf(), get_entrance_turf(doorway_entrance))

/// Whether A is on the outer side of the door
/datum/vehicle_door/proc/faces_atom(atom/A)
	var/turf/doorway = get_doorway_turf()
	var/turf/T = get_turf(A)
	if(!doorway || !T)
		return FALSE
	return get_dir(doorway, T) & get_outward_dir()

/// Whether A is next to the door on its outer side
/datum/vehicle_door/proc/is_in_front(atom/A)
	return get_dist(get_doorway_turf(), A) <= 1 && faces_atom(A)

/datum/vehicle_door/proc/set_open(new_open)
	if(open == new_open)
		return
	open = new_open
	playsound(vehicle, open ? 'sound/machines/door_open.ogg' : 'sound/machines/door_close.ogg', 25, TRUE)
	vehicle.update_icon()

/// Opening or closing the door from outside, or from inside through the interior exit
/datum/vehicle_door/proc/try_toggle(mob/living/user, atom/exit)
	if(occupant)
		to_chat(user, SPAN_WARNING("[occupant] is standing in \the [name]!"))
		return
	// The lock only keeps the door from being opened
	if(!open && (exit ? (vehicle.door_locked && vehicle.health > 0) : vehicle.is_locked_for(user)))
		to_chat(user, SPAN_WARNING("\The [vehicle] is locked!"))
		return
	set_open(!open)
	user.visible_message(SPAN_NOTICE("[user] [open ? "opens" : "closes"] \the [vehicle]'s [name]."),
	SPAN_NOTICE("You [open ? "open" : "close"] \the [vehicle]'s [name]."))

/// Whether something can be thrown out through the door from inside, the door opening for it
/datum/vehicle_door/proc/can_throw_through(mob/living/user)
	if(!open && vehicle.door_locked && vehicle.health > 0)
		to_chat(user, SPAN_WARNING("\The [vehicle] is locked!"))
		return FALSE
	return TRUE

/// Closes the door when the driver locks the vehicle, the occupant goes back inside
/datum/vehicle_door/proc/force_close()
	if(occupant && !return_inside())
		var/mob/living/carbon/human/user = release_occupant()
		put_outside(user)
	set_open(FALSE)

// Doorway occupant

/// Stepping into the doorway, from inside through the interior exit or from outside when there's no exit given.
/// On harm intent the user shoves whoever already stands there to the other side of the door
/datum/vehicle_door/proc/try_enter_doorway(mob/living/carbon/human/user, atom/exit)
	if(!can_enter_doorway(user, exit))
		return
	to_chat(user, SPAN_NOTICE("You move into \the [name]."))
	// Coming from inside, the user already sees outside while they wait
	if(exit)
		user.reset_view(vehicle)
	var/success = do_after(user, transition_time, INTERRUPT_NO_NEEDHAND, BUSY_ICON_GENERIC) && can_enter_doorway(user, exit) && (!occupant || shove_occupant(user, exit)) && get_doorway_turf()
	if(success)
		set_open(TRUE)
		take_occupant(user, get_doorway_turf())
	if(exit)
		user.reset_view(null)
	if(!success)
		return
	user.visible_message(SPAN_NOTICE("[user] appears in \the [vehicle]'s [name]."),
	SPAN_NOTICE("You stand in \the [vehicle]'s [name]. Step outward to get out, step inward or click \the [vehicle] to get inside."))

/datum/vehicle_door/proc/can_enter_doorway(mob/living/carbon/human/user, atom/exit)
	if(!istype(user) || user.is_mob_incapacitated() || user.body_position == LYING_DOWN)
		return FALSE
	if(exit)
		if(!user.Adjacent(exit))
			return FALSE
		if(vehicle.door_locked && vehicle.health > 0)
			to_chat(user, SPAN_WARNING("\The [name] is locked."))
			return FALSE
	else
		if(vehicle.get_door_at(user) != src)
			return FALSE
		if(!open)
			to_chat(user, SPAN_WARNING("\The [vehicle]'s [name] is closed."))
			return FALSE
		if(vehicle.is_locked_for(user))
			to_chat(user, SPAN_WARNING("\The [vehicle] is locked!"))
			return FALSE
	if(occupant && user.a_intent != INTENT_HARM)
		to_chat(user, SPAN_WARNING("[occupant] is already standing in \the [name]."))
		return FALSE
	return TRUE

/// Shoves the occupant inside when the user comes from outside, or outside when the user comes from inside
/datum/vehicle_door/proc/shove_occupant(mob/living/carbon/human/user, atom/exit)
	var/outward_dir = get_outward_dir()
	var/mob/living/carbon/human/shoved = release_occupant()
	var/success
	var/shove_dir
	if(exit)
		var/turf/entrance_turf = get_entrance_turf(doorway_entrance)
		// Stepping them out glides them out of the doorway
		success = shoved.Move(entrance_turf, outward_dir) || vehicle.interior.exit(shoved, entrance_turf)
		shove_dir = outward_dir
	else
		success = vehicle.interior.enter(shoved, doorway_entrance)
		// Entrance markers face the door
		var/obj/effect/landmark/interior/spawn/entrance/marker = get_entrance_marker()
		shove_dir = marker && turn(marker.dir, 180)
	if(!success)
		take_occupant(shoved, get_doorway_turf())
		to_chat(user, SPAN_WARNING("You fail to shove [shoved] [exit ? "out of" : "into"] \the [vehicle]!"))
		return FALSE
	user.visible_message(SPAN_WARNING("[user] shoves [shoved] [exit ? "out of" : "into"] \the [vehicle]!"),
	SPAN_WARNING("You shove [shoved] [exit ? "out of" : "into"] \the [vehicle]!"))
	if(shove_dir)
		var/turf/target = get_ranged_target_turf(shoved, shove_dir, shove_distance)
		INVOKE_ASYNC(shoved, TYPE_PROC_REF(/atom/movable, throw_atom), target, shove_distance, SPEED_FAST, user)
	return TRUE

/// Clicking the interior exit: disarm intent opens or closes the door, grab intent pulls the occupant back inside,
/// otherwise the user steps into the doorway
/datum/vehicle_door/proc/handle_inside_click(mob/living/carbon/human/user, atom/exit)
	if(user.a_intent == INTENT_DISARM)
		try_toggle(user, exit)
		return
	if(occupant && user.a_intent == INTENT_GRAB)
		try_pull_in(user, exit)
		return
	try_enter_doorway(user, exit)

/// Pulling the occupant back inside from the interior
/datum/vehicle_door/proc/try_pull_in(mob/living/carbon/human/user, atom/exit)
	var/mob/living/carbon/human/pulled = occupant
	user.visible_message(SPAN_WARNING("[user] grabs [pulled] and starts pulling them inside."),
	SPAN_WARNING("You grab [pulled] and start pulling them inside."))
	to_chat(pulled, SPAN_WARNING("[user] is pulling you inside \the [vehicle]!"))
	if(!do_after(user, transition_time, INTERRUPT_NO_NEEDHAND, BUSY_ICON_GENERIC))
		return
	if(occupant != pulled || !user.Adjacent(exit) || user.is_mob_incapacitated())
		return
	if(!return_inside())
		return
	user.visible_message(SPAN_WARNING("[user] pulls [pulled] inside."),
	SPAN_WARNING("You pull [pulled] inside."))

/// Pushing a pulled thing out through the door from inside
/datum/vehicle_door/proc/try_push_out(mob/living/carbon/human/user, atom/movable/pushed, atom/exit)
	if(vehicle.door_locked && vehicle.health > 0)
		to_chat(user, SPAN_WARNING("\The [name] is locked."))
		return
	if(occupant)
		to_chat(user, SPAN_WARNING("[occupant] is standing in \the [name]."))
		return
	to_chat(user, SPAN_NOTICE("You start pushing [pushed] out of \the [vehicle]..."))
	if(!do_after(user, 2 SECONDS, INTERRUPT_NO_NEEDHAND, BUSY_ICON_GENERIC))
		return
	if(occupant || user.pulling != pushed || !user.Adjacent(exit))
		return
	if(!vehicle.interior.exit(pushed, get_entrance_turf(doorway_entrance)))
		return
	set_open(TRUE)
	user.visible_message(SPAN_NOTICE("[user] pushes [pushed] out of \the [vehicle]'s [name]."),
	SPAN_NOTICE("You push [pushed] out of \the [vehicle]'s [name]."))

/datum/vehicle_door/proc/take_occupant(mob/living/carbon/human/user, turf/doorway)
	occupant = user
	occupant_old_layer = user.layer
	moving_occupant = TRUE
	user.forceMove(doorway)
	moving_occupant = FALSE
	user.base_transform = matrix().Scale(occupant_scale)
	user.apply_transform(user.raw_transform || matrix())
	update_occupant_visuals()
	RegisterSignal(user, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_occupant_pre_move))
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_occupant_moved))
	RegisterSignal(user, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(on_occupant_body_position))
	RegisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(on_occupant_deleted))

/// Clears the doorway state of the occupant without moving them. Returns the former occupant
/datum/vehicle_door/proc/release_occupant()
	var/mob/living/carbon/human/user = occupant
	occupant = null
	UnregisterSignal(user, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED, COMSIG_LIVING_SET_BODY_POSITION, COMSIG_PARENT_QDELETING))
	user.pixel_x = user.base_pixel_x
	user.pixel_y = user.base_pixel_y
	user.layer = occupant_old_layer
	user.base_transform = null
	user.apply_transform(user.raw_transform || matrix())
	return user

/datum/vehicle_door/proc/update_occupant_visuals()
	var/list/offsets = occupant_offsets["[vehicle.dir]"]
	occupant.setDir(get_outward_dir())
	occupant.pixel_x = occupant.base_pixel_x + offsets[1]
	occupant.pixel_y = occupant.base_pixel_y + offsets[2]
	occupant.layer = vehicle.layer + ((vehicle.dir & occupant_behind_dirs) ? -0.01 : 0.05)

/// Keeps the occupant in the doorway after the vehicle moved or turned
/datum/vehicle_door/proc/update_occupant()
	if(!occupant)
		return
	var/turf/doorway = get_doorway_turf()
	if(!doorway)
		release_occupant()
		return
	occupant.glide_size = vehicle.glide_size
	moving_occupant = TRUE
	occupant.forceMove(doorway)
	moving_occupant = FALSE
	update_occupant_visuals()

/// The occupant going back inside on their own. The camera moves inside while they wait
/datum/vehicle_door/proc/try_return_inside()
	if(!occupant || occupant_going_inside)
		return
	var/mob/living/carbon/human/user = occupant
	occupant_going_inside = TRUE
	user.reset_view(get_entrance_marker())
	// The vehicle moving the occupant along shouldn't interrupt them
	var/success = do_after(user, transition_time, INTERRUPT_NO_NEEDHAND & ~(INTERRUPT_DIFF_LOC|INTERRUPT_DIFF_TURF), BUSY_ICON_GENERIC) && occupant == user
	occupant_going_inside = FALSE
	if(success)
		return_inside()
	user.reset_view(null)

/datum/vehicle_door/proc/get_entrance_marker()
	for(var/obj/effect/landmark/interior/spawn/entrance/marker in vehicle.interior?.entrance_markers)
		if(marker.tag == doorway_entrance)
			return marker
	return null

/// Moves the occupant back inside. If there's no room, they stay in the doorway
/datum/vehicle_door/proc/return_inside()
	if(!occupant)
		return FALSE
	var/mob/living/carbon/human/user = release_occupant()
	if(!vehicle.interior?.enter(user, doorway_entrance))
		take_occupant(user, get_doorway_turf())
		return FALSE
	set_open(FALSE)
	return TRUE

/// Drops a former occupant out of the door, or back inside if the way out is blocked
/datum/vehicle_door/proc/put_outside(mob/living/carbon/human/user)
	if(!vehicle.interior)
		return
	if(vehicle.interior.exit(user, get_entrance_turf(doorway_entrance)))
		return
	vehicle.interior.enter(user, doorway_entrance)

/// Flings the occupant out of the door when the vehicle crashes, unless they hold on
/datum/vehicle_door/proc/eject_occupant(fling_distance)
	if(!occupant)
		return
	var/endurance = occupant.skills ? occupant.skills.get_skill_level(SKILL_ENDURANCE) : SKILL_ENDURANCE_NONE
	if(!prob(max(eject_chance - endurance * eject_chance_per_endurance, eject_chance_min)))
		shake_camera(occupant, 2, 1)
		to_chat(occupant, SPAN_WARNING("You barely hold on in \the [vehicle]'s [name]!"))
		return
	var/fling_dir = get_outward_dir()
	var/travel_dir = vehicle.move_momentum > 0 ? vehicle.dir : turn(vehicle.dir, 180)
	if(travel_dir != fling_dir && travel_dir != turn(fling_dir, 180))
		fling_dir |= travel_dir

	var/mob/living/carbon/human/user = release_occupant()
	user.apply_effect(1, STUN)
	user.apply_effect(2, WEAKEN)
	user.visible_message(SPAN_DANGER("[user] is flung out of \the [vehicle]'s [name]!"),
	SPAN_DANGER("You are flung out of \the [vehicle]!"))

	var/turf/target = get_ranged_target_turf(user, fling_dir, fling_distance)
	INVOKE_ASYNC(user, TYPE_PROC_REF(/atom/movable, throw_atom), target, fling_distance, SPEED_VERY_FAST, vehicle, TRUE)

/datum/vehicle_door/proc/on_vehicle_moved()
	SIGNAL_HANDLER
	update_occupant()

/datum/vehicle_door/proc/on_occupant_pre_move(mob/living/carbon/human/source, atom/new_loc)
	SIGNAL_HANDLER
	if(moving_occupant)
		return
	if(occupant_going_inside)
		return COMPONENT_CANCEL_MOVE
	var/move_dir = get_dir(source, new_loc)
	var/outward_dir = get_outward_dir()
	// Stepping out, finished in on_occupant_moved()
	if(move_dir & outward_dir)
		return
	if(move_dir & turn(outward_dir, 180))
		INVOKE_ASYNC(src, PROC_REF(try_return_inside))
	return COMPONENT_CANCEL_MOVE

/datum/vehicle_door/proc/on_occupant_moved()
	SIGNAL_HANDLER
	if(moving_occupant)
		return
	release_occupant()

/datum/vehicle_door/proc/on_occupant_body_position(mob/living/carbon/human/source, new_value)
	SIGNAL_HANDLER
	if(new_value != LYING_DOWN)
		return
	var/mob/living/carbon/human/user = release_occupant()
	user.visible_message(SPAN_WARNING("[user] falls out of \the [vehicle]'s [name]!"),
	SPAN_WARNING("You fall out of \the [vehicle]'s [name]!"))
	put_outside(user)

/datum/vehicle_door/proc/on_occupant_deleted()
	SIGNAL_HANDLER
	release_occupant()

// Vehicle helpers

/obj/vehicle/multitile/proc/get_door(entrance_id)
	for(var/datum/vehicle_door/door as anything in doors)
		if(entrance_id in door.entrance_ids)
			return door
	return null

/// The door whose entrance A stands at
/obj/vehicle/multitile/proc/get_door_at(atom/A)
	var/turf/T = get_turf(A)
	for(var/datum/vehicle_door/door as anything in doors)
		for(var/entrance_id in door.entrance_ids)
			if(door.get_entrance_turf(entrance_id) == T)
				return door
	return null

/// Clicking the vehicle from a door entrance: help intent opens or closes the door, other intents step into the doorway.
/// Returns TRUE if the click was handled
/obj/vehicle/multitile/proc/handle_door_click(mob/living/user)
	if(!ishuman(user))
		return FALSE
	var/datum/vehicle_door/door = get_door_at(user)
	if(!door)
		return FALSE
	if(user.a_intent == INTENT_HELP)
		door.try_toggle(user)
	else
		door.try_enter_doorway(user)
	return TRUE

/obj/vehicle/multitile/proc/get_occupied_door(mob/M)
	for(var/datum/vehicle_door/door as anything in doors)
		if(door.occupant == M)
			return door
	return null

/// The doorway occupant an attack from A would hit instead of the vehicle
/obj/vehicle/multitile/proc/get_door_occupant_in_front(atom/A)
	for(var/datum/vehicle_door/door as anything in doors)
		if(door.occupant && door.occupant != A && door.is_in_front(A))
			return door.occupant
	return null

/// Returns TRUE if the projectile went to a doorway occupant instead of the vehicle
/obj/vehicle/multitile/proc/door_occupant_intercept_projectile(obj/projectile/P)
	for(var/datum/vehicle_door/door as anything in doors)
		if(!door.occupant || P.firer == door.occupant)
			continue
		// The projectile reached the doorway and was shot from the door side
		if(get_dist(door.get_doorway_turf(), P) > 1 || !door.faces_atom(P.starting))
			continue
		return P.handle_mob(door.occupant)
	return FALSE

/obj/vehicle/multitile/proc/update_door_occupants()
	for(var/datum/vehicle_door/door as anything in doors)
		door.update_occupant()

/obj/vehicle/multitile/proc/close_doors()
	for(var/datum/vehicle_door/door as anything in doors)
		door.force_close()

/obj/vehicle/multitile/proc/eject_door_occupants(fling_distance)
	for(var/datum/vehicle_door/door as anything in doors)
		door.eject_occupant(fling_distance)

/obj/vehicle/multitile/proc/is_locked_for(mob/user)
	return door_locked && health > 0 && (!allowed(user) || !get_target_lock(user.faction_group))
