// smg magazines
/obj/item/ammo_magazine/smg/halo
	name = "halo smg magazine"
	icon = 'modular/halo/icons/halo/obj/items/weapons/guns_by_faction/unsc/unsc_magazines.dmi'
	icon_state = null
	ammo_band_icon = null
	ammo_band_icon_empty = null

/obj/item/ammo_magazine/smg/halo/m7
	name = "\improper M7 magazine (5×23mm M443 Caseless FMJ)"
	desc = "Прямоугольный магазин, вставляемый сбоку в пистолет-пулемёт M7. Вмещает 60 патронов 5×23 мм M443 Caseless FMJ."
	icon_state = "m7"
	max_rounds = 60
	gun_type = /obj/item/weapon/gun/smg/halo/
	default_ammo = /datum/ammo/bullet/smg/m7
	caliber = "5x23mm"
