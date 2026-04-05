#define LADDER_LOCKED 0
#define LADDER_UNLOCKED 1
#define LADDER_OPEN 2
#define WATCHING_NOTHING 0
#define WATCHING_BELOW 1
#define WATCHING_ABOVE 2

/obj/structure/ladder
	name = "ladder"
	desc = "A sturdy metal ladder."
	icon = 'icons/obj/structures/ladders.dmi'
	icon_state = "ladder11"
	/// Used to link up ladders that are above and below
	var/id = null
	/// The 'height' of the ladder. higher numbers are considered physically higher
	var/height = 0
	/// The ladder below this one
	var/obj/structure/ladder/down
	/// The ladder above this one
	var/obj/structure/ladder/up
	anchored = TRUE
	unslashable = TRUE
	unacidable = TRUE
	layer = LADDER_LAYER
	var/state = LADDER_OPEN //For hatch ladders. Other ladders are always open.
	var/is_watching = WATCHING_NOTHING
	var/obj/structure/machinery/camera/cam
	/// Ladders are wonderful creatures, only one person can use it at a time
	var/busy = FALSE
	var/static/list/direction_selection = list("up" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_ladder_up"), "down" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_ladder_down"))
	/// Slop
	var/climb_time = 2 SECONDS
	var/climb_sound = null

/obj/structure/ladder/Initialize(mapload, ...)
	. = ..()
	cam = new /obj/structure/machinery/camera(src)
	cam.network = list(CAMERA_NET_LADDER)
	cam.c_tag = name

	GLOB.ladder_list += src
	return INITIALIZE_HINT_LATELOAD

/obj/structure/ladder/get_examine_text(mob/user)
	. = ..()
	. += SPAN_NOTICE("Drag-click to look up or down [src].")
	. += SPAN_NOTICE("Ctrl-click to go up, Alt-click to go down.")
	if(ishuman(user))
		. += SPAN_NOTICE("Click [src] with unprimed grenades/flares to prime and toss it up or down.")
		. += SPAN_NOTICE("Ctrl-click or Alt-click with grenades/flares to throw in that direction.")

//If we drop ladders down, only need to run the proc on the middle ladder to connect three. Or any of two ladders.
/obj/structure/ladder/LateInitialize()
	. = ..()

	if(id) //Don't need to run this if there is no ID.
		for(var/obj/structure/ladder/other_ladder as anything in GLOB.ladder_list)
			if(up && down)
				break //If both our connections are filled; we are done.

			if(other_ladder.id == id)
				switch(other_ladder.height - height)
					if(-1)
						if(!down)
							down = other_ladder //Only if the connection isn't established yet.
						if(!other_ladder.up)
							other_ladder.up = src
							other_ladder.update_icon()
					if(1)
						if(!up)
							up = other_ladder
						if(!other_ladder.down)
							other_ladder.down = src
							other_ladder.update_icon()
	update_icon() //Update the icon regardless.

/obj/structure/ladder/Destroy()
	if(istype(down))
		down.up = null
		down.update_icon()
	if(istype(up))
		up.down = null
		up.update_icon()
	down = null
	up = null
	QDEL_NULL(cam)
	GLOB.ladder_list -= src
	return ..()

/obj/structure/ladder/update_icon()
	icon_state = "ladder[up ? 1 : 0][down ? 1 : 0]"

/obj/structure/ladder/attack_hand(mob/living/user)
	if(user.stat || get_dist(user, src) > 1 || user.blinded || user.body_position == LYING_DOWN || user.buckled || user.anchored)
		return
	if(busy)
		to_chat(user, SPAN_WARNING("Someone else is currently using [src]."))
		return

	if(state == LADDER_LOCKED) //Can't descend if it's locked.
		to_chat(user, SPAN_WARNING("It appears to be locked and bolted!"))
		return

	if(open_hatch(user))
		return //If it's closed and unlocked, we need to first pop it open, then we can climb in.

	var/direction
	if(up && down)
		var/choice = lowertext(show_radial_menu(user, src, direction_selection, require_near = TRUE))
		if(choice == "up")
			direction = "up"
		else if(choice == "down")
			direction = "down"
		else
			return //User cancelled or invalid choice
	else if(up)
		direction = "up"
	else if(down)
		direction = "down"
	else
		return FALSE //No valid directions

	climb_ladder(user, direction)

//Helper function to handle climbing logic for both manual clicks and modifier clicks
/obj/structure/ladder/proc/climb_ladder(mob/living/user, direction)
	if(user.stat || get_dist(user, src) > 1 || user.blinded || user.body_position == LYING_DOWN || user.buckled || user.anchored)
		return FALSE
	if(busy)
		to_chat(user, SPAN_WARNING("Someone else is currently using [src]."))
		return FALSE

	var/ladder_dir_name
	var/obj/structure/ladder/ladder_dest

	if(direction == "up")
		if(!up)
			return FALSE
		ladder_dir_name = "up"
		ladder_dest = up
	else if(direction == "down")
		if(!down)
			return FALSE
		ladder_dir_name = "down"
		ladder_dest = down
	else
		return FALSE

	if(!ladder_dest)
		return FALSE

	step(user, get_dir(user, src))
	user.visible_message(SPAN_NOTICE("[user] starts climbing [ladder_dir_name] [src]."),
	SPAN_NOTICE("You start climbing [ladder_dir_name] [src]."))
	if(climb_sound)
		playsound(src, climb_sound, 100)
	busy = TRUE
	if(do_after(user, climb_time, INTERRUPT_INCAPACITATED|INTERRUPT_OUT_OF_RANGE|INTERRUPT_RESIST, BUSY_ICON_GENERIC, src, INTERRUPT_NONE))
		if(!user.is_mob_incapacitated() && get_dist(user, src) <= 1 && !user.blinded && user.body_position != LYING_DOWN && !user.buckled && !user.anchored)
			if(ladder_dest.state == LADDER_LOCKED) //The ladder they are climbing to is a hatch and is locked.
				to_chat(user, SPAN_WARNING("There is a bolted hatch blocking your progress!"))
			else if(state <= LADDER_UNLOCKED) //The ladder hatch somehow closed while they were climbing. Shouldn't happen, but can happen.
				to_chat(user, SPAN_WARNING("The hatch suddenly closed before you could climb it!"))
			else
				visible_message(SPAN_NOTICE("[user] climbs [ladder_dir_name] [src].")) //Hack to give a visible message to the people here without duplicating user message
				user.visible_message(SPAN_NOTICE("[user] climbs [ladder_dir_name] [src]."),
				SPAN_NOTICE("You climb [ladder_dir_name] [src]."))
				user.trainteleport(ladder_dest.loc)
				if(!ladder_dest.open_hatch(user))
					ladder_dest.add_fingerprint(user) //Fingerprints are added by the open proc, elsewise we add them here.

	busy = FALSE
	add_fingerprint(user)
	if(ladder_dest.up && ladder_dest.down) // Make sure it has a up and down before opening the radial wheel, otherwise it sends you
		ladder_dest.attack_hand(user)
	return TRUE

//Alt click to go down
/obj/structure/ladder/proc/alt_click_action(mob/user)
	if(!isliving(user))
		return
	if(state == LADDER_LOCKED) //The ladder they are climbing to is a hatch and is locked.
		to_chat(user, SPAN_WARNING("There is a bolted hatch blocking your progress!"))
		return
	climb_ladder(user, "down")

//Ctrl click to go up
/obj/structure/ladder/proc/ctrl_click_action(mob/user)
	if(!isliving(user))
		return
	if(state == LADDER_LOCKED) //The ladder they are climbing to is a hatch and is locked.
		to_chat(user, SPAN_WARNING("There is a bolted hatch blocking your progress!"))
		return
	climb_ladder(user, "up")

//Shift click to go up
/obj/structure/ladder/proc/shift_click_action(mob/user)
	if(!isliving(user))
		return
	if(get_dist(user, src) > 1)
		return
	if(state == LADDER_LOCKED) //The ladder they are climbing to is a hatch and is locked.
		to_chat(user, SPAN_WARNING("There is a bolted hatch blocking your progress!"))
		return
	close_hatch(user)

//Override clicked to handle modifier clicks
/obj/structure/ladder/clicked(mob/user, list/mods)
	// If user is holding a throwable item, let attackby handle the modifier clicks
	if(isliving(user))
		var/mob/living/living_user = user
		var/obj/item/held_item = living_user.get_active_hand()
		if(held_item && (istype(held_item, /obj/item/explosive/grenade) || istype(held_item, /obj/item/device/flashlight)))
			return FALSE // Let attackby handle this

	if(mods[ALT_CLICK])
		alt_click_action(user)
		return TRUE
	if(mods[CTRL_CLICK])
		ctrl_click_action(user)
		return TRUE
	if(mods[SHIFT_CLICK])
		shift_click_action(user)
		return TRUE
	return ..()

/obj/structure/ladder/check_eye(mob/living/user)
	//Are we capable of looking?
	if(user.is_mob_incapacitated() || get_dist(user, src) > 1 || user.blinded || user.body_position == LYING_DOWN || !user.client)
		user.unset_interaction()
		return

	//Are ladder cameras ok?
	switch(is_watching)
		if(WATCHING_BELOW)
			if(state < LADDER_OPEN || !down || !down.cam || !down.cam.can_use()) //Watching below but we don't have a ladder, the ladder is not open, etc.
				user.unset_interaction()

		if(WATCHING_ABOVE)
			if(!up || up.state < LADDER_OPEN || !up.cam || !up.cam.can_use()) //Watching above but either it's a closed hatch or cams are gone, etc.
				user.unset_interaction()

/obj/structure/ladder/on_set_interaction(mob/user)
	switch(is_watching)
		if(WATCHING_BELOW)
			if(istype(down) && down.cam && down.cam.can_use()) //Camera works
				user.reset_view(down.cam)
				return

		if(WATCHING_ABOVE)
			if (istype(up) && up.cam && up.cam.can_use())
				user.reset_view(up.cam)
				return

	user.unset_interaction() //No usable cam, we stop interacting right away

/obj/structure/ladder/on_unset_interaction(mob/user)
	..()
	is_watching = WATCHING_NOTHING
	user.reset_view(null)

/obj/structure/ladder/proc/handle_move(mob/moved_mob, oldLoc, direct)
	SIGNAL_HANDLER
	moved_mob.unset_interaction()
	UnregisterSignal(moved_mob, COMSIG_MOVABLE_MOVED)

//Peeking up/down
/obj/structure/ladder/MouseDrop(over_object, src_location, over_location, mob/user)
	//Are we capable of looking?
	if(usr.is_mob_incapacitated() || get_dist(usr, src) > 1 || usr.blinded || !usr.client)
		return


	if(isliving(usr))
		var/mob/living/living_usr = usr
		if(living_usr.body_position == LYING_DOWN)
			return

	if(up && up.state < LADDER_OPEN)
		to_chat(usr, SPAN_WARNING("You try to peer up, but the hatch above is closed."))
		return

	if(down && down.state < LADDER_OPEN)
		to_chat(usr, SPAN_WARNING("You try to peer down, but the hatch below is closed."))
		return

	var/obj/structure/ladder/looking_at
	if(up && down)
		looking_at = lowertext(show_radial_menu(usr, src, direction_selection, require_near = TRUE))
		if(looking_at == "up")
			looking_at = up
			is_watching = WATCHING_ABOVE
			usr.visible_message(SPAN_NOTICE("[usr] looks up [src]!"),
			SPAN_NOTICE("You look up [src]!"))
			RegisterSignal(usr, COMSIG_MOVABLE_MOVED, PROC_REF(handle_move))
			usr.set_interaction(src)
		if(looking_at == "down")
			looking_at = down
			is_watching = WATCHING_BELOW
			usr.visible_message(SPAN_NOTICE("[usr] looks down [src]!"), SPAN_NOTICE("You look down [src]!"))
			RegisterSignal(usr, COMSIG_MOVABLE_MOVED, PROC_REF(handle_move))
			usr.set_interaction(src)
	else if(up)
		looking_at = up
		is_watching = WATCHING_ABOVE
		usr.visible_message(SPAN_NOTICE("[usr] looks up [src]!"),
		SPAN_NOTICE("You look up [src]!"))
		RegisterSignal(usr, COMSIG_MOVABLE_MOVED, PROC_REF(handle_move))
		usr.set_interaction(src)
	else if(down)
		looking_at = down
		is_watching = WATCHING_BELOW
		usr.visible_message(SPAN_NOTICE("[usr] looks down [src]!"),
		SPAN_NOTICE("You look down [src]!"))
		RegisterSignal(usr, COMSIG_MOVABLE_MOVED, PROC_REF(handle_move))
		usr.set_interaction(src)
	else
		return FALSE //just in case

	if(!looking_at)
		return

	add_fingerprint(usr)

/obj/structure/ladder/ex_act(severity)
	return

//Helper function to handle throwing items up/down ladders
/obj/structure/ladder/proc/throw_item_ladder(obj/item/item, mob/user, direction)
	var/ladder_dir_name
	var/obj/structure/ladder/ladder_dest

	if(direction == "up")
		if(!up)
			return FALSE
		ladder_dir_name = "up"
		ladder_dest = up
	else if(direction == "down")
		if(!down)
			return FALSE
		ladder_dir_name = "down"
		ladder_dest = down
	else
		return FALSE

	if(!ladder_dest)
		return FALSE

	// Handle grenade-specific logic
	if(istype(item, /obj/item/explosive/grenade))
		var/obj/item/explosive/grenade/G = item
		if(G.antigrief_protection && user.faction == FACTION_MARINE && explosive_antigrief_check(G, user))
			to_chat(user, SPAN_WARNING("\The [G.name]'s safe-area accident inhibitor prevents you from priming the grenade!"))
			msg_admin_niche("[key_name(user)] attempted to prime \a [G.name] in [get_area(src)] [ADMIN_JMP(src.loc)]")
			return FALSE

	user.visible_message(SPAN_WARNING("[user] takes position to throw [item] [ladder_dir_name] [src]."),
	SPAN_WARNING("You take position to throw [item] [ladder_dir_name] [src]."))

	if(do_after(user, 10, INTERRUPT_ALL, BUSY_ICON_HOSTILE))
		user.visible_message(SPAN_WARNING("[user] throws [item] [ladder_dir_name] [src]!"),
		SPAN_WARNING("You throw [item] [ladder_dir_name] [src]"))
		user.drop_held_item()
		item.forceMove(ladder_dest.loc)
		item.setDir(pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
		step_away(item, src, rand(1, 5))

		// Handle grenade activation
		if(istype(item, /obj/item/explosive/grenade))
			var/obj/item/explosive/grenade/G = item
			if(!G.active)
				G.activate(user)

		// Handle flare activation
		if(istype(item, /obj/item/device/flashlight/flare))
			var/obj/item/device/flashlight/flare/the_flare = item
			if(!the_flare.on)
				the_flare.turn_on()

	return TRUE

//Throwing Shiet
/obj/structure/ladder/attackby(obj/item/W, mob/user, list/mods)
	if(state < LADDER_OPEN)
		return //Can't drop anything if it's closed. Maybe this will change if grate hatches are added.

	// Check if this is a throwable item (grenades or flashlights)
	if(!istype(W, /obj/item/explosive/grenade) && !istype(W, /obj/item/device/flashlight))
		return attack_hand(user)

	var/direction

	// Check for modifier keys first
	if(mods && mods[CTRL_CLICK] && up)
		direction = "up"
	else if(mods && mods[ALT_CLICK] && down)
		direction = "down"
	// If no modifier or invalid direction, use menu/auto-select
	else if(up && down)
		var/choice = lowertext(show_radial_menu(user, src, direction_selection, require_near = TRUE))
		if(choice == "up")
			direction = "up"
		else if(choice == "down")
			direction = "down"
		else
			return // User cancelled
	else if(up)
		direction = "up"
	else if(down)
		direction = "down"
	else
		return FALSE // No valid directions

	// Use the helper function to throw the item
	throw_item_ladder(W, user, direction)

/obj/structure/ladder/fragile_almayer //goes away on hijack
	name = "rickety ladder"
	desc = "A slightly less stable-looking ladder, installed out of dry dock by some enterprising maintenance tech. Looks like it could collapse at any moment."

/obj/structure/ladder/fragile_almayer/Initialize()
	. = ..()

/obj/structure/ladder/fragile_almayer/Destroy()
	return ..()

/obj/structure/ladder/fragile_almayer/deconstruct()
	new /obj/structure/prop/broken_ladder(loc)
	return ..()

/obj/structure/prop/broken_ladder
	name = "rickety ladder"
	desc = "Well, it was only a matter of time."
	icon = 'icons/obj/structures/ladders.dmi'
	icon_state = "ladder00"
	anchored = TRUE
	unslashable = TRUE
	unacidable = TRUE
	layer = LADDER_LAYER

/obj/structure/ladder/multiz/LateInitialize()
	. = ..()

	up = locate(/obj/structure/ladder) in SSmapping.get_turf_above(get_turf(src))
	down = locate(/obj/structure/ladder) in SSmapping.get_turf_below(get_turf(src))

	update_icon()

//======== hatch-style ladder ===============
//These can be used in the future for grates and sewer entrances and such. Might need a few slight adjustments if that happens.

/obj/structure/ladder/hatch
	name = "locked hatch"
	desc = "A tightly closed hatch. It is currently locked and bolted, and cannot be opened."
	icon_state = "ladder_hatch0"
	state = LADDER_LOCKED
	pixel_y = 10 //Offset it up more.

/obj/structure/ladder/hatch/update_icon()
	icon_state = "ladder_hatch[state]"

/*
The following procs are made general as to cut down on type checking, since it's not really needed. Could make them children specific to hatch, but it should never come up.
If that changes, may need a slight refactor.
*/
/obj/structure/ladder/proc/toggle_lock(trigger_signal)
	if(!unlock_hatch(trigger_signal))
		lock_hatch(trigger_signal) //If it doesn't match the first one, we will do the second.

/obj/structure/ladder/proc/unlock_hatch(trigger_signal)
	if(state == LADDER_LOCKED && trigger_signal == id)
		name = "unlocked hatch"
		desc = "A tightly closed hatch. It has been unlocked and can now be opened."
		state = LADDER_UNLOCKED
		playsound(src, 'sound/effects/industrial_buzzer.ogg', 25, FALSE)
		update_icon()
		return TRUE

/obj/structure/ladder/proc/lock_hatch(trigger_signal)
	if(state > LADDER_LOCKED && trigger_signal == id)
		if(state == LADDER_OPEN)
			visible_message(SPAN_NOTICE("[src] closes!"), SPAN_NOTICE("Something closes nearby!"))
			playsound(src, 'sound/effects/hydraulic_close.ogg', 25, FALSE)
		name = initial(name)
		desc = initial(desc)
		state = LADDER_LOCKED
		playsound(src, 'sound/effects/industrial_buzzer.ogg', 25, FALSE)
		update_icon()
		return TRUE

/obj/structure/ladder/proc/open_hatch(mob/living/user)
	if(state == LADDER_UNLOCKED)
		if(user)
			user.visible_message(SPAN_NOTICE("[user] opens [src]."), SPAN_NOTICE("You open [src]."), SPAN_NOTICE("Something swings open nearby,"))
			add_fingerprint(user)
		else
			visible_message(SPAN_NOTICE("[src] swings open."), SPAN_NOTICE("Something swings open nearby,"))

		playsound(src, 'sound/effects/metal_open.ogg', 25, FALSE)
		name = "ladder hatch"
		desc = "A hatch with a metal ladder leading somewhere below."
		state = LADDER_OPEN
		update_icon()
		return TRUE

/obj/structure/ladder/proc/close_hatch()
	if(state == LADDER_OPEN)
		visible_message(SPAN_NOTICE("[src] closes!"), SPAN_NOTICE("Something closes nearby!"))
		playsound(src, 'sound/effects/hydraulic_close.ogg', 25, FALSE)
		name = "unlocked hatch"
		desc = "A tightly closed hatch. It has been unlocked and can now be opened."
		state = LADDER_UNLOCKED
		update_icon()
		return TRUE

/obj/structure/ladder/proc/toggle_hatch()
	if(!open_hatch())
		close_hatch()

//==============================================

/obj/structure/ladder/yautja
	name = "ladder"
	desc = "A sturdy metal ladder, made from an unknown metal, adorned with glowing runes."
	icon = 'icons/obj/structures/machinery/yautja_machines.dmi'

/obj/structure/ladder/rope
	name = "rope"
	desc = "A sturdy rope."
	icon = 'icons/obj/structures/props/almayer_props.dmi'
	icon_state = "rope"

/obj/structure/ladder/rope/update_icon()
	return

/obj/structure/ladder/maintenance
	name = "maintenance ladder"
	desc = "The hatch itself is the door to the underground. Though it looks like it the hatch itself is light enough to not be an issue!"
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "hatchclosed"
	color = "#666633"
	pixel_y = 7

/obj/structure/ladder/maintenance/update_icon()
	return

/obj/structure/ladder/tall
	name = "exceptionally long ladder"
	desc = "A very long metal ladder. Looks like it would take a while to climb."
	//climb_time = 30 SECONDS
	//climb_sound = 'sound/machines/long_ladder.ogg'

#undef LADDER_LOCKED
#undef LADDER_UNLOCKED
#undef LADDER_OPEN
#undef WATCHING_NOTHING
#undef WATCHING_BELOW
#undef WATCHING_ABOVE
