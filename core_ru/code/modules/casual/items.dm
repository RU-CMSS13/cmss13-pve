/// The atom's base transform scale for width.
/atom/var/tf_scale_x

/// The atom's base transform scale for height.
/atom/var/tf_scale_y

/// The atom's base transform scale for rotation.
/atom/var/tf_rotation

/// The atom's base transform scale for horizontal offset.
/atom/var/tf_offset_x

/// The atom's base transform scale for vertical offset.
/atom/var/tf_offset_y

/atom/proc/SetTransform(
	scale,
	scale_x = tf_scale_x,
	scale_y = tf_scale_y,
	rotation = tf_rotation,
	offset_x = tf_offset_x,
	offset_y = tf_offset_y,
	list/others
)
	if (!isnull(scale))
		tf_scale_x = scale
		tf_scale_y = scale
	else
		tf_scale_x = scale_x
		tf_scale_y = scale_y
	tf_rotation = rotation
	tf_offset_x = offset_x
	tf_offset_y = offset_y
	transform = matrix().Update(
		scale_x = tf_scale_x,
		scale_y = tf_scale_y,
		rotation = tf_rotation,
		offset_x = tf_offset_x,
		offset_y = tf_offset_y,
		others = others
	)

/// Runs Scale, Turn, and Translate if supplied parameters, then multiplies by others if set.
/matrix/proc/Update(scale_x, scale_y, rotation, offset_x, offset_y, list/others)
	var/x_null = isnull(scale_x)
	var/y_null = isnull(scale_y)
	if (!x_null || !y_null)
		Scale(x_null ? 1 : scale_x, y_null ? 1 : scale_y)
	if (!isnull(rotation))
		Turn(rotation)
	if (offset_x || offset_y)
		Translate(offset_x || 0, offset_y || 0)
	if (islist(others))
		for (var/other in others)
			Multiply(other)
	else if (others)
		Multiply(others)
	return src

/obj/effect/temp_visual/casual
	duration = 3 SECONDS
	layer = ABOVE_MOB_LAYER

/obj/effect/temp_visual/casual/Initialize(mapload)
	. = ..()
	animate(src, transform = matrix(0.5, MATRIX_SCALE), time = 1)

	animate(src, 1.5 SECONDS, easing = SINE_EASING|EASE_OUT, pixel_y = 64, transform = matrix().Update(scale_x = 1.5, scale_y = 1.5, rotation = 30))
	spawn(2 SECONDS)
		animate(src, 1 SECONDS, easing = SINE_EASING|EASE_IN, flags = ANIMATION_PARALLEL, alpha = 0, transform = matrix())

/obj/item/casual
	name = "equipment"
	desc = "..."

	icon = 'core_ru/code/modules/casual/icons.dmi'
	icon_state = "plate_kit"

	w_class = SIZE_TINY

/obj/item/casual/proc/pop_out() //proc that exist specifically to show that you used an item
	var/obj/effect/temp_visual/casual/U = new /obj/effect/temp_visual/casual(get_turf(loc))
	U.icon = icon
	U.icon_state = "[icon_state]"

/atom/movable/screen/plate_text
	name = "armor text"
	desc = "armor text"
	mouse_opacity = FALSE

	plane = HUD_PLANE
	layer = HUD_LAYER

	icon = 'core_ru/code/modules/casual/icons.dmi'
	icon_state = "text"
	screen_loc = "CENTER-0.4,CENTER+0.4"
	maptext_height = 128
	maptext_width = 128

	maptext_x = 13
	maptext_y = 5

/atom/movable/screen/plate
	name = "armor"
	desc = "armor"
	mouse_opacity = FALSE

	plane = HUD_PLANE
	layer = HUD_LAYER

	icon = 'core_ru/code/modules/casual/icons.dmi'
	icon_state = "plated"
	var/atom/movable/screen/plate_text/text_to_show
	var/mob/living/carbon/human/owner
	var/armor_amount = 0
	var/max_armor = 10

	screen_loc = "CENTER-0.4,CENTER+0.4"

/atom/movable/screen/plate/Initialize(mapload, ...)
	. = ..()
	SetTransform(0.5)
	text_to_show = new /atom/movable/screen/plate_text(src)
	START_PROCESSING(SSobj,src)

/atom/movable/screen/plate/proc/change_it(add_armor = 0)
	if(!(src in owner.client.screen) && owner.client)
		owner.client.screen += src
		owner.client.screen += text_to_show

	if(add_armor > 0)
		animation_flash_color(src, COLOR_RED)
	else
		animation_flash_color(src, COLOR_GREEN)
	animate(src, transform = matrix(0.5, MATRIX_SCALE)*matrix(2, 0, MATRIX_TRANSLATE), time = 0.5, easing = EASE_IN, flags = ANIMATION_PARALLEL)
	animate(transform = matrix(0.5, MATRIX_SCALE)*matrix(-2, 0, MATRIX_TRANSLATE), time = 1)
	animate(transform = matrix(0.5, MATRIX_SCALE)*matrix(0, 0, MATRIX_TRANSLATE), time = 0.3, easing = EASE_OUT)
	armor_amount = clamp(armor_amount - add_armor, 0, max_armor)

	text_to_show.maptext = SPAN_LANGCHAT("[armor_amount]")

/atom/movable/screen/plate/process()
	if(owner.client)
		if(armor_amount > 0 && !(src in owner.client.screen))
			owner.client.screen += src
			owner.client.screen += text_to_show

		if(armor_amount <= 0 && (src in owner.client.screen))
			owner.client.screen -= src
			owner.client.screen -= text_to_show

/obj/item/casual/plates
	name = "armor kit"
	desc = "Protects you fron next 5 incoming shots"

	w_class = SIZE_SMALL
	var/given_armor = 5

/obj/item/casual/plates/attack_self(mob/living/carbon/human/user)
	. = ..()

	if(user.plate_worn.armor_amount >= user.plate_worn.max_armor - 2)
		balloon_alert(user, "There is no space for another plate!", COLOR_WHITE)
		animation_flash_color(src, COLOR_RED)
		return FALSE

	pop_out()
	user.plate_worn.change_it(-given_armor)
	animation_flash_color(src, COLOR_GREEN)
	sleep(0.5 SECONDS)
	qdel(src)

/atom/movable/screen/fullscreen/nvg/heal
	alpha = 0

/atom/movable/screen/fullscreen/nvg/heal/Initialize()
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS, BOUNCE_EASING|EASE_IN)

/mob/living/carbon/human
	var/can_be_revived = TRUE

/obj/item/casual/revive_defib
	name = "emergency defibrillator"
	desc = "Brings people back even from the dead"

	icon_state = "revive_machine" // why tf this sprite named like that

	w_class = SIZE_MEDIUM

/obj/item/casual/revive_defib/attack(mob/living/carbon/human/M, mob/user)
	. = ..()
	if(!M.can_be_revived)
		balloon_alert(user, "Seems the damage is too severe...", COLOR_WHITE)
		animation_flash_color(src, COLOR_RED)
		return FALSE

	playsound(get_turf(user), 'sound/items/defib_safetyOn.ogg', 25, 0)
	sleep(5)
	playsound(get_turf(user),'sound/items/defib_charge.ogg', 25, 0)

	if(!do_after(user, 7 SECONDS, INTERRUPT_ALL, BUSY_ICON_MEDICAL))
		return FALSE

	pop_out()
	playsound(get_turf(user), 'sound/items/defib_release.ogg', 25, 1)
	M.rejuvenate()
	M.take_overall_damage(100, used_weapon = "low skill", limb_damage_chance = 50)
	animation_flash_color(src, COLOR_GREEN)
	M.overlay_fullscreen_timer(1 SECONDS, 5, "heal",/atom/movable/screen/fullscreen/nvg/heal)
	M.can_be_revived = FALSE
	return TRUE

/obj/item/casual/healing_vial
	name = "vial"
	desc = "There is just enough fluid to keep you on foot"
	icon_state = "heal_vial"

	w_class = SIZE_TINY

	var/list/chemicals_to_inject = list(
		"oxycodone" = 20,
		"bicaridine" = 30,
		"kelotane" = 30,
		"meralyne" = 15,
		"dermaline" = 15,
		"inaprovaline" = 30,
		"adrenaline_concentrated_nodamage" = 10,
		"ultrazine" = 10
	)

/obj/item/casual/healing_vial/attack_self(mob/living/carbon/human/user)
	. = ..()
	pop_out()
	playsound(loc,'sound/effects/pillbottle.ogg',10,TRUE)
	user.restore_blood()

	for(var/chemical in chemicals_to_inject)
		user.reagents.add_reagent(chemical, chemicals_to_inject[chemical])

	animation_flash_color(src, COLOR_GREEN)
	sleep(0.5 SECONDS)
	qdel(src)

/obj/item/casual/healing_vial/attack(mob/living/carbon/human/M, mob/user)
	. = ..()
	pop_out()
	playsound(loc,'sound/effects/pillbottle.ogg',10,TRUE)

	M.restore_blood()
	for(var/chemical in chemicals_to_inject)
		M.reagents.add_reagent(chemical, chemicals_to_inject[chemical])

	animation_flash_color(src, COLOR_GREEN)
	sleep(0.5 SECONDS)
	qdel(src)
