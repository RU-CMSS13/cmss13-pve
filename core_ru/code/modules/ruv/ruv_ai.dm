/mob/living/simple_animal/ruv/proc/toggle_mode()
	if(mode == RUV_MODE_AUTO)
		mode = RUV_MODE_MANUAL
		stop_walking()
		order = RUV_ORDER_HOLD
		order_target_ref = null
		pending_order = null
	else
		mode = RUV_MODE_AUTO
		set_order(RUV_ORDER_HOLD)
	playsound(loc, 'sound/machines/click.ogg', 25, TRUE)
	update_bot_icon()
	update_commander_actions()
	update_order_marker()
	if(commander)
		to_chat(commander, SPAN_NOTICE("[src] switches to [mode] mode."))

/// Called by the order buttons: some orders apply at once, the rest wait for the commander to click a target
/mob/living/simple_animal/ruv/proc/select_order(new_order)
	switch(new_order)
		if(RUV_ORDER_HOLD)
			pending_order = null
			stop_pulling()
			set_order(RUV_ORDER_HOLD, null, commander)
		if(RUV_ORDER_FOLLOW)
			set_order(RUV_ORDER_FOLLOW, commander, commander)
		if(RUV_ORDER_ATTACK)
			pending_order = new_order
			to_chat(commander, SPAN_NOTICE("Click what [src] should attack, or a spot to move to. Click [src] itself to cancel."))
		if(RUV_ORDER_INTERACT)
			pending_order = new_order
			to_chat(commander, SPAN_NOTICE("Click what [src] should grab or use. Click [src] itself to cancel."))
	refresh_order_buttons()

/mob/living/simple_animal/ruv/proc/set_order(new_order, atom/target, mob/living/giver)
	stop_walking()
	// Off to grab something else, the old load stays where it is
	if(new_order == RUV_ORDER_INTERACT && pulling && pulling != target)
		release_grab()
	order = new_order
	order_target_ref = WEAKREF(target)
	if(giver)
		order_giver_ref = WEAKREF(giver)
	update_order_marker()
	refresh_order_buttons()
	if(commander)
		switch(order)
			if(RUV_ORDER_HOLD)
				to_chat(commander, SPAN_NOTICE("[src] stops."))
			if(RUV_ORDER_FOLLOW)
				to_chat(commander, SPAN_NOTICE("[src] follows [target]."))
			if(RUV_ORDER_ATTACK)
				to_chat(commander, SPAN_NOTICE(isturf(target) ? "[src] moves out." : "[src] engages [target]."))
			if(RUV_ORDER_INTERACT)
				to_chat(commander, SPAN_NOTICE("[src] heads for [target]."))

/mob/living/simple_animal/ruv/proc/ai_process()
	if(is_mob_incapacitated() || !isturf(loc))
		return
	var/atom/order_target = order_target_ref?.resolve()
	if(order != RUV_ORDER_HOLD)
		var/turf/target_turf = get_turf(order_target)
		if(!target_turf || target_turf.z != z)
			set_order(RUV_ORDER_HOLD)
			order_target = null

	switch(order)
		if(RUV_ORDER_FOLLOW)
			if(get_dist(src, order_target) > RUV_FOLLOW_DISTANCE)
				move_towards(order_target)

		if(RUV_ORDER_ATTACK)
			if(isturf(order_target))
				if(loc == order_target)
					set_order(RUV_ORDER_HOLD)
				else
					move_towards(order_target)
			else
				attack_order_target(order_target)

		if(RUV_ORDER_INTERACT)
			var/obj/item/ruv_module/arm/arm_module = module
			if(!istype(arm_module) || !arm_module.can_interact_with(order_target))
				set_order(RUV_ORDER_HOLD)
			else if(!Adjacent(order_target))
				move_towards(order_target)
			else if(arm_module.use_on(order_target, src))
				var/mob/living/order_giver = order_giver_ref?.resolve()
				if(pulling && order_giver && order_giver.stat != DEAD)
					set_order(RUV_ORDER_FOLLOW, order_giver)
				else
					set_order(RUV_ORDER_HOLD)

	if(order != RUV_ORDER_ATTACK || isturf(order_target))
		engage_hostiles()

/mob/living/simple_animal/ruv/proc/attack_order_target(mob/living/target)
	if(isliving(target) && target.stat == DEAD)
		set_order(RUV_ORDER_HOLD)
		return

	if(istype(module, /obj/item/ruv_module/sentry))
		var/obj/item/ruv_module/sentry/sentry_module = module
		if(sentry_module.can_hit(target, src))
			stop_walking()
			sentry_module.fire(target, src)
		else
			move_towards(target)
		return

	if(istype(module, /obj/item/ruv_module/arm))
		var/obj/item/ruv_module/arm/arm_module = module
		if(!isliving(target))
			set_order(RUV_ORDER_HOLD)
		else if(!Adjacent(target))
			move_towards(target)
		else
			stop_walking()
			arm_module.strike(target, src)
		return

	set_order(RUV_ORDER_HOLD)

/// Lets the sentry shoot at whatever hostile is closest while the RUV goes about its order
/mob/living/simple_animal/ruv/proc/engage_hostiles()
	var/obj/item/ruv_module/sentry/sentry_module = module
	if(!istype(sentry_module) || !sentry_module.magazine?.current_rounds)
		return
	var/mob/living/closest
	var/closest_distance = INFINITY
	for(var/mob/living/potential_target in range(sentry_module.range, src))
		var/distance = get_dist(src, potential_target)
		if(distance >= closest_distance || !is_hostile(potential_target) || !has_clear_line(potential_target))
			continue
		closest = potential_target
		closest_distance = distance
	if(closest)
		sentry_module.fire(closest, src)

// Walking

/mob/living/simple_animal/ruv/proc/move_towards(atom/target)
	var/turf/destination = get_turf(target)
	if(!destination || destination.z != z)
		return
	if((!length(current_path) || path_destination != destination) && world.time >= next_path_time)
		next_path_time = world.time + 1 SECONDS
		path_destination = destination
		SSpathfinding.calculate_path(src, destination, RUV_PATH_RANGE, src, CALLBACK(src, PROC_REF(set_path)), list(src, target, pulling))
	if(length(current_path) && !walk_timer)
		path_step()

/mob/living/simple_animal/ruv/proc/set_path(list/path)
	current_path = path
	if(length(current_path) && !walk_timer && mode == RUV_MODE_AUTO)
		path_step()

/mob/living/simple_animal/ruv/proc/stop_walking()
	current_path = null
	path_destination = null
	if(walk_timer)
		deltimer(walk_timer)
		walk_timer = null
	SSpathfinding.stop_calculating_path(src)

/mob/living/simple_animal/ruv/proc/path_step()
	walk_timer = null
	if(mode != RUV_MODE_AUTO || stat == DEAD || !length(current_path) || !powered || reached_order_target())
		current_path = null
		return
	var/turf/next_turf = current_path[length(current_path)]
	if(get_dist(src, next_turf) > 1)
		current_path = null
		return
	if(world.time >= next_step_time)
		if(try_step(get_dir(src, next_turf)) || loc == next_turf)
			current_path.len--
		else
			// Something stepped into the way, look for another way around it
			current_path = null
			return
	walk_timer = addtimer(CALLBACK(src, PROC_REF(path_step)), max(next_step_time - world.time, world.tick_lag), TIMER_STOPPABLE)

/// Whether the RUV is close enough to do what it was ordered and should stop walking
/mob/living/simple_animal/ruv/proc/reached_order_target()
	var/atom/order_target = order_target_ref?.resolve()
	if(!order_target)
		return TRUE
	switch(order)
		if(RUV_ORDER_FOLLOW)
			return get_dist(src, order_target) <= RUV_FOLLOW_DISTANCE
		if(RUV_ORDER_INTERACT)
			return Adjacent(order_target)
		if(RUV_ORDER_ATTACK)
			if(isturf(order_target))
				return loc == order_target
			var/obj/item/ruv_module/sentry/sentry_module = module
			if(istype(sentry_module))
				return sentry_module.can_hit(order_target, src)
			return Adjacent(order_target)
	return TRUE

// How much a blocker costs an RUV looking for a path, see SSpathfinding

/atom/proc/ruv_obstacle(mob/living/simple_animal/ruv/bot, turf/target)
	if(get_turf(src) == target)
		return 0
	return INFINITY

/mob/living/ruv_obstacle(mob/living/simple_animal/ruv/bot, turf/target)
	// Mobs walk away or get swapped with
	return 5

/obj/structure/ruv_obstacle(mob/living/simple_animal/ruv/bot, turf/target)
	if(!density)
		return 0
	return ..()

/obj/structure/machinery/door/ruv_obstacle(mob/living/simple_animal/ruv/bot, turf/target)
	if(!density)
		return 0
	// The RUV carries no ID, so it gets through only the doors that open for anyone
	if(check_access(null))
		return 3
	return INFINITY

/obj/structure/machinery/door/airlock/ruv_obstacle(mob/living/simple_animal/ruv/bot, turf/target)
	if(density && (locked || welded || !arePowerSystemsOn()))
		return INFINITY
	return ..()
