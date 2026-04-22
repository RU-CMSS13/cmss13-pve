
#define COMSIG_KB_HUMAN_PIXEL_SHIFT_GRABBED_NORTH "keybinding_human_pixel_shift_grabbed_north"
#define COMSIG_KB_HUMAN_PIXEL_SHIFT_GRABBED_SOUTH "keybinding_human_pixel_shift_grabbed_south"
#define COMSIG_KB_HUMAN_PIXEL_SHIFT_GRABBED_EAST "keybinding_human_pixel_shift_grabbed_east"
#define COMSIG_KB_HUMAN_PIXEL_SHIFT_GRABBED_WEST "keybinding_human_pixel_shift_grabbed_west"


/datum/keybinding/human/pixel_shift
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")

/datum/keybinding/human/pixel_shift/can_use(client/user)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/human/human_user = user.mob
	var/obj/item/grab/grab = human_user.get_active_hand()
	if(!istype(grab))
		return FALSE
	var/obj/grabbed_atom = grab.grabbed_thing
	if(ishuman(grabbed_atom))
		return FALSE
	if(grabbed_atom.anchored)
		return FALSE
	return TRUE

/datum/keybinding/human/pixel_shift/north
	name = "pixel_shift_grabbed_north"
	full_name = "Pixel Shift Grabbed - North"
	keybind_signal = COMSIG_KB_HUMAN_PIXEL_SHIFT_GRABBED_NORTH

/datum/keybinding/human/pixel_shift/north/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/human_user = user.mob
	var/obj/item/grab/grab = human_user.get_active_hand()
	var/obj/grabbed = grab.grabbed_thing

	if(grabbed.pixel_y >= 16)
		return
	grabbed.pixel_y += 1
	return TRUE

/datum/keybinding/human/pixel_shift/south
	name = "pixel_shift_grabbed_south"
	full_name = "Pixel Shift Grabbed - South"
	keybind_signal = COMSIG_KB_HUMAN_PIXEL_SHIFT_GRABBED_SOUTH

/datum/keybinding/human/pixel_shift/south/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/human_user = user.mob
	var/obj/item/grab/grab = human_user.get_active_hand()
	var/obj/grabbed = grab.grabbed_thing

	if(grabbed.pixel_y <= -16)
		return
	grabbed.pixel_y -= 1
	return TRUE

/datum/keybinding/human/pixel_shift/east
	name = "pixel_shift_grabbed_east"
	full_name = "Pixel Shift Grabbed - East"
	keybind_signal = COMSIG_KB_HUMAN_PIXEL_SHIFT_GRABBED_EAST

/datum/keybinding/human/pixel_shift/east/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/human_user = user.mob
	var/obj/item/grab/grab = human_user.get_active_hand()
	var/obj/grabbed = grab.grabbed_thing

	if(grabbed.pixel_x >= 16)
		return
	grabbed.pixel_x += 1
	return TRUE

/datum/keybinding/human/pixel_shift/west
	name = "pixel_shift_grabbed_west"
	full_name = "Pixel Shift Grabbed - West"
	keybind_signal = COMSIG_KB_HUMAN_PIXEL_SHIFT_GRABBED_WEST

/datum/keybinding/human/pixel_shift/west/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/human_user = user.mob
	var/obj/item/grab/grab = human_user.get_active_hand()
	var/obj/grabbed = grab.grabbed_thing

	if(grabbed.pixel_x <= -16)
		return
	grabbed.pixel_x -= 1
	return TRUE
