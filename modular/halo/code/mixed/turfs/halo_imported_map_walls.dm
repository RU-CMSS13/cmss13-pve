/turf/closed/wall/Shipwall_yellow
	name = "reinforced walls"
	icon = 'icons/turf/walls/yellow_ship_wall.dmi'
	icon_state = "shipwall_yellow"
	desc = "A mash up of reinforced metals that are made to withstand the dangers of space. These feature some cushioning in the event you trip onto the wall."
	walltype = WALL_SHIPWALL_YELLOW
	damage_cap = HEALTH_WALL_REINFORCED

/turf/closed/wall/Shipwall_yellow/hull
	name = "reinforced walls"
	icon = 'icons/turf/walls/yellow_ship_wall.dmi'
	icon_state = "shipwall_h_yellow"
	walltype = WALL_SHIPWALL_HULL_YELLOW

/turf/closed/wall/Shipwall_yellow/hull/right
	name = "reinforced walls"
	icon = 'icons/turf/walls/yellow_ship_wall.dmi'
	icon_state = "shipwall_nr_yellow"
	walltype = WALL_SHIPWALL_NORTH_RIGHT_YELLOW

/turf/closed/wall/Shipwall_yellow/hull/left
	name = "reinforced walls"
	icon = 'icons/turf/walls/yellow_ship_wall.dmi'
	icon_state = "shipwall_nl_yellow"
	walltype = WALL_SHIPWALL_NORTH_LEFT_YELLOW

/turf/closed/wall/Shipwall_yellow/hull/southright
	name = "reinforced walls"
	icon = 'icons/turf/walls/yellow_ship_wall.dmi'
	icon_state = "shipwall_sr_yellow"
	walltype = WALL_SHIPWALL_SOUTH_RIGHT_YELLOW

/turf/closed/wall/Shipwall_yellow/hull/southleft
	name = "reinforced walls"
	icon = 'icons/turf/walls/yellow_ship_wall.dmi'
	icon_state = "shipwall_sl_yellow"
	walltype = WALL_SHIPWALL_SOUTH_LEFT_YELLOW

/turf/closed/wall/rock_column
	name = "rock wall"
	desc = "A set of near-hexagonal rocks."
	icon = 'modular/halo/icons/turf/walls/new_varadero/nv_rock_wall.dmi'
	icon_state = "nv_rock"
	walltype = WALL_BASALT_COLUMN
	hull = TRUE

/turf/closed/wall/rock_column/solid
	name = "rock wall"
	desc = "A set of near-hexagonal rocks."
	icon = 'modular/halo/icons/turf/walls/new_varadero/nv_rock_wall_alt.dmi'
	icon_state = "nv_rock_alt"
	walltype = WALL_BASALT_COLUMN_SOLID
	hull = TRUE

/turf/closed/wall/new_varadero
	name = "foundation wall"
	desc = "A concrete wall with metal reinforcements."
	icon = 'modular/halo/icons/turf/walls/new_varadero/new_varadero_wall.dmi'
	icon_state = "new_varadero"
	walltype = WALL_FOUNDATION

/turf/closed/wall/new_varadero/reinforced
	name = "secured foundation wall"
	desc = "A concrete wall with metal reinforcements. The plating seems to have more rivets giving a daunting finish."
	icon_state = "new_varadero_rh"
	walltype = WALL_FOUNDATIONR
	damage_cap = HEALTH_WALL_REINFORCED

/turf/closed/wall/new_varadero/reinforced/hull
	name = "heavily-secured foundation wall"
	desc = "A concrete wall with metal reinforcements. The plating seems to have more rivets giving a daunting finish. This seems impenetrable to most conventional standards."
	icon_state = "new_varadero_hh"
	hull = TRUE

/turf/closed/wall/new_varadero/concrete
	name = "concrete wall"
	desc = "What's inside here? That's concrete, baby!"
	icon_state = "concrete"
	walltype = WALL_CONCRETE
	icon = 'modular/halo/icons/turf/walls/new_varadero/new_varadero_wall.dmi'

/turf/closed/wall/new_varadero/concrete/reinforced
	name = "hard concrete wall"
	desc = "What's inside here? That's tougher concrete, baby!"
	icon_state = "concrete_rh"
	damage_cap = HEALTH_WALL_REINFORCED

/turf/closed/wall/new_varadero/concrete/reinforced/hull
	name = "dense concrete wall"
	desc = "What's inside here? That's tough and sturdy concrete, baby! This will withstand even the most strongest of explosions!"
	icon_state = "concrete_hh"
	hull = TRUE
