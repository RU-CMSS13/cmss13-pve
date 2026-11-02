GLOBAL_LIST_EMPTY(human_ai_squad_presets)

/datum/human_ai_squad_preset
	var/name = ""
	var/desc = ""
	var/faction = FACTION_NEUTRAL
	/// First entry is marked as squad leader
	var/list/ai_to_spawn = list()

/datum/human_ai_squad_preset/proc/spawn_ai(turf/spawn_loc, mob/user)
	var/list/viable_turfs = list()
	for(var/turf/open/floor_tile in range(1, spawn_loc))
		viable_turfs += floor_tile
	var/list/reducing_viable_turfs = viable_turfs.Copy()
	if(!length(viable_turfs))
		to_chat(user, SPAN_BOLDNOTICE("No viable turfs found!"))
		return

	var/datum/human_ai_squad/new_squad = SShuman_ai.create_new_squad()

	var/squad_leader_selected = FALSE
	for(var/datum/equipment_preset/ai_equipment as anything in ai_to_spawn)
		for(var/i in 1 to ai_to_spawn[ai_equipment])
			var/selected_turf = pick(viable_turfs)
			if(!length(reducing_viable_turfs) < 1)
				selected_turf = pick(reducing_viable_turfs)
				if(spawn_loc in reducing_viable_turfs)
					selected_turf = spawn_loc
				reducing_viable_turfs -= selected_turf

			var/mob/living/carbon/human/ai_human = new(selected_turf)
			arm_equipment(ai_human, ai_equipment, TRUE)
			var/datum/component/human_ai/ai_comp = ai_human.AddComponent(/datum/component/human_ai)
			new_squad.add_to_squad(ai_comp.ai_brain)
			if(!squad_leader_selected)
				new_squad.set_squad_leader(ai_comp.ai_brain)
				squad_leader_selected = TRUE
