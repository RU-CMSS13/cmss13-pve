/datum/faction/conam
	name = "Con-Amalagated Corporation"
	faction_tag = FACTION_CONAM

/datum/faction/conam/modify_hud_holder(image/holder, mob/living/carbon/human/H)
	var/hud_icon_state
	var/obj/item/card/id/ID = H.get_idcard()
	var/_role
	if(H.mind)
		_role = H.job
	else if(ID)
		_role = ID.rank
	switch(_role)
		if(JOB_CA_TRAINEE)
			hud_icon_state = "trainee"
		if(JOB_CA_JUNIOR_EXECUTIVE)
			hud_icon_state = "junior_exec"
		if(JOB_CA_CORPORATE_LIAISON)
			hud_icon_state = "liaison"
		if(JOB_CA_EXECUTIVE)
			hud_icon_state = "liaison"
		if(JOB_CA_SENIOR_EXECUTIVE)
			hud_icon_state = "senior_exec"
		if(JOB_CA_EXECUTIVE_SPECIALIST, JOB_CA_LEGAL_SPECIALIST)
			hud_icon_state = "exec_spec"
		if(JOB_CA_EXECUTIVE_SUPERVISOR, JOB_CA_LEGAL_SUPERVISOR)
			hud_icon_state = "exec_super"
	if(hud_icon_state)
		holder.overlays += image('icons/mob/hud/marine_hud.dmi', H, "hc_[hud_icon_state]")
