/datum/admin_music_variant
	var/title = "Track 1"
	var/description = ""
	var/duration_seconds = 0
	var/source_url = ""

/datum/admin_music_variant/proc/copy()
	var/datum/admin_music_variant/copied_variant = new
	copied_variant.title = title
	copied_variant.description = description
	copied_variant.duration_seconds = duration_seconds
	copied_variant.source_url = source_url
	return copied_variant

/datum/admin_music_variant/proc/to_json_data()
	return list(
		"title" = title,
		"description" = description,
		"duration_seconds" = duration_seconds,
		"source_url" = source_url,
	)

/datum/admin_music_variant/proc/to_ui_data()
	return list(
		"variant_id" = REF(src),
		"title" = title,
		"description" = description,
		"duration_seconds" = duration_seconds,
		"source_url" = source_url,
	)

/datum/admin_music_tier
	var/name = "Scene 1"
	var/description = ""
	var/list/variants = list()

/datum/admin_music_tier/proc/copy()
	var/datum/admin_music_tier/copied_tier = new
	copied_tier.name = name
	copied_tier.description = description
	copied_tier.variants = list()
	for(var/datum/admin_music_variant/variant as anything in variants)
		copied_tier.variants += variant.copy()
	return copied_tier

/datum/admin_music_tier/proc/to_json_data()
	var/list/variants_data = list()
	for(var/datum/admin_music_variant/variant as anything in variants)
		variants_data += list(variant.to_json_data())
	return list(
		"name" = name,
		"description" = description,
		"variants" = variants_data,
	)

/datum/admin_music_tier/proc/to_ui_data()
	var/list/variants_data = list()
	for(var/datum/admin_music_variant/variant as anything in variants)
		variants_data += list(variant.to_ui_data())
	return list(
		"tier_id" = REF(src),
		"name" = name,
		"description" = description,
		"variants" = variants_data,
	)

/datum/admin_music_tier/proc/find_variant_by_ref(variant_ref)
	for(var/datum/admin_music_variant/variant as anything in variants)
		if(REF(variant) == variant_ref)
			return variant
	return null

/datum/admin_music_preset
	var/preset_id
	var/name = "New Preset"
	var/description = ""
	var/audience_mode = "global"
	var/sound_type = "atmospheric"
	var/show_title_to_players = TRUE
	var/repeat = FALSE
	var/list/tiers = list()

/datum/admin_music_preset/proc/copy()
	var/datum/admin_music_preset/copied_preset = new
	copied_preset.preset_id = preset_id
	copied_preset.name = name
	copied_preset.description = description
	copied_preset.audience_mode = audience_mode
	copied_preset.sound_type = sound_type
	copied_preset.show_title_to_players = show_title_to_players
	copied_preset.repeat = repeat
	copied_preset.tiers = list()
	for(var/datum/admin_music_tier/tier as anything in tiers)
		copied_preset.tiers += tier.copy()
	return copied_preset

/datum/admin_music_preset/proc/count_variants()
	. = 0
	for(var/datum/admin_music_tier/tier as anything in tiers)
		. += length(tier.variants)

/datum/admin_music_preset/proc/to_json_data()
	var/list/tiers_data = list()
	for(var/datum/admin_music_tier/tier as anything in tiers)
		tiers_data += list(tier.to_json_data())
	return list(
		"version" = 1,
		"name" = name,
		"description" = description,
		"playback" = list(
			"audience_mode" = audience_mode,
			"sound_type" = sound_type,
			"show_title_to_players" = show_title_to_players,
			"repeat" = repeat,
		),
		"tiers" = tiers_data,
	)

/datum/admin_music_preset/proc/to_ui_data()
	var/list/tiers_data = list()
	for(var/datum/admin_music_tier/tier as anything in tiers)
		tiers_data += list(tier.to_ui_data())
	return list(
		"preset_id" = preset_id,
		"name" = name,
		"description" = description,
		"playback" = list(
			"audience_mode" = audience_mode,
			"sound_type" = sound_type,
			"show_title_to_players" = show_title_to_players,
			"repeat" = repeat,
		),
		"tiers" = tiers_data,
	)

/datum/admin_music_preset/proc/build_library_summary()
	return list(
		"preset_id" = preset_id,
		"name" = name,
		"description" = description,
		"tier_count" = length(tiers),
		"variant_count" = count_variants(),
	)

/datum/admin_music_preset/proc/find_tier_by_ref(tier_ref)
	for(var/datum/admin_music_tier/tier as anything in tiers)
		if(REF(tier) == tier_ref)
			return tier
	return null
