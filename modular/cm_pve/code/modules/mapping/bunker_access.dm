/// Loads the CM-PVE bunker access overlay that completes PR #1284 bunker shipmap ladders.
/proc/load_cm_pve_bunker_access_templates()
	var/datum/map_config/ship_map = SSmapping?.configs?[SHIP_MAP]
	if(!ship_map)
		return

	var/template_name
	var/origin_x
	var/origin_y

	switch(ship_map.map_path)
		if("map_files/uscm_bunker")
			template_name = "access_uscm_bunker.dmm"
			origin_x = 56
			origin_y = 40
		if("map_files/upp_bunker")
			template_name = "access_upp_bunker.dmm"
			origin_x = 25
			origin_y = 83
		else
			return

	var/list/main_ship_zlevels = SSmapping.levels_by_trait(ZTRAIT_MARINE_MAIN_SHIP)
	if(!length(main_ship_zlevels))
		log_mapping("CM-PVE bunker access overlay skipped for [ship_map.map_name]: no main ship z-level found.")
		return

	var/datum/map_template/access_template = SSmapping.map_templates[template_name]
	if(!access_template)
		log_mapping("CM-PVE bunker access overlay skipped for [ship_map.map_name]: template [template_name] is not preloaded.")
		return

	var/main_ship_z = main_ship_zlevels[1]
	var/turf/origin = locate(origin_x, origin_y, main_ship_z)
	if(!origin)
		log_mapping("CM-PVE bunker access overlay skipped for [ship_map.map_name]: origin [origin_x],[origin_y],[main_ship_z] was not found.")
		return

	if(!access_template.load(origin, FALSE, FALSE))
		log_mapping("CM-PVE bunker access overlay failed for [ship_map.map_name]: [template_name] at [origin_x],[origin_y],[main_ship_z].")
		return

	log_mapping("CM-PVE bunker access overlay loaded for [ship_map.map_name]: [template_name] at [origin_x],[origin_y],[main_ship_z].")
