/obj/item/clothing/head/helmet/marine/sangheili
	name = "\improper шлем сангхейли"
	desc = "Наноламинатный шлем, вдохновлённый древними доспехами сангхейли доковенантной эпохи и почти не менявший дизайн полсотни поколений. Оснащён полноценными системами связи и smart-link, позволяющими владельцу управлять своими подчинёнными и точно работать с оружием."
	icon = 'modular/halo/icons/halo/obj/items/clothing/covenant/helmets.dmi'
	icon_state = "sang_minor_1"
	item_state = "sang_minor_1"

	item_icons = list(
		WEAR_HEAD = 'modular/halo/icons/halo/mob/humans/onmob/clothing/sangheili/hat.dmi'
	)

	allowed_species_list = list(SPECIES_SANGHEILI,SPECIES_SANGHEILI_HEROIC,SPECIES_SANGHEILI_LEGENDARY,SPECIES_SANGHEILI_MYTHIC)

	flags_marine_helmet = NO_FLAGS
	flags_inventory = NO_FLAGS
	flags_inv_hide = NO_FLAGS
	flags_atom = NO_NAME_OVERRIDE|NO_SNOW_TYPE
	built_in_visors = list()

	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUM

/obj/item/clothing/head/helmet/marine/sangheili/minor
	name = "\improper шлем сангхейли-минора"

/obj/item/clothing/head/helmet/marine/sangheili/major
	name = "\improper шлем сангхейли-майора"
	icon_state = "sang_major_1"
	item_state = "sang_major_1"

	armor_melee = CLOTHING_ARMOR_HIGHPLUS
	armor_bullet = CLOTHING_ARMOR_HIGHPLUS
	armor_laser = CLOTHING_ARMOR_HIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUMHIGH

/obj/item/clothing/head/helmet/marine/sangheili/ultra
	name = "\improper шлем сангхейли-ультры"
	icon_state = "sang_ultra_1"
	item_state = "sang_ultra_1"

	armor_melee = CLOTHING_ARMOR_VERYHIGH
	armor_bullet = CLOTHING_ARMOR_VERYHIGH
	armor_laser = CLOTHING_ARMOR_HIGHPLUS
	armor_bomb = CLOTHING_ARMOR_HIGH

/obj/item/clothing/head/helmet/marine/sangheili/zealot
	name = "\improper шлем сангхейли-зилота"
	icon_state = "sang_zealot_1"
	item_state = "sang_zealot_1"

	armor_melee = CLOTHING_ARMOR_ULTRAHIGH
	armor_bullet = CLOTHING_ARMOR_ULTRAHIGH
	armor_laser = CLOTHING_ARMOR_VERYHIGH
	armor_bomb = CLOTHING_ARMOR_HIGH

/obj/item/clothing/head/helmet/marine/ruuhtian
	name = "\improper Ruuhtian combat helmet"
	desc = "A basic helmet given to Kig-Yar warriors."
	icon = 'modular/halo/icons/halo/obj/items/clothing/covenant/helmets.dmi'
	icon_state = "standard_helmet"
	item_state = "standard_helmet"

	item_icons = list(
		WEAR_HEAD = 'modular/halo/icons/halo/mob/humans/onmob/clothing/ruuhtian/hat.dmi'
	)

	allowed_species_list = list(SPECIES_RUUHTIAN)

	flags_marine_helmet = NO_FLAGS
	flags_inventory = NO_FLAGS
	flags_inv_hide = NO_FLAGS
	flags_atom = NO_NAME_OVERRIDE|NO_SNOW_TYPE
	built_in_visors = list()

/obj/item/clothing/head/helmet/marine/ruuhtian/better
	name = "\improper superior Ruuhtian combat helmet"
	icon_state = "superior_helmet"
	item_state = "superior_helmet"

	armor_melee = CLOTHING_ARMOR_HIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bomb = CLOTHING_ARMOR_MEDIUM

/obj/item/clothing/head/helmet/marine/ruuhtian/sniper
	name = "\improper Ruuhtian sniper helmet"
	desc = "An optics-heavy helmet variant issued to Kig-Yar sharpshooters."
	icon_state = "sniper_helmet"
	item_state = "sniper_helmet"

/obj/item/clothing/head/helmet/marine/ruuhtian/marksman
	name = "\improper Ruuhtian marksman helmet"
	desc = "A combat optics helmet used by Kig-Yar marksmen."
	icon_state = "marksman_helmet"
	item_state = "marksman_helmet"

/obj/item/clothing/head/helmet/marine/ruuhtian/headset
	name = "\improper Ruuhtian tactical headset"
	desc = "A light tactical headset used by Kig-Yar skirmishers."
	icon_state = "headset"
	item_state = "headset"
