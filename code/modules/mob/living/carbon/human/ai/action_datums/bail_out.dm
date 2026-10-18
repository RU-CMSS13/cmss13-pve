/datum/human_ai_brain
	/// The door of the vehicle interior the AI is getting out through
	var/obj/structure/interior_exit/vehicle/bail_out_door
	/// world.time when the AI is out, counted from when it reached the door
	var/bail_out_at = 0
	/// world.time when the AI gives up on walking to a door and gets out anyway
	var/bail_out_deadline = 0
	/// Doors that turned out to be blocked from outside
	var/list/obj/structure/interior_exit/vehicle/bail_out_blocked_doors = list()

/// Has the AI walk to the nearest door of the vehicle it is in and climb out. Returns FALSE if there is no door to go for
/datum/human_ai_brain/proc/bail_out(obj/vehicle/multitile/vehicle)
	bail_out_blocked_doors.Cut()
	var/obj/structure/interior_exit/vehicle/door = get_nearest_vehicle_door(vehicle)
	if(!door)
		return FALSE

	bail_out_door = door
	bail_out_at = 0
	bail_out_deadline = world.time + 20 SECONDS
	return TRUE

/// Returns the door of the vehicle's interior nearest to the AI, other than the ones blocked from outside
/datum/human_ai_brain/proc/get_nearest_vehicle_door(obj/vehicle/multitile/vehicle)
	RETURN_TYPE(/obj/structure/interior_exit/vehicle)
	if(!vehicle?.interior)
		return

	var/list/turf/bounds = vehicle.interior.get_bound_turfs()
	var/obj/structure/interior_exit/vehicle/nearest_door
	for(var/turf/interior_turf as anything in block(bounds[1], bounds[2]))
		for(var/obj/structure/interior_exit/vehicle/door in interior_turf)
			if(door in bail_out_blocked_doors)
				continue
			if(!nearest_door || (get_dist(tied_human, door) < get_dist(tied_human, nearest_door)))
				nearest_door = door
	return nearest_door

/datum/ai_action/bail_out
	name = "Bail Out"
	action_flags = ACTION_USING_LEGS
	preempts_actions = TRUE

/datum/ai_action/bail_out/get_weight(datum/human_ai_brain/brain)
	if(!brain.bail_out_door)
		return 0

	return 40

/datum/ai_action/bail_out/trigger_action()
	. = ..()

	var/obj/structure/interior_exit/vehicle/door = brain.bail_out_door
	var/mob/living/carbon/human/tied_human = brain.tied_human
	// Out already, or the vehicle is gone
	if(QDELETED(door) || (tied_human.z != door.z))
		brain.bail_out_door = null
		return ONGOING_ACTION_COMPLETED

	var/datum/interior/vehicle_interior = door.interior
	var/obj/vehicle/multitile/vehicle = vehicle_interior.exterior
	if(world.time > brain.bail_out_deadline)
		if(!vehicle_interior.exit(tied_human, door.get_exit_turf()))
			vehicle_interior.exit(tied_human)
		brain.bail_out_door = null
		return ONGOING_ACTION_COMPLETED

	if(get_dist(tied_human, door) > 1)
		brain.bail_out_at = 0
		brain.move_to_next_turf(get_turf(door))
		return ONGOING_ACTION_UNFINISHED

	// Climbing out takes as long as for anyone
	if(!brain.bail_out_at)
		brain.bail_out_at = world.time + vehicle.entrance_speed
		return ONGOING_ACTION_UNFINISHED

	if(world.time < brain.bail_out_at)
		return ONGOING_ACTION_UNFINISHED

	if(vehicle_interior.exit(tied_human, door.get_exit_turf()))
		brain.bail_out_door = null
		return ONGOING_ACTION_COMPLETED

	// Blocked from outside, try another door
	brain.bail_out_blocked_doors += door
	brain.bail_out_door = brain.get_nearest_vehicle_door(vehicle)
	brain.bail_out_at = 0
	if(!brain.bail_out_door)
		vehicle_interior.exit(tied_human)
		return ONGOING_ACTION_COMPLETED
	return ONGOING_ACTION_UNFINISHED
