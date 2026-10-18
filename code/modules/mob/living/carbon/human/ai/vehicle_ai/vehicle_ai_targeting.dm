/datum/vehicle_ai_brain
	/// Distance for view checks
	var/view_distance = 9
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

	COOLDOWN_DECLARE(target_scan)

/// Drops a target that can't be seen or fought anymore, then looks for a new one
/datum/vehicle_ai_brain/proc/scan_targets()
	var/turf/center = get_turf(vehicle)
	if(!center)
		return

	var/list/seen = view(view_distance, center)
	if(current_target && (!(current_target in seen) || !is_valid_target(current_target, center)))
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

		var/score = get_dist(center, thing)
		// Armor and emplacements are the bigger threat
		if(istype(thing, /obj/vehicle/multitile) || isdefenses(thing))
			score -= 3
		if(score < best_score)
			best_target = thing
			best_score = score

	if(best_target)
		set_target(best_target)

/datum/vehicle_ai_brain/proc/is_valid_target(atom/movable/target, turf/center)
	if(QDELETED(target) || target == vehicle)
		return FALSE

	if(get_dist(center, target) > view_distance)
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
