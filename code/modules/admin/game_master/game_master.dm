
/// Holds our active game_masters
GLOBAL_LIST_EMPTY(game_masters)

/// List of assoc lists that hold "object_name", "objective_info", and "object_ref". Name of the objective, any info typed about the objective, and then a reference to be resolved of the object for passing through TGUI
GLOBAL_LIST_EMPTY(game_master_objectives)

/// Percentage of characters end up clear when sent via radio message
GLOBAL_VAR_INIT(radio_communication_clarity, 100)

/proc/open_game_master_panel(client/using_client)
	set name = "Game Master Panel"
	set category = "Game Master"

	if(using_client.game_master_menu)
		using_client.game_master_menu.tgui_interact(using_client.mob)
		return

	using_client.game_master_menu = new /datum/game_master(using_client)

/client/proc/toggle_game_master()
	set name = "Game Master Panel"
	set category = "Game Master"
	if(!check_rights(R_ADMIN))
		return

	if(src)
		open_game_master_panel(src)

/client/proc/toggle_barricade_creation()
	set name = "Toggle Barricade Creation"
	set category = "Game Master.Flags"

	if(!check_rights(R_ADMIN))
		return

	if(!SSticker.mode)
		to_chat(usr, SPAN_WARNING("A mode hasn't been selected yet!"))
		return

	SSticker.mode.toggleable_flags ^= MODE_NO_MAKE_BARRICADES
	message_admins("[src] has [MODE_HAS_TOGGLEABLE_FLAG(MODE_NO_MAKE_BARRICADES) ? "disabled" : "enabled"] Barricade Creation.")

// Objective stuff
#define OBJECTIVE_NUMBER_OPTIONS list("zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine")
#define OBJECTIVE_COLOR_OPTIONS list("red", "purple", "blue")
#define OBJECTIVE_COLOR_OPTIONS_ASSOC list("red" = COLOR_RED, "purple" = COLOR_PURPLE, "blue" = COLOR_BLUE)

/// Types of click intercepts used by /datum/game_master variable current_click_intercept_action
#define OBJECTIVE_CLICK_INTERCEPT_ACTION "objective_click_intercept_action"
#define RECORD_CREATE_CLICK_INTERCEPT_ACTION "record_create_click_intercept_action"


/datum/game_master

	var/client/game_master_client

	/// Associated list of game master submenus organized by object_type = game_master_submenu
	var/list/submenu_types = list(
		/obj/structure/pipes/vents = /datum/game_master_submenu/ambush/vents,
		/obj/structure/tunnel = /datum/game_master_submenu/ambush/tunnels,
		/mob/living/carbon/human = /datum/game_master_submenu/infest,
	)

	/// List of current submenus
	var/list/current_submenus

	/// Holds what type of click intercept we are using
	var/current_click_intercept_action


	// Objective stuff

	/// If we are currently using the click intercept for the objective section
	var/objective_click_intercept = FALSE

	// Record stuff
	/// If we are currently using the click intercepts for record creation
	var/record_create_click_intercept = FALSE

	// Communication stuff

	/// The holder for the game master's virtual phone
	var/atom/movable/game_master_phone


/datum/game_master/New(client/using_client)
	. = ..()

	game_master_client = using_client

	tgui_interact(game_master_client.mob)

	current_submenus = list()

	game_master_phone = new(null)
	game_master_phone.AddComponent(/datum/component/phone/virtual, "Game Master", "white", "Company Command", null, PHONE_DND_ON, list(FACTION_MARINE, FACTION_COLONIST, FACTION_PMC, FACTION_TWE, FACTION_UPP), list(FACTION_MARINE, FACTION_COLONIST, FACTION_PMC, FACTION_TWE, FACTION_UPP), null, using_client)

	game_master_client.click_intercept = src

	for(var/datum/component/ai_behavior_override/override in GLOB.all_ai_behavior_overrides)
		game_master_client.images += override.behavior_image

	GLOB.game_masters |= game_master_client

/datum/game_master/Destroy(force, ...)
	. = ..()
	submenu_types = null
	current_submenus = null
	QDEL_NULL(game_master_phone)

	for(var/datum/component/ai_behavior_override/override in GLOB.all_ai_behavior_overrides)
		game_master_client.images -= override.behavior_image

	GLOB.game_masters -= game_master_client

/datum/game_master/ui_data(mob/user)
	. = ..()

	var/list/data = list()

	// Objective stuff
	data["objective_click_intercept"] = objective_click_intercept
	data["game_master_objectives"] = length(GLOB.game_master_objectives) ? GLOB.game_master_objectives : ""

	// Communication stuff
	data["radio_clarity"] = GLOB.radio_communication_clarity
	data["radio_clarity_example"] = stars("The quick brown fox jumped over the lazy dog.", GLOB.radio_communication_clarity)

	// Record stuff
	data["record_create_click_intercept"] = record_create_click_intercept

	return data

/datum/game_master/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	switch(action)

		//Spawn Section
		if("open_xeno_spawner")
			var/client/user_client = ui.user.client
			user_client?.open_xeno_ai_spawner_panel()
			return

		if("toggle_click_record_creation")
			if(record_create_click_intercept)
				reset_click_overrides()
				return

			reset_click_overrides()
			record_create_click_intercept = TRUE
			current_click_intercept_action = RECORD_CREATE_CLICK_INTERCEPT_ACTION
			ui.user.client?.click_intercept = src
			return

		//Objective Section
		if("toggle_click_objective")
			if(objective_click_intercept)
				reset_click_overrides()
				return

			reset_click_overrides()
			objective_click_intercept = TRUE
			current_click_intercept_action = OBJECTIVE_CLICK_INTERCEPT_ACTION
			ui.user.client?.click_intercept = src
			return

		if("jump_to")
			if(!params["val"])
				return

			var/list/objective = params["val"]

			var/atom/objective_atom = locate(objective["object_ref"])

			var/turf/objective_turf = get_turf(objective_atom)

			if(!objective_turf)
				return TRUE

			var/client/jumping_client = ui.user.client
			jumping_client.jump_to_turf(objective_turf)
			return TRUE

		if("remove_objective")
			if(!params["val"])
				return

			var/list/objective = params["val"]

			var/atom/objective_atom = locate(objective["object_ref"])

			if(!objective_atom)
				return TRUE

			if(tgui_alert(ui.user, "Do you want to remove [objective_atom] as an objective?", "Confirmation", list("Yes", "No")) != "Yes")
				return TRUE

			remove_objective(objective_atom)

		//Communication Section
		if("use_game_master_phone")
			game_master_phone.attack_hand(ui.user)

		if("set_radio_clarity")
			var/new_clarity = text2num(params["clarity"])
			if(!isnum(new_clarity))
				return

			GLOB.radio_communication_clarity = clamp(new_clarity, 0, 100)

/datum/game_master/ui_close(mob/user)
	. = ..()

	var/client/user_client = user.client
	if(user_client?.click_intercept == src)
		user_client.click_intercept = null

	reset_click_overrides()

	// The xeno spawner panel shows the same markers, leave them to it while it is open
	if(user_client?.xeno_spawn_menu && SStgui.get_open_ui(user, user_client.xeno_spawn_menu))
		return

	for(var/datum/component/ai_behavior_override/override in GLOB.all_ai_behavior_overrides)
		game_master_client.images -= override.behavior_image

/datum/game_master/ui_status(mob/user, datum/ui_state/state)
	return UI_INTERACTIVE

/datum/game_master/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GameMaster", "Game Master Menu")
		ui.open()

	user.client?.click_intercept = src

	for(var/datum/component/ai_behavior_override/override in GLOB.all_ai_behavior_overrides)
		game_master_client.images |= override.behavior_image

/datum/game_master/proc/InterceptClickOn(mob/user, params, atom/object)

	var/list/modifiers = params2list(params)

	switch(current_click_intercept_action)
		if(OBJECTIVE_CLICK_INTERCEPT_ACTION)
			var/turf/object_turf = get_turf(object)

			if(!object_turf)
				return TRUE

			if(SSminimaps.has_marker(object) || is_objective(object))
				if(tgui_alert(user, "Do you want to remove [object] as an objective?", "Confirmation", list("Yes", "No")) != "Yes")
					return TRUE

				remove_objective(object)
				return TRUE

			if(tgui_alert(user, "Do you want to make [object] an objective?", "Confirmation", list("Yes", "No")) != "Yes")
				return TRUE

			var/number_option = tgui_input_list(user, "Number on tacmap marker?", "Marker Number", OBJECTIVE_NUMBER_OPTIONS)
			if(!number_option)
				return TRUE

			var/color_option = tgui_input_list(user, "Color of tacmap marker?", "Marker Color", OBJECTIVE_COLOR_OPTIONS)
			if(!color_option)
				return TRUE

			color_option = OBJECTIVE_COLOR_OPTIONS_ASSOC[color_option]

			var/image/background = mutable_appearance('icons/ui_icons/map_blips.dmi', "background")
			background.color = color_option

			var/mutable_appearance/icon = image('icons/ui_icons/map_blips.dmi', icon_state = number_option)
			icon.appearance_flags = RESET_COLOR

			background.overlays += icon

			var/z_level = object_turf?.z

			if(!object || !z_level)
				return

			SSminimaps.add_marker(object, z_level, MINIMAP_FLAG_ALL, given_image = background)

			var/objective_info = tgui_input_text(user, "Objective info?", "Objective Info")

			var/object_ref = REF(object)

			RegisterSignal(object, COMSIG_PARENT_QDELETING, PROC_REF(remove_objective))

			GLOB.game_master_objectives += list(list(
				"object" = object,
				"object_name" = object.name,
				"objective_info" = (objective_info || ""),
				"object_ref" = object_ref,
				))
			return TRUE
		if(RECORD_CREATE_CLICK_INTERCEPT_ACTION)
			if(!ishuman(object))
				return FALSE
			var/mob/living/carbon/human/target = object
			GLOB.data_core.manifest_inject(target)
			to_chat(user, SPAN_NOTICE("Record created for [target.real_name]"))
			return TRUE
		else
			if(LAZYACCESS(modifiers, MIDDLE_CLICK))
				for(var/datum/game_master_submenu/submenu in current_submenus)
					if(submenu.referenced_atom == object)
						submenu.tgui_interact(user)
						return TRUE

				for(var/submenu_type in submenu_types)
					if(istype(object, submenu_type))
						var/new_submenu_type = submenu_types[submenu_type]
						current_submenus += new new_submenu_type(user, object)
						return TRUE

				return TRUE

/datum/game_master/proc/reset_click_overrides()
	objective_click_intercept = FALSE
	record_create_click_intercept = FALSE
	current_click_intercept_action = null

/datum/game_master/proc/is_objective(atom/checked_object)
	for(var/list/cycled_objective in GLOB.game_master_objectives)
		if(cycled_objective["object"] == checked_object)
			return TRUE

	return FALSE

/datum/game_master/proc/remove_objective(datum/removing_datum)
	SIGNAL_HANDLER

	for(var/list/cycled_objective in GLOB.game_master_objectives)
		if(cycled_objective["object"] == removing_datum)
			GLOB.game_master_objectives.Remove(list(cycled_objective))
			UnregisterSignal(removing_datum, COMSIG_PARENT_QDELETING)

	SSminimaps.remove_marker(removing_datum)


#undef OBJECTIVE_NUMBER_OPTIONS
#undef OBJECTIVE_COLOR_OPTIONS
#undef OBJECTIVE_COLOR_OPTIONS_ASSOC

#undef OBJECTIVE_CLICK_INTERCEPT_ACTION
#undef RECORD_CREATE_CLICK_INTERCEPT_ACTION
