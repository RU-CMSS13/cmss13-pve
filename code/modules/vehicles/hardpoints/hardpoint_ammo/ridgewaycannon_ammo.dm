// SS220 EDIT - START: PR #1266 D66-44 — translated name/desc to Russian
/obj/item/ammo_magazine/hardpoint/ridgewaycannon
	name = "115-мм магазин"
	desc = "Магазин для 115-мм гладкоствольной пушки тяжёлого танка Ridgeway, подающий 6 снарядов в автомат заряжания. Из-за отсутствия встроенного метательного заряда и использования внутреннего гиперголического бака в башне такие магазины отличаются высокой эффективностью использования пространства и общей безопасностью."
// SS220 EDIT - END
	caliber = "115mm" //Making this unique on purpose
	icon_state = "ridgewaycannon_6"
	w_class = SIZE_LARGE //Heavy fucker
	default_ammo = /datum/ammo/rocket/ltb/ridgeway
	max_rounds = 6
	gun_type = /obj/item/hardpoint/primary/cannon/ridgeway

/obj/item/ammo_magazine/hardpoint/ridgewaycannon/update_icon()
	icon_state = "ridgewaycannon_[current_rounds]"
