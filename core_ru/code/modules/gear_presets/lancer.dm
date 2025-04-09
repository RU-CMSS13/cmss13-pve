/datum/equipment_preset/uscm/lancer
	name = "Freelancer Marauder"
	role_comm_title = "FL"
	access = list(ACCESS_ILLEGAL_PIRATE)
	faction_group = list(FACTION_FREELANCER)
	faction = FACTION_FREELANCER
	flags = EQUIPMENT_PRESET_START_OF_ROUND|EQUIPMENT_PRESET_MARINE
	assignment = "Marauder"
	rank = JOB_SQUAD_MARINE
	skills = /datum/skills/pfc
	minimap_icon = "private"

/datum/equipment_preset/uscm/lancer/smartgunner
	name = "Freelancer Machinegunner"
	role_comm_title = "MG"
	access = list(ACCESS_ILLEGAL_PIRATE)
	assignment = "Machinegunner"
	rank = JOB_SQUAD_SMARTGUN
	skills = /datum/skills/smartgunner
	minimap_icon = "smartgunner"

/datum/equipment_preset/uscm/lancer/rto
	name = "Radio Jockey"
	role_comm_title = "RJ"
	access = list(ACCESS_ILLEGAL_PIRATE)
	assignment = "Radio Jokey"
	rank = JOB_SQUAD_RTO
	skills = /datum/skills/SL
	minimap_icon = "rto"

/datum/equipment_preset/uscm/lancer/med
	name = "Freelancer Surgeon"
	role_comm_title = "Srg"
	access = list(ACCESS_ILLEGAL_PIRATE)
	assignment = "Surgeon"
	rank = JOB_SQUAD_MEDIC
	skills = /datum/skills/combat_medic
	minimap_icon = "medic"

/datum/equipment_preset/uscm/lancer/tl
	name = "Freelancer Bruiser"
	role_comm_title = "Bruiser"
	access = list(ACCESS_ILLEGAL_PIRATE)
	assignment = "Bruiser"
	rank = JOB_SQUAD_TEAM_LEADER
	skills = /datum/skills/pmc/SL
	minimap_icon = "tl"

/datum/equipment_preset/uscm/lancer/sl
	name = "Freelancer Warlord"
	role_comm_title = "Warlord"
	access = list(ACCESS_ILLEGAL_PIRATE)
	assignment = "Warlord"
	rank = JOB_SQUAD_LEADER
	skills = /datum/skills/pmc/SL
	minimap_icon = "leader"
