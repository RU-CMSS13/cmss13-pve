/obj/item/device/radio/headset/almayer/marine/solardevils/unsc
	name = "UNSC headset"
	desc = "Специальная гарнитура, используемая Космическим Командованием Объединённых Наций во всех родах войск."
	minimap_type = MINIMAP_FLAG_UNSC
	frequency = UNSC_FREQ
	has_hud = TRUE
	hud_type = list(MOB_HUD_FACTION_UNSC)
	inbuilt_tracking_options = list(
		"Platoon Commander" = TRACKER_PLTCO,
		"Squad Leader" = TRACKER_SL,
		"Group Leader" = TRACKER_FTL,
		"Landing Zone" = TRACKER_LZ
	)

/obj/item/device/radio/headset/almayer/marine/solardevils/unsc/equipped(mob/living/carbon/human/user, slot)
	. = ..()

	if((user == user.assigned_squad?.fireteam_leaders["SQ1"] || user == user.assigned_squad?.fireteam_leaders["SQ2"]) && ("Squad Leader" in tracking_options))
		locate_setting = tracking_options["Squad Leader"]
		return

	if(((user in user.assigned_squad?.fireteams["SQ1"]) || (user in user.assigned_squad?.fireteams["SQ2"])) && ("Fireteam Leader" in tracking_options))
		locate_setting = tracking_options["Fireteam Leader"]
		return

/obj/item/device/radio/headset/almayer/marine/solardevils/unsc/odst
	name = "гарнитура ODST"
	frequency = ODST_FREQ

/obj/item/device/radio/headset/almayer/marine/solardevils/unsc/crew
	initial_keys = list(/obj/item/device/encryptionkey/mcom/alt/squads)

/obj/item/device/radio/headset/almayer/marine/solardevils/unsc/crew/odst
	parent_type = /obj/item/device/radio/headset/almayer/marine/solardevils/unsc/crew
	frequency = ODST_FREQ

/obj/item/device/radio/headset/almayer/marine/solardevils/unsc/command
	initial_keys = list(/obj/item/device/encryptionkey/mcom/alt/squads, /obj/item/device/encryptionkey/squadlead)

/obj/item/device/radio/headset/almayer/marine/solardevils/unsc/command/odst
	parent_type = /obj/item/device/radio/headset/almayer/marine/solardevils/unsc/command
	frequency = ODST_FREQ

/obj/item/device/radio/headset/almayer/marine/solardevils/pltco/unsc
	parent_type = /obj/item/device/radio/headset/almayer/marine/solardevils/unsc
	initial_keys = list(/obj/item/device/encryptionkey/mcom/alt/squads, /obj/item/device/encryptionkey/squadlead)

/obj/item/device/radio/headset/almayer/marine/solardevils/pltco/odst
	parent_type = /obj/item/device/radio/headset/almayer/marine/solardevils/unsc/odst
	initial_keys = list(/obj/item/device/encryptionkey/mcom/alt/squads, /obj/item/device/encryptionkey/squadlead)

/obj/item/device/radio/headset/distress/oni
	name = "ONI security headset"
	desc = "Гарнитура, используемая силами безопасности ONI."
	frequency = ONI_FREQ
	initial_keys = list(/obj/item/device/encryptionkey/oni)
