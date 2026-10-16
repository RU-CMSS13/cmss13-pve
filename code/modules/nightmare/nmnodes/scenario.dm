/datum/nmnode/scenario_def
	id = "def"
	var/list/values

/datum/nmnode/scenario_def/New(list/spec)
	. = ..()
	values = spec["values"]

/datum/nmnode/scenario_def/Destroy()
	values = null
	return ..()

/datum/nmnode/scenario_def/resolve(datum/nmcontext/context)
	. = ..()
	if(.)
		for(var/value in values)
			context.scenario[value] = values[value]

/// Adds the values this definition can set to the context directory, whether or not it gets picked
/datum/nmnode/scenario_def/proc/catalogue(datum/nmcontext/context)
	for(var/value in values)
		LAZYINITLIST(context.directory[value])
		context.directory[value] |= list(values[value])
