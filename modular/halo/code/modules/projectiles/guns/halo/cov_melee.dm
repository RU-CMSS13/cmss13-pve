/obj/item/weapon/covenant
	name = "Covenant weapon holder"
	desc = "Вы не должны это видеть. Если всё же видите, сообщите сопровождающему проекта."
	icon = 'modular/halo/icons/halo/obj/items/weapons/melee_by_faction/covenant/covenant_melee.dmi'
	embeddable = FALSE
	var/mouse_pointer = 'modular/halo/icons/halo/effects/mouse_pointer/energy_sword.dmi'
	item_icons = list(
		WEAR_J_STORE = 'modular/halo/icons/halo/mob/humans/onmob/clothing/suit_storage/suit_storage_by_faction/suit_slot_cov.dmi',
		WEAR_L_HAND = 'modular/halo/icons/halo/mob/humans/onmob/items_lefthand_halo_64.dmi',
		WEAR_R_HAND = 'modular/halo/icons/halo/mob/humans/onmob/items_righthand_halo_64.dmi'
	)

/obj/item/weapon/covenant/proc/update_mouse_pointer(mob/user, new_cursor)
	if(!user.client?.prefs.custom_cursors)
		return

	user.client.mouse_pointer_icon = new_cursor ? mouse_pointer : initial(user.client.mouse_pointer_icon)


/obj/item/weapon/covenant/pickup(user, silent)
	. = ..()
	update_mouse_pointer(user, TRUE)

/obj/item/weapon/covenant/dropped(user)
	. = ..()
	update_mouse_pointer(user, FALSE)

/obj/item/weapon/covenant/on_enter_storage(S)
	if(ishuman(loc))
		var/mob/living/carbon/human/user = loc
		update_mouse_pointer(user, FALSE)
	. = ..()

/obj/item/weapon/covenant/equipped(user, slot, silent)
	if(slot == WEAR_L_HAND| slot == WEAR_R_HAND)
		update_mouse_pointer(user, TRUE)
	else
		update_mouse_pointer(user, FALSE)
	. = ..()

/obj/item/weapon/covenant/Destroy()
	. = ..()
	if(ishuman(loc))
		var/mob/living/carbon/human/user = loc
		update_mouse_pointer(user, TRUE)

/obj/item/weapon/covenant/energy_sword
	name = "energy sword"
	desc = null
	icon_state = "energy_sword"
	item_state = "energy_sword"
	w_class = SIZE_MEDIUM
	damtype = BRUTE
	force = MELEE_FORCE_TIER_2
	attack_speed = 1 SECONDS
	attack_verb = list("ударил", "огрел")
	sharp = FALSE
	edge = FALSE
	flags_atom = NOBLOODY|FPRINT|QUICK_DRAWABLE
	flags_equip_slot = SLOT_STORE|SLOT_SUIT_STORE
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	// new vars
	var/activated
	var/activated_force = MELEE_FORCE_TIER_11
	/// Sound to set hitsound to when activated
	var/activated_hitsound = "energy_sword"
	/// If set to true, the energy sword will disable itself permanently when dropped on the floor. Used mostly for npc swords.
	var/self_destructs = FALSE
	/// Whether or not the energy sword is nonfunctional
	var/nonfunctional = FALSE
	// sounds
	drop_sound = 'modular/halo/sound/items/drop_lightweapon.ogg'
	hitsound = "swing_hit"
	var/on_sound = 'modular/halo/sound/weapons/energy_sword/energy_sword_on.ogg'
	var/off_sound = 'modular/halo/sound/weapons/energy_sword/energy_sword_off.ogg'
	var/break_sound = 'modular/halo/sound/weapons/energy_sword/energy_sword_disabled.ogg'
	// light stuff
	light_color = "#7b92df"
	light_power = 0.3
	light_range = 4

/obj/item/weapon/covenant/energy_sword/attack_self(mob/user)
	. = ..()
	toggle_activation(user)

/obj/item/weapon/covenant/energy_sword/proc/refresh_holder_hand_overlays(mob/living/carbon/human/user)
	var/mob/living/carbon/human/human_holder = user
	if(!human_holder && ishuman(loc))
		human_holder = loc
	if(!human_holder)
		return
	if(human_holder.l_hand == src)
		human_holder.update_inv_l_hand()
	if(human_holder.r_hand == src)
		human_holder.update_inv_r_hand()

/obj/item/weapon/covenant/energy_sword/proc/set_activation_state(should_activate, mob/living/carbon/human/user)
	if(should_activate)
		if(nonfunctional)
			if(issangheili(user) && user)
				to_chat(user, SPAN_NOTICE("The self destruct mechanism built into \the [src] has damaged this weapon beyond all repair."))
			else if(user)
				to_chat(user, SPAN_NOTICE("You fiddle with \the [src] for a moment, but it doesn't do anything. Seems like it's fried."))
			return FALSE
		if(activated)
			return TRUE
		if(user && issangheili(user))
			user.visible_message(SPAN_DANGER("[user] expertly activates the [src], flicking their wrist as the hot plasma slides out of the hilt!"), SPAN_NOTICE("You activate your [src] with ease!"))
		w_class = SIZE_HUGE
		force = activated_force
		attack_verb = list("sliced", "slashed")
		sharp = IS_SHARP_ITEM_ACCURATE
		edge = TRUE
		flags_equip_slot = null
		icon_state = "[initial(icon_state)]_activated"
		item_state = "[initial(item_state)]_activated"
		hitsound = activated_hitsound
		playsound(src, on_sound, 30)
		activated = TRUE
		set_light_on(TRUE)
		refresh_holder_hand_overlays(user)
		return TRUE

	if(!activated)
		return TRUE

	w_class = SIZE_MEDIUM
	force = MELEE_FORCE_TIER_2
	flags_equip_slot = SLOT_STORE|SLOT_SUIT_STORE
	attack_verb = list("whacked", "hit")
	sharp = FALSE
	edge = FALSE
	icon_state = "[initial(icon_state)]"
	item_state = "[initial(item_state)]"
	hitsound = initial(hitsound)
	playsound(src, off_sound, 30)
	activated = FALSE
	set_light_on(FALSE)
	refresh_holder_hand_overlays(user)
	return TRUE

/obj/item/weapon/covenant/energy_sword/proc/toggle_activation(mob/living/carbon/human/user)
	if(nonfunctional)
		if(issangheili(user) && user)
			to_chat(user, SPAN_NOTICE("The self destruct mechanism built into \the [src] has damaged this weapon beyond all repair."))
		else
			to_chat(user, SPAN_NOTICE("You fiddle with \the [src] for a moment, but it doesn't do anything. Seems like it's fried."))
		return
	if(!activated)
		if(!issangheili(user) && user)
			user.visible_message(SPAN_DANGER("[user] begins to fiddle with the [src] in their hands, attempting to activate it..."), SPAN_NOTICE("You start messing with \the [src], attempting to activate it..."))
			if(!do_after(user, rand(2, 4) SECONDS, INTERRUPT_ALL, BUSY_ICON_GENERIC))
				user.visible_message(SPAN_NOTICE("[user] seems to give up attempting to activate \the [src]..."), SPAN_NOTICE("You give up attempting to activate \the [src]..."))
				return
			if(prob(50))
				user.visible_message(SPAN_DANGER("[user] manages to safely activate \the [src]."), SPAN_NOTICE("You manage to activate \the [src]...safely."))
			else
				user.visible_message(SPAN_DANGER("[user] fails to safely activate \the [src], burning themselves with hot plasma in the process!"), SPAN_NOTICE("You fail to activate \the [src] safely, scorching yourself with hot plasma in the process! IT BURNS!!!"))
				user.apply_armoured_damage(activated_force/2, ARMOR_LASER, BURN, penetration = 25)
				user.apply_armoured_damage(activated_force/2, ARMOR_MELEE, BRUTE, penetration = 25)
		return set_activation_state(TRUE, user)

	return set_activation_state(FALSE, user)

/obj/item/weapon/covenant/energy_sword/dropped()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(check_for_floor)), 0.1 SECONDS)

/obj/item/weapon/covenant/energy_sword/proc/check_for_floor()
	if(istype(loc, /turf))
		if(nonfunctional)
			return
		if(self_destructs)
			balloon_alert_to_viewers("\The [src] sizzles and pops as it hits the ground!")
			nonfunctional = TRUE
			icon_state = "[initial(icon_state)]_broken"
			if(activated)
				set_activation_state(FALSE)
			playsound(src, break_sound, 50)
			name = "nonfunctional [initial(name)]"
		else
			if(activated)
				set_activation_state(FALSE)

/obj/item/weapon/covenant/energy_sword/self_destructing
	self_destructs = TRUE

/obj/item/weapon/covenant/energy_sword/self_destructing/gigadeath_prop
	activated_force = 200

/obj/item/weapon/covenant/energy_sword/self_destructing/gigadeath_prop/attack(mob/living/target, mob/living/user)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(user)
			var/obj/limb/targeted_limb = human_target.get_limb(user.zone_selected)
			if(user.zone_selected == "chest" || user.zone_selected == "groin" )
				return
			targeted_limb.droplimb(FALSE, FALSE, "dismemberment")

/obj/item/weapon/covenant/energy_sword/get_examine_text(mob/living/carbon/human/user)
	. = ..()
	var/list/origin = .
	var/insert_line
	if(isunggoy(user) || issangheili(user))
		origin[1] = "[icon2html(src, user)] Это энергетический меч образца Pelosus"
		insert_line = "Стандартный энергетический меч, выдаваемый воинам сангхейли, достигшим либо выдающихся успехов на поле боя, либо достаточного ранга. Массово производимый и в целом одноразовый инструмент, использующий сравнительно примитивную технологию для создания клинка, способного прорезать почти любую защиту."
	else
		origin[1] = "[icon2html(src, user)] Энергетический меч Тип-1"
		insert_line = "Высокоточное устройство, удерживающее стабильную высокоэнергетическую плазму в магнитном поле. Почти исключительно используется элитами и способно разрушить практически любую броню или материал, с которыми соприкасается. Лучше не позволяйте этой штуке вас задеть."
	origin.Insert(2, insert_line)


/obj/item/weapon/twohanded/covenant
	name = "Covenant weapon holder"
	desc = "Вы не должны это видеть. Если всё же видите, сообщите сопровождающему проекта."
	icon = 'modular/halo/icons/halo/obj/items/weapons/melee_by_faction/covenant/covenant_melee.dmi'
	embeddable = FALSE
