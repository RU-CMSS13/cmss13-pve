GLOBAL_DATUM_INIT(admin_music_service, /datum/admin_music_service, new)

/datum/admin_music_session
	var/owner_ckey
	var/source_kind
	var/audience_mode
	var/sound_type
	var/show_title_to_players = TRUE
	var/list/tracked_clients = list()
	var/list/sequence_variants = list()
	var/source_url
	var/resolved_url
	var/resolved_title
	var/start_time
	var/end_time
	var/duration_seconds = 0
	var/loop = FALSE
	var/playback_mode = "single"
	var/preset_id
	var/preset_name
	var/tier_id
	var/tier_name
	var/variant_id
	var/variant_title
	var/variant_description
	var/must_send_assets = FALSE
	var/asset_name
	var/takeover = FALSE
	var/current_variant_index = 1
	var/advance_timer_id
	var/started_at_world_time = 0

/datum/admin_music_session/proc/to_ui_data()
	return list(
		"source_kind" = source_kind,
		"owner" = owner_ckey,
		"audience_mode" = audience_mode,
		"show_title_to_players" = show_title_to_players,
		"resolved_title" = resolved_title,
		"source_url" = source_url,
		"preset_id" = preset_id,
		"preset_name" = preset_name,
		"tier_name" = tier_name,
		"variant_title" = variant_title,
		"variant_description" = variant_description,
		"duration_seconds" = duration_seconds,
		"has_known_end_time" = isnum(end_time) && isnum(start_time) && end_time > start_time,
		"broadcast_elapsed_seconds" = started_at_world_time ? max(0, round((world.time - started_at_world_time) / 10)) : 0,
		"loop" = loop,
		"playback_mode" = playback_mode,
		"takeover" = takeover,
	)

/datum/admin_music_service
	var/datum/admin_music_preset_library/preset_library
	var/list/open_panels = list()
	var/datum/admin_music_session/active_session

/datum/admin_music_service/New()
	preset_library = new
	return ..()

/datum/admin_music_service/proc/register_panel(datum/admin_music_panel/panel)
	if(!panel)
		return FALSE
	if(!(panel in open_panels))
		open_panels += panel
	return TRUE

/datum/admin_music_service/proc/unregister_panel(datum/admin_music_panel/panel)
	open_panels -= panel
	return TRUE

/datum/admin_music_service/proc/update_open_panels()
	for(var/datum/admin_music_panel/panel as anything in open_panels.Copy())
		if(QDELETED(panel))
			open_panels -= panel
			continue
		SStgui.update_uis(panel)

/datum/admin_music_service/proc/build_default_variant()
	return preset_library.build_default_variant()

/datum/admin_music_service/proc/build_default_tier()
	return preset_library.build_default_tier()

/datum/admin_music_service/proc/build_default_preset()
	return preset_library.build_default_preset()

/datum/admin_music_service/proc/get_preset_path(preset_id)
	return preset_library.get_preset_path(preset_id)

/datum/admin_music_service/proc/build_export_path(client/requester, preset_name)
	return preset_library.build_export_path(requester, preset_name)

/datum/admin_music_service/proc/get_audience_options()
	return list(
		list("id" = "global", "label" = "Globally"),
		list("id" = "xenos", "label" = "Xenos"),
		list("id" = "marines", "label" = "Marines"),
		list("id" = "ghosts", "label" = "Ghosts"),
		list("id" = "in_view", "label" = "All In View Range"),
		list("id" = "single_mob", "label" = "Single Mob"),
	)

/datum/admin_music_service/proc/get_sound_type_options()
	return list(
		list("id" = "atmospheric", "label" = "Atmospheric"),
		list("id" = "meme", "label" = "Meme"),
	)

/datum/admin_music_service/proc/is_valid_playback_mode(playback_mode)
	return playback_mode in list("single", "ordered", "random")

/datum/admin_music_service/proc/get_audience_label(audience_mode)
	switch(audience_mode)
		if("global")
			return "Globally"
		if("xenos")
			return "Xenos"
		if("marines")
			return "Marines"
		if("ghosts")
			return "Ghosts"
		if("in_view")
			return "All In View Range"
		if("single_mob")
			return "Single Mob"
	return "Unknown"

/datum/admin_music_service/proc/get_sound_type_label(sound_type)
	switch(sound_type)
		if("atmospheric")
			return "Atmospheric"
		if("meme")
			return "Meme"
	return "Unknown"

/datum/admin_music_service/proc/get_sound_type_flag(sound_type)
	switch(sound_type)
		if("meme")
			return SOUND_ADMIN_MEME
		if("atmospheric")
			return SOUND_ADMIN_ATMOSPHERIC
	return SOUND_ADMIN_ATMOSPHERIC

/datum/admin_music_service/proc/get_playback_mode_label(playback_mode)
	switch(playback_mode)
		if("single")
			return "Single"
		if("random")
			return "Random"
		if("ordered")
			return "In order"
	return "Unknown"

/datum/admin_music_service/proc/resolve_effective_audience_mode(datum/admin_music_preset/preset, audience_mode_override)
	var/audience_mode = trim("[audience_mode_override]")
	if(length(audience_mode) && preset_library.is_valid_audience_mode(audience_mode))
		return audience_mode
	return preset?.audience_mode

/datum/admin_music_service/proc/resolve_effective_sound_type(datum/admin_music_preset/preset, sound_type_override)
	var/sound_type = trim("[sound_type_override]")
	if(length(sound_type) && preset_library.is_valid_sound_type(sound_type))
		return sound_type
	return preset?.sound_type

/datum/admin_music_service/proc/resolve_effective_boolean(raw_value, fallback = FALSE)
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

/datum/admin_music_service/proc/resolve_effective_playback_mode(playback_mode_override, fallback = "single")
	var/playback_mode = lowertext(trim("[playback_mode_override]"))
	if(length(playback_mode) && is_valid_playback_mode(playback_mode))
		return playback_mode
	if(is_valid_playback_mode(fallback))
		return fallback
	return "single"

/datum/admin_music_service/proc/build_session_ui_data()
	if(!active_session)
		return null
	var/list/data = active_session.to_ui_data()
	data["audience_label"] = get_audience_label(active_session.audience_mode)
	data["sound_type_label"] = get_sound_type_label(active_session.sound_type)
	data["playback_mode_label"] = get_playback_mode_label(active_session.playback_mode)
	return data

/datum/admin_music_service/proc/build_preset_slug(raw_name, fallback = "preset")
	return preset_library.build_preset_slug(raw_name, fallback)

/datum/admin_music_service/proc/find_available_copy_name(base_name)
	return preset_library.find_available_copy_name(base_name)

/datum/admin_music_service/proc/ensure_library_loaded()
	return preset_library.ensure_loaded()

/datum/admin_music_service/proc/load_preset_from_file(path, preset_id)
	return preset_library.load_preset_from_file(path, preset_id)

/datum/admin_music_service/proc/parse_preset_json_text(json_text, preset_id_override = null)
	return preset_library.parse_preset_json_text(json_text, preset_id_override)

/datum/admin_music_service/proc/preset_from_json_data(list/json_data, preset_id_override = null)
	return preset_library.preset_from_json_data(json_data, preset_id_override)

/datum/admin_music_service/proc/build_library_ui_data()
	return preset_library.build_library_ui_data()

/datum/admin_music_service/proc/find_preset(preset_id)
	return preset_library.find_preset(preset_id)

/datum/admin_music_service/proc/load_preset_copy(preset_id)
	return preset_library.load_preset_copy(preset_id)

/datum/admin_music_service/proc/validate_preset(datum/admin_music_preset/preset)
	return preset_library.validate_preset(preset)

/datum/admin_music_service/proc/validate_selected_variant(datum/admin_music_preset/preset, datum/admin_music_tier/tier, datum/admin_music_variant/variant)
	return preset_library.validate_selected_variant(preset, tier, variant)

/datum/admin_music_service/proc/notify_validation_errors(client/requester, list/errors)
	if(!requester || !islist(errors) || !length(errors))
		return FALSE
	to_chat(requester, SPAN_WARNING(jointext(errors, " ")))
	return TRUE

/datum/admin_music_service/proc/write_preset_to_disk(datum/admin_music_preset/preset)
	return preset_library.write_preset_to_disk(preset)

/datum/admin_music_service/proc/save_draft(client/requester, datum/admin_music_preset/draft, as_copy = FALSE, name_override = null)
	var/old_id = draft?.preset_id
	var/desired_name = isnull(name_override) ? draft?.name : trim("[name_override]")
	var/datum/admin_music_preset/saved_preset = draft?.copy()
	if(saved_preset)
		saved_preset.name = desired_name

	var/list/errors = validate_preset(saved_preset)
	if(length(errors))
		notify_validation_errors(requester, errors)
		return null

	ensure_library_loaded()
	if(as_copy)
		if(isnull(name_override))
			desired_name = find_available_copy_name(saved_preset.name)
			saved_preset.name = desired_name

	var/desired_id = build_preset_slug(saved_preset.name)
	if(!as_copy)
		if(length(old_id))
			if(old_id != desired_id && preset_library.find_preset(desired_id))
				to_chat(requester, SPAN_WARNING("A different preset already uses that name. Rename it or use Save As Copy."))
				return null
		else if(preset_library.find_preset(desired_id))
			to_chat(requester, SPAN_WARNING("A preset with that name already exists. Rename it or use Save As Copy."))
			return null
	else
		if(length(old_id) && old_id == desired_id)
			to_chat(requester, SPAN_WARNING("Save As must use a different preset name."))
			return null
		if(preset_library.find_preset(desired_id))
			to_chat(requester, SPAN_WARNING("A preset with that name already exists. Choose a different name for Save As."))
			return null

	saved_preset.preset_id = desired_id
	write_preset_to_disk(saved_preset)

	if(!as_copy && length(old_id) && old_id != desired_id)
		preset_library.delete_preset(old_id)

	preset_library.cache_preset(saved_preset)
	update_open_panels()
	log_preset_action(requester, as_copy ? "save_as_copy" : "save", saved_preset)
	return saved_preset.copy()

/datum/admin_music_service/proc/delete_preset(client/requester, preset_id)
	if(!length(preset_id))
		return FALSE
	var/datum/admin_music_preset/preset = find_preset(preset_id)
	if(!preset)
		return FALSE
	preset_library.delete_preset(preset_id)
	update_open_panels()
	log_preset_action(requester, "delete", preset)
	return TRUE

/datum/admin_music_service/proc/export_draft(client/requester, datum/admin_music_preset/draft)
	var/list/errors = validate_preset(draft)
	if(length(errors))
		notify_validation_errors(requester, errors)
		return FALSE
	if(requester && requester.file_spam_check())
		return FALSE
	var/export_path = build_export_path(requester, draft.name)
	rustg_file_write(json_encode(draft.to_json_data()), export_path)
	requester << ftp(file(export_path))
	log_preset_action(requester, "export", draft)
	return TRUE

/datum/admin_music_service/proc/find_variant_by_trimmed_url(datum/admin_music_tier/tier, source_url)
	return preset_library.find_variant_by_trimmed_url(tier, source_url)

/datum/admin_music_service/proc/merge_imported_preset(datum/admin_music_preset/existing_preset, datum/admin_music_preset/imported_preset)
	return preset_library.merge_imported_preset(existing_preset, imported_preset)

/datum/admin_music_service/proc/import_preset_text(client/requester, json_text)
	var/list/parse_result = parse_preset_json_text(json_text)
	var/list/errors = parse_result["errors"]
	if(length(errors))
		notify_validation_errors(requester, errors)
		return null

	var/datum/admin_music_preset/imported_preset = parse_result["preset"]
	ensure_library_loaded()
	var/import_target_id = build_preset_slug(imported_preset.name)
	var/datum/admin_music_preset/existing_preset = find_preset(import_target_id)
	if(existing_preset)
		var/choice = tgui_alert(requester, "A preset named \"[existing_preset.name]\" already exists. How should it be imported?", "Import Preset", list("Replace Preset", "Merge New Tracks", "Save As Copy", "Cancel"))
		switch(choice)
			if("Replace Preset")
				imported_preset.preset_id = existing_preset.preset_id
				write_preset_to_disk(imported_preset)
				preset_library.cache_preset(imported_preset.copy())
				update_open_panels()
				log_preset_action(requester, "import_replace", imported_preset)
				return imported_preset.copy()
			if("Merge New Tracks")
				var/datum/admin_music_preset/merged_preset = existing_preset.copy()
				merge_imported_preset(merged_preset, imported_preset)
				write_preset_to_disk(merged_preset)
				preset_library.cache_preset(merged_preset.copy())
				update_open_panels()
				log_preset_action(requester, "import_merge", merged_preset)
				return merged_preset.copy()
			if("Save As Copy")
				imported_preset.preset_id = null
				return save_draft(requester, imported_preset, TRUE)
			else
				return null

	imported_preset.preset_id = null
	return save_draft(requester, imported_preset, FALSE)

/datum/admin_music_service/proc/get_media_players()
	var/list/datum/internet_media/media_players = list()
	if(CONFIG_GET(string/invoke_youtubedl))
		media_players += new /datum/internet_media/yt_dlp
	if(CONFIG_GET(string/cobalt_base_api))
		media_players += new /datum/internet_media/cobalt
	return media_players

/datum/admin_music_service/proc/resolve_media(client/requester, source_url, quiet = FALSE)
	var/list/datum/internet_media/media_players = get_media_players()
	if(!length(media_players))
		if(!quiet && requester)
			to_chat(requester, SPAN_BOLDWARNING("Your server host has not set up any web media players."))
		return null

	var/datum/media_response/response
	for(var/datum/internet_media/player as anything in media_players)
		response = player.get_media(source_url)
		if(istype(response))
			break

	if(!istype(response))
		if(!quiet && requester)
			to_chat(requester, SPAN_BOLDWARNING("All configured web media players failed to provide a valid response:"))
			for(var/datum/internet_media/player as anything in media_players)
				to_chat(requester, SPAN_WARNING("[player.type] error: [player.error]"))
		return null

	if(!findtext(response.url, GLOB.is_http_protocol))
		if(!quiet && requester)
			to_chat(requester, SPAN_BOLDWARNING("BLOCKED: Content URL not using http(s) protocol"), confidential = TRUE)
			to_chat(requester, SPAN_WARNING("The media provider returned a content URL that isn't using the HTTP or HTTPS protocol"), confidential = TRUE)
		return null

	return response

/datum/admin_music_service/proc/resolve_target_clients(client/requester, audience_mode)
	var/list/targets = list()
	switch(audience_mode)
		if("global")
			targets = GLOB.mob_list
		if("xenos")
			targets = GLOB.xeno_mob_list + GLOB.dead_mob_list
		if("marines")
			targets = GLOB.human_mob_list + GLOB.dead_mob_list
		if("ghosts")
			targets = GLOB.observer_list + GLOB.dead_mob_list
		if("in_view")
			if(!requester?.mob)
				to_chat(requester, SPAN_WARNING("You need a mob to target people in view range."))
				return null
			var/list/atom/ranged_atoms = urange(requester.view, get_turf(requester.mob))
			for(var/mob/receiver in ranged_atoms)
				targets += receiver
		if("single_mob")
			var/list/mob/all_client_mobs = list()
			for(var/client/possible_client as anything in GLOB.clients)
				if(possible_client?.mob)
					all_client_mobs += possible_client.mob
			var/mob/choice = tgui_input_list(requester, "Select the mob to play to:", "Select Mob", all_client_mobs)
			if(!choice || QDELETED(choice))
				return null
			targets += choice
		else
			return null

	var/list/unique_clients = list()
	for(var/mob/target_mob as anything in targets)
		var/client/target_client = target_mob?.client
		if(target_client && !(target_client in unique_clients))
			unique_clients += target_client
	return unique_clients

/datum/admin_music_service/proc/filter_eligible_clients(list/target_clients, sound_type)
	var/list/eligible_clients = list()
	var/sound_flag = get_sound_type_flag(sound_type)
	for(var/client/target_client as anything in target_clients)
		if(!target_client?.prefs)
			continue
		if(!(target_client.prefs.toggles_sound & SOUND_MIDI))
			continue
		if(!(target_client.prefs.toggles_sound & sound_flag))
			continue
		eligible_clients += target_client
	return eligible_clients

/datum/admin_music_service/proc/build_music_payload(datum/admin_music_session/session)
	return list(
		"link" = session.show_title_to_players ? session.source_url : "Song Link Hidden",
		"title" = session.show_title_to_players ? session.resolved_title : "Admin sound",
		"start" = session.start_time,
		"end" = session.end_time,
		"loop" = session.loop,
	)

/datum/admin_music_service/proc/cancel_session_followup(datum/admin_music_session/session)
	if(!session?.advance_timer_id)
		return FALSE
	deltimer(session.advance_timer_id)
	session.advance_timer_id = null
	return TRUE

/datum/admin_music_service/proc/resolve_session_duration_seconds(datum/admin_music_variant/variant, datum/media_response/response)
	var/resolved_duration_seconds = resolve_media_duration_seconds(response)
	if(resolved_duration_seconds > 0)
		return resolved_duration_seconds
	if(variant)
		return max(0, variant.duration_seconds)
	return 0

/datum/admin_music_service/proc/resolve_media_duration_seconds(datum/media_response/response)
	if(response && isnum(response.end_time) && isnum(response.start_time) && response.end_time > response.start_time)
		return max(0, response.end_time - response.start_time)
	return 0

/datum/admin_music_service/proc/find_sequence_variant_index(list/sequence_variants, datum/admin_music_variant/variant)
	if(!islist(sequence_variants) || !length(sequence_variants) || !variant)
		return 1
	for(var/index in 1 to length(sequence_variants))
		var/datum/admin_music_variant/candidate = sequence_variants[index]
		if(!candidate)
			continue
		if(trim("[candidate.source_url]") == trim("[variant.source_url]") && trim("[candidate.title]") == trim("[variant.title]"))
			return index
	return 1

/datum/admin_music_service/proc/pick_next_sequence_index(datum/admin_music_session/session)
	var/variant_count = length(session?.sequence_variants)
	if(variant_count <= 1)
		return session?.current_variant_index || 1
	if(session.playback_mode == "random")
		var/list/candidate_indexes = list()
		for(var/index in 1 to variant_count)
			if(index != session.current_variant_index)
				candidate_indexes += index
		if(length(candidate_indexes))
			return pick(candidate_indexes)
		return session.current_variant_index
	return session.current_variant_index >= variant_count ? 1 : session.current_variant_index + 1

/datum/admin_music_service/proc/apply_panel_session_track(datum/admin_music_session/session, datum/admin_music_variant/variant, datum/media_response/response, variant_index)
	if(!session || !variant || !response)
		return FALSE
	session.source_url = variant.source_url
	session.resolved_url = response.url
	session.resolved_title = length(variant.title) ? variant.title : (response.title ? response.title : "Admin sound")
	session.start_time = response.start_time
	session.end_time = response.end_time
	session.duration_seconds = resolve_session_duration_seconds(variant, response)
	session.variant_id = REF(variant)
	session.variant_title = variant.title
	session.variant_description = variant.description
	session.current_variant_index = max(1, variant_index)
	return TRUE

/datum/admin_music_service/proc/get_session_followup_delay(datum/admin_music_session/session)
	var/duration_seconds = max(0, session?.duration_seconds || 0)
	if(duration_seconds <= 0)
		return 0
	return max(1, round(duration_seconds * 10) + 5)

/datum/admin_music_service/proc/get_session_followup_remaining_delay(datum/admin_music_session/session)
	var/followup_delay = get_session_followup_delay(session)
	if(followup_delay <= 0)
		return 0
	if(!session?.started_at_world_time)
		return followup_delay
	var/elapsed_ticks = max(0, world.time - session.started_at_world_time)
	return max(1, followup_delay - elapsed_ticks)

/datum/admin_music_service/proc/panel_session_requires_followup(datum/admin_music_session/session)
	if(!session || active_session != session || session.source_kind != "panel")
		return FALSE
	if(session.loop)
		return FALSE
	if(!is_valid_playback_mode(session.playback_mode))
		return FALSE
	if(session.playback_mode == "single")
		return TRUE
	return length(session.sequence_variants) > 1

/datum/admin_music_service/proc/get_panel_followup_warning(datum/admin_music_session/session)
	if(!session)
		return null
	if(session.playback_mode == "single")
		return "This track has no reliable duration, so single playback cannot auto-stop after it ends."
	return "This track has no reliable duration, so sequential playback cannot auto-advance after it ends."

/datum/admin_music_service/proc/schedule_panel_session_followup(datum/admin_music_session/session)
	cancel_session_followup(session)
	if(!panel_session_requires_followup(session))
		return FALSE
	var/followup_delay = get_session_followup_remaining_delay(session)
	if(followup_delay <= 0)
		return FALSE
	session.advance_timer_id = addtimer(CALLBACK(src, PROC_REF(handle_panel_session_followup), session), followup_delay, TIMER_STOPPABLE | TIMER_DELETE_ME)
	return TRUE

/datum/admin_music_service/proc/is_active_panel_session_for_variant(datum/admin_music_preset/preset, datum/admin_music_tier/tier, datum/admin_music_variant/variant)
	if(!active_session || active_session.source_kind != "panel" || !tier || !variant)
		return FALSE

	var/matches_by_preset = !!(
		length(active_session.preset_id) && \
		length(preset?.preset_id) && \
		active_session.preset_id == preset.preset_id && \
		active_session.tier_name == tier.name && \
		active_session.variant_title == variant.title
	)
	var/matches_by_source = !!(
		length(active_session.source_url) && \
		length(variant.source_url) && \
		active_session.source_url == variant.source_url
	)

	return matches_by_preset || matches_by_source

/datum/admin_music_service/proc/set_live_panel_playback_mode(client/requester, datum/admin_music_preset/preset, datum/admin_music_tier/tier, datum/admin_music_variant/variant, playback_mode_override)
	var/datum/admin_music_session/session = active_session
	if(!session || session.source_kind != "panel")
		if(requester)
			to_chat(requester, SPAN_WARNING("No live panel broadcast is active."))
		return FALSE
	if(!is_active_panel_session_for_variant(preset, tier, variant))
		if(requester)
			to_chat(requester, SPAN_WARNING("Select the track currently on air to change its live playback mode."))
		return FALSE

	var/effective_playback_mode = resolve_effective_playback_mode(playback_mode_override, session.playback_mode)
	if(session.playback_mode == effective_playback_mode)
		update_open_panels()
		return TRUE

	session.playback_mode = effective_playback_mode
	if(panel_session_requires_followup(session))
		if(!schedule_panel_session_followup(session))
			if(requester)
				to_chat(requester, SPAN_WARNING(get_panel_followup_warning(session)))
	else
		cancel_session_followup(session)

	log_session_action(requester, "live_playback_mode", session, FALSE)
	update_open_panels()
	return TRUE

/datum/admin_music_service/proc/log_session_action(client/requester, action, datum/admin_music_session/session, notify_admins = TRUE)
	if(!session)
		return FALSE
	var/requester_name = requester ? key_name(requester) : "[session.owner_ckey]"
	var/requester_name_admin = requester ? key_name_admin(requester) : "[session.owner_ckey]"
	var/preset_id = session.preset_id ? session.preset_id : "none"
	var/preset_name = session.preset_name ? session.preset_name : ""
	var/tier_name = session.tier_name ? session.tier_name : ""
	var/variant_title = session.variant_title ? session.variant_title : ""
	var/takeover_suffix = session.takeover ? " (takeover)" : ""
	var/message = "[requester_name] admin music [action]: source=[session.source_kind], audience=[get_audience_label(session.audience_mode)], sound_type=[get_sound_type_label(session.sound_type)], show_title=[session.show_title_to_players], source_url=[session.source_url], resolved_title=[session.resolved_title], preset=[preset_id]/\"[preset_name]\", tier=\"[tier_name]\", variant=\"[variant_title]\", loop=[session.loop], playback_mode=[session.playback_mode], takeover=[session.takeover]"
	log_admin(message)
	if(notify_admins)
		message_admins("[requester_name_admin] admin music [action]: [session.resolved_title] ([get_audience_label(session.audience_mode)])[takeover_suffix]")
	return TRUE

/datum/admin_music_service/proc/stop_session_clients(datum/admin_music_session/session, list/limit_to_clients = null)
	if(!session)
		return FALSE
	for(var/client/target_client as anything in session.tracked_clients)
		if(islist(limit_to_clients) && !(target_client in limit_to_clients))
			continue
		target_client?.tgui_panel?.stop_music()
	return TRUE

/datum/admin_music_service/proc/log_preset_action(client/requester, action, datum/admin_music_preset/preset)
	if(!requester || !preset)
		return FALSE
	var/preset_id = preset.preset_id ? preset.preset_id : "unsaved"
	var/message = "[key_name(requester)] admin music preset [action]: [preset_id] / [preset.name]"
	log_admin(message)
	message_admins("[key_name_admin(requester)] admin music preset [action]: [preset.name]")
	return TRUE

/datum/admin_music_service/proc/apply_session(client/requester, datum/admin_music_session/session, list/eligible_clients, switch_mode = FALSE, announce_play = TRUE)
	if(!session || !islist(eligible_clients) || !length(eligible_clients))
		return FALSE
	session.takeover = !!active_session && !switch_mode

	if(active_session)
		cancel_session_followup(active_session)
		if(switch_mode)
			var/list/leaving_clients = list()
			for(var/client/old_client as anything in active_session.tracked_clients)
				if(!(old_client in eligible_clients))
					leaving_clients += old_client
			stop_session_clients(active_session, leaving_clients)
		else
			stop_session_clients(active_session)

	var/list/music_payload = build_music_payload(session)
	for(var/client/target_client as anything in eligible_clients)
		if(session.must_send_assets)
			SSassets.transport.send_assets(target_client, session.asset_name)
		target_client?.tgui_panel?.play_music(session.resolved_url, music_payload)
		if(announce_play)
			to_chat(target_client, SPAN_BOLDANNOUNCE("An admin played: [music_payload["title"]]"), confidential = TRUE)

	session.tracked_clients = eligible_clients.Copy()
	session.started_at_world_time = world.time
	active_session = session
	update_open_panels()
	return TRUE

/datum/admin_music_service/proc/force_stop_all_clients()
	for(var/client/target_client as anything in GLOB.clients)
		target_client?.tgui_panel?.stop_music()
	return TRUE

/datum/admin_music_service/proc/stop_broadcast(client/requester, reason = "stop")
	if(!active_session)
		force_stop_all_clients()
		if(requester)
			log_admin("[key_name(requester)] admin music [reason]: forced global browser-audio stop with no tracked session.")
			message_admins("[key_name_admin(requester)] admin music [reason]: forced global browser-audio stop with no tracked session.")
		update_open_panels()
		return TRUE
	cancel_session_followup(active_session)
	stop_session_clients(active_session)
	log_session_action(requester, reason, active_session)
	active_session = null
	update_open_panels()
	return TRUE

/datum/admin_music_service/proc/stop_panel_session_automatic(datum/admin_music_session/session, reason = "auto_stop")
	if(!session || active_session != session)
		return FALSE
	cancel_session_followup(session)
	stop_session_clients(session)
	log_session_action(null, reason, session, FALSE)
	active_session = null
	update_open_panels()
	return TRUE

/datum/admin_music_service/proc/handle_panel_session_followup(datum/admin_music_session/session)
	if(!session || active_session != session)
		return FALSE
	session.advance_timer_id = null
	if(session.loop)
		return FALSE
	if(session.playback_mode == "single")
		return stop_panel_session_automatic(session, "auto_stop_end")
	var/list/eligible_clients = filter_eligible_clients(session.tracked_clients, session.sound_type)
	if(!length(eligible_clients))
		return stop_panel_session_automatic(session, "auto_stop_no_listeners")
	var/variant_count = length(session.sequence_variants)
	if(variant_count <= 1)
		return stop_panel_session_automatic(session, "auto_stop_end")
	var/next_index = session.current_variant_index
	for(var/attempt in 1 to variant_count)
		next_index = pick_next_sequence_index(session)
		var/datum/admin_music_variant/next_variant = session.sequence_variants[next_index]
		if(!next_variant)
			continue
		var/datum/media_response/response = resolve_media(null, next_variant.source_url, TRUE)
		if(!response)
			session.current_variant_index = next_index
			continue
		apply_panel_session_track(session, next_variant, response, next_index)
		if(!apply_session(null, session, eligible_clients, TRUE, FALSE))
			return stop_panel_session_automatic(session, "auto_stop_apply_failed")
		schedule_panel_session_followup(session)
		log_session_action(null, session.playback_mode == "random" ? "auto_random" : "auto_ordered", session, FALSE)
		return TRUE
	return stop_panel_session_automatic(session, "auto_stop_unresolved")

/datum/admin_music_service/proc/play_panel_variant(client/requester, datum/admin_music_preset/preset, datum/admin_music_tier/tier, datum/admin_music_variant/variant, audience_mode_override = null, sound_type_override = null, show_title_override = null, repeat_override = null, playback_mode_override = null)
	var/effective_audience_mode = resolve_effective_audience_mode(preset, audience_mode_override)
	var/effective_sound_type = resolve_effective_sound_type(preset, sound_type_override)
	var/effective_show_title = resolve_effective_boolean(show_title_override, preset?.show_title_to_players)
	var/effective_repeat = resolve_effective_boolean(repeat_override, preset?.repeat)
	var/effective_playback_mode = resolve_effective_playback_mode(playback_mode_override)

	var/datum/admin_music_preset/validation_preset = preset?.copy()
	if(validation_preset)
		validation_preset.audience_mode = effective_audience_mode
		validation_preset.sound_type = effective_sound_type
		validation_preset.show_title_to_players = effective_show_title
		validation_preset.repeat = effective_repeat

	var/list/errors = validate_selected_variant(validation_preset ? validation_preset : preset, tier, variant)
	if(length(errors))
		notify_validation_errors(requester, errors)
		return FALSE

	var/datum/media_response/response = resolve_media(requester, variant.source_url)
	if(!response)
		return FALSE

	var/list/target_clients = resolve_target_clients(requester, effective_audience_mode)
	if(!islist(target_clients))
		return FALSE

	var/list/eligible_clients = filter_eligible_clients(target_clients, effective_sound_type)
	if(!length(eligible_clients))
		to_chat(requester, SPAN_WARNING("No eligible listeners were found for this preset."))
		return FALSE

	var/datum/admin_music_session/session = new
	session.owner_ckey = requester.ckey
	session.source_kind = "panel"
	session.audience_mode = effective_audience_mode
	session.sound_type = effective_sound_type
	session.show_title_to_players = effective_show_title
	session.source_url = variant.source_url
	session.resolved_url = response.url
	session.resolved_title = length(variant.title) ? variant.title : (response.title ? response.title : "Admin sound")
	session.start_time = response.start_time
	session.end_time = response.end_time
	session.duration_seconds = resolve_session_duration_seconds(variant, response)
	session.loop = effective_repeat
	session.playback_mode = effective_playback_mode
	session.preset_id = preset.preset_id
	session.preset_name = preset.name
	session.tier_id = REF(tier)
	session.tier_name = tier.name
	session.variant_id = REF(variant)
	session.variant_title = variant.title
	session.variant_description = variant.description
	var/datum/admin_music_tier/sequence_tier = tier?.copy()
	if(sequence_tier)
		session.sequence_variants = sequence_tier.variants
	session.current_variant_index = find_sequence_variant_index(session.sequence_variants, variant)

	var/switch_mode = active_session && active_session.source_kind == "panel" && active_session.owner_ckey == requester.ckey && active_session.preset_id == preset.preset_id
	if(!apply_session(requester, session, eligible_clients, switch_mode))
		return FALSE
	if(panel_session_requires_followup(session))
		if(get_session_followup_delay(session) <= 0 && requester)
			to_chat(requester, SPAN_WARNING(get_panel_followup_warning(session)))
		else
			schedule_panel_session_followup(session)
	log_session_action(requester, switch_mode ? "switch_tier" : "play", session)
	return TRUE

/datum/admin_music_service/proc/prompt_legacy_request(client/requester)
	var/sound_mode = tgui_input_list(requester, "Play a sound from which source?", "Select Source", list("Upload", "Web"))
	if(!sound_mode)
		return null

	var/list/request = list(
		"must_send_assets" = FALSE,
		"asset_name" = null,
		"source_input" = null,
		"resolved_title" = null,
		"resolved_url" = null,
		"start_time" = null,
		"end_time" = null,
	)

	if(sound_mode == "Web")
		var/source_url = input(requester, "Enter content URL (supported sites only)", "Play Internet Sound") as text|null
		source_url = trim(source_url)
		if(!length(source_url))
			return null

		var/datum/media_response/response = resolve_media(requester, source_url)
		if(!response)
			return null

		request["source_input"] = source_url
		request["resolved_title"] = response.title
		request["resolved_url"] = response.url
		request["start_time"] = response.start_time
		request["end_time"] = response.end_time
	else
		var/current_transport = CONFIG_GET(string/asset_transport)
		if(!current_transport || current_transport == "simple")
			if(tgui_alert(requester.mob, "WARNING: Your server is using simple asset transport. Sounds will have to be sent directly to players, which may freeze the game for long durations. Are you SURE?", "Really play direct sound?", list("Yes", "No")) != "Yes")
				return null
			request["must_send_assets"] = TRUE

		var/soundfile = input(requester.mob, "Choose a sound file to play", "Upload Sound") as null|file
		if(!soundfile)
			return null

		var/static/regex/only_extension = regex(@{"^.*\.([a-z0-9]{1,5})$"}, "gi")
		var/extension = only_extension.Replace("[soundfile]", "$1")
		if(!length(extension))
			to_chat(requester, SPAN_WARNING("Invalid filename extension."))
			return null

		var/static/playsound_notch = 1
		var/asset_name = "admin_sound_[playsound_notch++].[extension]"
		SSassets.transport.register_asset(asset_name, soundfile)
		message_admins("[key_name_admin(requester)] uploaded admin sound '[soundfile]' to asset transport.")

		var/static/regex/remove_extension = regex(@{"\.[a-z0-9]+$"}, "gi")
		request["source_input"] = "[soundfile]"
		request["resolved_title"] = remove_extension.Replace("[soundfile]", "")
		request["resolved_url"] = SSassets.transport.get_asset_url(asset_name)
		request["asset_name"] = asset_name

	if(!length(trim("[request["resolved_title"]]")))
		request["resolved_title"] = tgui_input_text(requester, "What is the title of this media?", "Media Title")

	var/show_title_choice = tgui_alert(requester, "Show the name of this sound to the players?", "Sound Name", list("No", "Yes", "Cancel"))
	if(show_title_choice == "Cancel")
		return null
	request["show_title_to_players"] = show_title_choice == "Yes"

	var/audience_choice = tgui_input_list(requester, "Who do you want to play this to?", "Select Listeners", list("Globally", "Xenos", "Marines", "Ghosts", "All In View Range", "Single Mob"))
	if(!audience_choice)
		return null

	switch(audience_choice)
		if("Globally")
			request["audience_mode"] = "global"
		if("Xenos")
			request["audience_mode"] = "xenos"
		if("Marines")
			request["audience_mode"] = "marines"
		if("Ghosts")
			request["audience_mode"] = "ghosts"
		if("All In View Range")
			request["audience_mode"] = "in_view"
		if("Single Mob")
			request["audience_mode"] = "single_mob"
		else
			return null

	var/sound_type_choice = tgui_input_list(requester, "What kind of sound is this?", "Select Sound Type", list("Atmospheric", "Meme"))
	if(!sound_type_choice)
		return null
	request["sound_type"] = sound_type_choice == "Meme" ? "meme" : "atmospheric"
	return request

/datum/admin_music_service/proc/play_legacy_prompted(client/requester)
	var/list/request = prompt_legacy_request(requester)
	if(!islist(request))
		return FALSE

	var/list/target_clients = resolve_target_clients(requester, request["audience_mode"])
	if(!islist(target_clients))
		return FALSE

	var/list/eligible_clients = filter_eligible_clients(target_clients, request["sound_type"])
	if(!length(eligible_clients))
		to_chat(requester, SPAN_WARNING("No eligible listeners were found for this admin sound."))
		return FALSE

	var/datum/admin_music_session/session = new
	session.owner_ckey = requester.ckey
	session.source_kind = "legacy"
	session.audience_mode = request["audience_mode"]
	session.sound_type = request["sound_type"]
	session.show_title_to_players = request["show_title_to_players"]
	session.source_url = request["source_input"]
	session.resolved_url = request["resolved_url"]
	session.resolved_title = request["resolved_title"] ? request["resolved_title"] : "Admin sound"
	session.start_time = request["start_time"]
	session.end_time = request["end_time"]
	session.loop = FALSE
	session.must_send_assets = !!request["must_send_assets"]
	session.asset_name = request["asset_name"]

	if(!apply_session(requester, session, eligible_clients, FALSE))
		return FALSE
	log_session_action(requester, "legacy_play", session)
	return TRUE
