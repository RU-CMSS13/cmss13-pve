/datum/species/guardian
	group = SPECIES_HUMAN
	name = SPECIES_GUARDIAN
	name_plural = "Guardians"
	icobase = 'icons/mob/humans/species/t_guardian.dmi'
	deform = 'icons/mob/humans/species/t_guardian.dmi'
	limb_overlays = list(
		"head" = "guardian_head",
		"torso" = "guardian_torso",
		"r_arm" = "guardian_right_arm",
		"l_arm" = "guardian_left_arm",
		"r_leg" = "guardian_right_leg",
		"l_leg" = "guardian_left_leg",
	)
	eyes = "blank_s"
	unarmed_type = /datum/unarmed_attack/punch
	blood_color = BLOOD_COLOR_ZOMBIE
	uses_skin_color = FALSE
	special_body_types = FALSE
	mob_flags = KNOWS_TECHNOLOGY
	flags = IS_WHITELISTED|NO_CLONE_LOSS|NO_POISON|NO_NEURO|NO_SHRAPNEL|HAS_HARDCRIT
	darksight = 20
	brute_mod = 0.5
	burn_mod = 0.8
	cold_level_1 = -1
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 500
	heat_level_2 = 1000
	heat_level_3 = 2000 //a small bit of resistance

	has_organ = list(
		"brain" = /datum/internal_organ/brain, //human brain but synthetic hearth
		"heart" = /datum/internal_organ/heart/prosthetic,
	)

	knock_down_reduction = 2.5
	stun_reduction = 2.5
	acid_blood_dodge_chance = 100

/datum/species/guardian/handle_post_spawn(mob/living/carbon/human/human)
	. = ..()
	if(human.hud_list)
		implant_embryo(human)

/datum/species/guardian/proc/implant_embryo(mob/living/carbon/human/human)
	if(!(locate(/obj/item/alien_embryo/dormant) in human))
		new /obj/item/alien_embryo/dormant(human)

/datum/species/guardian/handle_death(mob/living/carbon/human/dying_guardian, gibbed)
	if(gibbed)
		return
	var/obj/item/alien_embryo/dormant/embryo = locate() in dying_guardian
	if(!embryo)
		return
	playsound(get_turf(dying_guardian), "glassbreak", 25, FALSE)
	INVOKE_ASYNC(embryo, TYPE_PROC_REF(/obj/item/alien_embryo/dormant, burst))

/obj/item/alien_embryo/dormant
	stage = 6

/obj/item/alien_embryo/dormant/Initialize(mapload, ...)
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/alien_embryo/dormant/proc/burst()
	var/mob/living/carbon/host = loc
	if(!istype(host) || host != affected_mob)
		return
	become_larva()
	qdel(src)
	if(QDELETED(host))
		return
	var/mob/living/carbon/xenomorph/larva/larva = locate() in host
	larva?.chest_burst(host)

/datum/action/human_action/guardian_burst
	name = "Initiate Chestburst"
	icon_file = 'icons/mob/hud/actions_xeno.dmi'
	action_icon_state = "gut"

/datum/action/human_action/guardian_burst/can_use_action()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/guardian = owner
	return istype(guardian) && guardian.stat != DEAD && (locate(/obj/item/alien_embryo/dormant) in guardian)

/datum/action/human_action/guardian_burst/action_activate()
	. = ..()
	if(!can_use_action())
		return
	if(tgui_alert(owner, "The larva will tear its way out of you, and you will die. Continue?", name, list("Yes", "No")) != "Yes")
		return
	if(!can_use_action())
		return
	var/mob/living/carbon/human/guardian = owner
	var/obj/item/alien_embryo/dormant/embryo = locate() in guardian
	remove_from(guardian)
	guardian.visible_message(SPAN_DANGER("[guardian] clutches [guardian.p_their()] chest!"), SPAN_XENODANGER("You let the larva out."))
	embryo.burst()
