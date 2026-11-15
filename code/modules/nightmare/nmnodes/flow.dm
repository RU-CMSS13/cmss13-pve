/// Holding node for several child nodes
/datum/nmnode/branch
	id = "branch"
	/// Child nodes
	var/list/datum/nmnode/nodes

/datum/nmnode/branch/New(list/spec)
	. = ..()
	if(!nodes)
		nodes = SSnightmare.parse_tree(spec["nodes"])

/datum/nmnode/branch/Destroy()
	QDEL_NULL_LIST(nodes)
	return ..()

/datum/nmnode/branch/resolve(datum/nmcontext/context)
	. = ..()
	if(!. || !length(nodes))
		return FALSE
	for(var/datum/nmnode/node as anything in nodes)
		node.invoke(context)
	return TRUE

/datum/nmnode/branch/catalogue_inserts(datum/nmcontext/context, list/inserts, list/notes, group)
	notes = notes + get_notes()
	for(var/datum/nmnode/node as anything in nodes)
		node.catalogue_inserts(context, inserts, notes, group)

/// Same as branch, but load node data from another included file
/datum/nmnode/branch/include
	id = "include"
	var/filepath
	var/list/resolved_nodes = list()
/datum/nmnode/branch/include/New(list/spec)
	. = ..()
	if(spec["file"])
		filepath = spec["file"]
	if(!spec["name"])
		name += ": [filepath]"

/datum/nmnode/branch/include/resolve(datum/nmcontext/context)
	. = ..()
	var/list/datum/nmnode/nodes = SSnightmare.parse_file(context.get_file_path(filepath, "nightmare"))
	if(!nodes)
		CRASH("Include failed to load file: [filepath]")
	resolved_nodes += nodes
	for(var/datum/nmnode/node as anything in nodes)
		node.invoke(context)

/datum/nmnode/branch/include/catalogue_inserts(datum/nmcontext/context, list/inserts, list/notes, group)
	var/list/datum/nmnode/nodes = SSnightmare.parse_file(context.get_file_path(filepath, "nightmare"))
	notes = notes + get_notes()
	for(var/datum/nmnode/node as anything in nodes)
		node.catalogue_inserts(context, inserts, notes, group)
	QDEL_LIST(nodes)

/// Same as branch, but selects a subset of the given nodes
/// amount: how many items to pick
/// choices: nested nodes to pick from
/// each node should have a 'weight' key if you want to use weighted pick
/datum/nmnode/picker
	id = "pick"
	var/amount = 1
	var/list/datum/nmnode/choices

/datum/nmnode/picker/New(list/spec)
	. = ..()
	if(spec["amount"])
		amount = spec["amount"]
	choices = SSnightmare.parse_tree(spec["choices"])

/datum/nmnode/picker/Destroy()
	. = ..()
	QDEL_NULL_LIST(choices)

/datum/nmnode/picker/resolve(datum/nmcontext/context)
	. = ..()
	if(!.) return
	var/list/datum/nmnode/pickables = choices.Copy()
	// Only picked definitions get resolved, so catalogue every possible one here
	for(var/datum/nmnode/scenario_def/def in pickables)
		def.catalogue(context)
	for(var/datum/nmnode/node as anything in pickables)
		pickables[node] = isnum(node.raw["weight"]) ? node.raw["weight"] : 1
	var/list/datum/nmnode/picked = list()
	var/remaining = src.amount
#if defined(UNIT_TESTS)
	remaining = length(pickables) // Force all to be picked for testing (this could potentially make false positives though)
#endif
	while(length(pickables) && remaining > 0)
		var/datum/nmnode/node = pick_weight(pickables)
		remaining--
		pickables -= node
		picked += node
		node.resolve(context)
	return TRUE

/datum/nmnode/picker/catalogue_inserts(datum/nmcontext/context, list/inserts, list/notes, group)
	notes = notes + get_notes()
	if(name != id)
		group = name
	var/total_weight = 0
	for(var/datum/nmnode/node as anything in choices)
		total_weight += isnum(node.raw["weight"]) ? node.raw["weight"] : 1
	for(var/datum/nmnode/node as anything in choices)
		var/weight = isnum(node.raw["weight"]) ? node.raw["weight"] : 1
		node.catalogue_inserts(context, inserts, notes + "picks [amount], weight [weight]/[total_weight]", group)
