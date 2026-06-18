/obj/structure/closet/secure_closet/halo/job_locker
	name = "occupation locker"

/obj/structure/closet/secure_closet/halo/job_locker/proc/spawn_gear()
	return

/obj/structure/closet/secure_closet/halo/job_locker/proc/get_faction_helmet_motion()
	var/platoon_type = GLOB.RoleAuthority?.get_active_ship_platoon_type()
	switch(platoon_type)
		if(/datum/squad/marine/halo/unsc/alpha)
			return /obj/item/clothing/head/helmet/marine/unsc/motion
		if(/datum/squad/marine/halo/odst/alpha)
			return /obj/item/clothing/head/helmet/marine/unsc/odst/motion
		else
			return /obj/item/clothing/head/helmet/marine/motion

/obj/structure/closet/secure_closet/halo/job_locker/squad_leader
	name = "Squad Leader locker"
	desc = "Contains the equipment for a squad leader."
	req_access = list(ACCESS_MARINE_LEADER)

/obj/structure/closet/secure_closet/halo/job_locker/squad_leader/spawn_gear()
	. = ..()
	new /obj/item/ammo_box/magazine/m49a(src)
	new /obj/item/weapon/gun/rifle/m49a(src)
	new /obj/item/weapon/gun/launcher/grenade/m92(src)
	new /obj/item/device/binoculars/range/designator(src)
	var/helmet_type = get_faction_helmet_motion()
	new helmet_type(src)

/obj/structure/closet/secure_closet/halo/job_locker/rto
	name = "Radio Telephone Operator locker"
	req_access = list(ACCESS_MARINE_SMARTPREP)

/obj/structure/closet/secure_closet/halo/job_locker/rto/spawn_gear()
	. = ..()
	var/platoon_type = GLOB.RoleAuthority?.get_active_ship_platoon_type()
	switch(platoon_type)
		if(/datum/squad/marine/halo/unsc/alpha, /datum/squad/marine/halo/odst/alpha)
			new /obj/item/storage/backpack/marine/satchel/rto/unsc(src)
		else
			new /obj/item/storage/backpack/marine/satchel/rto(src)
	new /obj/item/device/binoculars/range/designator(src)
	new /obj/item/storage/box/flare/signal(src)
	new /obj/item/storage/box/flare/signal(src)
	var/helmet_type = get_faction_helmet_motion()
	new helmet_type(src)

/obj/structure/closet/secure_closet/halo/job_locker/weapons_spec
	name = "Weapons Specialist locker"
	req_access = list(ACCESS_MARINE_SPECPREP)
	var/role_lock = TRUE
	var/datum/weakref/claim_holder_ref = null

/obj/structure/closet/secure_closet/halo/job_locker/weapons_spec/proc/get_allowed_specialist_jobs()
	return list(
		JOB_SQUAD_SPECIALIST,
		JOB_SQUAD_SPECIALIST_UNSC,
		JOB_SQUAD_SPECIALIST_ODST,
	)

/obj/structure/closet/secure_closet/halo/job_locker/weapons_spec/proc/get_claim_holder()
	return claim_holder_ref?.resolve()

/obj/structure/closet/secure_closet/halo/job_locker/weapons_spec/proc/is_claimed_by(mob/living/carbon/human/human)
	var/datum/claim_holder = get_claim_holder()
	if(!claim_holder || !human)
		return FALSE

	return claim_holder == human.get_halo_job_locker_claim_holder()

/obj/structure/closet/secure_closet/halo/job_locker/weapons_spec/proc/can_access_claimed_locker(mob/living/user)
	if(!ishuman(user))
		return TRUE

	var/mob/living/carbon/human/human = user
	var/datum/claim_holder = get_claim_holder()
	if(!claim_holder)
		return TRUE
	if(is_claimed_by(human))
		return TRUE

	to_chat(user, SPAN_WARNING("This HALO job locker has already been claimed."))
	return FALSE

/obj/structure/closet/secure_closet/halo/job_locker/weapons_spec/proc/claim_selected_kit(mob/living/carbon/human/human, chosen_kit)
	if(!human || !chosen_kit)
		return FALSE
	if(get_claim_holder() || human.has_claimed_halo_job_locker())
		return FALSE

	var/datum/claim_holder = human.get_halo_job_locker_claim_holder()
	if(!claim_holder)
		return FALSE

	var/obj/item/storage/unsc_speckit/kit = new chosen_kit(src)
	if(!kit)
		return FALSE
	if(!human.claim_halo_job_locker())
		qdel(kit)
		return FALSE

	claim_holder_ref = WEAKREF(claim_holder)
	locked = FALSE
	open()
	return TRUE

/obj/structure/closet/secure_closet/halo/job_locker/weapons_spec/attack_hand(mob/living/user)
	if(!can_access_claimed_locker(user))
		return

	return ..()

/obj/structure/closet/secure_closet/halo/job_locker/weapons_spec/togglelock(mob/living/user)
	var/list/allowed_specialist_jobs = get_allowed_specialist_jobs()
	var/mob/living/carbon/human/human = null
	if(ishuman(user))
		human = user
	if(!allowed(user))
		to_chat(user, SPAN_WARNING("You do not have access to the contents of the locker."))
		return
	if(!can_access_claimed_locker(user))
		return
	if(get_claim_holder())
		return ..()
	if(human?.has_claimed_halo_job_locker())
		to_chat(user, SPAN_WARNING("You have already claimed a HALO job locker kit."))
		return

	if(role_lock && human)
		var/obj/item/card/id/card = human.get_idcard()
		if(card)
			if(!(human.job in allowed_specialist_jobs))
				to_chat(user, SPAN_WARNING("You aren't the right occupation for this locker."))
				return
			equipment_giver(user)
	else if(human)
		equipment_giver(user)

/obj/structure/closet/secure_closet/halo/job_locker/weapons_spec/proc/equipment_giver(mob/living/user)
	var/mob/living/carbon/human/human = null
	if(ishuman(user))
		human = user
	if(human)
		if(get_claim_holder() || human.has_claimed_halo_job_locker())
			to_chat(user, SPAN_WARNING("You have already claimed a HALO job locker kit."))
			return

	var/static/list/spec_equipment_list = list(
		"SPNKr kit" = /obj/item/storage/unsc_speckit/spnkr,
		"SRS-99AM kit" = /obj/item/storage/unsc_speckit/srs99,
	)

	var/chosen_kit = tgui_input_list(user, "Equipment Selection", "Select your equipment", spec_equipment_list)

	if(!chosen_kit)
		to_chat(user, SPAN_WARNING("You decide to think on it."))
		return

	if(human)
		if(get_claim_holder())
			to_chat(user, SPAN_WARNING("This HALO job locker has already been claimed."))
			return
		if(human.has_claimed_halo_job_locker())
			to_chat(user, SPAN_WARNING("You have already claimed a HALO job locker kit."))
			return

	chosen_kit = spec_equipment_list[chosen_kit]

	if(human)
		if(!claim_selected_kit(human, chosen_kit))
			to_chat(user, SPAN_WARNING("The locker fails to register your claim."))
			return
	else
		new chosen_kit(src)

/obj/structure/closet/secure_closet/halo/job_locker/weapons_spec/ft1
	name = "fireteam one Weapons Specialist locker"
	req_access = list(ACCESS_MARINE_SPECPREP, ACCESS_SQUAD_ONE)

/obj/structure/closet/secure_closet/halo/job_locker/weapons_spec/ft2
	name = "fireteam two Weapons Specialist locker"
	req_access = list(ACCESS_MARINE_SPECPREP, ACCESS_SQUAD_TWO)

/obj/structure/closet/secure_closet/halo/job_locker/fireteam_leader
	name = "Group Leader locker"
	req_access = list(ACCESS_MARINE_TL_PREP)

/obj/structure/closet/secure_closet/halo/job_locker/fireteam_leader/spawn_gear()
	. = ..()
	new /obj/item/ammo_box/magazine/m49a(src)
	new /obj/item/weapon/gun/rifle/m49a(src)
	new /obj/item/device/binoculars/range/designator/monocular(src)
	var/helmet_type = get_faction_helmet_motion()
	new helmet_type(src)

/obj/structure/closet/secure_closet/halo/job_locker/fireteam_leader/ft1
	name = "group one Group Leader locker"
	req_access = list(ACCESS_MARINE_TL_PREP, ACCESS_SQUAD_ONE)

/obj/structure/closet/secure_closet/halo/job_locker/fireteam_leader/ft2
	name = "group two Group Leader locker"
	req_access = list(ACCESS_MARINE_TL_PREP, ACCESS_SQUAD_TWO)

/obj/structure/closet/secure_closet/halo/job_locker/smartgunner
	name = "Smartgunner locker"
	desc = "A locker for Smartgunners."
	req_access = list(ACCESS_MARINE_SMARTPREP)

/obj/structure/closet/secure_closet/halo/job_locker/smartgunner/spawn_gear()
	. = ..()
	var/helmet_type = get_faction_helmet_motion()
	new helmet_type(src)
