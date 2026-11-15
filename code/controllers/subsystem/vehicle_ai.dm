SUBSYSTEM_DEF(vehicle_ai)
	name = "Vehicle AI"
	priority = SS_PRIORITY_VEHICLE_AI
	flags = SS_NO_INIT
	wait = 0.1 SECONDS
	/// List of all vehicle AI brains
	var/list/datum/vehicle_ai_brain/brains = list()
	/// A list of brains scheduled to process
	var/list/datum/vehicle_ai_brain/current_run = list()
	/// Assoc list of action type : action singleton used to weigh actions, see get_actions()
	var/list/datum/vehicle_ai_action/actions
	/// Squads of AI vehicles that game masters made
	var/list/datum/vehicle_ai_squad/squads = list()
	/// The id of the last squad made, so every squad gets a new one
	var/last_squad_id = 0

/datum/controller/subsystem/vehicle_ai/stat_entry(msg)
	msg = "P:[length(brains)]"
	return ..()

/datum/controller/subsystem/vehicle_ai/fire(resumed = FALSE)
	// Toggle Human AI stops vehicles as well
	if(SShuman_ai.ai_kill)
		return

	if(!resumed)
		src.current_run = brains.Copy()
	// Cache for sanic speed (lists are references anyways)
	var/list/current_run = src.current_run
	while(length(current_run))
		var/datum/vehicle_ai_brain/brain = current_run[length(current_run)]
		current_run.len--
		if(!QDELETED(brain))
			brain.process(wait * 0.1)

		if(MC_TICK_CHECK)
			return

/// Returns the action singletons, creating them on first use since brains can be made before the subsystems initialize
/datum/controller/subsystem/vehicle_ai/proc/get_actions()
	RETURN_TYPE(/list)
	if(!actions)
		actions = list()
		for(var/action_type in subtypesof(/datum/vehicle_ai_action))
			actions[action_type] = new action_type
	return actions
