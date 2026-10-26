/obj/item/device/ruv_controller
	name = "RUV control unit"
	desc = "A rugged hand-held terminal that links to a single RUV and relays its camera feed. Use it on an RUV to link them. Whoever holds it can give the RUV orders."
	icon = 'core_ru/icons/ruv.dmi'
	icon_state = "control_device"
	w_class = SIZE_SMALL
	var/mob/living/simple_animal/ruv/linked_bot

/obj/item/device/ruv_controller/Destroy()
	unlink_bot()
	return ..()

/obj/item/device/ruv_controller/get_examine_text(mob/user)
	. = ..()
	if(linked_bot)
		. += SPAN_NOTICE("It is linked to [SPAN_GREEN("<b>[strip_improper(linked_bot.name)]</b>")].")
	else
		. += SPAN_NOTICE("It is [SPAN_ORANGE("<b>not linked</b>")] to any RUV.")
	. += SPAN_HELPFUL("Use it on an RUV to link them. While you hold it in hand, its buttons switch the RUV between manual and automatic mode and give it orders. Use it in hand to look through the RUV's camera and drive it.")

/obj/item/device/ruv_controller/attack_self(mob/user)
	..()
	if(!ishuman(user))
		return
	if(!linked_bot)
		to_chat(user, SPAN_WARNING("[src] isn't linked to any RUV. Use it on an RUV to link them."))
		return
	if(linked_bot.operator == user)
		linked_bot.disconnect()
		return
	update_commander(user)
	linked_bot.try_connect(user)

/obj/item/device/ruv_controller/equipped(mob/user, slot, silent)
	. = ..()
	update_commander(user)

/obj/item/device/ruv_controller/dropped(mob/user)
	. = ..()
	update_commander(user)

/// Whoever holds the linked unit in hand commands the RUV
/obj/item/device/ruv_controller/proc/update_commander(mob/user)
	if(!linked_bot)
		return
	if(ishuman(user) && (user.l_hand == src || user.r_hand == src))
		linked_bot.set_commander(user)
	else if(linked_bot.commander == user)
		linked_bot.clear_commander()

/obj/item/device/ruv_controller/proc/link_bot(mob/living/simple_animal/ruv/bot, mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(bot.stat == DEAD)
		to_chat(user, SPAN_WARNING("[bot] is wrecked."))
		return
	if(linked_bot == bot)
		to_chat(user, SPAN_NOTICE("[src] is already linked to [bot]."))
		return
	if(bot.operator)
		to_chat(user, SPAN_WARNING("[bot] is being controlled right now."))
		return
	unlink_bot()
	bot.controller?.unlink_bot()
	linked_bot = bot
	bot.controller = src
	bot.set_faction_from(user)
	RegisterSignal(bot, COMSIG_PARENT_QDELETING, PROC_REF(on_bot_deleted))
	playsound(loc, 'sound/machines/twobeep.ogg', 25, TRUE)
	to_chat(user, SPAN_NOTICE("You link [src] to [bot]. It now recognizes your friends as its own."))
	update_commander(user)

/obj/item/device/ruv_controller/proc/unlink_bot()
	if(!linked_bot)
		return
	UnregisterSignal(linked_bot, COMSIG_PARENT_QDELETING)
	if(linked_bot.controller == src)
		linked_bot.clear_commander()
		linked_bot.controller = null
	linked_bot = null

/obj/item/device/ruv_controller/proc/on_bot_deleted()
	SIGNAL_HANDLER
	unlink_bot()

// The commander gives orders, the operator also looks through the camera and drives

/mob/living/simple_animal/ruv/proc/set_commander(mob/living/carbon/human/user)
	if(commander == user)
		return
	clear_commander()
	commander = user
	RegisterSignal(user, COMSIG_MOB_PRE_CLICK, PROC_REF(on_commander_click))
	RegisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(on_commander_deleted))
	update_commander_actions()
	update_order_marker()

/mob/living/simple_animal/ruv/proc/clear_commander()
	if(!commander)
		return
	disconnect()
	hide_order_marker()
	var/mob/living/carbon/human/user = commander
	commander = null
	pending_order = null
	UnregisterSignal(user, list(COMSIG_MOB_PRE_CLICK, COMSIG_PARENT_QDELETING))
	QDEL_LIST(commander_actions)

/mob/living/simple_animal/ruv/proc/on_commander_deleted()
	SIGNAL_HANDLER
	clear_commander()

/mob/living/simple_animal/ruv/proc/try_connect(mob/living/carbon/human/user)
	if(commander != user)
		return
	if(operator)
		to_chat(user, SPAN_WARNING("Someone else is already controlling [src]."))
		return
	if(stat == DEAD || z != user.z)
		to_chat(user, SPAN_WARNING("[controller] can't find [src]'s signal."))
		return
	if(!has_power())
		to_chat(user, SPAN_WARNING("[src] doesn't respond. Its battery must be dead."))
		return
	connect(user)

/mob/living/simple_animal/ruv/proc/connect(mob/living/carbon/human/user)
	operator = user
	RegisterSignal(user, COMSIG_CLIENT_MOB_MOVE, PROC_REF(on_operator_move))
	RegisterSignal(user, COMSIG_MOB_RESET_VIEW, PROC_REF(on_operator_reset_view))
	RegisterSignal(user, list(COMSIG_MOB_TAKE_DAMAGE, COMSIG_HUMAN_TAKE_DAMAGE), PROC_REF(on_operator_damaged))
	RegisterSignal(user, list(COMSIG_MOB_DEATH, COMSIG_MOB_LOGOUT, COMSIG_MOB_GHOSTIZE), PROC_REF(on_operator_lost))
	user.reset_view()
	apply_terminal_view(user)
	status_display.place_for(user)
	update_commander_actions()
	update_status_display()
	user.client?.add_to_screen(status_display)
	playsound(user, 'sound/machines/terminal_on.ogg', 25, TRUE)
	to_chat(user, SPAN_NOTICE("You connect to [src]. Move to drive it and click to use its module."))

/mob/living/simple_animal/ruv/proc/disconnect()
	if(!operator)
		return
	var/mob/living/carbon/human/user = operator
	operator = null
	UnregisterSignal(user, list(
		COMSIG_CLIENT_MOB_MOVE,
		COMSIG_MOB_RESET_VIEW,
		COMSIG_MOB_TAKE_DAMAGE,
		COMSIG_HUMAN_TAKE_DAMAGE,
		COMSIG_MOB_DEATH,
		COMSIG_MOB_LOGOUT,
		COMSIG_MOB_GHOSTIZE,
	))
	remove_terminal_view(user)
	user.client?.remove_from_screen(status_display)
	user.reset_view()
	update_commander_actions()
	to_chat(user, SPAN_NOTICE("You disconnect from [src]."))

/mob/living/simple_animal/ruv/proc/on_operator_lost()
	SIGNAL_HANDLER
	disconnect()

/mob/living/simple_animal/ruv/proc/on_operator_damaged(mob/user, list/damage_data, damagetype)
	SIGNAL_HANDLER
	if(damage_data["damage"] > 5)
		to_chat(user, SPAN_WARNING("The pain jolts you out of [src]'s camera feed!"))
		disconnect()

/mob/living/simple_animal/ruv/proc/on_operator_reset_view(mob/user, atom/focus)
	SIGNAL_HANDLER
	if(user.client)
		user.client.perspective = EYE_PERSPECTIVE
		user.client.eye = src
	return COMPONENT_OVERRIDE_VIEW

/mob/living/simple_animal/ruv/proc/on_operator_move(mob/user, new_loc, direction)
	SIGNAL_HANDLER
	if(user.is_mob_incapacitated())
		disconnect()
		return
	if(mode == RUV_MODE_MANUAL)
		INVOKE_ASYNC(src, PROC_REF(try_step), direction)
	return COMPONENT_OVERRIDE_MOVE

/mob/living/simple_animal/ruv/proc/on_commander_click(mob/user, atom/target, list/mods)
	SIGNAL_HANDLER
	// Without the camera feed only a click that picks an order's target is taken
	if(operator != user && !pending_order)
		return NONE
	// The commander's own HUD and inventory still work, and examining is left alone
	if(!isturf(target) && !isturf(target.loc) || mods[SHIFT_CLICK])
		return NONE
	INVOKE_ASYNC(src, PROC_REF(handle_commander_click), user, target, mods)
	return COMPONENT_INTERRUPT_CLICK

/mob/living/simple_animal/ruv/proc/handle_commander_click(mob/living/carbon/human/user, atom/target, list/mods)
	if(stat == DEAD || user.is_mob_incapacitated())
		return

	if(pending_order)
		var/new_order = pending_order
		pending_order = null
		refresh_order_buttons()
		if(target == src)
			to_chat(user, SPAN_NOTICE("Order cancelled."))
			return
		var/obj/item/ruv_module/arm/arm_module = module
		if(new_order == RUV_ORDER_INTERACT && (!istype(arm_module) || !arm_module.can_interact_with(target)))
			to_chat(user, SPAN_WARNING("There is nothing there for [src] to grab or use."))
			return
		set_order(new_order, target, user)
		return

	if(mode == RUV_MODE_AUTO)
		to_chat(user, SPAN_WARNING("[src] is in automatic mode. Give it an order, or switch it to manual control."))
		return

	if(target == src)
		release_grab()
		return
	if(!has_power())
		to_chat(user, SPAN_WARNING("[src] doesn't respond. Its battery is dead."))
		return

	if(istype(module, /obj/item/ruv_module/sentry))
		var/obj/item/ruv_module/sentry/sentry_module = module
		sentry_module.fire(target, src)
		return

	if(istype(module, /obj/item/ruv_module/arm))
		var/obj/item/ruv_module/arm/arm_module = module
		if(pulling && pulling == target)
			release_grab()
			return
		if(!Adjacent(target))
			return
		if(mods[CTRL_CLICK])
			arm_module.use_on(target, src, pull_only = TRUE)
			return
		if(user.a_intent == INTENT_HARM && isliving(target))
			arm_module.strike(target, src)
			return
		arm_module.use_on(target, src)

/mob/living/simple_animal/ruv/proc/release_grab()
	if(!pulling)
		return
	var/atom/movable/released = pulling
	stop_pulling()
	if(commander)
		to_chat(commander, SPAN_NOTICE("[src] lets go of [released]."))

// Terminal view

/atom/movable/screen/fullscreen/ruv_scanlines
	icon = 'core_ru/icons/ruv.dmi'
	icon_state = "scanlines"
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	appearance_flags = NONE

/mob/living/simple_animal/ruv/proc/apply_terminal_view(mob/user)
	/// Monochrome green, like an old phosphor screen
	var/static/list/terminal_matrix = list(
		0.045, 0.33, 0.105,
		0.0885, 0.65, 0.2065,
		0.0165, 0.12, 0.0385,
		0, 0.04, 0.01,
	)
	user.overlay_fullscreen("ruv", /atom/movable/screen/fullscreen/ruv_scanlines)
	var/atom/movable/screen/plane_master/game_plate = user.hud_used?.plane_masters["[RENDER_PLANE_GAME]"]
	game_plate?.add_filter("ruv_terminal", 2, color_matrix_filter(terminal_matrix))

/mob/living/simple_animal/ruv/proc/remove_terminal_view(mob/user)
	user.clear_fullscreen("ruv", 0)
	var/atom/movable/screen/plane_master/game_plate = user.hud_used?.plane_masters["[RENDER_PLANE_GAME]"]
	game_plate?.remove_filter("ruv_terminal")

// Status display

/atom/movable/screen/ruv_status
	name = "RUV status"
	icon = 'core_ru/icons/ruv.dmi'
	icon_state = "status_bar"
	screen_loc = "EAST,NORTH"

/// Puts the display right above the beacon tracker, wherever the viewer's HUD style keeps it
/atom/movable/screen/ruv_status/proc/place_for(mob/user)
	screen_loc = initial(screen_loc)
	var/locator_loc = user.hud_used?.ui_datum?.UI_SL_LOCATOR_LOC
	if(!locator_loc)
		return
	var/list/coords = splittext(locator_loc, ",")
	if(length(coords) != 2)
		return
	var/list/y_parts = splittext(coords[2], ":")
	var/locator_y = text2num(y_parts[1])
	if(isnull(locator_y))
		return
	y_parts[1] = "[locator_y + 1]"
	screen_loc = "[coords[1]],[jointext(y_parts, ":")]"

/atom/movable/screen/ruv_status/proc/update(health_percent, charge_percent)
	overlays.Cut()
	add_number(health_percent, 17)
	add_number(charge_percent, 8)

/// The status bar has two digit slots per row, so the value tops out at 99
/atom/movable/screen/ruv_status/proc/add_number(value, offset_y)
	value = clamp(floor(value), 0, 99)
	var/image/tens = image(icon, "num[floor(value / 10)]")
	tens.pixel_x = 13
	tens.pixel_y = offset_y
	var/image/ones = image(icon, "num[value % 10]")
	ones.pixel_x = 18
	ones.pixel_y = offset_y
	overlays += tens
	overlays += ones

/mob/living/simple_animal/ruv/proc/update_status_display()
	if(!operator || !status_display)
		return
	status_display.update(health / maxHealth * 100, cell ? cell.percent() : 0)

// Order marker

/// Brackets around the order's target, seen only by the commander
/mob/living/simple_animal/ruv/proc/update_order_marker()
	hide_order_marker()
	var/atom/target = order_target_ref?.resolve()
	if(!target || target == commander || mode != RUV_MODE_AUTO || !commander?.client)
		return
	order_marker = image(icon, target, "order_marker", ABOVE_FLY_LAYER)
	order_marker.plane = ABOVE_GAME_PLANE
	order_marker.appearance_flags = RESET_COLOR|RESET_TRANSFORM|RESET_ALPHA|KEEP_APART
	commander.client.images += order_marker

/mob/living/simple_animal/ruv/proc/hide_order_marker()
	if(!order_marker)
		return
	commander?.client?.images -= order_marker
	order_marker = null

// Commander actions

/mob/living/simple_animal/ruv/proc/update_commander_actions()
	QDEL_LIST(commander_actions)
	if(!commander)
		return
	var/list/action_types = list(/datum/action/ruv/connection, /datum/action/ruv/toggle_mode, /datum/action/ruv/order/stop)
	if(mode == RUV_MODE_AUTO)
		action_types += list(/datum/action/ruv/order/follow, /datum/action/ruv/order/attack)
		if(istype(module, /obj/item/ruv_module/arm))
			action_types += /datum/action/ruv/order/interact
	for(var/action_type in action_types)
		var/datum/action/ruv/action = new action_type
		action.bot = src
		action.give_to(commander)
		action.update_button_icon()
		commander_actions += action

/mob/living/simple_animal/ruv/proc/refresh_order_buttons()
	for(var/datum/action/ruv/order/action in commander_actions)
		action.update_button_icon()

/datum/action/ruv
	icon_file = 'core_ru/icons/ruv.dmi'
	button_icon_state = "order_frame_empty"
	var/mob/living/simple_animal/ruv/bot

/datum/action/ruv/New(Target, override_icon_state)
	. = ..()
	button.icon = icon_file

/datum/action/ruv/Destroy()
	bot = null
	return ..()

/datum/action/ruv/can_use_action()
	return ..() && bot && bot.commander == owner && !owner.is_mob_incapacitated()

/datum/action/ruv/connection
	name = "Connect to the RUV"
	action_icon_state = "order+connect"

/datum/action/ruv/connection/update_button_icon()
	var/connected = bot && owner && bot.operator == owner
	set_name(connected ? "Disconnect from the RUV" : "Connect to the RUV")
	button.overlays.Cut()
	button.overlays += image(icon_file, button, connected ? "order+disconnect" : "order+connect")

/datum/action/ruv/connection/action_activate()
	. = ..()
	if(!can_use_action())
		return
	if(bot.operator == owner)
		bot.disconnect()
	else
		bot.try_connect(owner)

/datum/action/ruv/toggle_mode
	name = "Switch to Automatic Mode"
	action_icon_state = "order+auto"

/datum/action/ruv/toggle_mode/update_button_icon()
	var/auto = bot?.mode == RUV_MODE_AUTO
	set_name(auto ? "Switch to Manual Control" : "Switch to Automatic Mode")
	button.overlays.Cut()
	button.overlays += image(icon_file, button, auto ? "order+manual" : "order+auto")

/datum/action/ruv/toggle_mode/action_activate()
	. = ..()
	if(can_use_action())
		bot.toggle_mode()

/datum/action/ruv/order
	var/order

/datum/action/ruv/order/update_button_icon()
	if(!bot)
		return
	if(bot.pending_order == order)
		button.icon_state = "order_frame_pending"
	else if(bot.order == order && bot.mode == RUV_MODE_AUTO)
		button.icon_state = "order_frame_active"
	else
		button.icon_state = "order_frame_empty"

/datum/action/ruv/order/action_activate()
	. = ..()
	if(can_use_action())
		bot.select_order(order)

/// Drops whatever the RUV is doing, in either mode: walking, shooting, dragging, a target being picked
/datum/action/ruv/order/stop
	name = "Stop"
	action_icon_state = "order+hold"
	order = RUV_ORDER_HOLD

/datum/action/ruv/order/follow
	name = "Order: Follow Me"
	action_icon_state = "order+follow"
	order = RUV_ORDER_FOLLOW

/datum/action/ruv/order/attack
	name = "Order: Attack"
	action_icon_state = "order+attack"
	order = RUV_ORDER_ATTACK

/datum/action/ruv/order/interact
	name = "Order: Grab or Use"
	action_icon_state = "order+interact"
	order = RUV_ORDER_INTERACT
