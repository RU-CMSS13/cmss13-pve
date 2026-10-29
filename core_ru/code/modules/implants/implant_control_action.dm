/// Wrist computer version of the Corporate Implants panel: lets the wearer warn or detonate the implants of their own faction.
/datum/action/human_action/synth_bracer/implant_control
	name = "Compliance Implant Control"
	icon_file = 'icons/mob/hud/actions.dmi'
	action_icon_state = "id_lock_locked"
	human_adaptable = TRUE
	/// Detonation has to be unlocked first, so a misclick can't blow anyone's head off
	var/armed = FALSE

/datum/action/human_action/synth_bracer/implant_control/form_call()
	tgui_interact(synth)

/datum/action/human_action/synth_bracer/implant_control/remove_from(user)
	SStgui.close_uis(src)
	return ..()

/datum/action/human_action/synth_bracer/implant_control/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CorporateImplantPanel", "Compliance Implant Control")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/action/human_action/synth_bracer/implant_control/ui_host(mob/user)
	return synth_bracer

/datum/action/human_action/synth_bracer/implant_control/ui_state(mob/user)
	return GLOB.not_incapacitated_and_inventory_state

/datum/action/human_action/synth_bracer/implant_control/ui_status(mob/user, datum/ui_state/state)
	if(!synth_bracer || !ishuman(user))
		return UI_CLOSE
	var/mob/living/carbon/human/human_user = user
	if(human_user.gloves != synth_bracer || !synth_bracer.allowed(user))
		return UI_CLOSE
	return ..()

/datum/action/human_action/synth_bracer/implant_control/ui_close(mob/user)
	armed = FALSE

/datum/action/human_action/synth_bracer/implant_control/ui_data(mob/user)
	var/list/data = list()

	data["admin"] = FALSE
	data["armed"] = armed
	data["implants"] = list()
	for(var/obj/item/implant/corporate_explosive/implant as anything in get_controlled_implants(user))
		var/list/implant_data = implant.get_ui_data()
		if(implant_data)
			data["implants"] += list(implant_data)

	return data

/datum/action/human_action/synth_bracer/implant_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	if(action == "toggle_armed")
		armed = !armed
		return TRUE

	var/obj/item/implant/corporate_explosive/implant = locate(params["ref"]) in get_controlled_implants(user)
	if(!implant)
		return TRUE

	switch(action)
		if("warn")
			implant.warn_host(user)
			return TRUE

		if("detonate")
			if(!armed)
				return TRUE
			implant.detonate(user)
			return TRUE

/// Returns the implants of the bracer's faction, except the user's own.
/datum/action/human_action/synth_bracer/implant_control/proc/get_controlled_implants(mob/user)
	. = list()
	for(var/obj/item/implant/corporate_explosive/implant as anything in GLOB.corporate_explosive_implants)
		var/mob/living/carbon/human/host = implant.get_host()
		if(!host || host == user || host.faction != synth_bracer.faction)
			continue
		. += implant
