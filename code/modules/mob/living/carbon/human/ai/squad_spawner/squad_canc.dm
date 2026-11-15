/datum/human_ai_squad_preset/canc
	faction = FACTION_CANC

/datum/human_ai_squad_preset/canc/riflemen
	name = "CANC Rebel, Patrol"
	ai_to_spawn = list(
		/datum/equipment_preset/canc/remnant/leader = 1,
		/datum/equipment_preset/canc/remnant = 2,
	)

/datum/human_ai_squad_preset/canc/patrol
	name = "CANC Reserve Forces, Patrol"
	desc = "2 soldiers, 1 leader."
	ai_to_spawn = list(
		/datum/equipment_preset/canc/remnant/leader = 1,
		/datum/equipment_preset/canc/remnant/old = 2,
	)

/datum/human_ai_squad_preset/canc/squad
	name = "CANC Reserve Forces, Squad"
	desc = "3 soldiers, 1 leader, 1 medic."
	ai_to_spawn = list(
		/datum/equipment_preset/canc/remnant/leader = 1,
		/datum/equipment_preset/canc/remnant/old = 3,
		/datum/equipment_preset/canc/remnant/old/medic = 1,
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

/datum/human_ai_squad_preset/canc/brotherhood
	name = "CANC Brotherhood, Patrol"
	ai_to_spawn = list(
		/datum/equipment_preset/canc/blackops = 2,
	)

/datum/human_ai_squad_preset/canc/brotherhood_lmgteam
	name = "CANC Brotherhood, Light Machinegun Team"
	ai_to_spawn = list(
		/datum/equipment_preset/canc/blackops = 1,
		/datum/equipment_preset/canc/machinegunner/blackops = 1,
	)

/datum/human_ai_squad_preset/canc/brotherhood_squad
	name = "CANC Brotherhood, Squad (DANGEROUS)"
	ai_to_spawn = list(
		/datum/equipment_preset/canc/blackops = 3,
		/datum/equipment_preset/canc/medic/blackops = 1,
		/datum/equipment_preset/canc/leader/blackops = 1,
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

/datum/human_ai_squad_preset/canc/meatwave
	name = "CANC Army Reserve Forces, Assault Force"
	desc = "6 soldiers."
	ai_to_spawn = list(
		/datum/equipment_preset/canc/remnant/old = 6,
	)

/datum/human_ai_squad_preset/canc/commando
	name = "CANC Army Commandos, Squad"
	desc = "2 commandos, 1 leader."
	ai_to_spawn = list(
		/datum/equipment_preset/canc/remnant/old/commando/leader = 1,
		/datum/equipment_preset/canc/remnant/old/commando = 2,
	)

/datum/human_ai_squad_preset/canc/commando_mg_team
	name = "CANC Army Commandos, Machinegun Team"
	desc = "1 commando, 1 MG."
	ai_to_spawn = list(
		/datum/equipment_preset/canc/remnant/old/commando/machinegunner = 1,
		/datum/equipment_preset/canc/remnant/old/commando = 1,
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
