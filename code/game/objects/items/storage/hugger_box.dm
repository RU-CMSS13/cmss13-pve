/// Holds a single live facehugger. It keeps the facehugger dormant until the lid is opened.
/obj/item/storage/hugger_box
	name = "small containment box"
	desc = "A sealed specimen box sized for a single facehugger. The lid can be set to pop open after a short delay."
	icon = 'icons/obj/items/storage/small_containment_box.dmi'
	icon_state = "small_containment_box"
	w_class = SIZE_MEDIUM
	storage_slots = 1
	can_hold = list(/obj/item/clothing/mask/facehugger)
	storage_flags = STORAGE_SHOW_FULLNESS
	use_sound = null
	flags_item = NOBLUDGEON
	/// The lid is open, so the facehugger leaps at whoever steps on or picks up the box
	var/active = FALSE
	/// The unlock timer is running
	var/priming = FALSE
	var/unlock_delay = 3 SECONDS
	var/lid_icon_state = "small_containment_box_closed"

/obj/item/storage/hugger_box/cultist
	name = "marked containment box"
	desc = "A sealed specimen box sized for a single facehugger. Someone has painted a strange symbol on the lid."
	lid_icon_state = "cultmark_closed"

/obj/item/storage/hugger_box/glass
	name = "glass containment box"
	desc = "A specimen box sized for a single facehugger, with a reinforced glass lid. The lid can be set to pop open after a short delay."
	lid_icon_state = "small_containment_box_glass_closed"

/obj/item/storage/hugger_box/get_examine_text(mob/user)
	. = ..()
	if(!get_hugger())
		. += SPAN_NOTICE("It is empty.")
	else if(active)
		. += SPAN_DANGER("The lid is open!")
	else if(priming)
		. += SPAN_WARNING("The lid lock is blinking.")

/obj/item/storage/hugger_box/proc/get_hugger()
	return locate(/obj/item/clothing/mask/facehugger) in contents

/obj/item/storage/hugger_box/can_be_inserted(obj/item/W, mob/user, stop_messages = FALSE)
	var/obj/item/clothing/mask/facehugger/hugger = W
	if(istype(hugger) && hugger.stat == DEAD)
		if(!stop_messages)
			to_chat(user, SPAN_WARNING("[hugger] is dead, there is nothing to contain."))
		return FALSE
	return ..()

/obj/item/storage/hugger_box/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !isturf(target.loc) || !(istype(target, /obj/item/clothing/mask/facehugger) || isfacehugger(target)))
		return ..()
	var/obj/item/clothing/mask/facehugger/stored_hugger = get_hugger()
	if(stored_hugger)
		to_chat(user, SPAN_WARNING("[src] already holds [stored_hugger]."))
		return
	if(isfacehugger(target))
		capture_mob_hugger(target, user)
		return
	if(can_be_inserted(target, user))
		handle_item_insertion(target, FALSE, user)

/obj/item/storage/hugger_box/proc/capture_mob_hugger(mob/living/carbon/xenomorph/facehugger/mob_hugger, mob/user)
	if(mob_hugger.stat == DEAD)
		to_chat(user, SPAN_WARNING("[mob_hugger] is dead, there is nothing to contain."))
		return
	if(mob_hugger.ckey) // Player controlled
		to_chat(user, SPAN_WARNING("[mob_hugger] squirms out of your reach!"))
		return
	var/obj/item/clothing/mask/facehugger/hugger = new(src, mob_hugger.hivenumber)
	_item_insertion(hugger, FALSE, user)
	qdel(mob_hugger)

/obj/item/storage/hugger_box/_item_insertion(obj/item/W, prevent_warning = FALSE, mob/user)
	var/obj/item/clothing/mask/facehugger/hugger = W
	if(istype(hugger))
		if(hugger.death_timer)
			deltimer(hugger.death_timer)
			hugger.death_timer = null
		if(hugger.jump_timer)
			deltimer(hugger.jump_timer)
			hugger.jump_timer = null
		hugger.go_idle()
	active = FALSE
	..()

/obj/item/storage/hugger_box/Exited(atom/movable/AM, newloc)
	. = ..()
	var/obj/item/clothing/mask/facehugger/hugger = AM
	if(!istype(hugger))
		return
	active = FALSE
	update_icon()
	if(hugger.stat == DEAD || hugger.attached)
		return
	if(!hugger.death_timer)
		hugger.death_timer = addtimer(CALLBACK(hugger, TYPE_PROC_REF(/obj/item/clothing/mask/facehugger, end_lifecycle)), hugger.time_to_live, TIMER_OVERRIDE|TIMER_STOPPABLE|TIMER_UNIQUE)
	hugger.go_active()

/obj/item/storage/hugger_box/open(mob/user)
	// Looking inside is enough for it to get you
	if(release_at(user))
		return
	return ..()

/obj/item/storage/hugger_box/attack_self(mob/user)
	. = ..() // Does nothing here, emptying is disabled by storage_flags
	if(active)
		active = FALSE
		update_icon()
		to_chat(user, SPAN_NOTICE("You shut the lid of [src]."))
		return
	if(priming)
		return
	if(!get_hugger())
		to_chat(user, SPAN_WARNING("[src] is empty."))
		return
	priming = TRUE
	playsound(src, 'sound/machines/twobeep.ogg', 25, TRUE)
	to_chat(user, SPAN_WARNING("You start the unlock timer on [src]!"))
	addtimer(CALLBACK(src, PROC_REF(prime)), unlock_delay)

/obj/item/storage/hugger_box/pickup(mob/user, silent)
	. = ..()
	if(active)
		release_at(user)

/obj/item/storage/hugger_box/Crossed(atom/movable/crosser)
	. = ..()
	if(active && isturf(loc))
		release_at(crosser)

/obj/item/storage/hugger_box/update_icon()
	overlays.Cut()
	if(!get_hugger())
		return
	overlays += image(icon, "facehugger_box")
	overlays += image(icon, "cover_inside")
	if(!active)
		overlays += image(icon, lid_icon_state)

/// Opens the lid and lets the facehugger go for whoever is holding or standing on the box.
/obj/item/storage/hugger_box/proc/prime()
	priming = FALSE
	if(!get_hugger())
		return
	active = TRUE
	update_icon()
	playsound(src, 'sound/machines/click.ogg', 25, TRUE)
	visible_message(SPAN_DANGER("The lid of [src] pops open!"))
	if(ishuman(loc))
		release_at(loc)
		return
	if(!isturf(loc))
		return
	for(var/mob/living/carbon/human/human in loc)
		if(release_at(human))
			return

/// Lets the facehugger out onto the target. Returns TRUE if it was released.
/obj/item/storage/hugger_box/proc/release_at(mob/living/carbon/human/target)
	var/obj/item/clothing/mask/facehugger/hugger = get_hugger()
	if(!hugger || !istype(target) || !can_hug(target, hugger.hivenumber))
		return FALSE
	remove_from_storage(hugger, get_turf(src))
	hugger.attach(target)
	return TRUE
