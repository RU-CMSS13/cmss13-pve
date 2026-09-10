/obj/item/criptic/utility
	name = "paranormal equipment"
	desc = "..."

	icon = 'core_ru/code/modules/criptid_hunting/id_items.dmi'
	icon_state = "hunter_badge"

	w_class = SIZE_TINY

/obj/item/criptic/utility/protective_cross
	name = "protection cross"
	desc = "Used to scare of some of the entities"

	light_color = LIGHT_COLOR_HOLY_MAGIC
	light_range = 2
	light_power = 0.5

	var/usage_cooldown = 1 MINUTES
	var/used = FALSE

	var/total_uses = 0
	var/total_uses_allowed = 5

/obj/item/criptic/utility/protective_cross/attack_self(mob/user)
	. = ..()
	if(used)
		animation_flash_color(src, COLOR_RED)
		return FALSE

	if(!used)
		used = TRUE
		addtimer(CALLBACK(src, PROC_REF(reset_cross)), usage_cooldown)
		set_light_on(1)

		// place for damage dealing

		sleep(1 SECONDS)

		set_light_range(4)
		set_light_power(1)

		// place for damage dealing

		sleep(1 SECONDS)

		set_light_range(2)
		set_light_power(0.5)
		set_light_on(0)

		add_filter("cross1", 1, list("type" = "outline", "color" = "#ff8411", "size" = 1))
		add_filter("cross2", 1, list("type" = "blur", "size" = 0.7))

		total_uses += 1
		if(total_uses >= total_uses_allowed)
			animate(src, alpha = 00, time = 1 SECONDS, easing = SINE_EASING | EASE_IN)
			sleep(1.2 SECONDS)
			qdel(src)

/obj/item/criptic/utility/protective_cross/proc/reset_cross()
	used = FALSE
	remove_filter("cross1")
	remove_filter("cross2")

/atom/movable/screen/fullscreen/nvg/heal
	alpha = 0

/atom/movable/screen/fullscreen/nvg/heal/Initialize()
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS, BOUNCE_EASING|EASE_IN)

/obj/item/criptic/utility/pills/healing
	name = "healing pills"
	desc = "Restores your body to the full, healed state"

	icon = 'core_ru/code/modules/criptid_hunting/items1.dmi'
	icon_state = "birth1" // why tf this sprite named like that

	w_class = SIZE_TINY

/obj/item/criptic/utility/pills/healing/attack_self(mob/living/carbon/human/user)
	. = ..()
	playsound(loc,'sound/effects/pillbottle.ogg',10,TRUE)
	user.rejuvenate()
	animation_flash_color(src, COLOR_GREEN)
	user.overlay_fullscreen_timer(1 SECONDS, 5, "heal",/atom/movable/screen/fullscreen/nvg/heal)

	sleep(0.5 SECONDS)
	qdel(src)

/obj/item/criptic/utility/pills/healing/attack(mob/living/carbon/human/M, mob/user)
	. = ..()
	playsound(loc,'sound/effects/pillbottle.ogg',10,TRUE)
	M.rejuvenate()
	animation_flash_color(src, COLOR_GREEN)
	M.overlay_fullscreen_timer(1 SECONDS, 5, "heal", /atom/movable/screen/fullscreen/nvg/heal)

	sleep(0.5 SECONDS)
	qdel(src)
