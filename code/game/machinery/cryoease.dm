// CryoEase - флафф-препарат для пробуждения после гиперсна, ничего не делает кроме сранья сообщений в чат.
// При вкалывании второй дозы - рвота. При третьей, смэрть. (ваще не должно происходить ибо только одну дозу можно депнуть из вендора, но если вдруг найдутся умники которые у других возьмут.)

/datum/reagent/medical/cryoease
	name = "CryoEase"
	id = "cryoease"
	description = "A proprietary Weyland-Yutani post-hypersleep recovery compound. A blend of stimulants, anti-nausea agents and muscle reactivation compounds that counteracts neurochemical shock and muscular atrophy after extended hypersleep. Repeated dosing within a 24-hour cycle causes severe nausea and may lead to cardiac arrest."
	reagent_state = LIQUID
	color = "#8fd3ff"
	chemclass = CHEM_CLASS_NONE
	flags = REAGENT_TYPE_MEDICAL | REAGENT_SCANNABLE | REAGENT_NO_GENERATION
	custom_metabolism = AMOUNT_PER_TIME(1, 30 SECONDS)
	var/ticks_processed = 0
	var/dose_number = 0
	var/last_volume = 0 // надеюсь это будет работать
	var/static/list/datum/weakref/dosed_mobs = list()

/datum/reagent/medical/cryoease/on_mob_life(mob/living/M, alien, delta_time)
	var/new_dose = volume > last_volume
	. = ..()
	if(!. || !ishuman(M))
		return
	last_volume = volume
	var/mob/living/carbon/human/human = M
	if(human.species?.flags & IS_SYNTHETIC)
		return

	if(new_dose)
		var/datum/weakref/human_ref = WEAKREF(human)
		dose_number = dosed_mobs[human_ref] + 1
		dosed_mobs[human_ref] = dose_number
		ticks_processed = 0
	ticks_processed++

	switch(dose_number)
		if(1)
			process_first_dose(human)
		if(2)
			process_second_dose(human)
		else
			process_lethal_dose(human)

/datum/reagent/medical/cryoease/proc/process_first_dose(mob/living/carbon/human/human)
	switch(ticks_processed)
		if(1)
			to_chat(human, SPAN_NOTICE(SPAN_LARGE("A sharp chill runs up your arm as the CryoEase floods your veins.")))
		if(6)
			to_chat(human, SPAN_NOTICE(SPAN_LARGE("The fog of hypersleep lifts from your mind. Your thoughts sharpen and the nausea fades.")))
		if(11)
			to_chat(human, SPAN_NOTICE(SPAN_LARGE("Warmth spreads through your stiff muscles. Your body finally feels like your own again.")))

/datum/reagent/medical/cryoease/proc/process_second_dose(mob/living/carbon/human/human)
	switch(ticks_processed)
		if(1)
			to_chat(human, SPAN_WARNING(SPAN_LARGE("Your heart flutters as a second dose of CryoEase hits your bloodstream. That was a bad idea.")))
		if(6)
			to_chat(human, SPAN_WARNING(SPAN_LARGE("Your stomach churns violently.")))
			human.vomit()

/datum/reagent/medical/cryoease/proc/process_lethal_dose(mob/living/carbon/human/human)
	if(human.stat == DEAD)
		return
	switch(ticks_processed)
		if(1)
			to_chat(human, SPAN_DANGER(SPAN_LARGE("Your heart hammers against your ribs, faster and faster. Way too much CryoEase.")))
			human.make_jittery(300)
		if(3)
			to_chat(human, SPAN_DANGER(SPAN_LARGE("A crushing pain grips your chest. Your heart skips a beat... then another.")))
			human.apply_effect(10, PARALYZE)
		if(5)
			to_chat(human, SPAN_HIGHDANGER("Your heart stops."))
			human.death(create_cause_data("CryoEase overdose"))

/obj/item/reagent_container/hypospray/autoinjector/empty/skillless/unit/cryoease
	name = "CryoEase injector"
	desc = "A compact, single-use autoinjector designed to rapidly counteract the neurochemical shock and muscular atrophy associated with extended hypersleep. The CryoEase Injector, nicknamed the \"WakeyStick\", delivers a fast-acting blend of stimulants, anti-nausea agents, and muscle reactivation compounds directly into the bloodstream. Do not administer more than one dose per 24-hour cycle without medical oversight."
	chemname = "cryoease"
	uses_left = 1

/obj/item/reagent_container/hypospray/autoinjector/empty/skillless/unit/cryoease/Initialize()
	. = ..()
	reagents.add_reagent(chemname, volume)
	update_icon()

/// vendor
/obj/structure/cryoease_dispenser
	name = "\improper CryoEase dispenser"
	desc = "A wall-mounted Weyland-Yutani dispenser holding post-hypersleep recovery injectors. One per employee, as the label sternly reminds you."
	icon = 'core_ru/icons/injector.dmi'
	icon_state = "wallinject"
	anchored = TRUE
	density = FALSE
	unslashable = TRUE
	unacidable = TRUE
	var/amount = 20
	var/injector_type = /obj/item/reagent_container/hypospray/autoinjector/empty/skillless/unit/cryoease
	var/list/dispensed_to = list()

/obj/structure/cryoease_dispenser/get_examine_text(mob/user)
	. = ..()
	. += SPAN_NOTICE("It has [amount] injector\s left.")

/obj/structure/cryoease_dispenser/attack_hand(mob/living/carbon/human/user)
	if(!ishuman(user))
		return
	if(amount <= 0)
		to_chat(user, SPAN_WARNING("[src] is empty."))
		return
	if(user.real_name in dispensed_to)
		to_chat(user, SPAN_WARNING("[src] beeps: \"Dose already issued to [user.real_name].\""))
		return
	dispensed_to += user.real_name
	amount--
	var/obj/item/injector = new injector_type(loc)
	user.put_in_hands(injector)
	flick("[initial(icon_state)]_vend", src)
	playsound(src, 'sound/machines/vending_drop.ogg', 25, TRUE)
	to_chat(user, SPAN_NOTICE("[src] dispenses \a [injector]."))
