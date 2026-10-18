/obj/item/hardpoint
	/// world.time when the vehicle AI finishes reloading this hardpoint, 0 if it isn't reloading
	var/ai_reload_finish = 0

/datum/vehicle_ai_brain
	/// If TRUE, empty magazines are replaced with new ones once the backup clips run out
	var/infinite_ammo = FALSE
	/// How long the AI takes to swap a magazine
	var/reload_time = 5 SECONDS
	/// How long automatic weapons fire before the AI lets go of the trigger
	var/autofire_length = 1.5 SECONDS
	/// Explosive and incendiary weapons won't fire at targets closer than this
	var/area_weapon_min_range = 4
	/// Explosive and incendiary weapons won't fire if a friendly is this close to the target
	var/danger_close_range = 3
	/// The direction the turret is about to turn to, a quarter turn from where it faces
	var/turret_turn_dir

	/// Ticks down while the turret is winding up to turn
	COOLDOWN_DECLARE(turret_turn)

/// Returns all installed hardpoints the AI can shoot enemies with
/datum/vehicle_ai_brain/proc/get_weapons()
	RETURN_TYPE(/list)
	. = list()
	for(var/obj/item/hardpoint/hardpoint as anything in vehicle.get_hardpoints_copy())
		if(is_ai_weapon(hardpoint))
			. += hardpoint

/datum/vehicle_ai_brain/proc/is_ai_weapon(obj/item/hardpoint/hardpoint)
	if(!istype(hardpoint, /obj/item/hardpoint/primary) && !istype(hardpoint, /obj/item/hardpoint/secondary) && !istype(hardpoint, /obj/item/hardpoint/special))
		return FALSE
	if(!hardpoint.activatable || !hardpoint.ammo)
		return FALSE
	if(istype(hardpoint, /obj/item/hardpoint/secondary/small_flamer))
		return TRUE
	var/datum/ammo/ammo_datum = GLOB.ammo_list[hardpoint.ammo.default_ammo]
	if(!ammo_datum || istype(ammo_datum, /datum/ammo/flare) || istype(ammo_datum, /datum/ammo/grenade_container/smoke))
		return FALSE
	return TRUE

/datum/vehicle_ai_brain/proc/get_weapon_range(obj/item/hardpoint/weapon)
	if(istype(weapon, /obj/item/hardpoint/secondary/small_flamer))
		var/obj/item/hardpoint/secondary/small_flamer/flamer = weapon
		return flamer.max_range
	var/datum/ammo/ammo_datum = GLOB.ammo_list[weapon.ammo.default_ammo]
	return ammo_datum.max_range

/// TRUE for weapons that hurt everyone around where they hit, like cannons and flamers
/datum/vehicle_ai_brain/proc/is_area_weapon(obj/item/hardpoint/weapon)
	if(istype(weapon, /obj/item/hardpoint/secondary/small_flamer))
		return TRUE
	var/datum/ammo/ammo_datum = GLOB.ammo_list[weapon.ammo.default_ammo]
	if(istype(ammo_datum, /datum/ammo/flamethrower) || istype(ammo_datum, /datum/ammo/grenade_container))
		return TRUE
	return ammo_datum.flags_ammo_behavior & (AMMO_EXPLOSIVE|AMMO_ROCKET)

/datum/vehicle_ai_brain/proc/has_iff(obj/item/hardpoint/weapon)
	return LAZYACCESS(weapon.traits_to_give, /datum/element/bullet_trait_iff)

/// Returns the rotatable turret of the vehicle, if it has one
/datum/vehicle_ai_brain/proc/get_turret()
	RETURN_TYPE(/obj/item/hardpoint/holder)
	for(var/obj/item/hardpoint/holder/holder in vehicle.hardpoints)
		if(istype(holder, /obj/item/hardpoint/holder/tank_turret) || istype(holder, /obj/item/hardpoint/holder/apc_turret) || istype(holder, /obj/item/hardpoint/holder/humvee_turret))
			return holder

/// TRUE if the vehicle has a turret that the AI can turn
/datum/vehicle_ai_brain/proc/has_working_turret()
	var/obj/item/hardpoint/holder/turret = get_turret()
	return turret && turret.health > 0

/// TRUE if the weapon isn't broken and has ammunition or can be reloaded
/datum/vehicle_ai_brain/proc/weapon_can_fire(obj/item/hardpoint/weapon)
	if(weapon.health <= 0)
		return FALSE

	var/obj/item/hardpoint/holder/weapon_holder = weapon.loc
	if(istype(weapon_holder) && (weapon_holder.health <= 0))
		return FALSE

	return infinite_ammo || (weapon.ammo?.current_rounds > 0) || LAZYLEN(weapon.backup_clips) || find_crew_magazine(weapon)

/// TRUE if a seated crewman can shoot back with one of the weapons, else the vehicle is better off driving away
/datum/vehicle_ai_brain/proc/can_fight_back()
	for(var/obj/item/hardpoint/weapon as anything in get_weapons())
		if(can_use_seat(weapon.allowed_seat) && weapon_can_fire(weapon))
			return TRUE
	return FALSE

/// Shoots every weapon that can hit the target and turns the turret towards it. Returns TRUE if anything fired
/datum/vehicle_ai_brain/proc/fire_weapons(atom/target)
	. = FALSE
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return

	var/obj/item/hardpoint/holder/turret = get_turret()
	var/turret_should_turn = FALSE
	for(var/obj/item/hardpoint/weapon as anything in get_weapons())
		if(!can_use_seat(weapon.allowed_seat))
			continue

		if(weapon.health <= 0)
			stop_weapon(weapon)
			continue

		// The turret keeps turning to the target while it is out of reach or the gun reloads
		if(!weapon.in_firing_arc(target))
			stop_weapon(weapon)
			if(turret && weapon.loc == turret)
				turret_should_turn = TRUE
			continue

		if(weapon.ammo.current_rounds <= 0)
			stop_weapon(weapon)
			continue

		var/turf/muzzle_turf = weapon.get_origin_turf()
		var/distance = get_dist(muzzle_turf, target_turf)
		if(distance > min(get_weapon_range(weapon), get_engage_distance(target)))
			stop_weapon(weapon)
			continue

		var/area_weapon = is_area_weapon(weapon)
		if(area_weapon && (distance < area_weapon_min_range || (target_turf in vehicle.locs)))
			stop_weapon(weapon)
			continue

		if(!firing_line_clear(muzzle_turf, target_turf, has_iff(weapon)))
			stop_weapon(weapon)
			continue

		if(area_weapon && friendly_near(target_turf))
			stop_weapon(weapon)
			continue

		fire_weapon(weapon, target)
		. = TRUE

	if(turret_should_turn)
		aim_turret(turret, target)

/datum/vehicle_ai_brain/proc/fire_weapon(obj/item/hardpoint/weapon, atom/target)
	// Already shooting, just keep the aim on the target
	if(weapon.auto_firing || weapon.burst_firing)
		weapon.set_target(target)
		return

	if(!COOLDOWN_FINISHED(weapon, fire_cooldown))
		return

	// The crewman in the seat is the shooter, giving the shot its IFF
	weapon.start_fire(vehicle.get_seat_mob(weapon.allowed_seat), target, get_turf(target))
	if(istype(weapon, /obj/item/hardpoint/primary))
		crew_say(fire_lines, weapon.allowed_seat, chance = 50)
	if(weapon.gun_firemode == GUN_FIREMODE_AUTOMATIC)
		addtimer(CALLBACK(src, PROC_REF(stop_weapon), weapon), autofire_length, TIMER_UNIQUE|TIMER_OVERRIDE)

/// Lets go of the trigger of an automatic weapon
/datum/vehicle_ai_brain/proc/stop_weapon(obj/item/hardpoint/weapon)
	if(QDELETED(weapon) || !weapon.auto_firing)
		return
	weapon.stop_fire()

/datum/vehicle_ai_brain/proc/stop_all_weapons()
	if(!vehicle)
		return
	for(var/obj/item/hardpoint/weapon as anything in get_weapons())
		if(can_use_seat(weapon.allowed_seat))
			stop_weapon(weapon)

/// Reloads every empty weapon the AI may use, in and out of combat
/datum/vehicle_ai_brain/proc/handle_reloads()
	for(var/obj/item/hardpoint/weapon as anything in get_weapons())
		if(weapon.health > 0 && weapon.ammo.current_rounds <= 0 && can_use_seat(weapon.allowed_seat))
			handle_reload(weapon)

/// Swaps the empty magazine of a weapon after reload_time
/datum/vehicle_ai_brain/proc/handle_reload(obj/item/hardpoint/weapon)
	var/mob/living/carbon/human/loader = get_loader()
	if(!loader)
		weapon.ai_reload_finish = 0
		return

	if(!weapon.ai_reload_finish)
		if(LAZYLEN(weapon.backup_clips) || load_crew_magazine(weapon) || infinite_ammo)
			weapon.ai_reload_finish = world.time + reload_time
			weapon.ai_dry_called = FALSE
			crewman_say(loader, reload_lines)
		else if(!weapon.ai_dry_called)
			weapon.ai_dry_called = TRUE
			crewman_say(loader, dry_lines, important = TRUE)
		return

	if(world.time < weapon.ai_reload_finish)
		return
	weapon.ai_reload_finish = 0

	var/obj/item/ammo_magazine/hardpoint/new_magazine
	if(LAZYLEN(weapon.backup_clips))
		new_magazine = weapon.backup_clips[1]
		LAZYREMOVE(weapon.backup_clips, new_magazine)
	else if(infinite_ammo)
		new_magazine = new weapon.ammo.type(weapon)
	if(!new_magazine)
		return

	// The crew drops the empty magazine like the weapons loader does
	weapon.ammo.forceMove(get_turf(loader))
	weapon.ammo.update_icon()
	weapon.ammo = new_magazine
	crewman_say(loader, loaded_lines)

/// TRUE if a shot from the muzzle won't be stopped by walls or hit a friendly on the way
/datum/vehicle_ai_brain/proc/firing_line_clear(turf/muzzle_turf, turf/target_turf, iff = FALSE)
	for(var/turf/line_turf as anything in get_line(muzzle_turf, target_turf))
		if(line_turf == target_turf)
			return TRUE

		if(line_turf.density)
			return FALSE

		if(iff || (line_turf in vehicle.locs))
			continue

		for(var/mob/living/carbon/human/possible_friendly in line_turf)
			if(possible_friendly.body_position == LYING_DOWN || possible_friendly.stat == DEAD)
				continue
			if(faction_check(possible_friendly))
				return FALSE

	return TRUE

/// TRUE if a friendly would be caught in an explosion or fire at the target turf
/datum/vehicle_ai_brain/proc/friendly_near(turf/target_turf)
	for(var/mob/living/carbon/human/possible_friendly in range(danger_close_range, target_turf))
		if(possible_friendly.stat != DEAD && faction_check(possible_friendly))
			return TRUE
	return FALSE

/// Turns the turret towards the target like a gunner would: a quarter turn at a time, each after the turret's windup
/datum/vehicle_ai_brain/proc/aim_turret(obj/item/hardpoint/holder/turret, atom/target)
	if(!turret || turret.health <= 0 || !can_use_seat(VEHICLE_GUNNER))
		return

	var/desired_dir = get_cardinal_dir_to(target)
	if(turret.dir == desired_dir)
		turret_turn_dir = null
		return

	// To turn around, go through the side the target is closer to
	var/step_dir = desired_dir
	if(desired_dir == turn(turret.dir, 180))
		var/target_angle = Get_Angle(get_turf(vehicle), get_turf(target))
		var/left_dir = turn(turret.dir, 90)
		var/right_dir = turn(turret.dir, -90)
		step_dir = (angle_between(dir2angle(left_dir), target_angle) < angle_between(dir2angle(right_dir), target_angle)) ? left_dir : right_dir

	// Restart the windup if the target moved to another side, so the turret doesn't jitter between two
	if(turret_turn_dir != step_dir)
		turret_turn_dir = step_dir
		COOLDOWN_START(src, turret_turn, get_turret_windup(turret))
		return

	if(!COOLDOWN_FINISHED(src, turret_turn))
		return

	turret_turn_dir = null
	rotate_turret(turret, turning_angle(turret.dir, step_dir))

/// Returns the smallest angle between two angles in degrees, 0 to 180
/datum/vehicle_ai_brain/proc/angle_between(angle_a, angle_b)
	var/difference = abs(angle_a - angle_b) % 360
	return difference > 180 ? 360 - difference : difference

/datum/vehicle_ai_brain/proc/get_turret_windup(obj/item/hardpoint/holder/turret)
	if(istype(turret, /obj/item/hardpoint/holder/tank_turret))
		var/obj/item/hardpoint/holder/tank_turret/tank_turret = turret
		return tank_turret.rotation_windup
	if(istype(turret, /obj/item/hardpoint/holder/apc_turret))
		var/obj/item/hardpoint/holder/apc_turret/apc_turret = turret
		return apc_turret.rotation_windup
	if(istype(turret, /obj/item/hardpoint/holder/humvee_turret))
		var/obj/item/hardpoint/holder/humvee_turret/humvee_turret = turret
		return humvee_turret.rotation_windup
	return 0.5 SECONDS

/datum/vehicle_ai_brain/proc/rotate_turret(obj/item/hardpoint/holder/turret, deg)
	// Each turret has its own rotate() that skips the gyrostabilizer with the second argument
	if(istype(turret, /obj/item/hardpoint/holder/tank_turret))
		var/obj/item/hardpoint/holder/tank_turret/tank_turret = turret
		tank_turret.rotate(deg, TRUE)
	else if(istype(turret, /obj/item/hardpoint/holder/apc_turret))
		var/obj/item/hardpoint/holder/apc_turret/apc_turret = turret
		apc_turret.rotate(deg, TRUE)
	else if(istype(turret, /obj/item/hardpoint/holder/humvee_turret))
		var/obj/item/hardpoint/holder/humvee_turret/humvee_turret = turret
		humvee_turret.rotate(deg, TRUE)
	else
		return

	vehicle.update_icon()

/// Returns the direction the hull should face to aim its weapons at the target, or null if it doesn't need to turn
/datum/vehicle_ai_brain/proc/get_hull_aim_dir(atom/target)
	// The turret aims for us
	if(has_working_turret())
		return null

	var/desired_dir = get_cardinal_dir_to(target)
	if(vehicle.dir == desired_dir)
		return null

	for(var/obj/item/hardpoint/weapon as anything in get_weapons())
		if(weapon.health <= 0 || !weapon.firing_arc || !can_use_seat(weapon.allowed_seat))
			continue
		if(!weapon.in_firing_arc(target))
			return desired_dir
	return null
