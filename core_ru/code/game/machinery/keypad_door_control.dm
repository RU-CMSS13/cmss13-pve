#define KEYPAD_STATUS_IDLE "idle"
#define KEYPAD_STATUS_GRANTED "granted"
#define KEYPAD_STATUS_DENIED "denied"
#define KEYPAD_STATUS_LOCKED "locked"
#define KEYPAD_STATUS_TIME (1.5 SECONDS)
#define KEYPAD_LIGHT_RANGE 1
#define KEYPAD_LIGHT_POWER 0.5

/obj/structure/machinery/door_control/keypad
	name = "keypad shutters-control"
	desc = "A remote control-switch for a door. This one has a keypad and wants a code."
	icon = 'core_ru/icons/keypad.dmi'
	icon_state = "keypad_panel"
	/// ID, keep in mind range is 10, if ya want more change var/range
	id = "CHANGE ME"
	/// The code that has to be entered, digits only. If left empty, it is taken from another keypad with the same id, or a random one of pin_length digits is rolled.
	var/password = ""
	/// Length of the randomly rolled code
	var/pin_length = 4
	/// If TRUE the keypad locks itself after correct code
	var/single_use = FALSE
	var/used = FALSE
	var/status = KEYPAD_STATUS_IDLE
	/// Codes of all keypads by their id, so that keypads of the same door end up with the same code
	var/static/list/shared_passwords = list()
	/// Keypad UI style
	var/ui_style = "uscm"
	light_color = "#00e94e"

/obj/structure/machinery/door_control/keypad/Initialize(mapload, ...)
	. = ..()
	password = "[password]" // mappers tend to put a number in here
	if(password && !isnull(id) && !shared_passwords[id])
		shared_passwords[id] = password
	update_glow()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/machinery/door_control/keypad/LateInitialize()
	. = ..()
	resolve_password()

/// Keypads without password take the password of the other keypads with the same id, or roll a new one for all of them.
/obj/structure/machinery/door_control/keypad/proc/resolve_password()
	if(password)
		return
	if(!isnull(id) && shared_passwords[id])
		password = shared_passwords[id]
		return
	for(var/i in 1 to pin_length)
		password += "[rand(0, 9)]"
	if(!isnull(id))
		shared_passwords[id] = password

/obj/structure/machinery/door_control/keypad/attack_hand(mob/living/user)
	add_fingerprint(user)
	if(istype(user, /mob/living/carbon/xenomorph))
		return
	if(inoperable())
		to_chat(user, SPAN_WARNING("[src] doesn't seem to be working."))
		return
	tgui_interact(user)

/obj/structure/machinery/door_control/keypad/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "KeypadDoorControl", name)
		ui.open()

/obj/structure/machinery/door_control/keypad/ui_static_data(mob/user)
	var/list/data = list()
	data["style"] = ui_style
	return data

/obj/structure/machinery/door_control/keypad/ui_data(mob/user)
	var/list/data = list()
	data["code_length"] = length(password)
	data["status"] = status
	return data

/obj/structure/machinery/door_control/keypad/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(inoperable() || status != KEYPAD_STATUS_IDLE || (used && single_use))
		return
	if(action == "keypress")
		playsound(src, get_sfx("terminal_button"), 25, FALSE)
		return
	if(action != "submit")
		return

	var/code = params["code"]
	if(!istext(code) || length(code) > length(password))
		return

	var/mob/living/user = ui.user
	add_fingerprint(user)
	if(code == password)
		status = KEYPAD_STATUS_GRANTED
		used = TRUE
		playsound(src, 'sound/machines/terminal_button07.ogg', 25, TRUE)
		use_button(user, TRUE)
	else
		status = KEYPAD_STATUS_DENIED
		playsound(src, 'sound/machines/buzz-sigh.ogg', 25, TRUE)
		flick(initial(icon_state) + "-denied", src)
	addtimer(CALLBACK(src, PROC_REF(reset_status)), KEYPAD_STATUS_TIME)
	return TRUE

/obj/structure/machinery/door_control/keypad/use_button(mob/living/user, force = FALSE)
	use_power(5)
	switch(normaldoorcontrol)
		if(CONTROL_NORMAL_DOORS)
			handle_door()
		if(CONTROL_POD_DOORS)
			handle_pod()
	desiredstate = !desiredstate

/obj/structure/machinery/door_control/keypad/power_change()
	..()
	icon_state = initial(icon_state) + ((stat & NOPOWER) ? "-p" : "")
	update_glow()

/obj/structure/machinery/door_control/keypad/proc/update_glow()
	if(stat & NOPOWER)
		set_light(0)
		return
	set_light(KEYPAD_LIGHT_RANGE, KEYPAD_LIGHT_POWER)

/obj/structure/machinery/door_control/keypad/proc/reset_status()
	status = (used && single_use) ? KEYPAD_STATUS_LOCKED : KEYPAD_STATUS_IDLE
	SStgui.update_uis(src)

/obj/structure/machinery/door_control/keypad/proc/get_linked_door()
	for(var/obj/structure/machinery/door/poddoor/poddoor in GLOB.machines)
		if(poddoor.id == id)
			return poddoor

/// Controls airlocks (by id_tag) instead of poddoors
/obj/structure/machinery/door_control/keypad/airlock
	name = "keypad door-control"
	normaldoorcontrol = CONTROL_NORMAL_DOORS

/obj/structure/machinery/door_control/keypad/upp
	icon_state = "keypad_panel_upp"
	ui_style = "upp"
	light_color = "#d62c2c"

/obj/structure/machinery/door_control/keypad/airlock/upp
	icon_state = "keypad_panel_upp"
	ui_style = "upp"
	light_color = "#d62c2c"

/// Unbolts and opens the linked airlocks, or closes and bolts them back if they are open
/obj/structure/machinery/door_control/keypad/airlock/handle_door()
	for(var/obj/structure/machinery/door/airlock/airlock in range(range))
		if(airlock.id_tag == id)
			INVOKE_ASYNC(src, PROC_REF(toggle_airlock), airlock)

/obj/structure/machinery/door_control/keypad/airlock/get_linked_door()
	for(var/obj/structure/machinery/door/airlock/airlock in range(range))
		if(airlock.id_tag == id)
			return airlock

/obj/structure/machinery/door_control/keypad/airlock/proc/toggle_airlock(obj/structure/machinery/door/airlock/airlock)
	if(airlock.density)
		airlock.unlock(TRUE)
		airlock.open()
	else if(airlock.close())
		airlock.lock(TRUE)

// Separated airlock type for keypad
/obj/structure/machinery/door/airlock/almayer/secure/reinforced/keypad
	id_tag = "CHANGE ME"

	locked = TRUE
	autoclose = FALSE // would close itself unbolted otherwise
	no_panel = TRUE
	damage_cap = HEALTH_WALL
	unslashable = TRUE
	unacidable = TRUE

/// Paper Prop with password, used for random passwords.
/obj/item/paper/keypad_code
	name = "scribbled note"
	/// id of the keypad
	var/keypad_id = "CHANGE ME"

/obj/item/paper/keypad_code/Initialize(mapload, photo_list)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/paper/keypad_code/LateInitialize()
	. = ..()
	if(isnull(keypad_id))
		return
	for(var/obj/structure/machinery/door_control/keypad/keypad in GLOB.machines)
		if(keypad.id != keypad_id)
			continue
		keypad.resolve_password()
		write_code(keypad)
		update_icon()
		updateinfolinks()
		return

/obj/item/paper/keypad_code/proc/write_code(obj/structure/machinery/door_control/keypad/keypad)
	info = "Door code: <b>[keypad.password]</b>"

/obj/item/paper/keypad_code/proc/write_notice(obj/structure/machinery/door_control/keypad/keypad, logo, organization, department, stamp_state, stamp_owner)
	var/obj/structure/machinery/door/door = keypad.get_linked_door()
	var/area/door_area = get_area(door || keypad)
	var/datum/asset/asset = get_asset_datum(/datum/asset/simple/paper)

	info = "<center><img src = [asset.get_url_mappings()[logo]]><br>"
	info += "<b>[organization]</b><br>"
	info += "<small>[department]</small><hr>"
	info += "<b><large>ACCESS CODE NOTICE</large></b><br>"
	info += "<small>RESTRICTED - AUTHORIZED PERSONNEL ONLY</small></center><hr>"
	info += "<b>Secured entry:</b> [door ? door.name : "unknown"]<br>"
	info += "<b>Location:</b> [door_area ? door_area.name : "unknown"]<br>"
	info += "<b>Lock type:</b> [keypad.name], [length(keypad.password)]-digit code<hr>"
	info += "<center>The access code for the entry listed above is:<br><br>"
	info += "<font face=\"monospace\" size=\"6\"><b>[jointext(splittext(keypad.password, ""), " ")]</b></font></center><hr>"
	info += "<small><i>Do not copy or transmit this code over open channels. Loss of this notice is to be reported to the commanding officer immediately.</i></small>"

	var/image/stampoverlay = image('icons/obj/items/paper.dmi')
	stampoverlay.icon_state = stamp_state
	LAZYADD(stamped, /obj/item/tool/stamp)
	overlays += stampoverlay
	stamps += "<HR><i>This paper has been stamped by the [stamp_owner].</i>"

/// USCM Paper Prop
/obj/item/paper/keypad_code/uscm
	name = "access code notice"
	icon_state = "paper_uscm_words"

/obj/item/paper/keypad_code/uscm/update_icon()
	return

/obj/item/paper/keypad_code/uscm/write_code(obj/structure/machinery/door_control/keypad/keypad)
	write_notice(keypad, "uscmlogo.png", "UNITED STATES COLONIAL MARINE CORPS", "[MAIN_SHIP_NAME] - Security Detachment", "paper_stamp-uscm", "Office of the Commanding Officer")

/// UPP Paper Prop
/obj/item/paper/keypad_code/upp
	name = "access code notice"

/obj/item/paper/keypad_code/upp/write_code(obj/structure/machinery/door_control/keypad/keypad)
	write_notice(keypad, "upplogo.png", "UNION OF PROGRESSIVE PEOPLES", "[MAIN_SHIP_NAME] - Ministry of Space Security", "paper_stamp-upp", "Ministry of Space Security")

#undef KEYPAD_STATUS_IDLE
#undef KEYPAD_STATUS_GRANTED
#undef KEYPAD_STATUS_DENIED
#undef KEYPAD_STATUS_LOCKED
#undef KEYPAD_STATUS_TIME
#undef KEYPAD_LIGHT_RANGE
#undef KEYPAD_LIGHT_POWER
