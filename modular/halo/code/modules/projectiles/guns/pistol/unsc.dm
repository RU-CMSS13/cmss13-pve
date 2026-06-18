// Pistols

/obj/item/weapon/gun/pistol/halo
	name = "Halo pistol holder"
	icon = 'modular/halo/icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_weapons.dmi'
	icon_state = null
	base_gun_icon = "smartpistol"
	item_icons = list(
		WEAR_BACK = 'modular/halo/icons/halo/mob/humans/onmob/clothing/back/guns_by_type/pistols_32.dmi',
		WEAR_J_STORE = 'modular/halo/icons/halo/mob/humans/onmob/clothing/suit_storage/suit_storage_by_faction/suit_slot_unsc.dmi',
		WEAR_L_HAND = 'modular/halo/icons/halo/mob/humans/onmob/items_lefthand_halo.dmi',
		WEAR_R_HAND = 'modular/halo/icons/halo/mob/humans/onmob/items_righthand_halo.dmi'
	)
	mouse_pointer = 'modular/halo/icons/halo/effects/mouse_pointer/magnum.dmi'
	reload_sound = 'modular/halo/sound/weapons/gun_magnum_reload.ogg'
	unload_sound = 'modular/halo/sound/weapons/gun_magnum_unload.ogg'
	cocked_sound = 'modular/halo/sound/weapons/gun_magnum_cocked.ogg'
	drop_sound = 'modular/halo/sound/items/drop_lightweapon.ogg'
	pickup_sound = 'modular/halo/sound/items/grab_lightweapon.ogg'
	flags_gun_features = GUN_AUTO_EJECT_CASINGS|GUN_CAN_POINTBLANK
	empty_sound = null

/obj/item/weapon/gun/pistol/halo/m6c
	name = "M6C service magnum"
	desc = "Полуавтоматический пистолет под 12.7x40 мм с коротким ходом ствола. Подача и рукоять здесь переработаны в попытке исправить поломки и проблемы надёжности. Его укороченный профиль удобен в тесноте, но неполное сгорание пороха заметно режет ожидаемые характеристики."
	icon_state = "m6c"
	item_state = "m6"
	caliber = "12.7x40mm"
	current_mag = /obj/item/ammo_magazine/pistol/halo/m6c
	attachable_allowed = list(/obj/item/attachable/scope/mini/smartscope/m6c, /obj/item/attachable/flashlight/m6)
	fire_sound = "gun_m6c"
	flags_gun_features = GUN_AUTO_EJECT_CASINGS|GUN_CAN_POINTBLANK

/obj/item/weapon/gun/pistol/halo/m6c/unloaded
	current_mag = null

/obj/item/weapon/gun/pistol/halo/m6c/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 21,"rail_x" = 16, "rail_y" = 16, "under_x" = 16, "under_y" = 16, "stock_x" = 18, "stock_y" = 15)

/obj/item/weapon/gun/pistol/halo/m6c/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_12)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_2
	scatter = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_5
	damage_mult = BASE_BULLET_DAMAGE_MULT

/obj/item/weapon/gun/pistol/halo/m6c/socom
	name = "M6C/SOCOM \"Automag\" pistol"
	desc = "Модифицированный Special Operations Command вариант M6C, известный как M6C/SOCOM. Этот пистолет получил целый набор тонких доработок для улучшения боевой эффективности, а заодно и более эффектную окраску."
	icon_state = "m6c_socom"
	current_mag = /obj/item/ammo_magazine/pistol/halo/m6c/socom
	attachable_allowed = list(/obj/item/attachable/flashlight/m6c_socom, /obj/item/attachable/suppressor/m6c_socom)
	starting_attachment_types = list(/obj/item/attachable/flashlight/m6c_socom, /obj/item/attachable/suppressor/m6c_socom)

/obj/item/weapon/gun/pistol/halo/m6c/socom/unloaded
	current_mag = null

/obj/item/weapon/gun/pistol/halo/m6c/socom/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_12)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_2
	scatter = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_5
	damage_mult = BASE_BULLET_DAMAGE_MULT

/obj/item/weapon/gun/pistol/halo/m6c/socom/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 19, "muzzle_y" = 15,"rail_x" = 16, "rail_y" = 16, "under_x" = 19, "under_y" = 16, "stock_x" = 0, "stock_y" = 0)

/obj/item/weapon/gun/pistol/halo/m6c/m4a
	name = "M4A pistol"
	desc = "Винтажный пистолет под 12.7x40 мм, популярный у гражданских и преступников. Предшественник более известной серии M6 был официально заменён ещё в 2414 году. Жалобы на него всегда были одни и те же: слабая точность, ослепляющая грязная вспышка и оглушительный выстрел. Именно это и подарило ему вторую жизнь у новой публики."
	icon_state = "m4a"
	current_mag = /obj/item/ammo_magazine/pistol/halo/m6c
	attachable_allowed = list(/obj/item/attachable/flashlight/m6)
	fire_sound = "gun_m6c"

/obj/item/weapon/gun/pistol/halo/m6c/m4a/unloaded
	current_mag = null

/obj/item/weapon/gun/pistol/halo/m6c/m4a/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 21,"rail_x" = 16, "rail_y" = 16, "under_x" = 16, "under_y" = 16, "stock_x" = 18, "stock_y" = 15)

/obj/item/weapon/gun/pistol/halo/m6c/m4a/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_8)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_2
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_5
	damage_mult = BASE_BULLET_DAMAGE_MULT - BULLET_DAMAGE_MULT_TIER_1

/obj/item/weapon/gun/pistol/halo/m6g
	name = "M6G service magnum"
	desc = "За счёт более длинного ствола и полигональных нарезов M6G точнее и быстрее своих предшественников. Вместимость при этом сократили до 8 патронов ради уменьшения оружия и боезапаса, но ценой потери обратной совместимости."
	icon_state = "m6g"
	item_state = "m6"
	caliber = "12.7x40mm"
	current_mag = /obj/item/ammo_magazine/pistol/halo/m6g
	attachable_allowed = list(/obj/item/attachable/scope/mini/smartscope/m6g, /obj/item/attachable/flashlight/m6)
	fire_sound = "gun_m6g"

/obj/item/weapon/gun/pistol/halo/m6g/unloaded
	current_mag = null

/obj/item/weapon/gun/pistol/halo/m6g/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 21,"rail_x" = 16, "rail_y" = 16, "under_x" = 16, "under_y" = 16, "stock_x" = 18, "stock_y" = 15)

/obj/item/weapon/gun/pistol/halo/m6g/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_9)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_8
	scatter_unwielded = SCATTER_AMOUNT_TIER_6
	damage_mult = BASE_BULLET_DAMAGE_MULT + BULLET_DAMAGE_MULT_TIER_4
	velocity_add = AMMO_SPEED_TIER_1

/obj/item/weapon/gun/pistol/halo/m6d
	name = "M6D service magnum"
	desc = "Вариант D заслужил репутацию мощного и точного пистолета. Для части стрелков встроенный малократный смарт-прицел KFA-2 делает его в плотной городской застройке чуть ли не заменой снайперской винтовке. Но у блеска есть цена: многие считают, что добавленный объём делает оружие слишком неповоротливым."
	desc_lore = null
	icon_state = "m6d"
	item_state = "m6"
	caliber = "12.7x40mm"
	current_mag = /obj/item/ammo_magazine/pistol/halo/m6d
	attachable_allowed = list(/obj/item/attachable/scope/variable_zoom/m6d, /obj/item/attachable/flashlight/m6)
	fire_sound = "gun_m6d"
	unload_sound = 'modular/halo/sound/weapons/m6d/gun_m6d_unload.ogg'
	reload_sound = 'modular/halo/sound/weapons/m6d/gun_m6d_reload.ogg'
	cocked_sound = 'modular/halo/sound/weapons/m6d/gun_m6d_cock.ogg'
	empty_click = 'modular/halo/sound/weapons/m6d/gun_m6d_dryfire.ogg'

/obj/item/weapon/gun/pistol/halo/m6d/unloaded
	current_mag = null

/obj/item/weapon/gun/pistol/halo/m6d/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 21,"rail_x" = 16, "rail_y" = 16, "under_x" = 16, "under_y" = 16, "stock_x" = 18, "stock_y" = 15)

/obj/item/weapon/gun/pistol/halo/m6d/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_9)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_6
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_6
	scatter = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_9
	damage_mult = BASE_BULLET_DAMAGE_MULT * 2
	velocity_add = AMMO_SPEED_TIER_2

/obj/item/weapon/gun/pistol/halo/m6d/handle_starting_attachment()
	..()
	var/obj/item/attachable/scope/variable_zoom/m6d/scope = new(src)
	scope.flags_attach_features &= ~ATTACH_REMOVABLE
	scope.Attach(src)
	scope.hidden = TRUE
	update_attachable(scope.slot)

/obj/item/weapon/gun/pistol/halo/m6a
	name = "M6A service magnum"
	desc = "Снятый с производства представитель семейства M6. Только вариант A получил узел поглощения отдачи, но проблемы с потерей скорости и точности так и остались до самой замены. Теперь его чаще можно встретить у охраны и правоохранителей как более компактное и удобное оружие постоянного ношения."
	icon_state = "m6a"
	item_state = "m6"
	caliber = "12.7x40mm"
	current_mag = /obj/item/ammo_magazine/pistol/halo/m6a
	attachable_allowed = list(/obj/item/attachable/flashlight/m6)
	fire_sound = "gun_m6c"

/obj/item/weapon/gun/pistol/halo/m6a/unloaded
	current_mag = null

/obj/item/weapon/gun/pistol/halo/m6a/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 21,"rail_x" = 16, "rail_y" = 16, "under_x" = 16, "under_y" = 16, "stock_x" = 18, "stock_y" = 15)


/obj/item/weapon/gun/pistol/halo/m6a/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_9)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_2
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_3
	scatter = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_5
	damage_mult =  BASE_BULLET_DAMAGE_MULT - BULLET_DAMAGE_MULT_TIER_4
