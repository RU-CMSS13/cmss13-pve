/obj/structure/window/framed/new_varadero/foundation
	name = "window"
	icon = 'modular/halo/icons/turf/walls/new_varadero/new_varadero_windows.dmi'
	icon_state = "new_varadero_window"
	basestate = "new_varadero_window"
	window_frame = /obj/structure/window_frame/new_varadero/foundation
	health = 15

/obj/structure/window/framed/new_varadero/foundation/reinforced
	name = "reinforced window"
	desc = "A glass window that's harder to see through; it's undoubtedly reinforced with something."
	health = 100
	reinf = TRUE
	icon_state = "new_varadero_r_window"
	basestate = "new_varadero_r_window"
	window_frame = /obj/structure/window_frame/new_varadero/foundation/reinforced

/obj/structure/window/framed/new_varadero/foundation/reinforced/hull
	icon_state = "new_varadero_r_window_hh"
	basestate = "new_varadero_r_window"
	desc = "A glass window. Something tells you this one is somehow indestructible."
	not_damageable = TRUE
	not_deconstructable = TRUE
	unslashable = TRUE
	unacidable = TRUE
	health = 1000000

/obj/structure/window/framed/new_varadero/concrete
	name = "picture window"
	icon = 'modular/halo/icons/turf/walls/new_varadero/concrete_windows.dmi'
	desc = "A fully sized window pane meant to have full view of the outside world. This window seems to be made thick enough to take a few hits."
	not_deconstructable = TRUE
	health = 100
	reinf = TRUE
	icon_state = "concrete_window"
	basestate = "concrete_window"
	window_frame = /obj/structure/window_frame/new_varadero/concrete_frame

/obj/structure/window/framed/new_varadero/concrete/hull
	name = "dense picture window"
	icon = 'modular/halo/icons/turf/walls/new_varadero/concrete_windows.dmi'
	desc = "A fully sized window pane meant to have full view of the outside world. The window looks thick enough to stop anything!"
	icon_state = "concrete_window_h"
	not_damageable = TRUE
	not_deconstructable = TRUE
	unslashable = TRUE
	unacidable = TRUE
	health = 1000000

/obj/structure/window/framed/shipwall
	name = "ship window"
	desc = "A glass window. It looks thin and flimsy. A few knocks with anything should shatter it."
	health = 100

/obj/structure/window/framed/shipwall/yellow
	icon = 'icons/turf/walls/yellow_ship_windows.dmi'
	icon_state = "shipwall_window0"
	basestate = "shipwall_window"
	window_frame = /obj/structure/window_frame/shipwall/yellow

/obj/structure/window/framed/shipwall/yellow/reinforced
	name = "ship reinforced window"
	desc = "A glass window. Light refracts incorrectly when looking through. It looks rather strong. Might take a few good hits to shatter it."
	icon_state = "shipwall_r_window0"
	basestate = "shipwall_r_window"
	window_frame = /obj/structure/window_frame/shipwall/yellow/reinforced
	reinf = TRUE

/obj/structure/window/framed/shipwall/yellow/hull
	name = "ship hull window"
	desc = "A glass window with a special rod matrix inside a wall frame. This one was made out of exotic materials to prevent hull breaches. No way to get through here."
	icon_state = "shipwall_hull_window0"
	basestate = "shipwall_hull_window"
	window_frame = /obj/structure/window_frame/shipwall/yellow/hull
	not_damageable = TRUE
	not_deconstructable = TRUE
	unslashable = TRUE
	unacidable = TRUE
	health = 1000000

/obj/structure/window/framed/shipwall/yellow/hull/north
	icon_state = "shipwall_hull_n_window"
	basestate = "shipwall_hull_n_window"
	window_frame = /obj/structure/window_frame/shipwall/yellow/hull/north

/obj/structure/window/framed/shipwall/yellow/hull/south
	icon_state = "shipwall_hull_s_window"
	basestate = "shipwall_hull_s_window"
	window_frame = /obj/structure/window_frame/shipwall/yellow/hull/south

/obj/structure/window_frame/new_varadero/foundation
	icon = 'modular/halo/icons/turf/walls/new_varadero/new_varadero_windows.dmi'
	icon_state = "new_varadero_window0_frame"
	basestate = "new_varadero_window"
	window_type = /obj/structure/window/framed/new_varadero/foundation

/obj/structure/window_frame/new_varadero/foundation/reinforced
	icon = 'modular/halo/icons/turf/walls/new_varadero/new_varadero_windows.dmi'
	icon_state = "new_varadero_r_window0_frame"
	basestate = "new_varadero_r_window"
	reinforced = TRUE
	window_type = /obj/structure/window/framed/new_varadero/foundation/reinforced

/obj/structure/window_frame/new_varadero/foundation/reinforced/hull
	icon = 'modular/halo/icons/turf/walls/new_varadero/new_varadero_windows.dmi'
	icon_state = "new_varadero_r_window0_frame"
	basestate = "new_varadero_r_window"
	unslashable = TRUE
	unacidable = TRUE
	window_type = /obj/structure/window/framed/new_varadero/foundation/reinforced/hull

/obj/structure/window_frame/new_varadero/concrete_frame
	icon = 'modular/halo/icons/turf/walls/new_varadero/concrete_windows.dmi'
	icon_state = "concrete_window0_frame"
	basestate = "concrete_window"
	reinforced = TRUE
	unslashable = TRUE
	density = FALSE
	window_type = /obj/structure/window/framed/new_varadero/concrete

/obj/structure/window_frame/shipwall/yellow
	icon = 'icons/turf/walls/yellow_ship_windows.dmi'
	icon_state = "shipwall_window0_frame"
	basestate = "shipwall_window0_frame"

/obj/structure/window_frame/shipwall/yellow/reinforced
	icon = 'icons/turf/walls/yellow_ship_windows.dmi'
	icon_state = "shipwall_r_window0_frame"
	basestate = "shipwall_r_window0_frame"

/obj/structure/window_frame/shipwall/yellow/hull
	icon = 'icons/turf/walls/yellow_ship_windows.dmi'
	icon_state = "shipwall_hull_window0_frame"
	basestate = "shipwall_hull_window0_frame"

/obj/structure/window_frame/shipwall/yellow/hull/north
	icon = 'icons/turf/walls/yellow_ship_windows.dmi'
	icon_state = "shipwall_hull_n_window0_frame"
	basestate = "shipwall_hull_n_window0_frame"

/obj/structure/window_frame/shipwall/yellow/hull/south
	icon = 'icons/turf/walls/yellow_ship_windows.dmi'
	icon_state = "shipwall_hull_s_window0_frame"
	basestate = "shipwall_hull_s_window0_frame"
