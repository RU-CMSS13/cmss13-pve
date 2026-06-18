/obj/item/explosive/grenade/high_explosive/covenant
	icon = 'modular/halo/icons/halo/obj/items/weapons/grenades.dmi'
	icon_state = "m9"
	item_state = "m9"
	arm_sound = 'sound/weapons/grenade.ogg'
	falloff_mode = EXPLOSION_FALLOFF_SHAPE_EXPONENTIAL_HALF
	shrapnel_count = 0

/obj/item/explosive/grenade/high_explosive/covenant/plasma
	name = "Type-1 plasma grenade"
	desc = "Штатная липкая плазменная граната Ковенанта. Известна также как «огненная бомба», «святой свет» и «сигнальная». Прилипает к живым целям и технике, после чего сжигает их перегретой плазмой."
	desc_lore = "Паттерн «Анскум» массово выдаётся войскам Ковенанта как стандартная ручная взрывчатка. «Умная материя» в сердечнике помогает гранате закрепляться на цели до детонации."
	det_time = 40
	dangerous = TRUE
	underslug_launchable = FALSE
	harmful = TRUE
	icon_state = "plasma"
	item_state = "plasma"
	arm_sound = 'modular/halo/sound/weapons/firebomb_throw.ogg'
	explosion_power = 125
	explosion_falloff = 20
	shrapnel_count = 32
	shrapnel_type = /datum/ammo/bullet/shrapnel/metal
	throw_range = 6
	dual_purpose = FALSE
	light_power = 0.4
	light_range = 1.1
	var/datum/looping_sound/plasma_hiss/hiss_loop
	var/list/atoms_it_can_stick_to = list(/obj/vehicle/multitile, /mob/living/carbon/human, /mob/living)
	var/attached = FALSE
	var/attached_icon = "stuck_plasma"
	var/time_triggered

/obj/item/explosive/grenade/high_explosive/covenant/plasma/New()
	hiss_loop = new(src)
	..()

/obj/item/explosive/grenade/high_explosive/covenant/plasma/Destroy()
	QDEL_NULL(hiss_loop)
	return ..()

/obj/item/explosive/grenade/high_explosive/plasma
	parent_type = /obj/item/explosive/grenade/high_explosive/covenant/plasma
	name = "\improper Anskum-pattern plasma grenade"
	desc = "Also referred to as a 'Firebomb', 'Holy Light' and 'Flare', the Anskum-pattern is the standard issue hand tossed explosive given to Covenant troops."

/obj/item/explosive/grenade/high_explosive/covenant/plasma/activate(mob/user = null, hand_throw = TRUE)
	..()
	if(active)
		time_triggered = world.time
		hiss_loop.start()
		set_light_on(TRUE)

/obj/item/explosive/grenade/high_explosive/covenant/plasma/attack(mob/living/target, mob/living/user)
	if(target == user)
		if(isunggoy(user))
			if(active)
				to_chat(user, SPAN_HIGHDANGER("Ты крепче сжимаешь [src] в ладонях. Она прожигает кожу!"))
				launch_impact(user)
			else
				to_chat(user, SPAN_HIGHDANGER("Ты начинаешь активировать [src] и прилепляешь её к ладоням!"))
				if(!do_after(user, 30, INTERRUPT_ALL, BUSY_ICON_HOSTILE, user, INTERRUPT_NEEDHAND, BUSY_ICON_HOSTILE))
					return
				to_chat(user, SPAN_HIGHDANGER("Ты крепче сжимаешь [src] в ладонях. Она прожигает кожу!"))
				var/mob/living/carbon/thrower = user
				thrower.toggle_throw_mode(THROW_MODE_NORMAL)
				activate()
				INVOKE_ASYNC(thrower, TYPE_PROC_REF(/mob, throw_item), thrower)

/obj/item/explosive/grenade/high_explosive/covenant/plasma/prime(mob/living/user)
	set waitfor = 0
	if(!attached)
		cell_explosion(src.loc, explosion_power, explosion_falloff, falloff_mode, null, cause_data)
		new /obj/effect/overlay/temp/sebb(get_turf(src))
		new /obj/effect/overlay/temp/emp_sparks(get_turf(src))
		for(var/mob/living/target_living in range(3, get_turf(src)))
			var/obj/projectile/projectile = new /obj/projectile(src)
			projectile.generate_bullet(GLOB.ammo_list[/datum/ammo/bullet/shrapnel/metal], 0, NO_FLAGS)
			if(!check_for_path_obstacles_projectile(get_turf(src), get_turf(target_living), projectile))
				var/datum/reagent/napalm/blue/reagent = new()
				target_living.TryIgniteMob(9, reagent)
			qdel(projectile)
		if(shrapnel_count)
			create_shrapnel(loc, shrapnel_count, , , shrapnel_type, cause_data)
		apply_explosion_overlay()
		empulse(src, 1, 2)
		qdel(src)

/obj/item/explosive/grenade/high_explosive/covenant/plasma/launch_impact(atom/hit_atom)
	. = ..()
	if(active)
		for(var/atomtype in atoms_it_can_stick_to)
			if(istype(hit_atom, atomtype))
				var/zone
				var/datum/launch_metadata/LM = launch_metadata
				if(istype(LM?.thrower, /mob/living))
					var/mob/living/living_thrower = LM.thrower
					zone = check_zone(living_thrower.zone_selected)
				else
					zone = rand_zone("chest", 75)
				hit_atom.AddComponent(/datum/component/status_effect/plasma_stuck, src, zone)
				return
		if(isturf(hit_atom))
			for(var/obj/vehicle/multitile/big_vehicle in hit_atom)
				big_vehicle.AddComponent(/datum/component/status_effect/plasma_stuck, src)
				return

/datum/looping_sound/plasma_hiss
	start_sound = list('modular/halo/sound/weapons/firebomb_throw.ogg' = 1)
	mid_sounds = list(
		'modular/halo/sound/weapons/firebomb_loop2.ogg' = 1,
		'modular/halo/sound/weapons/firebomb_loop1.ogg' = 1,
	)
	mid_length = 1 SECONDS

/datum/component/status_effect/plasma_stuck
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/obj/item/explosive/grenade/high_explosive/covenant/plasma/origin_nade
	var/zone
	var/stage = 0
	var/time_running = 0
	var/y_offset
	var/x_offset
	var/mutable_appearance/attached_icon_em
	var/image/attached_icon

/datum/component/status_effect/plasma_stuck/Initialize(origin_nade, zone)
	. = ..()
	src.origin_nade = origin_nade
	src.zone = zone
	if(src.origin_nade.attached)
		qdel(src)
		return

	var/atom/movable/parent_atom = parent
	if(isliving(parent_atom))
		update_human_icon()
		to_chat(parent, SPAN_HIGHDANGER("Срывай её! [origin_nade] прилипает к твоей [zone]!"))
	else if(isVehicle(parent_atom))
		update_vehicle_icon()
		src.origin_nade.alpha = 0
		src.origin_nade.mouse_opacity = 0

	attached_icon.pixel_x = x_offset
	attached_icon.pixel_y = y_offset
	attached_icon_em.pixel_x = x_offset
	attached_icon_em.pixel_y = y_offset
	attached_icon.layer = ABOVE_MOB_LAYER + 0.1
	attached_icon_em.layer = ABOVE_MOB_LAYER + 0.1
	parent_atom.overlays += attached_icon
	attached_icon_em.appearance_flags &= ~RESET_TRANSFORM
	parent_atom.overlays += attached_icon_em
	src.origin_nade.attached = TRUE
	src.origin_nade.forceMove(parent_atom)
	src.origin_nade.set_light_on(TRUE)
	animation_flash_color(parent_atom, COLOR_BLUE)
	time_running = world.time - src.origin_nade.time_triggered
	if(time_running >= 2.5 SECONDS)
		time_running -= 5
	if(istype(parent_atom, /mob/living))
		RegisterSignal(parent_atom, list(COMSIG_LIVING_REJUVENATED), PROC_REF(unstuck))
	START_PROCESSING(SSfastobj, src)

/datum/component/status_effect/plasma_stuck/UnregisterFromParent()
	STOP_PROCESSING(SSfastobj, src)
	UnregisterSignal(parent, list(COMSIG_LIVING_REJUVENATED))

	var/atom/movable/parent_atom = parent
	if(parent_atom)
		parent_atom.overlays -= attached_icon
		parent_atom.overlays -= attached_icon_em

/datum/component/status_effect/plasma_stuck/proc/unstuck(delete_nade = TRUE)
	var/atom/movable/parent_atom = parent
	if(delete_nade)
		qdel(src.origin_nade)
	else
		to_chat(parent, SPAN_HIGHDANGER("Ты отрываешь от себя пылающий шар света!"))
		src.origin_nade.forceMove(parent_atom.loc)
		src.origin_nade.attached = FALSE
		addtimer(CALLBACK(src.origin_nade, TYPE_PROC_REF(/obj/item/explosive/grenade/high_explosive/covenant/plasma, prime)), src.origin_nade.det_time - time_running)
		INVOKE_ASYNC(src.origin_nade, TYPE_PROC_REF(/atom/movable, throw_atom), get_random_turf_in_range_unblocked(parent_atom, 3, 1), src.origin_nade.throw_range, SPEED_SLOW, parent_atom, HIGH_LAUNCH)
	parent_atom.overlays -= attached_icon
	parent_atom.overlays -= attached_icon_em
	qdel(src)

/datum/component/status_effect/plasma_stuck/proc/update_vehicle_icon()
	var/atom/movable/parent_atom = parent
	x_offset = parent_atom.bound_width / 4
	y_offset = parent_atom.bound_height / 4
	x_offset += rand(-3, 3)
	y_offset += rand(-3, 3)
	switch(src.origin_nade.dir)
		if(NORTH)
			y_offset -= 8
		if(SOUTH)
			y_offset += 8
		if(EAST)
			x_offset -= 8
		if(WEST)
			x_offset += 8
		if(NORTHEAST)
			x_offset -= 6
			y_offset -= 6
		if(NORTHWEST)
			x_offset += 6
			y_offset -= 6
		if(SOUTHEAST)
			x_offset -= 6
			y_offset += 6
		if(SOUTHWEST)
			x_offset += 6
			y_offset += 6
	attached_icon = image(icon = 'modular/halo/icons/halo/obj/items/weapons/grenades.dmi', icon_state = "stuck_plasma")
	attached_icon_em = emissive_appearance(icon = 'modular/halo/icons/halo/obj/items/weapons/grenades.dmi', icon_state = "stuck_plasma")

/datum/component/status_effect/plasma_stuck/proc/update_human_icon()
	x_offset = rand(-3, 3)
	if(zone in list("chest", "head", "groin"))
		attached_icon = image(icon = 'modular/halo/icons/halo/obj/items/weapons/grenades.dmi', icon_state = "stuck_plasma_centerbody")
		attached_icon_em = emissive_appearance(icon = 'modular/halo/icons/halo/obj/items/weapons/grenades.dmi', icon_state = "stuck_plasma_centerbody")
		if(zone == "head")
			y_offset = rand(4, 7)
		else if(zone == "chest")
			y_offset = rand(2, 5)
		else
			y_offset = rand(1, -2)
	else
		attached_icon = image(icon = 'modular/halo/icons/halo/obj/items/weapons/grenades.dmi', icon_state = "stuck_plasma")
		attached_icon_em = emissive_appearance(icon = 'modular/halo/icons/halo/obj/items/weapons/grenades.dmi', icon_state = "stuck_plasma")
		if(zone in list("r_arm", "r_leg", "r_hand", "r_foot", "l_foot"))
			attached_icon.transform = matrix(-1, 0, 0, 0, 1, 0)
			attached_icon.transform.Translate(32, 0)
			attached_icon_em.transform = matrix(-1, 0, 0, 0, 1, 0)
			attached_icon_em.transform.Translate(32, 0)
		if(zone in list("l_arm", "r_arm", "l_hand", "r_hand"))
			y_offset = rand(-1, 2)
		else if(zone in list("r_leg", "l_leg"))
			y_offset = rand(-2, -5)
		else
			y_offset = rand(-7, -9)

/datum/component/status_effect/plasma_stuck/proc/light_tune(intensity)
	origin_nade.set_light_range(intensity)

/datum/component/status_effect/plasma_stuck/process(delta_time)
	time_running += delta_time
	light_tune(max(time_running / 5, 1))
	if(ishuman(parent))
		process_human(delta_time)
	else if(isliving(parent))
		process_living(delta_time)
	if(isVehicleMultitile(parent))
		process_vehicle(delta_time)

/datum/component/status_effect/plasma_stuck/proc/process_human(delta_time)
	var/atom/parent_atom = parent
	var/mob/living/carbon/human/stuck_human = parent_atom
	stuck_human.apply_damage(15 * (delta_time / 5), BURN, zone)
	if(time_running >= 0.5 SECONDS && stage == 0)
		animation_flash_color(parent_atom, COLOR_BLUE)
		INVOKE_ASYNC(stuck_human, TYPE_PROC_REF(/mob, emote), "pain")
		to_chat(parent, SPAN_HIGHDANGER("Ослепительно яркий свет прожигает твою [parse_zone(zone)]!"))
		stage = 1
	if(time_running >= 1.5 SECONDS && stage == 1)
		animation_flash_color(parent_atom, COLOR_BLUE)
		var/obj/limb/stuck_limb = stuck_human.get_limb(zone)
		to_chat(parent, SPAN_HIGHDANGER("Кости начинают плавиться!"))
		stuck_limb?.fracture(100)
		stage = 2
	if(time_running >= 2.5 SECONDS && stage == 2)
		to_chat(parent, SPAN_HIGHDANGER("Плоть разрывает перегретая плазма!"))
		var/obj/limb/stuck_limb = stuck_human.get_limb(zone)
		stuck_limb?.droplimb()
		origin_nade.attached = FALSE
		origin_nade.prime()
		stuck_human.gib()
		stage = 3

/datum/component/status_effect/plasma_stuck/proc/process_living(delta_time)
	var/atom/parent_atom = parent
	var/mob/living/stuck_mob = parent_atom
	stuck_mob.apply_damage(15 * (delta_time / 5), BURN)
	stuck_mob.Superslow(1)
	if(time_running >= 0.5 SECONDS && stage == 0)
		animation_flash_color(parent_atom, COLOR_BLUE)
		stuck_mob.KnockDown(1)
		to_chat(parent, SPAN_HIGHDANGER("Ослепительно яркий свет прожигает твою плоть!"))
		stage = 1
	if(time_running >= 1.5 SECONDS && stage == 1)
		animation_flash_color(parent_atom, COLOR_BLUE)
		stuck_mob.KnockDown(1)
		to_chat(parent, SPAN_HIGHDANGER("Кости начинают плавиться!"))
		stage = 2
	if(time_running >= 2.5 SECONDS && stage == 2)
		to_chat(parent, SPAN_HIGHDANGER("Плоть разрывает перегретая плазма!"))
		origin_nade.attached = FALSE
		origin_nade.prime()
		stuck_mob.gib()
		stage = 3

/datum/component/status_effect/plasma_stuck/proc/process_vehicle(delta_time)
	var/atom/parent_atom = parent
	var/obj/vehicle/multitile/multitile_vehicle = parent_atom
	multitile_vehicle.take_damage_type(400 * (delta_time / 5), "plasma flame", src)
	INVOKE_ASYNC(src, PROC_REF(update_vehicle_icon))
	if(time_running >= 0.5 SECONDS && stage == 0)
		animation_flash_color(parent_atom, COLOR_BLUE)
		var/turf/centre = multitile_vehicle.interior.get_middle_turf()
		var/turf/target = get_random_turf_in_range(centre, 2, 0)
		var/datum/reagent/napalm/blue/reagent = new()
		new /obj/flamer_fire(target, create_cause_data("Плазменная граната"), reagent, 0)
		multitile_vehicle.interior_crash_effect()
		stage = 1
	if(time_running >= 1.5 SECONDS && stage == 1)
		animation_flash_color(parent_atom, COLOR_BLUE)
		var/turf/centre = multitile_vehicle.interior.get_middle_turf()
		var/turf/target = get_random_turf_in_range(centre, 2, 0)
		var/datum/reagent/napalm/blue/reagent = new()
		new /obj/flamer_fire(target, create_cause_data("Плазменная граната"), reagent, 1)
		multitile_vehicle.interior_crash_effect()
		stage = 2
	if(time_running >= 2.5 SECONDS && stage == 2)
		animation_flash_color(parent_atom, COLOR_BLUE)
		var/turf/centre = multitile_vehicle.interior.get_middle_turf()
		var/turf/target = get_random_turf_in_range(centre, 2, 0)
		var/datum/reagent/napalm/blue/reagent = new()
		new /obj/flamer_fire(target, create_cause_data("Плазменная граната"), reagent, 1)
		multitile_vehicle.at_munition_interior_explosion_effect(cause_data = create_cause_data("Плазменная граната"))
		multitile_vehicle.interior_crash_effect()
		multitile_vehicle.ex_act(300)
		origin_nade.attached = FALSE
		origin_nade.prime()
		qdel(src)
