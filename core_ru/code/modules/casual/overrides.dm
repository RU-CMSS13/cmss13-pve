/mob/living/carbon/human
	var/atom/movable/screen/plate/plate_worn

/mob/living/carbon/human/Initialize(mapload, new_species)
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	plate_worn = new /atom/movable/screen/plate(src)
	plate_worn.owner = src

/mob/living/carbon/human/get_examine_text(mob/user)
	CAN_BE_REDEFINED(TRUE)
	. = ..()

	if(plate_worn && plate_worn.armor_amount >= 5)
		. += SPAN_GREEN("Looks bulky!")

	if(plate_worn && plate_worn.armor_amount < 4)
		. += SPAN_GREEN("Looks light!")

/mob/living/carbon/human/bullet_act(obj/projectile/P)
	CAN_BE_REDEFINED(TRUE)
	if(!P)
		return

	if(isxeno(P.firer))
		var/mob/living/carbon/xenomorph/X = P.firer
		if(X.can_not_harm(src))
			bullet_ping(P)
			return -1

	var/ammo_flags = P.ammo.flags_ammo_behavior | P.projectile_override_flags
	if(P.weapon_cause_data && P.weapon_cause_data.cause_name)
		var/mob/M = P.weapon_cause_data.resolve_mob()
		if(istype(M))
			M.track_shot_hit(P.weapon_cause_data.cause_name, src)

	var/damage = P.calculate_damage()
	var/damage_result = damage

	if(SEND_SIGNAL(src, COMSIG_HUMAN_PRE_BULLET_ACT, P) & COMPONENT_CANCEL_BULLET_ACT)
		return

	flash_weak_pain()
	if(P.ammo.stamina_damage)
		apply_stamina_damage(P.ammo.stamina_damage, P.def_zone, ARMOR_ENERGY) // Stamina damage is energy

	//Shields
	if( !(ammo_flags & AMMO_ROCKET) ) //No, you can't block rockets.
		if(prob(75) && check_shields(damage * 0.65, "[P]") ) // Lower chance to block bullets
			P.ammo.on_shield_block(src)
			bullet_ping(P)
			return

		if(plate_worn && plate_worn.armor_amount > 0)
			plate_worn.change_it(1)
			bullet_ping(P)
			return

	var/obj/limb/organ = get_limb(check_zone(P.def_zone)) //Let's finally get what organ we actually hit.
	if(!organ)
		return//Nope. Gotta shoot something!

	//Run armor check. We won't bother if there is no damage being done.
	if( damage > 0 && !(ammo_flags & AMMO_IGNORE_ARMOR) )
		var/armor //Damage types don't correspond to armor types. We are thus merging them.
		switch(P.ammo.damage_type)
			if(BRUTE)
				if(ammo_flags & AMMO_ROCKET)
					armor = getarmor_organ(organ, ARMOR_BOMB)
				else
					armor = getarmor_organ(organ, ARMOR_BULLET)
			if(BURN)
				if(ammo_flags & AMMO_ENERGY)
					armor = getarmor_organ(organ, ARMOR_ENERGY)
				else if(ammo_flags & AMMO_LASER)
					armor = getarmor_organ(organ, ARMOR_LASER)
				else
					armor = getarmor_organ(organ, ARMOR_BIO)
			if(TOX, OXY, CLONE)
				armor = getarmor_organ(organ, ARMOR_BIO)
			else
				armor = getarmor_organ(organ, ARMOR_ENERGY) //Won't be used, but just in case.

		damage_result = armor_damage_reduction(GLOB.marine_ranged, damage, armor, P.ammo.penetration)

		if(damage_result <= 5)
			to_chat(src,SPAN_XENONOTICE("Your armor absorbs the force of [P]!"))
		if(damage_result <= 3)
			damage_result = 0
			bullet_ping(P)
			visible_message(SPAN_AVOIDHARM("[src]'s armor deflects [P]!"))
			if(P.ammo.sound_armor) playsound(src, P.ammo.sound_armor, 50, 1)

	if(P.ammo.debilitate && stat != DEAD && ( damage || ( ammo_flags & AMMO_IGNORE_RESIST) ) )  //They can't be dead and damage must be inflicted (or it's a xeno toxin).
		//Predators and synths are immune to these effects to cut down on the stun spam. This should later be moved to their apply_effects proc, but right now they're just humans.
		if(!isspeciesyautja(src) && !isspeciessynth(src))
			apply_effects(arglist(P.ammo.debilitate))

	bullet_message(P) //We still want this, regardless of whether or not the bullet did damage. For griefers and such.

	if(SEND_SIGNAL(src, COMSIG_HUMAN_BULLET_ACT, damage_result, ammo_flags, P) & COMPONENT_CANCEL_BULLET_ACT)
		return

	P.play_hit_effect(src)
	if(damage_result || (ammo_flags & AMMO_SPECIAL_EMBED))

		var/splatter_dir = get_dir(P.starting, loc)
		handle_blood_splatter(splatter_dir)

		. = TRUE
		apply_damage(damage_result, P.ammo.damage_type, P.def_zone, firer = P.firer)

		if(P.ammo.shrapnel_chance > 0 && (damage_result/damage) > 0.5 && prob(trunc(P.ammo.shrapnel_chance * damage_result/damage)))
			if(ammo_flags & AMMO_SPECIAL_EMBED)
				P.ammo.on_embed(src, organ)

			var/obj/item/shard/shrapnel/new_embed = new P.ammo.shrapnel_type
			var/obj/item/large_shrapnel/large_embed = new P.ammo.shrapnel_type
			if(istype(large_embed))
				large_embed.on_embed(src, organ)
			if(istype(new_embed))
				var/found_one = FALSE
				for(var/obj/item/shard/shrapnel/S in embedded_items)
					if(S.name == new_embed.name)
						S.count++
						qdel(new_embed)
						found_one = TRUE
						break

				if(!found_one)
					new_embed.on_embed(src, organ)

				if(!stat && pain.feels_pain)
					emote("scream")
					to_chat(src, SPAN_HIGHDANGER("You scream in pain as the impact sends <B>shrapnel</b> into the wound!"))
	SEND_SIGNAL(P, COMSIG_POST_BULLET_ACT_HUMAN, src, damage, damage_result)

/datum/human_ai_brain
	cloak_visible_range = 1

/datum/human_ai_brain/is_lit(atom/movable/thing)
	CAN_BE_REDEFINED(TRUE)
	var/turf/thing_turf = get_turf(thing)
	if(thing_turf.luminosity || (thing_turf.dynamic_lumcount >= 1))
		return TRUE
	return FALSE

/datum/vehicle_ai_brain/can_target_mob(mob/living/carbon/target, turf/center)
	CAN_BE_REDEFINED(TRUE)
	if(target.stat == DEAD)
		return FALSE

	if(!shoots_to_kill() && (target.stat == UNCONSCIOUS || (locate(/datum/effects/crit) in target.effects_list)))
		return FALSE

	if(faction_check(target))
		return FALSE

	if(HAS_TRAIT(target, TRAIT_ABILITY_BURROWED))
		return FALSE

	var/distance = get_dist(center, target)
	if(HAS_TRAIT(target, TRAIT_CLOAKED) && distance > cloak_visible_range)
		return FALSE

	if(!has_nightvision && distance > dark_vision_range)
		var/turf/target_turf = get_turf(target)
		if(target_turf.luminosity || (target_turf.dynamic_lumcount >= 1))
			return TRUE
		return FALSE

	return TRUE
