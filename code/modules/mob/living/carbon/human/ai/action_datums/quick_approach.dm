/// How long the AI keeps failing to find a way to the ordered turf before it gives up on it
#define QUICK_APPROACH_GIVE_UP_TIME (5 SECONDS)

/datum/ai_action/quick_approach
	name = "Quick Approach"
	action_flags = ACTION_USING_LEGS
	/// When the AI last made its way towards the turf
	var/last_progress_time

/datum/ai_action/quick_approach/get_weight(datum/human_ai_brain/brain)
	if(!brain.quick_approach)
		return 0

	if(brain.hold_position)
		return 0

	return INFINITY

/datum/ai_action/quick_approach/Added()
	last_progress_time = world.time

/datum/ai_action/quick_approach/Destroy(force, ...)
	brain.quick_approach = null
	return ..()

/datum/ai_action/quick_approach/trigger_action()
	. = ..()

	var/turf/approach_turf = brain.quick_approach
	if(QDELETED(approach_turf))
		return ONGOING_ACTION_COMPLETED

	var/mob/tied_human = brain.tied_human
	if(get_dist(approach_turf, tied_human) > 0)
		if(!brain.move_to_next_turf(approach_turf))
			// Unreachable, don't stand here forever
			if(world.time > last_progress_time + QUICK_APPROACH_GIVE_UP_TIME)
				return ONGOING_ACTION_COMPLETED
			return ONGOING_ACTION_UNFINISHED

		last_progress_time = world.time
		if(get_dist(approach_turf, tied_human) > 0)
			return ONGOING_ACTION_UNFINISHED

	return ONGOING_ACTION_COMPLETED

#undef QUICK_APPROACH_GIVE_UP_TIME
