// shotgun internal magazines

/obj/item/ammo_magazine/internal/shotgun/m90
	caliber = "8g"
	max_rounds = 12
	current_rounds = 12
	default_ammo = /datum/ammo/bullet/shotgun/buckshot/unsc

/obj/item/ammo_magazine/internal/shotgun/m90/unloaded
	current_rounds = 0

/obj/item/ammo_magazine/internal/shotgun/m90/police
	default_ammo = /datum/ammo/bullet/shotgun/beanbag/unsc

// shotgun shells

/obj/item/ammo_magazine/handful/shotgun/buckshot_unsc
	name = "handful of MAG 15P-00B (8g)"
	icon = 'modular/halo/icons/obj/items/weapons/guns/handful.dmi'
	icon_state = "8g_shell_6"
	handful_state = "8g_shell"
	caliber = "8g"
	default_ammo = /datum/ammo/bullet/shotgun/buckshot/unsc
	max_rounds = 6
	current_rounds = 6
	transfer_handful_amount = 6

/obj/item/ammo_magazine/shotgun/buckshot/unsc
	name = "UNSC 8-gauge shotgun shell box"
	desc = "Коробка, заполненная дробовыми патронами MAG 15P-00B 8-го калибра."
	icon = 'modular/halo/icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_magazines.dmi'
	icon_state = "8g"
	default_ammo = /datum/ammo/bullet/shotgun/buckshot/unsc
	transfer_handful_amount = 6
	max_rounds = 24
	caliber = "8g"

/obj/item/ammo_magazine/handful/shotgun/slug_unsc
	name = "handful of MAG 15P-SL (8g)"
	icon = 'modular/halo/icons/obj/items/weapons/guns/handful.dmi'
	icon_state = "8g_slug_6"
	handful_state = "8g_slug"
	caliber = "8g"
	default_ammo = /datum/ammo/bullet/shotgun/slug/unsc
	max_rounds = 6
	current_rounds = 6
	transfer_handful_amount = 6

/obj/item/ammo_magazine/shotgun/slug/unsc
	name = "UNSC 8-gauge shotgun slug box"
	desc = "Коробка, заполненная пулевыми патронами MAG 15P-SL 8-го калибра."
	icon = 'modular/halo/icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_magazines.dmi'
	icon_state = "8g_slug"
	default_ammo = /datum/ammo/bullet/shotgun/slug/unsc
	transfer_handful_amount = 6
	max_rounds = 24
	caliber = "8g"

/obj/item/ammo_magazine/shotgun/beanbag/unsc
	name = "UNSC 8-gauge shotgun beanbag box"
	desc = "Коробка, заполненная травматическими патронами MAG LLHB 8-го калибра."
	icon = 'modular/halo/icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_magazines.dmi'
	icon_state = "8g_beanbag"
	default_ammo = /datum/ammo/bullet/shotgun/beanbag/unsc
	transfer_handful_amount = 6
	max_rounds = 24
	caliber = "8g"

// shotgun shell handfuls

/obj/item/ammo_magazine/handful/shotgun/halo
	name = "handful of MAG 15P-00B shotgun shells"
	icon = 'modular/halo/icons/obj/items/weapons/guns/handful.dmi'
	icon_state = "8g_shell_6"
	default_ammo = /datum/ammo/bullet/shotgun/buckshot/unsc
	caliber = "8g"
	max_rounds = 6
	current_rounds = 6
	gun_type = /obj/item/weapon/gun/shotgun/pump/halo
	handful_state = "8g_shell"
	transfer_handful_amount = 6
	flags_human_ai = AMMUNITION_ITEM

/obj/item/ammo_magazine/handful/shotgun/halo/beanbag
	name = "handful of MAG LLHB shotgun shells"
	icon_state = "8g_beanbag_6"
	default_ammo = /datum/ammo/bullet/shotgun/beanbag/unsc
	handful_state = "8g_beanbag"
