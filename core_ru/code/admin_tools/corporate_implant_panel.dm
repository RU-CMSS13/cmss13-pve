GLOBAL_DATUM_INIT(corporate_implant_panel, /datum/corporate_implant_panel, new)

/client/proc/open_corporate_implant_panel()
	set name = "Corporate Implants"
	set category = "Game Master.Extras"
	if(!check_rights(R_ADMIN))
		return

	GLOB.corporate_implant_panel.tgui_interact(mob)

/// Game master panel to warn or detonate the explosive implants of corporate presets.
/datum/corporate_implant_panel
	/// ckeys of admins who have unlocked detonation. Kept per admin so one GM arming the panel doesn't arm it for everyone.
	var/list/armed_ckeys = list()

/datum/corporate_implant_panel/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CorporateImplantPanel", "Corporate Implants")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/corporate_implant_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/corporate_implant_panel/ui_close(mob/user)
	armed_ckeys -= user.ckey

/datum/corporate_implant_panel/ui_data(mob/user)
	var/list/data = list()

	data["armed"] = (user.ckey in armed_ckeys)
	data["implants"] = list()
	for(var/obj/item/implant/corporate_explosive/implant as anything in GLOB.corporate_explosive_implants)
		var/mob/living/carbon/human/host = implant.get_host()
		if(!host || implant.detonated)
			continue

		var/status = "Alive"
		switch(host.stat)
			if(UNCONSCIOUS)
				status = "Unconscious"
			if(DEAD)
				status = "Dead"

		var/area/host_area = get_area(host)
		data["implants"] += list(list(
			"name" = host.real_name,
			"job" = host.job || "Unknown",
			"status" = status,
			"area" = host_area?.name || "Unknown",
			"player" = !!host.client,
			"ref" = REF(implant),
		))

	return data

/datum/corporate_implant_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	if(!check_rights(R_ADMIN))
		return

	if(action == "toggle_armed")
		if(user.ckey in armed_ckeys)
			armed_ckeys -= user.ckey
		else
			armed_ckeys += user.ckey
		return TRUE

	var/obj/item/implant/corporate_explosive/implant = locate(params["ref"]) in GLOB.corporate_explosive_implants
	if(!implant)
		return TRUE
	var/mob/living/carbon/human/host = implant.get_host()
	if(!host)
		return TRUE

	switch(action)
		if("jump")
			user.client?.jump_to_turf(get_turf(host))
			return TRUE

		if("warn")
			implant.warn_host(user)
			return TRUE

		if("detonate")
			if(!(user.ckey in armed_ckeys))
				return TRUE
			implant.detonate(user)
			return TRUE
