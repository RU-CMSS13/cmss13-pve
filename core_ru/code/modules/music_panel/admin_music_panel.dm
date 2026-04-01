/client/proc/open_admin_music_panel()
	set name = "Admin Music Panel"
	set category = "Admin.Fun"

	if(!check_rights(R_SOUNDS))
		return

	new /datum/admin_music_panel(src)

/datum/admin_music_panel
	var/client/holder
	var/datum/admin_music_preset/draft
	var/draft_token = 0
	var/dirty = FALSE
	var/selected_tier_id
	var/selected_variant_id
	var/list/preview_command
	var/preview_nonce = 0
	var/closing = FALSE

/datum/admin_music_panel/New(client/new_holder)
	holder = new_holder
	draft = GLOB.admin_music_service.build_default_preset()
	draft_token = 1
	. = ..()
	sync_selection()
	GLOB.admin_music_service.register_panel(src)
	if(holder && holder.mob)
		tgui_interact(holder.mob)

/datum/admin_music_panel/Destroy()
	GLOB.admin_music_service.unregister_panel(src)
	holder = null
	draft = null
	preview_command = null
	return ..()

/datum/admin_music_panel/proc/sync_selection()
	if(!draft)
		selected_tier_id = null
		selected_variant_id = null
		return

	var/datum/admin_music_tier/selected_tier = draft.find_tier_by_ref(selected_tier_id)
	if(!selected_tier && length(draft.tiers))
		selected_tier = draft.tiers[1]
		selected_tier_id = REF(selected_tier)

	var/datum/admin_music_variant/selected_variant = selected_tier?.find_variant_by_ref(selected_variant_id)
	if(!selected_variant && selected_tier && length(selected_tier.variants))
		selected_variant = selected_tier.variants[1]
		selected_variant_id = REF(selected_variant)

/datum/admin_music_panel/proc/get_selected_tier()
	sync_selection()
	return draft?.find_tier_by_ref(selected_tier_id)

/datum/admin_music_panel/proc/get_selected_variant()
	var/datum/admin_music_tier/tier = get_selected_tier()
	if(!tier)
		return null
	return tier.find_variant_by_ref(selected_variant_id)

/datum/admin_music_panel/proc/build_next_scene_name()
	var/index = 1
	var/list/used_names = list()
	for(var/datum/admin_music_tier/tier as anything in draft?.tiers)
		used_names[lowertext(trim("[tier.name]"))] = TRUE
	while(used_names[lowertext("Scene [index]")])
		index++
	return "Scene [index]"

/datum/admin_music_panel/proc/build_next_track_title(datum/admin_music_tier/tier)
	var/index = 1
	var/list/used_titles = list()
	for(var/datum/admin_music_variant/variant as anything in tier?.variants)
		used_titles[lowertext(trim("[variant.title]"))] = TRUE
	while(used_titles[lowertext("Track [index]")])
		index++
	return "Track [index]"

/datum/admin_music_panel/proc/mark_dirty()
	dirty = TRUE
	GLOB.admin_music_service.update_open_panels()
	return TRUE

/datum/admin_music_panel/proc/load_draft(datum/admin_music_preset/new_draft, new_dirty = FALSE)
	draft = new_draft
	if(!draft)
		draft = GLOB.admin_music_service.build_default_preset()
	draft_token++
	dirty = new_dirty
	preview_command = null
	sync_selection()
	GLOB.admin_music_service.update_open_panels()
	return TRUE

/datum/admin_music_panel/proc/confirm_discard_changes(message, title = "Unsaved Changes")
	if(!dirty)
		return TRUE
	var/target = holder
	if(holder && holder.mob)
		target = holder.mob
	return tgui_alert(target, message, title, list("Discard Changes", "Cancel")) == "Discard Changes"

/datum/admin_music_panel/proc/request_close()
	if(closing)
		return FALSE
	if(dirty && !confirm_discard_changes("Discard unsaved Admin Music Panel changes and close the panel?"))
		return FALSE
	closing = TRUE
	qdel(src)
	return TRUE

/datum/admin_music_panel/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminMusicPanel", "Admin Music Panel")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/admin_music_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/admin_music_panel/ui_status(mob/user, datum/ui_state/state)
	if(!holder || !check_rights_for(holder, R_SOUNDS))
		return UI_CLOSE
	if(user != holder.mob)
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/admin_music_panel/ui_data(mob/user)
	sync_selection()
	return list(
		"library" = GLOB.admin_music_service.build_library_ui_data(),
		"draft" = draft?.to_ui_data(),
		"draft_token" = draft_token,
		"dirty" = dirty,
		"selected_tier_id" = selected_tier_id,
		"selected_variant_id" = selected_variant_id,
		"can_delete_saved_preset" = !!(draft?.preset_id && GLOB.admin_music_service.find_preset(draft.preset_id)),
		"current_session" = GLOB.admin_music_service.build_session_ui_data(),
		"audience_options" = GLOB.admin_music_service.get_audience_options(),
		"sound_type_options" = GLOB.admin_music_service.get_sound_type_options(),
		"preview_command" = preview_command,
	)

/datum/admin_music_panel/ui_close(mob/user)
	if(closing)
		return
	qdel(src)

/datum/admin_music_panel/proc/set_preview_command(command, list/payload = null)
	preview_nonce++
	preview_command = list("nonce" = preview_nonce, "command" = command)
	if(islist(payload))
		for(var/key in payload)
			preview_command[key] = payload[key]
	return TRUE

/datum/admin_music_panel/proc/coerce_ui_boolean(raw_value, fallback = FALSE)
	if(isnull(raw_value))
		return fallback
	if(isnum(raw_value))
		return raw_value ? TRUE : FALSE
	var/text_value = lowertext(trim("[raw_value]"))
	if(text_value in list("1", "true", "yes", "on"))
		return TRUE
	if(text_value in list("0", "false", "no", "off"))
		return FALSE
	return fallback

/datum/admin_music_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!holder || !check_rights_for(holder, R_SOUNDS))
		return FALSE

	switch(action)
		if("request_close")
			return request_close()

		if("new_draft")
			if(!confirm_discard_changes("Discard the current draft and create a new preset?"))
				return FALSE
			return load_draft(GLOB.admin_music_service.build_default_preset(), FALSE)

		if("load_preset")
			if(!confirm_discard_changes("Discard the current draft and load a saved preset?"))
				return FALSE
			var/datum/admin_music_preset/loaded_preset = GLOB.admin_music_service.load_preset_copy(params["preset_id"])
			if(!loaded_preset)
				return FALSE
			return load_draft(loaded_preset, FALSE)

		if("save")
			var/datum/admin_music_preset/saved_preset = GLOB.admin_music_service.save_draft(holder, draft, FALSE)
			if(!saved_preset)
				return FALSE
			return load_draft(saved_preset, FALSE)

		if("save_as_copy")
			var/datum/admin_music_preset/copied_preset = GLOB.admin_music_service.save_draft(holder, draft, TRUE)
			if(!copied_preset)
				return FALSE
			return load_draft(copied_preset, FALSE)

		if("delete_preset")
			if(!draft?.preset_id)
				return FALSE
			var/delete_message = "Delete the saved preset \"[draft.name]\"?"
			if(dirty)
				delete_message = "Delete the saved preset \"[draft.name]\" and discard current draft changes?"
			var/delete_choice = tgui_alert(holder.mob, delete_message, "Delete Preset", list("Delete", "Cancel"))
			if(delete_choice != "Delete")
				return FALSE
			if(!GLOB.admin_music_service.delete_preset(holder, draft.preset_id))
				return FALSE
			return load_draft(GLOB.admin_music_service.build_default_preset(), FALSE)

		if("export_preset")
			return GLOB.admin_music_service.export_draft(holder, draft)

		if("import_json")
			if(!confirm_discard_changes("Discard the current draft and import a preset from JSON?"))
				return FALSE
			var/datum/admin_music_preset/imported_preset = GLOB.admin_music_service.import_preset_text(holder, params["json_text"])
			if(!imported_preset)
				return FALSE
			return load_draft(imported_preset, FALSE)

		if("set_name")
			draft.name = params["name"]
			return mark_dirty()

		if("set_description")
			draft.description = params["description"]
			return mark_dirty()

		if("set_audience_mode")
			draft.audience_mode = params["audience_mode"]
			return mark_dirty()

		if("set_sound_type")
			draft.sound_type = params["sound_type"]
			return mark_dirty()

		if("set_show_title")
			draft.show_title_to_players = coerce_ui_boolean(params["show_title_to_players"], draft.show_title_to_players)
			return mark_dirty()

		if("set_repeat")
			draft.repeat = coerce_ui_boolean(params["repeat"], draft.repeat)
			return mark_dirty()

		if("select_tier")
			if(selected_tier_id != params["tier_id"])
				selected_variant_id = null
			selected_tier_id = params["tier_id"]
			sync_selection()
			GLOB.admin_music_service.update_open_panels()
			return TRUE

		if("add_tier")
			var/datum/admin_music_tier/new_tier = GLOB.admin_music_service.build_default_tier()
			new_tier.name = build_next_scene_name()
			draft.tiers += new_tier
			selected_tier_id = REF(new_tier)
			selected_variant_id = null
			sync_selection()
			return mark_dirty()

		if("remove_tier")
			if(length(draft.tiers) <= 1)
				to_chat(holder, SPAN_WARNING("A preset must keep at least one scene."))
				return FALSE
			var/datum/admin_music_tier/tier_to_remove = draft.find_tier_by_ref(params["tier_id"])
			if(!tier_to_remove)
				return FALSE
			draft.tiers -= tier_to_remove
			if(selected_tier_id == params["tier_id"])
				selected_tier_id = null
				selected_variant_id = null
			sync_selection()
			return mark_dirty()

		if("set_tier_name")
			var/datum/admin_music_tier/named_tier = draft.find_tier_by_ref(params["tier_id"])
			if(!named_tier)
				return FALSE
			named_tier.name = params["name"]
			return mark_dirty()

		if("set_tier_description")
			var/datum/admin_music_tier/described_tier = draft.find_tier_by_ref(params["tier_id"])
			if(!described_tier)
				return FALSE
			described_tier.description = params["description"]
			return mark_dirty()

		if("select_variant")
			selected_tier_id = params["tier_id"]
			selected_variant_id = params["variant_id"]
			sync_selection()
			GLOB.admin_music_service.update_open_panels()
			return TRUE

		if("add_variant")
			var/datum/admin_music_tier/add_variant_tier = get_selected_tier()
			if(!add_variant_tier)
				return FALSE
			var/datum/admin_music_variant/new_variant = GLOB.admin_music_service.build_default_variant()
			new_variant.title = build_next_track_title(add_variant_tier)
			add_variant_tier.variants += new_variant
			selected_variant_id = REF(new_variant)
			sync_selection()
			return mark_dirty()

		if("remove_variant")
			var/datum/admin_music_tier/remove_variant_tier = get_selected_tier()
			if(!remove_variant_tier)
				return FALSE
			if(length(remove_variant_tier.variants) <= 1)
				to_chat(holder, SPAN_WARNING("A scene must keep at least one track."))
				return FALSE
			var/datum/admin_music_variant/variant_to_remove = remove_variant_tier.find_variant_by_ref(params["variant_id"])
			if(!variant_to_remove)
				return FALSE
			remove_variant_tier.variants -= variant_to_remove
			if(selected_variant_id == params["variant_id"])
				selected_variant_id = null
			sync_selection()
			return mark_dirty()

		if("set_variant_title")
			var/datum/admin_music_variant/titled_variant = get_selected_variant()
			if(!titled_variant)
				return FALSE
			titled_variant.title = params["title"]
			return mark_dirty()

		if("set_variant_description")
			var/datum/admin_music_variant/described_variant = get_selected_variant()
			if(!described_variant)
				return FALSE
			described_variant.description = params["description"]
			return mark_dirty()

		if("set_variant_duration")
			var/datum/admin_music_variant/duration_variant = get_selected_variant()
			if(!duration_variant)
				return FALSE
			duration_variant.duration_seconds = max(round(text2num("[params["duration_seconds"]]")), 0)
			return mark_dirty()

		if("set_variant_source_url")
			var/datum/admin_music_variant/source_variant = get_selected_variant()
			if(!source_variant)
				return FALSE
			source_variant.source_url = params["source_url"]
			return mark_dirty()

		if("preview_selected")
			var/datum/admin_music_tier/preview_tier = get_selected_tier()
			var/datum/admin_music_variant/preview_variant = get_selected_variant()
			var/list/errors = GLOB.admin_music_service.validate_selected_variant(draft, preview_tier, preview_variant)
			if(length(errors))
				GLOB.admin_music_service.notify_validation_errors(holder, errors)
				return FALSE
			var/datum/media_response/preview_response = GLOB.admin_music_service.resolve_media(holder, preview_variant.source_url)
			if(!preview_response)
				return FALSE
			set_preview_command("play", list(
				"title" = length(preview_variant.title) ? preview_variant.title : (preview_response.title ? preview_response.title : "Admin sound"),
				"url" = preview_response.url,
				"start" = preview_response.start_time,
				"end" = preview_response.end_time,
			))
			GLOB.admin_music_service.update_open_panels()
			return TRUE

		if("stop_preview")
			set_preview_command("stop")
			GLOB.admin_music_service.update_open_panels()
			return TRUE

		if("play_selected")
			var/datum/admin_music_tier/play_tier = get_selected_tier()
			var/datum/admin_music_variant/play_variant = get_selected_variant()
			return GLOB.admin_music_service.play_panel_variant(
				holder,
				draft,
				play_tier,
				play_variant,
				params["audience_mode"],
				params["sound_type"],
				params["show_title_to_players"],
				params["repeat"],
			)

		if("stop_broadcast")
			return GLOB.admin_music_service.stop_broadcast(holder, "panel_stop")

	return FALSE
