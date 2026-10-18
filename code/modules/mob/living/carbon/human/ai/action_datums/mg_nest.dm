/datum/human_ai_brain
	var/turf/machinegunner_home
	var/machinegunner_dir = SOUTH

/datum/ai_action/machinegunner_nest
	name = "Machinegunner Nest"
	action_flags = ACTION_USING_LEGS
	var/initial_view
	var/initial_reload_line_chance

/datum/ai_action/machinegunner_nest/get_weight(datum/human_ai_brain/brain)
	if(!brain.machinegunner_home)
		return 0

	if(brain.tried_reload)
		return 0

	if(brain.current_cover)
		return 0

	if(!brain.primary_weapon)
		return 0

	if(brain.healing_someone)
		return 0

	return 12

/datum/ai_action/machinegunner_nest/Added()
	initial_view = brain.view_distance
	initial_reload_line_chance = brain.reload_line_chance
	brain.reload_line_chance = 0

/datum/ai_action/machinegunner_nest/Destroy(force, ...)
	brain.view_distance = initial_view
	brain.reload_line_chance = initial_reload_line_chance
	return ..()

/datum/ai_action/machinegunner_nest/trigger_action()
	. = ..()

	if(brain.tried_reload || brain.current_cover || brain.healing_someone)
		return ONGOING_ACTION_COMPLETED

	var/obj/item/weapon/gun/primary_weapon = brain.primary_weapon
	if(!primary_weapon)
		return ONGOING_ACTION_COMPLETED

	var/turf/machinegunner_home = brain.machinegunner_home
	if(QDELETED(machinegunner_home))
		return ONGOING_ACTION_COMPLETED

	var/mob/living/carbon/tied_human = brain.tied_human
	if(get_dist(tied_human, machinegunner_home) > 0)
		if(!brain.move_to_next_turf(machinegunner_home))
			return ONGOING_ACTION_COMPLETED

	if(!get_dist(tied_human, machinegunner_home))
		brain.view_distance = 30
		brain.tied_human.face_dir(brain.machinegunner_dir)

	if(!brain.should_reload())
		brain.unholster_primary()
		brain.ensure_primary_hand(primary_weapon)
		brain.wield_primary()

	return ONGOING_ACTION_UNFINISHED
