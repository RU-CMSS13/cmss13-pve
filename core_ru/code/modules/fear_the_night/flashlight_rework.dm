/client/proc/toggle_flashlight_hardmode()
	set name = "Toggle Hardcore Lights"
	set category = "Admin.Flags"

	if(!admin_holder || !check_rights(R_MOD, FALSE))
		return

	if(!SSticker.mode)
		to_chat(usr, SPAN_WARNING("A mode hasn't been selected yet!"))
		return

	SSticker.mode.toggleable_flags ^= MODE_HARDCORE_LIGHTS
	message_admins("[src] has [MODE_HAS_TOGGLEABLE_FLAG(MODE_HARDCORE_LIGHTS) ? "toggled flashlight hardcoreness" : "returned flashlights to basics"].")

/atom/movable/marine_light
	var/obj/item/clothing/suit/connected_suit

/atom/movable/marine_light/process()
	if(light_on && connected_suit)
		if(connected_suit.power_current < 0)
			connected_suit.turn_light(connected_suit.loc, !light_on)
		else
			connected_suit.power_current = clamp(connected_suit.power_current - 1, 0, connected_suit.power_amount)

	if(!light_on && connected_suit && connected_suit.power_current < connected_suit.power_amount)
		connected_suit.power_current = clamp(connected_suit.power_current + 0.5, 0, connected_suit.power_amount)

	if(ishuman(connected_suit.loc))
		connected_suit.maptext = SPAN_LANGCHAT("|[connected_suit.power_current]/[connected_suit.power_amount]|%")

/obj/item/clothing/suit
	var/power_amount = 30
	var/power_current = 30
	maptext_width = 48
	maptext_height = 48

/obj/item/clothing/suit/marine/dropped(mob/user)
	. = ..()
	maptext = ""

/obj/item/clothing/suit/storage/marine/dropped(mob/user)
	. = ..()
	maptext = ""

/obj/item/device/flashlight
	var/needs_battery = TRUE
	var/put_in_battery_type = TRUE
	var/battery_type = /obj/item/cell/crap

	var/flashlight_hungriness = 5

	var/obj/item/cell/battery

/obj/item/device/flashlight/get_examine_text(mob/user)
	. = ..()

	if(MODE_HAS_TOGGLEABLE_FLAG(MODE_HARDCORE_LIGHTS) && needs_battery)
		if(battery)
			. += SPAN_BLUE("There is battery inside, charged to [battery.percent()].")
		if(!battery)
			. += SPAN_RED("It needs battery to work, but there is nothing inside!")


/obj/item/device/flashlight/Initialize()
	. = ..()

	if(needs_battery)
		if(put_in_battery_type)
			battery = new battery_type(src)
		else
			battery = new /obj/item/cell(src)

/obj/item/device/flashlight/process()
	if(battery.charge <= 0)
		playsound(src.loc, breaking_sound, 25, 1)
		turn_off_light()

		STOP_PROCESSING(SSobj,src)

	if(battery.charge > 0)
		battery.use(flashlight_hungriness)

/obj/item/device/flashlight/clicked(mob/user, list/mods)
	if(mods[ALT_CLICK] && needs_battery)
		if(!CAN_PICKUP(user, src))
			return ..()
		battery.forceMove(get_turf(loc))
		user.put_in_hands(battery)
		battery = null
		if(process())
			playsound(src.loc, breaking_sound, 25, 1)
			turn_off_light()
			STOP_PROCESSING(SSobj,src)
		return TRUE
	return ..()

/obj/item/device/flashlight/lamp/menorah
	needs_battery = FALSE

/obj/item/device/flashlight/lamp/candelabra
	needs_battery = FALSE

/obj/item/device/flashlight/lamp/tripod
	needs_battery = FALSE

/obj/item/device/flashlight/flare
	needs_battery = FALSE

/obj/item/device/flashlight/slime
	needs_battery = FALSE

/obj/item/device/flashlight/combat
	put_in_battery_type = /obj/item/cell

/obj/item/device/flashlight/lamp
	flashlight_hungriness = 10

/obj/item/device/flashlight/tnr
	put_in_battery_type = /obj/item/cell
