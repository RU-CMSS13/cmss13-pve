/obj/vehicle/multitile/apc/pmc
	name = "M577-WY Armored Personnel Carrier"
	desc = "An M577 Armored Personnel Carrier. Designed for transporting forces of the W-Y PMCs. An armored transport with four big wheels. Entrances on the sides and back."

	icon = 'icons/obj/vehicles/apc_pmc.dmi'
	icon_state = "hull_wy"

	interior_map = /datum/map_template/interior/apc_pmc

	hardpoints_allowed = list(
		/obj/item/hardpoint/primary/dualcannon/pmc,
		/obj/item/hardpoint/secondary/frontalcannon/pmc,
		/obj/item/hardpoint/support/flare_launcher,
		/obj/item/hardpoint/locomotion/apc_wheels/pmc,
	)

	mob_size_required_to_hit = MOB_SIZE_XENO

	dmg_multipliers = list(
		"all" = 1,
		"acid" = 1.6,
		"slash" = 0.8,
		"bullet" = 0.6,
		"explosive" = 0.7,
		"blunt" = 0.7,
		"abstract" = 1
	)

	move_max_momentum = 2
	move_momentum_build_factor = 1.5
	move_turn_momentum_loss_factor = 0.8

	var/sensor_radius = 45 //45 tiles radius

	/// weakrefs of xenos temporarily added to the marine minimap
	var/list/minimap_added = list()

/obj/vehicle/multitile/apc/pmc/Initialize()
	. = ..()
	START_PROCESSING(SSslowobj, src)
	GLOB.command_apc_list += src

/obj/vehicle/multitile/apc/pmc/Destroy()
	GLOB.command_apc_list -= src
	STOP_PROCESSING(SSslowobj, src)
	return ..()

/obj/vehicle/multitile/apc/pmc/process()
	var/turf/apc_turf = get_turf(src)
	if(health == 0 || !visible_in_tacmap || !is_ground_level(apc_turf.z))
		return

	for(var/mob/living/carbon/xenomorph/current_xeno as anything in GLOB.living_xeno_list)
		var/turf/xeno_turf = get_turf(current_xeno)
		if(!is_ground_level(xeno_turf.z))
			continue

		if(get_dist(src, current_xeno) <= sensor_radius)
			if(WEAKREF(current_xeno) in minimap_added)
				continue

			SSminimaps.remove_marker(current_xeno)
			current_xeno.add_minimap_marker(MINIMAP_FLAG_USCM|get_minimap_flag_for_faction(current_xeno.hivenumber))
			minimap_added += WEAKREF(current_xeno)
		else
			if(WEAKREF(current_xeno) in minimap_added)
				SSminimaps.remove_marker(current_xeno)
				current_xeno.add_minimap_marker()
				minimap_added -= WEAKREF(current_xeno)

/obj/vehicle/multitile/apc/pmc/load_role_reserved_slots()
	var/datum/role_reserved_slots/RRS = new
	RRS.category_name = "Crewmen"
	RRS.roles = list(JOB_PMC_CREWMAN)
	RRS.total = 1
	role_reserved_slots += RRS

	RRS = new
	RRS.category_name = "Command Staff"
	RRS.roles = JOB_COMMAND_ROLES_LIST
	RRS.total = 1
	role_reserved_slots += RRS

	RRS = new
	RRS.category_name = "Synthetic Unit"
	RRS.roles = list(JOB_PMC_SYNTH)
	RRS.total = 1
	role_reserved_slots += RRS

/obj/vehicle/multitile/apc/pmc/add_seated_verbs(mob/living/M, seat)
	if(!M.client)
		return
	add_verb(M.client, list(
		/obj/vehicle/multitile/proc/get_status_info,
		/obj/vehicle/multitile/proc/open_controls_guide,
		/obj/vehicle/multitile/proc/name_vehicle,
	))
	if(seat == VEHICLE_DRIVER)
		add_verb(M.client, list(
			/obj/vehicle/multitile/proc/toggle_door_lock,
			/obj/vehicle/multitile/proc/switch_hardpoint,
			/obj/vehicle/multitile/proc/cycle_hardpoint,
			/obj/vehicle/multitile/proc/activate_horn,
		))
	else if(seat == VEHICLE_GUNNER)
		add_verb(M.client, list(
			/obj/vehicle/multitile/proc/switch_hardpoint,
			/obj/vehicle/multitile/proc/cycle_hardpoint,
		))
	else if(seat == VEHICLE_SUPPORT_GUNNER_ONE || seat == VEHICLE_SUPPORT_GUNNER_TWO)
		remove_verb(M.client, list(
			/obj/vehicle/multitile/proc/reload_firing_port_weapon
		))

/obj/vehicle/multitile/apc/pmc/remove_seated_verbs(mob/living/M, seat)
	if(!M.client)
		return
	remove_verb(M.client, list(
		/obj/vehicle/multitile/proc/get_status_info,
		/obj/vehicle/multitile/proc/open_controls_guide,
		/obj/vehicle/multitile/proc/name_vehicle,
	))
	SStgui.close_user_uis(M, src)
	if(seat == VEHICLE_DRIVER)
		remove_verb(M.client, list(
			/obj/vehicle/multitile/proc/toggle_door_lock,
			/obj/vehicle/multitile/proc/switch_hardpoint,
			/obj/vehicle/multitile/proc/cycle_hardpoint,
			/obj/vehicle/multitile/proc/activate_horn,
		))
	else if(seat == VEHICLE_GUNNER)
		remove_verb(M.client, list(
			/obj/vehicle/multitile/proc/switch_hardpoint,
			/obj/vehicle/multitile/proc/cycle_hardpoint,
		))
	else if(seat == VEHICLE_SUPPORT_GUNNER_ONE || seat == VEHICLE_SUPPORT_GUNNER_TWO)
		remove_verb(M.client, list(
			/obj/vehicle/multitile/proc/reload_firing_port_weapon
		))


/obj/vehicle/multitile/apc/pmc/initialize_cameras(change_tag = FALSE)
	if(!camera)
		camera = new /obj/structure/machinery/camera/vehicle(src)
	if(change_tag)
		camera.c_tag = "#[rand(1,100)] M777-WY \"[nickname]\" APC"
		if(camera_int)
			camera_int.c_tag = camera.c_tag + " interior"
	else
		camera.c_tag = "#[rand(1,100)] M777-WY APC"
		if(camera_int)
			camera_int.c_tag = camera.c_tag + " interior"

/*
** PRESETS SPAWNERS
*/
/obj/effect/vehicle_spawner/apc_pmc
	name = "APC Transport Spawner"
	icon = 'icons/obj/vehicles/apc_pmc.dmi'
	icon_state = "hull_wy"
	pixel_x = -48
	pixel_y = -48

//Installation of transport APC Firing Ports Weapons
/obj/effect/vehicle_spawner/apc_pmc/proc/load_fpw(obj/vehicle/multitile/apc/V)
	var/obj/item/hardpoint/special/firing_port_weapon/FPW = new
	FPW.allowed_seat = VEHICLE_SUPPORT_GUNNER_ONE
	V.add_hardpoint(FPW)
	FPW.dir = turn(V.dir, 90)
	FPW.name = "Left "+ initial(FPW.name)
	FPW.origins = list(1, 0)
	FPW.muzzle_flash_pos = list(
		"1" = list(-18, 14),
		"2" = list(18, -42),
		"4" = list(34, 3),
		"8" = list(-32, -34)
	)

	FPW = new
	FPW.allowed_seat = VEHICLE_SUPPORT_GUNNER_TWO
	V.add_hardpoint(FPW)
	FPW.dir = turn(V.dir, -90)
	FPW.name = "Right "+ initial(FPW.name)
	FPW.origins = list(-1, 0)
	FPW.muzzle_flash_pos = list(
		"1" = list(16, 14),
		"2" = list(-18, -42),
		"4" = list(34, -34),
		"8" = list(-32, 2)
	)

/obj/effect/vehicle_spawner/apc_pmc/Initialize()
	. = ..()
	spawn_vehicle()
	qdel(src)

//PRESET: FPWs, no hardpoints
/obj/effect/vehicle_spawner/apc_pmc/spawn_vehicle()
	var/obj/vehicle/multitile/apc/pmc/APC = new (loc)

	load_misc(APC)
	load_fpw(APC)
	load_hardpoints(APC)
	handle_direction(APC)
	APC.update_icon()

//PRESET: FPWs, wheels installed
/obj/effect/vehicle_spawner/apc_pmc/plain/load_hardpoints(obj/vehicle/multitile/apc/V)
	V.add_hardpoint(new /obj/item/hardpoint/locomotion/apc_wheels/pmc)

//PRESET: default hardpoints, destroyed (this one spawns on VASRS elevatorfor VCs)
/obj/effect/vehicle_spawner/apc_pmc/decrepit/spawn_vehicle()
	var/obj/vehicle/multitile/apc/pmc/APC = new (loc)

	load_misc(APC)
	load_fpw(APC)
	load_hardpoints(APC)
	handle_direction(APC)
	load_damage(APC)
	APC.update_icon()

/obj/effect/vehicle_spawner/apc_pmc/decrepit/load_hardpoints(obj/vehicle/multitile/apc/V)
	V.add_hardpoint(new /obj/item/hardpoint/primary/dualcannon/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/secondary/frontalcannon/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/support/flare_launcher)
	V.add_hardpoint(new /obj/item/hardpoint/locomotion/apc_wheels/pmc)

//PRESET: FPWs, default hardpoints
/obj/effect/vehicle_spawner/apc_pmc/fixed/load_hardpoints(obj/vehicle/multitile/apc/V)
	V.add_hardpoint(new /obj/item/hardpoint/primary/dualcannon/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/secondary/frontalcannon/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/support/flare_launcher)
	V.add_hardpoint(new /obj/item/hardpoint/locomotion/apc_wheels/pmc)

//Transport version without FPWs

/obj/vehicle/multitile/apc_pmc/unarmed
	interior_map = /datum/map_template/interior/apc_no_fpw

//PRESET: no hardpoints
/obj/effect/vehicle_spawner/apc_pmc/unarmed/spawn_vehicle()
	var/obj/vehicle/multitile/apc_pmc/unarmed/APC = new (loc)

	load_misc(APC)
	load_hardpoints(APC)
	handle_direction(APC)
	APC.update_icon()

	return APC

/obj/effect/vehicle_spawner/apc_pmc/unarmed/load_hardpoints(obj/vehicle/multitile/apc/V)
	return

/obj/effect/vehicle_spawner/apc_pmc/unarmed/broken/spawn_vehicle()
	var/obj/vehicle/multitile/apc/pmc/apc = ..()
	load_damage(apc)
	apc.update_icon()

//PRESET: default hardpoints, destroyed
/obj/effect/vehicle_spawner/apc_pmc/unarmed/decrepit/spawn_vehicle()
	var/obj/vehicle/multitile/apc_pmc/unarmed/APC = new (loc)

	load_misc(APC)
	load_hardpoints(APC)
	handle_direction(APC)
	load_damage(APC)
	APC.update_icon()

/obj/effect/vehicle_spawner/apc_pmc/unarmed/decrepit/load_hardpoints(obj/vehicle/multitile/apc/V)
	V.add_hardpoint(new /obj/item/hardpoint/primary/dualcannon/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/secondary/frontalcannon/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/support/flare_launcher)
	V.add_hardpoint(new /obj/item/hardpoint/locomotion/apc_wheels/pmc)

//PRESET: no FPWs, wheels installed
/obj/effect/vehicle_spawner/apc_pmc/unarmed/plain/load_hardpoints(obj/vehicle/multitile/apc/unarmed/V)
	V.add_hardpoint(new /obj/item/hardpoint/locomotion/apc_wheels/pmc)

//PRESET: default hardpoints
/obj/effect/vehicle_spawner/apc_pmc/unarmed/fixed/load_hardpoints(obj/vehicle/multitile/apc/unarmed/V)
	V.add_hardpoint(new /obj/item/hardpoint/primary/dualcannon/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/secondary/frontalcannon/pmc)
	V.add_hardpoint(new /obj/item/hardpoint/support/flare_launcher)
	V.add_hardpoint(new /obj/item/hardpoint/locomotion/apc_wheels/pmc)
