#define XENO_PLASMA_TIER_11 9999 * XENO_UNIVERSAL_PLASMAMULT
#define XENO_HEALTH_WENDIGO 2600 * XENO_UNIVERSAL_HPMULT

/datum/caste_datum/criptic_wendigo
	caste_type = XENO_CASTE_WENDIGO
	caste_desc = "A fast, four-legged terror."
	tier = 0
	melee_damage_lower = XENO_DAMAGE_TIER_5
	melee_damage_upper = XENO_DAMAGE_TIER_6
	plasma_gain = XENO_PLASMA_GAIN_TIER_10
	plasma_max = XENO_PLASMA_TIER_11
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_8
	armor_deflection = XENO_ARMOR_TIER_5
	max_health = XENO_HEALTH_WENDIGO
	evasion = XENO_EVASION_MEDIUM
	speed = XENO_SPEED_TIER_10
	attack_delay = 1

	minimum_evolve_time = 0

	tackle_min = 2
	tackle_max = 5
	tackle_chance = 60
	tacklestrength_min = 4
	tacklestrength_max = 4

	heal_resting = 2.5
	heal_standing = 1.25
	heal_knocked_out = 1.25
	innate_healing = TRUE

	minimap_icon = "hellhound"

/mob/living/carbon/xenomorph/criptic_wendigo
	AUTOWIKI_SKIP(TRUE)

	caste_type = XENO_CASTE_WENDIGO
	name = XENO_CASTE_WENDIGO
	desc = "A disgusting beast from hell, it has deer horns."
	icon = 'core_ru/code/modules/criptid_hunting/wendigo.dmi'
	icon_state = "Wendigo Running"
	icon_size = 64
	layer = MOB_LAYER
	plasma_types = list(PLASMA_CHITIN)
	tier = 0
	acid_blood_damage = 0
	pull_speed = -0.5
	viewsize = 9

	speaking_key = "h"
	speaking_noise = "hiss_talk"
	langchat_color = "#770000"

	slash_verb = "rend"
	slashes_verb = "rends"
	slash_sound = 'sound/weapons/bite.ogg'

	mob_size = MOB_SIZE_XENO

	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/activable/pounce/lurker,
		/datum/action/xeno_action/onclick/lurker_invisibility,
		/datum/action/xeno_action/onclick/tremor,
		/datum/action/xeno_action/onclick/tail_sweep,
		/datum/action/xeno_action/activable/prae_abduct,
		/datum/action/xeno_action/onclick/toggle_long_range/runner,
		/datum/action/xeno_action/onclick/tacmap,
	)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

	icon_xeno = 'core_ru/code/modules/criptid_hunting/wendigo.dmi'
	icon_xenonid = 'core_ru/code/modules/criptid_hunting/wendigo.dmi'
	gib_chance = 0

	pixel_x = -16
	old_x = -16

	pixel_y = -16
	old_y = -16

	var/fur_dropped = FALSE

/mob/living/carbon/xenomorph/criptic_wendigo/Initialize(mapload, mob/living/carbon/xenomorph/oldXeno, h_number)
	. = ..(mapload, oldXeno, h_number || XENO_HIVE_YAUTJA)

	set_languages(list(ALL_HUMAN_LANGUAGES))

	GLOB.living_xeno_list -= src
	GLOB.xeno_mob_list -= src
	SSmob.living_misc_mobs += src
	GLOB.hellhound_list += src

/mob/living/carbon/xenomorph/criptic_wendigo/prepare_huds()
	..()
	var/image/health_holder = hud_list[HEALTH_HUD_XENO]
	health_holder.pixel_x = -12
	var/image/status_holder = hud_list[XENO_STATUS_HUD]
	status_holder.pixel_x = -10
	var/image/banished_holder = hud_list[XENO_BANISHED_HUD]
	banished_holder.pixel_x = -12
	banished_holder.pixel_y = -6

/mob/living/carbon/xenomorph/criptic_wendigo/Login()
	. = ..()
	if(SSticker.mode) SSticker.mode.xenomorphs -= mind

/mob/living/carbon/xenomorph/criptic_wendigo/death(cause, gibbed)
	. = ..(cause, gibbed, "lets out a horrible roar as it collapses and stops moving...")
	if(!.)
		return
	emote("roar")
	SSmob.living_misc_mobs -= src

/mob/living/carbon/xenomorph/criptic_wendigo/rejuvenate()
	..()
	GLOB.living_xeno_list -= src
	SSmob.living_misc_mobs |= src

/mob/living/carbon/xenomorph/criptic_wendigo/Destroy()
	SSmob.living_misc_mobs -= src
	return ..()

/mob/living/carbon/xenomorph/criptic_wendigo/handle_blood_splatter(splatter_dir)
	new /obj/effect/temp_visual/dir_setting/bloodsplatter/criptidsplatter(loc, splatter_dir)

/obj/effect/temp_visual/dir_setting/bloodsplatter/criptidsplatter
	splatter_type = "csplatter"
	color = "#000000"

/datum/caste_datum/criptic_wendigo/banshee
	caste_type = XENO_CASTE_BANSHEE
	melee_damage_lower = XENO_DAMAGE_TIER_1
	melee_damage_upper = XENO_DAMAGE_TIER_2
	plasma_gain = XENO_PLASMA_GAIN_TIER_8
	plasma_max = XENO_PLASMA_TIER_10
	max_health = 100
	xeno_explosion_resistance = XENO_NO_EXPLOSIVE_ARMOR
	armor_deflection = XENO_NO_ARMOR
	evasion = XENO_EVASION_MEDIUM
	speed = XENO_SPEED_TIER_7
	attack_delay = 0

/mob/living/carbon/xenomorph/criptic_wendigo/banshee
	AUTOWIKI_SKIP(TRUE)

	caste_type = XENO_CASTE_BANSHEE
	name = XENO_CASTE_BANSHEE
	desc = "A disgusting beast from hell, it has tendrils."
	icon = 'core_ru/code/modules/criptid_hunting/lessers.dmi'
	icon_state = "Banshee Running"

	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/onclick/tacmap,
		)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

	icon_xeno = 'core_ru/code/modules/criptid_hunting/lessers.dmi'
	icon_xenonid = 'core_ru/code/modules/criptid_hunting/lessers.dmi'
	gib_chance = 100

/mob/living/carbon/xenomorph/criptic_wendigo/banshee/init_movement_handler()
	return new /datum/xeno_ai_movement/drone(src)

/obj/item/criptic/clue_item/criptid_cloth
	name = "criptid part"
	desc = "Some kind of occult old shit."
	icon = 'core_ru/code/modules/criptid_hunting/ms_scrap.dmi'
	icon_state = "scrap_leather"

	w_class = SIZE_TINY

/obj/item/weapon/knife/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	if(istype(target,/mob/living/carbon/xenomorph/criptic_wendigo) && prob(20))
		var/mob/living/carbon/xenomorph/criptic_wendigo/W = target
		if(!W.fur_dropped)
			W.fur_dropped = TRUE
			new /obj/item/criptic/clue_item/criptid_cloth(get_turf(src))
