//------------GEAR VENDOR---------------

GLOBAL_LIST_INIT(cm_vending_gear_leader, list(
		list("SQUAD LEADER KIT (CHOOSE 1)", 0, null, null, null),
		list("Essential SL Kit", 0, /obj/effect/essentials_set/leader, MARINE_CAN_BUY_ESSENTIALS, VENDOR_ITEM_MANDATORY),

		list("SQUAD KIT (CHOOSE 1, for yourself or your squad)", 0, null, null, null),
		list("M49A Sniper Kit", 0, /obj/item/storage/box/kit/mini_sniper, MARINE_CAN_BUY_KIT, VENDOR_ITEM_REGULAR),
		list("M41A Standard Kit", 0, /obj/item/storage/box/kit/m41a_kit	, MARINE_CAN_BUY_KIT, VENDOR_ITEM_REGULAR),
		list("M240 Pyrotechnician Support Kit", 0, /obj/item/storage/box/kit/mini_pyro, MARINE_CAN_BUY_KIT, VENDOR_ITEM_REGULAR),
		list("M2C Heavy Machine Gun", 0, /obj/item/storage/box/guncase/m2c, MARINE_CAN_BUY_KIT, VENDOR_ITEM_REGULAR),
		list("M56D Heavy Machine Gun", 0, /obj/item/storage/box/guncase/m56d, MARINE_CAN_BUY_KIT, VENDOR_ITEM_REGULAR),
		list("M79 Grenade Launcher", 0, /obj/item/storage/box/guncase/m79, MARINE_CAN_BUY_KIT, VENDOR_ITEM_REGULAR),
		list("MOU-53 Shotgun", 0, /obj/item/storage/box/guncase/mou53, MARINE_CAN_BUY_KIT, VENDOR_ITEM_REGULAR),
		list("XM88 Heavy Rifle", 0, /obj/item/storage/box/guncase/xm88, MARINE_CAN_BUY_KIT, VENDOR_ITEM_REGULAR),
		list("Basic Engineering Supplies", 0, /obj/item/storage/box/kit/engineering_supply_kit, MARINE_CAN_BUY_KIT, VENDOR_ITEM_REGULAR),

		list("ARMORS", 0, null, null, null),
		list("M4 Pattern Armor", 16, /obj/item/clothing/suit/storage/marine/medium/rto, null, VENDOR_ITEM_REGULAR),

		list("CLOTHING ITEMS", 0, null, null, null),
		list("Machete Scabbard (Full)", 4, /obj/item/storage/large_holster/machete/full, null, VENDOR_ITEM_REGULAR),
		list("Machete Pouch (Full)", 4, /obj/item/storage/pouch/machete/full, null, VENDOR_ITEM_REGULAR),
		list("USCM Radio Telephone Pack", 5, /obj/item/storage/backpack/marine/satchel/rto, null, VENDOR_ITEM_REGULAR),
		list("M276 Pattern Combat Toolbelt Rig", 15, /obj/item/storage/belt/gun/utility, null, VENDOR_ITEM_REGULAR),

		list("UTILITIES", 0, null, null, null),
		list("Whistle", 3, /obj/item/device/whistle, null, VENDOR_ITEM_REGULAR),
		list("Fire Extinguisher (Portable)", 3, /obj/item/tool/extinguisher/mini, null, VENDOR_ITEM_REGULAR),
		list("Motion Detector", 5, /obj/item/device/motiondetector, null, VENDOR_ITEM_REGULAR),
		list("Fulton Device Stack", 5, /obj/item/stack/fulton, null, VENDOR_ITEM_REGULAR),

		list("BINOCULARS", 0, null, null, null),
		list("Range Finder", 3, /obj/item/device/binoculars/range, null, VENDOR_ITEM_REGULAR),
		list("Laser Designator", 5, /obj/item/device/binoculars/range/designator, null, VENDOR_ITEM_REGULAR),

		list("HELMET OPTICS", 0, null, null, null),
		list("Welding Visor", 5, /obj/item/device/helmet_visor/welding_visor, null, VENDOR_ITEM_REGULAR),
		list("Medical Helmet Optic", 4, /obj/item/device/helmet_visor/medical, null, VENDOR_ITEM_RECOMMENDED),
		list("Night Vision Optic", 20, /obj/item/device/helmet_visor/night_vision, null, VENDOR_ITEM_RECOMMENDED),

		list("ENGINEERING SUPPLIES", 0, null, null, null),
		list("Insulated Gloves", 3, /obj/item/clothing/gloves/yellow, null, VENDOR_ITEM_REGULAR),
		list("Metal x10", 5, /obj/item/stack/sheet/metal/small_stack, null, VENDOR_ITEM_RECOMMENDED),
		list("Plasteel x10", 7, /obj/item/stack/sheet/plasteel/small_stack, null, VENDOR_ITEM_RECOMMENDED),
		list("Plastic explosive", 5, /obj/item/explosive/plastic, null, VENDOR_ITEM_RECOMMENDED),
		list("Breaching Charge", 7, /obj/item/explosive/plastic/breaching_charge, null, VENDOR_ITEM_RECOMMENDED),
		list("Sandbags x25", 10, /obj/item/stack/sandbags_empty/half, null, VENDOR_ITEM_RECOMMENDED),
		list("Signal Flare Pack", 7, /obj/item/storage/box/flare/signal, null, VENDOR_ITEM_REGULAR),
		list("Tools Pouch (Full)", 5, /obj/item/storage/pouch/tools/full, null, VENDOR_ITEM_REGULAR),
		list("Welding Goggles", 5, /obj/item/clothing/glasses/welding, null, VENDOR_ITEM_REGULAR),

		list("EXPLOSIVES", 0, null, null, null),
		list("M40 HEDP High Explosive Packet (x3 grenades)", 18, /obj/item/storage/box/packet/high_explosive, null, VENDOR_ITEM_REGULAR),
		list("M40 HIDP Incendiary Packet (x3 grenades)", 18, /obj/item/storage/box/packet/incendiary, null, VENDOR_ITEM_REGULAR),
		list("M40 WPDP White Phosphorus Packet (x3 grenades)", 18, /obj/item/storage/box/packet/phosphorus, null, VENDOR_ITEM_REGULAR),
		list("M40 HSDP Smoke Packet (x3 grenades)", 9, /obj/item/storage/box/packet/smoke, null, VENDOR_ITEM_REGULAR),
		list("M20 Mine Box (x5 mines)", 20, /obj/item/storage/box/explosive_mines, null, VENDOR_ITEM_REGULAR),
		list("M40 MFHS Metal Foam Grenade", 5, /obj/item/explosive/grenade/metal_foam, null, VENDOR_ITEM_REGULAR),
		list("G2 Electroshock Grenade Packet (x3 grenades)",  16, /obj/item/storage/box/packet/sebb, null, VENDOR_ITEM_REGULAR),

		list("MEDICAL SUPPLIES", 0, null, null, null),
		list("Burn Kit", 2, /obj/item/stack/medical/advanced/ointment, null, VENDOR_ITEM_REGULAR),
		list("Trauma Kit", 2, /obj/item/stack/medical/advanced/bruise_pack, null, VENDOR_ITEM_REGULAR),
		list("Advanced Firstaid Kit", 12, /obj/item/storage/firstaid/softpack/adv, null, VENDOR_ITEM_REGULAR),
		list("Medical Splints", 1, /obj/item/stack/medical/splint, null, VENDOR_ITEM_REGULAR),

		list("Injector (Bicaridine)", 1, /obj/item/reagent_container/hypospray/autoinjector/bicaridine, null, VENDOR_ITEM_REGULAR),
		list("Injector (Dexalin+)", 1, /obj/item/reagent_container/hypospray/autoinjector/dexalinp, null, VENDOR_ITEM_REGULAR),
		list("Injector (Inaprovaline)", 1, /obj/item/reagent_container/hypospray/autoinjector/inaprovaline, null, VENDOR_ITEM_REGULAR),
		list("Injector (Kelotane)", 1, /obj/item/reagent_container/hypospray/autoinjector/kelotane, null, VENDOR_ITEM_REGULAR),
		list("Injector (Oxycodone)", 2, /obj/item/reagent_container/hypospray/autoinjector/oxycodone, null, VENDOR_ITEM_REGULAR),
		list("Injector (Tramadol)", 1, /obj/item/reagent_container/hypospray/autoinjector/tramadol, null, VENDOR_ITEM_REGULAR),
		list("Injector (Tricord)", 1, /obj/item/reagent_container/hypospray/autoinjector/tricord, null, VENDOR_ITEM_REGULAR),

		list("Health Diagnostic Equipment", 4, /obj/item/device/healthanalyzer/soul, null, VENDOR_ITEM_REGULAR),
		list("Roller Bed", 2, /obj/item/roller, null, VENDOR_ITEM_REGULAR),

		list("PRIMARY AMMUNITION", 0, null, null, null),
		list("M49A AP Magazine (10x24mm)", 6, /obj/item/ammo_magazine/rifle/m49a/ap, null, VENDOR_ITEM_REGULAR),
		list("M39 AP Magazine (10x20mm)", 6, /obj/item/ammo_magazine/smg/m39/ap , null, VENDOR_ITEM_REGULAR),
		list("M39 Extended Magazine (10x20mm)", 6, /obj/item/ammo_magazine/smg/m39/extended , null, VENDOR_ITEM_REGULAR),
		list("M41A AP Magazine (10x24mm)", 6, /obj/item/ammo_magazine/rifle/ap , null, VENDOR_ITEM_REGULAR),
		list("M41A Extended Magazine (10x24mm)", 6, /obj/item/ammo_magazine/rifle/extended , null, VENDOR_ITEM_REGULAR),

		list("SIDEARM AMMUNITION", 0, null, null, null),
		list("M44 Heavy Speed Loader (.44)", 6, /obj/item/ammo_magazine/revolver/heavy, null, VENDOR_ITEM_REGULAR),
		list("M44 Marksman Speed Loader (.44)", 6, /obj/item/ammo_magazine/revolver/marksman, null, VENDOR_ITEM_REGULAR),
		list("M4A3 HP Magazine", 3, /obj/item/ammo_magazine/pistol/hp, null, VENDOR_ITEM_REGULAR),
		list("M4A3 AP Magazine", 3, /obj/item/ammo_magazine/pistol/ap, null, VENDOR_ITEM_REGULAR),
		list("VP78 Magazine", 3, /obj/item/ammo_magazine/pistol/vp78, null, VENDOR_ITEM_REGULAR),
		list("SU-6 Smartpistol Magazine (.45)", 6, /obj/item/ammo_magazine/pistol/smart, null, VENDOR_ITEM_REGULAR),

		list("SPECIAL AMMUNITION", 0, null, null, null),
		list("M240 Incinerator Tank (Napthal)", 3, /obj/item/ammo_magazine/flamer_tank, null, VENDOR_ITEM_REGULAR),
		list("M240 Incinerator Tank (B-Gel)", 3, /obj/item/ammo_magazine/flamer_tank/gellied, null, VENDOR_ITEM_REGULAR),

		list("RESTRICTED FIREARMS", 0, null, null, null),
		list("M240 Incinerator Unit", 18, /obj/item/storage/box/guncase/flamer, null, VENDOR_ITEM_REGULAR),
		list("VP78 Pistol", 8, /obj/item/storage/box/guncase/vp78, null, VENDOR_ITEM_REGULAR),
		list("SU-6 Smart Pistol", 12, /obj/item/storage/box/guncase/smartpistol, null, VENDOR_ITEM_REGULAR),
		list("M79 Grenade Launcher", 18, /obj/item/storage/box/guncase/m79, null, VENDOR_ITEM_REGULAR),

		list("RADIO KEYS", 0, null, null, null),
		list("Engineering Radio Encryption Key", 3, /obj/item/device/encryptionkey/engi, null, VENDOR_ITEM_REGULAR),
		list("Intel Radio Encryption Key", 3, /obj/item/device/encryptionkey/intel, null, VENDOR_ITEM_REGULAR),
		list("JTAC Radio Encryption Key", 3, /obj/item/device/encryptionkey/jtac, null, VENDOR_ITEM_REGULAR),
		list("Supply Radio Encryption Key", 3, /obj/item/device/encryptionkey/req, null, VENDOR_ITEM_REGULAR),
	))

/obj/structure/machinery/cm_vending/gear/leader
	name = "\improper ColMarTech Squad Leader Gear Rack"
	desc = "An automated gear rack for Squad Leaders."
	icon_state = "sl_gear"
	show_points = TRUE
	vendor_role = list(JOB_SQUAD_LEADER)
	req_access = list(ACCESS_MARINE_LEADER)

/obj/structure/machinery/cm_vending/gear/leader/get_listed_products(mob/user)
	return GLOB.cm_vending_gear_leader

//------------CLOTHING VENDOR---------------

GLOBAL_LIST_INIT(cm_vending_clothing_leader, list(
		list("STANDARD EQUIPMENT (TAKE ALL)", 0, null, null, null),
		list("Standard Marine Apparel", 0, list(/obj/item/clothing/under/marine, /obj/item/clothing/shoes/marine/knife, /obj/item/clothing/gloves/marine, /obj/item/device/radio/headset/almayer/marine, /obj/item/clothing/head/helmet/marine/leader), MARINE_CAN_BUY_UNIFORM, VENDOR_ITEM_MANDATORY),
		list("B12 Pattern Armor", 0, /obj/item/clothing/suit/storage/marine/medium/leader, MARINE_CAN_BUY_ARMOR, VENDOR_ITEM_MANDATORY),
		list("MRE", 0, /obj/item/storage/box/mre, MARINE_CAN_BUY_MRE, VENDOR_ITEM_MANDATORY),
		list("Map", 0, /obj/item/map/current_map, MARINE_CAN_BUY_ATTACHMENT, VENDOR_ITEM_MANDATORY),

		list("BACKPACK (CHOOSE 1)", 0, null, null, null),
		list("Backpack", 0, /obj/item/storage/backpack/marine, MARINE_CAN_BUY_BACKPACK, VENDOR_ITEM_REGULAR),
		list("Machete Scabbard (Full)", 0, /obj/item/storage/large_holster/machete/full, MARINE_CAN_BUY_BACKPACK, VENDOR_ITEM_REGULAR),
		list("Satchel", 0, /obj/item/storage/backpack/marine/satchel, MARINE_CAN_BUY_BACKPACK, VENDOR_ITEM_RECOMMENDED),

		list("BELT (CHOOSE 1)", 0, null, null, null),
		list("G8-A General Utility Pouch", 0, /obj/item/storage/backpack/general_belt, MARINE_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),
		list("M276 Ammo Load Rig", 0, /obj/item/storage/belt/marine, MARINE_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),
		list("M276 General Pistol Holster Rig", 0, /obj/item/storage/belt/gun/m4a3, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 Lifesaver Bag", 0, /obj/item/storage/belt/medical/lifesaver, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 Medical Storage Rig", 0, /obj/item/storage/belt/medical, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 M39 Holster Rig", 0, /obj/item/storage/belt/gun/m39, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 General Revolver Holster Rig", 0, /obj/item/storage/belt/gun/m44, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 M82F Holster Rig", 0, /obj/item/storage/belt/gun/flaregun, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 Shotgun Shell Loading Rig", 0, /obj/item/storage/belt/shotgun, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 Toolbelt Rig (Full)", 0, /obj/item/storage/belt/utility/full, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 M40 Grenade Rig", 0, /obj/item/storage/belt/grenade, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),

		list("POUCHES (CHOOSE 2)", 0, null, null, null),
		list("Autoinjector Pouch (Full)", 0, /obj/item/storage/pouch/autoinjector/full, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("First-Aid Pouch (Refillable Injectors)", 0, /obj/item/storage/pouch/firstaid/full, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("First-Aid Pouch (Splints, Gauze, Ointment)", 0, /obj/item/storage/pouch/firstaid/full/alternate, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("First-Aid Pouch (Pill Packets)", 0, /obj/item/storage/pouch/firstaid/full/pills, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("Flare Pouch (Full)", 0, /obj/item/storage/pouch/flare/full, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Fuel Tank Strap Pouch", 0, /obj/item/storage/pouch/flamertank, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Large General Pouch", 0, /obj/item/storage/pouch/general/large, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("Sling Pouch", 0, /obj/item/storage/pouch/sling, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Large Magazine Pouch", 0, /obj/item/storage/pouch/magazine/large, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Large Shotgun Shell Pouch", 0, /obj/item/storage/pouch/shotgun/large, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Large Pistol Magazine Pouch", 0, /obj/item/storage/pouch/magazine/pistol/large, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Pistol Pouch", 0, /obj/item/storage/pouch/pistol, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),

		list("ACCESSORIES (CHOOSE 1)", 0, null, null, null),
		list("Black Webbing Vest", 0, /obj/item/clothing/accessory/storage/black_vest, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("Brown Webbing Vest", 0, /obj/item/clothing/accessory/storage/black_vest/brown_vest, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_RECOMMENDED),
		list("Shoulder Holster", 0, /obj/item/clothing/accessory/storage/holster, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("Webbing", 0, /obj/item/clothing/accessory/storage/webbing, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("Drop Pouch", 0, /obj/item/clothing/accessory/storage/droppouch, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),

		list("MASK (CHOOSE 1)", 0, null, null, null),
		list("Gas Mask", 0, /obj/item/clothing/mask/gas, MARINE_CAN_BUY_MASK, VENDOR_ITEM_REGULAR),
		list("Heat Absorbent Coif", 0, /obj/item/clothing/mask/rebreather/scarf, MARINE_CAN_BUY_MASK, VENDOR_ITEM_REGULAR),
	))

/obj/structure/machinery/cm_vending/clothing/leader
	name = "\improper ColMarTech Squad Leader Equipment Rack"
	desc = "An automated rack hooked up to a colossal storage of Squad Leader standard-issue equipment."
	req_access = list(ACCESS_MARINE_LEADER)
	vendor_role = list(JOB_SQUAD_LEADER)

/obj/structure/machinery/cm_vending/clothing/leader/get_listed_products(mob/user)
	return GLOB.cm_vending_clothing_leader

/obj/structure/machinery/cm_vending/clothing/leader/alpha
	squad_tag = SQUAD_MARINE_1
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_ALPHA)
	headset_type = /obj/item/device/radio/headset/almayer/marine/alpha/lead

/obj/structure/machinery/cm_vending/clothing/leader/bravo
	squad_tag = SQUAD_MARINE_2
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_BRAVO)
	headset_type = /obj/item/device/radio/headset/almayer/marine/bravo/lead

/obj/structure/machinery/cm_vending/clothing/leader/charlie
	squad_tag = SQUAD_MARINE_3
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_CHARLIE)
	headset_type = /obj/item/device/radio/headset/almayer/marine/charlie/lead

/obj/structure/machinery/cm_vending/clothing/leader/delta
	squad_tag = SQUAD_MARINE_4
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_DELTA)
	headset_type = /obj/item/device/radio/headset/almayer/marine/delta/lead

//------------ESSENTIAL SETS---------------

/obj/effect/essentials_set/leader
	spawned_gear_list = list(
		/obj/item/explosive/plastic,
		/obj/item/device/binoculars/range/designator,
		/obj/item/storage/box/flare/signal,
		/obj/item/tool/extinguisher/mini,
		/obj/item/storage/box/zipcuffs,
	)

// PMC Small Squad

// gear

/obj/effect/essentials_set/leader/pmc
	spawned_gear_list = list(
		/obj/item/explosive/plastic,
		/obj/item/device/binoculars/range/designator,
		/obj/item/storage/box/flare/signal,
		/obj/item/tool/extinguisher/mini,
		/obj/item/storage/box/zipcuffs,
	)

GLOBAL_LIST_INIT(cm_vending_gear_leader_pmc, list(
		list("SQUAD LEADER KIT (CHOOSE 1)", 0, null, null, null),
		list("Essential SL Kit", 0, /obj/effect/essentials_set/leader/pmc, MARINE_CAN_BUY_ESSENTIALS, VENDOR_ITEM_MANDATORY),

		list("SQUAD KIT (CHOOSE 1, for yourself or your squad)", 0, null, null, null),
		list("M240A1 Pyrotechnician Support Kit", 0, /obj/item/storage/box/kit/mini_pyro/pmc, MARINE_CAN_BUY_KIT, VENDOR_ITEM_REGULAR),
		list("M92 Grenadier Kit", 0, /obj/item/storage/box/kit/grenadier, MARINE_CAN_BUY_KIT, VENDOR_ITEM_REGULAR),
		list("M42C Sniper Kit", 0, /obj/item/storage/box/guncase/m42c/heap, MARINE_CAN_BUY_KIT, VENDOR_ITEM_REGULAR),
		list("Shotgunner Kit", 0, /obj/item/storage/box/kit/shotgunner, MARINE_CAN_BUY_KIT, VENDOR_ITEM_REGULAR),
		list("Mateba Kit", 0, /obj/item/storage/box/kit/mateba, MARINE_CAN_BUY_KIT, VENDOR_ITEM_REGULAR),

		list("UTILITIES", 0, null, null, null),
		list("Whistle", 3, /obj/item/device/whistle, null, VENDOR_ITEM_REGULAR),
		list("Fire Extinguisher (Portable)", 3, /obj/item/tool/extinguisher/mini, null, VENDOR_ITEM_REGULAR),
		list("Motion Detector", 5, /obj/item/device/motiondetector/hacked/pmc, null, VENDOR_ITEM_REGULAR),

		list("HELMET OPTICS", 0, null, null, null),
		list("Medical Helmet Optic", 10, /obj/item/device/helmet_visor/medical, null, VENDOR_ITEM_RECOMMENDED),

		list("ENGINEERING SUPPLIES", 0, null, null, null),
		list("Metal x10", 5, /obj/item/stack/sheet/metal/small_stack, null, VENDOR_ITEM_RECOMMENDED),
		list("Plasteel x10", 7, /obj/item/stack/sheet/plasteel/small_stack, null, VENDOR_ITEM_RECOMMENDED),
		list("Plastic explosive", 5, /obj/item/explosive/plastic, null, VENDOR_ITEM_RECOMMENDED),
		list("Breaching Charge", 7, /obj/item/explosive/plastic/breaching_charge, null, VENDOR_ITEM_RECOMMENDED),
		list("Sandbags x25", 10, /obj/item/stack/sandbags_empty/half, null, VENDOR_ITEM_RECOMMENDED),
		list("Tactical Tools Pouch (Full)", 20, /obj/item/storage/pouch/tools/tactical/full, null, VENDOR_ITEM_REGULAR),

		list("EXPLOSIVES", 0, null, null, null),
		list("M12 Blast Grenade", 10, /obj/item/explosive/grenade/high_explosive/pmc, null, VENDOR_ITEM_REGULAR),
		list("G2 Electroshock Grenade Packet (x3 grenades)",  10, /obj/item/storage/box/packet/sebb, null, VENDOR_ITEM_REGULAR),
		list("M20A2P Mine Box (x5 mines)", 15, /obj/item/storage/box/explosive_mines/pmc, null, VENDOR_ITEM_REGULAR),
		list("M40 HEDP Grenade Box (x25 grenades)", 15, /obj/item/ammo_box/magazine/nade_box, null, VENDOR_ITEM_REGULAR),
		list("M40 Super HEDP Grenade Box (x25 grenades)", 40, /obj/item/ammo_box/magazine/nade_box/super, null, VENDOR_ITEM_REGULAR),
		list("M72A2 HIPF Starshell Grenade Box (x25 grenades)", 10, /obj/item/ammo_box/magazine/nade_box/flare, null, VENDOR_ITEM_REGULAR),
		list("M47 HSDP Grenade Box (x25 grenades)", 10, /obj/item/ammo_box/magazine/nade_box/smoke, null, VENDOR_ITEM_REGULAR),

		list("MEDICAL SUPPLIES", 0, null, null, null),
		list("Burn Kit", 2, /obj/item/stack/medical/advanced/ointment, null, VENDOR_ITEM_REGULAR),
		list("Trauma Kit", 2, /obj/item/stack/medical/advanced/bruise_pack, null, VENDOR_ITEM_REGULAR),
		list("Advanced Firstaid Kit", 12, /obj/item/storage/firstaid/softpack/adv, null, VENDOR_ITEM_REGULAR),
		list("Medical Splints", 1, /obj/item/stack/medical/splint, null, VENDOR_ITEM_REGULAR),

		list("Injector (Bicaridine)", 1, /obj/item/reagent_container/hypospray/autoinjector/bicaridine, null, VENDOR_ITEM_REGULAR),
		list("Injector (Dexalin+)", 1, /obj/item/reagent_container/hypospray/autoinjector/dexalinp, null, VENDOR_ITEM_REGULAR),
		list("Injector (Inaprovaline)", 1, /obj/item/reagent_container/hypospray/autoinjector/inaprovaline, null, VENDOR_ITEM_REGULAR),
		list("Injector (Kelotane)", 1, /obj/item/reagent_container/hypospray/autoinjector/kelotane, null, VENDOR_ITEM_REGULAR),
		list("Injector (Oxycodone)", 2, /obj/item/reagent_container/hypospray/autoinjector/oxycodone, null, VENDOR_ITEM_REGULAR),
		list("Injector (Tramadol)", 1, /obj/item/reagent_container/hypospray/autoinjector/tramadol, null, VENDOR_ITEM_REGULAR),
		list("Injector (Tricord)", 1, /obj/item/reagent_container/hypospray/autoinjector/tricord, null, VENDOR_ITEM_REGULAR),

		list("Health Diagnostic Equipment", 4, /obj/item/device/healthanalyzer/soul, null, VENDOR_ITEM_REGULAR),
		list("Roller Bed", 2, /obj/item/roller, null, VENDOR_ITEM_REGULAR),

		list("PRIMARY AMMUNITION", 0, null, null, null),
		list("M41A MK1 LEAP Magazine (10x24mm)", 6, /obj/item/ammo_magazine/rifle/m41aMK1/ap, null, VENDOR_ITEM_REGULAR),
		list("M41A MK1 Incendiary Magazine (10x24mm)", 6, /obj/item/ammo_magazine/rifle/m41aMK1/incendiary, null, VENDOR_ITEM_REGULAR),
		list("M41A MK1 Wall-Penetrating Magazine (10x24mm)", 12, /obj/item/ammo_magazine/rifle/m41aMK1/penetrating, null, VENDOR_ITEM_REGULAR),
		list("M41A MK1 HEAP Magazine (10x24mm)", 18, /obj/item/ammo_magazine/rifle/m41aMK1/heap, null, VENDOR_ITEM_REGULAR),

		list("SIDEARM AMMUNITION", 0, null, null, null),
		list("Mateba Speed Loader (.454)", 6, /obj/item/ammo_magazine/revolver/mateba, null, VENDOR_ITEM_REGULAR),
		list("High Impact Mateba Speed Loader (.454)", 12, /obj/item/ammo_magazine/revolver/mateba/highimpact, null, VENDOR_ITEM_REGULAR),
		list("High Impact Armor-Piercing Mateba Speed Loader (.454)", 16, /obj/item/ammo_magazine/revolver/mateba/highimpact/ap, null, VENDOR_ITEM_REGULAR),

		list("SPECIAL AMMUNITION", 0, null, null, null),
		list("M240 Incinerator Tank (Napthal)", 3, /obj/item/ammo_magazine/flamer_tank, null, VENDOR_ITEM_REGULAR),
		list("M240 Incinerator Tank (B-Gel)", 6, /obj/item/ammo_magazine/flamer_tank/gellied, null, VENDOR_ITEM_REGULAR),
		list("M240 Incinerator Tank (EX)", 12, /obj/item/ammo_magazine/flamer_tank/EX, null, VENDOR_ITEM_REGULAR),
	))

/obj/structure/machinery/cm_vending/gear/leader/pmc
	name = "\improper WeyTech Squad Leader Gear Rack"
	desc = "An automated gear rack for Squad Leaders."
	icon_state = "sl_gear"
	show_points = TRUE
	vendor_role = list(JOB_SQUAD_LEADER)
	req_access = list(ACCESS_WY_SENIOR_LEAD)
	vendor_theme = VENDOR_THEME_COMPANY

/obj/structure/machinery/cm_vending/gear/leader/pmc/get_listed_products(mob/user)
	return GLOB.cm_vending_gear_leader_pmc

// clothing

GLOBAL_LIST_INIT(cm_vending_clothing_leader_pmc, list(
		list("STANDARD EQUIPMENT (TAKE ALL)", 0, null, null, null),
		list("Leader Apparel", 0, list(/obj/item/clothing/under/marine/veteran/pmc/leader/commando/leader, /obj/item/clothing/gloves/marine/veteran/pmc/black, /obj/item/clothing/shoes/veteran/pmc/knife, /obj/item/clothing/head/cmcap/weyyu/guard/lead), MARINE_CAN_BUY_UNIFORM, VENDOR_ITEM_MANDATORY),
		list("Guard Leader Armor", 0, /obj/item/clothing/suit/marine/veteran/pmc/leader/guard, MARINE_CAN_BUY_ARMOR, VENDOR_ITEM_MANDATORY),

		list("BACKPACK (CHOOSE 1)", 0, null, null, null),
		list("Expedition Leader Backpack", 0, /obj/item/storage/backpack/pmc/backpack/commando/leader, MARINE_CAN_BUY_BACKPACK, VENDOR_ITEM_RECOMMENDED),
		list("Radio Telephone Backpack", 0, /obj/item/storage/backpack/pmc/backpack/rto_broken, MARINE_CAN_BUY_BACKPACK, VENDOR_ITEM_REGULAR),

		list("BELT (CHOOSE 1)", 0, null, null, null),
		list("WY-TM612 General Utility Pouch", 0, /obj/item/storage/backpack/general_belt/wy, MARINE_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),
		list("M276 Pattern M82F Holster Rig", 0, /obj/item/storage/belt/gun/flaregun, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("WY-TM625 Lifesaver Bag (Full)", 0, /obj/item/storage/belt/medical/lifesaver/wy/full, MARINE_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),
		list("WY-TM402 Pattern Ammo Load Rig", 0, /obj/item/storage/belt/marine/wy, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("WY-TM406 pattern Shotgun Shell Rig", 0, /obj/item/storage/belt/shotgun/wy, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("WY-TM892 Pattern General Pistol Holster Rig", 0, /obj/item/storage/belt/gun/m4a3/wy, MARINE_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),

		list("POUCHES (CHOOSE 2)", 0, null, null, null),
		list("Autoinjector Pouch (Refillable Injectors)", 0, /obj/item/storage/pouch/autoinjector/full/wy, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("Large General Pouch", 0, /obj/item/storage/pouch/general/large/wy, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Large Magazine Pouch", 0, /obj/item/storage/pouch/magazine/large/wy, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("Large Shotgun Shell Pouch", 0, /obj/item/storage/pouch/shotgun/large, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Large Pistol Magazine Pouch", 0, /obj/item/storage/pouch/magazine/pistol/large, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Tactical Tools Pouch (Full)", 0, /obj/item/storage/pouch/tools/tactical/full, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),

		list("ACCESSORIES (CHOOSE 1)", 0, null, null, null),
		list("Waist Holster", 0, /obj/item/clothing/accessory/storage/holster/waist, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("Small Pouch", 0, /obj/item/clothing/accessory/storage/smallpouch/wy, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
		list("Drop Pouch", 0, /obj/item/clothing/accessory/storage/droppouch/wy, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
	))

/obj/structure/machinery/cm_vending/clothing/leader/pmc
	name = "\improper ColMarTech Squad Leader Equipment Rack"
	desc = "An automated rack hooked up to a colossal storage of Squad Leader standard-issue equipment."
	icon_state = "pmc_gear"
	req_access = list(ACCESS_WY_SENIOR_LEAD)
	vendor_role = list(JOB_SQUAD_LEADER)
	vendor_theme = VENDOR_THEME_COMPANY

/obj/structure/machinery/cm_vending/clothing/leader/pmc/get_listed_products(mob/user)
	return GLOB.cm_vending_clothing_leader_pmc
