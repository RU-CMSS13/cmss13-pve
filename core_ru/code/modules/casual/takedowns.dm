/datum/keybinding/human/takedown
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "takedown"
	full_name = "Takedown"
	keybind_signal = COMSIG_KB_HUMAN_TAKEDOWN

/datum/keybinding/human/takedown/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/human = user.mob

	var/list/turf/turfs = list()
	for(var/turf/T in get_line(human,get_ranged_target_turf(human,human.dir,2)))
		if(istype(T,/turf/closed))
			continue
		turfs += T

	var/list/targets = list()

	for(var/turf/T in turfs)
		for(var/atom/A in T)
			if(A == T)
				continue
			if(A.density && !istype(A,/mob/living) && !istype(A,/obj/structure/surface/table) && !istype(A,/obj/structure/window_frame))
				turfs -= T

	for(var/turf/T in turfs)
		for(var/mob/living/carbon/human/H in T)
			if(H.stat != CONSCIOUS)
				continue
			if(H == human)
				continue
			targets += H

	if(!length(targets))
		human.balloon_alert(human, "No one to grab!", COLOR_WHITE)
		return FALSE

	var/mob/living/carbon/human/enemy = pick(targets)
	var/turf/user_turf = get_turf(human)

	if(user_turf.get_lumcount() > 0.5 && human.alpha > 45)
		human.balloon_alert(human, "Too bright!", COLOR_WHITE)
		return FALSE

	if(enemy.dir != human.dir && can_see(enemy,human)) // we can do that only if there is something between us or target turned their back to us
		human.balloon_alert(human, "They will see it coming!", COLOR_WHITE)
		return FALSE

	var/turf/user_front_turf = get_turf(get_step(human,human.dir))
	if(istype(user_front_turf,/turf/closed))
		human.balloon_alert(human, "There's the wall in the way!", COLOR_WHITE)
		return FALSE

	enemy.forceMove(get_step_towards(enemy, human))
	var/held_item = human.get_held_item()
	if(held_item && istype(held_item,/obj/item/weapon/knife/marine))
		human.animation_attack_on(enemy)
		human.flick_attack_overlay(enemy, "punch")
		playsound(human.loc,'sound/weapons/slice.ogg', 25, 1)
		animate(enemy, transform = matrix(2, 0, MATRIX_TRANSLATE), time = 0.5, easing = EASE_IN, flags = ANIMATION_PARALLEL)
		animate(transform = matrix(-2, 0, MATRIX_TRANSLATE), time = 1)
		animate(transform = matrix(0, 0, MATRIX_TRANSLATE), time = 0.3, easing = EASE_OUT)
		enemy.apply_damage(50, BRUTE, "head")
		enemy.death()
		return TRUE

	else
		human.animation_attack_on(enemy)
		human.flick_attack_overlay(enemy, "grab")
		//playsound(human.loc,'sound/weapons/slash.ogg', 25, 1)
		animate(enemy, transform = matrix(2, 0, MATRIX_TRANSLATE), time = 0.5, easing = EASE_IN, flags = ANIMATION_PARALLEL)
		animate(transform = matrix(-2, 0, MATRIX_TRANSLATE), time = 1)
		animate(transform = matrix(0, 0, MATRIX_TRANSLATE), time = 0.3, easing = EASE_OUT)
		enemy.apply_effect(60, PARALYZE)
		return TRUE

