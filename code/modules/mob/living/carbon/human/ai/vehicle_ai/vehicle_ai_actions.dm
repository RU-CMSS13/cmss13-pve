/**
 * Something the vehicle AI does, weighed every tick like /datum/ai_action of human AI.
 *
 * SSvehicle_ai keeps one instance of each type to call get_weight() and get_conflicts() on,
 * the brain makes its own instance for each action it starts.
 */
/datum/vehicle_ai_action
	var/name
	/// The brain doing this action, null on the singletons
	var/datum/vehicle_ai_brain/brain
	var/action_flags = null
	/// The weight this action started with. A heavier action that conflicts with it replaces it
	var/weight = 0

/// Proc to be overridden to determine what weight this action should have, 0 to not do it
/datum/vehicle_ai_action/proc/get_weight(datum/vehicle_ai_brain/brain)
	return 0

/// Returns the action types that can't run at the same time as this one
/datum/vehicle_ai_action/proc/get_conflicts(datum/vehicle_ai_brain/brain)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)
	. = list()

	if(!action_flags)
		return

	var/list/datum/vehicle_ai_action/all_actions = SSvehicle_ai.get_actions()
	for(var/action_type in all_actions)
		if(all_actions[action_type].action_flags & action_flags)
			. += action_type

/datum/vehicle_ai_action/New(datum/vehicle_ai_brain/brain)
	. = ..()

	if(!brain)
		return

	src.brain = brain
	Added()

/// Called when an action is created and assigned a brain
/datum/vehicle_ai_action/proc/Added()
	return

/datum/vehicle_ai_action/Destroy(force, ...)
	if(brain)
		brain.ongoing_actions -= src
		brain = null
	return ..()

/// Everything that the action should do should go in this proc
/datum/vehicle_ai_action/proc/trigger_action()
	SHOULD_NOT_SLEEP(TRUE)
	if(!brain)
		return ONGOING_ACTION_COMPLETED

	// The situation changed and this isn't worth doing anymore
	if(!get_weight(brain))
		return ONGOING_ACTION_COMPLETED

/datum/vehicle_ai_action/driving
	action_flags = VEHICLE_AI_ACTION_DRIVING

/datum/vehicle_ai_action/driving/Destroy(force, ...)
	brain?.clear_path()
	return ..()

// Gunning

/datum/vehicle_ai_action/engage_target
	name = "Engage Target"
	action_flags = VEHICLE_AI_ACTION_GUNNING

/datum/vehicle_ai_action/engage_target/get_weight(datum/vehicle_ai_brain/brain)
	if(!brain.current_target)
		return 0

	return 10

/datum/vehicle_ai_action/engage_target/Destroy(force, ...)
	brain?.stop_all_weapons()
	return ..()

/datum/vehicle_ai_action/engage_target/trigger_action()
	. = ..()
	if(.)
		return

	brain.fire_weapons(brain.current_target)
	return ONGOING_ACTION_UNFINISHED

// Driving

/datum/vehicle_ai_action/driving/move_to_destination
	name = "Move To Destination"

/datum/vehicle_ai_action/driving/move_to_destination/get_weight(datum/vehicle_ai_brain/brain)
	if(!brain.destination || brain.hold_position || !brain.can_drive())
		return 0

	return 12

/datum/vehicle_ai_action/driving/move_to_destination/trigger_action()
	. = ..()
	if(.)
		return

	if(brain.drive_to(brain.destination, 1) == VEHICLE_AI_DRIVE_MOVING)
		return ONGOING_ACTION_UNFINISHED

	brain.destination = null
	return ONGOING_ACTION_COMPLETED

/datum/vehicle_ai_action/driving/keep_distance
	name = "Keep Distance"

/datum/vehicle_ai_action/driving/keep_distance/get_weight(datum/vehicle_ai_brain/brain)
	if(!brain.in_combat || !brain.current_target || brain.hold_position || !brain.can_drive())
		return 0

	if(get_dist(brain.vehicle, brain.current_target) >= brain.min_engage_distance)
		return 0

	return 9

/datum/vehicle_ai_action/driving/keep_distance/trigger_action()
	. = ..()
	if(.)
		return

	// Back off one tile at a time, moving backwards if we can so the front keeps facing the enemy
	var/turf/center = get_turf(brain.vehicle)
	var/best_dir
	var/best_distance = get_dist(center, brain.current_target)
	for(var/direction in list(turn(brain.vehicle.dir, 180), brain.vehicle.dir, turn(brain.vehicle.dir, 90), turn(brain.vehicle.dir, -90)))
		var/turf/next_center = get_step(center, direction)
		if(!brain.can_occupy(next_center))
			continue
		var/distance = get_dist(next_center, brain.current_target)
		if(distance > best_distance)
			best_dir = direction
			best_distance = distance

	if(!best_dir)
		return ONGOING_ACTION_COMPLETED

	brain.drive_step(best_dir)
	return ONGOING_ACTION_UNFINISHED

/datum/vehicle_ai_brain
	/// The AI drives towards its target until it is this close and can see it
	var/max_engage_distance = 7
	/// Closer than this to its target, the AI backs off
	var/min_engage_distance = 4
	/// How long the AI waits after failing to reach its target before trying again
	var/approach_retry_time = 5 SECONDS

	COOLDOWN_DECLARE(approach_retry)

/datum/vehicle_ai_action/driving/approach_target
	name = "Approach Target"

/datum/vehicle_ai_action/driving/approach_target/get_weight(datum/vehicle_ai_brain/brain)
	if(!brain.in_combat || !brain.target_turf || brain.hold_position || !brain.can_drive())
		return 0

	if(!COOLDOWN_FINISHED(brain, approach_retry))
		return 0

	if(brain.current_target && (get_dist(brain.vehicle, brain.target_turf) <= brain.max_engage_distance) && brain.has_line_of_sight(brain.target_turf))
		return 0

	return 8

/datum/vehicle_ai_action/driving/approach_target/trigger_action()
	. = ..()
	if(.)
		return

	switch(brain.drive_to(brain.target_turf, 2))
		if(VEHICLE_AI_DRIVE_MOVING)
			return ONGOING_ACTION_UNFINISHED
		if(VEHICLE_AI_DRIVE_ARRIVED)
			// Nobody here anymore
			if(!brain.current_target)
				brain.target_turf = null
		if(VEHICLE_AI_DRIVE_FAILED)
			COOLDOWN_START(brain, approach_retry, brain.approach_retry_time)

	return ONGOING_ACTION_COMPLETED

/datum/vehicle_ai_action/driving/face_target
	name = "Face Target"

/datum/vehicle_ai_action/driving/face_target/get_weight(datum/vehicle_ai_brain/brain)
	if(!brain.current_target || !brain.can_drive())
		return 0

	if(!brain.get_hull_aim_dir(brain.current_target))
		return 0

	return 7

/datum/vehicle_ai_action/driving/face_target/trigger_action()
	. = ..()
	if(.)
		return

	brain.turn_to(brain.get_hull_aim_dir(brain.current_target))
	return ONGOING_ACTION_UNFINISHED
