/datum/supply_packs/pouches_ammo
	name = "Large Pouch 2x(pistol,magazine,general)"
	contains = list(
		/obj/item/storage/pouch/magazine/large,
		/obj/item/storage/pouch/magazine/large,
		/obj/item/storage/pouch/magazine/pistol/large,
		/obj/item/storage/pouch/magazine/pistol/large,
		/obj/item/storage/pouch/general,
		/obj/item/storage/pouch/general,
	)
	cost = 60
	containertype = /obj/structure/closet/crate
	containername = "Large Pouch"
	group = "Clothing"

/datum/supply_packs/pouches_medical
	name = "medical pouches crate (1x firstaid, medical, syringe, medkit, autoinjector)"
	contains = list(
		/obj/item/storage/pouch/firstaid,
		/obj/item/storage/pouch/medical,
		/obj/item/storage/pouch/syringe,
		/obj/item/storage/pouch/medkit,
		/obj/item/storage/pouch/autoinjector,
	)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "medical pouches crate"
	group = "Clothing"

//---------------------------------------------
//HOLSTERS & WEBBING BELOW THIS LINE
//---------------------------------------------
/datum/supply_packs/drop_pouches
	name = "Drop Pouch Crate (x4)"
	contains = list(
		/obj/item/clothing/accessory/storage/droppouch,
		/obj/item/clothing/accessory/storage/droppouch,
		/obj/item/clothing/accessory/storage/droppouch,
		/obj/item/clothing/accessory/storage/droppouch,
	)
	cost = 10
	containertype = /obj/structure/closet/crate/green
	containername = "Drop Pouch Crate"
	group = "Clothing"


/datum/supply_packs/webbing_knives//for the lulz
	name = "Knife Vest Crate (x3)"
	contains = list(
		/obj/item/clothing/accessory/storage/knifeharness,//old unathi knife harness updated for our needs
		/obj/item/clothing/accessory/storage/knifeharness,
		/obj/item/clothing/accessory/storage/knifeharness
	)
	cost = 30
	containertype = /obj/structure/closet/crate/green
	containername = "Knife Vest Crate"
	group = "Clothing"

/datum/supply_packs/webbing_holster
	name = "Shoulder Holster Crate (x4)"
	contains = list(
		/obj/item/clothing/accessory/storage/holster,
		/obj/item/clothing/accessory/storage/holster,
		/obj/item/clothing/accessory/storage/holster,
		/obj/item/clothing/accessory/storage/holster,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/green
	containername = "Shoulder Holster Crate"
	group = "Clothing"

/datum/supply_packs/officer_outfits//lmao this shit is so hideously out of date
	contains = list(
		/obj/item/clothing/under/marine/officer/qm_suit,
		/obj/item/clothing/under/marine/officer/bridge,
		/obj/item/clothing/under/marine/officer/bridge,
		/obj/item/clothing/under/marine/dress,
		/obj/item/clothing/under/marine/officer/ce,
	)
	name = "officer outfit crate"
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "officer dress crate"
	group = "Clothing"
