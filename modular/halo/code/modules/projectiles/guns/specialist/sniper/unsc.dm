// snipers

/obj/item/weapon/gun/rifle/sniper/halo
	name = "SRS99-AM sniper rifle"
	desc = "Новая штатная снайперская винтовка ККОН. Использует магазин на 4 патрона 14.5x114 мм APFSDS и показывает выдающиеся результаты на предельных дистанциях. Её характерная особенность - заметная модульность, особенно в районе ствола, который можно быстро заменить целиком."
	icon = 'modular/halo/icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_weapons.dmi'
	icon_state = "srs99"
	base_gun_icon = "m42a"
	item_state = "srs99"
	caliber = "14.5x114mm"
	mouse_pointer = 'modular/halo/icons/halo/effects/mouse_pointer/srs99.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	worn_x_dimension = 64
	worn_y_dimension = 64
	item_icons = list(
		WEAR_BACK = 'modular/halo/icons/halo/mob/humans/onmob/clothing/back/guns_by_type/marksman_rifles_64.dmi',
		WEAR_L_HAND = 'modular/halo/icons/halo/mob/humans/onmob/items_lefthand_halo_64.dmi',
		WEAR_R_HAND = 'modular/halo/icons/halo/mob/humans/onmob/items_righthand_halo_64.dmi'
	)

	fire_sound = "gun_srs99"
	reload_sound = 'modular/halo/sound/weapons/gun_srs99_reload.ogg'
	cocked_sound = 'modular/halo/sound/weapons/gun_srs99_cocked.ogg'
	unload_sound = 'modular/halo/sound/weapons/gun_srs99_unload.ogg'
	empty_sound = null

	current_mag = /obj/item/ammo_magazine/rifle/halo/sniper
	force = 12
	wield_delay = WIELD_DELAY_HORRIBLE
	flags_equip_slot = SLOT_BLOCK_SUIT_STORE|SLOT_BACK
	zoomdevicename = "scope"
	attachable_allowed = list(/obj/item/attachable/srs_assembly, /obj/item/attachable/scope/variable_zoom/oracle, /obj/item/attachable/srs_barrel, /obj/item/attachable/bipod/srs_bipod)
	starting_attachment_types = list(/obj/item/attachable/scope/variable_zoom/oracle, /obj/item/attachable/srs_barrel, /obj/item/attachable/bipod/srs_bipod)
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	map_specific_decoration = FALSE
	skill_locked = FALSE
	flags_item = TWOHANDED
	indestructible = TRUE
	var/can_change_barrel = TRUE

/obj/item/weapon/gun/rifle/sniper/halo/verb/toggle_scope_zoom_level()
	set name = "Toggle Scope Zoom Level"
	set category = "Weapons"
	set src in usr
	var/obj/item/attachable/scope/variable_zoom/S = attachments["rail"]
	S.toggle_zoom_level()

/obj/item/weapon/gun/rifle/sniper/halo/handle_starting_attachment()
	..()
	var/obj/item/attachable/srs_assembly/S = new(src)
	S.flags_attach_features &= ~ATTACH_REMOVABLE
	S.Attach(src)
	update_attachable(S.slot)

/obj/item/weapon/gun/rifle/sniper/halo/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 38, "muzzle_y" = 21,"rail_x" = 21, "rail_y" = 24, "under_x" = 32, "under_y" = 14, "special_x" = 48, "special_y" = 17)


/obj/item/weapon/gun/rifle/sniper/halo/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_SNIPER)
	set_burst_amount(BURST_AMOUNT_TIER_1)
	accuracy_mult = BASE_ACCURACY_MULT * 3 //you HAVE to be able to hit
	scatter = SCATTER_AMOUNT_TIER_3
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_5

/obj/item/weapon/gun/rifle/sniper/halo/unloaded
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_TRIGGER_SAFETY
	current_mag = null

/obj/item/weapon/mateba_key/halo_sniper
	name = "SRS99 barrel key"
	desc = "Ключ для ствола SRS99, которым отпирают механизм и снимают ствол."

/obj/item/weapon/gun/rifle/sniper/halo/attackby(obj/item/subject, mob/user)
	if(istype(subject, /obj/item/weapon/mateba_key/halo_sniper) && can_change_barrel)
		var/obj/item/attachable/attachment = attachments["muzzle"]
		if(attachment)
			visible_message(SPAN_NOTICE("[user] begins stripping [attachment] from [src]."),
			SPAN_NOTICE("You begin stripping [attachment] from [src]."), null, 4)

			if(!do_after(usr, 35, INTERRUPT_ALL, BUSY_ICON_FRIENDLY))
				return

			if(!(attachment == attachments[attachment.slot]))
				return

			visible_message(SPAN_NOTICE("[user] unlocks and removes [attachment] from [src]."),
			SPAN_NOTICE("You unlocks removes [attachment] from [src]."), null, 4)
			attachment.Detach(user, src)
			playsound(src, 'sound/handling/attachment_remove.ogg', 15, 1, 4)
			update_icon()
	. = ..()

/obj/item/weapon/gun/rifle/sniper/halo/able_to_fire(mob/living/user)
	if(!attachments["muzzle"])
		to_chat(user, SPAN_WARNING("You can't fire the [src] without a barrel!"))
		return
	. = ..()
