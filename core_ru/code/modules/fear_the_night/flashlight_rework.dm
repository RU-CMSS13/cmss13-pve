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
		connected_suit.power_current = clamp(connected_suit.power_current + 0.2, 0, connected_suit.power_amount)

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
		if(on)
			turn_off_light()
		STOP_PROCESSING(SSobj,src)

	if(battery.charge > 0)
		battery.use(flashlight_hungriness)

	if(!battery)
		playsound(src.loc, breaking_sound, 25, 1)
		if(on)
			turn_off_light()
		STOP_PROCESSING(SSobj,src)

/obj/item/device/flashlight/clicked(mob/user, list/mods)
	if(mods[ALT_CLICK] && needs_battery)
		if(!CAN_PICKUP(user, src))
			return ..()
		battery.forceMove(get_turf(loc))
		user.put_in_hands(battery)
		battery = null
		if(on)
			turn_off_light()
		if(process())
			playsound(src.loc, breaking_sound, 25, 1)
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
	battery_type = /obj/item/cell

/obj/item/device/flashlight/lamp
	flashlight_hungriness = 10

/obj/item/device/flashlight/tnr
	battery_type = /obj/item/cell

/obj/item/tool/candle
	light_system = MOVABLE_LIGHT

/obj/item/tool/lighter
	var/fuel = 100

/obj/item/tool/lighter/get_examine_text(mob/user)
	. = ..()

	if(MODE_HAS_TOGGLEABLE_FLAG(MODE_HARDCORE_LIGHTS))
		if(fuel < initial(fuel) / 2 && fuel > 0)
			. += SPAN_ORANGE("It's almost done...")
		if(fuel <= 0)
			. += SPAN_RED("It's empty!")

/obj/item/tool/lighter/process()
	if(fuel > 0)
		fuel = clamp(fuel - 1, 0, initial(fuel))

	if(fuel <= 0)
		turn_off_no_mob(0)

/obj/item/tool/lighter/proc/turn_off_no_mob(silent = 1)
	if(heat_source)
		heat_source = 0
		icon_state = icon_off
		item_state = icon_off
		if(!silent)
			if(istype(src, /obj/item/tool/lighter/zippo))
				playsound(src.loc,"zippo_close",10, 1, 3)

		set_light_on(FALSE)
		STOP_PROCESSING(SSobj, src)
		return 1
	return 0

/obj/item/device/flashlight/flare
	fuel = 5 MINUTES

/obj/item/device/flashlight/flare/on/illumination/Initialize()
	. = ..()
	fuel = rand(1.0 MINUTES, 2.0 MINUTES) // Approximately half the effective duration of a flare, but justified since it's invincible

/obj/item/storage/box/flare
	storage_slots = 6
	max_storage_space = 6

/obj/item/weapon/gun/flamer
	light_range = 1
	light_power = 0.3

/obj/item/clothing/head/hardhat
	light_system = DIRECTIONAL_LIGHT
	var/power_amount = 10
	var/power_current = 10

/obj/item/clothing/head/hardhat/dropped(mob/user)
	. = ..()
	maptext = ""

/obj/item/clothing/head/hardhat/process()
	if(light_on)
		if(power_current < 0)
			turn_light(loc, !light_on)
		else
			power_current = clamp(power_current - 0.3, 0, power_amount)

	if(!light_on && power_current < power_amount)
		power_current = clamp(power_current + 0.1, 0, power_amount)

	if(ishuman(loc))
		maptext = SPAN_LANGCHAT("|[power_current]/[power_amount]|%")
