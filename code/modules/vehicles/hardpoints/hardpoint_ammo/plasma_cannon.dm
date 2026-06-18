// SS220 EDIT - START: PR #1266 D66-44 — translated name/desc to Russian
/obj/item/ammo_magazine/hardpoint/plasmacannon
	name = "магазин PARS 177"
	desc = "Экранированный цилиндрический магазин для плазменной пушки точечной обороны тяжёлого танка Ridgeway. Содержит 3 кадмий-теллуридные гранулы по 2,4 г. Питание обеспечивает встроенный в башню 7-мВт водородный топливный элемент, которого хватает на 2500 выстрелов."
// SS220 EDIT - END
	icon = 'icons/obj/items/weapons/guns/ammo_by_faction/uscm.dmi'
	caliber = "93mm" //Making this unique on purpose
	icon_state = "plasmacannon_3"
	w_class = SIZE_LARGE //Heavy
	default_ammo = /datum/ammo/energy/plasma
	max_rounds = 3
	gun_type = /obj/item/hardpoint/primary/cannon/plasmacannon

/obj/item/ammo_magazine/hardpoint/plasmacannon/update_icon()
	icon_state = "plasmacannon_[current_rounds]"
