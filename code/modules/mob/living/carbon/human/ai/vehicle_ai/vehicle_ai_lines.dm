/obj/item/hardpoint
	/// If TRUE, the vehicle AI crew has already called out that this hardpoint is out of ammunition
	var/ai_dry_called = FALSE

/datum/vehicle_ai_brain
	/// Lines said when the vehicle spots an enemy. %DIR% is replaced with the direction to it
	var/list/contact_lines = list(
		"CONTACT!",
		"CONTACT, %DIR%!",
		"TARGET, %DIR%!",
		"Target spotted!",
		"Gunner, target, %DIR%!",
		"Hostiles, %DIR%!",
		"We've got hostiles!",
		"Enemy spotted, %DIR%!",
		"Identified! Engaging!",
	)
	/// Lines said when the fight is over
	var/list/clear_lines = list(
		"Area clear.",
		"No more targets.",
		"Cease fire, cease fire.",
		"Looks clear.",
		"Scan your sectors.",
		"Keep scanning, might be more.",
	)
	/// Lines said when the target is dead or destroyed
	var/list/kill_lines = list(
		"Target down!",
		"Target destroyed!",
		"Scratch one!",
		"Got 'em!",
		"Good hit, good hit!",
		"Target neutralized.",
		"That's a kill!",
	)
	/// Lines said by the gunner when firing a main gun
	var/list/fire_lines = list(
		"ON THE WAY!",
		"FIRING!",
		"Shot out!",
		"FIRE!",
		"Sending it!",
	)
	/// Lines said when starting to reload a weapon
	var/list/reload_lines = list(
		"Reloading!",
		"Loading!",
		"Gun's dry, reloading!",
		"Hold on, loading!",
	)
	/// Lines said when a weapon is loaded again
	var/list/loaded_lines = list(
		"UP!",
		"Loaded!",
		"Gun up!",
		"Ready to fire!",
	)
	/// Lines said when a weapon has no ammunition left at all
	var/list/dry_lines = list(
		"We're out of ammo!",
		"That's the last of it, we're dry!",
		"No more rounds for this one!",
		"We're Winchester!",
	)
	/// Lines said when the vehicle takes damage
	var/list/hit_lines = list(
		"We're hit!",
		"Taking fire!",
		"Hit! Still in it!",
		"Armor's holding!",
		"That one rang the bell!",
		"Shit, we're hit!",
		"Where's that coming from?!",
	)
	/// Lines said once when the hull is about to give
	var/list/hull_critical_lines = list(
		"Hull's breaking apart!",
		"We can't take much more of this!",
		"Armor critical!",
		"She's falling apart!",
	)
	/// Lines said when a crewman dies
	var/list/crew_death_lines = list(
		"CREW DOWN!",
		"WE LOST ONE!",
		"Shit, they're dead!",
		"No, no, NO!",
		"THEY GOT ONE OF US!",
	)
	/// Lines said when enemies get inside
	var/list/boarder_lines = list(
		"BOARDERS!",
		"THEY'RE INSIDE!",
		"WE'VE GOT BOARDERS!",
		"Hostile inside the vehicle!",
	)
	/// Lines said when bailing out of the destroyed vehicle
	var/list/bail_out_lines = list(
		"BAIL OUT! BAIL OUT!",
		"GET OUT, GET OUT!",
		"We're done, bail!",
		"Everyone out!",
	)
	/// Lines said when a crewman moves to the seat of a dead one. %SEAT% is replaced with what they take over
	var/list/seat_takeover_lines = list(
		"I'll take the %SEAT%!",
		"Taking over the %SEAT%!",
		"I've got the %SEAT%!",
	)
	/// Lines said by the driver when driving away from enemies the vehicle can't fight
	var/list/flee_lines = list(
		"We can't fight that, pulling back!",
		"Get us out of here!",
		"Falling back!",
		"Reversing, reversing!",
		"Nothing to shoot back with, we're leaving!",
	)
	/// Lines said by the driver when cornered and driving into the enemy
	var/list/ram_lines = list(
		"Nowhere to go, hold on!",
		"Run them over!",
		"Floor it, through them!",
		"Brace, we're going through!",
	)
	/// Lines said by the driver when friendlies stand in the way
	var/list/move_lines = list(
		"MOVE!",
		"Get out of the way!",
		"Clear the road!",
		"Coming through!",
	)

	/// How long the crew keeps quiet after saying something. Important lines are said anyway
	var/crew_line_delay = 4 SECONDS
	/// If TRUE, the crew has already called out that the hull is about to give
	var/hull_critical_called = FALSE
	/// Combined health of the hull and hardpoints when last checked, to notice hits
	var/last_integrity

	COOLDOWN_DECLARE(crew_line_cooldown)

/// Makes a seated crewman say one of the lines, preferring whoever sits in the given seat
/datum/vehicle_ai_brain/proc/crew_say(list/lines, seat, important = FALSE, list/replacements, chance = 100)
	if(!prob(chance))
		return
	var/mob/living/carbon/human/speaker = get_crew_speaker(seat)
	if(speaker)
		crewman_say(speaker, lines, important, replacements)

/datum/vehicle_ai_brain/proc/crewman_say(mob/living/carbon/human/speaker, list/lines, important = FALSE, list/replacements)
	if(!length(lines) || (!important && !COOLDOWN_FINISHED(src, crew_line_cooldown)))
		return
	if(speaker.stat != CONSCIOUS || speaker.client || speaker.health < HEALTH_THRESHOLD_CRIT)
		return

	var/line = pick(lines)
	for(var/token in replacements)
		line = replacetext(line, token, replacements[token])
	COOLDOWN_START(src, crew_line_cooldown, crew_line_delay)
	INVOKE_ASYNC(speaker, TYPE_PROC_REF(/mob, say), line)

/datum/vehicle_ai_brain/proc/get_crew_speaker(seat)
	RETURN_TYPE(/mob/living/carbon/human)
	if(seat)
		var/mob/living/carbon/human/seated_mob = vehicle.seats[seat]
		if((seated_mob in crew) && is_crewman_seated(seated_mob))
			return seated_mob
	for(var/mob/living/carbon/human/crewman as anything in crew)
		if(is_crewman_seated(crewman))
			return crewman

/datum/vehicle_ai_brain/proc/say_contact_line()
	var/atom/target = current_target || target_turf
	var/direction = target ? dir2text(get_dir(vehicle, target)) : null
	crew_say(contact_lines, VEHICLE_GUNNER, replacements = list("%DIR%" = direction ? uppertext(direction) : "FRONT"))

/// Calls out hits and a failing hull, checked every target scan
/datum/vehicle_ai_brain/proc/check_damage_lines()
	var/integrity = vehicle.health
	for(var/obj/item/hardpoint/hardpoint as anything in vehicle.get_hardpoints_copy())
		integrity += hardpoint.health
	if(!isnull(last_integrity) && integrity < last_integrity)
		crew_say(hit_lines)
	last_integrity = integrity

	if(!hull_critical_called && vehicle.health < initial(vehicle.health) * 0.3)
		hull_critical_called = TRUE
		crew_say(hull_critical_lines, important = TRUE)

/// TRUE if the target was killed or destroyed rather than lost from sight
/datum/vehicle_ai_brain/proc/is_target_destroyed(atom/movable/target)
	if(QDELETED(target))
		return TRUE
	if(ismob(target))
		var/mob/mob_target = target
		return mob_target.stat == DEAD
	if(istype(target, /obj/vehicle/multitile))
		var/obj/vehicle/multitile/vehicle_target = target
		return !vehicle_target.ai_can_fight()
	if(isdefenses(target))
		var/obj/structure/machinery/defenses/defense_target = target
		return !defense_target.turned_on
	return FALSE
