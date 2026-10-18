/datum/vehicle_ai_brain
	/// Equipment preset of the crew spawned into the seats once the interior has loaded
	var/datum/equipment_preset/crew_preset
	/// Seats the crew is spawned into, most important first. When crew dies, the survivors move up this list
	var/list/crew_seats = list(VEHICLE_GUNNER, VEHICLE_DRIVER)
	/// Human AI crewmen of this vehicle
	var/list/mob/living/carbon/human/crew = list()
	/// If TRUE, the crew has already bailed out of the destroyed vehicle
	var/crew_evacuated = FALSE
	/// Assoc list of seat role : seat in the interior, see get_interior_seat()
	var/list/obj/structure/bed/chair/comfy/vehicle/interior_seats

/// Seats a human AI crewman of the given preset in each crew seat
/datum/vehicle_ai_brain/proc/spawn_crew()
	var/datum/equipment_preset/preset = crew_preset
	crew_preset = null
	for(var/seat_role in crew_seats)
		// Some vehicles only list a seat role once someone sits in it, so going by the seats inside
		if(vehicle.seats[seat_role])
			continue

		var/obj/structure/bed/chair/comfy/vehicle/seat = get_interior_seat(seat_role)
		if(!seat)
			continue

		var/mob/living/carbon/human/crewman = new(get_turf(seat))
		// Equipped first, the AI looks through its inventory when it is added
		arm_equipment(crewman, preset, TRUE)
		// Whatever the preset, the crew can sit in every seat of their vehicle
		if(crewman.skills && (crewman.skills.get_skill_level(SKILL_VEHICLE) < SKILL_VEHICLE_CREWMAN))
			crewman.skills.set_skill(SKILL_VEHICLE, SKILL_VEHICLE_CREWMAN)
		// A crew of another faction would fight for it once it bails out
		if(crewman.faction != faction)
			crewman.set_faction(faction)
		var/datum/component/human_ai/ai_component = crewman.AddComponent(/datum/component/human_ai)
		fill_ammo_rig(crewman)
		add_crewman(crewman)
		ai_component.ai_brain.vehicle_seat = seat
		seat.do_buckle(crewman, crewman)

/datum/vehicle_ai_brain/proc/add_crewman(mob/living/carbon/human/crewman)
	crew += crewman
	RegisterSignal(crewman, COMSIG_PARENT_QDELETING, PROC_REF(on_crewman_delete))
	RegisterSignal(crewman, COMSIG_MOB_DEATH, PROC_REF(on_crewman_death))

/datum/vehicle_ai_brain/proc/remove_crewman(mob/living/carbon/human/crewman)
	crew -= crewman
	UnregisterSignal(crewman, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH))
	var/datum/human_ai_brain/crewman_brain = crewman.get_ai_brain()
	if(crewman_brain)
		crewman_brain.vehicle_seat = null

/datum/vehicle_ai_brain/proc/on_crewman_delete(mob/living/carbon/human/crewman, force)
	SIGNAL_HANDLER
	remove_crewman(crewman)

/datum/vehicle_ai_brain/proc/on_crewman_death(mob/living/carbon/human/crewman)
	SIGNAL_HANDLER
	crew_say(crew_death_lines, important = TRUE)

/datum/vehicle_ai_brain/proc/get_interior_seat(seat_role)
	RETURN_TYPE(/obj/structure/bed/chair/comfy/vehicle)
	if(interior_seats)
		return interior_seats[seat_role]

	interior_seats = list()
	var/list/turf/bounds = vehicle.interior.get_bound_turfs()
	for(var/turf/interior_turf as anything in block(bounds[1], bounds[2]))
		for(var/obj/structure/bed/chair/comfy/vehicle/seat in interior_turf)
			interior_seats[seat.seat] = seat
	return interior_seats[seat_role]

/// Fills the crewman's vehicle ammo rig with magazines for the vehicle's weapons, main guns first
/datum/vehicle_ai_brain/proc/fill_ammo_rig(mob/living/carbon/human/crewman)
	var/obj/item/storage/belt/tank/ammo_rig = crewman.belt
	if(!istype(ammo_rig))
		return

	var/list/obj/item/hardpoint/weapons = list()
	for(var/obj/item/hardpoint/weapon as anything in get_weapons())
		if(istype(weapon, /obj/item/hardpoint/primary))
			weapons.Insert(1, weapon)
		else
			weapons += weapon

	// Go around the weapons until the rig is full
	var/added = TRUE
	while(added)
		added = FALSE
		for(var/obj/item/hardpoint/weapon as anything in weapons)
			if(length(ammo_rig.contents) >= ammo_rig.storage_slots)
				return
			if(is_type_in_list(weapon.ammo, ammo_rig.can_hold))
				new weapon.ammo.type(ammo_rig)
				added = TRUE

/// TRUE if the crewman is alive, awake and sitting in one of this vehicle's seats
/datum/vehicle_ai_brain/proc/is_crewman_seated(mob/living/carbon/human/crewman)
	if(crewman.stat != CONSCIOUS || crewman.client)
		return FALSE
	var/obj/structure/bed/chair/comfy/vehicle/seat = crewman.buckled
	return istype(seat) && seat.vehicle == vehicle

/// Returns a seated crewman who can load and swap magazines, if the vehicle needs one
/datum/vehicle_ai_brain/proc/get_loader()
	for(var/mob/living/carbon/human/crewman as anything in crew)
		if(is_crewman_seated(crewman))
			return crewman

/// Returns a magazine for the weapon that a seated crewman carries, if any
/datum/vehicle_ai_brain/proc/find_crew_magazine(obj/item/hardpoint/weapon)
	RETURN_TYPE(/obj/item/ammo_magazine/hardpoint)
	for(var/mob/living/carbon/human/crewman as anything in crew)
		if(!is_crewman_seated(crewman))
			continue
		for(var/obj/item/storage/container in crewman)
			for(var/obj/item/ammo_magazine/hardpoint/magazine in container)
				if((magazine.type == weapon.ammo.type) && (magazine.current_rounds > 0))
					return magazine

/// Moves a full magazine for the weapon from a crewman's storage into the weapon's backup clips, like loading the weapons loader
/datum/vehicle_ai_brain/proc/load_crew_magazine(obj/item/hardpoint/weapon)
	var/obj/item/ammo_magazine/hardpoint/magazine = find_crew_magazine(weapon)
	if(!magazine)
		return FALSE

	var/obj/item/storage/container = magazine.loc
	container.remove_from_storage(magazine, weapon)
	LAZYADD(weapon.backup_clips, magazine)
	return TRUE

/// Returns TRUE if the vehicle is no use to its crew anymore: wrecked, or stuck in place with nothing left to shoot
/datum/vehicle_ai_brain/proc/is_knocked_out()
	if(vehicle.health <= 0)
		return TRUE

	for(var/obj/item/hardpoint/locomotion/locomotion in vehicle.hardpoints)
		if(locomotion.health > 0)
			return FALSE

	for(var/obj/item/hardpoint/weapon as anything in get_weapons())
		if(weapon_can_fire(weapon))
			return FALSE

	return TRUE

/// Moves surviving crew into the seats that matter most, so a lone crewman mans the guns instead of the wheel
/datum/vehicle_ai_brain/proc/reassign_crew_seats()
	if(!length(crew) || !vehicle.interior?.ready)
		return

	for(var/seat_index in 1 to length(crew_seats))
		var/obj/structure/bed/chair/comfy/vehicle/seat = get_interior_seat(crew_seats[seat_index])
		if(!seat)
			continue

		// The dead are taken out of their seat
		var/mob/living/seated_mob = seat.buckled_mob
		if(seated_mob?.stat == DEAD)
			seat.unbuckle()

		var/seat_manned = FALSE
		for(var/mob/living/carbon/human/crewman as anything in crew)
			if(crewman.stat != DEAD && crewman.get_ai_brain()?.vehicle_seat == seat)
				seat_manned = TRUE
				break
		if(seat_manned)
			continue

		// Take a living crewman from the least important seat below this one
		for(var/lower_index in length(crew_seats) to seat_index + 1 step -1)
			var/obj/structure/bed/chair/comfy/vehicle/lower_seat = get_interior_seat(crew_seats[lower_index])
			var/mob/living/carbon/human/moving_crewman
			for(var/mob/living/carbon/human/crewman as anything in crew)
				if(crewman.stat != DEAD && !crewman.client && crewman.get_ai_brain()?.vehicle_seat == lower_seat)
					moving_crewman = crewman
					break
			if(!moving_crewman)
				continue
			if(moving_crewman.buckled == lower_seat)
				lower_seat.unbuckle()
			moving_crewman.get_ai_brain().vehicle_seat = seat
			crewman_say(moving_crewman, seat_takeover_lines, important = TRUE, replacements = list("%SEAT%" = (seat.seat == VEHICLE_GUNNER) ? "gun" : "controls"))
			break

/// Makes the seated crew get up and fight anyone hostile who got inside
/datum/vehicle_ai_brain/proc/check_boarders()
	if(!length(crew) || !vehicle.interior?.ready)
		return

	var/boarded = FALSE
	for(var/mob/living/passenger as anything in vehicle.interior.get_passengers())
		// Downed and restrained enemies are no threat and human AI may not shoot them anymore, so they would keep the crew out of the seats
		if(passenger.stat != CONSCIOUS || passenger.is_mob_restrained() || (locate(/datum/effects/crit) in passenger.effects_list))
			continue
		if(!faction_check(passenger))
			boarded = TRUE
			break
	if(!boarded)
		return

	crew_say(boarder_lines, important = TRUE)
	for(var/mob/living/carbon/human/crewman as anything in crew)
		var/obj/structure/bed/chair/comfy/vehicle/seat = crewman.buckled
		if(istype(seat) && seat.vehicle == vehicle && !crewman.client)
			seat.unbuckle()

/// The vehicle is destroyed, everyone who can still walk gets out
/datum/vehicle_ai_brain/proc/evacuate_crew()
	crew_evacuated = TRUE
	for(var/mob/living/carbon/human/crewman as anything in crew.Copy())
		remove_crewman(crewman)
		if(crewman.stat == DEAD || crewman.client)
			continue
		addtimer(CALLBACK(src, PROC_REF(evacuate_crewman), crewman), rand(1 SECONDS, 3 SECONDS))

/datum/vehicle_ai_brain/proc/evacuate_crewman(mob/living/carbon/human/crewman)
	if(QDELETED(crewman) || crewman.stat != CONSCIOUS || !vehicle.interior)
		return

	var/obj/structure/bed/chair/comfy/vehicle/seat = crewman.buckled
	if(istype(seat))
		seat.unbuckle()
	crewman_say(crewman, bail_out_lines, important = TRUE)

	for(var/entrance in vehicle.entrances)
		var/list/entrance_coords = vehicle.entrances[entrance]
		if(vehicle.interior.exit(crewman, locate(vehicle.x + entrance_coords[1], vehicle.y + entrance_coords[2], vehicle.z)))
			return
	vehicle.interior.exit(crewman)

/// Unbuckles the crew and lets their human AI take over, used when the vehicle AI goes away
/datum/vehicle_ai_brain/proc/release_crew()
	for(var/mob/living/carbon/human/crewman as anything in crew.Copy())
		remove_crewman(crewman)
		var/obj/structure/bed/chair/comfy/vehicle/seat = crewman.buckled
		if(istype(seat) && seat.vehicle == vehicle)
			seat.unbuckle()

// Human AI side of the crew

/datum/human_ai_brain
	/// The vehicle seat this AI crews. While buckled in it, the vehicle AI uses this AI as its crew
	var/obj/structure/bed/chair/comfy/vehicle/vehicle_seat

/// Returns TRUE if this AI sits in the seat of a vehicle driven by vehicle AI, which then acts for it
/datum/human_ai_brain/proc/is_vehicle_crew_seated()
	var/obj/structure/bed/chair/comfy/vehicle/seat = tied_human.buckled
	return istype(seat) && seat.vehicle?.ai_brain

/datum/ai_action/man_vehicle_seat
	name = "Man Vehicle Seat"
	action_flags = ACTION_USING_LEGS

/datum/ai_action/man_vehicle_seat/get_weight(datum/human_ai_brain/brain)
	// Only fights in sight keep the crew out of their seats, waiting for in_combat to wear off would leave the vehicle idle
	var/obj/structure/bed/chair/comfy/vehicle/seat = brain.vehicle_seat
	if(!seat || brain.current_target || brain.tied_human.buckled || seat.buckled_mob)
		return 0

	if(brain.tied_human.z != seat.z || seat.vehicle?.health <= 0)
		return 0

	return 8

/datum/ai_action/man_vehicle_seat/trigger_action()
	. = ..()

	var/obj/structure/bed/chair/comfy/vehicle/seat = brain.vehicle_seat
	var/mob/living/carbon/human/tied_human = brain.tied_human
	if(!seat || brain.current_target || tied_human.buckled || seat.buckled_mob || tied_human.z != seat.z)
		return ONGOING_ACTION_COMPLETED

	if(get_dist(tied_human, seat) > 1)
		if(!brain.move_to_next_turf(get_turf(seat)))
			return ONGOING_ACTION_COMPLETED
		return ONGOING_ACTION_UNFINISHED

	tied_human.forceMove(get_turf(seat))
	seat.do_buckle(tied_human, tied_human)
	return ONGOING_ACTION_COMPLETED
