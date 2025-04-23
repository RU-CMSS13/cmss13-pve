/datum/squad/marine/lancer
	name = SQUAD_MERC
	equipment_color = "#8d8d8d"
	chat_color = "#424242"
	access = list(ACCESS_ILLEGAL_PIRATE)
	minimap_color = MINIMAP_SQUAD_LANCER
	radio_freq = PUB_FREQ
	use_stripe_overlay = FALSE
	usable = TRUE
	faction = FACTION_FREELANCER

/datum/squad/marine/lancer/New()
	. = ..()

	RegisterSignal(SSdcs, COMSIG_GLOB_PLATOON_NAME_CHANGE, PROC_REF(rename_platoon)) //this signal allows pltco to change platoon’s name
