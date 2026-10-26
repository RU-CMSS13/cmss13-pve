// Carrying the RUV by hand, the way cats and mice get scooped up

/obj/item/holder/ruv
	name = "RUV"
	icon = 'core_ru/icons/ruv.dmi'
	icon_state = "carried_empty"
	item_state = "empty"
	item_icons = list(
		WEAR_L_HAND = 'core_ru/icons/ruv_lefthand.dmi',
		WEAR_R_HAND = 'core_ru/icons/ruv_righthand.dmi',
	)
	w_class = SIZE_MASSIVE
	flags_equip_slot = NO_FLAGS

/obj/item/holder/ruv/pickup(mob/user, silent)
	. = ..()
	RegisterSignal(user, COMSIG_HUMAN_POST_MOVE_DELAY, PROC_REF(handle_movedelay), override = TRUE)

/obj/item/holder/ruv/dropped(mob/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_HUMAN_POST_MOVE_DELAY)
	// Put down on the floor, the RUV rolls out at once instead of on the next process tick
	addtimer(CALLBACK(src, PROC_REF(release_if_on_floor)), 1)

/obj/item/holder/ruv/proc/handle_movedelay(mob/user, list/movedata)
	SIGNAL_HANDLER
	if(loc == user)
		movedata["move_delay"] += RUV_CARRY_SLOWDOWN

/obj/item/holder/ruv/proc/release_if_on_floor()
	if(!QDELETED(src) && isturf(loc))
		process()

/obj/item/holder/ruv/proc/update_from(mob/living/simple_animal/ruv/bot)
	var/base_state = bot.module ? bot.module.bot_icon_state : "empty"
	icon_state = "carried_[bot.body_prefix][base_state]"
	item_state = "[bot.body_prefix][base_state]"
	var/mob/holder_mob = loc
	if(istype(holder_mob))
		holder_mob.update_inv_l_hand()
		holder_mob.update_inv_r_hand()

/mob/living/simple_animal/ruv/MouseDrop(atom/over_object)
	var/mob/living/carbon/human/grabber = over_object
	if(!CAN_PICKUP(usr, src) || !istype(grabber) || grabber != usr || grabber.a_intent != INTENT_HELP)
		return ..()
	get_scooped(grabber)

/mob/living/simple_animal/ruv/get_scooped(mob/living/carbon/grabber)
	if(stat == DEAD || !ishuman(grabber))
		return
	if(grabber.l_hand && grabber.r_hand)
		to_chat(grabber, SPAN_WARNING("You need a free hand to lift [src]."))
		return
	grabber.visible_message(SPAN_NOTICE("[grabber] starts lifting [src]."), SPAN_NOTICE("You start lifting [src]. It is heavy."))
	if(!do_after(grabber, 1 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_GENERIC, src))
		return
	if(!isturf(loc) || !grabber.Adjacent(src))
		return
	var/obj/item/holder/ruv/holder = pack()
	grabber.put_in_hands(holder)
	grabber.visible_message(SPAN_NOTICE("[grabber] lifts [src]."), SPAN_NOTICE("You lift [src]."))

/// Folds the RUV into an item, wherever it is: on the floor, or in its crate
/mob/living/simple_animal/ruv/proc/pack()
	disconnect()
	stop_walking()
	stop_pulling()
	var/obj/item/holder/ruv/holder = new(loc)
	holder.name = name
	holder.desc = desc
	forceMove(holder)
	invisibility = INVISIBILITY_MAXIMUM
	holder.update_from(src)
	return holder

// The crate it is shipped in

/mob/living/simple_animal/ruv/packed
	cell = null

/mob/living/simple_animal/ruv/pmc
	name = "\improper WY RUV-7P remote utility vehicle"
	desc = "A Weyland-Yutani refit of the RUV-7 remote utility vehicle in white corporate livery, driven from a hand-held control unit. A hardpoint on its hull takes either a manipulator arm or a light sentry module."
	faction = FACTION_PMC
	body_prefix = "pmc_"

/mob/living/simple_animal/ruv/pmc/arm
	module = /obj/item/ruv_module/arm

/mob/living/simple_animal/ruv/pmc/sentry
	module = /obj/item/ruv_module/sentry

/mob/living/simple_animal/ruv/pmc/packed
	cell = null

/obj/item/ruv_module/sentry/empty
	magazine = null

/obj/structure/closet/crate/ruv
	name = "\improper RUV-7 deployment crate"
	desc = "A crate with an RUV-7 remote utility vehicle, its control unit, both hardpoint modules, three batteries and two sentry ammo drums."
	icon_state = "closed_weapons"
	icon_opened = "open_weapons"
	icon_closed = "closed_weapons"
	var/ruv_type = /mob/living/simple_animal/ruv/packed
	var/magazine_type = /obj/item/ammo_magazine/sentry

/obj/structure/closet/crate/ruv/pmc
	name = "\improper W-Y RUV deployment crate"
	desc = "A Weyland-Yutani crate with a WY RUV-7P remote utility vehicle, its control unit, both hardpoint modules, three batteries and two H20 sentry ammo drums."
	icon_state = "secure_unlocked_weyland"
	icon_opened = "secure_open_weyland"
	icon_closed = "secure_unlocked_weyland"
	ruv_type = /mob/living/simple_animal/ruv/pmc/packed
	magazine_type = /obj/item/ammo_magazine/sentry/wy

/obj/structure/closet/crate/ruv/Initialize()
	. = ..()
	var/mob/living/simple_animal/ruv/bot = new ruv_type(src)
	bot.pack()
	new /obj/item/device/ruv_controller(src)
	new /obj/item/ruv_module/arm(src)
	new /obj/item/ruv_module/sentry/empty(src)
	new /obj/item/cell/ruv(src)
	new /obj/item/cell/ruv(src)
	new /obj/item/cell/ruv(src)
	new magazine_type(src)
	new magazine_type(src)
