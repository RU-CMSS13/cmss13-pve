/// Click intercept used by /datum/human_ai_management_menu to place patrol waypoints
#define PATROL_CLICK_INTERCEPT_ACTION "patrol_click_intercept_action"
/// How long a patrol waits at each of its waypoints
#define PATROL_WAYPOINT_WAIT (10 SECONDS)

/datum/human_ai_management_menu
	/// Holds what type of click intercept we are using
	var/current_click_intercept_action
	/// Waypoints of the patrol being placed
	var/list/turf/patrol_waypoints = list()
	/// Images marking patrol_waypoints for the game master
	var/list/image/waypoint_images = list()
	/// The client that sees waypoint_images
	var/client/waypoint_viewer

/datum/human_ai_management_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HumanAIManager", "Human AI Manager")
		ui.open()

/datum/human_ai_management_menu/ui_state(mob/user)
	return GLOB.admin_state

/datum/human_ai_management_menu/ui_close(mob/user)
	. = ..()
	current_click_intercept_action = null
	release_click_intercept(user)
	clear_waypoints()

/datum/human_ai_management_menu/ui_data(mob/user)
	var/list/data = list()

	data["placing_patrol"] = (user.client?.click_intercept == src) && (current_click_intercept_action == PATROL_CLICK_INTERCEPT_ACTION)
	data["patrol_waypoints"] = length(patrol_waypoints)

	data["ai_humans"] = list()
	for(var/datum/human_ai_brain/brain as anything in GLOB.human_ai_brains)
		var/mob/living/carbon/human/ai_human = brain.tied_human
		if(!ai_human || (ai_human.stat == DEAD))
			continue

		var/status = "Idle"
		if(ai_human.client)
			status = "Player"
		else if(brain.is_vehicle_crew_seated())
			status = "Crewing"
		else if(brain.is_manning_gun())
			status = "On gun"
		else if(brain.in_combat)
			status = "Fighting"
		else if(brain.hold_position)
			status = "Holding"
		else if(brain.quick_approach || brain.target_turf)
			status = "Moving"
		else if(istype(brain.current_order, /datum/ai_order/patrol))
			status = "Patrolling"

		data["ai_humans"] += list(list(
			"name" = ai_human.real_name,
			"ref" = REF(ai_human),
			"brain_ref" = REF(brain),
			"faction" = ai_human.faction,
			"health" = floor(ai_human.health / ai_human.maxHealth * 100),
			"status" = status,
			"squad_id" = brain.squad_id,
			"is_leader" = brain.is_squad_leader,
			"can_assign_squad" = brain.can_assign_squad,
			"area" = get_area_name(ai_human, TRUE),
		))

	data["squads"] = list()
	for(var/datum/human_ai_squad/squad as anything in SShuman_ai.squads)
		data["squads"] += list(list(
			"id" = squad.id,
			"name" = squad.name || "Squad #[squad.id]",
			"leader" = squad.squad_leader?.tied_human?.real_name,
			"order_ref" = squad.current_order ? REF(squad.current_order) : null,
			"members" = length(squad.ai_in_squad),
		))

	data["orders"] = list()
	for(var/datum/ai_order/order as anything in SShuman_ai.existing_orders)
		var/waypoint_count = 0
		if(istype(order, /datum/ai_order/patrol))
			var/datum/ai_order/patrol/patrol = order
			waypoint_count = length(patrol.waypoints)
		data["orders"] += list(list(
			"name" = order.name,
			"desc" = order.desc,
			"ref" = REF(order),
			"waypoints" = waypoint_count,
			"brains" = length(order.brains),
		))

	return data

/datum/human_ai_management_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("view_variables")
			var/datum/gotten_ref = locate(params["ref"])
			if(!istype(gotten_ref))
				return

			user.client?.debug_variables(gotten_ref)
			return TRUE

		if("jump_to")
			var/atom/movable/jump_target = locate(params["ref"])
			if(!istype(jump_target) || !get_turf(jump_target))
				return

			user.client?.jump_to_turf(get_turf(jump_target))
			return TRUE

		if("delete_ai")
			var/datum/human_ai_brain/brain = locate(params["brain_ref"]) in GLOB.human_ai_brains
			var/mob/living/carbon/human/ai_human = brain?.tied_human
			if(!ai_human || ai_human.client)
				return

			qdel(ai_human)
			return TRUE

		if("create_squad")
			SShuman_ai.create_new_squad()
			return TRUE

		if("rename_squad")
			var/datum/human_ai_squad/squad = SShuman_ai.get_squad("[params["squad"]]")
			if(!squad)
				return

			var/new_name = tgui_input_text(user, "Input the new name of the squad, only game masters see it", "Rename Squad", squad.name, MAX_NAME_LEN)
			if(!new_name || QDELETED(squad))
				return

			squad.name = new_name
			return TRUE

		if("disband_squad")
			var/datum/human_ai_squad/squad = SShuman_ai.get_squad("[params["squad"]]")
			if(!squad)
				return

			qdel(squad)
			return TRUE

		if("set_squad")
			var/datum/human_ai_brain/brain = locate(params["brain_ref"]) in GLOB.human_ai_brains
			if(!brain?.can_assign_squad)
				return

			var/new_squad_id = text2num(params["squad"])
			if(!new_squad_id)
				SShuman_ai.get_squad("[brain.squad_id]")?.remove_from_squad(brain)
				return TRUE

			var/datum/human_ai_squad/squad = SShuman_ai.get_squad("[new_squad_id]")
			if(!squad)
				return

			squad.add_to_squad(brain)
			if(!squad.squad_leader)
				squad.set_squad_leader(brain)
			return TRUE

		if("set_leader")
			var/datum/human_ai_brain/brain = locate(params["brain_ref"]) in GLOB.human_ai_brains
			var/datum/human_ai_squad/squad = SShuman_ai.get_squad("[brain?.squad_id]")
			if(!squad)
				return

			squad.set_squad_leader(brain)
			return TRUE

		if("set_squad_order")
			var/datum/human_ai_squad/squad = SShuman_ai.get_squad("[params["squad"]]")
			if(!squad)
				return

			var/datum/ai_order/order = locate(params["order"]) in SShuman_ai.existing_orders
			if(squad.current_order)
				squad.remove_current_order()
			if(order)
				squad.set_current_order(order)
			return TRUE

		if("delete_order")
			var/datum/ai_order/order = locate(params["ref"]) in SShuman_ai.existing_orders
			if(!order)
				return

			qdel(order)
			return TRUE

		if("toggle_patrol_placing")
			var/client/user_client = user.client
			if(!user_client)
				return

			if(current_click_intercept_action == PATROL_CLICK_INTERCEPT_ACTION && user_client.click_intercept == src)
				current_click_intercept_action = null
				release_click_intercept(user)
				return TRUE

			current_click_intercept_action = PATROL_CLICK_INTERCEPT_ACTION
			user_client.click_intercept = src
			return TRUE

		if("undo_waypoint")
			if(length(patrol_waypoints))
				remove_last_waypoint()
			return TRUE

		if("clear_waypoints")
			clear_waypoints()
			return TRUE

		if("create_patrol")
			if(!length(patrol_waypoints))
				return

			var/description = tgui_input_text(user, "Describe the patrol, only game masters see it.", "Patrol Description")
			if(!description || !length(patrol_waypoints))
				return

			var/datum/ai_order/patrol/patrol = new(list(patrol_waypoints.Copy(), PATROL_WAYPOINT_WAIT))
			patrol.desc = description
			clear_waypoints()
			current_click_intercept_action = null
			release_click_intercept(user)
			return TRUE

/// Stops intercepting clicks, handing them back to the game master panel if it is open
/datum/human_ai_management_menu/proc/release_click_intercept(mob/user)
	var/client/user_client = user.client
	if(user_client?.click_intercept != src)
		return

	user_client.click_intercept = null
	if(user_client.game_master_menu && SStgui.get_open_ui(user, user_client.game_master_menu))
		user_client.click_intercept = user_client.game_master_menu

/datum/human_ai_management_menu/proc/InterceptClickOn(mob/user, params, atom/object)
	if(current_click_intercept_action != PATROL_CLICK_INTERCEPT_ACTION)
		return FALSE

	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		remove_last_waypoint()
		return TRUE

	var/turf/waypoint = get_turf(object)
	if(!waypoint)
		return TRUE

	if(length(patrol_waypoints))
		var/turf/last_waypoint = patrol_waypoints[length(patrol_waypoints)]
		var/distance = get_dist(last_waypoint, waypoint)
		if((last_waypoint.z != waypoint.z) || (distance > HUMAN_AI_MAX_PATHFINDING_RANGE))
			to_chat(user, SPAN_WARNING("This waypoint is too far from the previous one, AI can walk at most [HUMAN_AI_MAX_PATHFINDING_RANGE] tiles between them."))
			return TRUE

	add_waypoint(user, waypoint)
	return TRUE

/datum/human_ai_management_menu/proc/add_waypoint(mob/user, turf/waypoint)
	if(waypoint_viewer != user.client)
		clear_waypoint_images()
		waypoint_viewer = user.client

	patrol_waypoints += waypoint
	var/image/waypoint_image = image('icons/turf/overlays.dmi', waypoint, "blueOverlay")
	waypoint_image.plane = ABOVE_LIGHTING_PLANE
	waypoint_image.maptext = MAPTEXT("<b>[length(patrol_waypoints)]</b>")
	waypoint_images += waypoint_image
	waypoint_viewer?.images += waypoint_image

/datum/human_ai_management_menu/proc/remove_last_waypoint()
	if(!length(patrol_waypoints))
		return

	patrol_waypoints.len--
	var/image/waypoint_image = waypoint_images[length(waypoint_images)]
	waypoint_images.len--
	waypoint_viewer?.images -= waypoint_image

/datum/human_ai_management_menu/proc/clear_waypoints()
	patrol_waypoints.Cut()
	clear_waypoint_images()

/datum/human_ai_management_menu/proc/clear_waypoint_images()
	waypoint_viewer?.images -= waypoint_images
	waypoint_images.Cut()
	waypoint_viewer = null

#undef PATROL_CLICK_INTERCEPT_ACTION
#undef PATROL_WAYPOINT_WAIT

/client/proc/open_human_ai_management_panel()
	set name = "Human AI Management Panel"
	set category = "Game Master.HumanAI"

	if(!check_rights(R_DEBUG))
		return

	if(human_ai_menu)
		human_ai_menu.tgui_interact(mob)
		return

	human_ai_menu = new /datum/human_ai_management_menu(src)
	human_ai_menu.tgui_interact(mob)

/client/proc/create_human_ai()
	set name = "Create Human AI - Expanded"
	set category = "Game Master.HumanAI"

	if(!check_rights(R_DEBUG))
		return

	if(!SSticker.mode)
		to_chat(src, SPAN_WARNING("The round hasn't started yet!"))
		return

	var/mob/living/carbon/human/ai_human = new()
	ai_human.AddComponent(/datum/component/human_ai)

	if(!cmd_admin_dress_human(ai_human, randomize = TRUE))
		qdel(ai_human)
		return

	ai_human.face_dir(mob.dir)
	ai_human.forceMove(get_turf(mob))
	ai_human.get_ai_brain().appraise_inventory(armor = TRUE)

/client/proc/make_human_ai(mob/living/carbon/human/mob in GLOB.human_mob_list)
	set name = "Make AI"
	set desc = "Add AI functionality to a human."
	set category = null

	if(!check_rights(R_DEBUG|R_ADMIN))
		return

	if(QDELETED(mob))
		return

	if(mob.GetComponent(/datum/component/human_ai))
		to_chat(usr, SPAN_WARNING("[mob] already has an assigned AI."))
		return

	if(mob.ckey && tgui_alert(mob, "This mob is being controlled by [mob.ckey]. Are you sure you wish to add AI to it?","Make AI", list("Yes","No")) != "Yes")
		return

	mob.AddComponent(/datum/component/human_ai)
	mob.get_ai_brain().appraise_inventory()

	message_admins("[key_name_admin(usr)] assigned an AI component to [mob.real_name].")

/client/proc/toggle_human_ai_tweaks()
	set name = "Toggle Human AI Tweaks"
	set category = "Game Master.Flags"

	if(!admin_holder || !check_rights(R_MOD, FALSE))
		return

	if(!SSticker.mode)
		to_chat(usr, SPAN_WARNING("A mode hasn't been selected yet!"))
		return

	SSticker.mode.toggleable_flags ^= MODE_HUMAN_AI_TWEAKS
	message_admins("[src] has [MODE_HAS_TOGGLEABLE_FLAG(MODE_HUMAN_AI_TWEAKS) ? "toggled Human AI tweaks on" : "toggled Human AI tweaks off"].")
/*
/client/proc/import_human_ai_preset_dictictonary()
	set name = "Import Human AI Presets Dictionary"
	set category = "Game Master.HumanAI"

	if(!admin_holder || !check_rights(R_MOD, FALSE))
		return

	var/dictionary_string = input(usr, "Choose a Human AI preset dictionary file.","Upload hAi_dictionary.txt") as null|file
	dictionary_string = file2text(dictionary_string)
	var/datum/human_ai_spawner_menu/the_beast
	the_beast.lazy_ui_data = json_decode(dictionary_string)
	for(var/faction_name in the_beast.lazy_ui_data)
		var/list/faction_list = the_beast.lazy_ui_data[faction_name]
		for(var/list/preset_data in faction_list)
			preset_data["path"] = text2path(preset_data["path"])
	the_beast = new()
*/
