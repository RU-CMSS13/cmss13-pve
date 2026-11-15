GLOBAL_DATUM_INIT(nightmare_menu, /datum/nightmare_menu, new)

#define NIGHTMARE_PREVIEW_DURATION (15 SECONDS)

/client/proc/toggle_nightmare_menu()
	set name = "Nightmare Menu"
	set category = "Game Master.Extras"
	if(!check_rights(R_ADMIN))
		return

	GLOB.nightmare_menu.tgui_interact(mob)

/// Lets admins pick the Nightmare scenario and inserts of the upcoming round in the lobby, run Nightmare early or skip it for the round
/datum/nightmare_menu
	/// Map contexts shown in the menu, mapped to the map type they belong to
	var/static/list/menu_contexts = list(
		NIGHTMARE_CTX_GROUND = GROUND_MAP,
		NIGHTMARE_CTX_SHIP = SHIP_MAP,
	)
	/// Insert previews being shown, as list(ckey = list of images)
	var/list/previews = list()

/datum/nightmare_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NightmareMenu", "Nightmare Menu")
		ui.open()

/datum/nightmare_menu/ui_state(mob/user)
	return GLOB.admin_state

/datum/nightmare_menu/ui_data(mob/user)
	var/list/data = list()

	data["status"] = SSnightmare.stat
	// Nightmare only gets a start_time once it runs, so DONE without one means an admin skipped it
	data["disabled"] = (SSnightmare.stat == NIGHTMARE_STATUS_DONE && !SSnightmare.start_time)
	data["editable"] = can_edit()
	data["ran"] = !!(SSnightmare.stat == NIGHTMARE_STATUS_DONE && SSnightmare.start_time)

	var/list/contexts = list()
	for(var/context_name in menu_contexts)
		var/datum/nmcontext/context = SSnightmare.contexts[context_name]
		if(!context)
			continue
		var/datum/map_config/map_config = SSmapping.configs[menu_contexts[context_name]]
		var/list/parameters = list()
		for(var/parameter in context.directory)
			parameters += list(list(
				"name" = parameter,
				"values" = context.directory[parameter],
				"current" = context.scenario[parameter],
			))
		var/list/inserts = list()
		for(var/id in SSnightmare.get_inserts(context_name))
			var/list/insert = context.inserts[id]
			inserts += list(insert + list(
				"override" = context.insert_overrides[id],
				"landmark_found" = !!GLOB.nightmare_landmarks[insert["landmark"]],
				"loaded" = !!context.loaded_inserts[id],
			))
		contexts += list(list(
			"id" = context_name,
			"map_name" = map_config?.map_name,
			"parameters" = parameters,
			"inserts" = inserts,
		))
	data["contexts"] = contexts

	return data

/datum/nightmare_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	var/context_name = params["context"]
	var/datum/nmcontext/context
	if(context_name in menu_contexts)
		context = SSnightmare.contexts[context_name]

	// Looking around changes nothing, so it works at any time
	switch(action)
		if("jump_to_insert", "preview_insert")
			var/list/insert = context?.inserts?[params["id"]]
			if(!insert)
				return
			var/turf/landmark_turf = GLOB.nightmare_landmarks[insert["landmark"]]
			if(!landmark_turf)
				to_chat(user, SPAN_WARNING("Landmark '[insert["landmark"]]' is not on the map, another insert has to place it first."))
				return
			if(isnewplayer(user))
				to_chat(user, SPAN_WARNING("Observe first to look at the map from the lobby."))
				return
			if(action == "jump_to_insert")
				user.client.jump_to_turf(landmark_turf)
			else
				preview_insert(user.client, insert, landmark_turf)
			return

	if(!can_edit())
		to_chat(user, SPAN_WARNING("Nightmare can only be changed in the lobby, before it has run."))
		return

	switch(action)
		if("set_scenario")
			var/parameter = params["name"]
			var/value = params["value"]
			// Only values the scenario files can produce, the inserts are keyed on them
			if(!context || !(parameter in context.directory) || !(value in context.directory[parameter]))
				return
			SSnightmare.set_scenario_value(parameter, value, context_name)
			message_admins("[key_name_admin(user)] set Nightmare [context_name] scenario value '[parameter]' to '[value]'.")
			return TRUE

		if("set_insert_override")
			var/id = params["id"]
			var/list/insert = context?.inserts?[id]
			if(!insert)
				return
			switch(params["override"])
				if("force")
					// Replacing inserts delete the landmark, so only the first forced one at a landmark would load
					if(!insert["keep"])
						for(var/other_id in context.insert_overrides)
							var/list/other = context.inserts[other_id]
							if(other_id == id || !context.insert_overrides[other_id] || other["keep"] || other["landmark"] != insert["landmark"])
								continue
							context.insert_overrides -= other_id
							to_chat(user, SPAN_NOTICE("Nightmare insert '[other["file"]]' set back to auto, only one replacing insert can be forced at '[insert["landmark"]]'."))
					context.insert_overrides[id] = TRUE
				if("block")
					context.insert_overrides[id] = FALSE
				else
					context.insert_overrides -= id
			message_admins("[key_name_admin(user)] set Nightmare insert '[insert["file"]]' at '[insert["landmark"]]' to [params["override"]].")
			return TRUE

		if("reset_insert_overrides")
			if(!context || !length(context.insert_overrides))
				return
			context.insert_overrides.Cut()
			message_admins("[key_name_admin(user)] reset all Nightmare [context_name] insert overrides.")
			return TRUE

		if("prepare_game")
			if(SSnightmare.stat != NIGHTMARE_STATUS_STANDBY)
				return
			if(tgui_alert(user, "Run Nightmare now and load all of its inserts before the round starts? This cannot be undone.", "Confirmation", list("Yes", "No")) != "Yes")
				return
			if(!can_edit() || SSnightmare.stat != NIGHTMARE_STATUS_STANDBY)
				return
			message_admins("[key_name_admin(user)] ran Nightmare ahead of round start.")
			INVOKE_ASYNC(SSnightmare, TYPE_PROC_REF(/datum/controller/subsystem/nightmare, prepare_game))
			return TRUE

		if("toggle_disabled")
			if(SSnightmare.stat == NIGHTMARE_STATUS_STANDBY)
				if(tgui_alert(user, "Skip Nightmare this round? No inserts will be loaded.", "Confirmation", list("Yes", "No")) != "Yes")
					return
				if(!can_edit())
					return
				SSnightmare.stat = NIGHTMARE_STATUS_DONE
				message_admins("[key_name_admin(user)] disabled Nightmare for this round.")
			else
				SSnightmare.stat = NIGHTMARE_STATUS_STANDBY
				message_admins("[key_name_admin(user)] re-enabled Nightmare for this round.")
			return TRUE

/// Whether Nightmare can still be changed: in the lobby, and either not run yet or skipped by an admin
/datum/nightmare_menu/proc/can_edit()
	if(SSticker.current_state != GAME_STATE_PREGAME || !SSnightmare.initialized)
		return FALSE
	if(SSnightmare.stat == NIGHTMARE_STATUS_STANDBY)
		return TRUE
	return SSnightmare.stat == NIGHTMARE_STATUS_DONE && !SSnightmare.start_time

/// Shows the insert to the viewer only, where it would load, without loading anything
/datum/nightmare_menu/proc/preview_insert(client/viewer, list/insert, turf/landmark_turf)
	var/datum/parsed_map/nightmare_preview/preview = new(file(insert["path"]))
	if(!preview.bounds)
		to_chat(viewer, SPAN_WARNING("Could not read insert file [insert["file"]]."))
		return
	preview.load(landmark_turf.x, landmark_turf.y, landmark_turf.z, crop_map = TRUE, no_changeturf = TRUE)
	if(!viewer)
		return

	clear_preview(viewer.ckey)
	previews[viewer.ckey] = preview.images
	viewer.images += preview.images
	to_chat(viewer, SPAN_NOTICE("Previewing [insert["file"]] for [NIGHTMARE_PREVIEW_DURATION / (1 SECONDS)] seconds."))
	addtimer(CALLBACK(src, PROC_REF(clear_preview), viewer.ckey), NIGHTMARE_PREVIEW_DURATION, TIMER_UNIQUE|TIMER_OVERRIDE)

/datum/nightmare_menu/proc/clear_preview(ckey)
	var/list/images = previews[ckey]
	if(!images)
		return
	previews -= ckey
	var/client/viewer = GLOB.directory[ckey]
	viewer?.images -= images

/**
 * Reads an insert file like a map load would, but only makes images of what it would place
 *
 * Images use the type and var edits from the file, so atoms that build their look in Initialize(), like smoothed walls, show their map icon.
 */
/datum/parsed_map/nightmare_preview
	/// Images of the insert, on the turfs it would load onto
	var/list/image/images = list()

/datum/parsed_map/nightmare_preview/build_coordinate(list/model, turf/crds, no_changeturf as num, placeOnTop as num, new_z, delete)
	if(!crds)
		return
	var/list/members = model[1]
	var/list/members_attributes = model[2]

	var/image/tile = image('icons/effects/alphacolors.dmi', crds, "white", TURF_LAYER - 0.1)
	tile.plane = ABOVE_GAME_PLANE
	tile.color = "#00ff00"
	tile.alpha = 60
	tile.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	images += tile

	// The last member is the area, which has nothing to show
	for(var/index in 1 to length(members) - 1)
		var/atom/path = members[index]
		if(path == /turf/template_noop)
			continue
		var/list/attributes = members_attributes[index]
		var/image/preview = image(initial(path.icon), crds, initial(path.icon_state), initial(path.layer), initial(path.dir))
		preview.pixel_x = initial(path.pixel_x)
		preview.pixel_y = initial(path.pixel_y)
		preview.color = initial(path.color)
		preview.alpha = initial(path.alpha)
		var/invisibility = initial(path.invisibility)
		for(var/var_name in attributes)
			switch(var_name)
				if("icon")
					preview.icon = attributes[var_name]
				if("icon_state")
					preview.icon_state = attributes[var_name]
				if("dir")
					preview.dir = attributes[var_name]
				if("layer")
					preview.layer = attributes[var_name]
				if("pixel_x")
					preview.pixel_x = attributes[var_name]
				if("pixel_y")
					preview.pixel_y = attributes[var_name]
				if("color")
					preview.color = attributes[var_name]
				if("alpha")
					preview.alpha = attributes[var_name]
				if("invisibility")
					invisibility = attributes[var_name]
		if(!preview.icon || invisibility)
			continue
		preview.plane = ABOVE_GAME_PLANE
		preview.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		images += preview

#undef NIGHTMARE_PREVIEW_DURATION
