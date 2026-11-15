/obj/effect/temp_visual/utility
	duration = 3 SECONDS
	layer = ABOVE_MOB_LAYER

/obj/effect/temp_visual/utility/Initialize(mapload)
	. = ..()
	animate(src, transform = matrix(0.5, MATRIX_SCALE), time = 1)

	animate(src, 1.5 SECONDS, easing = SINE_EASING|EASE_OUT, pixel_y = 64, transform = matrix().Update(scale_x = 1.5, scale_y = 1.5, rotation = 30))
	spawn(2 SECONDS)
		animate(src, 1 SECONDS, easing = SINE_EASING|EASE_IN, flags = ANIMATION_PARALLEL, alpha = 0, transform = matrix())

/obj/item/criptic/utility
	name = "paranormal equipment"
	desc = "..."

	icon = 'core_ru/code/modules/criptid_hunting/id_items.dmi'
	icon_state = "hunter_badge"

	w_class = SIZE_TINY

/obj/item/criptic/utility/proc/pop_out() //proc that exist specifically to show that you used an item
	var/obj/effect/temp_visual/utility/U = new /obj/effect/temp_visual/utility(get_turf(loc))
	U.icon = icon
	U.icon_state = "[icon_state]"
