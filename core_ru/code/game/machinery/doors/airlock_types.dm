// Hybrisa

/obj/structure/machinery/door/airlock/hybrisa
	openspeed = 4
/obj/structure/machinery/door/airlock/hybrisa/generic
	name = "\improper Airlock"
	icon = 'icons/obj/structures/doors/hybrisa/hybrisa_generic_glass.dmi'
	opacity = FALSE
	glass = TRUE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_PUBLIC)
/obj/structure/machinery/door/airlock/hybrisa/generic/autoname
	req_access = null
	opacity = FALSE
	glass = TRUE
	req_one_access = list(ACCESS_CIVILIAN_PUBLIC)
	autoname = TRUE

/obj/structure/machinery/door/airlock/hybrisa/generic_solid
	name = "\improper Airlock"
	icon = 'icons/obj/structures/doors/hybrisa/hybrisa_generic.dmi'
	opacity = TRUE
	glass = FALSE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_PUBLIC)

/obj/structure/machinery/door/airlock/hybrisa/generic_solid/autoname
	autoname = TRUE
	opacity = TRUE
	glass = FALSE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_PUBLIC)

// Medical

/obj/structure/machinery/door/airlock/hybrisa/medical
	name = "\improper Airlock"
	icon = 'icons/obj/structures/doors/hybrisa/hybrisa_medidoor_glass.dmi'
	opacity = FALSE
	glass = TRUE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_MEDBAY, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_CIVILIAN_PUBLIC)

/obj/structure/machinery/door/airlock/hybrisa/medical/autoname
	autoname = TRUE
	opacity = FALSE
	glass = TRUE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_MEDBAY, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_CIVILIAN_PUBLIC)

/obj/structure/machinery/door/airlock/hybrisa/medical_solid
	name = "\improper Airlock"
	icon = 'icons/obj/structures/doors/hybrisa/hybrisa_medidoor.dmi'
	opacity = TRUE
	glass = FALSE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_MEDBAY, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_CIVILIAN_PUBLIC)
/obj/structure/machinery/door/airlock/hybrisa/medical_solid/autoname
	autoname = TRUE
	opacity = TRUE
	glass = FALSE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_MEDBAY, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_CIVILIAN_PUBLIC)

// Personal
/obj/structure/machinery/door/airlock/hybrisa/personal
	name = "\improper Airlock"
	icon = 'icons/obj/structures/doors/hybrisa/hybrisa_personaldoor_glass.dmi'
	opacity = FALSE
	glass = TRUE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_WY_COLONIAL)
/obj/structure/machinery/door/airlock/hybrisa/personal/autoname
	autoname = TRUE
	opacity = FALSE
	glass = TRUE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_WY_COLONIAL)


/obj/structure/machinery/door/airlock/hybrisa/personal_solid
	name = "\improper Airlock"
	icon = 'icons/obj/structures/doors/hybrisa/hybrisa_personaldoor.dmi'
	opacity = TRUE
	glass = FALSE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_WY_COLONIAL)

/obj/structure/machinery/door/airlock/hybrisa/personal_solid/autoname
	autoname = TRUE
	req_access = null
	opacity = TRUE
	glass = FALSE
	req_one_access = list(ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_WY_COLONIAL)

// Personal White
/obj/structure/machinery/door/airlock/hybrisa/personal_white
	name = "\improper Airlock"
	icon = 'icons/obj/structures/doors/hybrisa/hybrisa_personaldoor_glass_white.dmi'
	opacity = FALSE
	glass = TRUE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_WY_COLONIAL)
/obj/structure/machinery/door/airlock/hybrisa/personal_white/autoname
	autoname = TRUE
	req_access = null
	opacity = FALSE
	glass = TRUE
	req_one_access = list(ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_WY_COLONIAL)


/obj/structure/machinery/door/airlock/hybrisa/personal_solid_white
	name = "\improper Airlock"
	icon = 'icons/obj/structures/doors/hybrisa/hybrisa_personaldoor_white.dmi'
	opacity = TRUE
	glass = FALSE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_WY_COLONIAL)
/obj/structure/machinery/door/airlock/hybrisa/personal_solid_white/autoname
	autoname = TRUE
	opacity = TRUE
	glass = FALSE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_WY_COLONIAL)


/obj/structure/machinery/door/airlock/multi_tile/hybrisa
	openspeed = 4
/obj/structure/machinery/door/airlock/multi_tile/hybrisa/generic
	name = "\improper Airlock"
	icon = 'icons/obj/structures/doors/hybrisa/hybrisa_2x1generic.dmi'
	opacity = FALSE
	glass = TRUE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_PUBLIC)
/obj/structure/machinery/door/airlock/multi_tile/hybrisa/generic/autoname
	req_access = null
	opacity = FALSE
	glass = TRUE
	req_one_access = list(ACCESS_CIVILIAN_PUBLIC)
	autoname = TRUE

/obj/structure/machinery/door/airlock/multi_tile/hybrisa/generic_solid
	name = "\improper Airlock"
	icon = 'icons/obj/structures/doors/hybrisa/hybrisa_2x1generic_solid.dmi'
	opacity = TRUE
	glass = FALSE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_PUBLIC)

/obj/structure/machinery/door/airlock/multi_tile/hybrisa/generic_solid/autoname
	autoname = TRUE
	opacity = TRUE
	glass = FALSE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_PUBLIC)

// Medical

/obj/structure/machinery/door/airlock/multi_tile/hybrisa/medical
	name = "\improper Airlock"
	icon = 'icons/obj/structures/doors/hybrisa/hybrisa_2x1medidoor.dmi'
	opacity = FALSE
	glass = TRUE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_MEDBAY, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_CIVILIAN_PUBLIC)

/obj/structure/machinery/door/airlock/multi_tile/hybrisa/medical/autoname
	autoname = TRUE
	opacity = FALSE
	glass = TRUE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_MEDBAY, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_CIVILIAN_PUBLIC)

/obj/structure/machinery/door/airlock/multi_tile/hybrisa/medical_solid
	name = "\improper Airlock"
	icon = 'icons/obj/structures/doors/hybrisa/hybrisa_2x1medidoor_solid.dmi'
	opacity = TRUE
	glass = FALSE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_MEDBAY, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_CIVILIAN_PUBLIC)
/obj/structure/machinery/door/airlock/multi_tile/hybrisa/medical_solid/autoname
	autoname = TRUE
	opacity = TRUE
	glass = FALSE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_MEDBAY, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_CIVILIAN_PUBLIC)

// Personal
/obj/structure/machinery/door/airlock/multi_tile/hybrisa/personal
	name = "\improper Airlock"
	icon = 'icons/obj/structures/doors/hybrisa/hybrisa_2x1personaldoor_glass.dmi'
	opacity = FALSE
	glass = TRUE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_WY_COLONIAL)
/obj/structure/machinery/door/airlock/multi_tile/hybrisa/personal/autoname
	autoname = TRUE
	opacity = FALSE
	glass = TRUE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_WY_COLONIAL)


/obj/structure/machinery/door/airlock/multi_tile/hybrisa/personal_solid
	name = "\improper Airlock"
	icon = 'icons/obj/structures/doors/hybrisa/hybrisa_2x1personaldoor.dmi'
	opacity = TRUE
	glass = FALSE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_WY_COLONIAL)

/obj/structure/machinery/door/airlock/multi_tile/hybrisa/personal_solid/autoname
	autoname = TRUE
	opacity = TRUE
	glass = FALSE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_WY_COLONIAL)

// Personal White

/obj/structure/machinery/door/airlock/multi_tile/hybrisa/personal_white
	name = "\improper Airlock"
	icon = 'icons/obj/structures/doors/hybrisa/hybrisa_2x1personaldoor_glass_white.dmi'
	opacity = FALSE
	glass = TRUE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_WY_COLONIAL)
/obj/structure/machinery/door/airlock/multi_tile/hybrisa/personal_white/autoname
	autoname = TRUE
	opacity = FALSE
	glass = TRUE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_WY_COLONIAL)


/obj/structure/machinery/door/airlock/multi_tile/hybrisa/personal_solid_white
	name = "\improper Airlock"
	icon = 'icons/obj/structures/doors/hybrisa/hybrisa_2x1personaldoor_white.dmi'
	opacity = TRUE
	glass = FALSE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_WY_COLONIAL)
/obj/structure/machinery/door/airlock/multi_tile/hybrisa/personal_solid_white/autoname
	autoname = TRUE
	opacity = TRUE
	glass = FALSE
	req_access = null
	req_one_access = list(ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_COMMAND, ACCESS_WY_COLONIAL)
