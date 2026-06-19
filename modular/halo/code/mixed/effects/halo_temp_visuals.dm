/particles/plasma
	icon = 'modular/halo/icons/halo/effects/plasma.dmi'
	icon_state = "circle"
	width = 340
	height = 340
	count = 100
	spawning = 5
	gradient = list("#FFFFFF", "#9990ffff", "#3e308aff")
	color_change = generator(GEN_NUM, 0.025, 0.05)
	lifespan = 15
	fade = generator(GEN_NUM, 25, 45)
	grow = -0.075
	velocity = list(0, 15)
	position = generator(GEN_CIRCLE, 3, 3, NORMAL_RAND)
	scale = generator(GEN_NUM, 0.65, 0.9)
	rotation = generator(GEN_NUM, 45, 135)
	spin = generator(GEN_NUM, -20, 20)
	drift = generator(GEN_VECTOR, list(-0.5, 0), list(0.5, 0), LINEAR_RAND)

/particles/plasma_explosion
	icon = 'modular/halo/icons/halo/effects/plasma.dmi'
	icon_state = list("shape_1" = 1, "shape_2" = 1, "shape_3" = 1, "shape_4" = 1)
	width = 340
	height = 340
	count = 45
	spawning = 45
	gradient = list("#FFFFFF", "#9990ffff", "#3e308aff")
	color_change = generator(GEN_NUM, 0.025, 0.01)
	lifespan = 6
	fade = generator(GEN_NUM, 25, 45)
	grow = -0.075
	velocity = generator(GEN_CIRCLE, 45, 35, NORMAL_RAND)
	scale = generator(GEN_NUM, 1.5, 1.7)
	friction = generator(GEN_NUM, 0.5, 0.25)

/particles/plasma_explosion/small
	count = 15
	spawning = 15
	velocity = generator(GEN_CIRCLE, 10, 15, NORMAL_RAND)
	scale = generator(GEN_NUM, 0.5, 1)

/particles/plasma_explosion/green
	count = 35
	spawning = 35
	gradient = list("#FFFFFF", "#5dbf67ff", "#328a30ff")
	velocity = generator(GEN_CIRCLE, 35, 25, NORMAL_RAND)

/particles/plasma_explosion/glassing
	width = 850
	height = 850
	count = 500
	spawning = 45
	fade = generator(GEN_NUM, 25, 55)
	position = list(0, -218)
	scale = generator(GEN_NUM, 2, 3)
	gradient = list("#FFFFFF", "#e67d71ff", "#470d0dff")
	velocity = generator(GEN_CIRCLE, 85, 75, NORMAL_RAND)

/particles/plasma_explosion/shield_pop
	count = 15
	spawning = 15
	velocity = generator(GEN_CIRCLE, 10, 15, NORMAL_RAND)
	scale = generator(GEN_NUM, 0.65, 1.1)

/particles/plasma_explosion/shield_hit
	count = 5
	spawning = 5
	velocity = generator(GEN_CIRCLE, 10, 15, NORMAL_RAND)
	fade = generator(GEN_NUM, 35, 55)
	scale = generator(GEN_NUM, 0.2, 0.25)

/particles/shield_spark
	icon = 'modular/halo/icons/halo/effects/plasma.dmi'
	icon_state = "circle"
	width = 150
	height = 150
	count = 12
	spawning = 12
	gradient = list("#FFFFFF", "#bce0ff", "#3e308aff")
	color_change = 0.25
	lifespan = 5
	fade = 5
	scale = list(0.17, 0.17)
	grow = -0.03
	velocity = generator(GEN_CIRCLE, 35, 35, NORMAL_RAND)
	position = generator(GEN_CIRCLE, 5, 5, NORMAL_RAND)
	friction = generator(GEN_NUM, 0.5, 0.4)

/particles/plasma_grenade_flame
	icon = 'modular/halo/icons/halo/effects/plasma.dmi'
	icon_state = list("shape_1" = 1, "shape_2" = 1, "shape_3" = 1, "shape_4" = 1)
	width = 340
	height = 340
	count = 50
	spawning = 0
	gradient = list("#FFFFFF", "#9990ffff", "#3e308aff")
	color_change = generator(GEN_NUM, 0.025, 0.01)
	lifespan = 6
	fade = generator(GEN_NUM, 5, 35)
	grow = -0.065
	position = generator(GEN_CIRCLE, 2, 2, NORMAL_RAND)
	velocity = list(0, 7.5)
	scale = generator(GEN_NUM, 0.2, 0.35)
	friction = generator(GEN_NUM, 0.1, 0.15)

/obj/effect/temp_visual
	var/halo_perf_is_halo_temp_visual = FALSE
	var/halo_perf_is_shield_temp_visual = FALSE

/obj/effect/temp_visual/proc/halo_perf_track_initialize()
	if(!halo_perf_is_halo_temp_visual)
		return

	halo_perf_bump_temp_visuals()
	halo_perf_adjust_active_halo_temp_visuals(1)
	if(halo_perf_is_shield_temp_visual)
		halo_perf_adjust_active_shield_temp_visuals(1)

/obj/effect/temp_visual/Destroy()
	if(halo_perf_is_halo_temp_visual)
		halo_perf_adjust_active_halo_temp_visuals(-1)
		if(halo_perf_is_shield_temp_visual)
			halo_perf_adjust_active_shield_temp_visuals(-1)
			halo_perf_bump_shield_temp_visual_qdels()
	return ..()

/obj/effect/temp_visual/plasma_incoming
	icon = null
	duration = 3 SECONDS
	pixel_z = 480
	light_on = TRUE
	light_power = 3
	light_range = 3
	light_color = "#71a2e6ff"
	layer = ABOVE_FLY_LAYER
	indestructible = TRUE
	halo_perf_is_halo_temp_visual = TRUE

/obj/effect/temp_visual/plasma_incoming/Initialize(mapload)
	. = ..()
	halo_perf_track_initialize()
	particles = new /particles/plasma
	add_filter("pixel_outline", 1, outline_filter(1, "#4f308aff", OUTLINE_SHARP))
	add_filter("glow", 2, drop_shadow_filter(0, 0, 5, 1, "#4f308aff"))
	addtimer(VARSET_CALLBACK(particles, count, 0), 0.65 SECONDS)
	animate(src, pixel_z = -140, time = 1.25 SECONDS)

/obj/effect/temp_visual/plasma_explosion
	icon = null
	duration = 7
	light_on = TRUE
	light_power = 5
	light_range = 6
	light_color = "#71a2e6ff"
	layer = ABOVE_MOB_LAYER
	indestructible = TRUE
	halo_perf_is_halo_temp_visual = TRUE
	var/outline_color = "#4f308aff"
	var/particles_used = /particles/plasma_explosion

/obj/effect/temp_visual/plasma_explosion/Initialize(mapload)
	. = ..()
	halo_perf_track_initialize()
	particles = new particles_used
	add_filter("pixel_outline", 1, outline_filter(1, outline_color, OUTLINE_SHARP))
	add_filter("glow", 2, drop_shadow_filter(0, 0, 5, 1, outline_color))
	addtimer(VARSET_CALLBACK(particles, count, 0), 0.25 SECONDS)

/obj/effect/temp_visual/plasma_explosion/cyan
	light_color = "#3decff"
	particles_used = /particles/plasma_explosion
	outline_color = "#3decff"

/obj/effect/temp_visual/plasma_explosion/small
	light_power = 2
	light_range = 3
	particles_used = /particles/plasma_explosion/small

/obj/effect/temp_visual/plasma_explosion/green
	light_color = "#75d66eff"
	particles_used = /particles/plasma_explosion/green
	outline_color = "#328a30ff"

/obj/effect/temp_visual/plasma_explosion/shield_pop
	light_color = "#77b6ff"
	particles_used = /particles/plasma_explosion/shield_pop
	outline_color = "#77b6ff"
	light_power = 2
	light_range = 3
	halo_perf_is_shield_temp_visual = TRUE

/obj/effect/temp_visual/plasma_explosion/shield_hit
	light_color = "#77b6ff"
	particles_used = /particles/plasma_explosion/shield_hit
	outline_color = "#77b6ff"
	light_power = 1
	light_range = 2
	halo_perf_is_shield_temp_visual = TRUE

/obj/effect/temp_visual/flyby
	layer = FLY_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	duration = 2 SECONDS
	indestructible = TRUE
	halo_perf_is_halo_temp_visual = TRUE
	var/override_dir = TRUE
	var/pixel_distance = 960

/obj/effect/temp_visual/flyby/Initialize()
	. = ..()
	halo_perf_track_initialize()
	if(!override_dir)
		var/random_dir = pick(NORTH, SOUTH, EAST, WEST)
		setDir(random_dir)
	else
		setDir(NORTH)
	switch(dir)
		if(NORTH)
			pixel_z = -pixel_distance
			animate(src, pixel_z = pixel_distance, time = duration)
		if(SOUTH)
			pixel_z = pixel_distance
			animate(src, pixel_z = -pixel_distance, time = duration)
		if(EAST)
			pixel_w = -pixel_distance
			animate(src, pixel_w = pixel_distance, time = duration)
		if(WEST)
			pixel_w = pixel_distance
			animate(src, pixel_w = -pixel_distance, time = duration)

/obj/effect/temp_visual/flyby/banshee_flyby
	icon = 'modular/halo/icons/halo/effects/banshee_flyby.dmi'
	icon_state = "banshee_shadow"
	pixel_x = -64
	pixel_y = -64

/obj/effect/temp_visual/flyby/seraph_flyby
	icon = 'modular/halo/icons/halo/effects/kai_seraph_flyby.dmi'
	icon_state = "kai_shadow"
	pixel_x = -140
	pixel_y = -140

/obj/effect/temp_visual/flyby/wombat_flyby
	icon = 'modular/halo/icons/halo/effects/wombat_flyby.dmi'
	icon_state = "wombat_shadow"
	pixel_x = -144
	pixel_y = -144

/obj/effect/temp_visual/flyby/c712_longsword_flyby
	icon = 'modular/halo/icons/halo/effects/c712_flyby.dmi'
	icon_state = "c712_shadow"
	pixel_x = -352
	pixel_y = -352
	pixel_distance = 1920

/obj/effect/temp_visual/flyby/c709_longsword_flyby
	icon = 'modular/halo/icons/halo/effects/c709_flyby.dmi'
	icon_state = "c709_shadow"
	pixel_distance = 2240 // this thing is massive and needs extra travel distance.
	pixel_y = -720
	pixel_x = -720
	duration = 5 SECONDS

/obj/effect/temp_visual/glassing_beam
	icon = 'modular/halo/icons/halo/effects/glassing.dmi'
	icon_state = "beam"
	pixel_x = -50
	duration = 8.5 SECONDS
	light_on = TRUE
	light_power = 25
	light_range = 50
	light_color = "#e67d71ff"
	layer = ABOVE_FLY_LAYER
	indestructible = TRUE
	halo_perf_is_halo_temp_visual = TRUE
	var/outline_color = "#c50909ff"
	var/particles_used = /particles/plasma_explosion/glassing

/obj/effect/temp_visual/glassing_beam/Initialize(mapload)
	. = ..()
	halo_perf_track_initialize()
	particles = new particles_used
	add_filter("pixel_outline", 1, outline_filter(1, outline_color, OUTLINE_SHARP))
	add_filter("glow", 2, drop_shadow_filter(0, 0, 3, 1, outline_color))
	addtimer(CALLBACK(src, PROC_REF(beam_off)), 7.5 SECONDS)

/obj/effect/temp_visual/glassing_beam/proc/beam_off()
	particles.count = 0
	icon_state = "off"
	light_on = FALSE

/obj/effect/temp_visual/shield_spark
	icon = null
	duration = 4
	layer = ABOVE_MOB_LAYER
	indestructible = TRUE
	halo_perf_is_halo_temp_visual = TRUE
	halo_perf_is_shield_temp_visual = TRUE

/obj/effect/temp_visual/shield_spark/Initialize(mapload)
	. = ..()
	halo_perf_track_initialize()
	particles = new /particles/shield_spark
	addtimer(VARSET_CALLBACK(particles, count, 0), 1)
	add_filter("glow", 2, drop_shadow_filter(0, 0, 3, 1, "#77b6ff"))

// ================
// Dropship hover visuals
// ================

/obj/effect/temp_visual/dropship_hover/phantom
	icon = 'modular/halo/icons/halo/effects/phantom_flyby.dmi'
	icon_state = "phantom_shadow"
	duration = 1 MINUTES
	pixel_x = -560
	pixel_y = -560
	var/datum/looping_sound/phantom_loop/hover
	randomdir = FALSE
	light_range = 15
	light_color = "#b188b6"
	halo_perf_is_halo_temp_visual = TRUE

/obj/effect/temp_visual/dropship_hover/phantom/Initialize()
	. = ..()
	halo_perf_track_initialize()
	particles = null
	hover = new(src)
	hover.start()
	animate(src, time = 1 SECONDS, loop = -1, LINEAR_EASING, pixel_y = src.pixel_y +2)
	animate(time = 1 SECONDS, easing = LINEAR_EASING, pixel_y = src.pixel_y - 2)
	set_light_on(TRUE)

/obj/effect/temp_visual/dropship_hover/phantom/fade_away()
	. = ..()
	hover.stop()

/obj/effect/temp_visual/dropship_hover/spirit
	icon = 'modular/halo/icons/halo/effects/spirit_flyby.dmi'
	icon_state = "spirit_shadow"
	duration = 1 MINUTES
	pixel_x = -384
	pixel_y = -384
	var/datum/looping_sound/phantom_loop/hover
	randomdir = FALSE
	light_range = 9
	light_color = "#b188b6"
	halo_perf_is_halo_temp_visual = TRUE

/obj/effect/temp_visual/dropship_hover/spirit/Initialize()
	. = ..()
	halo_perf_track_initialize()
	particles = null
	hover = new(src)
	hover.start()
	animate(src, time = 2 SECONDS, loop = -1, LINEAR_EASING, pixel_y = src.pixel_y +4)
	animate(time = 2 SECONDS, easing = LINEAR_EASING, pixel_y = src.pixel_y - 4)
	set_light_on(TRUE)

/obj/effect/temp_visual/dropship_hover/spirit/fade_away()
	. = ..()
	hover.stop()

/obj/effect/temp_visual/dropship_hover/pelican
	icon = 'modular/halo/icons/halo/effects/pelican_flyby.dmi'
	icon_state = "pelican_shadow"
	duration = 1 MINUTES
	pixel_x = -368
	pixel_y = -368
	var/datum/looping_sound/pelican_loop/hover
	randomdir = FALSE
	light_range = 9
	light_color = "#d7935b"
	halo_perf_is_halo_temp_visual = TRUE

/obj/effect/temp_visual/dropship_hover/pelican/Initialize()
	. = ..()
	halo_perf_track_initialize()
	particles = null
	hover = new(src)
	hover.start()
	animate(src, time = 1 SECONDS, loop = -1, LINEAR_EASING, pixel_y = src.pixel_y +2)
	animate(time = 1 SECONDS, easing = LINEAR_EASING, pixel_y = src.pixel_y - 2)
	set_light_on(TRUE)

/obj/effect/temp_visual/dropship_hover/pelican/fade_away()
	. = ..()
	hover.stop()
