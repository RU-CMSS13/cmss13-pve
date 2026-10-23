/datum/human_ai_brain
	/// How often a medic looks around for wounded allies
	var/patient_search_delay = 2 SECONDS
	/// How long a medic leaves an ally alone after treating them or giving up on them
	var/patient_rest_delay = 15 SECONDS
	/// Assoc list of ally ref = world.time from which a medic may treat them again
	var/list/patient_rest_times = list()
	COOLDOWN_DECLARE(patient_search_cooldown)

/// Returns the health analyzer that makes us a medic, if we carry one
/datum/human_ai_brain/proc/get_medical_scanner()
	RETURN_TYPE(/obj/item/device/healthanalyzer)
	for(var/obj/item/device/healthanalyzer/scanner in list(tied_human.belt, tied_human.back, tied_human.s_store, tied_human.l_hand, tied_human.r_hand))
		return scanner
	return get_item_from_equipment_map_path(/obj/item/device/healthanalyzer, HUMAN_AI_TOOLS)

/// Returns TRUE if the ally is in sight, hurt, and something we carry helps them
/datum/human_ai_brain/proc/can_treat_patient(mob/living/carbon/human/patient)
	if(QDELETED(patient) || (patient == tied_human) || (patient.stat == DEAD) || patient.on_fire)
		return FALSE

	if((patient.z != tied_human.z) || (get_dist(tied_human, patient) > view_distance))
		return FALSE

	if(patient_rest_times[REF(patient)] > world.time)
		return FALSE

	if(!faction_check(patient) || !healing_start_check(patient))
		return FALSE

	return !!find_treatment(patient)

/// Returns the most hurt ally in sight that we can treat, looking around again only every patient_search_delay
/datum/human_ai_brain/proc/find_patient()
	RETURN_TYPE(/mob/living/carbon/human)
	if(found_injured_ally)
		if(can_treat_patient(found_injured_ally))
			return found_injured_ally
		lose_injured_ally()

	if(!COOLDOWN_FINISHED(src, patient_search_cooldown))
		return

	COOLDOWN_START(src, patient_search_cooldown, patient_search_delay)
	var/mob/living/carbon/human/patient = get_injured_ally()
	set_injured_ally(patient)
	return patient

/// Leaves the patient alone for a while
/datum/human_ai_brain/proc/rest_patient(mob/living/carbon/human/patient)
	if(patient)
		patient_rest_times[REF(patient)] = world.time + patient_rest_delay
	if(patient == found_injured_ally)
		lose_injured_ally()

/datum/ai_action/treat_ally
	name = "Treat Ally"
	action_flags = ACTION_USING_HANDS | ACTION_USING_LEGS
	/// If TRUE, the patient was looked over with the health analyzer
	var/scanned = FALSE
	/// When we give up on a patient that keeps walking away or can't be treated
	var/give_up_time

/datum/ai_action/treat_ally/get_weight(datum/human_ai_brain/brain)
	if(iszombie(brain.tied_human))
		return 0

	if(brain.healing_someone || brain.current_target || brain.hold_position)
		return 0

	var/should_fire_offscreen = (brain.target_turf && !COOLDOWN_FINISHED(brain, fire_offscreen))
	if(should_fire_offscreen)
		return 0

	if(!length(brain.equipment_map[HUMAN_AI_HEALTHITEMS]) || !brain.get_medical_scanner())
		return 0

	// Patch ourselves up first
	if(brain.healing_start_check(brain.tied_human) && COOLDOWN_FINISHED(brain, treatment_search_cooldown) && brain.find_treatment(brain.tied_human))
		return 0

	if(!brain.find_patient())
		return 0

	return 6

/datum/ai_action/treat_ally/Added()
	give_up_time = world.time + 30 SECONDS

/datum/ai_action/treat_ally/trigger_action()
	. = ..()

	// Finish what we started first, the item is already in our hand
	if(brain.healing_someone)
		return ONGOING_ACTION_UNFINISHED

	var/mob/living/carbon/human/patient = brain.found_injured_ally
	if(brain.current_target || !brain.can_treat_patient(patient) || (world.time > give_up_time))
		brain.rest_patient(patient)
		return ONGOING_ACTION_COMPLETED

	var/mob/living/carbon/human/medic = brain.tied_human
	if(get_dist(medic, patient) > 1)
		if(!brain.move_to_next_turf(get_turf(patient)))
			brain.rest_patient(patient)
			return ONGOING_ACTION_COMPLETED
		return ONGOING_ACTION_UNFINISHED

	medic.face_atom(patient)
	if(!scanned)
		scanned = TRUE
		brain.get_medical_scanner()?.ai_use(medic, brain, patient)
		return ONGOING_ACTION_UNFINISHED

	brain.apply_treatment(patient, brain.find_treatment(patient))
	return ONGOING_ACTION_UNFINISHED
