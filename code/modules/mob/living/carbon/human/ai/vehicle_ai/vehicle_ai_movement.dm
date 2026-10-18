/datum/vehicle_ai_brain
	/// The list of turfs the vehicle's center is moving through, next step last
	var/list/turf/current_path
	/// The turf that current_path or the running pathfinder leads to
	var/turf/path_goal
	/// If TRUE, no path to path_goal was found
	var/path_failed = FALSE
	/// The path search in progress, if any
	var/datum/vehicle_ai_pathfinder/pathfinder
	/// How many tiles the pathfinder may look at each tick
	var/path_nodes_per_tick = 150
	/// Assoc list of turf : world.time until which the AI won't path through it, filled when the vehicle gets stuck
	var/list/turf/blocked_turfs = list()
	/// How long a turf the vehicle got stuck on is avoided
	var/blocked_turf_time = 15 SECONDS
	/// How many moves in a row failed to move the vehicle
	var/failed_moves = 0
	/// After this many failed moves in a row, the turfs ahead are avoided and a new path is found
	var/max_failed_moves = 4
	/// Paths with more straight steps backwards than this turn the vehicle around instead of reversing
	var/max_reverse_steps = 3
	/// Path cost added for each dense object the vehicle would have to crush
	var/crush_penalty = 3
	/// How long the AI waits for friendlies to get out of its way before driving around them
	var/friendly_wait_time = 4 SECONDS
	/// world.time when friendlies started blocking the way, 0 if they aren't
	var/friendly_blocked_since = 0

	/// Throttles new path searches
	COOLDOWN_DECLARE(repath_cooldown)

/// Returns the turfs covered by the vehicle if its center was on the given turf, or null if it doesn't fit on the map
/datum/vehicle_ai_brain/proc/get_footprint(turf/center)
	var/width = vehicle.bound_width / world.icon_size
	var/height = vehicle.bound_height / world.icon_size
	var/min_x = center.x + vehicle.bound_x / world.icon_size
	var/min_y = center.y + vehicle.bound_y / world.icon_size
	if(min_x < 1 || min_y < 1 || (min_x + width - 1) > world.maxx || (min_y + height - 1) > world.maxy)
		return null
	return block(min_x, min_y, center.z, min_x + width - 1, min_y + height - 1, center.z)

/// Path cost of a single turf for the vehicle, -1 if it can't drive there
/datum/vehicle_ai_brain/proc/get_turf_drive_cost(turf/checked_turf)
	if(checked_turf.density || istype(checked_turf, /turf/open/space) || istype(checked_turf, /turf/open_space))
		return -1

	if(blocked_turfs[checked_turf] > world.time)
		return -1

	. = 0
	for(var/atom/movable/thing as anything in checked_turf)
		if(thing == vehicle)
			continue
		if(istype(thing, /obj/structure/blocker/forcefield/vehicles) || istype(thing, /obj/structure/blocker/forcefield/multitile_vehicles))
			if(GLOB.vehicle_blockers && !(vehicle.vehicle_flags & VEHICLE_BYPASS_BLOCKERS))
				return -1
			continue
		if(!thing.density || ismob(thing))
			continue
		if(istype(thing, /obj/vehicle))
			return -1
		// Heavy vehicles barely slow down for it, they only go around for a way that isn't longer
		. += vehicle.ai_crushes_obstacles ? 1 : crush_penalty

/// TRUE if the whole vehicle can drive onto the turfs around the given center
/datum/vehicle_ai_brain/proc/can_occupy(turf/center)
	if(!center)
		return FALSE
	var/list/turf/footprint = get_footprint(center)
	if(!footprint)
		return FALSE
	for(var/turf/footprint_turf as anything in footprint)
		if(get_turf_drive_cost(footprint_turf) < 0)
			return FALSE
	return TRUE

/// Turns the hull in place to face the given cardinal direction
/datum/vehicle_ai_brain/proc/turn_to(direction)
	if(vehicle.dir == direction || world.time < vehicle.next_move)
		return
	if(direction == turn(vehicle.dir, 180))
		vehicle.try_rotate(90)
	else
		vehicle.try_rotate(turning_angle(vehicle.dir, direction))

/// Drives the vehicle towards the goal. Returns VEHICLE_AI_DRIVE_MOVING, VEHICLE_AI_DRIVE_ARRIVED or VEHICLE_AI_DRIVE_FAILED
/datum/vehicle_ai_brain/proc/drive_to(turf/goal, radius = 1)
	var/turf/center = get_turf(vehicle)
	if(!goal || !center || goal.z != center.z)
		return VEHICLE_AI_DRIVE_FAILED

	if(get_dist(center, goal) <= radius)
		clear_path()
		return VEHICLE_AI_DRIVE_ARRIVED

	// The goal is new or has moved too far away from the one we have a path for
	if(!path_goal || get_dist(path_goal, goal) > 2 || (!pathfinder && !path_failed && !length(current_path)))
		if(!COOLDOWN_FINISHED(src, repath_cooldown))
			return VEHICLE_AI_DRIVE_MOVING
		start_path(goal, radius)

	if(pathfinder)
		return VEHICLE_AI_DRIVE_MOVING

	if(path_failed)
		return VEHICLE_AI_DRIVE_FAILED

	// Skip steps we have already made
	while(length(current_path) && current_path[length(current_path)] == center)
		current_path.len--
	if(!length(current_path))
		return VEHICLE_AI_DRIVE_MOVING

	var/turf/next_turf = current_path[length(current_path)]
	// We've somehow deviated from our current path, find a new one
	if(get_dist(center, next_turf) != 1)
		current_path = null
		return VEHICLE_AI_DRIVE_MOVING

	var/direction = get_dir(center, next_turf)
	// Count how far the path goes straight on, to know if reversing is worth it
	var/straight_steps = 1
	for(var/index in length(current_path) - 1 to 1 step -1)
		var/turf/path_turf = current_path[index]
		if(get_dir(current_path[index + 1], path_turf) != direction)
			break
		straight_steps++

	drive_step(direction, straight_steps)
	if(get_turf(vehicle) == next_turf)
		current_path.len--
	return VEHICLE_AI_DRIVE_MOVING

/// Moves or turns the vehicle once in the given cardinal direction, returns TRUE if the vehicle moved or turned
/datum/vehicle_ai_brain/proc/drive_step(direction, straight_steps = 1)
	if(world.time < vehicle.next_move)
		return FALSE

	var/turf/old_loc = vehicle.loc
	var/old_dir = vehicle.dir
	var/turning_around = (direction == turn(vehicle.dir, 180) && straight_steps > max_reverse_steps)
	var/moving = !turning_around && (direction == vehicle.dir || direction == turn(vehicle.dir, 180))
	if(moving && friendly_in_way(direction))
		// Honk and give them a moment, then go around
		if(!friendly_blocked_since)
			friendly_blocked_since = world.time
			ask_to_make_way(direction)
			if(world.time >= vehicle.next_honk)
				vehicle.next_honk = world.time + 10 SECONDS
				vehicle.perform_honk()
				crew_say(move_lines, VEHICLE_DRIVER)
		else if(world.time > friendly_blocked_since + friendly_wait_time)
			friendly_blocked_since = 0
			avoid_turfs_ahead(direction)
			clear_path()
		return FALSE
	friendly_blocked_since = 0

	var/list/turf/turfs_ahead = moving ? get_turfs_ahead(direction) : null
	var/obstacles_ahead = moving ? count_obstacles(turfs_ahead) : 0

	if(turning_around)
		vehicle.try_rotate(90)
	else
		// Moves forwards and backwards, turns otherwise. Async since bumping into some things sleeps
		INVOKE_ASYNC(vehicle, TYPE_PROC_REF(/obj/vehicle/multitile, pre_movement), direction)

	if(vehicle.loc != old_loc || vehicle.dir != old_dir)
		failed_moves = 0
		return TRUE

	// Ramming through something that breaks or folds is progress, only what stays in the way gets us stuck
	if(moving && (count_obstacles(turfs_ahead) < obstacles_ahead))
		failed_moves = 0
		return FALSE

	// Braking fails some moves too, so only give up after several in a row
	failed_moves++
	if(failed_moves >= max_failed_moves)
		failed_moves = 0
		avoid_turfs_ahead(direction)
		clear_path()
	return FALSE

/// Returns the turfs the vehicle would newly cover by moving one step in the given direction
/datum/vehicle_ai_brain/proc/get_turfs_ahead(direction)
	RETURN_TYPE(/list)
	var/turf/center = get_turf(vehicle)
	var/turf/next_center = get_step(center, direction)
	var/list/turf/next_footprint = next_center && get_footprint(next_center)
	if(!next_footprint)
		return list()
	return next_footprint - get_footprint(center)

/// TRUE if a friendly that the vehicle would run over is standing in the way
/datum/vehicle_ai_brain/proc/friendly_in_way(direction)
	for(var/turf/ahead_turf as anything in get_turfs_ahead(direction))
		for(var/mob/living/carbon/possible_friendly in ahead_turf)
			if(possible_friendly.stat != DEAD && faction_check(possible_friendly))
				return TRUE
	return FALSE

/// Counts the walls and dense things other than mobs on the turfs, what the vehicle has to break through
/datum/vehicle_ai_brain/proc/count_obstacles(list/turf/turfs)
	. = 0
	for(var/turf/checked_turf as anything in turfs)
		if(checked_turf.density)
			.++
		for(var/atom/movable/thing as anything in checked_turf)
			if(thing.density && !ismob(thing) && thing != vehicle)
				.++

/// Marks the turfs the vehicle failed to drive into, so the next path goes around them. Only the ones with something in the way, if any have
/datum/vehicle_ai_brain/proc/avoid_turfs_ahead(direction)
	var/list/turf/turfs_ahead = get_turfs_ahead(direction)
	var/list/turf/blocking_turfs = list()
	for(var/turf/ahead_turf as anything in turfs_ahead)
		if(count_obstacles(list(ahead_turf)))
			blocking_turfs += ahead_turf

	for(var/turf/ahead_turf as anything in (length(blocking_turfs) ? blocking_turfs : turfs_ahead))
		blocked_turfs[ahead_turf] = world.time + blocked_turf_time

/// Asks the friendly human AI standing in the way to step aside
/datum/vehicle_ai_brain/proc/ask_to_make_way(direction)
	for(var/turf/ahead_turf as anything in get_turfs_ahead(direction))
		for(var/mob/living/carbon/human/friendly in ahead_turf)
			if(friendly.client || (friendly.stat != CONSCIOUS) || !faction_check(friendly))
				continue
			var/datum/human_ai_brain/friendly_brain = friendly.get_ai_brain()
			var/turf/side_turf = friendly_brain && get_make_way_turf(ahead_turf, direction)
			if(side_turf)
				friendly_brain.make_way(side_turf)

/// Returns a free turf right beside the way the vehicle drives in the direction, for someone standing on the turf to step to
/datum/vehicle_ai_brain/proc/get_make_way_turf(turf/standing_turf, direction)
	var/vertical = (direction == NORTH) || (direction == SOUTH)
	var/low = INFINITY
	var/high = -INFINITY
	for(var/turf/footprint_turf as anything in get_footprint(get_turf(vehicle)))
		var/across = vertical ? footprint_turf.x : footprint_turf.y
		low = min(low, across)
		high = max(high, across)

	// The nearer side first
	var/standing_across = vertical ? standing_turf.x : standing_turf.y
	var/list/sides = ((standing_across - low) <= (high - standing_across)) ? list(low - 1, high + 1) : list(high + 1, low - 1)
	for(var/across in sides)
		for(var/along_shift in list(0, 1, -1))
			var/turf/side_turf = vertical ? locate(across, standing_turf.y + along_shift, standing_turf.z) : locate(standing_turf.x + along_shift, across, standing_turf.z)
			if(side_turf && !is_blocked_turf(side_turf))
				return side_turf

/datum/vehicle_ai_brain/proc/start_path(turf/goal, radius)
	clear_path()
	COOLDOWN_START(src, repath_cooldown, 1 SECONDS)
	path_goal = goal

	// Forget turfs we are done avoiding
	for(var/turf/blocked_turf as anything in blocked_turfs.Copy())
		if(blocked_turfs[blocked_turf] <= world.time)
			blocked_turfs -= blocked_turf

	pathfinder = new(src, get_turf(vehicle), goal, radius, !vehicle.ai_crushes_obstacles)

/datum/vehicle_ai_brain/proc/clear_path()
	QDEL_NULL(pathfinder)
	current_path = null
	path_goal = null
	path_failed = FALSE

/// Called by the pathfinder when it is done, path is null if there is none
/datum/vehicle_ai_brain/proc/set_path(list/turf/path)
	pathfinder = null
	current_path = path
	path_failed = !length(path)

/**
 * A* search for the vehicle's center, spread over several ticks.
 * A center turf can be used if the whole vehicle fits around it.
 */
/datum/vehicle_ai_pathfinder
	/// The brain that receives the path
	var/datum/vehicle_ai_brain/brain
	var/turf/start
	var/turf/goal
	/// The search ends on any turf this close to the goal
	var/goal_radius = 0
	/// Total tiles the search may look at before giving up
	var/max_nodes = 2500
	/// If TRUE, the path may not go through anything the vehicle would have to crush. If there is no such path, a search that may is started
	var/clear_only = FALSE
	/// Total tiles a clear_only search may look at, it gives up sooner since another search follows
	var/clear_only_max_nodes = 1000
	/// Path cost added each time the path turns, since the vehicle has to stop and rotate
	var/turn_penalty = 2
	/// Tiles looked at so far
	var/expanded = 0

	/// Binary min-heap of open turfs, ordered by the matching heap_scores
	var/list/turf/heap_turfs = list()
	var/list/heap_scores = list()
	/// Assoc list of turf : cost of the best path to it
	var/list/g_scores = list()
	/// Assoc list of turf : the turf before it on the best path
	var/list/came_from = list()
	/// Assoc list of turfs that are done
	var/list/closed = list()
	/// Assoc list of center turf : path cost of the vehicle standing there, -1 if it can't
	var/list/center_costs = list()
	/// Assoc list of turf : path cost of that one turf, -1 if the vehicle can't drive on it
	var/list/turf_costs = list()

/datum/vehicle_ai_pathfinder/New(datum/vehicle_ai_brain/brain, turf/start, turf/goal, goal_radius, clear_only = FALSE)
	. = ..()
	src.brain = brain
	src.start = start
	src.clear_only = clear_only
	if(clear_only)
		max_nodes = clear_only_max_nodes
	src.goal = goal
	src.goal_radius = goal_radius

	// Other vehicles cover more turfs than their loc, so mark them all as blocked
	for(var/obj/vehicle/multitile/other_vehicle as anything in GLOB.all_multi_vehicles)
		if(other_vehicle == brain.vehicle || other_vehicle.z != start.z || get_dist(other_vehicle, start) > VEHICLE_AI_MAX_PATHFINDING_RANGE + 3)
			continue
		for(var/turf/vehicle_turf as anything in other_vehicle.locs)
			turf_costs[vehicle_turf] = -1

	g_scores[start] = 0
	heap_push(start, get_heuristic(start))

/datum/vehicle_ai_pathfinder/Destroy(force, ...)
	brain = null
	start = null
	goal = null
	heap_turfs = null
	g_scores = null
	came_from = null
	closed = null
	center_costs = null
	turf_costs = null
	return ..()

/// Looks at up to budget tiles, then sends the path to the brain once it is done
/datum/vehicle_ai_pathfinder/proc/search(budget)
	while(length(heap_turfs))
		if(budget-- <= 0 || TICK_CHECK)
			return

		var/turf/current = heap_pop()
		if(closed[current])
			continue
		closed[current] = TRUE

		if(get_dist(current, goal) <= goal_radius)
			finish(build_path(current))
			return

		if(++expanded > max_nodes)
			break

		var/turf/previous = came_from[current]
		for(var/direction in GLOB.cardinals)
			var/turf/neighbor = get_step(current, direction)
			if(!neighbor || closed[neighbor] || get_dist(neighbor, start) > VEHICLE_AI_MAX_PATHFINDING_RANGE)
				continue

			var/cost = get_center_cost(neighbor)
			if(cost < 0)
				continue

			var/new_g_score = g_scores[current] + 1 + cost
			if(previous && get_dir(previous, current) != direction)
				new_g_score += turn_penalty

			var/old_g_score = g_scores[neighbor]
			if(!isnull(old_g_score) && new_g_score >= old_g_score)
				continue

			g_scores[neighbor] = new_g_score
			came_from[neighbor] = current
			heap_push(neighbor, new_g_score + get_heuristic(neighbor))

	finish(null)

/datum/vehicle_ai_pathfinder/proc/finish(list/turf/path)
	var/datum/vehicle_ai_brain/owner = brain
	// No way around, crush through
	if(!path && clear_only)
		owner.pathfinder = new /datum/vehicle_ai_pathfinder(owner, start, goal, goal_radius, FALSE)
		qdel(src)
		return

	qdel(src)
	owner.set_path(path)

/datum/vehicle_ai_pathfinder/proc/build_path(turf/end)
	var/list/turf/path = list()
	var/turf/node = end
	while(node && node != start)
		path += node
		node = came_from[node]
	return path

/datum/vehicle_ai_pathfinder/proc/get_heuristic(turf/checked_turf)
	return abs(checked_turf.x - goal.x) + abs(checked_turf.y - goal.y)

/datum/vehicle_ai_pathfinder/proc/get_center_cost(turf/center)
	var/cached_cost = center_costs[center]
	if(!isnull(cached_cost))
		return cached_cost

	var/list/turf/footprint = brain.get_footprint(center)
	. = footprint ? 0 : -1
	for(var/turf/footprint_turf as anything in footprint)
		var/turf_cost = turf_costs[footprint_turf]
		if(isnull(turf_cost))
			turf_cost = brain.get_turf_drive_cost(footprint_turf)
			turf_costs[footprint_turf] = turf_cost
		if((turf_cost < 0) || (clear_only && turf_cost > 0))
			. = -1
			break
		. += turf_cost

	center_costs[center] = .

/datum/vehicle_ai_pathfinder/proc/heap_push(turf/new_turf, score)
	heap_turfs += new_turf
	heap_scores += score
	var/index = length(heap_turfs)
	while(index > 1)
		var/parent = floor(index / 2)
		if(heap_scores[parent] <= heap_scores[index])
			break
		heap_turfs.Swap(index, parent)
		heap_scores.Swap(index, parent)
		index = parent

/datum/vehicle_ai_pathfinder/proc/heap_pop()
	var/turf/top = heap_turfs[1]
	var/last = length(heap_turfs)
	heap_turfs[1] = heap_turfs[last]
	heap_scores[1] = heap_scores[last]
	heap_turfs.len--
	heap_scores.len--

	var/count = last - 1
	var/index = 1
	while(TRUE)
		var/left = index * 2
		var/right = left + 1
		var/smallest = index
		if(left <= count && heap_scores[left] < heap_scores[smallest])
			smallest = left
		if(right <= count && heap_scores[right] < heap_scores[smallest])
			smallest = right
		if(smallest == index)
			break
		heap_turfs.Swap(index, smallest)
		heap_scores.Swap(index, smallest)
		index = smallest
	return top
