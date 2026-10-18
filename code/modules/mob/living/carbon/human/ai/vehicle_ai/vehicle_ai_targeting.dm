/datum/vehicle_ai_brain
	/// Distance for view checks
	var/view_distance = 9
	/// Vehicles are big and loud, so they are made out this far with a clear line of sight
	var/vehicle_spot_distance = 10
	/// A vehicle we fight is followed with the guns this far, as long as there is a clear line of sight to it
	var/vehicle_engage_distance = 14
	/// If FALSE, targets further than dark_vision_range away are only seen when they stand in light
	var/has_nightvision = FALSE
	/// How far the AI sees targets standing in the dark
	var/dark_vision_range = 2
	/// At how far out the AI can see cloaked enemies
	var/cloak_visible_range = 3
	/// How often the AI looks for new targets
	var/target_scan_delay = 1 SECONDS
	/// Ref to the currently focused (and shooting at) target
	var/atom/movable/current_target
	/// Last turf our target was seen at
	var/turf/target_turf
	/// What the AI was ordered to fire at, an atom or a turf, until ordered_fire_until
	var/atom/ordered_fire_target
	/// world.time when the order to fire at ordered_fire_target runs out
	var/ordered_fire_until = 0

	COOLDOWN_DECLARE(target_scan)

/// Drops a target that can't be seen or fought anymore, then looks for a new one
/datum/vehicle_ai_brain/proc/scan_targets()
	var/turf/center = get_turf(vehicle)
	if(!center)
		return

	var/list/seen = view(view_distance, center)
	if(current_target && (!can_see_target(current_target, center, seen, TRUE) || !is_valid_target(current_target, center)))
		if(is_target_destroyed(current_target))
			crew_say(kill_lines, VEHICLE_GUNNER, important = TRUE)
		lose_target()

	if(current_target)
		target_turf = get_turf(current_target)
		return

	var/atom/movable/best_target
	var/best_score = INFINITY
	for(var/atom/movable/thing in seen)
		if(!is_valid_target(thing, center))
			continue

		var/score = get_target_score(thing, center)
		if(score < best_score)
			best_target = thing
			best_score = score

	// Vehicles past the view distance
	for(var/obj/vehicle/multitile/other_vehicle as anything in GLOB.all_multi_vehicles)
		if(other_vehicle.z != center.z || (other_vehicle in seen) || get_dist(center, other_vehicle) > vehicle_spot_distance)
			continue
		if(!is_valid_target(other_vehicle, center) || !has_line_of_sight(other_vehicle))
			continue

		var/score = get_target_score(other_vehicle, center)
		if(score < best_score)
			best_target = other_vehicle
			best_score = score

	if(best_target)
		set_target(best_target)

/// Lower is a better target
/datum/vehicle_ai_brain/proc/get_target_score(atom/movable/target, turf/center)
	. = get_dist(center, target)
	// Armor and emplacements are the bigger threat
	if(istype(target, /obj/vehicle/multitile) || isdefenses(target))
		. -= 3

/**
 * TRUE if the target can be seen from the center. Vehicles stand out further than view_distance,
 * and once fought they are followed up to vehicle_engage_distance. seen is view(view_distance, center) if already at hand
 */
/datum/vehicle_ai_brain/proc/can_see_target(atom/movable/target, turf/center, list/seen, fighting = FALSE)
	if(istype(target, /obj/vehicle/multitile))
		var/distance = get_dist(center, target)
		if(distance <= view_distance && seen)
			return (target in seen)
		return (distance <= (fighting ? vehicle_engage_distance : vehicle_spot_distance)) && has_line_of_sight(target)

	if(!seen)
		seen = view(view_distance, center)
	return (target in seen)

/// Has the AI fire everything at the target for a while instead of anything it sees, a turf is fired at too
/datum/vehicle_ai_brain/proc/order_fire_at(atom/target, duration)
	clear_fire_order()
	ordered_fire_target = target
	ordered_fire_until = world.time + duration
	if(!isturf(target))
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(clear_fire_order))

/datum/vehicle_ai_brain/proc/clear_fire_order()
	SIGNAL_HANDLER
	if(ordered_fire_target && !isturf(ordered_fire_target))
		UnregisterSignal(ordered_fire_target, COMSIG_PARENT_QDELETING)
	ordered_fire_target = null

/// Returns what the AI is ordered to fire at, null once the order ran out or the target is destroyed
/datum/vehicle_ai_brain/proc/get_ordered_fire_target()
	if(!ordered_fire_target)
		return

	if((world.time > ordered_fire_until) || (!isturf(ordered_fire_target) && is_target_destroyed(ordered_fire_target)))
		clear_fire_order()
		return

	return ordered_fire_target

/// Returns what the guns should point at: what they were ordered at, the target, or where the enemy was last seen or shot from while in combat
/datum/vehicle_ai_brain/proc/get_aim_target()
	var/atom/ordered_target = get_ordered_fire_target()
	if(ordered_target)
		return ordered_target
	if(current_target)
		return current_target
	if(in_combat && target_turf && (target_turf.z == vehicle.z))
		return target_turf

/// How far the guns may reach out for the target
/datum/vehicle_ai_brain/proc/get_engage_distance(atom/target)
	return istype(target, /obj/vehicle/multitile) ? vehicle_engage_distance : view_distance

/datum/vehicle_ai_brain/proc/is_valid_target(atom/movable/target, turf/center)
	if(QDELETED(target) || target == vehicle)
		return FALSE

	if(get_dist(center, target) > get_engage_distance(target))
		return FALSE

	if(iscarbon(target))
		return can_target_mob(target, center)

	if(istype(target, /obj/vehicle/multitile))
		var/obj/vehicle/multitile/vehicle_target = target
		return vehicle_target.ai_is_threat() && !faction_check(vehicle_target)

	if(isdefenses(target))
		var/obj/structure/machinery/defenses/defense_target = target
		return defense_target.turned_on && !faction_check(defense_target)

	return FALSE

/datum/vehicle_ai_brain/proc/can_target_mob(mob/living/carbon/target, turf/center)
	if(target.stat == DEAD)
		return FALSE

	var/datum/human_ai_faction/faction_data = get_faction_data()
	if(faction_data && !faction_data.get_shoot_to_kill() && (target.stat == UNCONSCIOUS || (locate(/datum/effects/crit) in target.effects_list)))
		return FALSE

	if(faction_check(target))
		return FALSE

	if(HAS_TRAIT(target, TRAIT_ABILITY_BURROWED))
		return FALSE

	var/distance = get_dist(center, target)
	if(HAS_TRAIT(target, TRAIT_CLOAKED) && distance > cloak_visible_range)
		return FALSE

	if(!has_nightvision && distance > dark_vision_range)
		for(var/turf/open/nearby_turf in range(1, target))
			if(nearby_turf.luminosity || (nearby_turf.dynamic_lumcount >= 1))
				return TRUE
		return FALSE

	return TRUE

/datum/vehicle_ai_brain/proc/set_target(atom/movable/new_target)
	if(!new_target)
		return

	if(current_target)
		lose_target()
	RegisterSignal(new_target, COMSIG_PARENT_QDELETING, PROC_REF(on_target_delete))
	current_target = new_target
	target_turf = get_turf(current_target)

/datum/vehicle_ai_brain/proc/lose_target()
	if(current_target)
		UnregisterSignal(current_target, COMSIG_PARENT_QDELETING)
	current_target = null

/datum/vehicle_ai_brain/proc/on_target_delete(datum/source, force)
	SIGNAL_HANDLER
	// Usually gibbed by our own shells
	crew_say(kill_lines, VEHICLE_GUNNER, important = TRUE)
	lose_target()

/// TRUE if nothing solid stands between the vehicle and the target
/datum/vehicle_ai_brain/proc/has_line_of_sight(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return FALSE
	for(var/turf/line_turf as anything in get_line(get_turf(vehicle), target_turf))
		if(line_turf.opacity)
			return FALSE
		for(var/obj/structure/thing in line_turf)
			if(thing.opacity)
				return FALSE
	return TRUE

/// Rounds the direction from the vehicle to the target to a cardinal
/datum/vehicle_ai_brain/proc/get_cardinal_dir_to(atom/target)
	var/angle = Get_Angle(get_turf(vehicle), get_turf(target))
	switch(round(angle / 90, 1) % 4)
		if(0)
			return NORTH
		if(1)
			return EAST
		if(2)
			return SOUTH
	return WEST
