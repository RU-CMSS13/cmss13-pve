/// Enemies this close make a gunner leave a gun that can't be turned to them, and the gun ignores those farther out of its reach
#define MOUNTED_GUN_ABANDON_RANGE 3
/// The farthest a gunner goes to get back on its gun
#define MOUNTED_GUN_RETURN_RANGE 10

/datum/human_ai_brain
	/// The mounted machine gun the AI was told to man
	var/obj/structure/machinery/m56d_hmg/mounted_gun
	COOLDOWN_DECLARE(mounted_gun_cooldown)

/datum/human_ai_brain/proc/set_mounted_gun(obj/structure/machinery/m56d_hmg/gun)
	if(mounted_gun)
		UnregisterSignal(mounted_gun, COMSIG_PARENT_QDELETING)
	mounted_gun = gun
	if(mounted_gun)
		RegisterSignal(mounted_gun, COMSIG_PARENT_QDELETING, PROC_REF(on_mounted_gun_delete))

/datum/human_ai_brain/proc/on_mounted_gun_delete(datum/source, force)
	SIGNAL_HANDLER
	mounted_gun = null

/// Returns TRUE if we are behind the handles of our mounted gun
/datum/human_ai_brain/proc/is_manning_gun()
	return mounted_gun && (mounted_gun.operator == tied_human)

/// Returns FALSE for targets that our mounted gun can't be brought to bear on and that are too far to leave the gun for
/datum/human_ai_brain/proc/can_engage_from_gun(atom/target)
	if(!is_manning_gun())
		return TRUE

	if(get_dist(tied_human, target) <= MOUNTED_GUN_ABANDON_RANGE)
		return TRUE

	return mounted_gun.can_aim_at(target)

/// Returns ammunition that reloads our mounted gun, from our gear or from the ground next to the gun
/datum/human_ai_brain/proc/find_mounted_gun_ammo()
	RETURN_TYPE(/obj/item/ammo_magazine)

	var/ammo_type = mounted_gun?.ammo_box_type
	if(!ammo_type)
		return

	for(var/obj/item/ammo_magazine/ammo as anything in equipment_map[HUMAN_AI_AMMUNITION])
		if(istype(ammo, ammo_type) && (ammo.current_rounds > 0))
			return ammo

	for(var/obj/item/ammo_magazine/ammo in range(1, mounted_gun))
		if(istype(ammo, ammo_type) && isturf(ammo.loc) && (ammo.current_rounds > 0))
			return ammo

/datum/ai_action/man_mounted_gun
	name = "Man Mounted Gun"
	action_flags = ACTION_USING_HANDS | ACTION_USING_LEGS
	// The gun outguns anything we carry, so stop shooting or picking things up and get back on it
	preempts_actions = TRUE
	/// The view distance of the AI before it got on the gun
	var/initial_view
	/// If TRUE, we are putting a new ammo box in
	var/reloading = FALSE
	/// If TRUE, we have the trigger held down
	var/firing = FALSE
	/// If TRUE, the gun got hot and we wait for it to cool down before shooting again
	var/cooling_down = FALSE
	/// When the current burst ends
	var/burst_end_time = 0
	COOLDOWN_DECLARE(burst_pause_cooldown)

/datum/ai_action/man_mounted_gun/get_weight(datum/human_ai_brain/brain)
	var/obj/structure/machinery/m56d_hmg/gun = brain.mounted_gun
	if(QDELETED(gun) || !COOLDOWN_FINISHED(brain, mounted_gun_cooldown))
		return 0

	var/mob/living/carbon/human/tied_human = brain.tied_human
	if(gun.operator && (gun.operator != tied_human))
		return 0

	if((gun.z != tied_human.z) || (get_dist(gun, tied_human) > MOUNTED_GUN_RETURN_RANGE))
		return 0

	// Orders from a game master come first
	if(brain.quick_approach)
		return 0

	if(!gun.rounds && !brain.find_mounted_gun_ammo())
		return 0

	if(gun.operator != tied_human)
		// Rather fight than walk to the gun with an enemy in our face
		if(brain.current_target && (get_dist(tied_human, brain.current_target) <= MOUNTED_GUN_ABANDON_RANGE))
			return 0

		if(brain.hold_position && (get_dist(tied_human, gun) > 1))
			return 0

		// Don't drop what is in our hands halfway through using it
		if(brain.healing_someone || brain.has_ongoing_action(/datum/ai_action/reload) || brain.has_ongoing_action(/datum/ai_action/throw_grenade))
			return 0

		if(brain.wants_treatment())
			return 0

	return 20

/datum/ai_action/man_mounted_gun/Added()
	initial_view = brain.view_distance

/datum/ai_action/man_mounted_gun/Destroy(force, ...)
	var/obj/structure/machinery/m56d_hmg/gun = brain.mounted_gun
	if(gun)
		stop_firing(gun)
	brain.view_distance = initial_view
	return ..()

/datum/ai_action/man_mounted_gun/trigger_action()
	. = ..()

	var/obj/structure/machinery/m56d_hmg/gun = brain.mounted_gun
	var/mob/living/carbon/human/tied_human = brain.tied_human
	if(QDELETED(gun) || (gun.operator && (gun.operator != tied_human)))
		return ONGOING_ACTION_COMPLETED

	if(reloading)
		return ONGOING_ACTION_UNFINISHED

	if(gun.operator != tied_human)
		return get_on_gun(gun)

	// Players get their view pushed forward when on the gun, this is the same reach
	brain.view_distance = GLOB.world_view_size + (gun.zoom ? 5 : 2)
	brain.end_cover()

	var/atom/target = brain.current_target
	if(target && !brain.can_engage_from_gun(target))
		brain.lose_target()
		target = null

	// Flanked where the gun can't turn, so fight with what we carry
	if(target && (get_dist(tied_human, target) <= MOUNTED_GUN_ABANDON_RANGE) && !gun.can_aim_at(target))
		leave_gun(gun, 15 SECONDS)
		return ONGOING_ACTION_COMPLETED

	if(brain.quick_approach || (!target && brain.wants_treatment()))
		leave_gun(gun, 10 SECONDS)
		return ONGOING_ACTION_COMPLETED

	if(!gun.rounds)
		stop_firing(gun)
		var/obj/item/ammo_magazine/ammo = brain.find_mounted_gun_ammo()
		if(!ammo)
			leave_gun(gun, 30 SECONDS)
			return ONGOING_ACTION_COMPLETED

		reload_gun(gun, ammo)
		return ONGOING_ACTION_UNFINISHED

	if(!target && brain.target_turf && !COOLDOWN_FINISHED(brain, fire_offscreen))
		target = brain.target_turf

	operate_gun(gun, target)
	return ONGOING_ACTION_UNFINISHED

/datum/ai_action/man_mounted_gun/proc/get_on_gun(obj/structure/machinery/m56d_hmg/gun)
	var/mob/living/carbon/human/tied_human = brain.tied_human
	var/turf/handles_turf = get_handles_turf(gun)
	if(!handles_turf)
		COOLDOWN_START(brain, mounted_gun_cooldown, 5 SECONDS)
		return ONGOING_ACTION_COMPLETED

	if(get_turf(tied_human) != handles_turf)
		if(!brain.move_to_next_turf(handles_turf))
			COOLDOWN_START(brain, mounted_gun_cooldown, 5 SECONDS)
			return ONGOING_ACTION_COMPLETED
		return ONGOING_ACTION_UNFINISHED

	// Both hands go on the handles
	brain.holster_primary()
	for(var/obj/item/held_item in list(tied_human.l_hand, tied_human.r_hand))
		var/storage_id = brain.storage_has_room(held_item)
		if(!storage_id || !brain.store_item(held_item, storage_id, brain.get_equipment_map_type(held_item)))
			tied_human.drop_held_item(held_item)

	gun.try_mount_gun(tied_human)
	if(gun.operator != tied_human)
		COOLDOWN_START(brain, mounted_gun_cooldown, 5 SECONDS)
		return ONGOING_ACTION_COMPLETED

	brain.end_cover()
	return ONGOING_ACTION_UNFINISHED

/// Returns a free turf behind the gun to man it from, preferring the one we stand on
/datum/ai_action/man_mounted_gun/proc/get_handles_turf(obj/structure/machinery/m56d_hmg/gun)
	var/list/turf/handles_turfs = list()
	for(var/direction in reverse_nearby_direction(gun.dir))
		var/turf/handles_turf = get_step(gun, direction)
		if(handles_turf == get_turf(brain.tied_human))
			return handles_turf

		if(!handles_turf || handles_turf.density)
			continue

		var/blocked = FALSE
		for(var/obj/structure/blocker in handles_turf)
			if(blocker.density)
				blocked = TRUE
				break

		if(!blocked)
			handles_turfs += handles_turf

	if(length(handles_turfs))
		return handles_turfs[1]

/datum/ai_action/man_mounted_gun/proc/leave_gun(obj/structure/machinery/m56d_hmg/gun, cooldown)
	stop_firing(gun)
	if(gun.operator == brain.tied_human)
		brain.tied_human.unset_interaction()
	COOLDOWN_START(brain, mounted_gun_cooldown, cooldown)

/datum/ai_action/man_mounted_gun/proc/operate_gun(obj/structure/machinery/m56d_hmg/gun, atom/target)
	if(istype(gun, /obj/structure/machinery/m56d_hmg/auto))
		var/obj/structure/machinery/m56d_hmg/auto/m2c = gun
		// Overheating jams the gun and damages it, so let it cool down well before that
		if(m2c.overheat_value >= m2c.overheat_threshold * 0.7)
			cooling_down = TRUE
		else if(m2c.overheat_value <= m2c.overheat_threshold * 0.3)
			cooling_down = FALSE

		if(target && !m2c.in_firing_arc(target) && m2c.can_rotate_to(target) && (world.time > m2c.rotate_timer))
			m2c.rotate_timer = world.time + 0.4 SECONDS
			m2c.rotate_to(brain.tied_human, target)

	if(!target || cooling_down || !gun.in_firing_arc(target) || !firing_line_clear(gun, target))
		stop_firing(gun)
		return

	if(firing && (world.time > burst_end_time))
		stop_firing(gun)
		COOLDOWN_START(src, burst_pause_cooldown, rand(4, 8))
		return

	if(!firing)
		if(!COOLDOWN_FINISHED(src, burst_pause_cooldown))
			return

		firing = TRUE
		burst_end_time = world.time + rand(1.5 SECONDS, 3 SECONDS)

	brain.tied_human.face_dir(gun.dir)
	gun.set_target(target)
	// Does nothing if the gun is already firing, and restarts it if something stopped it
	SEND_SIGNAL(gun, COMSIG_GUN_FIRE)

/datum/ai_action/man_mounted_gun/proc/stop_firing(obj/structure/machinery/m56d_hmg/gun)
	if(!firing)
		return

	firing = FALSE
	gun.stop_fire()

/// Returns TRUE if no wall or standing friendly is between the gun and the target
/datum/ai_action/man_mounted_gun/proc/firing_line_clear(obj/structure/machinery/m56d_hmg/gun, atom/target)
	for(var/turf/line_turf as anything in get_line(get_turf(gun), get_turf(target), include_start_atom = FALSE))
		if(line_turf.density)
			return FALSE

		for(var/mob/living/carbon/human/possible_friendly in line_turf)
			if((possible_friendly.body_position == STANDING_UP) && brain.faction_check(possible_friendly))
				return FALSE

	return !brain.ally_behind_target(get_turf(gun), get_turf(target))

/datum/ai_action/man_mounted_gun/proc/reload_gun(obj/structure/machinery/m56d_hmg/gun, obj/item/ammo_magazine/ammo)
	set waitfor = FALSE

	reloading = TRUE
	var/mob/living/carbon/human/tied_human = brain.tied_human
	brain.say_reload_line()
	if(isturf(ammo.loc))
		tied_human.put_in_active_hand(ammo)
	else
		brain.equip_item_from_equipment_map(HUMAN_AI_AMMUNITION, ammo)

	if(tied_human.is_holding(ammo))
		sleep(brain.short_action_delay * brain.action_delay_mult)
		if(!QDELETED(gun) && !QDELETED(ammo) && !tied_human.is_mob_incapacitated() && tied_human.is_holding(ammo))
			gun.attackby(ammo, tied_human)

		// The handles need both hands again
		if(!QDELETED(ammo) && tied_human.is_holding(ammo))
			var/storage_id = brain.storage_has_room(ammo)
			if(!storage_id || !brain.store_item(ammo, storage_id, HUMAN_AI_AMMUNITION))
				tied_human.drop_held_item(ammo)

	reloading = FALSE

#undef MOUNTED_GUN_ABANDON_RANGE
#undef MOUNTED_GUN_RETURN_RANGE
