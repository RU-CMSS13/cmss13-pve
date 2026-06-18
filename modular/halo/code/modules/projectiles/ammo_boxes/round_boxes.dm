// HALO PVE EDIT - VARIOUS AMMO PACKETS

/obj/item/ammo_box/rounds/unsc
	name = "\improper generic ammunition packet"
	desc = "A tear-open packet of ammo to refill spent magazines. This one reads \"SHOULD NOT BE SEEN\"."
	icon = 'modular/halo/icons/halo/obj/items/storage/packets.dmi'
	icon_state = "ammo_packet"
	item_state = "ammo_packet"
	flags_equip_slot = null
	w_class = SIZE_SMALL
	default_ammo = /datum/ammo/bullet/rifle/ma5
	bullet_amount = 120 //120 AR, 72 magnum, 180 SMG, 108 BR
	max_bullet_amount = 120
	caliber = "7.62x51"
	can_explode = FALSE
	var/opened = FALSE
	var/use_sound = "rip"
	///Should the packet rotate when thrown?
	var/rotation_on_throw = FALSE

//---------------------GENERAL PROCS

/obj/item/ammo_box/rounds/unsc/Initialize()
	. = ..()
	if(empty)
		opened = TRUE
		bullet_amount = 0
		empty = TRUE
		update_icon()
	else
		opened = FALSE
		icon_state = "[initial(icon_state)]"

/obj/item/ammo_box/rounds/unsc/update_icon()
	if(opened)
		icon_state = "[initial(icon_state)]_o"

//---------------------INTERACTION PROCS

/obj/item/ammo_box/rounds/unsc/attack_self(mob/living/carbon/human/user)
	if(user.a_intent == INTENT_HARM)
		unfold_box(user)
		return
	else
		if(!opened)
			open_packet()
			user.pickup_recent()
			return
	..()

/obj/item/ammo_box/rounds/unsc/proc/open_packet(mob/living/user)
	if(!opened)
		opened = TRUE
		playsound(loc, use_sound, 25, TRUE, 3)
		update_icon()

/obj/item/ammo_box/rounds/unsc/unfold_box(mob/user)
	if(is_loaded())
		to_chat(user, SPAN_WARNING("You need to empty the packet before unfolding it!"))
		return
	qdel(src)

/obj/item/ammo_box/rounds/unsc/attackby(obj/item/I, mob/user)
	if(!opened)
		to_chat(user, SPAN_DANGER("How do you expect to refill your magazine whilst the packet is sealed shut? Open it first!"))
		return
	if(burning)
		to_chat(user, SPAN_DANGER("It's on fire and might explode!"))
		return
	if(istype(I, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/AM = I
		if(!isturf(loc))
			to_chat(user, SPAN_WARNING("You need to put the packet down first!"))
			return
		if(AM.default_ammo != default_ammo)
			to_chat(user, SPAN_WARNING("That's the wrong caliber!"))
			return
		if(AM.current_rounds >= AM.max_rounds)
			to_chat(user, SPAN_WARNING("[AM] is already full!"))
			return
		if(bullet_amount <= 0)
			to_chat(user, SPAN_WARNING("The packet is empty!"))
			return
		var/amount_to_transfer = min(bullet_amount, AM.max_rounds - AM.current_rounds)
		bullet_amount -= amount_to_transfer
		AM.current_rounds += amount_to_transfer
		to_chat(user, SPAN_NOTICE("You refill [AM] with [amount_to_transfer] rounds from [src]."))
		playsound(loc, 'sound/weapons/gun_rifle_reload.ogg', 25, TRUE, 3)
		if(bullet_amount <= 0)
			unfold_box(user)
		update_icon()
		return
	..()

/obj/item/ammo_box/rounds/unsc/get_examine_text(mob/user)
	. = ..()
	if(opened)
		. += SPAN_INFO("It has [bullet_amount] round\s left.")
	else
		. += SPAN_INFO("It is still sealed.")

//---------------------AMMO TYPES

/obj/item/ammo_box/rounds/unsc/ma5
	name = "\improper M118 (7.62x51mm) ammunition packet"
	desc = "A tear-open packet of 7.62x51mm ammunition for MA5 series rifles. Contains 120 rounds."
	default_ammo = /datum/ammo/bullet/rifle/ma5
	bullet_amount = 120
	max_bullet_amount = 120
	caliber = "7.62x51"

/obj/item/ammo_box/rounds/unsc/ma5/empty
	empty = TRUE

/obj/item/ammo_box/rounds/unsc/m7
	name = "\improper M443 (5x23mm) ammunition packet"
	desc = "A tear-open packet of 5x23mm caseless ammunition for M7 SMGs. Contains 180 rounds."
	default_ammo = /datum/ammo/bullet/smg/halo/m7
	bullet_amount = 180
	max_bullet_amount = 180
	caliber = "5x23mm caseless"

/obj/item/ammo_box/rounds/unsc/m7/empty
	empty = TRUE

/obj/item/ammo_box/rounds/unsc/m6
	name = "\improper M225 (12.7x40mm) ammunition packet"
	desc = "A tear-open packet of 12.7x40mm ammunition for M6 series handguns. Contains 72 rounds."
	default_ammo = /datum/ammo/bullet/pistol/halo/m6
	bullet_amount = 72
	max_bullet_amount = 72
	caliber = "12.7x40mm"

/obj/item/ammo_box/rounds/unsc/m6/empty
	empty = TRUE

/obj/item/ammo_box/rounds/unsc/br55
	name = "\improper M634 (9.5x40mm) ammunition packet"
	desc = "A tear-open packet of 9.5x40mm ammunition for BR55 battle rifles. Contains 108 rounds."
	default_ammo = /datum/ammo/bullet/rifle/br55
	bullet_amount = 108
	max_bullet_amount = 108
	caliber = "9.5x40mm"

/obj/item/ammo_box/rounds/unsc/br55/empty
	empty = TRUE
