/obj/vehicle/multitile
	/// The AI driving this vehicle, if any
	var/datum/vehicle_ai_brain/ai_brain

/// Hands the vehicle over to an AI fighting for the given faction, crewed by human AI of the given preset
/obj/vehicle/multitile/proc/enable_ai(faction, datum/equipment_preset/crew_preset, infinite_ammo = FALSE)
	RETURN_TYPE(/datum/vehicle_ai_brain)
	if(!ai_brain)
		new /datum/vehicle_ai_brain(src, faction)
	else
		ai_brain.set_faction(faction)
	ai_brain.crew_preset = crew_preset
	ai_brain.infinite_ammo = infinite_ammo
	return ai_brain

/obj/vehicle/multitile/proc/disable_ai()
	QDEL_NULL(ai_brain)

/// TRUE if the AI can drive the vehicle right now, mirroring the checks done for a driver in relaymove()
/obj/vehicle/multitile/proc/ai_can_move()
	if(health <= 0)
		return FALSE

	// Non-square vehicles can't rotate yet, so the AI can't steer them
	if(!can_rotate(90))
		return FALSE

	for(var/obj/item/hardpoint/locomotion/locomotion in hardpoints)
		if(locomotion.health > 0)
			return TRUE
	return FALSE

/obj/vehicle/multitile/arc/ai_can_move()
	if(antenna_deployed)
		return FALSE
	return ..()

/obj/vehicle/multitile/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "-----VEHICLE-----")
	VV_DROPDOWN_OPTION(VV_HK_TOGGLE_VEHICLE_AI, "Toggle AI Control")

/obj/vehicle/multitile/vv_do_topic(list/href_list)
	. = ..()
	if(!href_list[VV_HK_TOGGLE_VEHICLE_AI] || !check_rights(R_DEBUG))
		return

	if(ai_brain)
		disable_ai()
		message_admins("[key_name_admin(usr)] disabled the AI of [src].", x, y, z)
		return

	var/list/factions = list()
	for(var/faction_name in SShuman_ai.human_ai_factions)
		factions += faction_name
	var/new_faction = tgui_input_list(usr, "Choose the faction the vehicle fights for. Friendly and neutral factions are the same as for human AI of that faction.", "Vehicle AI Faction", factions)
	if(!new_faction || QDELETED(src))
		return

	var/static/list/crew_presets = list(
		/datum/equipment_preset/uscm/tank/ammo_rig,
		/datum/equipment_preset/upp/tank/ammo_rig,
		/datum/equipment_preset/uscm/tank,
		/datum/equipment_preset/upp/tank,
	)
	var/list/crew_options = list()
	for(var/datum/equipment_preset/preset_type as anything in crew_presets)
		crew_options[preset_type::name] = preset_type
	var/crew_choice = tgui_input_list(usr, "Choose the human AI crew seated in the driver and gunner seats.", "Vehicle AI Crew", crew_options)
	if(!crew_choice || QDELETED(src) || ai_brain)
		return

	enable_ai(new_faction, crew_options[crew_choice])
	message_admins("[key_name_admin(usr)] gave [src] an AI fighting for [new_faction] ([crew_choice]).", x, y, z)

// Spawners

/obj/effect/vehicle_spawner/tank/fixed/ai
	name = "AI Tank Spawner (LTB)"
	ai_faction = FACTION_MARINE
	ai_crew_preset = /datum/equipment_preset/uscm/tank/ammo_rig

/obj/effect/vehicle_spawner/tank/fixed/minigun/ai
	name = "AI Tank Spawner (MINIGUN)"
	ai_faction = FACTION_MARINE
	ai_crew_preset = /datum/equipment_preset/uscm/tank/ammo_rig

/obj/effect/vehicle_spawner/tank/fixed/flamer/ai
	name = "AI Tank Spawner (FLAMER)"
	ai_faction = FACTION_MARINE
	ai_crew_preset = /datum/equipment_preset/uscm/tank/ammo_rig

/obj/effect/vehicle_spawner/tank/fixed/autocannon/ai
	name = "AI Tank Spawner (AUTOCANNON)"
	ai_faction = FACTION_MARINE
	ai_crew_preset = /datum/equipment_preset/uscm/tank/ammo_rig

/obj/effect/vehicle_spawner/upptank/fixed/ai
	name = "AI Tank Spawner (UPP)"
	ai_faction = FACTION_UPP
	ai_crew_preset = /datum/equipment_preset/upp/tank/ammo_rig
