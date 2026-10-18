/**
 * Drives and fights with a multitile vehicle through its human AI crew, in the same way as human AI.
 *
 * The brain weighs /datum/vehicle_ai_action each tick and runs the best ones that don't conflict.
 * A seat's job is only done while a conscious AI crewman sits in it, so killing the driver stops the vehicle
 * and killing the gunner silences its guns. A player in a seat does that seat's job instead of the AI.
 */
/datum/vehicle_ai_brain
	/// The vehicle that this brain controls
	var/obj/vehicle/multitile/vehicle
	/// Faction the vehicle fights for. Friendly and neutral factions are taken from the human AI faction of the same name
	var/faction = FACTION_NEUTRAL

	/// List of current action datums
	var/list/datum/vehicle_ai_action/ongoing_actions = list()

	/// If TRUE, the AI will not drive anywhere, only turn in place
	var/hold_position = FALSE
	/// A turf the AI was ordered to drive to. It keeps shooting on the way, but doesn't stop to fight
	var/turf/destination

	/// If TRUE, then we're actively fighting someone or have been shot at
	var/in_combat = FALSE
	/// The minimum amount of time that can pass before this AI can leave combat
	var/combat_decay_time_min = 20 SECONDS
	/// The maximum amount of time that can pass before this AI can leave combat
	var/combat_decay_time_max = 40 SECONDS

/datum/vehicle_ai_brain/New(obj/vehicle/multitile/vehicle, faction)
	. = ..()
	src.vehicle = vehicle
	vehicle.ai_brain = src
	set_faction(faction)
	RegisterSignal(vehicle, COMSIG_PARENT_QDELETING, PROC_REF(on_vehicle_delete))
	SSvehicle_ai.brains += src

/datum/vehicle_ai_brain/Destroy(force, ...)
	SSvehicle_ai.brains -= src
	SSvehicle_ai.current_run -= src
	reset_ai()
	release_crew()
	if(vehicle)
		UnregisterSignal(vehicle, COMSIG_PARENT_QDELETING)
		vehicle.ai_brain = null
		vehicle.door_locked = initial(vehicle.door_locked)
		vehicle = null
	return ..()

/datum/vehicle_ai_brain/proc/on_vehicle_delete(datum/source, force)
	SIGNAL_HANDLER
	qdel(src)

/// Stops everything the AI is doing and forgets its targets and orders
/datum/vehicle_ai_brain/proc/reset_ai()
	in_combat = FALSE
	target_turf = null
	destination = null
	lose_target()
	clear_path()
	stop_all_weapons()

	for(var/datum/vehicle_ai_action/action as anything in ongoing_actions.Copy())
		qdel(action)
	ongoing_actions.Cut()

/datum/vehicle_ai_brain/process(delta_time)
	if(is_knocked_out())
		if(length(ongoing_actions) || current_target)
			reset_ai()
		if(!crew_evacuated && length(crew))
			evacuate_crew()
		return

	// The interior loads after the vehicle, so the crew boards once it's ready
	if(crew_preset && vehicle.interior?.ready)
		spawn_crew()

	// Buckling into a seat sets the vehicle's IFF to the crewman's faction, keep ours unless someone is driving
	if(!vehicle.seats[VEHICLE_DRIVER])
		vehicle.vehicle_faction = faction

	if(COOLDOWN_FINISHED(src, target_scan))
		COOLDOWN_START(src, target_scan, target_scan_delay)
		check_boarders()
		reassign_crew_seats()
		check_damage_lines()
		scan_targets()
		if(current_target)
			enter_combat()
	else if(current_target)
		target_turf = get_turf(current_target)

	pathfinder?.search(path_nodes_per_tick)
	handle_reloads()

	// List all actions for the AI to consider, skipping ones we are already doing
	var/list/datum/vehicle_ai_action/all_actions = SSvehicle_ai.get_actions()
	var/list/possible_actions = list()
	for(var/action_type in all_actions)
		if(has_ongoing_action(action_type))
			continue
		var/weight = all_actions[action_type].get_weight(src)
		if(weight) // No weight means we shouldn't consider this action at all
			possible_actions[action_type] = weight

	var/list/sorted_actions = sortTim(possible_actions, GLOBAL_PROC_REF(cmp_numeric_dsc), TRUE)

	// Start new actions. A heavier action replaces the conflicting ongoing ones, a lighter one waits for them
	for(var/action_type in sorted_actions)
		var/weight = sorted_actions[action_type]
		var/list/conflicting_actions = all_actions[action_type].get_conflicts(src)
		var/list/datum/vehicle_ai_action/to_replace = list()
		var/blocked = FALSE
		for(var/datum/vehicle_ai_action/ongoing_action as anything in ongoing_actions)
			if(!(ongoing_action.type in conflicting_actions))
				continue
			if(ongoing_action.weight >= weight)
				blocked = TRUE
				break
			to_replace += ongoing_action

		if(blocked)
			continue

		for(var/datum/vehicle_ai_action/replaced_action as anything in to_replace)
			qdel(replaced_action)

		var/datum/vehicle_ai_action/new_action = new action_type(src)
		new_action.weight = weight
		ongoing_actions += new_action

	for(var/datum/vehicle_ai_action/action as anything in ongoing_actions.Copy())
		var/retval = action.trigger_action()
		switch(retval)
			if(ONGOING_ACTION_UNFINISHED_BLOCK)
				return
			if(ONGOING_ACTION_COMPLETED)
				qdel(action)

/// Returns if this AI has a given action, based on path
/datum/vehicle_ai_brain/proc/has_ongoing_action(path)
	for(var/datum/vehicle_ai_action/action as anything in ongoing_actions)
		if(istype(action, path))
			return TRUE
	return FALSE

/// TRUE if an AI crewman sits in the given seat, so the AI may do that seat's job
/datum/vehicle_ai_brain/proc/can_use_seat(seat)
	var/mob/living/carbon/human/seated_mob = vehicle.seats[seat]
	return seated_mob && is_crewman_seated(seated_mob)

/// TRUE if the AI is allowed to and able to drive right now
/datum/vehicle_ai_brain/proc/can_drive()
	return can_use_seat(VEHICLE_DRIVER) && vehicle.ai_can_move()

// Factions

/datum/vehicle_ai_brain/proc/set_faction(new_faction)
	faction = new_faction
	vehicle.vehicle_faction = new_faction
	vehicle.door_locked = TRUE

/// Returns the human AI faction that holds our friendly and neutral factions, if there is one
/datum/vehicle_ai_brain/proc/get_faction_data()
	RETURN_TYPE(/datum/human_ai_faction)
	return SShuman_ai.human_ai_factions[faction]

/// TRUE if the faction is ours or friendly to us
/datum/vehicle_ai_brain/proc/is_friendly_faction(target_faction)
	if(!target_faction)
		return FALSE
	if(target_faction == faction)
		return TRUE
	var/datum/human_ai_faction/faction_data = get_faction_data()
	return faction_data && (target_faction in faction_data.get_friendly_factions())

/// TRUE if the faction is ours, friendly or neutral to us
/datum/vehicle_ai_brain/proc/is_allied_faction(target_faction)
	if(is_friendly_faction(target_faction))
		return TRUE
	var/datum/human_ai_faction/faction_data = get_faction_data()
	return faction_data && (target_faction in faction_data.get_neutral_factions())

/// Returns TRUE if the target is friendly/neutral to us
/datum/vehicle_ai_brain/proc/faction_check(atom/target)
	if(ismob(target))
		var/mob/mob_target = target
		return is_allied_faction(mob_target.faction)

	if(istype(target, /obj/vehicle/multitile))
		var/obj/vehicle/multitile/vehicle_target = target
		// Abandoned vehicles are no threat
		return !vehicle_target.vehicle_faction || is_allied_faction(vehicle_target.vehicle_faction)

	if(isdefenses(target))
		var/obj/structure/machinery/defenses/defense_target = target
		for(var/defense_faction in defense_target.faction_group)
			if(is_allied_faction(defense_faction))
				return TRUE
		return FALSE

	return FALSE

/// Removes neutral faction status from a given faction
/datum/vehicle_ai_brain/proc/on_neutral_faction_betray(betrayer_faction)
	var/datum/human_ai_faction/faction_data = get_faction_data()
	if(!faction_data || !(betrayer_faction in faction_data.get_neutral_factions()))
		return
	faction_data.remove_neutral_faction(betrayer_faction)

// Combat

/datum/vehicle_ai_brain/proc/enter_combat()
	if(!in_combat)
		alert_nearby_ai()
		say_contact_line()

	in_combat = TRUE
	addtimer(CALLBACK(src, PROC_REF(exit_combat)), rand(combat_decay_time_min, combat_decay_time_max), TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE)
	SShuman_ai.combat_ever_started = TRUE

/datum/vehicle_ai_brain/proc/exit_combat()
	if(!in_combat)
		return

	in_combat = FALSE
	lose_target()
	target_turf = null
	stop_all_weapons()
	crew_say(clear_lines)

/// Points nearby friendly human AI without a target at what we are fighting, like a squad calling for help
/datum/vehicle_ai_brain/proc/alert_nearby_ai()
	if(!target_turf)
		return

	for(var/datum/human_ai_brain/brain as anything in GLOB.human_ai_brains)
		var/mob/living/carbon/human/ai_human = brain.tied_human
		if(!ai_human || ai_human.client || brain.target_turf || (ai_human.z != vehicle.z))
			continue
		if(get_dist(ai_human, vehicle) > brain.view_distance)
			continue
		if(!is_friendly_faction(ai_human.faction))
			continue
		brain.target_turf = target_turf

/// Called when a projectile hits the vehicle
/datum/vehicle_ai_brain/proc/on_shot(obj/projectile/bullet)
	var/atom/firer = bullet.firer
	if(!firer || firer == vehicle)
		return

	if(ismob(firer))
		var/mob/mob_firer = firer
		on_neutral_faction_betray(mob_firer.faction)
	else if(isdefenses(firer))
		var/obj/structure/machinery/defenses/defense_firer = firer
		for(var/defense_faction in defense_firer.faction_group)
			on_neutral_faction_betray(defense_faction)
	else if(istype(firer, /obj/vehicle/multitile))
		var/obj/vehicle/multitile/vehicle_firer = firer
		on_neutral_faction_betray(vehicle_firer.vehicle_faction)

	on_attacked(firer)

/// Called when something hostile attacks the vehicle, for example a xeno slashing it
/datum/vehicle_ai_brain/proc/on_attacked(atom/attacker)
	if(!attacker || faction_check(attacker))
		return

	if(!current_target)
		var/turf/center = get_turf(vehicle)
		if(isturf(attacker.loc) && is_valid_target(attacker, center) && (attacker in view(view_distance, center)))
			set_target(attacker)
		else
			target_turf = get_turf(attacker)

	enter_combat()
