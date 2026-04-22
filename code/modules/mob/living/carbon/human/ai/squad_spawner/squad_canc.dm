/datum/human_ai_squad_preset/canc
	faction = FACTION_CANC

/datum/human_ai_squad_preset/canc/riflemen
	name = "CANC Rebel, Patrol"
	ai_to_spawn = list(
		/datum/equipment_preset/canc/remnant/leader = 1,
		/datum/equipment_preset/canc/remnant = 2,
	)

/datum/human_ai_squad_preset/canc/lowgear
	name = "CANC Rebel, Low Gear Patrol (Pistols)"
	ai_to_spawn = list(
		/datum/equipment_preset/canc/remnant/lowgear = 2,
	)

/datum/human_ai_squad_preset/canc/lowgear/rifle
	name = "CANC Rebel, Low Gear Patrol (Rifles)"
	ai_to_spawn = list(
		/datum/equipment_preset/canc/remnant/lowgear/rifle = 2,
	)

/datum/human_ai_squad_preset/canc/recruits
	name = "CANC Rebel, Recruits"
	ai_to_spawn = list(
		/datum/equipment_preset/canc/remnant = 1,
		/datum/equipment_preset/canc/newblood = 2,
	)

/datum/human_ai_squad_preset/canc/lmgteam
	name = "CANC Rebel, Light Machinegun Team"
	ai_to_spawn = list(
		/datum/equipment_preset/canc/newblood_machinegunner = 1,
		/datum/equipment_preset/canc/newblood = 1,
	)

/datum/human_ai_squad_preset/canc/mgteam
	name = "CANC Rebel, Machinegun Team"
	ai_to_spawn = list(
		/datum/equipment_preset/canc/machinegunner = 1,
		/datum/equipment_preset/canc/remnant = 1,
	)

/datum/human_ai_squad_preset/canc/atteam
	name = "CANC Rebel, Anti-Tank Team"
	ai_to_spawn = list(
		/datum/equipment_preset/canc/at = 1,
		/datum/equipment_preset/canc/remnant = 1,
	)

/datum/human_ai_squad_preset/canc/rifleman_snowman
	name = "CANC Rebel Snowman, Patrol"
	ai_to_spawn = list(
		/datum/equipment_preset/canc/remnant/leader/snowman = 1,
		/datum/equipment_preset/canc/remnant/snowman = 2,
	)

/datum/human_ai_squad_preset/canc/mgteam_snowman
	name = "CANC Rebel Snowman, Machinegun Team"
	ai_to_spawn = list(
		/datum/equipment_preset/canc/machinegunner/snowman = 1,
		/datum/equipment_preset/canc/remnant/snowman = 1,
	)

/datum/human_ai_squad_preset/canc/atteam_snowman
	name = "CANC Rebel Snowman, Anti-Tank Team"
	ai_to_spawn = list(
		/datum/equipment_preset/canc/at/snowman = 1,
		/datum/equipment_preset/canc/remnant/snowman = 1,
	)
