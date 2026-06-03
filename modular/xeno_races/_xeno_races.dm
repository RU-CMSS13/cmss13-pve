/datum/modpack/xeno_races
	name = "xeno races modpack"
	desc = "Ports Bodyburster/Lanky and Pathogen xenomorph race content."
	author = "OpenAI Codex, upstream cmss13-pve contributors"

/datum/modpack/xeno_races/initialize()
	if(!GLOB.hive_datum[XENO_HIVE_PATHOGEN])
		GLOB.hive_datum[XENO_HIVE_PATHOGEN] = new /datum/hive_status/pathogen()

	GLOB.xeno_race_caste_mobs = list(
		XENO_CASTE_BODYBURSTER = /mob/living/carbon/xenomorph/bodyburster,
		XENO_CASTE_LANKY = /mob/living/carbon/xenomorph/lanky,
		PATHOGEN_CREATURE_BURSTER = /mob/living/carbon/xenomorph/bloodburster,
		PATHOGEN_CREATURE_SPRINTER = /mob/living/carbon/xenomorph/sprinter,
		PATHOGEN_CREATURE_POPPER = /mob/living/carbon/xenomorph/popper,
		PATHOGEN_CREATURE_NEOMORPH = /mob/living/carbon/xenomorph/neomorph,
		PATHOGEN_CREATURE_BLIGHT = /mob/living/carbon/xenomorph/blight,
		PATHOGEN_CREATURE_BRUTE = /mob/living/carbon/xenomorph/brute,
		PATHOGEN_CREATURE_VENATOR = /mob/living/carbon/xenomorph/venator,
	)
	GLOB.xeno_race_ai_spawnables = list(
		XENO_CASTE_BODYBURSTER,
		XENO_CASTE_LANKY,
		PATHOGEN_CREATURE_BURSTER,
		PATHOGEN_CREATURE_SPRINTER,
		PATHOGEN_CREATURE_POPPER,
		PATHOGEN_CREATURE_NEOMORPH,
		PATHOGEN_CREATURE_BLIGHT,
		PATHOGEN_CREATURE_BRUTE,
		PATHOGEN_CREATURE_VENATOR,
	)

	if(islist(GLOB.pp_transformables))
		GLOB.pp_transformables["Alien Tier 2"] += list(
			list(
				name = XENO_CASTE_BODYBURSTER,
				key = /mob/living/carbon/xenomorph/bodyburster,
				color = "purple"
			)
		)
		GLOB.pp_transformables["Alien Tier 3"] += list(
			list(
				name = XENO_CASTE_LANKY,
				key = /mob/living/carbon/xenomorph/lanky,
				color = "purple"
			)
		)
		GLOB.pp_transformables["Pathogen Tier 0"] = list(
			list(
				name = PATHOGEN_CREATURE_BURSTER,
				key = /mob/living/carbon/xenomorph/bloodburster,
				color = "purple"
			)
		)
		GLOB.pp_transformables["Pathogen Tier 1"] = list(
			list(
				name = PATHOGEN_CREATURE_SPRINTER,
				key = /mob/living/carbon/xenomorph/sprinter,
				color = "purple"
			),
			list(
				name = PATHOGEN_CREATURE_POPPER,
				key = /mob/living/carbon/xenomorph/popper,
				color = "purple"
			)
		)
		GLOB.pp_transformables["Pathogen Tier 2"] = list(
			list(
				name = PATHOGEN_CREATURE_NEOMORPH,
				key = /mob/living/carbon/xenomorph/neomorph,
				color = "purple"
			),
			list(
				name = PATHOGEN_CREATURE_BLIGHT,
				key = /mob/living/carbon/xenomorph/blight,
				color = "purple"
			)
		)
		GLOB.pp_transformables["Pathogen Tier 3"] = list(
			list(
				name = PATHOGEN_CREATURE_BRUTE,
				key = /mob/living/carbon/xenomorph/brute,
				color = "purple"
			),
			list(
				name = PATHOGEN_CREATURE_VENATOR,
				key = /mob/living/carbon/xenomorph/venator,
				color = "purple"
			)
		)

	var/datum/hive_status/main_hive = GLOB.hive_datum[XENO_HIVE_NORMAL]
	if(main_hive?.evolution_menu_images)
		for(var/caste_name in ALL_PATHOGEN_CREATURES)
			main_hive.evolution_menu_images[caste_name] = image('modular/xeno_races/icons/mob/xenos/radial_xenos.dmi', caste_name)

	var/datum/hive_status/pathogen/pathogen_hive = GLOB.hive_datum[XENO_HIVE_PATHOGEN]
	if(pathogen_hive)
		pathogen_hive.hive_structure_types[PATHOGEN_STRUCTURE_CORE] = /datum/construction_template/xenomorph/pathogen_core

	return
