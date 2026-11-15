/datum/human_ai_brain
	/// A turf to step to so a friendly vehicle can pass
	var/turf/make_way_turf
	/// world.time after which the AI stops trying to reach make_way_turf
	var/make_way_until = 0

/// Has the AI step aside to the turf, out of the way of a friendly vehicle
/datum/human_ai_brain/proc/make_way(turf/side_turf)
	make_way_turf = side_turf
	make_way_until = world.time + 5 SECONDS

/datum/ai_action/make_way
	name = "Make Way"
	action_flags = ACTION_USING_LEGS
	preempts_actions = TRUE

/datum/ai_action/make_way/get_weight(datum/human_ai_brain/brain)
	if(!brain.make_way_turf || (world.time > brain.make_way_until))
		return 0

	// The vehicle goes around a manned gun
	if(brain.tied_human.buckled || brain.is_manning_gun())
		return 0

	return 30

/datum/ai_action/make_way/Destroy(force, ...)
	brain?.make_way_turf = null
	return ..()

/datum/ai_action/make_way/trigger_action()
	. = ..()

	var/turf/side_turf = brain.make_way_turf
	if(!side_turf || (world.time > brain.make_way_until) || (get_turf(brain.tied_human) == side_turf))
		return ONGOING_ACTION_COMPLETED

	if(!brain.move_to_next_turf(side_turf))
		return ONGOING_ACTION_COMPLETED

	return ONGOING_ACTION_UNFINISHED
