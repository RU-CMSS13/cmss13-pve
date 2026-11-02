/datum/action/human_action/synth_bracer/med_injector
	name = "Emergency Injection"
	icon_file = 'icons/mob/hud/actions.dmi'
	action_icon_state = "syringe_inject"
	cooldown = 1 MINUTES
	charge_cost = 50
	human_adaptable = TRUE

	/// Reagents synthesised and injected into the wearer per use, as reagent id = amount.
	var/list/dose = list(
		"oxycodone" = 20,
		"bicaridine" = 30,
		"kelotane" = 30,
		"meralyne" = 15,
		"dermaline" = 15,
		"dexalinp" = 1,
		"inaprovaline" = 30,
	)

/datum/action/human_action/synth_bracer/med_injector/form_call()
	if(!synth.reagents)
		return
	for(var/reagent_id in dose)
		synth.reagents.add_reagent(reagent_id, dose[reagent_id])
	playsound(synth, 'sound/items/hypospray.ogg', 25, TRUE)
	to_chat(synth, SPAN_NOTICE("[synth_bracer.name] beeps, \"Emergency injection administered.\" You feel a tiny prick in your wrist."))
