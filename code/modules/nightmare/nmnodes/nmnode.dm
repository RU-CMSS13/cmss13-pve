/// Decriptive nightmare config nodes loaded from config files
/datum/nmnode
	/// Unique identifier for referencing in JSON configuration
	var/id = "abstract"
	/// User provided name for debugging
	var/name
	/// Original JSON object that was used to create this
	var/list/raw

/datum/nmnode/New(list/spec)
	. = ..()
	src.raw = spec
	src.name = id
	if(spec["name"])
		src.name = spec["name"]
	if(isnum(spec["chance"]))
		AddElement(/datum/element/nmnode_prob, spec["chance"])
	var/list/conds = spec["when"]
	if(islist(conds))
		for(var/pname in conds)
			var/pvalue = conds[pname]
			var/modifier = copytext(pname, 1, 2)
			var/negate = FALSE
			if(modifier == "!")
				negate = TRUE
				pname = copytext(pname, 2)
			AddComponent(/datum/component/nmnode_cond, pname, pvalue, negate)

/// Implementation of the node, resolving into tasks in the given context
/datum/nmnode/proc/resolve(datum/nmcontext/context)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)
	. = TRUE
	if(SEND_SIGNAL(src, COMSIG_NIGHTMARE_APPLYING_NODE, context) & COMPONENT_ABORT_NMNODE)
		. = FALSE

/// Call wrapper for resolving nodes
/datum/nmnode/proc/invoke(datum/nmcontext/context)
	SHOULD_NOT_OVERRIDE(TRUE)
	. = resolve(context)
	if(.)
		context.trace += src


/**
 * Adds every map insert this node could schedule to inserts, for the admin Nightmare menu
 *
 * Arguments:
 * * inserts - list(insert id = insert data) being filled, see [/datum/nmnode/proc/add_catalogue_insert]
 * * notes - conditions inherited from parent nodes, as readable strings
 * * group - name of the closest pick node, to group its choices together
 */
/datum/nmnode/proc/catalogue_inserts(datum/nmcontext/context, list/inserts, list/notes, group)
	return

/// Returns the conditions and chance of this node itself as readable strings
/datum/nmnode/proc/get_notes()
	. = list()
	var/list/conds = raw["when"]
	if(islist(conds))
		for(var/pname in conds)
			if(copytext(pname, 1, 2) == "!")
				. += "[copytext(pname, 2)] != [conds[pname]]"
			else
				. += "[pname] = [conds[pname]]"
	if(isnum(raw["chance"]))
		. += "[raw["chance"] * 100]% chance"

/// Adds one insert to the catalogue. Its id matches the landmark and path of the /datum/nmtask/mapload it would schedule
/datum/nmnode/proc/add_catalogue_insert(datum/nmcontext/context, list/inserts, list/notes, group, filepath, landmark, keep)
	var/insert_id = NIGHTMARE_INSERT_ID(landmark, filepath)
	if(inserts[insert_id])
		return
	inserts[insert_id] = list(
		"id" = insert_id,
		"group" = group,
		"landmark" = landmark,
		"path" = filepath,
		"file" = replacetext(filepath, "[context.config["prefix_map"]]/", ""),
		"keep" = !!keep,
		"notes" = jointext(notes, ", "),
	)
