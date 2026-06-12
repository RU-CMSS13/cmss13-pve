/datum/admin_music_preset_library
	var/list/presets = list()
	var/library_loaded = FALSE

/datum/admin_music_preset_library/proc/reset_cache(as_loaded = FALSE)
	presets = list()
	library_loaded = as_loaded
	return TRUE

/datum/admin_music_preset_library/proc/build_default_variant()
	return new /datum/admin_music_variant

/datum/admin_music_preset_library/proc/build_default_tier()
	var/datum/admin_music_tier/tier = new
	tier.variants += build_default_variant()
	return tier

/datum/admin_music_preset_library/proc/build_default_preset()
	var/datum/admin_music_preset/preset = new
	preset.tiers += build_default_tier()
	return preset

/datum/admin_music_preset_library/proc/get_preset_path(preset_id)
	return "data/admin_sound_presets/[preset_id].json"

/datum/admin_music_preset_library/proc/build_export_path(client/requester, preset_name)
	var/export_name = sanitize_filename(trim(preset_name))
	var/requester_key = requester ? requester.ckey : "admin"
	if(!length(export_name))
		export_name = "admin_sound_preset"
	return "tmp/[requester_key]_[export_name]_[world.time].json"

/datum/admin_music_preset_library/proc/build_preset_slug(raw_name, fallback = "preset")
	var/slug = lowertext(trim(raw_name))
	slug = replacetext(slug, " ", "_")
	slug = sanitize_filename(slug)
	while(findtext(slug, "__"))
		slug = replacetext(slug, "__", "_")
	slug = trim(slug)
	if(!length(slug))
		return fallback
	return slug

/datum/admin_music_preset_library/proc/find_available_copy_name(base_name)
	var/base_trimmed = trim(base_name)
	if(!length(base_trimmed))
		base_trimmed = "New Preset"
	var/index = 2
	var/candidate_name = "[base_trimmed] ([index])"
	var/candidate_id = build_preset_slug(candidate_name)
	ensure_loaded()
	while(presets[candidate_id])
		index++
		candidate_name = "[base_trimmed] ([index])"
		candidate_id = build_preset_slug(candidate_name)
	return candidate_name

/datum/admin_music_preset_library/proc/ensure_loaded()
	if(library_loaded)
		return TRUE
	library_loaded = TRUE
	presets = list()

	var/static/regex/json_file_regex = regex("\\.json$", "i")
	var/list/file_names = flist("data/admin_sound_presets/")
	for(var/file_name as anything in file_names)
		if(findtext(file_name, "/", -1))
			continue
		if(!json_file_regex.Find(file_name))
			continue
		var/preset_id = replacetext(file_name, ".json", "")
		var/datum/admin_music_preset/preset = load_preset_from_file(get_preset_path(preset_id), preset_id)
		if(preset)
			presets[preset_id] = preset
	return TRUE

/datum/admin_music_preset_library/proc/load_preset_from_file(path, preset_id)
	var/raw_text = file2text(path)
	if(!length(raw_text))
		return null
	var/list/parse_result = parse_preset_json_text(raw_text, preset_id)
	if(!islist(parse_result) || !parse_result["preset"])
		var/list/error_messages = list("unknown parse failure")
		if(islist(parse_result) && islist(parse_result["errors"]) && length(parse_result["errors"]))
			error_messages = parse_result["errors"]
		log_world("admin_music_service failed to parse preset file [path]: [jointext(error_messages, "; ")]")
		return null
	return parse_result["preset"]

/datum/admin_music_preset_library/proc/parse_preset_json_text(json_text, preset_id_override = null)
	var/list/result = list("errors" = list())
	if(!istext(json_text) || !length(trim(json_text)))
		result["errors"] += "JSON text is empty."
		return result

	var/list/json_data
	try
		json_data = json_decode(json_text)
	catch(var/exception/decode_error)
		result["errors"] += "Failed to decode JSON: [decode_error]"
		return result

	if(!islist(json_data))
		result["errors"] += "Preset JSON root must be an object."
		return result

	var/version_raw = json_data["version"]
	var/version = text2num("[version_raw]")
	if(isnull(version_raw) || version != 1)
		result["errors"] += "Preset JSON version must be 1."
		return result

	var/datum/admin_music_preset/preset = preset_from_json_data(json_data, preset_id_override)
	if(!preset)
		result["errors"] += "Preset JSON could not be converted to a preset."
		return result

	var/list/errors = validate_preset(preset)
	if(length(errors))
		result["errors"] = errors
		return result

	result["preset"] = preset
	return result

/datum/admin_music_preset_library/proc/preset_from_json_data(list/json_data, preset_id_override = null)
	if(!islist(json_data))
		return null

	var/datum/admin_music_preset/preset = new
	preset.preset_id = preset_id_override
	preset.name = "[isnull(json_data["name"]) ? "" : json_data["name"]]"
	preset.description = "[isnull(json_data["description"]) ? "" : json_data["description"]]"

	var/list/playback = json_data["playback"]
	if(islist(playback))
		if(!isnull(playback["audience_mode"]))
			preset.audience_mode = "[playback["audience_mode"]]"
		if(!isnull(playback["sound_type"]))
			preset.sound_type = "[playback["sound_type"]]"
		if(!isnull(playback["show_title_to_players"]))
			preset.show_title_to_players = !!playback["show_title_to_players"]
		if(!isnull(playback["repeat"]))
			preset.repeat = !!playback["repeat"]

	preset.tiers = list()
	var/list/tiers_data = json_data["tiers"]
	if(islist(tiers_data))
		for(var/list/tier_data as anything in tiers_data)
			if(!islist(tier_data))
				continue
			var/datum/admin_music_tier/tier = new
			tier.name = "[isnull(tier_data["name"]) ? "" : tier_data["name"]]"
			tier.description = "[isnull(tier_data["description"]) ? "" : tier_data["description"]]"
			tier.variants = list()

			var/list/variants_data = tier_data["variants"]
			if(islist(variants_data))
				for(var/list/variant_data as anything in variants_data)
					if(!islist(variant_data))
						continue
					var/datum/admin_music_variant/variant = new
					variant.title = "[isnull(variant_data["title"]) ? "" : variant_data["title"]]"
					variant.description = "[isnull(variant_data["description"]) ? "" : variant_data["description"]]"
					variant.duration_seconds = max(round(text2num("[variant_data["duration_seconds"]]")), 0)
					variant.source_url = "[isnull(variant_data["source_url"]) ? "" : variant_data["source_url"]]"
					tier.variants += variant

			preset.tiers += tier

	return preset

/datum/admin_music_preset_library/proc/build_library_ui_data()
	ensure_loaded()
	var/list/library = list()
	for(var/preset_id in presets)
		var/datum/admin_music_preset/preset = presets[preset_id]
		library += list(preset.build_library_summary())
	return library

/datum/admin_music_preset_library/proc/find_preset(preset_id)
	ensure_loaded()
	return presets[preset_id]

/datum/admin_music_preset_library/proc/load_preset_copy(preset_id)
	var/datum/admin_music_preset/preset = find_preset(preset_id)
	if(!preset)
		return null
	return preset.copy()

/datum/admin_music_preset_library/proc/is_valid_audience_mode(audience_mode)
	return audience_mode in list("global", "xenos", "marines", "ghosts", "in_view", "single_mob")

/datum/admin_music_preset_library/proc/is_valid_sound_type(sound_type)
	return sound_type in list("atmospheric", "meme")

/datum/admin_music_preset_library/proc/validate_preset(datum/admin_music_preset/preset)
	var/list/errors = list()
	if(!preset)
		errors += "Preset is missing."
		return errors

	preset.name = trim("[preset.name]")
	preset.description = trim("[preset.description]")
	if(!length(preset.name))
		errors += "Preset name cannot be empty."

	if(!is_valid_audience_mode(preset.audience_mode))
		errors += "Preset audience mode is invalid."

	if(!is_valid_sound_type(preset.sound_type))
		errors += "Preset sound type is invalid."

	if(!length(preset.tiers))
		errors += "Preset must contain at least one tier."
		return errors

	var/list/seen_tier_names = list()
	for(var/datum/admin_music_tier/tier as anything in preset.tiers)
		tier.name = trim("[tier.name]")
		tier.description = trim("[tier.description]")
		if(!length(tier.name))
			errors += "Tier names cannot be empty."
		else
			var/tier_key = lowertext(tier.name)
			if(seen_tier_names[tier_key])
				errors += "Tier names must be unique."
			seen_tier_names[tier_key] = TRUE

		if(!length(tier.variants))
			errors += "Each tier must contain at least one variant."
			continue

		for(var/datum/admin_music_variant/variant as anything in tier.variants)
			variant.title = trim("[variant.title]")
			variant.description = trim("[variant.description]")
			variant.source_url = trim("[variant.source_url]")
			variant.duration_seconds = max(round(variant.duration_seconds), 0)

			if(!length(variant.title))
				errors += "Variant titles cannot be empty."
			if(!length(variant.source_url))
				errors += "Variant source URLs cannot be empty."
			else if(!findtext(variant.source_url, GLOB.is_http_protocol))
				errors += "Variant source URLs must use http or https."
	return errors

/datum/admin_music_preset_library/proc/validate_selected_variant(datum/admin_music_preset/preset, datum/admin_music_tier/tier, datum/admin_music_variant/variant)
	var/list/errors = list()
	if(!preset || !tier || !variant)
		errors += "No tier or variant is selected."
		return errors
	if(!is_valid_audience_mode(preset.audience_mode))
		errors += "Preset audience mode is invalid."
	if(!is_valid_sound_type(preset.sound_type))
		errors += "Preset sound type is invalid."
	variant.title = trim("[variant.title]")
	variant.description = trim("[variant.description]")
	variant.source_url = trim("[variant.source_url]")
	variant.duration_seconds = max(round(variant.duration_seconds), 0)
	if(!length(variant.title))
		errors += "Variant title cannot be empty."
	if(!length(variant.source_url))
		errors += "Variant source URL cannot be empty."
	else if(!findtext(variant.source_url, GLOB.is_http_protocol))
		errors += "Variant source URL must use http or https."
	return errors

/datum/admin_music_preset_library/proc/write_preset_to_disk(datum/admin_music_preset/preset)
	if(!preset || !length(preset.preset_id))
		return FALSE
	rustg_file_write(json_encode(preset.to_json_data()), get_preset_path(preset.preset_id))
	return TRUE

/datum/admin_music_preset_library/proc/cache_preset(datum/admin_music_preset/preset)
	if(!preset || !length(preset.preset_id))
		return FALSE
	ensure_loaded()
	presets[preset.preset_id] = preset
	return TRUE

/datum/admin_music_preset_library/proc/delete_preset(preset_id, delete_file = TRUE)
	if(!length(preset_id))
		return FALSE
	ensure_loaded()
	if(!presets[preset_id])
		return FALSE
	if(delete_file)
		fdel(get_preset_path(preset_id))
	presets -= preset_id
	return TRUE

/datum/admin_music_preset_library/proc/find_variant_by_trimmed_url(datum/admin_music_tier/tier, source_url)
	var/needle = trim(source_url)
	for(var/datum/admin_music_variant/variant as anything in tier.variants)
		if(trim(variant.source_url) == needle)
			return variant
	return null

/datum/admin_music_preset_library/proc/merge_imported_preset(datum/admin_music_preset/existing_preset, datum/admin_music_preset/imported_preset)
	if(!existing_preset || !imported_preset)
		return existing_preset
	var/list/tier_lookup = list()
	for(var/datum/admin_music_tier/existing_tier as anything in existing_preset.tiers)
		tier_lookup[lowertext(trim(existing_tier.name))] = existing_tier

	for(var/datum/admin_music_tier/imported_tier as anything in imported_preset.tiers)
		var/tier_key = lowertext(trim(imported_tier.name))
		var/datum/admin_music_tier/target_tier = tier_lookup[tier_key]
		if(!target_tier)
			target_tier = imported_tier.copy()
			existing_preset.tiers += target_tier
			tier_lookup[tier_key] = target_tier
			continue

		for(var/datum/admin_music_variant/imported_variant as anything in imported_tier.variants)
			if(find_variant_by_trimmed_url(target_tier, imported_variant.source_url))
				continue
			target_tier.variants += imported_variant.copy()
	return existing_preset
