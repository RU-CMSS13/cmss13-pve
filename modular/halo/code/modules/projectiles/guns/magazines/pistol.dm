// pistol magazines

/obj/item/ammo_magazine/pistol/halo
	name = "halo magazine"
	icon = 'modular/halo/icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_magazines.dmi'
	icon_state = null
	ammo_band_icon = null
	ammo_band_icon_empty = null
	caliber = "12.7x40mm"

/obj/item/ammo_magazine/pistol/halo/m6c
	name = "\improper M6C magazine (12.7x40mm SAP-HE)"
	desc = "Наклонный прямоугольный магазин для M6C на 12 патронов 12.7x40 мм SAP-HE."
	icon_state = "m6c"
	gun_type = /obj/item/weapon/gun/pistol/halo/m6c
	default_ammo = /datum/ammo/bullet/pistol/magnum
	max_rounds = 12
	bonus_overlay = "m6c_overlay"

/obj/item/ammo_magazine/pistol/halo/m6c/socom
	name = "\improper M6C/SOCOM magazine (12.7x40mm SAP-HE)"
	desc = "Увеличенный магазин для M6C, вмещающий 16 патронов вместо стандартных 12. Выполнен в спецоперативном чёрном цвете - для настоящего скрытного оперативника."
	max_rounds = 16
	icon_state = "m6c_socom"
	bonus_overlay = "m6c_ext_overlay"

/obj/item/ammo_magazine/pistol/halo/m6a
	name = "\improper M6A magazine (12.7x40mm SAP-HE)"
	desc = "Наклонный прямоугольный магазин для M6A на 12 патронов 12.7x40 мм SAP-HE."
	icon_state = "m6c"
	gun_type = /obj/item/weapon/gun/pistol/halo/m6a
	default_ammo = /datum/ammo/bullet/pistol/magnum
	max_rounds = 12

/obj/item/ammo_magazine/pistol/halo/m6g
	name = "\improper M6G magazine (12.7x40mm SAP-HE)"
	desc = "Наклонный прямоугольный магазин для M6G на 8 патронов 12.7x40 мм SAP-HE."
	icon_state = "m6g"
	gun_type = /obj/item/weapon/gun/pistol/halo/m6g
	default_ammo = /datum/ammo/bullet/pistol/magnum
	max_rounds = 8

/obj/item/ammo_magazine/pistol/halo/m6d
	name = "\improper M6D magazine (12.7x40mm SAP-HE)"
	desc = "Наклонный прямоугольный магазин для M6D на 12 патронов 12.7x40 мм SAP-HE. Хромированная отделка."
	icon_state = "m6d"
	gun_type = /obj/item/weapon/gun/pistol/halo/m6d
	default_ammo = /datum/ammo/bullet/pistol/magnum
	max_rounds = 12
