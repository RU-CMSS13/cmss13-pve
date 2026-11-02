/datum/ai_action/treat_self
	name = "Treat Self"
	action_flags = ACTION_USING_HANDS

/datum/ai_action/treat_self/get_weight(datum/human_ai_brain/brain)
	if(iszombie(brain.tied_human))
		return 0

	if(brain.healing_someone)
		return 0

	var/should_fire_offscreen = (brain.target_turf && !COOLDOWN_FINISHED(brain, fire_offscreen))
	if(brain.current_target || should_fire_offscreen)
		return 0

	if(length(brain.to_pickup))
		return 0

	if(!length(brain.equipment_map[HUMAN_AI_HEALTHITEMS]))
		return 0

	if(!COOLDOWN_FINISHED(brain, treatment_search_cooldown))
		return 0

	if(!brain.healing_start_check(brain.tied_human))
		return 0

	return 4

/datum/ai_action/treat_self/trigger_action()
	. = ..()

	// Finish what we started first, the item is already in our hand
	if(brain.healing_someone)
		return ONGOING_ACTION_UNFINISHED

	if(brain.current_target)
		return ONGOING_ACTION_COMPLETED

	var/mob/living/carbon/human/tied_human = brain.tied_human
	if(tied_human.on_fire)
		return ONGOING_ACTION_COMPLETED

	if(!brain.healing_start_check(tied_human))
		return ONGOING_ACTION_COMPLETED

	var/obj/item/treatment = brain.find_treatment(tied_human)
	if(!treatment)
		// Nothing we carry helps right now, so don't look through it every tick
		COOLDOWN_START(brain, treatment_search_cooldown, brain.treatment_search_delay)
		return ONGOING_ACTION_COMPLETED

	brain.apply_treatment(tied_human, treatment)
	return ONGOING_ACTION_UNFINISHED
