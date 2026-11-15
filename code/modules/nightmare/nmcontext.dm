/// Context within which we resolve nightmare actions
/datum/nmcontext
	/// User-friendly name
	var/name = "context"
	/// Storage of scenario values in the context as KV
	var/list/scenario = list()
	/// All values each scenario parameter can take, as list(name = list(value, ...)). Used by the admin Nightmare menu
	var/list/directory = list()
	/// Every map insert the context could load, built on demand by /datum/controller/subsystem/nightmare/proc/get_inserts(). See /datum/nmnode/proc/add_catalogue_insert()
	var/list/inserts
	/// Admin overrides of inserts, as list(insert id = TRUE to force it, FALSE to block it)
	var/list/insert_overrides = list()
	/// Ids of the inserts that were loaded, as list(insert id = TRUE)
	var/list/loaded_inserts = list()
	/// Config values used internally relevant to context
	var/list/config = list()
	/// Scheduler task type
	var/scheduler_type = /datum/nmtask/scheduler
	/// Holder for tasks to execute in the context
	VAR_PRIVATE/datum/nmtask/scheduler/scheduler
	/// Runtime debug list of resolved nodes in the context
	var/list/datum/nmnode/trace = list()

/datum/nmcontext/Destroy()
	QDEL_NULL(scheduler)
	scenario = null
	directory = null
	inserts = null
	insert_overrides = null
	loaded_inserts = null
	return ..()

/datum/nmcontext/New(name)
	. = ..()
	if(name)
		src.name = name
	scheduler = new scheduler_type

/// Get a value from the scenario, or a global value
/datum/nmcontext/proc/get_scenario_value(pname)
	var/datum/nmcontext/scope = src
	var/modifier = copytext(pname, 1, 2)
	if(modifier == "$")
		pname = copytext(pname, 2)
		scope = SSnightmare.contexts[NIGHTMARE_CTX_GLOBAL]
	return scope.scenario[pname]

/// Set a value in the scenario. This should only be used by manual user intervention, such as admins tweaking scenario!!
/datum/nmcontext/proc/set_scenario_value(pname, value)
	scenario[pname] = value

/// Resolve a config file path using context configuration
/datum/nmcontext/proc/get_file_path(relative_path, file_type = "config")
	if(config["prefix_[file_type]"])
		relative_path = "[config["prefix_[file_type]"]]/[relative_path]"
	if(fexists(relative_path))
		return relative_path
	CRASH("Nightmare context '[name]' failed to find file in scope '[file_type]': [relative_path]")

/datum/nmcontext/proc/add_task(task)
	scheduler.add_task(task)

/datum/nmcontext/proc/run_tasks()
	. = scheduler.invoke_sync()
	for(var/datum/nmtask/mapload/task in scheduler.donetasks)
		if(task.loaded)
			loaded_inserts[NIGHTMARE_INSERT_ID(task.landmark, task.filepath)] = TRUE

/// Removes the scheduled inserts admins blocked and schedules the ones they forced. Called once the base nodes are resolved
/datum/nmcontext/proc/apply_insert_overrides()
	if(!length(insert_overrides))
		return
	var/list/scheduled = list()
	for(var/datum/nmtask/mapload/task in scheduler.tasks)
		var/id = NIGHTMARE_INSERT_ID(task.landmark, task.filepath)
		if(insert_overrides[id] == FALSE)
			scheduler.remove_task(task)
			log_debug("Nightmare: Admin blocked insert [id]")
		else
			scheduled[id] = task
	for(var/id in insert_overrides)
		var/list/insert = inserts?[id]
		if(!insert_overrides[id] || !insert || scheduled[id])
			continue
		// The forced insert replaces whatever rolled for its landmark, unless it only adds on top
		if(!insert["keep"])
			for(var/other_id in scheduled)
				var/datum/nmtask/mapload/other = scheduled[other_id]
				if(other.landmark == insert["landmark"] && !insert_overrides[other_id])
					scheduler.remove_task(other)
					scheduled -= other_id
		var/datum/nmtask/mapload/task = new("Admin forced @ [insert["landmark"]]", insert["path"], insert["landmark"], insert["keep"])
		add_task(task)
		scheduled[id] = task
		log_debug("Nightmare: Admin forced insert [id]")

/// Context belonging to a map scope (ground map, ship map, etc)
/datum/nmcontext/map
	// TODO: Factor in map traits to provide info about the map
	scheduler_type = /datum/nmtask/scheduler/mapload
