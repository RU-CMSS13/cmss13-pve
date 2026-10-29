/// trans_to_ingest() puts a swallowed pill's reagents into the blood 9.5 seconds later, over half a second
#define PILL_ABSORPTION_TIME (10.5 SECONDS)

/datum/human_ai_brain
	/// What items the AI considers when trying to heal brute damage, besides medicine with brute_heal_reagents
	var/static/list/brute_heal_items = list(
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/tool/weldingtool,
		/obj/item/stack/nanopaste,
	)

	/// What items the AI considers when trying to heal burn damage, besides medicine with burn_heal_reagents
	var/static/list/burn_heal_items = list(
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/stack/medical/ointment,
		/obj/item/stack/cable_coil,
		/obj/item/stack/nanopaste,
	)

	/// What items the AI considers when trying to fix bleeding
	var/static/list/bleed_heal_items = list(
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/bruise_pack,
	)

	/// What items the AI considers when trying to fix bonebreaks
	var/static/list/bonebreak_heal_items = list(
		/obj/item/stack/medical/splint,
	)

	/// Medicine treating everything at once that is spent after one use, saved for when the AI is about to go down
	var/static/list/emergency_heal_items = list(
		/obj/item/reagent_container/hypospray/autoinjector/emergency,
	)

	/// Reagents the AI looks for in its pills, injectors and hyposprays when trying to heal brute damage
	var/static/list/brute_heal_reagents = list(
		"bicaridine",
		"meralyne",
		"tricordrazine",
	)

	/// Reagents the AI looks for in its medicine when trying to heal burn damage
	var/static/list/burn_heal_reagents = list(
		"kelotane",
		"dermaline",
		"tricordrazine",
	)

	/// Reagents the AI looks for in its medicine when trying to heal toxin damage
	var/static/list/tox_heal_reagents = list(
		"anti_toxin",
		"tricordrazine",
	)

	/// Reagents the AI looks for in its medicine when trying to heal oxygen damage
	var/static/list/oxy_heal_reagents = list(
		"dexalin",
		"dexalinp",
		"tricordrazine",
	)

	/// Reagents the AI looks for in its medicine when trying to reduce pain. Painkillers don't stack, so only one is taken at a time
	var/static/list/painkiller_reagents = list(
		"tramadol",
		"oxycodone",
		"paracetamol",
	)

	/// At what percentage of max HP to start searching for medical treatment
	var/healing_start_threshold = 0.7
	/// At what percentage of max HP to use emergency_heal_items
	var/emergency_heal_threshold = 0.4
	/// Requires this much damage of one type to consider it a problem
	var/damage_problem_threshold = 5
	/// Pain percentage (out of 100) for the AI to consider using painkillers
	var/pain_percentage_threshold = 1

	/// Are we currently treating someone?
	var/healing_someone = FALSE

	/// Reference for found injured ally
	var/mob/living/carbon/human/found_injured_ally

	/// Reagents of the pills the AI has fed that have not reached the blood yet, as list(mob ref = list(reagent id = amount))
	var/list/pending_ingested_reagents = list()

	/// How long the AI waits before looking for treatment again when nothing it carries helps
	var/treatment_search_delay = 5 SECONDS
	COOLDOWN_DECLARE(treatment_search_cooldown)

/datum/human_ai_brain/proc/set_injured_ally(mob/living/new_target)
	if(!new_target)
		return

	RegisterSignal(new_target, COMSIG_PARENT_QDELETING, PROC_REF(lose_injured_ally), TRUE)
	RegisterSignal(new_target, COMSIG_MOB_DEATH, PROC_REF(lose_injured_ally), TRUE)
	found_injured_ally = new_target

/datum/human_ai_brain/proc/lose_injured_ally()
	if(found_injured_ally)
		UnregisterSignal(found_injured_ally, COMSIG_PARENT_QDELETING)
		UnregisterSignal(found_injured_ally, COMSIG_MOB_DEATH)
		var/patient_ref = REF(found_injured_ally)
		if(patient_medics[patient_ref] == src)
			patient_medics -= patient_ref
	found_injured_ally = null

/// Returns the most hurt ally in sight that we can treat
/datum/human_ai_brain/proc/get_injured_ally()
	RETURN_TYPE(/mob/living/carbon/human)
	var/lowest_health = INFINITY
	for(var/mob/living/carbon/human/possible_patient in view(view_distance, tied_human))
		if(!can_treat_patient(possible_patient))
			continue

		var/health_ratio = possible_patient.health / possible_patient.maxHealth
		if(health_ratio < lowest_health)
			lowest_health = health_ratio
			. = possible_patient

/// Returns TRUE if the fight is over and we carry something that patches us up
/datum/human_ai_brain/proc/wants_treatment()
	if(in_combat || current_target || !length(equipment_map[HUMAN_AI_HEALTHITEMS]) || !COOLDOWN_FINISHED(src, treatment_search_cooldown))
		return FALSE

	return healing_start_check(tied_human) && find_treatment(tied_human)

/datum/human_ai_brain/proc/healing_start_check(mob/living/carbon/human/target)
	return ((target.health / target.maxHealth) <= healing_start_threshold) || target.is_bleeding() || has_unsplinted_fracture(target)

/// Returns TRUE if the target has a broken limb that a splint can still help
/datum/human_ai_brain/proc/has_unsplinted_fracture(mob/living/carbon/human/target)
	for(var/obj/limb/limb as anything in target.limbs)
		if((limb.status & LIMB_BROKEN) && !(limb.status & (LIMB_SPLINTED|LIMB_DESTROYED|LIMB_ROBOT|LIMB_SYNTHSKIN)))
			return TRUE
	return FALSE

/// Returns the item the AI should use next on the target, or null if nothing it carries helps right now
/datum/human_ai_brain/proc/find_treatment(mob/living/carbon/human/target)
	RETURN_TYPE(/obj/item)

	if((target.health / target.maxHealth) <= emergency_heal_threshold)
		. = find_heal_item(target, emergency_heal_items, emergency = TRUE)
		if(.)
			return

	// Prioritize bleeding, then brute, then broken bones, then burn, then tox, then oxy, then pain.
	if(target.is_bleeding())
		. = find_heal_item(target, bleed_heal_items)
		if(.)
			return

	if(target.getBruteLoss() > damage_problem_threshold)
		. = find_heal_item(target, brute_heal_items, brute_heal_reagents)
		if(.)
			return

	// Doesn't support bone-healing chems
	if(has_unsplinted_fracture(target))
		. = find_heal_item(target, bonebreak_heal_items)
		if(.)
			return

	if(target.getFireLoss() > damage_problem_threshold)
		. = find_heal_item(target, burn_heal_items, burn_heal_reagents)
		if(.)
			return

	if(target.getToxLoss() > damage_problem_threshold)
		. = find_heal_item(target, null, tox_heal_reagents)
		if(.)
			return

	if(target.getOxyLoss() > damage_problem_threshold)
		. = find_heal_item(target, null, oxy_heal_reagents)
		if(.)
			return

	if(target.pain?.get_pain_percentage() > pain_percentage_threshold)
		return find_heal_item(target, null, painkiller_reagents)

/// Returns a usable medical item of one of item_types, or medicine containing one of reagent_ids
/datum/human_ai_brain/proc/find_heal_item(mob/living/carbon/human/target, list/item_types, list/reagent_ids, emergency = FALSE)
	RETURN_TYPE(/obj/item)

	for(var/obj/item/heal_item as anything in equipment_map[HUMAN_AI_HEALTHITEMS])
		if(!emergency && is_type_in_list(heal_item, emergency_heal_items))
			continue

		if(!is_type_in_list(heal_item, item_types) && !(reagent_ids && medicine_has_reagent(heal_item, reagent_ids)))
			continue

		if(heal_item.ai_can_use(tied_human, src, target))
			return heal_item

/// Returns TRUE if the pill bottle, injector or hypospray holds any of the reagents
/datum/human_ai_brain/proc/medicine_has_reagent(obj/item/medicine, list/reagent_ids)
	var/datum/reagents/medicine_reagents = medicine.reagents
	if(istype(medicine, /obj/item/storage/pill_bottle))
		var/obj/item/reagent_container/pill/pill = locate() in medicine
		medicine_reagents = pill?.reagents

	if(!medicine_reagents)
		return FALSE

	for(var/datum/reagent/reagent as anything in medicine_reagents.reagent_list)
		if(reagent.id in reagent_ids)
			return TRUE

	return FALSE

/// Returns how much of the reagent is in the target's blood, counting pills we fed it that are still being absorbed
/datum/human_ai_brain/proc/get_active_reagent_amount(mob/living/carbon/human/target, reagent_id)
	. = target.reagents?.get_reagent_amount(reagent_id)
	var/list/pending = pending_ingested_reagents[REF(target)]
	if(pending)
		. += pending[reagent_id]

/**
 * Returns TRUE if giving the target amount units of the dose is safe
 *
 * The dose must not push any of its reagents over its overdose threshold. Unless stack_doses is set, it also must not be
 * given while an earlier dose of the same reagent is still working, or alongside another painkiller, as those don't stack.
 * More units of a reagent only make it work for longer, so the next dose waits until a third of the last one is left.
 */
/datum/human_ai_brain/proc/is_safe_dose(mob/living/carbon/human/target, datum/reagents/dose, amount = dose?.total_volume, stack_doses = FALSE)
	if(!target.reagents || !dose?.total_volume || (amount <= 0))
		return FALSE

	var/dose_share = min(amount / dose.total_volume, 1)
	for(var/datum/reagent/reagent as anything in dose.reagent_list)
		var/dose_amount = reagent.volume * dose_share
		var/active_amount = get_active_reagent_amount(target, reagent.id)
		if(reagent.overdose && ((active_amount + dose_amount) > reagent.overdose))
			return FALSE

		if(stack_doses)
			continue

		if(active_amount >= dose_amount / 3)
			return FALSE

		if(reagent.id in painkiller_reagents)
			for(var/painkiller in painkiller_reagents - reagent.id)
				if(get_active_reagent_amount(target, painkiller) > 0)
					return FALSE

	return TRUE

/// Remembers the reagents of a pill fed to the target until they reach its blood, so that another pill can't overdose it meanwhile
/datum/human_ai_brain/proc/add_pending_reagents(mob/living/carbon/human/target, list/reagent_amounts)
	var/target_ref = REF(target)
	var/list/pending = pending_ingested_reagents[target_ref]
	if(!pending)
		pending = list()
		pending_ingested_reagents[target_ref] = pending

	for(var/reagent_id in reagent_amounts)
		pending[reagent_id] += reagent_amounts[reagent_id]

	addtimer(CALLBACK(src, PROC_REF(remove_pending_reagents), target_ref, reagent_amounts), PILL_ABSORPTION_TIME)

/datum/human_ai_brain/proc/remove_pending_reagents(target_ref, list/reagent_amounts)
	var/list/pending = pending_ingested_reagents[target_ref]
	if(!pending)
		return

	for(var/reagent_id in reagent_amounts)
		pending[reagent_id] -= reagent_amounts[reagent_id]
		if(pending[reagent_id] <= 0)
			pending -= reagent_id

	if(!length(pending))
		pending_ingested_reagents -= target_ref

/// Takes the item out of our gear, uses it on the target and puts it back
/datum/human_ai_brain/proc/apply_treatment(mob/living/carbon/human/target, obj/item/heal_item)
	set waitfor = FALSE

	healing_someone = TRUE
	clear_main_hand()
	if(!equip_item_from_equipment_map(HUMAN_AI_HEALTHITEMS, heal_item))
		healing_someone = FALSE
		return

	sleep(short_action_delay * action_delay_mult)
	if(QDELETED(tied_human))
		return

	if(!QDELETED(heal_item) && tied_human.is_holding(heal_item))
		heal_item.ai_use(tied_human, src, target)
#if defined(TESTING) || defined(HUMAN_AI_TESTING)
		to_chat(world, "[tied_human.name] treated [target.name] using [heal_item].")
#endif

	if(QDELETED(tied_human))
		return

	if(!QDELETED(heal_item) && tied_human.is_holding(heal_item))
		if(heal_item.ai_is_spent() || !store_item(heal_item, storage_has_room(heal_item), HUMAN_AI_HEALTHITEMS))
			tied_human.drop_held_item(heal_item)

	healing_someone = FALSE

#undef PILL_ABSORPTION_TIME
