/obj/structure/closet/secure_closet/marine_personal
	var/squad_type
	var/list/generated_spawn_gear_contents = list()

/obj/structure/closet/secure_closet/marine_personal/Initialize(mapload, ...)
	var/list/preexisting_contents = contents ? contents.Copy() : list()
	. = ..()
	refresh_generated_spawn_gear_contents(preexisting_contents)

/obj/structure/closet/secure_closet/marine_personal/proc/refresh_generated_spawn_gear_contents(list/preexisting_contents = null)
	generated_spawn_gear_contents = list()
	if(!has_cryo_gear)
		return

	if(!islist(preexisting_contents))
		preexisting_contents = list()

	for(var/atom/movable/movable as anything in contents)
		if(preexisting_contents.Find(movable))
			continue
		generated_spawn_gear_contents += movable

/obj/structure/closet/secure_closet/marine_personal/proc/get_preserved_contents_for_ship_surface_swap()
	. = list()
	var/list/generated_contents = generated_spawn_gear_contents

	for(var/atom/movable/movable as anything in contents)
		if(islist(generated_contents) && generated_contents.Find(movable))
			continue
		. += movable

/obj/structure/closet/secure_closet/marine_personal/proc/get_normalized_job_title_for_personal_locker(job_title)
	if(!job_title)
		return null

	var/datum/authority/branch/role/role_authority = GLOB.RoleAuthority
	var/normalized_job_title = role_authority?.get_job_preference_bucket_key(job_title)
	if(normalized_job_title)
		return normalized_job_title

	return GET_DEFAULT_ROLE(job_title)

/obj/structure/closet/secure_closet/marine_personal/proc/is_correct_job(mob/living/carbon/human/H)
	if(!H)
		return FALSE

	var/normalized_human_job = get_normalized_job_title_for_personal_locker(H.job)
	var/normalized_locker_job = get_normalized_job_title_for_personal_locker(job)
	if(!normalized_human_job || !normalized_locker_job)
		return H.job == job

	return normalized_human_job == normalized_locker_job

/obj/structure/closet/secure_closet/marine_personal/proc/is_correct_squad(mob/living/carbon/human/H)
	if(!squad_type)
		return TRUE
	if(!H.assigned_squad)
		return FALSE
	var/datum/squad_name_manager/manager = GLOB.squad_name_manager
	var/expected_squad_name = manager ? manager.get_runtime_name(squad_type) : squad_type
	if(H.assigned_squad.name == expected_squad_name)
		return TRUE
	if(H.assigned_squad.name == squad_type)
		return TRUE

	if(squad_type == SQUAD_MARINE_1)
		if(H.assigned_squad.name == GLOB.main_platoon_name)
			return TRUE
	return FALSE

/obj/structure/closet/secure_closet/marine_personal/proc/matches_player_for_personal_locker(mob/living/carbon/human/human)
	if(!human)
		return FALSE

	if(!is_correct_job(human))
		return FALSE

	var/turf/human_turf = get_turf(human)
	if(linked_spawn_turf)
		if(human_turf == linked_spawn_turf)
			return is_correct_squad(human)

		if(!istype(human.loc, /obj/structure/machinery/cryopod))
			return FALSE

		var/is_adjacent_to_spawn = FALSE
		for(var/cardinal in GLOB.cardinals)
			if(get_step(linked_spawn_turf, cardinal) == human_turf)
				is_adjacent_to_spawn = TRUE
				break

		if(!is_adjacent_to_spawn)
			return FALSE

	return is_correct_squad(human)

/obj/structure/closet/secure_closet/marine_personal/proc/is_abandoned_for_personal_locker(list/alive_human_names)
	if(!owner || !islist(alive_human_names))
		return FALSE

	return !alive_human_names[owner]

/obj/structure/closet/secure_closet/marine_personal/proc/reinitialize_for_personal_locker_reuse()
	if(opened)
		opened = FALSE
		density = TRUE

	welded = FALSE

	for(var/atom/movable/movable as anything in contents)
		if(ismob(movable))
			movable.forceMove(get_turf(src))
			continue
		qdel(movable)

	broken = FALSE
	locked = TRUE
	update_icon()
	spawn_gear()
	refresh_generated_spawn_gear_contents()

/obj/structure/closet/secure_closet/marine_personal/rifleman
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-rm"
	icon_closed = "secure-rm"
	icon_locked = "secure1-rm"
	icon_opened = "secureopen-rm"
	icon_broken = "securebroken-rm"
	icon_off = "secureoff-rm"

/obj/structure/closet/secure_closet/marine_personal/smartgunner
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-sg"
	icon_closed = "secure-sg"
	icon_locked = "secure1-sg"
	icon_opened = "secureopen-sg"
	icon_broken = "securebroken-sg"
	icon_off = "secureoff-sg"

/obj/structure/closet/secure_closet/marine_personal/engineer
	job = JOB_SQUAD_ENGI
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-eng"
	icon_closed = "secure-eng"
	icon_locked = "secure1-eng"
	icon_opened = "secureopen-eng"
	icon_broken = "securebroken-eng"
	icon_off = "secureoff-eng"

/obj/structure/closet/secure_closet/marine_personal/corpsman
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-med"
	icon_closed = "secure-med"
	icon_locked = "secure1-med"
	icon_opened = "secureopen-med"
	icon_broken = "securebroken-med"
	icon_off = "secureoff-med"

/obj/structure/closet/secure_closet/marine_personal/specialist
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-spec"
	icon_closed = "secure-spec"
	icon_locked = "secure1-spec"
	icon_opened = "secureopen-spec"
	icon_broken = "securebroken-spec"
	icon_off = "secureoff-spec"

/obj/structure/closet/secure_closet/marine_personal/rto
	job = JOB_SQUAD_RTO
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-rto"
	icon_closed = "secure-rto"
	icon_locked = "secure1-rto"
	icon_opened = "secureopen-rto"
	icon_broken = "securebroken-rto"
	icon_off = "secureoff-rto"

/obj/structure/closet/secure_closet/marine_personal/rto/spawn_gear()
	. = ..()
	new /obj/item/device/binoculars/fire_support/uscm(src)
	new /obj/item/storage/box/flare/signal(src)
	new /obj/item/storage/box/flare/signal(src)

/obj/structure/closet/secure_closet/marine_personal/squad_leader
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-ftl"
	icon_closed = "secure-ftl"
	icon_locked = "secure1-ftl"
	icon_opened = "secureopen-ftl"
	icon_broken = "securebroken-ftl"
	icon_off = "secureoff-ftl"

/obj/structure/closet/secure_closet/marine_personal/platoon_leader
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-sl"
	icon_closed = "secure-sl"
	icon_locked = "secure1-sl"
	icon_opened = "secureopen-sl"
	icon_broken = "securebroken-sl"
	icon_off = "secureoff-sl"

/obj/structure/closet/secure_closet/marine_personal/platoon_commander
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-so"
	icon_closed = "secure-so"
	icon_locked = "secure1-so"
	icon_opened = "secureopen-so"
	icon_broken = "securebroken-so"
	icon_off = "secureoff-so"

/obj/structure/closet/secure_closet/marine_personal/platoon_commander/spawn_gear()
	. = ..()
	new /obj/item/clothing/head/helmet/marine/motion(src)
