/obj/item/criptic/clue_item
	name = "relic"
	desc = "Some kind of occult old shit."
	icon = 'core_ru/code/modules/criptid_hunting/precious_objects.dmi'
	icon_state = "teapot_gold"

	w_class = SIZE_TINY

/obj/structure/criptic/clue/item
	covered = TRUE

	icon = 'core_ru/code/modules/criptid_hunting/precious_objects.dmi'
	icon_state = "nothing"
	icon_state_found = "nothing"
	var/obj/item/criptic/clue_item/stored_goods

	mouse_opacity = FALSE

/obj/structure/criptic/clue/item/Initialize(mapload, ...)
	. = ..()
	stored_goods = new /obj/item/criptic/clue_item(src)
	stored_goods.icon_state = pick(icon_states(stored_goods.icon))

	icon_state_found = stored_goods.icon_state
	connected_image.icon_state = icon_state_found

/obj/structure/criptic/clue/item/reveal_itself()
	icon_state_found = "nothing"

	for(var/obj/structure/criptic/mission_controller/M in world)
		M.current_clues_found += 1
		M.show_current_progress()

	revealed = TRUE
	stored_goods.forceMove(get_turf(src))

/obj/item/criptic/instrument/brush
	name = "brush"
	desc = "For uncovering hidden"

	clue_type_to_reveal = list(/obj/structure/criptic/clue/uv,/obj/structure/criptic/clue/uv/plasm,/obj/structure/criptic/clue/uv/runes,/obj/structure/criptic/clue/item)

	icon = 'core_ru/code/modules/criptid_hunting/misc.dmi'

	icon_state = "brush_0"
	icon_state_on = "brush_0"

	w_class = SIZE_SMALL
	flags_equip_slot = SLOT_WAIST | SLOT_SUIT_STORE
