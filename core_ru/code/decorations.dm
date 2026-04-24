/obj/structure/prop/almayer/missile_silo
	name = "missile silo blast door"
	desc = "An enormous reinforced plasteel silo door. It is mechanically operated and can not be forced non-destructively."
	icon = 'core_ru/icons/missile_silo.dmi'
	icon_state = "silo"
	bound_width = 96
	bound_height = 96

/obj/structure/prop/almayer/icbm
	name = "RS-20 nuclear ballistic missile"
	desc = "A Zavodskoi-designed hypersonic missile carrying a nuclear payload. With a maximum speed of over 20% the speed of light in vacuum or Mach 25 in atmosphere, interplanetary travel capability, and an accuracy to the meter, this missile forms a cornerstone of arsenals galaxy-wide, able to function as both an anti-orbital weapon and an intercontinental nuclear bomb, delivered anywhere on a planet or in a solar system. The nuclear warhead on this has enough power to level a city."
	icon = 'core_ru/icons/icbm.dmi'
	icon_state = "icbm"
	layer = BILLBOARD_LAYER

/obj/structure/blocker/invisible_wall/fog
	name = "dense fog"
	desc = "It looks way too dangerous to traverse. Best wait until it has cleared up."
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	opacity = TRUE

/obj/structure/blocker/invisible_wall/fog/New()
	..()
	icon_state = initial(icon_state)

/obj/structure/blocker/invisible_wall/fog/evac
	name = "dense fog"
	desc = "Ты не можешь бросить свсоих пока идёт эвакуация!"
