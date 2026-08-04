/datum/loadout_picker/proc/get_origin_text(datum/gear/gear)
	var/list/origins = gear.allowed_origins
	if(!length(origins))
		return "Any faction"

	var/static/list/origin_groups = list( //yeah that's stupid but I don't want to see the entire list
		"USCM" = USCM_ORIGINS,
		"UPP" = UPP_ORIGINS,
		"TWE" = TWE_ORIGINS,
		"USCM, UPP & TWE" = FACTION_ORIGINS,
		"Non-USCM" = NON_USCM_ORIGINS,
		"Non-UPP" = NON_UPP_ORIGINS,
		"Non-TWE" = NON_TWE_ORIGINS,
	)

	for(var/label in origin_groups)
		var/list/group = origin_groups[label]
		if(length(group) != length(origins))
			continue

		var/matches = TRUE
		for(var/single_origin in origins)
			if(!(single_origin in group))
				matches = FALSE
				break

		if(matches)
			return label

	return english_list(origins, and_text = ", ")

/datum/loadout_picker/proc/get_gear_data(datum/gear/gear)
	return list(
		"name" = gear.display_name,
		"cost" = gear.cost,
		"desc" = initial(gear.path::desc),
		"origin" = get_origin_text(gear),
		"roles" = length(gear.allowed_roles) ? english_list(gear.allowed_roles, and_text = ", ") : null,
	)

/datum/loadout_picker/ui_static_data(mob/user)
	. = ..()

	.["categories"] = list()
	for(var/category in GLOB.gear_datums_by_category)
		var/list/datum/gear/gears = GLOB.gear_datums_by_category[category]

		var/items = list()

		for(var/gear_key as anything in gears)
			var/datum/gear/gear = gears[gear_key]
			items += list(get_gear_data(gear))

		.["categories"] += list(
			list("name" = category, "items" = items)
		)

	.["max_points"] = MAX_GEAR_COST

/datum/loadout_picker/ui_data(mob/user)
	. = ..()

	var/datum/preferences/prefs = user.client?.prefs
	if(!prefs)
		return

	var/points = 0

	.["loadout"] = list()

	for(var/item in prefs.gear)
		var/datum/gear/gear = GLOB.gear_datums_by_name[item]
		points += gear.cost

		.["loadout"] += list(get_gear_data(gear))

	.["points"] = points

/datum/loadout_picker/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	var/datum/preferences/prefs = ui.user.client?.prefs
	if(!prefs)
		return

	switch(action)
		if("add")
			var/datum/gear/gear = GLOB.gear_datums_by_name[params["name"]]
			if(!istype(gear))
				return

			var/total_cost = 0
			for(var/gear_name in prefs.gear)
				total_cost += GLOB.gear_datums_by_name[gear_name].cost

			total_cost += gear.cost
			if(total_cost > MAX_GEAR_COST)
				return

			prefs.gear += gear.display_name

		if("remove")
			var/datum/gear/gear = GLOB.gear_datums_by_name[params["name"]]
			if(!istype(gear))
				return

			prefs.gear -= gear.display_name

	prefs.ShowChoices(ui.user)
	return TRUE

/datum/loadout_picker/tgui_interact(mob/user, datum/tgui/ui)
	. = ..()

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "LoadoutPicker", "Loadout Picker")
		ui.open()
		ui.set_autoupdate(FALSE)

	winset(user, ui.window.id, "focus=true")

/datum/loadout_picker/ui_state(mob/user)
	return GLOB.always_state
