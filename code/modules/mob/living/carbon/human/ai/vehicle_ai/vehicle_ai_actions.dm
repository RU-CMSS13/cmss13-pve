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

/// Fires everything at what the game master ordered, before anything the crew picks itself
/datum/vehicle_ai_action/fire_on_order
	name = "Fire On Order"
	action_flags = VEHICLE_AI_ACTION_GUNNING

/datum/vehicle_ai_action/fire_on_order/get_weight(datum/vehicle_ai_brain/brain)
	return brain.get_ordered_fire_target() ? 15 : 0

/datum/vehicle_ai_action/fire_on_order/Destroy(force, ...)
	brain?.stop_all_weapons()
	return ..()

/datum/vehicle_ai_action/fire_on_order/trigger_action()
	. = ..()
	if(.)
		return

	// As far as the guns reach, the game master sees what the crew can't
	brain.fire_weapons(brain.get_ordered_fire_target(), INFINITY)
	return ONGOING_ACTION_UNFINISHED

/// Turns the turret to where we were shot from or last saw the enemy, so it is ready once they show up
/datum/vehicle_ai_action/aim_at_threat
	name = "Aim At Threat"
	action_flags = VEHICLE_AI_ACTION_GUNNING

/datum/vehicle_ai_action/aim_at_threat/get_weight(datum/vehicle_ai_brain/brain)
	if(brain.current_target || !brain.get_aim_target() || !brain.has_working_turret())
		return 0

	return 5

/datum/vehicle_ai_action/aim_at_threat/trigger_action()
	. = ..()
	if(.)
		return

	brain.aim_turret(brain.get_turret(), brain.get_aim_target())
	return ONGOING_ACTION_UNFINISHED

// Driving

/// Drives out of the way of a friendly vehicle that asked to pass
/datum/vehicle_ai_action/driving/make_way
	name = "Make Way"

/datum/vehicle_ai_action/driving/make_way/get_weight(datum/vehicle_ai_brain/brain)
	if(!brain.make_way_turf || (world.time > brain.make_way_until) || !brain.can_drive())
		return 0

	return 14

/datum/vehicle_ai_action/driving/make_way/trigger_action()
	. = ..()
	if(.)
		return

	if(brain.drive_to(brain.make_way_turf, 0) == VEHICLE_AI_DRIVE_MOVING)
		return ONGOING_ACTION_UNFINISHED

	brain.make_way_turf = null
	return ONGOING_ACTION_COMPLETED

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

	if(!brain.can_fight_back())
		return 0

	if(!COOLDOWN_FINISHED(brain, approach_retry))
		return 0

	// Without shoot to kill only fire from out of sight is driven up to, enemies in sight aren't chased
	if(!brain.shoots_to_kill() && (brain.current_target || !brain.target_turf_unseen))
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
	var/atom/aim_target = brain.get_aim_target()
	if(!aim_target || !brain.can_drive())
		return 0

	if(!brain.get_hull_aim_dir(aim_target))
		return 0

	return 7

/datum/vehicle_ai_action/driving/face_target/trigger_action()
	. = ..()
	if(.)
		return

	brain.turn_to(brain.get_hull_aim_dir(brain.get_aim_target()))
	return ONGOING_ACTION_UNFINISHED

/datum/vehicle_ai_brain
	/// A vehicle that can't shoot back drives until it is this far from where its enemy was last seen
	var/flee_distance = 12
	/// How many places for the vehicle the search for a way out may look at
	var/flee_search_nodes = 800
	/// The way out doesn't lead closer than this to the enemy
	var/flee_threat_clearance = 2
	/// How long a cornered vehicle tries to run its enemy over before looking for a way out again
	var/ram_time = 6 SECONDS

/datum/vehicle_ai_action/driving/flee
	name = "Flee"
	/// The turf we are driving away to
	var/turf/flee_turf
	/// world.time until which we try to run the enemy over instead, 0 if we aren't cornered
	var/ramming_until = 0
	/// A way out that gets us less than this much further from the enemy is no way out, unless it gets us out of reach
	var/min_flee_gain = 4

/datum/vehicle_ai_action/driving/flee/get_weight(datum/vehicle_ai_brain/brain)
	if(!brain.in_combat || brain.hold_position || !brain.can_drive())
		return 0

	if(!brain.current_target && (!brain.target_turf || (get_dist(brain.vehicle, brain.target_turf) >= brain.flee_distance)))
		return 0

	if(brain.can_fight_back())
		return 0

	return 11

/datum/vehicle_ai_action/driving/flee/Added()
	brain.crew_say(brain.flee_lines, VEHICLE_DRIVER)

/datum/vehicle_ai_action/driving/flee/trigger_action()
	. = ..()
	if(.)
		return

	var/turf/threat_turf = brain.current_target ? get_turf(brain.current_target) : brain.target_turf
	if(ramming_until)
		if(world.time < ramming_until)
			ram(brain.current_target)
			return ONGOING_ACTION_UNFINISHED
		// Moving around may have opened a way out
		ramming_until = 0
		brain.clear_path()

	if(!flee_turf)
		var/list/turf/path = brain.find_flee_path(threat_turf, min_flee_gain)
		if(!path)
			ramming_until = world.time + brain.ram_time
			if(isliving(brain.current_target))
				brain.crew_say(brain.ram_lines, VEHICLE_DRIVER)
			return ONGOING_ACTION_UNFINISHED

		// The search already found the way, the pathfinder takes over only if we get stuck on it
		brain.clear_path()
		flee_turf = path[1]
		brain.current_path = path
		brain.path_goal = flee_turf

	// The way out can be a single step, so only standing on it counts as there
	switch(brain.drive_to(flee_turf, 0))
		if(VEHICLE_AI_DRIVE_ARRIVED)
			// Still in danger, keep going
			flee_turf = null
		if(VEHICLE_AI_DRIVE_FAILED)
			flee_turf = null
			brain.clear_path()

	return ONGOING_ACTION_UNFINISHED

/// Cornered, drives into the enemy to run it over. Vehicles and emplacements can't be, so it just waits for a way out
/datum/vehicle_ai_action/driving/flee/proc/ram(atom/movable/target)
	if(!isliving(target))
		return

	// Ran into it, pull away for another go
	if(get_dist(brain.vehicle, target) <= 1)
		brain.clear_path()
		var/target_dir = get_cardinal_dir(brain.vehicle, target)
		brain.drive_step((target_dir == REVERSE_DIR(brain.vehicle.dir)) ? brain.vehicle.dir : REVERSE_DIR(brain.vehicle.dir))
		return

	if(brain.drive_to(get_turf(target), 1) == VEHICLE_AI_DRIVE_FAILED)
		brain.clear_path()

/**
 * Looks for a way away from the threat, going along corridors and around corners like the vehicle would drive.
 * Takes the closest place at least flee_distance from the threat, else the furthest one that gets us min_gain further away.
 * Unless the vehicle crushes its way through anyway, open ground is tried first. Returns the path there, next step last, or null if there is no way out
 */
/datum/vehicle_ai_brain/proc/find_flee_path(turf/threat_turf, min_gain)
	RETURN_TYPE(/list)
	if(!vehicle.ai_crushes_obstacles)
		. = search_flee_path(threat_turf, min_gain, TRUE)
	if(!.)
		. = search_flee_path(threat_turf, min_gain, FALSE)

/datum/vehicle_ai_brain/proc/search_flee_path(turf/threat_turf, min_gain, clear_only)
	RETURN_TYPE(/list)
	var/turf/start = get_turf(vehicle)
	if(!start || !threat_turf || (threat_turf.z != start.z))
		return

	var/list/turf/came_from = list()
	came_from[start] = start
	var/list/turf/queue = list(start)
	// Assoc list of turf : drive cost, footprints of neighbouring places overlap a lot
	var/list/turf_costs = list()

	var/turf/best_turf
	var/best_distance = min(get_dist(start, threat_turf) + min_gain, flee_distance) - 1
	var/index = 0
	while((index < length(queue)) && (index < flee_search_nodes))
		index++
		var/turf/current = queue[index]
		var/distance = get_dist(current, threat_turf)
		if(distance > best_distance)
			best_turf = current
			best_distance = distance
			// Breadth first, so this is the closest place out of reach
			if(distance >= flee_distance)
				break

		for(var/direction in GLOB.cardinals)
			var/turf/neighbor = get_step(current, direction)
			if(!neighbor || came_from[neighbor])
				continue
			came_from[neighbor] = current
			if(get_dist(neighbor, threat_turf) <= flee_threat_clearance)
				continue
			if(!can_flee_through(neighbor, turf_costs, clear_only))
				continue
			queue += neighbor

	if(!best_turf)
		return

	var/list/turf/path = list()
	var/turf/node = best_turf
	while(node != start)
		path += node
		node = came_from[node]
	return path

/// TRUE if the whole vehicle fits around the center, without anything to crush in the way if clear_only
/datum/vehicle_ai_brain/proc/can_flee_through(turf/center, list/turf_costs, clear_only)
	var/list/turf/footprint = get_footprint(center)
	if(!footprint)
		return FALSE

	for(var/turf/footprint_turf as anything in footprint)
		var/cost = turf_costs[footprint_turf]
		if(isnull(cost))
			cost = get_turf_drive_cost(footprint_turf)
			turf_costs[footprint_turf] = cost
		if((cost < 0) || (clear_only && cost > 0))
			return FALSE
	return TRUE
