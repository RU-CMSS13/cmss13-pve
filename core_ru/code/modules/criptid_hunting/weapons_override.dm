/obj/item/weapon/gun
	var/datum/ammo/additional_ammo_type

/obj/item/weapon/gun/get_examine_text(mob/user)
	. = ..()

	if(additional_ammo_type && additional_ammo_type.silver)
		. += SPAN_RED("It's loaded with silver bullets.")

	if(additional_ammo_type && additional_ammo_type.uv)
		. += SPAN_PURPLE("It's loaded with UV bullets.")

	if(additional_ammo_type && additional_ammo_type.salt)
		. += SPAN_BLUE("It's loaded with salt bullets.")

/obj/item/weapon/gun/ready_in_chamber()
	if(additional_ammo_type)
		QDEL_NULL(in_chamber)
		if(current_mag && current_mag.current_rounds > 0)
			in_chamber = create_bullet(additional_ammo_type, initial(name))
			apply_traits(in_chamber)
			current_mag.current_rounds-- //Subtract the round from the mag.
			return in_chamber
	else
		..()

/obj/item/weapon/gun/lever_action/ready_lever_action_internal_mag()
	if(additional_ammo_type)
		if(isnull(current_mag) || !length(current_mag.chamber_contents))
			return
		if(current_mag.current_rounds > 0)
			in_chamber = create_bullet(additional_ammo_type, initial(name))
			current_mag.current_rounds--
			current_mag.chamber_contents[current_mag.chamber_position] = "empty"
			current_mag.chamber_position--
			return in_chamber
	else
		..()

/obj/item/weapon/gun/revolver/ready_in_chamber()
	if(additional_ammo_type)
		if(current_mag)
			if(current_mag.current_rounds > 0)
				if(current_mag.chamber_contents[current_mag.chamber_position] == "bullet")
					current_mag.current_rounds-- //Subtract the round from the mag.
					in_chamber = create_bullet(additional_ammo_type, initial(name))
					apply_traits(in_chamber)
					return in_chamber
			else if(current_mag.chamber_closed)
				unload(null)
	else
		..()

/obj/item/weapon/gun/shotgun/ready_shotgun_tube()
	if(additional_ammo_type)
		if(isnull(current_mag) || !length(current_mag.chamber_contents))
			return
		if(current_mag.current_rounds > 0)
			in_chamber = create_bullet(additional_ammo_type, initial(name))
			current_mag.current_rounds--
			current_mag.chamber_contents[current_mag.chamber_position] = "empty"
			current_mag.chamber_position--
			return in_chamber
	else
		..()

/datum/ammo
	var/silver = FALSE
	var/uv = FALSE
	var/salt = FALSE

/datum/ammo/on_hit_mob(mob/M, obj/projectile/P, mob/user)
	. = ..()

	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

/datum/ammo/bullet/pistol/heavy/super/highimpact/on_hit_mob(mob/M, obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/revolver/heavy/on_hit_mob(mob/entity, obj/projectile/bullet)
	if((silver && entity.weak_to_silver) || (uv && entity.weak_to_uv) || (salt && entity.weak_to_salt))
		entity.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		entity.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		entity.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/revolver/upp/shrapnel/on_hit_mob(mob/M, obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/revolver/mateba/highimpact/on_hit_mob(mob/M, obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/rifle/heavy/on_hit_mob(mob/M,obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/rifle/heavy/rmcdmr/on_hit_mob(mob/M,obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/rifle/heavy/impdet/on_hit_mob(mob/entity, obj/projectile/bullet)
	if((silver && entity.weak_to_silver) || (uv && entity.weak_to_uv) || (salt && entity.weak_to_salt))
		entity.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		entity.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		entity.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/rifle/heavy/upp/flak/on_hit_mob(mob/target, obj/projectile/fired_proj)
	if((silver && target.weak_to_silver) || (uv && target.weak_to_uv) || (salt && target.weak_to_salt))
		target.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		target.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		target.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/rifle/heavy/upp/flak_spread/on_hit_mob(mob/target, obj/projectile/fired_proj)
	if((silver && target.weak_to_silver) || (uv && target.weak_to_uv) || (salt && target.weak_to_salt))
		target.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		target.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		target.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/rifle/heavy/incendiary/on_hit_mob(mob/M,obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/rifle/heavy/flak/on_hit_mob(mob/M,obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/shotgun/slug/on_hit_mob(mob/M,obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/shotgun/slug/special/on_hit_mob(mob/M,obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/shotgun/flechette/on_hit_mob(mob/M,obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/shotgun/flechette/special/on_hit_mob(mob/M,obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/shotgun/flechette_spread/special/on_hit_mob(mob/M,obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/shotgun/buckshot/on_hit_mob(mob/M,obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/shotgun/spread/on_hit_mob(mob/M,obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/shotgun/heavy/buckshot/on_hit_mob(mob/M,obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/shotgun/heavy/slug/on_hit_mob(mob/M,obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/shotgun/twobore/on_hit_mob(mob/living/M, obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/shotgun/slug/medium/on_hit_mob(mob/M,obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/sniper/on_hit_mob(mob/M,obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/sniper/upp/flak/on_hit_mob(mob/M,obj/projectile/P)
	if((silver && M.weak_to_silver) || (uv && M.weak_to_uv) || (salt && M.weak_to_salt))
		M.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		M.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		M.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()

/datum/ammo/bullet/sniper/anti_materiel/on_hit_mob(mob/target_mob,obj/projectile/aimed_projectile)
	if((silver && target_mob.weak_to_silver) || (uv && target_mob.weak_to_uv) || (salt && target_mob.weak_to_salt))
		target_mob.AddComponent(/datum/component/status_effect/toxic_buildup, 20)
		target_mob.AddComponent(/datum/component/bonus_damage_stack, 100, world.time, 280, 1)
		target_mob.AddComponent(/datum/component/damage_over_time_simple, 10, 5, BURN)

	..()
