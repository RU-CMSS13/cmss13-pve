/obj/item/clothing/under/marine/odst
	name = "ODST bodyglove"
	icon = 'modular/halo/icons/halo/obj/items/clothing/undersuit.dmi'
	icon_state = "odst"
	worn_state = "odst"
	flags_jumpsuit = null
	flags_atom = NO_SNOW_TYPE|NO_NAME_OVERRIDE
	item_icons = list(
		WEAR_BODY = 'modular/halo/icons/halo/mob/humans/onmob/clothing/uniforms.dmi',
	)

/obj/item/clothing/under/marine/crew
	name = "\improper UNSC crewman uniform"
	desc = "Штатная форма члена экипажа ККОН, обычно носимая небоевым персоналом и выпускаемая в разных цветах в зависимости от роли носителя на корабле или станции."
	flags_jumpsuit = null
	flags_atom = NO_SNOW_TYPE|NO_NAME_OVERRIDE
	icon = 'modular/halo/icons/halo/obj/items/clothing/undersuit.dmi'
	icon_state = "crewjumpsuit"
	worn_state = "crewjumpsuit"
	item_icons = list(
		WEAR_BODY = 'modular/halo/icons/halo/mob/humans/onmob/clothing/uniforms.dmi',
	)

/obj/item/clothing/under/marine/crew/flight
	name = "\improper UNSC flight-deck crewman uniform"
	icon_state = "crewjumpsuit_flight"
	worn_state = "crewjumpsuit_flight"

/obj/item/clothing/under/marine/crew/flight/officer
	name = "\improper UNSC flight-deck officer uniform"
	icon_state = "crewjumpsuit_flight_o"
	worn_state = "crewjumpsuit_flight_o"

/obj/item/clothing/under/marine/crew/engi
	name = "\improper UNSC engineering technician uniform"
	icon_state = "crewjumpsuit_engi"
	worn_state = "crewjumpsuit_engi"

/obj/item/clothing/under/marine/crew/engi/officer
	name = "\improper UNSC engineering officer uniform"
	icon_state = "crewjumpsuit_engi_o"
	worn_state = "crewjumpsuit_engi_o"

/obj/item/clothing/under/marine/crew/med
	name = "\improper UNSC medical specialist uniform"
	icon_state = "crewjumpsuit_med"
	worn_state = "crewjumpsuit_med"

/obj/item/clothing/under/marine/crew/med/officer
	name = "\improper UNSC medical officer uniform"
	icon_state = "crewjumpsuit_med_o"
	worn_state = "crewjumpsuit_med_o"

/obj/item/clothing/under/marine/crew/operations
	name = "\improper UNSC operations specialist uniform"
	icon_state = "crewjumpsuit_ops"
	worn_state = "crewjumpsuit_ops"

/obj/item/clothing/under/marine/crew/operations/officer
	name = "\improper UNSC operations officer uniform"
	icon_state = "crewjumpsuit_ops_o"
	worn_state = "crewjumpsuit_ops_o"

/obj/item/clothing/under/marine/crew/command
	name = "\improper UNSC naval command uniform"
	icon_state = "crewjumpsuit_comm"
	worn_state = "crewjumpsuit_comm"

/obj/item/clothing/under/marine/crew/rnd
	name = "\improper UNSC science officer uniform"
	icon_state = "crewjumpsuit_rnd"
	worn_state = "crewjumpsuit_rnd"

/obj/item/clothing/under/marine/classic
	name = "\improper UNSC fatigues"
	desc = "Униформа морской пехоты старого образца с вставками из венларовой брони в критических зонах для защиты от клинков и баллистических угроз."
	icon = 'modular/halo/icons/halo/obj/items/clothing/undersuit.dmi'
	icon_state = "classic_marine"
	worn_state = "classic_marine"
	flags_jumpsuit = UNIFORM_SLEEVE_ROLLABLE
	flags_atom = NO_SNOW_TYPE|NO_NAME_OVERRIDE
	item_icons = list(
		WEAR_BODY = 'modular/halo/icons/halo/mob/humans/onmob/clothing/uniforms.dmi')
