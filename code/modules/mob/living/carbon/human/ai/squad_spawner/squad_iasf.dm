/datum/human_ai_squad_preset/iasf
	faction = FACTION_IASF

/datum/human_ai_squad_preset/iasf/rifleteam
	name = "TWE, IASF Patrol Team"
	desc = "TWE IASF patrol group armed with F903 rifles."
	ai_to_spawn = list(
		/datum/equipment_preset/iasf/leader/lesser = 1,
		/datum/equipment_preset/iasf/standard = 2,
	)

/datum/human_ai_squad_preset/iasf/gunteam
	name = "TWE, IASF Fire Support Team, MG"
	desc = "TWE IASF fireteam armed with a F903 rifle and an L58A3 smartgun."
	ai_to_spawn = list(
		/datum/equipment_preset/iasf/machinegun = 1,
		/datum/equipment_preset/iasf/standard = 1,
	)

/datum/human_ai_squad_preset/iasf/gunteam_marksman
	name = "TWE, IASF Fire Support Team, Marksman"
	desc = "TWE IASF fireteam armed with a F903 and an F903A1 marksman rifles."
	ai_to_spawn = list(
		/datum/equipment_preset/iasf/sniper/light = 1,
		/datum/equipment_preset/iasf/standard = 1,
	)

/datum/human_ai_squad_preset/iasf/squad
	name = "TWE, IASF Infantry Squad, MG"
	desc = "TWE IASF squad armed with F903 rifles and an L58A3 smartgun."
	ai_to_spawn = list(
		/datum/equipment_preset/iasf/leader = 1,
		/datum/equipment_preset/iasf/leader/lesser = 1,
		/datum/equipment_preset/iasf/standard = 2,
		/datum/equipment_preset/iasf/machinegun = 1,
	)

/datum/human_ai_squad_preset/iasf/squad_marksman
	name = "TWE, IASF Infantry Squad, Marksman"
	desc = "TWE IASF squad armed with F903 rifles and an F903A1 marksman rifle."
	ai_to_spawn = list(
		/datum/equipment_preset/iasf/leader = 1,
		/datum/equipment_preset/iasf/leader/lesser = 1,
		/datum/equipment_preset/iasf/standard = 2,
		/datum/equipment_preset/iasf/sniper/light = 1,
	)

/datum/human_ai_squad_preset/iasf/support
	name = "TWE, IASF Technician Support Team"
	desc = "TWE IASF specialist team armed with P90 SMG and F903 rifle, carrying ample medical & engineering supplies."
	ai_to_spawn = list(
		/datum/equipment_preset/iasf/medic = 1,
		/datum/equipment_preset/iasf/engineer = 1,
	)

/datum/human_ai_squad_preset/iasf/command
	name = "TWE, Command Component"
	desc = "TWE IASF platoon commander and his escort armed with NSG L23 and F903 rifles, carrying ample ammunition."
	ai_to_spawn = list(
		/datum/equipment_preset/iasf/lieutenant = 1,
		/datum/equipment_preset/iasf/troopsergeant = 1,
		/datum/equipment_preset/iasf/standard = 2,
	)
