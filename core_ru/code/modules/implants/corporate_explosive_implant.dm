GLOBAL_LIST_EMPTY_TYPED(corporate_explosive_implants, /obj/item/implant/corporate_explosive)

/// Head bomb given to Weyland-Yutani PMC presets. Only a game master can trigger it, from the Corporate Implants panel.
/obj/item/implant/corporate_explosive
	name = "corporate compliance implant"
	desc = "A tiny shaped charge wired into the base of the skull. Standard Weyland-Yutani contract enforcement."
	icon_state = "implant_evil"
	/// Set once the implant goes off, so it can't be triggered twice
	var/detonated = FALSE

/obj/item/implant/corporate_explosive/Initialize(mapload, ...)
	. = ..()
	GLOB.corporate_explosive_implants += src

/obj/item/implant/corporate_explosive/Destroy()
	GLOB.corporate_explosive_implants -= src
	imp_in = null
	return ..()

/obj/item/implant/corporate_explosive/get_data()
	return {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Weyland-Yutani WY-CC7 Contract Compliance Implant<BR>
<b>Life:</b> Activates upon receiving an encoded corporate signal.<BR>
<b>Important Notes:</b> Removal without corporate authorization voids the employment contract.<BR>
<HR>
<b>Implant Details:</b><BR>
<b>Function:</b> Contains a shaped micro-charge seated against the brain stem.<BR>
<b>Integrity:</b> Implant is hardened against the host's immune system."}

/// Returns the human this implant is still sitting in the head of, or null if it was removed or the head is gone.
/obj/item/implant/corporate_explosive/proc/get_host()
	var/mob/living/carbon/human/host = imp_in
	if(!ishuman(host) || loc != host)
		return null
	if(!istype(part, /obj/limb/head) || (part.status & LIMB_DESTROYED))
		return null
	return host

/// Gives the host a stabbing pain at the implant site, as a warning from the corporation.
/obj/item/implant/corporate_explosive/proc/warn_host(mob/user)
	var/mob/living/carbon/human/host = get_host()
	if(!host || detonated || host.stat == DEAD)
		return FALSE

	to_chat(host, SPAN_HIGHDANGER("You feel a sharp, stabbing pain at the base of your skull, right where the corporate implant sits. Someone is reminding you of your contract."))
	if(host.client)
		playsound_client(host.client, 'sound/items/countdown.ogg', host, 25)
	if(host.stat == CONSCIOUS && host.pain.feels_pain)
		INVOKE_ASYNC(host, TYPE_PROC_REF(/mob, emote), "pain")

	message_admins("[key_name_admin(user)] sent a warning through the corporate implant of [key_name_admin(host)]. [ADMIN_JMP(host)]")
	log_admin("[key_name(user)] sent a warning through the corporate implant of [key_name(host)].")
	return TRUE

/// Blows the host's head off.
/obj/item/implant/corporate_explosive/proc/detonate(mob/user)
	var/mob/living/carbon/human/host = get_host()
	if(!host || detonated)
		return FALSE
	detonated = TRUE

	var/obj/limb/head = part
	var/turf/host_turf = get_turf(host)

	message_admins("[key_name_admin(user)] detonated the corporate implant of [key_name_admin(host)]. [ADMIN_JMP(host)]")
	log_admin("[key_name(user)] detonated the corporate implant of [key_name(host)].")
	log_attack("[key_name(host)] had their head blown off by a corporate implant, detonated by [key_name(user)].")

	host.visible_message(SPAN_HIGHDANGER("[host]'s head bursts apart in a spray of blood, bone and brain matter!"),
		SPAN_HIGHDANGER("Something clicks inside your skull..."),
		SPAN_HIGHDANGER("You hear a wet, muffled bang!"))
	playsound(host_turf, "explosion", 60, TRUE)
	playsound(host_turf, 'sound/effects/gibbed.ogg', 50, TRUE)
	new /obj/effect/decal/cleanable/blood/gibs(host_turf)
	new /obj/effect/decal/cleanable/blood/splatter(host_turf)

	// The implant sits in the head, so droplimb() deletes it along with the head
	head.droplimb(FALSE, TRUE, create_cause_data("corporate implant", user))
	return TRUE
