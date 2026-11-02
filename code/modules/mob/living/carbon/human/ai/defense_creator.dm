#define DEFENSE_CREATOR_TAB_DEFENSES "defenses"
#define DEFENSE_CREATOR_TAB_FORTIFY "fortify"

/// Types of click intercepts used by /datum/human_defense_creator_menu variable click_mode
#define DEFENSE_CREATOR_CLICK_PLACE "place"
#define DEFENSE_CREATOR_CLICK_ROOM "room"

/// Where placed defenses face. Away from and towards you go by where the clicked turf is from the game master
#define DEFENSE_CREATOR_DIRECTIONS list("Your facing", "Away from you", "Towards you", "North", "East", "South", "West")

#define FORTIFY_OPENING_WINDOW "window"
#define FORTIFY_OPENING_DOOR "door"

/// Barricades rooms are fortified with: name = list(barricade, folding barricade for doors, menu icon). Without a folding one doors get the barricade too
#define FORTIFY_MATERIALS list( \
	"Wood" = list(/obj/structure/barricade/wooden, null, "wooden"), \
	"Sandbags" = list(/obj/structure/barricade/sandbags/full, null, "sandbag"), \
	"Sandbags (Wired)" = list(/obj/structure/barricade/sandbags/wired, null, "sandbag_wired"), \
	"Metal" = list(/obj/structure/barricade/metal, /obj/structure/barricade/plasteel/metal, "metal"), \
	"Metal (Wired)" = list(/obj/structure/barricade/metal/wired, /obj/structure/barricade/plasteel/metal/wired, "metal_wired"), \
	"Plasteel" = list(/obj/structure/barricade/metal/plasteel, /obj/structure/barricade/plasteel, "plasteel"), \
	"Plasteel (Wired)" = list(/obj/structure/barricade/metal/plasteel/wired, /obj/structure/barricade/plasteel/wired, "plasteel_wired"), \
)

/// Rooms are scanned up to this many turfs, an open area would go on forever
#define FORTIFY_MAX_ROOM_SIZE 400

/// The most defenses one Shift+click places in a line
#define DEFENSE_CREATOR_MAX_LINE 15

/// Things that MMB removes while placing defenses
#define DEFENSE_CREATOR_REMOVABLE list(/obj/structure/machinery/defenses, /obj/structure/barricade, /obj/item/explosive/mine, /obj/structure/machinery/deployable)

/datum/human_defense_creator_menu
	var/static/list/lazy_defense_dict = list()
	var/static/list/lazy_ui_data = list()

	/// The open tab
	var/tab = DEFENSE_CREATOR_TAB_DEFENSES
	/// What clicks on the map do while we intercept them
	var/click_mode

	/// Path of the /datum/human_ai_defense selected to be placed
	var/selected_defense
	/// The faction placed defenses and mines belong to
	var/faction = FACTION_MARINE
	/// If placed defenses are turned on
	var/turned_on = TRUE
	/// The name of the direction placed defenses face
	var/place_direction = "Your facing"
	/// Where the last defense was placed, Shift+LMB places a line from it
	var/turf/last_placed_turf
	/// Weakrefs to what the last placement created, removed by undo
	var/list/datum/weakref/last_placed = list()

/datum/human_defense_creator_menu/New()
	if(!length(lazy_ui_data))
		for(var/datum/human_ai_defense/defense_type as anything in subtypesof(/datum/human_ai_defense))
			if(!defense_type::name)
				continue

			if(!lazy_ui_data[defense_type::category])
				lazy_ui_data[defense_type::category] = list()

			lazy_ui_data[defense_type::category] += list(list(
				"name" = defense_type::name,
				"path" = defense_type,
				"description" = defense_type::desc,
				"image" = defense_type::icon_state,
				"uses_faction" = defense_type::uses_faction,
				"uses_turned_on" = defense_type::uses_turned_on,
			))

/datum/human_defense_creator_menu/Destroy(force, ...)
	clear_room()
	return ..()

/datum/human_defense_creator_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HumanDefenseManager")
		ui.open()

/datum/human_defense_creator_menu/ui_state(mob/user)
	return GLOB.admin_state

/datum/human_defense_creator_menu/ui_close(mob/user)
	. = ..()
	click_mode = null
	release_click_intercept(user)
	clear_room()

/datum/human_defense_creator_menu/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/defense_menu),
	)

/datum/human_defense_creator_menu/ui_data(mob/user)
	var/list/data = list()

	// Another panel can take the click intercept away from us at any time
	var/intercepting = user.client?.click_intercept == src

	data["tab"] = tab

	// Defense stuff
	data["selected_defense"] = selected_defense
	data["faction"] = faction
	data["turned_on"] = turned_on
	data["place_direction"] = place_direction
	data["placing"] = intercepting && click_mode == DEFENSE_CREATOR_CLICK_PLACE
	data["can_undo"] = length(last_placed) > 0

	// Fortify stuff
	data["fortify_material"] = fortify_material
	data["fortify_windows"] = fortify_windows
	data["fortify_doors"] = fortify_doors
	data["picking_room"] = intercepting && click_mode == DEFENSE_CREATOR_CLICK_ROOM
	data["room_picked"] = !!room_origin
	data["room_size"] = length(room_turfs)
	data["room_capped"] = room_capped
	var/planned_windows = 0
	var/planned_doors = 0
	for(var/list/planned as anything in fortify_plan)
		if(planned[4] == FORTIFY_OPENING_WINDOW)
			planned_windows++
		else
			planned_doors++
	data["planned_windows"] = planned_windows
	data["planned_doors"] = planned_doors

	return data

/datum/human_defense_creator_menu/ui_static_data(mob/user)
	var/list/data = list()

	data["defenses"] = lazy_ui_data
	data["valid_factions"] = list(FACTION_MARINE, FACTION_UA_REBEL, FACTION_UPP, FACTION_CANC, FACTION_WY, FACTION_FREELANCER, FACTION_TWE, FACTION_TWE_REBEL, FACTION_MERCENARY)
	data["directions"] = DEFENSE_CREATOR_DIRECTIONS

	data["materials"] = list()
	var/list/materials = FORTIFY_MATERIALS
	for(var/material_name in materials)
		var/list/material = materials[material_name]
		data["materials"] += list(list(
			"name" = material_name,
			"image" = material[3],
			"folding" = !!material[2],
		))
	data["max_room_size"] = FORTIFY_MAX_ROOM_SIZE

	return data

/datum/human_defense_creator_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("set_tab")
			var/new_tab = params["tab"]
			if(!(new_tab in list(DEFENSE_CREATOR_TAB_DEFENSES, DEFENSE_CREATOR_TAB_FORTIFY)) || (new_tab == tab))
				return

			tab = new_tab
			click_mode = null
			release_click_intercept(user)
			clear_room()
			return TRUE

		// Defense Section
		if("select_defense")
			var/defense_path = text2path(params["path"])
			if(!ispath(defense_path, /datum/human_ai_defense))
				return

			selected_defense = defense_path
			return TRUE

		if("set_faction")
			var/new_faction = params["faction"]
			if(!(new_faction in list(FACTION_MARINE, FACTION_UA_REBEL, FACTION_UPP, FACTION_CANC, FACTION_WY, FACTION_FREELANCER, FACTION_TWE, FACTION_TWE_REBEL, FACTION_MERCENARY)))
				return

			faction = new_faction
			return TRUE

		if("toggle_turned_on")
			turned_on = !turned_on
			return TRUE

		if("set_direction")
			var/new_direction = params["direction"]
			if(!(new_direction in DEFENSE_CREATOR_DIRECTIONS))
				return

			place_direction = new_direction
			return TRUE

		if("toggle_placing")
			toggle_click_intercept(user, DEFENSE_CREATOR_CLICK_PLACE)
			return TRUE

		if("place_here")
			var/turf/user_turf = get_turf(user)
			if(user_turf)
				last_placed.Cut()
				place_defense(user, user_turf, get_place_dir(user, user_turf))
			return TRUE

		if("undo")
			undo_placement()
			return TRUE

		// Fortify Section
		if("set_material")
			var/new_material = params["material"]
			if(!(new_material in FORTIFY_MATERIALS))
				return

			fortify_material = new_material
			update_room(user)
			return TRUE

		if("toggle_windows")
			fortify_windows = !fortify_windows
			update_room(user)
			return TRUE

		if("toggle_doors")
			fortify_doors = !fortify_doors
			update_room(user)
			return TRUE

		if("toggle_room_picking")
			toggle_click_intercept(user, DEFENSE_CREATOR_CLICK_ROOM)
			return TRUE

		if("fortify")
			fortify_room(user)
			return TRUE

		if("cancel_room")
			clear_room()
			return TRUE

/// Turns the given click intercept on, or off if it is the one already in use
/datum/human_defense_creator_menu/proc/toggle_click_intercept(mob/user, new_click_mode)
	var/client/user_client = user.client
	if(!user_client)
		return

	if(click_mode == new_click_mode && user_client.click_intercept == src)
		click_mode = null
		release_click_intercept(user)
		return

	click_mode = new_click_mode
	user_client.click_intercept = src

/// Stops intercepting clicks, handing them back to the game master panel if it is open
/datum/human_defense_creator_menu/proc/release_click_intercept(mob/user)
	var/client/user_client = user.client
	if(user_client?.click_intercept != src)
		return

	user_client.click_intercept = null
	if(user_client.game_master_menu && SStgui.get_open_ui(user, user_client.game_master_menu))
		user_client.click_intercept = user_client.game_master_menu

/datum/human_defense_creator_menu/proc/InterceptClickOn(mob/user, params, atom/object)
	var/list/modifiers = params2list(params)
	var/turf/clicked_turf = get_turf(object)
	if(!clicked_turf)
		return FALSE

	switch(click_mode)
		if(DEFENSE_CREATOR_CLICK_PLACE)
			if(LAZYACCESS(modifiers, MIDDLE_CLICK))
				remove_defense(object, clicked_turf)
			else if(LAZYACCESS(modifiers, SHIFT_CLICK) && last_placed_turf && (last_placed_turf.z == clicked_turf.z))
				place_line(user, clicked_turf)
			else
				last_placed.Cut()
				place_defense(user, clicked_turf, get_place_dir(user, clicked_turf))
			SStgui.update_uis(src)
			return TRUE

		if(DEFENSE_CREATOR_CLICK_ROOM)
			pick_room(user, clicked_turf)
			SStgui.update_uis(src)
			return TRUE

	return FALSE

/// Returns the direction a defense placed on the turf faces
/datum/human_defense_creator_menu/proc/get_place_dir(mob/user, turf/place_turf)
	var/user_dir = (user.dir in GLOB.cardinals) ? user.dir : SOUTH
	switch(place_direction)
		if("North")
			return NORTH
		if("East")
			return EAST
		if("South")
			return SOUTH
		if("West")
			return WEST
		if("Away from you", "Towards you")
			var/direction = get_cardinal_dir(get_turf(user), place_turf) || user_dir
			return place_direction == "Towards you" ? REVERSE_DIR(direction) : direction

	return user_dir

/// Places the selected defense on the turf. Returns TRUE if it was placed
/datum/human_defense_creator_menu/proc/place_defense(mob/user, turf/place_turf, direction)
	if(!selected_defense)
		to_chat(user, SPAN_WARNING("Pick a defense first."))
		return FALSE

	if(place_turf.density)
		return FALSE

	if(!lazy_defense_dict[selected_defense])
		lazy_defense_dict[selected_defense] = new selected_defense()

	var/datum/human_ai_defense/defense_object = lazy_defense_dict[selected_defense]
	var/atom/movable/placed = defense_object.spawn_object(place_turf, direction, faction, turned_on)
	if(placed)
		last_placed += WEAKREF(placed)
	last_placed_turf = place_turf
	return TRUE

/// Places the selected defense on every turf in a line from the last placed one to the clicked one
/datum/human_defense_creator_menu/proc/place_line(mob/user, turf/end_turf)
	var/direction = get_place_dir(user, end_turf)
	var/list/turf/line = get_line(last_placed_turf, end_turf)
	// The first turf already has one
	line.Cut(1, 2)
	if(length(line) > DEFENSE_CREATOR_MAX_LINE)
		line.Cut(DEFENSE_CREATOR_MAX_LINE + 1)
		to_chat(user, SPAN_WARNING("Lines are up to [DEFENSE_CREATOR_MAX_LINE] tiles long."))

	last_placed.Cut()
	for(var/turf/line_turf as anything in line)
		place_defense(user, line_turf, direction)

/// Deletes what the last click or fortified room placed
/datum/human_defense_creator_menu/proc/undo_placement()
	for(var/datum/weakref/placed_ref as anything in last_placed)
		var/atom/movable/placed = placed_ref.resolve()
		if(!QDELETED(placed))
			qdel(placed)
	last_placed.Cut()
	last_placed_turf = null

/// Deletes the clicked defense, barricade or mine, or the topmost one on the clicked turf
/datum/human_defense_creator_menu/proc/remove_defense(atom/object, turf/clicked_turf)
	var/list/removable_types = DEFENSE_CREATOR_REMOVABLE
	if(is_type_in_list(object, removable_types))
		qdel(object)
		return

	for(var/index in length(clicked_turf.contents) to 1 step -1)
		var/atom/movable/thing = clicked_turf.contents[index]
		if(is_type_in_list(thing, removable_types))
			qdel(thing)
			return

/client/proc/open_human_defense_creator_panel()
	set name = "Human Defense Creator Panel"
	set category = "Game Master.HumanAI"

	if(!check_rights(R_DEBUG))
		return

	if(!human_defense_menu)
		human_defense_menu = new /datum/human_defense_creator_menu()
	human_defense_menu.tgui_interact(mob)

// Fortify stuff

/datum/human_defense_creator_menu
	/// The name of the FORTIFY_MATERIALS entry rooms are fortified with
	var/fortify_material = "Metal"
	/// If windows are barricaded
	var/fortify_windows = TRUE
	/// If doors are barricaded
	var/fortify_doors = TRUE
	/// The turf the room to fortify was picked from, null if none is picked
	var/turf/room_origin
	/// The turfs of the picked room
	var/list/turf/room_turfs = list()
	/// If the room was too big to scan whole
	var/room_capped = FALSE
	/// Barricades planned for the room, each a list(turf, direction, barricade type, FORTIFY_OPENING_*)
	var/list/fortify_plan = list()
	/// Images previewing the room and its barricades
	var/list/image/preview_images = list()
	/// The client that sees preview_images
	var/client/preview_viewer
	/// Assoc list of "[type]-[direction]" = how a new barricade looks, shared by every game master
	var/static/list/barricade_previews = list()

/// Picks the room the turf is in and previews how it would be fortified
/datum/human_defense_creator_menu/proc/pick_room(mob/user, turf/picked_turf)
	if(istype(picked_turf, /turf/closed) || get_opening(picked_turf))
		to_chat(user, SPAN_WARNING("Pick a floor inside the room."))
		return

	room_origin = picked_turf
	update_room(user)
	if(room_capped)
		to_chat(user, SPAN_WARNING("The room is not closed or bigger than [FORTIFY_MAX_ROOM_SIZE] tiles, only the part marked blue gets fortified."))

/// Scans the picked room again and updates its preview
/datum/human_defense_creator_menu/proc/update_room(mob/user)
	plan_fortification()
	update_preview(user)

/// Returns the FORTIFY_OPENING_* leading out of the room on the turf, if any
/datum/human_defense_creator_menu/proc/get_opening(turf/checked_turf)
	if((locate(/obj/structure/window_frame) in checked_turf) || (locate(/obj/structure/window) in checked_turf))
		return FORTIFY_OPENING_WINDOW
	if(locate(/obj/structure/machinery/door) in checked_turf)
		return FORTIFY_OPENING_DOOR

/// Finds the turfs of the picked room and plans a barricade in front of each window and door leading out of it
/datum/human_defense_creator_menu/proc/plan_fortification()
	room_turfs = list()
	fortify_plan = list()
	room_capped = FALSE
	if(!room_origin)
		return

	var/list/materials = FORTIFY_MATERIALS
	var/list/material = materials[fortify_material]
	var/cade_type = material[1]
	var/door_cade_type = material[2] || cade_type

	var/list/turf/visited = list()
	visited[room_origin] = TRUE
	room_turfs += room_origin
	var/index = 0
	while(index < length(room_turfs))
		index++
		var/turf/room_turf = room_turfs[index]
		for(var/direction in GLOB.cardinals)
			var/turf/nearby_turf = get_step(room_turf, direction)
			if(!nearby_turf || istype(nearby_turf, /turf/closed))
				continue

			var/opening = get_opening(nearby_turf)
			if(opening)
				var/wanted = (opening == FORTIFY_OPENING_WINDOW) ? fortify_windows : fortify_doors
				if(wanted && !has_barricade_facing(room_turf, direction))
					fortify_plan += list(list(room_turf, direction, (opening == FORTIFY_OPENING_WINDOW) ? cade_type : door_cade_type, opening))
				continue

			if(visited[nearby_turf])
				continue
			visited[nearby_turf] = TRUE
			if(length(room_turfs) >= FORTIFY_MAX_ROOM_SIZE)
				room_capped = TRUE
				continue
			room_turfs += nearby_turf

/datum/human_defense_creator_menu/proc/has_barricade_facing(turf/checked_turf, direction)
	for(var/obj/structure/barricade/cade in checked_turf)
		if(cade.dir == direction)
			return TRUE
	return FALSE

/// Shows the picked room and see-through barricades where they would go to the game master
/datum/human_defense_creator_menu/proc/update_preview(mob/user)
	clear_preview()
	if(!room_origin || !user?.client)
		return

	preview_viewer = user.client
	for(var/turf/room_turf as anything in room_turfs)
		var/image/turf_image = image('icons/turf/overlays.dmi', room_turf, "blueOverlay")
		turf_image.plane = ABOVE_LIGHTING_PLANE
		turf_image.alpha = 70
		preview_images += turf_image

	for(var/list/planned as anything in fortify_plan)
		preview_images += image(get_barricade_preview(planned[3], planned[2]), planned[1])

	preview_viewer.images += preview_images

/datum/human_defense_creator_menu/proc/clear_preview()
	preview_viewer?.images -= preview_images
	preview_images.Cut()
	preview_viewer = null

/datum/human_defense_creator_menu/proc/clear_room()
	room_origin = null
	room_turfs.Cut()
	fortify_plan.Cut()
	room_capped = FALSE
	clear_preview()

/// Returns how a new barricade of the type looks facing the direction, see-through so it reads as a preview
/datum/human_defense_creator_menu/proc/get_barricade_preview(cade_type, direction)
	RETURN_TYPE(/mutable_appearance)
	var/preview_key = "[cade_type]-[direction]"
	var/mutable_appearance/preview = barricade_previews[preview_key]
	if(preview)
		return preview

	// Made outside the world only to copy how it looks
	var/obj/structure/barricade/cade = new cade_type(null, null, direction)
	cade.setDir(direction)
	// Folding ones are placed raised
	if(istype(cade, /obj/structure/barricade/plasteel))
		cade.closed = FALSE
	cade.update_icon()
	preview = new(cade)
	qdel(cade)

	preview.alpha = 160
	preview.plane = ABOVE_LIGHTING_PLANE
	barricade_previews[preview_key] = preview
	return preview

/// Places the planned barricades, folding ones raised
/datum/human_defense_creator_menu/proc/fortify_room(mob/user)
	if(!room_origin)
		return

	// Things may have changed since the preview
	plan_fortification()
	last_placed.Cut()
	for(var/list/planned as anything in fortify_plan)
		var/cade_type = planned[3]
		var/direction = planned[2]
		var/obj/structure/barricade/cade = new cade_type(planned[1], null, direction)
		cade.setDir(direction)
		if(istype(cade, /obj/structure/barricade/plasteel))
			var/obj/structure/barricade/plasteel/folding_cade = cade
			folding_cade.open(folding_cade)
		last_placed += WEAKREF(cade)

	to_chat(user, SPAN_NOTICE("Placed [length(fortify_plan)] barricades over [length(room_turfs)] tiles."))
	clear_room()

/datum/human_ai_defense
	var/name = ""
	var/desc = ""
	var/category = "default"
	var/icon = 'icons/misc/human_defense_menu.dmi'
	var/icon_state
	var/uses_faction = TRUE
	var/uses_turned_on = TRUE
	var/path_to_spawn

/// Spawns the defense, returns what was spawned
/datum/human_ai_defense/proc/spawn_object(turf/loc_to_spawn, dir_to_spawn, faction, turned_on)
	RETURN_TYPE(/atom/movable)
	return

// Sentries

/datum/human_ai_defense/defense/spawn_object(turf/loc_to_spawn, dir_to_spawn, faction, turned_on)
	var/obj/structure/machinery/defenses/defense = new path_to_spawn(loc_to_spawn)
	defense.setDir(dir_to_spawn)
	defense.placed = TRUE
	if(turned_on)
		defense.power_on()
	else
		defense.power_off()
	if(faction)
		defense.handle_iff(faction)
	return defense

/datum/human_ai_defense/defense/sentry
	category = "Sentries"

/datum/human_ai_defense/defense/sentry/uscm
	name = "USCM Sentry"
	desc = /obj/structure/machinery/defenses/sentry::desc
	icon_state = "uscm_sentry"
	path_to_spawn = /obj/structure/machinery/defenses/sentry

/datum/human_ai_defense/defense/sentry/uscm/static_gun
	name = "USCM Sentry - Static"
	desc = /obj/structure/machinery/defenses/sentry/premade/deployable/almayer::desc
	path_to_spawn = /obj/structure/machinery/defenses/sentry/premade/deployable/almayer

/datum/human_ai_defense/defense/sentry/uscm/dmr
	name = "USCM Sentry - DMR"
	desc = /obj/structure/machinery/defenses/sentry/dmr::desc
	icon_state = "uscm_sentry_dmr"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/dmr

/datum/human_ai_defense/defense/sentry/uscm/shotgun
	name = "USCM Sentry - Shotgun"
	desc = /obj/structure/machinery/defenses/sentry/shotgun::desc
	icon_state = "uscm_sentry_shotgun"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/shotgun

/datum/human_ai_defense/defense/sentry/uscm/mini
	name = "USCM Sentry - Mini"
	desc = /obj/structure/machinery/defenses/sentry/mini::desc
	icon_state = "uscm_sentry_mini"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/mini

/datum/human_ai_defense/defense/sentry/uscm/flamer
	name = "USCM Sentry - Flamer"
	desc = /obj/structure/machinery/defenses/sentry/flamer::desc
	icon_state = "uscm_flamer"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/flamer

/datum/human_ai_defense/defense/sentry/uscm/flamer/mini
	name = "USCM Sentry - Mini Flamer"
	desc = /obj/structure/machinery/defenses/sentry/flamer/mini::desc
	icon_state = "uscm_flamer_mini"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/flamer/mini

/datum/human_ai_defense/defense/sentry/upp
	name = "UPP Sentry"
	desc = /obj/structure/machinery/defenses/sentry/upp::desc
	icon_state = "upp_sentry"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/upp

/datum/human_ai_defense/defense/sentry/upp/light
	name = "UPP Sentry - Light"
	desc = /obj/structure/machinery/defenses/sentry/upp/light::desc
	icon_state = "upp_sentry_light"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/upp/light

/datum/human_ai_defense/defense/sentry/upp/flamer
	name = "UPP Sentry - Flamer"
	desc = /obj/structure/machinery/defenses/sentry/flamer/upp::desc
	icon_state = "upp_flamer"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/flamer/upp

/datum/human_ai_defense/defense/sentry/wy
	name = "W-Y Sentry"
	desc = /obj/structure/machinery/defenses/sentry/wy::desc
	icon_state = "wy_sentry"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/wy

/datum/human_ai_defense/defense/sentry/wy/flamer
	name = "W-Y Sentry - Flamer"
	desc = /obj/structure/machinery/defenses/sentry/flamer/wy::desc
	icon_state = "wy_flamer"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/flamer/wy

/datum/human_ai_defense/defense/sentry/wy/static_gun
	name = "W-Y Sentry - Static"
	icon_state = "wy_sentry_static"

/datum/human_ai_defense/defense/sentry/wy/mini
	name = "W-Y Sentry - Mini Sentry"
	desc = /obj/structure/machinery/defenses/sentry/mini/wy::desc
	icon_state = "wy_sentry_mini"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/mini/wy

/datum/human_ai_defense/defense/sentry/wy/heavy
	name = "W-Y Sentry - Heavy"
	desc = /obj/structure/machinery/defenses/sentry/dmr/wy::desc
	icon_state = "wy_sentry_heavy"
	path_to_spawn = /obj/structure/machinery/defenses/sentry/dmr/wy

// Bell towers

/datum/human_ai_defense/defense/bell_tower
	name = "USCM Bell Tower"
	desc = /obj/structure/machinery/defenses/bell_tower::desc
	icon_state = "uscm_belltower"
	category = "Bell Towers"
	path_to_spawn = /obj/structure/machinery/defenses/bell_tower

/datum/human_ai_defense/defense/bell_tower/cloaked
	name = "USCM Bell Tower - Cloaked"
	desc = /obj/structure/machinery/defenses/bell_tower/cloaker::desc
	icon_state = "uscm_belltower_cloak"
	path_to_spawn = /obj/structure/machinery/defenses/bell_tower/cloaker

/datum/human_ai_defense/defense/bell_tower/md
	name = "USCM Bell Tower - MD"
	desc = /obj/structure/machinery/defenses/bell_tower/md::desc
	icon_state = "uscm_belltower_md"
	path_to_spawn = /obj/structure/machinery/defenses/bell_tower/md

// Flags

/datum/human_ai_defense/defense/flag
	category = "Planted Flags"

/datum/human_ai_defense/defense/flag/uscm
	name = "USCM Planted Flag"
	desc = /obj/structure/machinery/defenses/planted_flag::desc
	icon_state = "uscm_flag"
	path_to_spawn = /obj/structure/machinery/defenses/planted_flag

/datum/human_ai_defense/defense/flag/uscm/range
	name = "USCM Planted Flag - Range+"
	desc = /obj/structure/machinery/defenses/planted_flag/range::desc
	icon_state = "uscm_flag_range"
	path_to_spawn = /obj/structure/machinery/defenses/planted_flag/range

/datum/human_ai_defense/defense/flag/uscm/warbanner
	name = "USCM Planted Flag - Warbanner"
	desc = /obj/structure/machinery/defenses/planted_flag/warbanner::desc
	icon_state = "uscm_flag_warbanner"
	path_to_spawn = /obj/structure/machinery/defenses/planted_flag/warbanner

/datum/human_ai_defense/defense/flag/upp
	name = "UPP Planted Flag"
	desc = /obj/structure/machinery/defenses/planted_flag/upp::desc
	icon_state = "upp_flag"
	path_to_spawn = /obj/structure/machinery/defenses/planted_flag/upp

/datum/human_ai_defense/defense/flag/wy
	name = "W-Y Planted Flag"
	desc = /obj/structure/machinery/defenses/planted_flag/wy::desc
	icon_state = "wy_flag"
	path_to_spawn = /obj/structure/machinery/defenses/planted_flag/wy

// Teslas

/datum/human_ai_defense/defense/tesla
	name = "USCM Tesla Coil"
	desc = /obj/structure/machinery/defenses/tesla_coil::desc
	icon_state = "uscm_tesla"
	category = "Tesla Coils"
	path_to_spawn = /obj/structure/machinery/defenses/tesla_coil

/datum/human_ai_defense/defense/tesla/stun
	name = "USCM Tesla Coil - Overclocked"
	desc = /obj/structure/machinery/defenses/tesla_coil/stun::desc
	icon_state = "uscm_tesla_stun"
	path_to_spawn = /obj/structure/machinery/defenses/tesla_coil/stun

/datum/human_ai_defense/defense/tesla/micro
	name = "USCM Tesla Coil - Micro"
	desc = /obj/structure/machinery/defenses/tesla_coil/micro::desc
	icon_state = "uscm_tesla_micro"
	path_to_spawn = /obj/structure/machinery/defenses/tesla_coil/micro

// Mines

/datum/human_ai_defense/mine
	uses_turned_on = FALSE
	category = "Landmines"

/datum/human_ai_defense/mine/spawn_object(turf/loc_to_spawn, dir_to_spawn, faction, turned_on)
	var/obj/item/explosive/mine/defense = new path_to_spawn(loc_to_spawn)
	defense.setDir(dir_to_spawn)
	if(faction)
		defense.iff_signal = faction
	return defense

/datum/human_ai_defense/mine/claymore
	name = "Claymore"
	desc = /obj/item/explosive/mine/active::desc
	icon_state = "claymore"
	path_to_spawn = /obj/item/explosive/mine/active

/datum/human_ai_defense/mine/claymore/wy
	name = "Claymore - WY"
	desc = /obj/item/explosive/mine/pmc/active::desc
	icon_state = "claymore_wy"
	path_to_spawn = /obj/item/explosive/mine/pmc/active

/datum/human_ai_defense/mine/sebb
	name = "G2 Electroshock"
	desc = /obj/item/explosive/mine/sebb/active::desc
	icon_state = "sebb"
	path_to_spawn = /obj/item/explosive/mine/sebb/active

// Barricades

/datum/human_ai_defense/barricade
	uses_turned_on = FALSE
	uses_faction = FALSE
	category = "Barricades"

/datum/human_ai_defense/barricade/spawn_object(turf/loc_to_spawn, dir_to_spawn, faction, turned_on)
	// Sandbags shift towards the way they face when they are made
	var/obj/structure/barricade/defense = new path_to_spawn(loc_to_spawn, null, dir_to_spawn)
	defense.setDir(dir_to_spawn)
	return defense

/datum/human_ai_defense/barricade/wooden
	name = "Wooden Barricade"
	desc = /obj/structure/barricade/wooden::desc
	icon_state = "wooden"
	path_to_spawn = /obj/structure/barricade/wooden

/datum/human_ai_defense/barricade/metal
	name = "Metal Barricade"
	desc = /obj/structure/barricade/metal::desc
	icon_state = "metal"
	path_to_spawn = /obj/structure/barricade/metal

/datum/human_ai_defense/barricade/metal/wired
	name = "Metal Barricade - Wired"
	desc = /obj/structure/barricade/metal/wired::desc
	icon_state = "metal_wired"
	path_to_spawn = /obj/structure/barricade/metal/wired

/datum/human_ai_defense/barricade/sandbag
	name = "Sandbags"
	desc = /obj/structure/barricade/sandbags/full::desc
	icon_state = "sandbag"
	path_to_spawn = /obj/structure/barricade/sandbags/full

/datum/human_ai_defense/barricade/plasteel_folding
	name = "Plasteel Folding Barricade"
	desc = /obj/structure/barricade/plasteel::desc
	icon_state = "plasteel_folding"
	path_to_spawn = /obj/structure/barricade/plasteel

/datum/human_ai_defense/barricade/plasteel_folding/spawn_object(turf/loc_to_spawn, dir_to_spawn, faction, turned_on)
	var/obj/structure/barricade/plasteel/defense = new path_to_spawn(loc_to_spawn)
	defense.setDir(dir_to_spawn)
	defense.open() // closes it
	return defense

/datum/human_ai_defense/barricade/plasteel_folding/wired
	name = "Plasteel Folding Barricade - Wired"
	desc = /obj/structure/barricade/plasteel/wired::desc
	icon_state = "plasteel_folding_wired"
	path_to_spawn = /obj/structure/barricade/plasteel/wired

/datum/human_ai_defense/barricade/metal_folding
	name = "Metal Folding Barricade"
	desc = /obj/structure/barricade/plasteel/metal::desc
	icon_state = "metal_folding"
	path_to_spawn =/obj/structure/barricade/plasteel/metal

/datum/human_ai_defense/barricade/metal_folding/spawn_object(turf/loc_to_spawn, dir_to_spawn, faction, turned_on)
	var/obj/structure/barricade/plasteel/metal/defense = new path_to_spawn(loc_to_spawn)
	defense.setDir(dir_to_spawn)
	defense.open() // closes it
	return defense

/datum/human_ai_defense/barricade/metal_folding/wired
	name = "Metal Folding Barricade - Wired"
	desc = /obj/structure/barricade/plasteel/metal/wired::desc
	icon_state = "metal_folding_wired"
	path_to_spawn = /obj/structure/barricade/plasteel/metal/wired

/datum/human_ai_defense/barricade/wooden
	name = "Wooden Barricade"
	desc = /obj/structure/barricade/wooden::desc
	icon_state = "wooden"
	path_to_spawn = /obj/structure/barricade/wooden

/datum/human_ai_defense/barricade/snow
	name = "Snow Barricade"
	desc = /obj/structure/barricade/snow::desc
	icon_state = "snow"
	path_to_spawn = /obj/structure/barricade/snow

/datum/human_ai_defense/barricade/plasteel
	name = "Plasteel Barricade"
	desc = /obj/structure/barricade/metal/plasteel::desc
	icon_state = "plasteel"
	path_to_spawn = /obj/structure/barricade/metal/plasteel

/datum/human_ai_defense/barricade/plasteel/wired
	name = "Plasteel Barricade - Wired"
	desc = /obj/structure/barricade/metal/plasteel/wired::desc
	icon_state = "plasteel_wired"
	path_to_spawn = /obj/structure/barricade/metal/plasteel/wired

/datum/human_ai_defense/barricade/deployable
	name = "Portable Barricade"
	desc = /obj/structure/barricade/deployable::desc
	icon_state = "folding_0"
	path_to_spawn = /obj/structure/barricade/deployable

/datum/human_ai_defense/misc_defences
	uses_turned_on = FALSE
	uses_faction = FALSE
	category = "Miscellaneous Defenses"

/datum/human_ai_defense/misc_defences/spawn_object(turf/loc_to_spawn, dir_to_spawn, faction, turned_on)
	var/obj/structure/barricade/defense = new path_to_spawn(loc_to_spawn)
	defense.setDir(dir_to_spawn)
	return defense

/datum/human_ai_defense/misc_defences/barrier
	name = "Deployable Barrier"
	desc = /obj/structure/machinery/deployable/barrier::desc
	icon_state = "barrier0"
	path_to_spawn = /obj/structure/machinery/deployable/barrier

/datum/human_ai_defense/misc_defences/table
	name = "Table Barricade"
	desc = /obj/structure/barricade/table::desc
	icon_state = "metalflip"
	path_to_spawn = /obj/structure/barricade/table

/datum/human_ai_defense/misc_defences/table/wood
	name = "Wooden Table Barricade"
	desc = /obj/structure/barricade/table/wood::desc
	icon_state = "woodflip"
	path_to_spawn = /obj/structure/barricade/table/wood

/datum/human_ai_defense/misc_defences/table/poor
	name = "Poor Table Barricade"
	desc = /obj/structure/barricade/table/wood/poor::desc
	icon_state = "pwoodflip"
	path_to_spawn = /obj/structure/barricade/table/wood/poor

/datum/human_ai_defense/misc_defences/table/gambling
	name = "Gambling Table Barricade"
	desc = /obj/structure/barricade/table/wood/gambling::desc
	icon_state = "gameflip"
	path_to_spawn = /obj/structure/barricade/table/wood/gambling

/datum/human_ai_defense/misc_defences/table/reinforced
	name = "Reinforced Table Barricade"
	desc = /obj/structure/barricade/table/reinforced::desc
	icon_state = "reinfflip"
	path_to_spawn = /obj/structure/barricade/table/reinforced

/datum/human_ai_defense/misc_defences/table/almayer
	name = "Almayer Table Barricade"
	desc = /obj/structure/barricade/table/almayer::desc
	icon_state = "almflip"
	path_to_spawn = /obj/structure/barricade/table/almayer

/datum/human_ai_defense/misc_defences/table/prison
	name = "Prison Table Barricade"
	desc = /obj/structure/barricade/table/prison::desc
	icon_state = "prisonflip"
	path_to_spawn = /obj/structure/barricade/table/prison

/datum/human_ai_defense/misc_defences/razorwire
	name = "Razorwire"
	desc = /obj/structure/barricade/razorwire::desc
	icon_state = "barbed_wire"
	path_to_spawn = /obj/structure/barricade/razorwire

#undef DEFENSE_CREATOR_TAB_DEFENSES
#undef DEFENSE_CREATOR_TAB_FORTIFY
#undef DEFENSE_CREATOR_DIRECTIONS
#undef DEFENSE_CREATOR_MAX_LINE
#undef DEFENSE_CREATOR_REMOVABLE
#undef DEFENSE_CREATOR_CLICK_PLACE
#undef DEFENSE_CREATOR_CLICK_ROOM
#undef FORTIFY_OPENING_WINDOW
#undef FORTIFY_OPENING_DOOR
#undef FORTIFY_MATERIALS
#undef FORTIFY_MAX_ROOM_SIZE
