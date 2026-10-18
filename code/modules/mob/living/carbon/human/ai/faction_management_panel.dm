#define FACTION_RELATION_HOSTILE "hostile"
#define FACTION_RELATION_NEUTRAL "neutral"
#define FACTION_RELATION_FRIENDLY "friendly"

/datum/human_faction_management_menu

/datum/human_faction_management_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HumanFactionManager", "Human Faction Manager")
		ui.open()

/datum/human_faction_management_menu/ui_state(mob/user)
	return GLOB.admin_state

/datum/human_faction_management_menu/ui_data(mob/user)
	var/list/data = list()

	var/list/ai_counts = list()
	for(var/datum/human_ai_brain/brain as anything in GLOB.human_ai_brains)
		var/mob/living/carbon/human/ai_human = brain.tied_human
		if(ai_human && (ai_human.stat != DEAD))
			ai_counts[ai_human.faction]++

	data["factions"] = list()
	for(var/faction_name in SShuman_ai.human_ai_factions)
		var/datum/human_ai_faction/ai_faction = SShuman_ai.human_ai_factions[faction_name]
		data["factions"] += list(list(
			"name" = ai_faction.faction,
			"shoot_to_kill" = ai_faction.get_shoot_to_kill(),
			"friendly" = ai_faction.get_friendly_factions(),
			"neutral" = ai_faction.get_neutral_factions(),
			"ai_count" = ai_counts[ai_faction.faction] || 0,
		))

	return data

/datum/human_faction_management_menu/ui_static_data(mob/user)
	var/list/data = list()

	data["all_factions"] = FACTION_LIST_HUMANOID + FACTION_LIST_XENOMORPH

	return data

/datum/human_faction_management_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("create_faction")
			var/gotten_faction = params["faction"]
			if(!(gotten_faction in FACTION_LIST_HUMANOID + FACTION_LIST_XENOMORPH) || (gotten_faction in SShuman_ai.human_ai_factions))
				return

			var/datum/human_ai_faction/new_faction = new()
			new_faction.faction = gotten_faction
			SShuman_ai.human_ai_factions[new_faction.faction] = new_faction
			return TRUE

		if("set_shoot_to_kill")
			var/datum/human_ai_faction/faction_obj = SShuman_ai.human_ai_factions[params["faction"]]
			if(!faction_obj)
				return

			faction_obj.set_shoot_to_kill(!!text2num(params["value"]))
			return TRUE

		if("set_relation")
			var/datum/human_ai_faction/faction_obj = SShuman_ai.human_ai_factions[params["faction"]]
			var/other_faction = params["other"]
			if(!faction_obj || !(other_faction in FACTION_LIST_HUMANOID + FACTION_LIST_XENOMORPH) || (other_faction == faction_obj.faction))
				return

			set_relation(faction_obj, other_faction, params["relation"])
			// The other side sees us the same way, if it has an AI faction
			if(text2num(params["mutual"]))
				var/datum/human_ai_faction/other_obj = SShuman_ai.human_ai_factions[other_faction]
				if(other_obj)
					set_relation(other_obj, faction_obj.faction, params["relation"])
			return TRUE

/// Makes faction_obj see other_faction as hostile, neutral or friendly
/datum/human_faction_management_menu/proc/set_relation(datum/human_ai_faction/faction_obj, other_faction, relation)
	switch(relation)
		if(FACTION_RELATION_FRIENDLY)
			faction_obj.add_friendly_faction(other_faction)
		if(FACTION_RELATION_NEUTRAL)
			faction_obj.add_neutral_faction(other_faction)
		if(FACTION_RELATION_HOSTILE)
			faction_obj.remove_friendly_faction(other_faction)
			faction_obj.remove_neutral_faction(other_faction)

/client/proc/open_human_faction_management_panel()
	set name = "Human Faction Management Panel"
	set category = "Game Master.HumanAI"

	if(!check_rights(R_DEBUG))
		return

	if(!human_faction_menu)
		human_faction_menu = new /datum/human_faction_management_menu()

	human_faction_menu.tgui_interact(mob)

#undef FACTION_RELATION_HOSTILE
#undef FACTION_RELATION_NEUTRAL
#undef FACTION_RELATION_FRIENDLY
