#define SPAN_WHITE(X) "<span class='white'>[X]</span>"

/datum/component/damage_over_time_simple
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// How much to damage (negative is healing) will incorporate dmg_mult after Initialize
	var/dam_amount = 10
	/// The kind of damage to perform
	var/dam_type = BURN
	var/for_time = 10

	/// Parent as a living mob
	var/mob/living/living_parent

/datum/component/damage_over_time_simple/InheritComponent(for_time, dam_amount, dam_type, synth_dmg_mult, pred_dmg_mult)
	return // Ultimately just here to suppress named arg errors

/datum/component/damage_over_time_simple/Initialize(for_time, dam_amount=5, dam_type=BURN, synth_dmg_mult=0.5, pred_dmg_mult=0.5)
	src.for_time = for_time
	src.dam_amount = dam_amount
	src.dam_type = dam_type

	living_parent = parent

	if(!istype(living_parent))
		return COMPONENT_INCOMPATIBLE
	if(living_parent.stat == DEAD)
		return COMPONENT_INCOMPATIBLE

	if(issynth(living_parent))
		dam_amount *= synth_dmg_mult
	if(isyautja(living_parent))
		dam_amount *= pred_dmg_mult

	try_to_damage()

/datum/component/damage_over_time_simple/process(delta_time)
	try_to_damage()

/datum/component/damage_over_time_simple/proc/try_to_damage()
	if(QDELETED(living_parent) || living_parent.stat == DEAD)
		qdel(src)
		return

	for_time -= 1
	if(for_time <= 0)
		qdel(src)
		return

	living_parent.apply_damage(5*dam_amount,dam_type)
	animation_flash_color(living_parent, COLOR_RED)

/datum/component/damage_over_time_simple/RegisterWithParent()
	START_PROCESSING(SSdcs, src)

/datum/component/damage_over_time_simple/UnregisterFromParent()
	STOP_PROCESSING(SSdcs, src)

/mob
	var/weak_to_silver = FALSE
	var/weak_to_uv = FALSE
	var/weak_to_salt = FALSE

/obj/effect/temp_visual/working_progress
	duration = 4 SECONDS
	icon = 'core_ru/code/modules/criptid_hunting/chaplainRitual.dmi'
	icon_state = "NOTHING"
	layer = ABOVE_MOB_LAYER
	var/random_start_timing = 0

/obj/effect/temp_visual/working_progress/Initialize(mapload)
	. = ..()

	random_start_timing = pick(0, 1 SECONDS, 2 SECONDS)
	pixel_x = rand(-20,64)
	pixel_y = rand(-20,32)

	spawn(random_start_timing)
		icon_state = "darkness-old"
		animate(src, transform = matrix(3, MATRIX_SCALE), pixel_x = pixel_x + rand(-15,15), pixel_y = pixel_y + rand(-15,15), time = 5)

/obj/item/criptic/scrap
	name = "scrap"
	desc = "Can be used on crafting station."
	icon = 'core_ru/code/modules/criptid_hunting/misc.dmi'
	icon_state = "custararmorkit"

	w_class = SIZE_SMALL

/obj/item/criptic/scrap/attack_hand(mob/user)
	if(istype(loc,/obj/structure/criptic/gunbench))
		var/obj/structure/criptic/gunbench/G = loc
		G.resources -= src
		SetTransform(1)

	. = ..()

/obj/item/criptic/blueprint
	name = "criptic blueprint (SALT)"
	desc = "Used to upgrade equipment on crafting station."
	icon = 'core_ru/code/modules/criptid_hunting/misc.dmi'
	icon_state = "confession_indexer"
	var/silver = FALSE
	var/salt = TRUE
	var/uv = FALSE

	w_class = SIZE_SMALL

/obj/item/criptic/blueprint/attack_hand(mob/user)
	if(istype(loc,/obj/structure/criptic/gunbench))
		var/obj/structure/criptic/gunbench/G = loc
		G.resources -= src
		SetTransform(1)

	. = ..()

/obj/item/criptic/blueprint/silver
	name = "criptic blueprint (SILVER)"
	icon_state = "confession_indexer_blood"
	silver = TRUE
	salt = FALSE

/obj/item/criptic/blueprint/uv
	name = "criptic blueprint (UV)"
	icon_state = "confession_indexer_blood_c"
	uv = TRUE
	salt = FALSE

/obj/structure/criptic/chemstation
	name = "chemical station"
	desc = "You can reveal criptid weakness there!"

	icon = 'core_ru/code/modules/criptid_hunting/workbenches.dmi'

	icon_state = "chemicalset"
	var/obj/structure/criptic/mission_controller/MC
	var/used = FALSE
	var/type_to_display = "None"

/obj/structure/criptic/chemstation/Initialize(mapload, ...)
	. = ..()

	MC = locate(/obj/structure/criptic/mission_controller) in world
	type_to_display = MC.weakness

/obj/structure/criptic/chemstation/MouseEntered(location, control, params)
	. = ..()

	var/mob/living/L = usr
	if(loc == L && get_dist(L,src) < 2 && used)
		maptext_y = pixel_y + 15
		maptext_x = pixel_x + 5
		maptext = SPAN_LANGCHAT("[type_to_display]")

/obj/structure/criptic/chemstation/MouseExited(location, control, params)
	. = ..()

	if(maptext)
		maptext = ""

/obj/structure/criptic/chemstation/attack_hand(mob/user)
	. = ..()
	if(used)
		return FALSE

	if(MC.current_clues_found < MC.needed_amount / 2)
		balloon_alert(user, "You need atleast half of the clues to research that!", COLOR_WHITE)
		return FALSE

	for(var/i in 0 to 10)
		new /obj/effect/temp_visual/working_progress(get_turf(src))

	if(do_after(user, 4 SECONDS, INTERRUPT_ALL, BUSY_ICON_BUILD))
		used = TRUE
		balloon_alert(user, "Possibly weak to: [type_to_display]", COLOR_WHITE)
		switch(type_to_display)
			if("Salt")
				add_filter("salt", 1, list("type" = "outline", "color" = "#c2c2c2", "size" = 1))
			if("Silver")
				add_filter("silver", 1, list("type" = "outline", "color" = "#c50d0d", "size" = 1))
			if("UV")
				add_filter("uv", 1, list("type" = "outline", "color" = "#6f0091", "size" = 1))
	return TRUE

/obj/structure/criptic/gunbench
	name = "workbench"
	desc = "You can modify your gun there!"

	icon = 'core_ru/code/modules/criptid_hunting/workbenches.dmi'

	icon_state = "tinkerbench"
	pixel_y = -10
	bound_width = 64

	density = TRUE

	var/obj/item/weapon/gun/target_gun
	var/list/resources = list()

/obj/structure/criptic/gunbench/attackby(obj/item/W, mob/user)
	. = ..()

	if(istype(W,/obj/item/weapon/gun))
		var/obj/item/weapon/gun/G = W
		if(G.additional_ammo_type)
			balloon_alert(user, "[G] ammunition upgraded already!", COLOR_WHITE)
			animation_flash_color(G, COLOR_RED)
			return FALSE
		else
			target_gun = G
			user.drop_held_item(G)
			G.forceMove(get_turf(src))

			G.pixel_x = 20
			G.layer += 0.1
			return TRUE

	if(istype(W,/obj/item/criptic/blueprint))
		if(locate(/obj/item/criptic/blueprint) in resources)
			balloon_alert(user, "Remove other criptic blueprint from the table first!", COLOR_WHITE)
			animation_flash_color(W, COLOR_RED)
			return FALSE
		else
			resources += W
			user.drop_held_item(W)
			W.forceMove(get_turf(src))

			W.pixel_x = 36
			W.pixel_y = 2
			W.SetTransform(0.7)
			return TRUE

	if(istype(W,/obj/item/criptic/scrap))
		resources += W
		user.drop_held_item(W)
		W.forceMove(get_turf(src))

		W.pixel_x = -2
		W.pixel_y = 2
		W.SetTransform(0.7)
		return TRUE

/obj/structure/criptic/gunbench/attack_hand(mob/user)
	. = ..()

	var/obj/item/criptic/blueprint/print = locate(/obj/item/criptic/blueprint) in resources
	var/list/scrap = list()

	for(var/obj/item/criptic/scrap/S in resources)
		if(length(scrap) < 3)
			scrap += S

	if(!target_gun)
		balloon_alert(user, "There is no gun to modify!", COLOR_WHITE)
		return FALSE
	if(!print)
		balloon_alert(user, "There is no criptic blueprint to work on!", COLOR_WHITE)
		return FALSE
	if(length(scrap) < 3)
		balloon_alert(user, "There is not enough materials for that!", COLOR_WHITE)
		return FALSE

	///////////

	for(var/i in 0 to 10)
		new /obj/effect/temp_visual/working_progress(get_turf(src))

	if(do_after(user, 2 SECONDS, INTERRUPT_ALL, BUSY_ICON_BUILD))
		if(!isnull(target_gun.ammo))
			target_gun.additional_ammo_type = new target_gun.ammo.type()
		if(isnull(target_gun.ammo))
			var/datum/ammo/ammunition = GLOB.ammo_list[target_gun.current_mag.chamber_contents[target_gun.current_mag.chamber_position]]
			target_gun.additional_ammo_type = new ammunition.type()

		if(print.silver)
			target_gun.additional_ammo_type.silver = TRUE
			target_gun.add_filter("silver", 1, list("type" = "outline", "color" = "#c50d0d", "size" = 1))
		if(print.uv)
			target_gun.additional_ammo_type.uv = TRUE
			target_gun.add_filter("uv", 1, list("type" = "outline", "color" = "#6f0091", "size" = 1))
		if(print.salt)
			target_gun.additional_ammo_type.salt = TRUE
			target_gun.add_filter("salt", 1, list("type" = "outline", "color" = "#c2c2c2", "size" = 1))

		user.put_in_hands(target_gun)
		target_gun = null

		for(var/obj/item/criptic/scrap/S in scrap)
			resources -= S
			qdel(S)

		resources -= print
		qdel(print)
		return TRUE
	return FALSE

/obj/item/weapon/gun/attack_hand(mob/user)
	if(istype(loc,/obj/structure/criptic/gunbench))
		var/obj/structure/criptic/gunbench/G = loc
		G.target_gun = null

	. = ..()
