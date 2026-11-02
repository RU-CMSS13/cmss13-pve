/mob/living/simple_animal/ruv
	name = "\improper RUV-7 remote utility vehicle"
	desc = "A tracked remote utility vehicle, driven from a hand-held control unit. A hardpoint on its hull takes either a manipulator arm or a light sentry module."
	icon = 'core_ru/icons/ruv.dmi'
	icon_state = "empty"
	icon_living = "empty"
	icon_dead = "empty"
	health = 200
	maxHealth = 200
	mob_size = MOB_SIZE_HUMAN
	faction = FACTION_MARINE
	wander = FALSE
	stop_automated_movement = TRUE
	response_help = "pats"
	response_disarm = "shoves"
	response_harm = "punches"
	harm_intent_damage = 0
	custom_slashed_sound = "alien_claw_metal"
	speak_emote = list("beeps")
	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	minbodytemp = 0
	maxbodytemp = 1000
	unsuitable_atoms_damage = 0
	black_market_value = 50
	dead_black_market_value = 0

	/// Prepended to the body icon states for a livery, the light overlays are shared
	var/body_prefix = ""
	/// Starts as a type path, replaced by the instance in Initialize()
	var/obj/item/cell/ruv/cell = /obj/item/cell/ruv
	/// Starts as a type path, replaced by the instance in Initialize()
	var/obj/item/ruv_module/module
	var/obj/item/device/ruv_controller/controller
	/// Who holds the linked control unit in hand and gives the orders
	var/mob/living/carbon/human/commander
	/// Who looks through the RUV's camera right now, always the commander too
	var/mob/living/carbon/human/operator
	var/mode = RUV_MODE_MANUAL
	var/order = RUV_ORDER_HOLD
	/// What the current order is about: whom to follow, what to attack or interact with
	var/datum/weakref/order_target_ref
	/// Who gave the current order, followed after the arm grabs something
	var/datum/weakref/order_giver_ref
	/// The order chosen with an action button that waits for the commander to click its target
	var/pending_order
	var/powered = FALSE
	var/next_step_time = 0
	var/image/light_overlay
	var/atom/movable/screen/ruv_status/status_display
	var/list/datum/action/ruv/commander_actions = list()
	var/image/order_marker

	/// Turfs from the destination back to the next step, in the order SSpathfinding returns them
	var/list/turf/current_path
	var/turf/path_destination
	var/next_path_time = 0
	var/walk_timer

/mob/living/simple_animal/ruv/arm
	module = /obj/item/ruv_module/arm

/mob/living/simple_animal/ruv/sentry
	module = /obj/item/ruv_module/sentry

/mob/living/simple_animal/ruv/Initialize()
	. = ..()
	GLOB.ruvs += src
	faction_group = list(faction)
	if(ispath(cell))
		cell = new cell(src)
	if(ispath(module))
		var/module_type = module
		module = null
		install_module(new module_type(src))
	powered = has_power()
	status_display = new
	update_bot_icon()
	START_PROCESSING(SSfastobj, src)

/mob/living/simple_animal/ruv/Destroy()
	clear_commander()
	stop_walking()
	STOP_PROCESSING(SSfastobj, src)
	GLOB.ruvs -= src
	controller?.unlink_bot()
	QDEL_NULL(cell)
	QDEL_NULL(module)
	QDEL_NULL(status_display)
	return ..()

/mob/living/simple_animal/ruv/proc/update_bot_icon()
	var/base_state = module ? module.bot_icon_state : "empty"
	icon_state = "[body_prefix][base_state]"
	icon_living = icon_state
	overlays -= light_overlay
	var/light_state = "green"
	if(!powered)
		light_state = "powerless"
	else if(mode == RUV_MODE_AUTO)
		light_state = "red"
	light_overlay = image(icon, "[base_state]+[light_state]")
	overlays += light_overlay
	var/obj/item/holder/ruv/holder = loc
	if(istype(holder))
		holder.update_from(src)

/mob/living/simple_animal/ruv/get_examine_text(mob/user)
	var/list/examine_lines = ..()
	// The last line is the simple animal one about wounds and bleeding, hull integrity replaces it
	examine_lines.len--
	. = examine_lines
	var/health_percent = floor(health / maxHealth * 100)
	. += SPAN_NOTICE("Hull integrity: [ruv_level_span(health_percent, "<b>[health_percent]%</b>")]")
	if(cell)
		var/charge_percent = floor(cell.percent())
		. += SPAN_NOTICE("Battery: [ruv_level_span(charge_percent, "<b>[charge_percent]%</b>")]")
	else
		. += SPAN_NOTICE("Battery: [SPAN_RED("<b>none</b>")]")
	if(module)
		. += SPAN_NOTICE("Module: <b>[module.name]</b>")
		var/module_status = module.get_status_text()
		if(module_status)
			. += module_status
	else
		. += SPAN_NOTICE("Module: [SPAN_ORANGE("<b>none</b>")]")
	if(mode == RUV_MODE_AUTO)
		. += SPAN_NOTICE("Mode: [SPAN_RED("<b>automatic</b>")], current order: <b>[order]</b>")
	else
		. += SPAN_NOTICE("Mode: [SPAN_GREEN("<b>manual</b>")]")
	. += SPAN_HELPFUL("Use an RUV control unit on it to link them; whoever holds the linked unit in hand commands it. Attach a module by hand and remove it with a screwdriver. Insert an RUV battery by hand and pry it out with a crowbar. Load sentry ammo drums straight into it. Repair the hull with a welder.")

/// Wraps the text in green, orange or red, depending on how much of something is left
/proc/ruv_level_span(percent, text)
	if(percent >= 60)
		return SPAN_GREEN(text)
	if(percent >= 25)
		return SPAN_ORANGE(text)
	return SPAN_RED(text)

/mob/living/simple_animal/ruv/process(delta_time)
	if(stat == DEAD)
		return PROCESS_KILL
	use_charge(RUV_IDLE_DRAIN * delta_time)
	update_status_display()
	if(mode == RUV_MODE_AUTO && powered)
		ai_process()

/mob/living/simple_animal/ruv/movement_delay()
	. = RUV_MOVE_DELAY
	if(pulling)
		. += RUV_PULL_SLOWDOWN
	move_delay = .

/mob/living/simple_animal/ruv/IsAdvancedToolUser()
	return istype(module, /obj/item/ruv_module/arm)

/mob/living/simple_animal/ruv/handle_blood_splatter(splatter_dir)
	if(prob(25))
		new /obj/effect/decal/cleanable/blood/oil(loc)

/mob/living/simple_animal/ruv/ai_check_stat(mob/living/carbon/xenomorph/X)
	return stat != DEAD

/mob/living/simple_animal/ruv/emp_act(severity)
	. = ..()
	if(cell)
		cell.use(min(cell.charge, cell.maxcharge / (severity * 2)))
		check_power()
	apply_damage(20 / severity, BURN)
	if(operator)
		to_chat(operator, SPAN_DANGER("The feed from [src] dissolves into static!"))
		disconnect()

// Damage and death

/mob/living/simple_animal/ruv/adjustBruteLoss(damage)
	. = ..()
	check_destroyed()

/mob/living/simple_animal/ruv/adjustFireLoss(damage)
	. = ..()
	check_destroyed()

/mob/living/simple_animal/ruv/proc/check_destroyed()
	if(health <= 0 && stat != DEAD)
		death(last_damage_data)

/mob/living/simple_animal/ruv/death(datum/cause_data/cause_data, gibbed = FALSE, deathmessage = "blows apart in a shower of sparks!", should_deathmessage = TRUE)
	. = ..()
	if(!.)
		return
	if(operator)
		to_chat(operator, SPAN_DANGER("You lose the feed from [src]!"))
	disconnect()
	stop_walking()
	stop_pulling()
	// It may die while carried, the parts still go on the floor
	var/turf/wreck_turf = get_turf(src)
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(5, 1, wreck_turf)
	sparks.start()
	playsound(wreck_turf, 'sound/effects/metal_crash.ogg', 50, TRUE)
	new /obj/effect/decal/cleanable/blood/gibs/robot(wreck_turf)
	if(module)
		uninstall_module(wreck_turf)
	if(cell)
		cell.forceMove(wreck_turf)
		cell.update_icon()
		cell = null
	QDEL_IN(src, 1)

// Power

/mob/living/simple_animal/ruv/proc/has_power()
	return cell?.charge > 0

/// Takes charge from the battery, returns FALSE if there was not enough
/mob/living/simple_animal/ruv/proc/use_charge(amount)
	if(!has_power())
		check_power()
		return FALSE
	if(!cell.use(amount))
		cell.charge = 0
		check_power()
		return FALSE
	check_power()
	return TRUE

/mob/living/simple_animal/ruv/proc/check_power()
	var/now_powered = has_power()
	if(now_powered == powered)
		return
	powered = now_powered
	update_bot_icon()
	update_status_display()
	if(!powered)
		stop_walking()
		playsound(loc, 'sound/machines/twobeep.ogg', 25, TRUE)
		visible_message(SPAN_WARNING("[src] whirs down as its lights start blinking."), null, null, 5)

// Movement

/// One step in the given direction, as fast as the RUV's motors allow
/mob/living/simple_animal/ruv/proc/try_step(direction)
	if(world.time < next_step_time || stat == DEAD || !isturf(loc) || is_mob_incapacitated())
		return FALSE
	if(!has_power())
		return FALSE
	next_step_time = world.time + movement_delay()
	var/turf/old_loc = loc
	Move(get_step(src, direction), direction)
	if(loc == old_loc)
		setDir(direction)
		return FALSE
	use_charge(RUV_STEP_COST)
	return TRUE

// Tools, modules and the battery

/mob/living/simple_animal/ruv/attackby(obj/item/item, mob/user)
	if(istype(item, /obj/item/device/ruv_controller))
		var/obj/item/device/ruv_controller/new_controller = item
		new_controller.link_bot(src, user)
		return

	if(istype(item, /obj/item/ruv_module))
		if(stat == DEAD)
			return
		if(module)
			to_chat(user, SPAN_WARNING("[src] already has \a [module] installed. Remove it with a screwdriver first."))
			return
		if(!do_after(user, 2 SECONDS * user.get_skill_duration_multiplier(SKILL_CONSTRUCTION), INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src))
			return
		if(module || !user.drop_inv_item_to_loc(item, src))
			return
		install_module(item)
		playsound(loc, 'sound/items/Screwdriver.ogg', 25, TRUE)
		user.visible_message(SPAN_NOTICE("[user] installs \a [item] on [src]."), SPAN_NOTICE("You install \the [item] on [src]."))
		return

	if(istype(item, /obj/item/cell))
		if(!istype(item, /obj/item/cell/ruv))
			to_chat(user, SPAN_WARNING("\The [item] doesn't fit [src]'s battery slot."))
			return
		if(cell)
			to_chat(user, SPAN_WARNING("[src] already has a battery. Pry it out with a crowbar first."))
			return
		if(!user.drop_inv_item_to_loc(item, src))
			return
		cell = item
		check_power()
		playsound(loc, 'sound/machines/click.ogg', 25, TRUE)
		user.visible_message(SPAN_NOTICE("[user] slots \a [item] into [src]."), SPAN_NOTICE("You slot \the [item] into [src]."))
		return

	if(istype(item, /obj/item/ammo_magazine/sentry))
		var/obj/item/ruv_module/sentry/sentry_module = module
		if(!istype(sentry_module))
			to_chat(user, SPAN_WARNING("[src] has no sentry module to load."))
			return
		sentry_module.load_magazine(item, user)
		return

	if(HAS_TRAIT(item, TRAIT_TOOL_SCREWDRIVER))
		if(!module)
			to_chat(user, SPAN_WARNING("[src] has no module to remove."))
			return
		user.visible_message(SPAN_NOTICE("[user] starts unscrewing \the [module] from [src]."), SPAN_NOTICE("You start unscrewing \the [module] from [src]."))
		if(!do_after(user, 2 SECONDS * user.get_skill_duration_multiplier(SKILL_CONSTRUCTION), INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src))
			return
		if(!module)
			return
		var/obj/item/ruv_module/removed = module
		uninstall_module(loc)
		user.put_in_hands(removed)
		playsound(loc, 'sound/items/Screwdriver.ogg', 25, TRUE)
		user.visible_message(SPAN_NOTICE("[user] removes \the [removed] from [src]."), SPAN_NOTICE("You remove \the [removed] from [src]."))
		return

	if(HAS_TRAIT(item, TRAIT_TOOL_CROWBAR))
		if(!cell)
			to_chat(user, SPAN_WARNING("[src] has no battery."))
			return
		if(!do_after(user, 1 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_GENERIC, src))
			return
		if(!cell)
			return
		var/obj/item/cell/removed = cell
		cell = null
		removed.update_icon()
		user.put_in_hands(removed)
		check_power()
		playsound(loc, 'sound/items/Crowbar.ogg', 25, TRUE)
		user.visible_message(SPAN_NOTICE("[user] pries \the [removed] out of [src]."), SPAN_NOTICE("You pry \the [removed] out of [src]."))
		return

	if(iswelder(item))
		repair(item, user)
		return

	if(istype(item, /obj/item/stack/medical))
		to_chat(user, SPAN_WARNING("[src] is a machine, bandages won't help it. Use a welder."))
		return

	return ..()

/mob/living/simple_animal/ruv/proc/repair(obj/item/tool/weldingtool/welder, mob/user)
	if(stat == DEAD)
		return
	if(!HAS_TRAIT(welder, TRAIT_TOOL_BLOWTORCH))
		to_chat(user, SPAN_WARNING("You need a stronger blowtorch!"))
		return
	if(health >= maxHealth)
		to_chat(user, SPAN_WARNING("[src] isn't in need of repairs."))
		return
	if(!welder.remove_fuel(1, user))
		return
	user.visible_message(SPAN_NOTICE("[user] begins repairing [src]."), SPAN_NOTICE("You begin repairing [src]."))
	if(!do_after(user, 3 SECONDS * user.get_skill_duration_multiplier(SKILL_CONSTRUCTION), INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_FRIENDLY, src))
		return
	health = min(health + 50, maxHealth)
	playsound(loc, 'sound/items/Welder2.ogg', 25, TRUE)
	user.visible_message(SPAN_NOTICE("[user] repairs [src]."), SPAN_NOTICE("You repair [src]."))
	update_status_display()

/mob/living/simple_animal/ruv/proc/install_module(obj/item/ruv_module/new_module)
	module = new_module
	new_module.forceMove(src)
	new_module.on_install(src)
	if(order == RUV_ORDER_INTERACT)
		set_order(RUV_ORDER_HOLD)
	update_bot_icon()
	update_commander_actions()

/mob/living/simple_animal/ruv/proc/uninstall_module(atom/drop_loc)
	var/obj/item/ruv_module/old_module = module
	module = null
	old_module.on_uninstall(src)
	old_module.forceMove(drop_loc)
	if(order == RUV_ORDER_INTERACT)
		set_order(RUV_ORDER_HOLD)
	update_bot_icon()
	update_commander_actions()

/mob/living/simple_animal/ruv/proc/set_faction_from(mob/living/carbon/human/user)
	faction = user.faction
	var/list/id_group = user.get_id_faction_group()
	var/list/user_group = user.faction_group
	if(islist(id_group))
		faction_group = id_group.Copy()
	else if(islist(user_group))
		faction_group = user_group.Copy()
	else
		faction_group = list(faction)

/// Whether the RUV should shoot at the mob on its own
/mob/living/simple_animal/ruv/proc/is_hostile(mob/living/target)
	if(target == src || target.stat == DEAD || target.invisibility || HAS_TRAIT(target, TRAIT_ABILITY_BURROWED))
		return FALSE
	if(!iscarbon(target) && !isruv(target))
		return FALSE
	if(target.faction == faction || target.get_target_lock(faction_group))
		return FALSE
	var/datum/human_ai_faction/our_faction = SShuman_ai.human_ai_factions[faction]
	if(our_faction && ((target.faction in our_faction.get_friendly_factions()) || (target.faction in our_faction.get_neutral_factions())))
		return FALSE
	return TRUE

/// Whether nothing solid or opaque stands between the RUV and the target
/mob/living/simple_animal/ruv/proc/has_clear_line(atom/target)
	for(var/turf/line_turf as anything in get_line(src, target, include_start_atom = FALSE))
		if(line_turf == get_turf(target))
			return TRUE
		if(line_turf.density || line_turf.opacity)
			return FALSE
		for(var/obj/structure/structure in line_turf)
			if(structure.opacity)
				return FALSE
	return TRUE
