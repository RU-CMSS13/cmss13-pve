/datum/human_ai_brain
	/// How long the AI waits after throwing a grenade before it may throw another
	var/grenade_throw_delay = 10 SECONDS
	COOLDOWN_DECLARE(grenade_throw_cooldown)

/// Returns TRUE if a grenade thrown at the turf would land there without hurting friendlies
/datum/human_ai_brain/proc/can_throw_grenade_at(turf/target_turf, obj/item/explosive/grenade/grenade)
	var/distance = get_dist(tied_human, target_turf)
	if(distance <= 2) // basic precautions
		return FALSE

	if(distance > min(view_distance, grenade?.throw_range || 7))
		return FALSE

	for(var/turf/line_turf as anything in get_line(tied_human, target_turf, include_start_atom = FALSE))
		if(line_turf.density)
			return FALSE

		// Cover right in front of the target only makes the grenade land next to it
		if(get_dist(line_turf, target_turf) <= 1)
			continue

		for(var/atom/movable/blocker as anything in line_turf)
			if(ishuman(blocker))
				var/mob/living/carbon/human/human_blocker = blocker
				if((human_blocker.body_position == STANDING_UP) && faction_check(human_blocker))
					return FALSE
				continue

			if(blocker.density && !(blocker.pass_flags?.flags_can_pass_all & PASS_OVER_THROW_ITEM))
				return FALSE

	for(var/mob/living/carbon/human/nearby_human in range(2, target_turf))
		if((nearby_human.stat != DEAD) && faction_check(nearby_human))
			return FALSE

	return TRUE

/datum/ai_action/throw_grenade
	name = "Throw Grenade"
	action_flags = ACTION_USING_HANDS
	var/obj/item/explosive/grenade/throwing
	var/mid_throw

/datum/ai_action/throw_grenade/get_weight(datum/human_ai_brain/brain)
	if(!brain.grenading_allowed)
		return 0

	if(!brain.in_combat)
		return 0

	if(!COOLDOWN_FINISHED(brain, grenade_throw_cooldown))
		return 0

	var/turf/target_turf = brain.target_turf
	if(!target_turf)
		return 0

	var/obj/item/explosive/grenade/grenade = locate() in brain.equipment_map[HUMAN_AI_GRENADES]
	if(!grenade)
		return 0

	// Grenades are for enemies we can't shoot, be it for lack of a gun or because they hid
	if(brain.primary_weapon && brain.current_target)
		var/datum/ai_action/fire_at_target/fire_action = GLOB.AI_actions[/datum/ai_action/fire_at_target]
		if(fire_action.firing_line_check(brain, brain.current_target))
			return 0

	if(!brain.can_throw_grenade_at(target_turf, grenade))
		return 0

	return 11

/datum/ai_action/throw_grenade/get_conflicts(datum/human_ai_brain/brain)
	. = ..()
	. += /datum/ai_action/chase_target
	. += /datum/ai_action/sniper_nest

/datum/ai_action/throw_grenade/Added()
	throwing = locate() in brain.equipment_map[HUMAN_AI_GRENADES]

/datum/ai_action/throw_grenade/Destroy(force, ...)
	throwing = null
	return ..()

/datum/ai_action/throw_grenade/trigger_action()
	. = ..()

	var/mob/living/carbon/human/tied_human = brain.tied_human
	if(mid_throw)
		// ai_use() is done once the grenade leaves our hand, one way or another
		if(QDELETED(throwing) || (throwing.loc != tied_human))
			return ONGOING_ACTION_COMPLETED
		return ONGOING_ACTION_UNFINISHED

	var/turf/target_turf = brain.target_turf
	if(QDELETED(throwing) || !target_turf || !brain.can_throw_grenade_at(target_turf, throwing))
		return ONGOING_ACTION_COMPLETED

	if(brain.primary_weapon)
		brain.primary_weapon.unwield(tied_human)
		if(tied_human.get_active_hand() == brain.primary_weapon)
			tied_human.swap_hand()

	if(!brain.equip_item_from_equipment_map(HUMAN_AI_GRENADES, throwing))
		return ONGOING_ACTION_COMPLETED

	// below code is disabled because it leads to a lot of grenade FF and grenade walltosses.
	// The below code is better for making AI realistic, but shouldn't be uncommented until it's fixed.
	// Until then, we're using can_throw_grenade_at() where AI perfectly throw their nades.
	/*turf_loop:
		for(var/turf/turf in shuffle(RANGE_TURFS(2, target_turf)))
			var/distance = get_dist(tied_human, turf)
			if(distance <= 2) // basic precautions
				continue

			if(distance > brain.view_distance)
				continue

			var/list/turf_line = get_line(tied_human, turf)

			for(var/turf/turf2 as anything in turf_line)
				if(turf2.density)
					continue turf_loop

				for(var/obj/object in turf2)
					if(object.density)
						continue turf_loop

			throw_target = turf
			break*/

	mid_throw = TRUE
	COOLDOWN_START(brain, grenade_throw_cooldown, brain.grenade_throw_delay)
	tied_human.face_atom(target_turf)
	INVOKE_ASYNC(throwing, TYPE_PROC_REF(/obj/item, ai_use), tied_human, brain, target_turf)
	return ONGOING_ACTION_UNFINISHED
