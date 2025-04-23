/obj/docking_port/mobile/marine_dropship/lancer
	name = "Lancer"
	id = DROPSHIP_LANCER
	width = 8
	height = 14

	dwidth = 4
	dheight = 7


/obj/docking_port/mobile/marine_dropship/lancer/get_transit_path_type()
	return /turf/open/space/transit/dropship/lancer

/datum/map_template/shuttle/lancer
	name = "Lancer"
	shuttle_id = DROPSHIP_LANCER
