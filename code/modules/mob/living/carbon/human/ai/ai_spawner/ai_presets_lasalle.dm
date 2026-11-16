/datum/human_ai_equipment_preset/lasalle
	faction = FACTION_LASALLE_BIONATIONAL

// Hazard Intervention Group

/datum/human_ai_equipment_preset/lasalle/hig
	name = "HIG - Operator"
	desc = "The standard Lasalle Bionational Hazard Intervention Group operator. Usually armed with an A-M36 SMG, rarely a combat shotgun."
	path = /datum/equipment_preset/survivor/lasalle_merc/standard

/datum/human_ai_equipment_preset/lasalle/hig/medic
	name = "HIG - Medical Specialist"
	desc = "The medical element of a HIG team. Same weapons as the operator, carries extra medical supplies."
	path = /datum/equipment_preset/survivor/lasalle_merc/medic

/datum/human_ai_equipment_preset/lasalle/hig/engineer
	name = "HIG - Technical Specialist"
	desc = "The technical element of a HIG team. Same weapons as the operator, carries tools and engineering supplies."
	path = /datum/equipment_preset/survivor/lasalle_merc/engineer

/datum/human_ai_equipment_preset/lasalle/hig/leader
	name = "HIG - Team Leader"
	desc = "The leader of a HIG team. Same weapons as the operator."
	path = /datum/equipment_preset/survivor/lasalle_merc/leader

/datum/human_ai_equipment_preset/lasalle/hig/commander
	name = "HIG - Operations Commander"
	desc = "The commander of a HIG operation. Armed with an A-M36 SMG and a suppressed Beretta."
	path = /datum/equipment_preset/survivor/lasalle_merc/lasalle_commander

/datum/human_ai_equipment_preset/lasalle/hig/synth
	name = "HIG - Support Synthetic"
	desc = "A HIG support synthetic. Unarmored and only carries a telescopic baton."
	path = /datum/equipment_preset/synth/survivor/lasalle_merc

// Fire Colony personnel, ordinary colony workers rather than corporate operatives, so they use the colonist faction

/datum/human_ai_equipment_preset/lasalle_personnel
	faction = FACTION_COLONIST

/datum/human_ai_equipment_preset/lasalle_personnel/security
	name = "Lasalle - Corporate Security Guard"
	desc = "A Lasalle Bionational security guard. Armed with a W/EK 17 carbine."
	path = /datum/equipment_preset/survivor/fire_colony/corporate_goon

/datum/human_ai_equipment_preset/lasalle_personnel/liaison
	name = "Lasalle - Corporate Liaison"
	desc = "A Lasalle Bionational corporate representative. Might carry a firearm."
	path = /datum/equipment_preset/survivor/lasalle_bionational

/datum/human_ai_equipment_preset/lasalle_personnel/civilian
	name = "Lasalle - Colonist"
	desc = "A Lasalle Bionational colony worker. Might carry a firearm."
	path = /datum/equipment_preset/survivor/fire_colony/civilian

/datum/human_ai_equipment_preset/lasalle_personnel/doctor
	name = "Lasalle - Doctor"
	desc = "A Lasalle Bionational colony doctor. Might carry a firearm."
	path = /datum/equipment_preset/survivor/fire_colony/doctor

/datum/human_ai_equipment_preset/lasalle_personnel/engineer
	name = "Lasalle - Engineer"
	desc = "A Lasalle Bionational colony engineer. Might carry a firearm."
	path = /datum/equipment_preset/survivor/fire_colony/engineer

/datum/human_ai_equipment_preset/lasalle_personnel/xenoarchaeologist
	name = "Lasalle - Xenoarchaeologist"
	desc = "A Lasalle Bionational xenoarchaeologist. Might carry a firearm."
	path = /datum/equipment_preset/survivor/fire_colony/scientist_xenoarchaeologist

/datum/human_ai_equipment_preset/lasalle_personnel/xenobiologist
	name = "Lasalle - Xenobiologist"
	desc = "A Lasalle Bionational xenobiologist. Might carry a firearm."
	path = /datum/equipment_preset/survivor/fire_colony/scientist_xenobiologist

/datum/human_ai_equipment_preset/lasalle_personnel/xenoflora
	name = "Lasalle - Xenobotanist"
	desc = "A Lasalle Bionational xenobotanist. Might carry a firearm."
	path = /datum/equipment_preset/survivor/fire_colony/scientist_xenoflora
