/datum/ai_action/select_primary
	name = "Select Primary"
	action_flags = ACTION_USING_HANDS

/datum/ai_action/select_primary/get_weight(datum/human_ai_brain/brain)
	if(!length(brain.secondary_weapons))
		return 0

	if(!brain.tried_reload && brain.primary_weapon)
		return 0

	if(brain.primary_weapon?.ai_can_use(brain.tied_human, brain))
		return 0

	return 12

/datum/ai_action/select_primary/trigger_action()
	. = ..()
	UNLINT(decide_primary_weapon())
	return ONGOING_ACTION_COMPLETED

/datum/ai_action/select_primary/proc/decide_primary_weapon()
	var/mob/living/carbon/human/tied_human = brain.tied_human

	var/obj/item/weapon/gun/best_secondary
	var/datum/firearm_appraisal/best_secondary_appraisal
	for(var/obj/item/weapon/gun/secondary as anything in brain.secondary_weapons)
		// Lost or taken from us, so it can't be drawn
		if(!brain.is_in_inventory(secondary))
			brain.remove_secondary_weapon(secondary)
			continue

		if(!secondary.ai_can_use(tied_human, brain))
			continue

		if(!best_secondary)
			best_secondary = secondary
			best_secondary_appraisal = get_firearm_appraisal(best_secondary)
			continue

		var/datum/firearm_appraisal/this_appraisal = get_firearm_appraisal(secondary)
		if(this_appraisal.primary_weight > best_secondary_appraisal.primary_weight)
			best_secondary = secondary
			best_secondary_appraisal = this_appraisal
			continue

	if(!best_secondary)
		return

	var/obj/item/weapon/gun/primary_weapon = brain.primary_weapon
	if(primary_weapon && brain.tied_human.is_holding(primary_weapon))
		primary_weapon.unwield(tied_human)
		brain.holster_primary()

	brain.remove_secondary_weapon(best_secondary)
	brain.set_primary_weapon(best_secondary)
	if(primary_weapon && brain.is_in_inventory(primary_weapon))
		brain.add_secondary_weapon(primary_weapon)
	brain.tried_reload = FALSE
	return best_secondary
