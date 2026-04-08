/datum/supply_packs/m56_hmg
	name = "M56D Heavy Machine Gun (x1)"
	contains = list(
		/obj/item/storage/box/guncase/m56d,
	)
	cost = 60
	containertype = /obj/structure/closet/crate/weapon
	containername = "M56D Machine Gun Crate"
	group = "Weapons"

/datum/supply_packs/m2c_hmg
	name = "M2C Heavy Machine Gun (x1)"
	contains = list(
		/obj/item/storage/box/guncase/m2c,
	)
	cost = 80
	containertype = /obj/structure/closet/crate/weapon
	containername = "M2C Machine Gun Crate"
	group = "Weapons"

/datum/supply_packs/flamethrower
	name = "M240 Flamethrower Crate (M240 x2, Broiler-T Fuelback x2)"
	contains = list(
		/obj/item/storage/box/guncase/flamer,
		/obj/item/storage/box/guncase/flamer,
		/obj/item/storage/backpack/marine/engineerpack/flamethrower/kit,
		/obj/item/storage/backpack/marine/engineerpack/flamethrower/kit,
	)
	cost = 80
	containertype = /obj/structure/closet/crate/ammo/alt/flame
	containername = "M240 Incinerator crate"
	group = "Weapons"

/datum/supply_packs/vp78
	name = "VP-78 Hand Cannon Crate (x2)"
	contains = list(
		/obj/item/storage/box/guncase/vp78,
		/obj/item/storage/box/guncase/vp78,
	)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "VP-78 Hand Cannon Crate"
	group = "Weapons"

/datum/supply_packs/gun
	contains = list(
		/obj/item/weapon/gun/rifle/m41aMK1,
		/obj/item/weapon/gun/rifle/m41aMK1,
		/obj/item/ammo_magazine/rifle/m41aMK1,
		/obj/item/ammo_magazine/rifle/m41aMK1,
	)
	name = "M41A MK1 Rifle Crate (x2 MK1, x2 magazines)"
	cost = 20
	containertype = /obj/structure/closet/crate/weapon
	containername = "M41A MK1 Rifle Crate"
	group = "Weapons"

/datum/supply_packs/gun/heavyweapons
	contains = list(
		/obj/item/storage/box/guncase/lmg,
		/obj/item/storage/box/guncase/lmg,
	)
	name = "M41AE2 HPR crate (HPR x2, HPR ammo box x2)"
	cost = 80
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M41AE2 HPR crate"
	group = "Weapons"


	contains = list(
		/obj/item/prop/folded_anti_tank_sadar,
		/obj/item/prop/folded_anti_tank_sadar,
	)
	name = "M83 SADAR Anti-Tank RPG crate (M83 SADAR x2)"
	cost = 80
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M83 SADAR"
	group = "Weapons"

/* Uncomment me if it's decided to let the m707 be purchasable through req
/datum/supply_packs/gun/m707
	name = "M707 Anti-Materiel Rifle crate (M707 x1)"
	contains = list()
	cost = 120
	containertype = /obj/structure/closet/crate/secure/vulture
	containername = "M707 crate"
	group = "Weapons"

*/

/datum/supply_packs/gun/merc
	contains = list()
	name = "black market firearms (x1)"
	cost = 40
	contraband = 1
	containertype = /obj/structure/largecrate/guns/merc
	containername = "\improper black market firearms crate"
	group = "Weapons"
