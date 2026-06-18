// SMGs

/obj/item/weapon/gun/smg/halo
	name = "halo smg holder"
	icon = 'modular/halo/icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_weapons.dmi'
	icon_state = null
	base_gun_icon = "p90"
	item_icons = list(
		WEAR_BACK = 'modular/halo/icons/halo/mob/humans/onmob/clothing/back/guns_by_type/smgs_32.dmi',
		WEAR_J_STORE = 'modular/halo/icons/halo/mob/humans/onmob/clothing/suit_storage/suit_storage_by_faction/suit_slot_unsc.dmi',
		WEAR_L_HAND = 'modular/halo/icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'modular/halo/icons/halo/mob/humans/onmob/items_righthand_halo.dmi',
		WEAR_WAIST = 'modular/halo/icons/halo/mob/humans/onmob/clothing/suit_storage/suit_storage_by_faction/suit_slot_unsc.dmi'
	)

/obj/item/weapon/gun/smg/halo/m7
	name = "M7 submachine gun"
	desc = "Компактный пистолет-пулемёт под безгильзовый патрон 5 мм. Складной приклад, складывающаяся рукоять и приличная останавливающая способность сделали M7 своим в абордаже, охране и спецоперациях."
	icon_state = "m7"
	item_state = "m7"
	caliber = "5x23mm"
	mouse_pointer = 'modular/halo/icons/halo/effects/mouse_pointer/ma5b.dmi'

	fire_sound = "gun_m7"
	fire_rattle = "gun_m7"
	reload_sound = 'modular/halo/sound/weapons/gun_m7_reload.ogg'
	cocked_sound = 'modular/halo/sound/weapons/gun_m7_cocked.ogg'
	unload_sound = 'modular/halo/sound/weapons/gun_m7_unload.ogg'
	empty_sound = null
	w_class = SIZE_LARGE

	flags_gun_features = GUN_CAN_POINTBLANK
	start_automatic = TRUE
	map_specific_decoration = FALSE
	current_mag = /obj/item/ammo_magazine/smg/halo/m7
	starting_attachment_types = list(/obj/item/attachable/stock/m7, /obj/item/attachable/stock/m7/grip/folded_down)
	attachable_allowed = list(
		/obj/item/attachable/stock/m7,
		/obj/item/attachable/stock/m7/grip,
		/obj/item/attachable/flashlight/m7,
		/obj/item/attachable/reddot/m7,
		/obj/item/attachable/suppressor/m7,
	)

/obj/item/weapon/gun/smg/halo/m7/folded_up
	starting_attachment_types = list(/obj/item/attachable/stock/m7, /obj/item/attachable/stock/m7/grip)

/obj/item/weapon/gun/smg/halo/m7/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 15,"rail_x" = 16, "rail_y" = 16, "under_x" = 30, "under_y" = 15, "stock_x" = 13, "stock_y" = 14, "special_x" = 17, "special_y" = 16)

/obj/item/weapon/gun/smg/halo/m7/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_12)
	set_burst_delay(FIRE_DELAY_TIER_12)
	set_burst_amount(BURST_AMOUNT_TIER_3)
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_8
	burst_scatter_mult = SCATTER_AMOUNT_TIER_9
	scatter_unwielded = SCATTER_AMOUNT_TIER_8
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_2
	fa_scatter_peak = 40
	fa_max_scatter = 3

/obj/item/weapon/gun/smg/halo/m7/socom
	name = "M7S submachine gun"
	starting_attachment_types = list(
		/obj/item/attachable/stock/m7,
		/obj/item/attachable/stock/m7/grip/folded_down,
		/obj/item/attachable/flashlight/m7,
		/obj/item/attachable/reddot/m7,
		/obj/item/attachable/suppressor/m7,
	)

/obj/item/weapon/gun/smg/halo/m7/socom/folded_up
	starting_attachment_types = list(
		/obj/item/attachable/stock/m7,
		/obj/item/attachable/stock/m7/grip,
		/obj/item/attachable/flashlight/m7,
		/obj/item/attachable/reddot/m7,
		/obj/item/attachable/suppressor/m7,
	)
