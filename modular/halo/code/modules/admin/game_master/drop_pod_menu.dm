GLOBAL_LIST_EMPTY(game_master_droppods)
GLOBAL_DATUM_INIT(droppod_panel, /datum/drop_pod_menu, new)
#define DROPPOD_CLICK_INTERCEPT_ACTION "droppod_click_intercept_action"

/client/proc/toggle_droppod_menu()
	set name = "Drop Pod Menu"
	set category = "Game Master.Extras"
	if(!check_rights(R_ADMIN))
		return

	GLOB.droppod_panel.tgui_interact(mob)

/datum/drop_pod_menu
	var/droppod_click_intercept = FALSE
	var/list/selected_launch_targets = list()
	var/next_launch_target_index = 1

/datum/drop_pod_menu/ui_data(mob/user)
	. = ..()

	var/list/data = list()

	prune_selected_targets()
	var/list/game_master_droppods = list()
	for(var/list/droppod_entry in GLOB.game_master_droppods)
		var/list/entry_copy = droppod_entry.Copy()
		entry_copy["selected_for_launch"] = (entry_copy["droppod_ref"] in selected_launch_targets)
		game_master_droppods += list(entry_copy)
	data["game_master_droppods"] = length(game_master_droppods) ? game_master_droppods : ""
	data["selected_launch_target_count"] = length(selected_launch_targets)
	data["droppod_click_intercept"] = droppod_click_intercept
	return data

/datum/drop_pod_menu/proc/prune_selected_targets()
	if(!length(selected_launch_targets))
		next_launch_target_index = 1
		return
	for(var/target_ref in selected_launch_targets.Copy())
		var/obj/effect/landmark/droppod/target = locate(target_ref)
		if(!istype(target))
			selected_launch_targets -= target_ref
			continue
		if(!get_turf(target))
			selected_launch_targets -= target_ref
	if(!length(selected_launch_targets) || next_launch_target_index > length(selected_launch_targets))
		next_launch_target_index = 1

/datum/drop_pod_menu/proc/toggle_launch_target(obj/effect/landmark/droppod/target)
	var/target_ref = REF(target)
	if(target_ref in selected_launch_targets)
		selected_launch_targets -= target_ref
		if(!length(selected_launch_targets))
			next_launch_target_index = 1
		return FALSE
	selected_launch_targets += list(target_ref)
	return TRUE

/datum/drop_pod_menu/proc/get_selected_launch_targets()
	prune_selected_targets()
	. = list()
	for(var/target_ref in selected_launch_targets)
		var/obj/effect/landmark/droppod/target = locate(target_ref)
		if(!istype(target))
			continue
		var/turf/target_turf = get_turf(target)
		if(!target_turf)
			continue
		. += target_turf

/datum/drop_pod_menu/proc/get_rotated_launch_targets(list/selected_targets)
	. = list()
	var/target_count = length(selected_targets)
	if(!target_count)
		return
	if(next_launch_target_index < 1 || next_launch_target_index > target_count)
		next_launch_target_index = 1
	var/start_index = next_launch_target_index
	for(var/i = 0, i < target_count, i++)
		var/list_index = ((start_index + i - 1) % target_count) + 1
		. += selected_targets[list_index]
	next_launch_target_index = (start_index % target_count) + 1

/datum/drop_pod_menu/proc/InterceptClickOn(mob/user, params, atom/object)
	var/list/modifiers = params2list(params)
	if(droppod_click_intercept)
		var/turf/object_turf = get_turf(object)
		if(LAZYACCESS(modifiers, MIDDLE_CLICK))
			for(var/obj/effect/landmark/droppod/R in object_turf)
				remove_droppod(R)
			return TRUE

		var/obj/effect/landmark/droppod/droppod = new(object_turf)
		var/droppod_ref = REF(droppod)
		GLOB.game_master_droppods += list(list(
			"droppod" = droppod,
			"droppod_name" = droppod.name,
			"droppod_ref" = droppod_ref,
			"droppod_x" = droppod.x,
			"droppod_y" = droppod.y,
			"droppod_z" = droppod.z,
			))
		return TRUE

/datum/drop_pod_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GameMasterDroppodMenu", "Droppod Menu")
		ui.open()
	user.client?.click_intercept = src
/datum/drop_pod_menu/ui_status(mob/user, datum/ui_state/state)
	return UI_INTERACTIVE


/datum/drop_pod_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	switch(action)
		if("remove_droppod")
			if(!params["val"])
				return

			var/list/droppod = params["val"]

			var/atom/droppod_atom = locate(droppod["droppod_ref"])

			if(!droppod_atom)
				return TRUE

			if(tgui_alert(ui.user, "Do you want to remove [droppod_atom] ?", "Confirmation", list("Yes", "No")) != "Yes")
				return TRUE

			remove_droppod(droppod_atom)

		if("jump_to_droppod")
			if(!params["val"])
				return

			var/list/droppod = params["val"]

			var/atom/droppod_atom = locate(droppod["droppod_ref"])

			var/turf/droppod_turf = get_turf(droppod_atom)

			if(!droppod_turf)
				return TRUE

			var/client/jumping_client = ui.user.client
			jumping_client.jump_to_turf(droppod_turf)
			return TRUE
		if("set_target")
			if(!params["val"])
				return

			var/list/droppod = params["val"]
			var/obj/effect/landmark/droppod/droppod_atom = locate(droppod["droppod_ref"])
			if(!istype(droppod_atom))
				return TRUE
			var/selected = toggle_launch_target(droppod_atom)
			message_admins("[key_name_admin(ui.user)] [selected ? "added" : "removed"] the ODST drop launch target at [droppod_atom.x], [droppod_atom.y], [droppod_atom.z]", droppod_atom.x, droppod_atom.y, droppod_atom.z)
			return TRUE
		if("toggle_click_droppod")
			droppod_click_intercept = !droppod_click_intercept
			return
		if("launch_pods")
			var/list/turf/selected_targets = get_selected_launch_targets()
			if(!length(selected_targets))
				to_chat(ui.user, SPAN_WARNING("Select at least one droppod LZ first."))
				return TRUE
			var/launched_pods = 0
			for(var/obj/structure/halo_droppod/pod in world)
				if(!pod.can_start_launch())
					continue
				pod.set_launch_targets(get_rotated_launch_targets(selected_targets))
				if(pod.start_launch_pod(ui.user))
					launched_pods++
			if(!launched_pods)
				to_chat(ui.user, SPAN_WARNING("No ready occupied droppods were found."))
			return TRUE
/datum/drop_pod_menu/ui_close(mob/user)
	var/client/user_client = user.client
	if(user_client?.click_intercept == src)
		user_client.click_intercept = null

	droppod_click_intercept = FALSE
	selected_launch_targets.Cut()
	next_launch_target_index = 1

/datum/drop_pod_menu/proc/remove_droppod(obj/removing_datum)
	SIGNAL_HANDLER
	var/removing_ref = REF(removing_datum)
	selected_launch_targets -= removing_ref
	if(!length(selected_launch_targets))
		next_launch_target_index = 1

	for(var/list/cycled_droppod in GLOB.game_master_droppods)
		if(cycled_droppod["droppod"] == removing_datum)
			GLOB.game_master_droppods.Remove(list(cycled_droppod))
			QDEL_NULL(removing_datum)
