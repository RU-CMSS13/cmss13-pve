// Spawn stuff
#define HUMAN_AI_SPAWNER_TAB_INFANTRY "infantry"
#define HUMAN_AI_SPAWNER_TAB_SQUADS "squads"
#define HUMAN_AI_SPAWNER_TAB_VEHICLES "vehicles"
#define HUMAN_AI_SPAWNER_TAB_ORDERS "orders"
#define HUMAN_AI_SPAWNER_TABS list(HUMAN_AI_SPAWNER_TAB_INFANTRY, HUMAN_AI_SPAWNER_TAB_SQUADS, HUMAN_AI_SPAWNER_TAB_VEHICLES, HUMAN_AI_SPAWNER_TAB_ORDERS)

#define HUMAN_AI_SPAWNER_MODE_SINGLE "single"
#define HUMAN_AI_SPAWNER_MODE_SQUAD "squad"
#define HUMAN_AI_SPAWNER_MODE_NEST "nest"
#define HUMAN_AI_SPAWNER_MODE_SNIPER "sniper"
#define HUMAN_AI_SPAWNER_MODES list(HUMAN_AI_SPAWNER_MODE_SINGLE, HUMAN_AI_SPAWNER_MODE_SQUAD, HUMAN_AI_SPAWNER_MODE_NEST, HUMAN_AI_SPAWNER_MODE_SNIPER)

/// Category of the presets that game masters add during the round
#define HUMAN_AI_SPAWNER_CUSTOM_CATEGORY "Custom"
/// Faction and species option that keeps what the equipment preset gives
#define HUMAN_AI_SPAWNER_PRESET_DEFAULT "Preset default"

#define HUMAN_AI_SPAWNER_EQUIPMENT_FULL "Full Equipment"
#define HUMAN_AI_SPAWNER_EQUIPMENT_NO_WEAPONS "No Weapons"
#define HUMAN_AI_SPAWNER_EQUIPMENT_NAKED "Birthday Suit"
#define HUMAN_AI_SPAWNER_EQUIPMENT list(HUMAN_AI_SPAWNER_EQUIPMENT_FULL, HUMAN_AI_SPAWNER_EQUIPMENT_NO_WEAPONS, HUMAN_AI_SPAWNER_EQUIPMENT_NAKED)

/// Per preset, both in single mode and in a squad
#define HUMAN_AI_SPAWNER_MAX_COUNT 10
#define HUMAN_AI_SPAWNER_MAX_SQUAD_SIZE 20
#define HUMAN_AI_SPAWNER_DEFAULT_SQUAD_RADIUS 2
#define HUMAN_AI_SPAWNER_MAX_SQUAD_RADIUS 7
#define HUMAN_AI_SPAWNER_MAX_SPARE_AMMO 5
/// How far from their post snipers and machinegunners watch
#define HUMAN_AI_SPAWNER_MAX_SNIPER_RANGE 30

/// Mounted guns that MG nests are built around, by the name shown in the menu
#define HUMAN_AI_SPAWNER_NEST_GUNS list( \
	"M56D" = /obj/structure/machinery/m56d_hmg, \
	"M2C" = /obj/structure/machinery/m56d_hmg/auto, \
	"Scoped M56D nest" = /obj/structure/machinery/m56d_hmg/mg_turret, \
)

/// Presets made for MG nests and sniper posts, listed under these categories
#define HUMAN_AI_SPAWNER_POST_PRESETS list( \
	"Snipers" = list( \
		/datum/equipment_preset/clf/soldier/bolt, \
		/datum/equipment_preset/clf/soldier/svd, \
		/datum/equipment_preset/rebel/sniper, \
		/datum/equipment_preset/canc/remnant/marksman, \
		/datum/equipment_preset/canc/remnant/marksman/snowman, \
		/datum/equipment_preset/canc/remnant/marksman/type88, \
		/datum/equipment_preset/canc/remnant/marksman/type88/snowman, \
		/datum/equipment_preset/pmc/sniper, \
		/datum/equipment_preset/upp/sniper, \
		/datum/equipment_preset/uscm/specialist_equipped/sniper, \
		/datum/equipment_preset/other/freelancer/marksman, \
		/datum/equipment_preset/royal_marine/sniper/ai, \
		/datum/equipment_preset/colonist/security/guard/marksman, \
		/datum/equipment_preset/mercenary/sentinel/marksman, \
	), \
	"Machinegunners" = list( \
		/datum/equipment_preset/rebel/soldier, \
		/datum/equipment_preset/clf/soldier, \
		/datum/equipment_preset/canc/remnant, \
		/datum/equipment_preset/canc/newblood_machinegunner, \
		/datum/equipment_preset/canc/machinegunner, \
		/datum/equipment_preset/canc/remnant/snowman, \
		/datum/equipment_preset/canc/machinegunner/snowman, \
		/datum/equipment_preset/upp/machinegunner, \
		/datum/equipment_preset/contractor/duty/heavy, \
		/datum/equipment_preset/pmc/gunner, \
		/datum/equipment_preset/uscm/smartgunner_equipped, \
		/datum/equipment_preset/usa/gunner, \
		/datum/equipment_preset/usa/heavygunner, \
		/datum/equipment_preset/royal_marine/machinegun, \
		/datum/equipment_preset/contractor/covert/heavy, \
		/datum/equipment_preset/other/freelancer/machinegunner, \
		/datum/equipment_preset/other/elite_merc/heavy, \
		/datum/equipment_preset/rebel/soldier/machinegunner, \
		/datum/equipment_preset/clf/soldier/machinegunner, \
		/datum/equipment_preset/mercenary/sentinel/mg, \
	), \
)

/// The preset category a mode opens with the first time it is picked
#define HUMAN_AI_SPAWNER_MODE_CATEGORIES list(HUMAN_AI_SPAWNER_MODE_NEST = "Machinegunners", HUMAN_AI_SPAWNER_MODE_SNIPER = "Snipers")

/// Where MG nests and vehicles face when spawned, 0 being the way the game master faces
#define HUMAN_AI_SPAWNER_DIRECTIONS list("Your facing" = 0, "North" = NORTH, "East" = EAST, "South" = SOUTH, "West" = WEST)

/// Fully equipped vehicles by category, then by the name shown in the menu
#define HUMAN_AI_SPAWNER_VEHICLES list( \
	"USCM" = list( \
		"M34A2 Longstreet (LTB)" = /obj/effect/vehicle_spawner/tank/fixed, \
		"M34A2 Longstreet (minigun)" = /obj/effect/vehicle_spawner/tank/fixed/minigun, \
		"M34A2 Longstreet (flamer)" = /obj/effect/vehicle_spawner/tank/fixed/flamer, \
		"M34A2 Longstreet (autocannon)" = /obj/effect/vehicle_spawner/tank/fixed/autocannon, \
		"M34A2 Longstreet, desert (LTB)" = /obj/effect/vehicle_spawner/tank/desert/fixed, \
		"M34A2 Longstreet, desert (minigun)" = /obj/effect/vehicle_spawner/tank/desert/fixed/minigun, \
		"M34A2 Longstreet, desert (flamer)" = /obj/effect/vehicle_spawner/tank/desert/fixed/flamer, \
		"M34A2 Longstreet, desert (autocannon)" = /obj/effect/vehicle_spawner/tank/desert/fixed/autocannon, \
		"M34A2 Longstreet, jungle (LTB)" = /obj/effect/vehicle_spawner/tank/jungle/fixed, \
		"M34A2 Longstreet, jungle (minigun)" = /obj/effect/vehicle_spawner/tank/jungle/fixed/minigun, \
		"M34A2 Longstreet, jungle (flamer)" = /obj/effect/vehicle_spawner/tank/jungle/fixed/flamer, \
		"M34A2 Longstreet, jungle (autocannon)" = /obj/effect/vehicle_spawner/tank/jungle/fixed/autocannon, \
		"M34A2 Longstreet, night (LTB)" = /obj/effect/vehicle_spawner/tank/night/fixed, \
		"M34A2 Longstreet, night (minigun)" = /obj/effect/vehicle_spawner/tank/night/fixed/minigun, \
		"M34A2 Longstreet, night (flamer)" = /obj/effect/vehicle_spawner/tank/night/fixed/flamer, \
		"M34A2 Longstreet, night (autocannon)" = /obj/effect/vehicle_spawner/tank/night/fixed/autocannon, \
		"M34A3 Hampton command tank" = /obj/effect/vehicle_spawner/tank/command/fixed, \
		"M40 Ridgeway" = /obj/effect/vehicle_spawner/ridgeway/fixed, \
		"M40 Ridgeway (plasma)" = /obj/effect/vehicle_spawner/ridgeway/plasma, \
		"M577 APC" = /obj/effect/vehicle_spawner/apc/fixed, \
		"M577 APC (unarmed)" = /obj/effect/vehicle_spawner/apc/unarmed/fixed, \
		"M577-CMD APC" = /obj/effect/vehicle_spawner/apc_cmd/fixed, \
		"M577-MED APC" = /obj/effect/vehicle_spawner/apc_med/fixed, \
		"M577A3 APC" = /obj/effect/vehicle_spawner/apc_movie/fixed, \
		"M577A5 treatment vehicle" = /obj/effect/vehicle_spawner/apc_moviemed/fixed, \
		"M577A3E2 mobile gun system" = /obj/effect/vehicle_spawner/apc_wolfpack/plain, \
		"M579 air defence carrier" = /obj/effect/vehicle_spawner/apc_aa/fixed, \
		"M540 ARC" = /obj/effect/vehicle_spawner/arc/fixed, \
		"M540 ARC (weaponless)" = /obj/effect/vehicle_spawner/arc/weaponless/fixed, \
		"M34E1 Buckner AEV" = /obj/effect/vehicle_spawner/aev, \
		"M2420 JTMV" = /obj/effect/vehicle_spawner/humvee, \
		"M2420 JTMV (medical)" = /obj/effect/vehicle_spawner/humvee/medical, \
		"M2420 JTMV (transport)" = /obj/effect/vehicle_spawner/humvee/transport, \
	), \
	"UPP" = list( \
		"Cheetah 2A (cannon)" = /obj/effect/vehicle_spawner/upptank/fixed, \
		"Cheetah 2A (railgun)" = /obj/effect/vehicle_spawner/upptank/fixed/railgun, \
		"Cheetah 2A (sniper railgun)" = /obj/effect/vehicle_spawner/upptank/fixed/sniper_railgun, \
		"Cheetah 2A (TOW)" = /obj/effect/vehicle_spawner/upptank/fixed/tow, \
		"Cheetah 2A (no armor)" = /obj/effect/vehicle_spawner/upptank/fixed/non_armor, \
		"Cheetah 2B command tank" = /obj/effect/vehicle_spawner/upptank/command/fixed, \
		"ZSL-68 Pilgrim (minigun)" = /obj/effect/vehicle_spawner/apc/uppapc/minigun, \
		"ZSL-68 Pilgrim (minigun, HJ-35)" = /obj/effect/vehicle_spawner/apc/uppapc/minigunhj35, \
	), \
	"W-Y" = list( \
		"M577-WY APC" = /obj/effect/vehicle_spawner/apc_pmc/fixed, \
		"M577-WY APC (unarmed)" = /obj/effect/vehicle_spawner/apc_pmc/unarmed/fixed, \
	), \
	"TWE" = list( \
		"FV150 Hobelar" = /obj/effect/vehicle_spawner/twe_tank/fixed/armed, \
		"Type 200 Senshi" = /obj/effect/vehicle_spawner/twe_apc/fixed/armed, \
		"Type 200 Senshi command" = /obj/effect/vehicle_spawner/twe_apc/command/fixed/armed, \
	), \
)

/// Faction and crew picked when a vehicle of the category is selected
#define HUMAN_AI_SPAWNER_VEHICLE_DEFAULTS list( \
	"USCM" = list(FACTION_MARINE, /datum/equipment_preset/uscm/tank/ammo_rig), \
	"UPP" = list(FACTION_UPP, /datum/equipment_preset/upp/tank/ammo_rig), \
	"W-Y" = list(FACTION_PMC, /datum/equipment_preset/pmc/crewman), \
	"TWE" = list(FACTION_TWE, /datum/equipment_preset/other/tank), \
)

/// Equipment presets that can crew AI vehicles
#define HUMAN_AI_SPAWNER_VEHICLE_CREWS list( \
	/datum/equipment_preset/uscm/tank/ammo_rig, \
	/datum/equipment_preset/uscm/tank, \
	/datum/equipment_preset/upp/tank/ammo_rig, \
	/datum/equipment_preset/upp/tank, \
	/datum/equipment_preset/pmc/crewman, \
	/datum/equipment_preset/us_army/tank, \
	/datum/equipment_preset/usa/tank, \
	/datum/equipment_preset/other/tank, \
)

/// Types of click intercepts used by /datum/human_ai_spawner_menu variable current_click_intercept_action
#define SPAWN_CLICK_INTERCEPT_ACTION "spawn_click_intercept_action"
#define ORDER_CLICK_INTERCEPT_ACTION "order_click_intercept_action"

/client/proc/open_human_ai_spawner_panel()
	set name = "Create Human AI"
	set category = "Game Master.HumanAI"

	if(!check_rights(R_DEBUG))
		return

	open_human_ai_spawner_tab(HUMAN_AI_SPAWNER_TAB_INFANTRY)

/// Opens the human AI spawner on the given tab, creating it if needed
/client/proc/open_human_ai_spawner_tab(tab)
	if(!SSticker.mode)
		to_chat(src, SPAN_WARNING("The round hasn't started yet!"))
		return

	if(!human_spawn_menu)
		human_spawn_menu = new /datum/human_ai_spawner_menu()

	human_spawn_menu.set_tab(mob, tab)
	human_spawn_menu.tgui_interact(mob)

/datum/human_ai_spawner_menu
	/// Assoc list of category = list of preset data lists, shared by every game master
	var/static/list/preset_categories
	/// Assoc list of equipment preset path = data list of the preset
	var/static/list/presets_by_path
	/// Assoc list of squad category = list of squad data lists
	var/static/list/squad_categories
	/// Assoc list of vehicle spawner path = data list of the vehicle
	var/static/list/vehicles_by_path
	/// Vehicle categories as sent to the UI
	var/static/list/vehicle_ui_data
	/// Assoc list of crew preset path = name
	var/static/list/crew_presets

	/// Holds what type of click intercept we are using
	var/current_click_intercept_action
	/// The tab that is open
	var/tab = HUMAN_AI_SPAWNER_TAB_INFANTRY


	// Infantry stuff

	/// If a click spawns the selected preset, the whole squad or an MG nest manned by the selected preset
	var/mode = HUMAN_AI_SPAWNER_MODE_SINGLE

	/// The preset category shown in the infantry tab
	var/category

	/// Assoc list of mode = list(category, selected preset) it was left with, so every mode keeps its own like a tab. Squad mode shares single mode's
	var/list/mode_selections = list()

	/// The equipment preset path selected to be spawned in single and nest mode
	var/selected_preset

	/// The amount of humans to spawn in single mode
	var/spawn_count = 1

	/// The presets to spawn in squad mode, organized as preset path = amount
	var/list/squad = list()

	/// How far from the clicked turf the squad is spread
	var/squad_radius = HUMAN_AI_SPAWNER_DEFAULT_SQUAD_RADIUS

	/// The faction the humans are spawned into, or the one of their preset
	var/selected_faction = HUMAN_AI_SPAWNER_PRESET_DEFAULT

	/// The species the humans are turned into, or the one of their preset
	var/selected_species = HUMAN_AI_SPAWNER_PRESET_DEFAULT

	/// How much of their preset the humans are spawned with
	var/selected_equipment = HUMAN_AI_SPAWNER_EQUIPMENT_FULL

	/// If the spawned humans are AI
	var/spawn_ai = TRUE

	/// If the spawned humans drop in by parachute
	var/paradrop = FALSE

	/// If clicking a human dresses it in the preset instead of spawning a new one
	var/outfit = FALSE

	/// The name of the gun the MG nest is built around
	var/nest_gun = "M2C"

	/// How many spare ammo boxes are left behind the gun of an MG nest
	var/nest_spare_ammo = 2

	/// The name of the direction that MG nests and vehicles face
	var/spawn_direction = "Your facing"

	/// Where the next sniper stands, picked by the first click in sniper mode
	var/turf/sniper_post


	// Squad stuff

	/// The squad preset path selected to be spawned
	var/selected_squad


	// Vehicle stuff

	/// The vehicle spawner path selected to be spawned
	var/selected_vehicle

	/// The faction the vehicle AI fights for
	var/vehicle_faction = FACTION_MARINE

	/// The equipment preset of the vehicle crew
	var/vehicle_crew = /datum/equipment_preset/uscm/tank/ammo_rig

	/// If the vehicle is driven by AI
	var/vehicle_ai = TRUE

	/// If the vehicle AI never runs out of ammunition
	var/vehicle_infinite_ammo = FALSE

	/// If only the vehicle's faction can get in, like when its crew locks the doors
	var/vehicle_lock_doors = FALSE


	// Order stuff

	/// Brains of the human AI that orders are given to
	var/list/datum/human_ai_brain/selected_humans = list()

	/// Brains of the vehicle AI that orders are given to
	var/list/datum/vehicle_ai_brain/selected_vehicles = list()

	/// Assoc list of selected brain = image marking its body for the game master
	var/list/selection_images = list()

	/// The first corner of the area being selected
	var/turf/selection_corner

	/// Marks selection_corner or sniper_post for the game master
	var/image/corner_image

	/// The client that sees corner_image
	var/client/corner_viewer

	/// The client that sees the selection images
	var/client/selection_viewer

/datum/human_ai_spawner_menu/New()
	. = ..()

	if(!preset_categories)
		setup_static_data()

	if(preset_categories[FACTION_MARINE])
		category = FACTION_MARINE
	else if(length(preset_categories))
		category = preset_categories[1]

/// Builds the preset, squad and vehicle lists shared by every game master
/datum/human_ai_spawner_menu/proc/setup_static_data()
	preset_categories = list()
	presets_by_path = list()
	for(var/datum/human_ai_equipment_preset/preset_type as anything in subtypesof(/datum/human_ai_equipment_preset))
		if(!preset_type::name || !preset_type::path)
			continue
		add_preset(preset_type::path, preset_type::faction, preset_type::name, preset_type::desc)

	// These can already be listed under their faction, so they skip add_preset()
	var/list/post_presets = HUMAN_AI_SPAWNER_POST_PRESETS
	for(var/post_category in post_presets)
		for(var/datum/equipment_preset/preset_path as anything in post_presets[post_category])
			var/list/listed_data = presets_by_path["[preset_path]"]
			var/list/preset_data = list(
				"name" = preset_path::name,
				"description" = listed_data ? listed_data["description"] : "Made for MG nests and sniper posts.",
				"path" = "[preset_path]",
				"category" = post_category,
			)
			LAZYADD(preset_categories[post_category], list(preset_data))
			if(!listed_data)
				presets_by_path["[preset_path]"] = preset_data

	squad_categories = list()
	for(var/datum/human_ai_squad_preset/squad_type as anything in subtypesof(/datum/human_ai_squad_preset))
		if(!squad_type::name)
			continue

		var/datum/human_ai_squad_preset/squad_preset = new squad_type()
		GLOB.human_ai_squad_presets["[squad_type]"] = squad_preset

		var/list/contents = list()
		for(var/datum/equipment_preset/equipment_path as anything in squad_preset.ai_to_spawn)
			contents += "[squad_preset.ai_to_spawn[equipment_path]]x [equipment_path::name]"

		LAZYADD(squad_categories[squad_preset.faction], list(list(
			"name" = squad_preset.name,
			"description" = squad_preset.desc,
			"path" = "[squad_type]",
			"contents" = contents,
		)))

	vehicles_by_path = list()
	vehicle_ui_data = list()
	var/list/vehicle_categories = HUMAN_AI_SPAWNER_VEHICLES
	for(var/vehicle_category in vehicle_categories)
		var/list/vehicles = list()
		for(var/vehicle_name in vehicle_categories[vehicle_category])
			var/vehicle_path = vehicle_categories[vehicle_category][vehicle_name]
			var/list/vehicle_data = list(
				"name" = vehicle_name,
				"path" = "[vehicle_path]",
				"category" = vehicle_category,
			)
			vehicles += list(vehicle_data)
			vehicles_by_path["[vehicle_path]"] = vehicle_data
		vehicle_ui_data += list(list(
			"name" = vehicle_category,
			"vehicles" = vehicles,
		))

	crew_presets = list()
	for(var/datum/equipment_preset/crew_type as anything in HUMAN_AI_SPAWNER_VEHICLE_CREWS)
		crew_presets["[crew_type]"] = crew_type::name

/// Adds an equipment preset to the presets shown in the infantry tab. Returns FALSE if it is already there
/datum/human_ai_spawner_menu/proc/add_preset(datum/equipment_preset/preset_path, category, name, desc)
	if(!ispath(preset_path, /datum/equipment_preset) || presets_by_path["[preset_path]"])
		return FALSE

	var/list/preset_data = list(
		"name" = name || preset_path::name,
		"description" = desc || "Added preset.",
		"path" = "[preset_path]",
		"category" = category,
	)
	LAZYADD(preset_categories[category], list(preset_data))
	presets_by_path["[preset_path]"] = preset_data
	return TRUE

/datum/human_ai_spawner_menu/proc/remove_preset(preset_path)
	var/list/preset_data = presets_by_path[preset_path]
	if(!preset_data)
		return

	var/preset_category = preset_data["category"]
	preset_categories[preset_category] -= list(preset_data)
	if(!length(preset_categories[preset_category]))
		preset_categories -= preset_category
	presets_by_path -= preset_path
	squad -= preset_path
	if(selected_preset == preset_path)
		selected_preset = null

/datum/human_ai_spawner_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HumanAISpawner", "Human AI Spawner")
		ui.open()

/datum/human_ai_spawner_menu/ui_state(mob/user)
	return GLOB.admin_state

/datum/human_ai_spawner_menu/ui_close(mob/user)
	. = ..()

	current_click_intercept_action = null
	release_click_intercept(user)
	selection_corner = null
	sniper_post = null
	update_corner_image()
	clear_selection()

/datum/human_ai_spawner_menu/ui_static_data(mob/user)
	var/list/data = list()

	data["preset_categories"] = list()
	for(var/preset_category in preset_categories)
		data["preset_categories"] += list(list(
			"name" = preset_category,
			"presets" = preset_categories[preset_category],
		))

	data["squad_categories"] = list()
	for(var/squad_category in squad_categories)
		data["squad_categories"] += list(list(
			"name" = squad_category,
			"squads" = squad_categories[squad_category],
		))

	data["vehicle_categories"] = vehicle_ui_data

	data["crew_presets"] = list()
	for(var/crew_path in crew_presets)
		data["crew_presets"] += list(list(
			"name" = crew_presets[crew_path],
			"path" = crew_path,
		))

	data["factions"] = FACTION_LIST_HUMANOID + "Normal Hive"
	data["vehicle_factions"] = list()
	for(var/faction_name in SShuman_ai.human_ai_factions)
		data["vehicle_factions"] += faction_name
	data["species"] = list(SPECIES_HUMAN, SPECIES_ZOMBIE) + SYNTH_TYPES
	data["equipment_options"] = HUMAN_AI_SPAWNER_EQUIPMENT
	data["nest_guns"] = list()
	for(var/gun_name in HUMAN_AI_SPAWNER_NEST_GUNS)
		data["nest_guns"] += gun_name
	data["directions"] = list()
	for(var/direction_name in HUMAN_AI_SPAWNER_DIRECTIONS)
		data["directions"] += direction_name
	data["preset_default"] = HUMAN_AI_SPAWNER_PRESET_DEFAULT
	data["custom_category"] = HUMAN_AI_SPAWNER_CUSTOM_CATEGORY
	data["max_count"] = HUMAN_AI_SPAWNER_MAX_COUNT
	data["max_squad_size"] = HUMAN_AI_SPAWNER_MAX_SQUAD_SIZE
	data["max_squad_radius"] = HUMAN_AI_SPAWNER_MAX_SQUAD_RADIUS
	data["max_spare_ammo"] = HUMAN_AI_SPAWNER_MAX_SPARE_AMMO
	data["max_sniper_range"] = HUMAN_AI_SPAWNER_MAX_SNIPER_RANGE

	return data

/datum/human_ai_spawner_menu/ui_data(mob/user)
	var/list/data = list()

	// Another panel can take the click intercept away from us at any time
	var/intercepting = user.client?.click_intercept == src

	data["tab"] = tab
	data["spawn_click_intercept"] = intercepting && current_click_intercept_action == SPAWN_CLICK_INTERCEPT_ACTION
	data["order_click_intercept"] = intercepting && current_click_intercept_action == ORDER_CLICK_INTERCEPT_ACTION

	// Infantry stuff
	data["mode"] = mode
	data["category"] = category
	data["selected_preset"] = selected_preset
	data["spawn_count"] = spawn_count
	data["squad"] = get_squad_ui_data()
	data["squad_radius"] = squad_radius
	data["selected_faction"] = selected_faction
	data["selected_species"] = selected_species
	data["selected_equipment"] = selected_equipment
	data["spawn_ai"] = spawn_ai
	data["paradrop"] = paradrop
	data["outfit"] = outfit
	data["nest_gun"] = nest_gun
	data["nest_spare_ammo"] = nest_spare_ammo
	data["spawn_direction"] = spawn_direction
	data["sniper_post"] = !!sniper_post
	data["zombie_random_helmet"] = GLOB.gm_set_zombie_random_helmet
	data["zombie_helmet_chance"] = GLOB.gm_set_zombie_helmet_chance
	data["zombie_delimb_multi"] = GLOB.gm_set_zombie_delimb_multi || 1
	data["zombie_disable_auto_clean"] = GLOB.gm_set_zombie_disable_auto_clean

	// Squad stuff
	data["selected_squad"] = selected_squad

	// Vehicle stuff
	data["selected_vehicle"] = selected_vehicle
	data["vehicle_faction"] = vehicle_faction
	data["vehicle_crew"] = "[vehicle_crew]"
	data["vehicle_ai"] = vehicle_ai
	data["vehicle_infinite_ammo"] = vehicle_infinite_ammo
	data["vehicle_lock_doors"] = vehicle_lock_doors

	// Order stuff
	data["selected_units"] = get_selection_ui_data()
	data["selecting_area"] = !!selection_corner

	return data

/// Returns the squad as a list of assoc lists that hold "path", "name" and "count"
/datum/human_ai_spawner_menu/proc/get_squad_ui_data()
	var/list/squad_data = list()
	for(var/preset_path in squad)
		var/list/preset_data = presets_by_path[preset_path]
		squad_data += list(list(
			"path" = preset_path,
			"name" = preset_data ? preset_data["name"] : preset_path,
			"count" = squad[preset_path],
		))

	return squad_data

/datum/human_ai_spawner_menu/proc/get_squad_size()
	. = 0
	for(var/preset_path in squad)
		. += squad[preset_path]

/datum/human_ai_spawner_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("set_tab")
			set_tab(user, params["tab"])
			return TRUE

		if("toggle_click_spawn")
			toggle_click_intercept(user, SPAWN_CLICK_INTERCEPT_ACTION)
			return TRUE

		//Infantry Section
		if("set_mode")
			var/new_mode = params["mode"]
			if(!(new_mode in HUMAN_AI_SPAWNER_MODES))
				return

			switch_mode(new_mode)
			return TRUE

		if("set_category")
			var/new_category = params["category"]
			if(!preset_categories[new_category])
				return

			category = new_category
			return TRUE

		if("select_preset")
			var/preset_path = params["path"]
			if(!presets_by_path[preset_path])
				return

			selected_preset = preset_path
			return TRUE

		if("set_spawn_count")
			var/new_count = text2num(params["count"])
			if(!isnum(new_count))
				return

			spawn_count = clamp(round(new_count), 1, HUMAN_AI_SPAWNER_MAX_COUNT)
			return TRUE

		if("set_squad_count")
			var/preset_path = params["path"]
			if(!presets_by_path[preset_path])
				return

			var/new_count = text2num(params["count"])
			if(!isnum(new_count))
				return

			var/free_slots = HUMAN_AI_SPAWNER_MAX_SQUAD_SIZE - get_squad_size() + squad[preset_path]
			new_count = clamp(round(new_count), 0, min(HUMAN_AI_SPAWNER_MAX_COUNT, free_slots))
			if(new_count)
				squad[preset_path] = new_count
			else
				squad -= preset_path
			return TRUE

		if("clear_squad")
			squad = list()
			return TRUE

		if("set_squad_radius")
			var/new_radius = text2num(params["radius"])
			if(!isnum(new_radius))
				return

			squad_radius = clamp(round(new_radius), 0, HUMAN_AI_SPAWNER_MAX_SQUAD_RADIUS)
			return TRUE

		if("set_faction")
			var/new_faction = params["faction"]
			if((new_faction != HUMAN_AI_SPAWNER_PRESET_DEFAULT) && !(new_faction in (FACTION_LIST_HUMANOID + "Normal Hive")))
				return

			selected_faction = new_faction
			return TRUE

		if("set_species")
			var/new_species = params["species"]
			if((new_species != HUMAN_AI_SPAWNER_PRESET_DEFAULT) && !(new_species in (list(SPECIES_HUMAN, SPECIES_ZOMBIE) + SYNTH_TYPES)))
				return

			selected_species = new_species
			return TRUE

		if("set_equipment")
			var/new_equipment = params["equipment"]
			if(!(new_equipment in HUMAN_AI_SPAWNER_EQUIPMENT))
				return

			selected_equipment = new_equipment
			return TRUE

		if("toggle_spawn_ai")
			spawn_ai = !spawn_ai
			return TRUE

		if("toggle_paradrop")
			paradrop = !paradrop
			return TRUE

		if("toggle_outfit")
			outfit = !outfit
			return TRUE

		if("set_nest_gun")
			var/new_gun = params["gun"]
			if(!(new_gun in HUMAN_AI_SPAWNER_NEST_GUNS))
				return

			nest_gun = new_gun
			return TRUE

		if("set_nest_spare_ammo")
			var/new_amount = text2num(params["amount"])
			if(!isnum(new_amount))
				return

			nest_spare_ammo = clamp(round(new_amount), 0, HUMAN_AI_SPAWNER_MAX_SPARE_AMMO)
			return TRUE

		if("set_direction")
			var/new_direction = params["direction"]
			if(!(new_direction in HUMAN_AI_SPAWNER_DIRECTIONS))
				return

			spawn_direction = new_direction
			return TRUE

		if("add_preset")
			var/preset_name = tgui_input_list(user, "Pick a preset to add.", "Add Preset", GLOB.gear_name_presets_list)
			var/datum/equipment_preset/preset = GLOB.gear_name_presets_list[preset_name]
			if(!preset)
				return

			if(!add_preset(preset.type, HUMAN_AI_SPAWNER_CUSTOM_CATEGORY))
				to_chat(user, SPAN_WARNING("[preset.name] is already in the list."))
				return

			category = HUMAN_AI_SPAWNER_CUSTOM_CATEGORY
			selected_preset = "[preset.type]"
			update_static_data_for_all_viewers()
			return TRUE

		if("remove_preset")
			var/preset_path = params["path"]
			var/list/preset_data = presets_by_path[preset_path]
			if(preset_data?["category"] != HUMAN_AI_SPAWNER_CUSTOM_CATEGORY)
				return

			remove_preset(preset_path)
			update_static_data_for_all_viewers()
			return TRUE

		if("toggle_zombie_random_helmet")
			GLOB.gm_set_zombie_random_helmet = !GLOB.gm_set_zombie_random_helmet
			return TRUE

		if("set_zombie_helmet_chance")
			var/new_chance = text2num(params["chance"])
			if(!isnum(new_chance))
				return

			GLOB.gm_set_zombie_helmet_chance = clamp(round(new_chance), 0, 100)
			return TRUE

		if("set_zombie_delimb_multi")
			var/new_multi = text2num(params["multi"])
			if(!isnum(new_multi))
				return

			// Anything below zero turns delimbing off
			GLOB.gm_set_zombie_delimb_multi = new_multi > 0 ? min(new_multi, 20) : -1
			return TRUE

		if("toggle_zombie_auto_clean")
			GLOB.gm_set_zombie_disable_auto_clean = !GLOB.gm_set_zombie_disable_auto_clean
			return TRUE

		if("delete_ai_in_view")
			if(tgui_alert(user, "Do you want to delete all human AI within your view range?", "Confirmation", list("Yes", "No")) != "Yes")
				return

			for(var/mob/living/carbon/human/viewed_human in view(user.client))
				if(!viewed_human.client && viewed_human.get_ai_brain())
					qdel(viewed_human)
			return TRUE

		if("delete_all_ai")
			if(tgui_alert(user, "Do you want to delete all human AI?", "Confirmation", list("Yes", "No")) != "Yes")
				return

			for(var/mob/living/carbon/human/ai_human as anything in GLOB.ai_humans)
				if(!ai_human.client)
					qdel(ai_human)
			return TRUE

		//Squad Section
		if("select_squad")
			var/squad_path = params["path"]
			if(!GLOB.human_ai_squad_presets[squad_path])
				return

			selected_squad = squad_path
			return TRUE

		//Vehicle Section
		if("select_vehicle")
			var/list/vehicle_data = vehicles_by_path[params["path"]]
			if(!vehicle_data)
				return

			selected_vehicle = vehicle_data["path"]
			var/list/category_defaults = HUMAN_AI_SPAWNER_VEHICLE_DEFAULTS
			var/list/defaults = category_defaults[vehicle_data["category"]]
			if(defaults)
				vehicle_faction = defaults[1]
				vehicle_crew = defaults[2]
			return TRUE

		if("set_vehicle_faction")
			var/new_faction = params["faction"]
			if(!SShuman_ai.human_ai_factions[new_faction])
				return

			vehicle_faction = new_faction
			return TRUE

		if("set_vehicle_crew")
			var/new_crew = params["crew"]
			if(!crew_presets[new_crew])
				return

			vehicle_crew = text2path(new_crew)
			return TRUE

		if("toggle_vehicle_ai")
			vehicle_ai = !vehicle_ai
			return TRUE

		if("toggle_vehicle_infinite_ammo")
			vehicle_infinite_ammo = !vehicle_infinite_ammo
			return TRUE

		if("toggle_vehicle_lock_doors")
			vehicle_lock_doors = !vehicle_lock_doors
			return TRUE

		//Order Section
		if("toggle_click_order")
			toggle_click_intercept(user, ORDER_CLICK_INTERCEPT_ACTION)
			return TRUE

		if("order_hold")
			order_hold(user, TRUE)
			return TRUE

		if("order_release")
			order_hold(user, FALSE)
			return TRUE

		if("order_stop")
			order_stop(user)
			return TRUE

		if("select_in_view")
			for(var/mob/living/carbon/human/viewed_human in view(user.client))
				var/datum/human_ai_brain/brain = viewed_human.get_ai_brain()
				if(brain && (viewed_human.stat != DEAD))
					select_unit(user, brain)
			for(var/obj/vehicle/multitile/viewed_vehicle in view(user.client))
				if(viewed_vehicle.ai_brain)
					select_unit(user, viewed_vehicle.ai_brain)
			return TRUE

		if("clear_selection")
			clear_selection()
			return TRUE

		if("deselect_unit")
			var/datum/unit_brain = locate(params["ref"]) in (selected_humans + selected_vehicles)
			if(unit_brain)
				deselect_unit(unit_brain)
			return TRUE

		if("jump_to_unit")
			var/datum/unit_brain = locate(params["ref"]) in (selected_humans + selected_vehicles)
			var/atom/unit = get_unit_body(unit_brain)
			if(unit)
				user.client?.jump_to_turf(get_turf(unit))
			return TRUE

/// Picks the mode, which comes back with the category and preset it was left with
/datum/human_ai_spawner_menu/proc/switch_mode(new_mode)
	var/old_key = get_mode_selection_key(mode)
	var/new_key = get_mode_selection_key(new_mode)
	mode = new_mode
	sniper_post = null
	update_corner_image()
	if(old_key == new_key)
		return

	mode_selections[old_key] = list(category, selected_preset)
	var/list/saved_selection = mode_selections[new_key]
	if(saved_selection)
		if(preset_categories[saved_selection[1]])
			category = saved_selection[1]
		selected_preset = presets_by_path[saved_selection[2]] ? saved_selection[2] : null
		return

	// The first time it opens the presets made for it
	var/list/mode_categories = HUMAN_AI_SPAWNER_MODE_CATEGORIES
	var/new_category = mode_categories[new_mode]
	if(!preset_categories[new_category])
		return
	category = new_category
	if(!category_has_preset(new_category, selected_preset))
		selected_preset = null

/// Squad mode shares its category and preset with single mode
/datum/human_ai_spawner_menu/proc/get_mode_selection_key(checked_mode)
	return (checked_mode == HUMAN_AI_SPAWNER_MODE_SQUAD) ? HUMAN_AI_SPAWNER_MODE_SINGLE : checked_mode

/datum/human_ai_spawner_menu/proc/category_has_preset(checked_category, preset_path)
	for(var/list/preset_data as anything in preset_categories[checked_category])
		if(preset_data["path"] == preset_path)
			return TRUE
	return FALSE

/// Opens the tab, dropping the click mode of the previous one
/datum/human_ai_spawner_menu/proc/set_tab(mob/user, new_tab)
	if(!(new_tab in HUMAN_AI_SPAWNER_TABS) || (new_tab == tab))
		return

	tab = new_tab
	current_click_intercept_action = null
	release_click_intercept(user)
	selection_corner = null
	sniper_post = null
	update_corner_image()

/// Turns the given click intercept on, or off if it is the one already in use
/datum/human_ai_spawner_menu/proc/toggle_click_intercept(mob/user, intercept_action)
	var/client/user_client = user.client
	if(!user_client)
		return

	selection_corner = null
	sniper_post = null
	update_corner_image()

	if(current_click_intercept_action == intercept_action && user_client.click_intercept == src)
		current_click_intercept_action = null
		release_click_intercept(user)
		return

	current_click_intercept_action = intercept_action
	user_client.click_intercept = src

/// Stops intercepting clicks, handing them back to the game master panel if it is open
/datum/human_ai_spawner_menu/proc/release_click_intercept(mob/user)
	var/client/user_client = user.client
	if(user_client?.click_intercept != src)
		return

	user_client.click_intercept = null
	if(user_client.game_master_menu && SStgui.get_open_ui(user, user_client.game_master_menu))
		user_client.click_intercept = user_client.game_master_menu

/datum/human_ai_spawner_menu/proc/InterceptClickOn(mob/user, params, atom/object)
	var/list/modifiers = params2list(params)

	switch(current_click_intercept_action)
		if(SPAWN_CLICK_INTERCEPT_ACTION)
			if(LAZYACCESS(modifiers, MIDDLE_CLICK))
				delete_clicked(object)
				return TRUE

			if(LAZYACCESS(modifiers, ALT_CLICK))
				if(ishuman(object))
					var/mob/living/carbon/human/clicked_human = object
					if(clicked_human.assigned_equipment_preset && add_preset(clicked_human.assigned_equipment_preset.type, HUMAN_AI_SPAWNER_CUSTOM_CATEGORY))
						to_chat(user, SPAN_NOTICE("Added [clicked_human.assigned_equipment_preset.name] to the custom presets."))
						update_static_data_for_all_viewers()
				return TRUE

			var/turf/spawn_turf = get_turf(object)
			if(!spawn_turf)
				return FALSE

			switch(tab)
				if(HUMAN_AI_SPAWNER_TAB_INFANTRY)
					spawn_infantry(user, object, spawn_turf)
				if(HUMAN_AI_SPAWNER_TAB_SQUADS)
					spawn_squad_preset(user, spawn_turf)
				if(HUMAN_AI_SPAWNER_TAB_VEHICLES)
					spawn_vehicle(user, spawn_turf)
			return TRUE

		if(ORDER_CLICK_INTERCEPT_ACTION)
			handle_order_click(user, modifiers, object)
			return TRUE

	return FALSE

/// Deletes a clicked human that no player controls, or a clicked AI vehicle
/datum/human_ai_spawner_menu/proc/delete_clicked(atom/object)
	if(ishuman(object))
		var/mob/living/carbon/human/clicked_human = object
		if(!clicked_human.ckey)
			qdel(clicked_human)
		return

	if(istype(object, /obj/vehicle/multitile))
		var/obj/vehicle/multitile/clicked_vehicle = object
		if(clicked_vehicle.ai_brain)
			qdel(clicked_vehicle)

/// Returns the direction spawned MG nests and vehicles face
/datum/human_ai_spawner_menu/proc/get_spawn_dir(mob/user)
	var/list/directions = HUMAN_AI_SPAWNER_DIRECTIONS
	var/direction = directions[spawn_direction]
	if(!direction)
		direction = (user.dir in GLOB.cardinals) ? user.dir : SOUTH
	return direction

/datum/human_ai_spawner_menu/proc/spawn_infantry(mob/user, atom/object, turf/spawn_turf)
	switch(mode)
		if(HUMAN_AI_SPAWNER_MODE_SINGLE)
			if(!selected_preset)
				to_chat(user, SPAN_WARNING("Pick a preset first."))
				return

			if(outfit)
				outfit_human(user, object)
				return

			var/list/turf/spawn_turfs = list(spawn_turf)
			if(spawn_count > 1)
				spawn_turfs = shuffle(get_squad_turfs(spawn_turf, 1))
				spawn_turfs -= spawn_turf
				spawn_turfs.Insert(1, spawn_turf)
			for(var/i in 1 to spawn_count)
				spawn_human(user, selected_preset, spawn_turfs[((i - 1) % length(spawn_turfs)) + 1])

		if(HUMAN_AI_SPAWNER_MODE_SQUAD)
			spawn_squad(user, spawn_turf)

		if(HUMAN_AI_SPAWNER_MODE_NEST)
			spawn_nest(user, spawn_turf)

		if(HUMAN_AI_SPAWNER_MODE_SNIPER)
			spawn_sniper(user, spawn_turf)

/// Spawns a human of the preset with the chosen options. Returns the human
/datum/human_ai_spawner_menu/proc/spawn_human(mob/user, preset_path, turf/spawn_turf, facing = user.dir)
	var/mob/living/carbon/human/new_human = new(spawn_turf)
	dress_human(new_human, preset_path, TRUE)
	new_human.face_dir(facing)
	if(paradrop)
		new_human.paradrop()

	if(spawn_ai)
		new_human.AddComponent(/datum/component/human_ai)
	return new_human

/// Dresses the human in the preset and applies the chosen faction, species and equipment
/datum/human_ai_spawner_menu/proc/dress_human(mob/living/carbon/human/dressed_human, preset_path, randomise)
	arm_equipment(dressed_human, text2path(preset_path), randomise, FALSE, mob_client = dressed_human.client)

	if(selected_species != HUMAN_AI_SPAWNER_PRESET_DEFAULT)
		set_species(dressed_human, selected_species)

	switch(selected_equipment)
		if(HUMAN_AI_SPAWNER_EQUIPMENT_NO_WEAPONS)
			dressed_human.strip_weapons()
		if(HUMAN_AI_SPAWNER_EQUIPMENT_NAKED)
			dressed_human.strip_all()

	if(selected_faction != HUMAN_AI_SPAWNER_PRESET_DEFAULT)
		dressed_human.set_faction(selected_faction)

/// Turns the human into the species, zombies drop their weapons and get what zombie presets get
/datum/human_ai_spawner_menu/proc/set_species(mob/living/carbon/human/changed_human, species_name)
	if(changed_human.species?.name == species_name)
		return

	if(species_name == SPECIES_ZOMBIE)
		changed_human.strip_weapons()
		// Claws go into the hands
		for(var/obj/item/held_item in list(changed_human.l_hand, changed_human.r_hand))
			qdel(held_item)
		QDEL_NULL(changed_human.head)
		QDEL_NULL(changed_human.gloves)
		QDEL_NULL(changed_human.glasses)
		QDEL_NULL(changed_human.wear_mask)

	changed_human.set_species(species_name)

	if(species_name == SPECIES_ZOMBIE)
		changed_human.zombie_delimb_chance_multi = GLOB.gm_set_zombie_delimb_multi
		changed_human.zombie_disable_auto_clean = GLOB.gm_set_zombie_disable_auto_clean
		if(GLOB.gm_set_zombie_random_helmet && prob(GLOB.gm_set_zombie_helmet_chance))
			changed_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/zombie(changed_human), WEAR_HEAD)

	if(issynth(changed_human))
		changed_human.set_skills(/datum/skills/synthetic)

/// Strips the clicked human and dresses it in the selected preset
/datum/human_ai_spawner_menu/proc/outfit_human(mob/user, atom/object)
	if(!ishuman(object))
		var/mob/living/carbon/clicked_mob = object
		if(!istype(clicked_mob))
			return
		object = clicked_mob.change_mob_type(/mob/living/carbon/human, null, null, TRUE, "Human")
		if(!ishuman(object))
			return

	var/mob/living/carbon/human/dressed_human = object
	for(var/obj/item/worn_item in dressed_human.get_equipped_items())
		qdel(worn_item)

	dress_human(dressed_human, selected_preset, FALSE)
	var/datum/human_ai_brain/brain = dressed_human.get_ai_brain()
	if(brain)
		brain.appraise_inventory()
	else if(spawn_ai && !dressed_human.ckey)
		dressed_human.AddComponent(/datum/component/human_ai)

/// Spawns the whole squad around the turf as one AI squad led by its first member
/datum/human_ai_spawner_menu/proc/spawn_squad(mob/user, turf/center)
	if(!length(squad))
		to_chat(user, SPAN_WARNING("The squad is empty, add some presets to it first."))
		return

	var/list/turf/spawn_turfs = shuffle(get_squad_turfs(center, squad_radius))
	var/list/humans = list()
	for(var/preset_path in squad)
		for(var/i in 1 to squad[preset_path])
			humans += spawn_human(user, preset_path, spawn_turfs[(length(humans) % length(spawn_turfs)) + 1])

	if(spawn_ai)
		make_ai_squad(humans)

/// Puts the AI humans into a new squad, the first one leading it
/datum/human_ai_spawner_menu/proc/make_ai_squad(list/mob/living/carbon/human/humans)
	var/datum/human_ai_squad/new_squad = SShuman_ai.create_new_squad()
	for(var/mob/living/carbon/human/squad_member as anything in humans)
		var/datum/human_ai_brain/brain = squad_member.get_ai_brain()
		if(!brain)
			continue

		new_squad.add_to_squad(brain)
		if(!new_squad.squad_leader)
			new_squad.set_squad_leader(brain)

/// Returns the turfs within radius of center that can be walked to from it, so nothing ends up behind a wall
/datum/human_ai_spawner_menu/proc/get_squad_turfs(turf/center, radius)
	var/list/turf/reachable_turfs = list(center)

	var/checked = 0
	while(checked < length(reachable_turfs))
		checked++
		var/turf/current_turf = reachable_turfs[checked]
		for(var/direction in GLOB.cardinals)
			var/turf/neighbor = get_step(current_turf, direction)
			if(!neighbor || get_dist(center, neighbor) > radius)
				continue
			if((neighbor in reachable_turfs) || is_blocked_turf(neighbor))
				continue
			reachable_turfs += neighbor

	return reachable_turfs

/// Builds a mounted gun facing the chosen direction with the selected preset manning it from behind
/datum/human_ai_spawner_menu/proc/spawn_nest(mob/user, turf/gun_turf)
	if(!selected_preset)
		to_chat(user, SPAN_WARNING("Pick a preset for the gunner first."))
		return

	var/direction = get_spawn_dir(user)
	var/turf/handles_turf = get_step(gun_turf, REVERSE_DIR(direction))
	if(is_blocked_turf(gun_turf) || !handles_turf || is_blocked_turf(handles_turf))
		to_chat(user, SPAN_WARNING("There is no room for the gun and its gunner there."))
		return

	var/list/nest_guns = HUMAN_AI_SPAWNER_NEST_GUNS
	var/gun_type = nest_guns[nest_gun]
	var/obj/structure/machinery/m56d_hmg/gun = new gun_type(gun_turf)
	gun.setDir(direction)
	gun.rounds = gun.rounds_max
	gun.update_icon()
	for(var/i in 1 to nest_spare_ammo)
		new gun.ammo_box_type(handles_turf)

	var/mob/living/carbon/human/gunner = spawn_human(user, selected_preset, handles_turf, direction)
	gunner.get_ai_brain()?.set_mounted_gun(gun)

/**
 * The first click picks the post the AI holds, the second one the center of the area it watches.
 * The AI then stays there facing that way with a long view, like a machinegunner or sniper nest.
 */
/datum/human_ai_spawner_menu/proc/spawn_sniper(mob/user, turf/clicked_turf)
	if(!selected_preset)
		to_chat(user, SPAN_WARNING("Pick a preset first."))
		return

	if(!sniper_post || (sniper_post.z != clicked_turf.z))
		if(is_blocked_turf(clicked_turf))
			to_chat(user, SPAN_WARNING("There is no room to stand there."))
			return
		sniper_post = clicked_turf
		update_corner_image(user)
		return

	// Clicking the post again picks another one
	if(clicked_turf == sniper_post)
		sniper_post = null
		update_corner_image()
		return

	var/distance = get_dist(sniper_post, clicked_turf)
	if(distance > HUMAN_AI_SPAWNER_MAX_SNIPER_RANGE)
		to_chat(user, SPAN_WARNING("That is [distance] tiles away from the post, the AI watches up to [HUMAN_AI_SPAWNER_MAX_SNIPER_RANGE] tiles."))
		return

	for(var/turf/line_turf as anything in get_line(sniper_post, clicked_turf))
		if(line_turf.density)
			to_chat(user, SPAN_WARNING("A wall is in the way, the AI could not see there."))
			return

	var/direction = get_cardinal_dir(sniper_post, clicked_turf)
	var/mob/living/carbon/human/new_human = spawn_human(user, selected_preset, sniper_post, direction)
	var/datum/human_ai_brain/brain = new_human.get_ai_brain()
	if(brain)
		// Both nests behave the same, but the one matching the gun reads better when viewing variables
		if(istype(brain.gun_data, /datum/firearm_appraisal/sniper) || istype(brain.gun_data, /datum/firearm_appraisal/boltaction))
			brain.sniper_home = sniper_post
			brain.sniper_dir = direction
		else
			brain.machinegunner_home = sniper_post
			brain.machinegunner_dir = direction

	sniper_post = null
	update_corner_image()

/datum/human_ai_spawner_menu/proc/spawn_squad_preset(mob/user, turf/spawn_turf)
	var/datum/human_ai_squad_preset/squad_preset = GLOB.human_ai_squad_presets[selected_squad]
	if(!squad_preset)
		to_chat(user, SPAN_WARNING("Pick a squad first."))
		return

	squad_preset.spawn_ai(spawn_turf, user)

/// Spawns the selected vehicle facing the chosen direction, crewed by AI if asked to
/datum/human_ai_spawner_menu/proc/spawn_vehicle(mob/user, turf/spawn_turf)
	if(!selected_vehicle)
		to_chat(user, SPAN_WARNING("Pick a vehicle first."))
		return

	var/vehicle_spawner_type = text2path(selected_vehicle)
	var/list/old_vehicles = GLOB.all_multi_vehicles.Copy()
	new vehicle_spawner_type(spawn_turf)

	// Spawners make their vehicle and delete themselves in Initialize()
	for(var/obj/vehicle/multitile/new_vehicle as anything in GLOB.all_multi_vehicles - old_vehicles)
		switch(get_spawn_dir(user))
			if(EAST)
				new_vehicle.try_rotate(90)
			if(WEST)
				new_vehicle.try_rotate(-90)
			if(NORTH)
				new_vehicle.try_rotate(90)
				new_vehicle.try_rotate(90)

		if(vehicle_ai)
			new_vehicle.enable_ai(vehicle_faction, vehicle_crew, vehicle_infinite_ammo, vehicle_lock_doors)

/datum/human_ai_spawner_menu/proc/handle_order_click(mob/user, list/modifiers, atom/object)
	var/turf/clicked_turf = get_turf(object)
	if(!clicked_turf)
		return

	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		order_move(user, clicked_turf, FALSE)
		return

	if(LAZYACCESS(modifiers, ALT_CLICK))
		order_move(user, clicked_turf, TRUE)
		return

	var/adding = LAZYACCESS(modifiers, SHIFT_CLICK)
	var/datum/clicked_brain = get_clicked_unit(object)
	if(clicked_brain)
		selection_corner = null
		update_corner_image()
		if(adding && ((clicked_brain in selected_humans) || (clicked_brain in selected_vehicles)))
			deselect_unit(clicked_brain)
			return

		if(!adding)
			clear_selection()
		select_unit(user, clicked_brain)
		return

	if(!selection_corner || (selection_corner.z != clicked_turf.z))
		selection_corner = clicked_turf
		update_corner_image(user)
		return

	if(!adding)
		clear_selection()
	select_area(user, selection_corner, clicked_turf)
	selection_corner = null
	update_corner_image()

/// Returns the brain of the human or vehicle AI that was clicked, if any
/datum/human_ai_spawner_menu/proc/get_clicked_unit(atom/object)
	if(ishuman(object))
		var/mob/living/carbon/human/clicked_human = object
		if(clicked_human.stat == DEAD)
			return
		return clicked_human.get_ai_brain()

	if(istype(object, /obj/vehicle/multitile))
		var/obj/vehicle/multitile/clicked_vehicle = object
		return clicked_vehicle.ai_brain

/// Returns the human or vehicle that the brain controls
/datum/human_ai_spawner_menu/proc/get_unit_body(datum/unit_brain)
	RETURN_TYPE(/atom/movable)
	if(istype(unit_brain, /datum/human_ai_brain))
		var/datum/human_ai_brain/human_brain = unit_brain
		return human_brain.tied_human

	if(istype(unit_brain, /datum/vehicle_ai_brain))
		var/datum/vehicle_ai_brain/vehicle_brain = unit_brain
		return vehicle_brain.vehicle

/datum/human_ai_spawner_menu/proc/select_area(mob/user, turf/corner_a, turf/corner_b)
	for(var/turf/area_turf as anything in block(corner_a, corner_b))
		for(var/mob/living/carbon/human/area_human in area_turf)
			if(area_human.stat == DEAD)
				continue
			var/datum/human_ai_brain/brain = area_human.get_ai_brain()
			if(brain)
				select_unit(user, brain)

	var/min_x = min(corner_a.x, corner_b.x)
	var/max_x = max(corner_a.x, corner_b.x)
	var/min_y = min(corner_a.y, corner_b.y)
	var/max_y = max(corner_a.y, corner_b.y)
	for(var/obj/vehicle/multitile/vehicle as anything in GLOB.all_multi_vehicles)
		if(!vehicle.ai_brain || (vehicle.z != corner_a.z))
			continue
		if(ISINRANGE(vehicle.x, min_x, max_x) && ISINRANGE(vehicle.y, min_y, max_y))
			select_unit(user, vehicle.ai_brain)

/datum/human_ai_spawner_menu/proc/select_unit(mob/user, datum/unit_brain)
	if((unit_brain in selected_humans) || (unit_brain in selected_vehicles))
		return

	var/atom/movable/unit = get_unit_body(unit_brain)
	if(!unit)
		return

	if(istype(unit_brain, /datum/human_ai_brain))
		selected_humans += unit_brain
	else
		selected_vehicles += unit_brain
	RegisterSignal(unit_brain, COMSIG_PARENT_QDELETING, PROC_REF(on_selected_brain_delete))

	if(selection_viewer != user.client)
		clear_selection_images()
		selection_viewer = user.client

	var/image/selection_image = image('icons/turf/overlays.dmi', unit, "greenOverlay")
	selection_image.plane = ABOVE_LIGHTING_PLANE
	selection_image.appearance_flags = RESET_COLOR|RESET_TRANSFORM|KEEP_APART
	selection_images[unit_brain] = selection_image
	selection_viewer?.images += selection_image

/datum/human_ai_spawner_menu/proc/deselect_unit(datum/unit_brain)
	selected_humans -= unit_brain
	selected_vehicles -= unit_brain
	UnregisterSignal(unit_brain, COMSIG_PARENT_QDELETING)
	var/image/selection_image = selection_images[unit_brain]
	selection_images -= unit_brain
	selection_viewer?.images -= selection_image

/datum/human_ai_spawner_menu/proc/on_selected_brain_delete(datum/source, force)
	SIGNAL_HANDLER
	deselect_unit(source)

/datum/human_ai_spawner_menu/proc/clear_selection()
	for(var/datum/unit_brain as anything in selected_humans + selected_vehicles)
		deselect_unit(unit_brain)
	clear_selection_images()

/datum/human_ai_spawner_menu/proc/clear_selection_images()
	for(var/datum/unit_brain as anything in selection_images)
		selection_viewer?.images -= selection_images[unit_brain]
	selection_images.Cut()
	selection_viewer = null

/// Shows the first corner of the area being selected or the picked sniper post to the game master, or hides it
/datum/human_ai_spawner_menu/proc/update_corner_image(mob/user)
	if(corner_image)
		corner_viewer?.images -= corner_image
		corner_image = null
		corner_viewer = null

	var/turf/marked_turf = selection_corner || sniper_post
	if(!marked_turf || !user?.client)
		return

	corner_image = image('icons/turf/overlays.dmi', marked_turf, "blueOverlay")
	corner_image.plane = ABOVE_LIGHTING_PLANE
	corner_viewer = user.client
	corner_viewer.images += corner_image

/// Returns the selected units as a list of assoc lists that hold "name", "ref", "vehicle", "health" and "status"
/datum/human_ai_spawner_menu/proc/get_selection_ui_data()
	var/list/units = list()
	for(var/datum/human_ai_brain/brain as anything in selected_humans)
		var/mob/living/carbon/human/ai_human = brain.tied_human
		if(!ai_human)
			continue

		var/status = "Idle"
		if(ai_human.stat == DEAD)
			status = "Dead"
		else if(brain.hold_position)
			status = "Holding"
		else if(brain.in_combat)
			status = "Fighting"
		else if(brain.quick_approach || brain.target_turf)
			status = "Moving"

		units += list(list(
			"name" = ai_human.real_name,
			"ref" = REF(brain),
			"vehicle" = FALSE,
			"health" = floor(ai_human.health / ai_human.maxHealth * 100),
			"status" = status,
		))

	for(var/datum/vehicle_ai_brain/vehicle_brain as anything in selected_vehicles)
		var/obj/vehicle/multitile/vehicle = vehicle_brain.vehicle
		if(!vehicle)
			continue

		var/status = "Idle"
		if(vehicle.health <= 0)
			status = "Destroyed"
		else if(vehicle_brain.hold_position)
			status = "Holding"
		else if(vehicle_brain.in_combat)
			status = "Fighting"
		else if(vehicle_brain.destination || vehicle_brain.target_turf)
			status = "Moving"

		units += list(list(
			"name" = vehicle.name,
			"ref" = REF(vehicle_brain),
			"vehicle" = TRUE,
			"health" = floor(vehicle.health / initial(vehicle.health) * 100),
			"status" = status,
		))

	return units

/// Sends the selected units to the turf. Rushing ones run there no matter what, the others advance and fight on the way
/datum/human_ai_spawner_menu/proc/order_move(mob/user, turf/destination, rush)
	if(!length(selected_humans) && !length(selected_vehicles))
		to_chat(user, SPAN_WARNING("Select some AI first."))
		return

	for(var/datum/human_ai_brain/brain as anything in selected_humans)
		brain.hold_position = FALSE
		if(rush)
			brain.quick_approach = destination
		else
			brain.quick_approach = null
			brain.target_turf = destination

	// The guns keep firing while the vehicle drives, so it goes all the way there either way instead of stopping at the first enemy
	for(var/datum/vehicle_ai_brain/vehicle_brain as anything in selected_vehicles)
		vehicle_brain.hold_position = FALSE
		vehicle_brain.destination = destination

	var/image/order_image = image('icons/turf/overlays.dmi', destination, rush ? "redOverlay" : "greenOverlay")
	order_image.plane = ABOVE_LIGHTING_PLANE
	flick_overlay_to_clients(order_image, list(user.client), 1 SECONDS)

/datum/human_ai_spawner_menu/proc/order_hold(mob/user, hold)
	for(var/datum/human_ai_brain/brain as anything in selected_humans)
		brain.hold_position = hold
		if(hold)
			brain.quick_approach = null

	for(var/datum/vehicle_ai_brain/vehicle_brain as anything in selected_vehicles)
		vehicle_brain.hold_position = hold
		if(hold)
			vehicle_brain.destination = null

/// Cancels where the selected units were sent, they go back to what they would do on their own
/datum/human_ai_spawner_menu/proc/order_stop(mob/user)
	for(var/datum/human_ai_brain/brain as anything in selected_humans)
		brain.quick_approach = null
		if(!brain.current_target)
			brain.target_turf = null

	for(var/datum/vehicle_ai_brain/vehicle_brain as anything in selected_vehicles)
		vehicle_brain.destination = null
		if(!vehicle_brain.current_target)
			vehicle_brain.target_turf = null

/datum/human_ai_equipment_preset
	/// The GM-visible name of the equipment preset
	var/name = ""
	/// A short description of what the preset does. Including important equipment or usecases is a good idea
	var/desc = ""
	/// What faction the preset is related to
	var/faction = FACTION_NEUTRAL
	/// The /datum/equipment_preset that this preset should create
	var/path

#undef HUMAN_AI_SPAWNER_TAB_INFANTRY
#undef HUMAN_AI_SPAWNER_TAB_SQUADS
#undef HUMAN_AI_SPAWNER_TAB_VEHICLES
#undef HUMAN_AI_SPAWNER_TAB_ORDERS
#undef HUMAN_AI_SPAWNER_TABS

#undef HUMAN_AI_SPAWNER_MODE_SINGLE
#undef HUMAN_AI_SPAWNER_MODE_SQUAD
#undef HUMAN_AI_SPAWNER_MODE_NEST
#undef HUMAN_AI_SPAWNER_MODE_SNIPER
#undef HUMAN_AI_SPAWNER_MODES

#undef HUMAN_AI_SPAWNER_CUSTOM_CATEGORY
#undef HUMAN_AI_SPAWNER_PRESET_DEFAULT

#undef HUMAN_AI_SPAWNER_EQUIPMENT_FULL
#undef HUMAN_AI_SPAWNER_EQUIPMENT_NO_WEAPONS
#undef HUMAN_AI_SPAWNER_EQUIPMENT_NAKED
#undef HUMAN_AI_SPAWNER_EQUIPMENT

#undef HUMAN_AI_SPAWNER_MAX_COUNT
#undef HUMAN_AI_SPAWNER_MAX_SQUAD_SIZE
#undef HUMAN_AI_SPAWNER_DEFAULT_SQUAD_RADIUS
#undef HUMAN_AI_SPAWNER_MAX_SQUAD_RADIUS
#undef HUMAN_AI_SPAWNER_MAX_SPARE_AMMO
#undef HUMAN_AI_SPAWNER_MAX_SNIPER_RANGE

#undef HUMAN_AI_SPAWNER_NEST_GUNS
#undef HUMAN_AI_SPAWNER_POST_PRESETS
#undef HUMAN_AI_SPAWNER_MODE_CATEGORIES
#undef HUMAN_AI_SPAWNER_DIRECTIONS
#undef HUMAN_AI_SPAWNER_VEHICLES
#undef HUMAN_AI_SPAWNER_VEHICLE_DEFAULTS
#undef HUMAN_AI_SPAWNER_VEHICLE_CREWS

#undef SPAWN_CLICK_INTERCEPT_ACTION
#undef ORDER_CLICK_INTERCEPT_ACTION
