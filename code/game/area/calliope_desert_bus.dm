//================================================CALLIOPE DESERT BUS
//BASE
/area/calliope_route
	name = "Calliope Highway"
	icon_state = "lv626"
	can_build_special = TRUE
	powernet_name = "ground"
	minimap_color = MINIMAP_AREA_COLONY
	ambience_exterior = AMBIENCE_BIGRED
//==============================================PARENTS
/area/calliope_route/highway
	name = "Calliope Passage"
	ceiling = CEILING_NONE
/area/calliope_route/exterior_buildings
	name = "Building"
	ceiling = CEILING_METAL
/area/calliope_route/tunnel
	name = "Tunnel"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
/area/calliope_route/oob
	name = "oob"
	ceiling = CEILING_DEEP_UNDERGROUND
/area/calliope_route/oob_o
	name = "open oob"
	ceiling = CEILING_NONE
//===============================================SHUTTLES
/area/calliope_route/shuttles/drop1
	name = "New Arkansas - Perimeter Gates"
	icon_state = "shuttle"
	icon = 'icons/turf/area_varadero.dmi'
	minimap_color = MINIMAP_AREA_LZ
/area/calliope_route/shuttles/drop2
	name = "Calliope Highway - Tunnel Opening"
	icon_state = "shuttle2"
	icon = 'icons/turf/area_varadero.dmi'
	minimap_color = MINIMAP_AREA_LZ
/area/calliope_route/shuttles/drop3
	name = "Calliope Highway - Far South Opening"
	icon_state = "shuttle2"
	icon = 'icons/turf/area_varadero.dmi'
	minimap_color = MINIMAP_AREA_LZ
/area/calliope_route/shuttles/drop4
	name = "Calliope Highway - Far South Opening - SECONDARY"
	icon_state = "shuttle3"
	icon = 'icons/turf/area_varadero.dmi'
	minimap_color = MINIMAP_AREA_LZ
//===============================================SOUTH
/area/calliope_route/highway/far_south
	name = "Highway Far South Roadway"
	icon_state = "south"
/area/calliope_route/highway/exchange
	name = "Highway Interchange"
	icon_state = "away1"
/area/calliope_route/highway/close_south
	name = "Highway South Roadway"
	icon_state = "south"
/area/calliope_route/tunnel/tunnel_s
	name = "South Tunnel Segment"
	icon_state = "hall1"
//===============================================NORTH
/area/calliope_route/tunnel/maintenance_hall
	name = "Tunnel Maintenance Segment"
	icon_state = "hall2"
/area/calliope_route/tunnel/generator_maints
	name = "Tunnel Maintenance Power Segment"
	icon_state = "engine_smes"
/area/calliope_route/tunnel/tunnel_n
	name = "North Tunnel Segment"
	icon_state = "hall3"
/area/calliope_route/highway/north
	name = "Highway North Roadway"
	icon_state = "north"
/area/calliope_route/tunnel/caves
	name = "Highway Cavern System"
	icon_state = "cave"
//===============================================BUIDLINGS
/area/calliope_route/exterior_buildings/buildings
	name = "Highway Structure"
	icon_state = "red"
/area/calliope_route/exterior_buildings/gateways
	name = "Highway Gateways"
	icon_state = "red"
//===============================================OTHER

//Zulu Areas (Yes I am this lazy)

/area/firebase_zulu
	name = "Master"
	icon = 'icons/turf/area_almayer.dmi'
	icon_state = "almayer"
	powernet_name = "firebase_zulu"
	sound_environment = SOUND_ENVIRONMENT_ROOM
	soundscape_interval = 30
	ambience_exterior = AMBIENCE_BIGRED

/area/firebase_zulu/outside
	name = "LV818 - Barrens"
	icon_state = "lifeboat"

/area/firebase_zulu/outside/compound
	name = "LV818 - Firebase Zulu - Compound"

/area/firebase_zulu/inside
	name = "Inside-Master"
	sound_environment = SOUND_ENVIRONMENT_ROOM
	ceiling = CEILING_METAL

/area/firebase_zulu/inside/motor_pool
	name = "\improper Motor Pool"
	icon_state = "workshop"
	ceiling = CEILING_NONE

/area/firebase_zulu/inside/platoonarmory
	name = "\improper Platoon Armory"
	icon_state = "alpha"

/area/firebase_zulu/inside/platoonprep
	name = "\improper Platoon Prep"
	icon_state = "bravo"

/area/firebase_zulu/inside/dorms
	name = "\improper Dorms"
	icon_state = "gruntrnr"

/area/firebase_zulu/inside/hangar
	name = "\improper Hangar"
	icon_state = "hangar"

/area/firebase_zulu/inside/shared_office
	name = "\improper Shared Office"
	icon_state = "alpha"

/area/firebase_zulu/inside/medical
	name = "\improper Medical"
	icon_state = "medical"
	ceiling = CEILING_NONE

/area/firebase_zulu/inside/canteen
	name = "\improper Canteen"
	icon_state = "food"

/area/firebase_zulu/inside/platoon_commander_rooms
	name = "\improper Platoon Commander's Tents"
	icon_state = "livingspace"
	ceiling = CEILING_NONE

/area/firebase_zulu/inside/engineering
	name = "\improper Engineering"
	icon_state = "upperengineering"
