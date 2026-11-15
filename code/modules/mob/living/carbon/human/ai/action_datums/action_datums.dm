GLOBAL_LIST_INIT_TYPED(AI_actions, /datum/ai_action, setup_ai_actions())

/proc/setup_ai_actions()
	var/list/action_list = list()
	for(var/action in subtypesof(/datum/ai_action))
		var/datum/ai_action/A = new action
		action_list[A.type] = A
	return action_list


/datum/ai_action
	var/name
	var/datum/human_ai_brain/brain
	var/action_flags = null
	/// get_conflicts() as an assoc list of action type = TRUE, filled on the GLOB.AI_actions singleton the first time it's needed
	var/list/cached_conflicts
	/// If TRUE, the action stops conflicting ongoing actions that started with less weight instead of waiting for them to end
	var/preempts_actions = FALSE
	/// The weight this action had when it was started
	var/started_weight = 0

/// Proc to be overridden to determine what weight this action should have
/// The reason a brain is passed in as an arg is that we have GLOB.AI_actions that are iterated through, calling get_weight() on each for every AI
/// As such they act as singletons, except when they don't
/datum/ai_action/proc/get_weight(datum/human_ai_brain/brain)
	return 0

/// Proc to determine what actions aren't compatible with any that the AI currently have ongoing
/// If you want to add one, override this on child and add a typepath of an action to .
/datum/ai_action/proc/get_conflicts(datum/human_ai_brain/brain)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)
	. = list()

	if(!action_flags)
		return

	for(var/action_type as anything in GLOB.AI_actions)
		if(GLOB.AI_actions[action_type].action_flags & action_flags)
			. += action_type

/// Cached get_conflicts(), as conflicts don't depend on the brain
/datum/ai_action/proc/get_cached_conflicts(datum/human_ai_brain/brain)
	RETURN_TYPE(/list)
	if(isnull(cached_conflicts))
		cached_conflicts = list()
		for(var/action_type in get_conflicts(brain))
			cached_conflicts[action_type] = TRUE
	return cached_conflicts

/datum/ai_action/New(datum/human_ai_brain/brain)
	. = ..()

	if(!brain)
		return

	src.brain = brain
	Added()

/// Called when an action is created and assigned a brain
/datum/ai_action/proc/Added()
	return

/datum/ai_action/Destroy(force, ...)
	brain.ongoing_actions -= src
	brain = null
	return ..()

/// Everything that the action should do should go in this proc
/datum/ai_action/proc/trigger_action()
	SHOULD_NOT_SLEEP(TRUE)
	if(!brain)
		return ONGOING_ACTION_COMPLETED
