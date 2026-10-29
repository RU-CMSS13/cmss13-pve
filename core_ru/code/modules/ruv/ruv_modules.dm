/obj/item/cell/ruv
	name = "RUV battery"
	desc = "A heavy rechargeable battery pack shaped to fit the slot of an RUV."
	icon = 'core_ru/icons/ruv.dmi'
	icon_state = "cell"
	charge = 2000
	maxcharge = 2000
	w_class = SIZE_MEDIUM

/obj/item/cell/ruv/update_icon()
	..()
	overlays.Cut()
	if(charge < 0.01)
		return
	overlays += image(icon, charge / maxcharge >= 0.5 ? "cell+full" : "cell+half")

/obj/item/cell/ruv/get_examine_text(mob/user)
	. = ..()
	. += SPAN_HELPFUL("Recharge it in a cell charger. Insert it into an RUV by hand and pry it out with a crowbar.")

/obj/item/ruv_module
	name = "RUV module"
	desc = "A hardpoint module for an RUV."
	icon = 'core_ru/icons/ruv.dmi'
	w_class = SIZE_MEDIUM
	/// RUV body state with this module installed
	var/bot_icon_state = "empty"

/obj/item/ruv_module/proc/on_install(mob/living/simple_animal/ruv/bot)
	return

/obj/item/ruv_module/proc/on_uninstall(mob/living/simple_animal/ruv/bot)
	return

/obj/item/ruv_module/proc/get_status_text()
	return

/obj/item/ruv_module/proc/get_usage_text()
	return "Install it on an RUV by hand and remove it with a screwdriver."

/obj/item/ruv_module/get_examine_text(mob/user)
	. = ..()
	var/status = get_status_text()
	if(status)
		. += status
	. += SPAN_HELPFUL(get_usage_text())

// Arm

/obj/item/ruv_module/arm
	name = "RUV manipulator arm"
	desc = "A hydraulic manipulator arm for an RUV. Strong enough to drag a body or a crate, gentle enough to press a button, and it hits hard."
	icon_state = "arm_module"
	bot_icon_state = "arm"
	var/melee_damage_lower = 20
	var/melee_damage_upper = 30
	COOLDOWN_DECLARE(action_cooldown)

/obj/item/ruv_module/arm/get_usage_text()
	return "[..()] While driving the RUV, click what is next to it to grab or use it, ctrl-click to only grab, and use harm intent to hit. Click the RUV itself or the Stop button to let go."

/obj/item/ruv_module/arm/on_install(mob/living/simple_animal/ruv/bot)
	ADD_TRAIT(bot, TRAIT_OPPOSABLE_THUMBS, TRAIT_SOURCE_RUV_ARM)

/obj/item/ruv_module/arm/on_uninstall(mob/living/simple_animal/ruv/bot)
	REMOVE_TRAIT(bot, TRAIT_OPPOSABLE_THUMBS, TRAIT_SOURCE_RUV_ARM)
	bot.stop_pulling()

/obj/item/ruv_module/arm/proc/strike(mob/living/target, mob/living/simple_animal/ruv/bot)
	if(!COOLDOWN_FINISHED(src, action_cooldown) || !bot.Adjacent(target))
		return FALSE
	if(!bot.use_charge(RUV_ARM_COST))
		return FALSE
	COOLDOWN_START(src, action_cooldown, 1 SECONDS)
	bot.face_atom(target)
	bot.animation_attack_on(target)
	bot.flick_attack_overlay(target, "punch")
	playsound(bot.loc, 'sound/weapons/genhit3.ogg', 50, TRUE)
	bot.visible_message(SPAN_DANGER("[bot] slams its arm into [target]!"), null, null, 5)
	var/mob/cause_mob = bot.commander || bot
	target.last_damage_data = create_cause_data(initial(bot.name), cause_mob, bot)
	log_attack("[key_name(cause_mob)] hit [key_name(target)] with [bot] at [get_area_name(bot)]")
	target.apply_damage(rand(melee_damage_lower, melee_damage_upper), BRUTE)
	return TRUE

/obj/item/ruv_module/arm/proc/can_pull(atom/target)
	if(!ismovable(target))
		return FALSE
	var/atom/movable/movable_target = target
	return !movable_target.anchored

/// Loose atoms get grabbed, anchored machines and structures get pressed, opened or toggled
/obj/item/ruv_module/arm/proc/can_interact_with(atom/target, pull_only = FALSE)
	if(can_pull(target))
		return TRUE
	return !pull_only && isobj(target) && !isitem(target)

/obj/item/ruv_module/arm/proc/use_on(atom/target, mob/living/simple_animal/ruv/bot, pull_only = FALSE)
	if(!COOLDOWN_FINISHED(src, action_cooldown) || !bot.Adjacent(target) || !can_interact_with(target, pull_only))
		return FALSE
	if(!bot.use_charge(RUV_ARM_COST))
		return FALSE
	COOLDOWN_START(src, action_cooldown, 0.5 SECONDS)
	bot.face_atom(target)
	if(can_pull(target))
		if(bot.pulling != target)
			bot.stop_pulling()
		bot.start_pulling(target)
		return bot.pulling == target
	bot.animation_attack_on(target)
	target.attack_hand(bot)
	return TRUE

// Sentry

/obj/item/ruv_module/sentry
	name = "RUV sentry module"
	desc = "A compact sentry turret for an RUV, fed from standard sentry ammo drums."
	icon_state = "sentry_mode"
	bot_icon_state = "sentry"
	/// Starts as a type path, replaced by the instance in Initialize()
	var/obj/item/ammo_magazine/sentry/magazine = /obj/item/ammo_magazine/sentry
	var/fire_delay = 0.6 SECONDS
	var/burst = 2
	var/burst_delay = 0.15 SECONDS
	var/range = 7
	var/firing_sound = 'sound/weapons/gun_smartgun1.ogg'
	COOLDOWN_DECLARE(fire_cooldown)
	COOLDOWN_DECLARE(empty_message_cooldown)

/obj/item/ruv_module/sentry/Initialize(mapload, ...)
	. = ..()
	if(ispath(magazine))
		magazine = new magazine(src)

/obj/item/ruv_module/sentry/Destroy()
	QDEL_NULL(magazine)
	return ..()

/obj/item/ruv_module/sentry/get_status_text()
	if(!magazine)
		return SPAN_NOTICE("Ammo: [SPAN_RED("<b>no drum</b>")]")
	var/ammo_percent = magazine.current_rounds / magazine.max_rounds * 100
	return SPAN_NOTICE("Ammo: [ruv_level_span(ammo_percent, "<b>[magazine.current_rounds]/[magazine.max_rounds]</b>")]")

/obj/item/ruv_module/sentry/get_usage_text()
	return "[..()] Load sentry ammo drums into it directly, or into the RUV it is installed on. While driving the RUV, click to fire; in automatic mode it shoots hostiles in range on its own."

/obj/item/ruv_module/sentry/attackby(obj/item/item, mob/user)
	if(istype(item, /obj/item/ammo_magazine/sentry))
		load_magazine(item, user)
		return
	return ..()

/obj/item/ruv_module/sentry/proc/load_magazine(obj/item/ammo_magazine/sentry/new_magazine, mob/user)
	if(new_magazine.current_rounds <= 0)
		to_chat(user, SPAN_WARNING("\The [new_magazine] is empty."))
		return
	if(!user.drop_inv_item_to_loc(new_magazine, src))
		return
	var/obj/item/ammo_magazine/sentry/old_magazine = magazine
	magazine = new_magazine
	if(old_magazine)
		old_magazine.update_icon()
		user.put_in_hands(old_magazine)
	playsound(src, 'sound/weapons/unload.ogg', 25, TRUE)
	user.visible_message(SPAN_NOTICE("[user] loads \a [new_magazine] into \the [src]."), SPAN_NOTICE("You load \the [new_magazine] into \the [src]."))

/obj/item/ruv_module/sentry/proc/can_hit(atom/target, mob/living/simple_animal/ruv/bot)
	return get_dist(bot, target) <= range && bot.has_clear_line(target)

/obj/item/ruv_module/sentry/proc/fire(atom/target, mob/living/simple_animal/ruv/bot)
	if(!COOLDOWN_FINISHED(src, fire_cooldown) || !isturf(bot.loc) || get_turf(target) == get_turf(bot))
		return FALSE
	if(!magazine || magazine.current_rounds <= 0)
		if(COOLDOWN_FINISHED(src, empty_message_cooldown))
			COOLDOWN_START(src, empty_message_cooldown, 3 SECONDS)
			playsound(bot.loc, 'sound/weapons/smg_empty_alarm.ogg', 25, TRUE)
			bot.visible_message(SPAN_WARNING("[bot] beeps steadily and its ammo light blinks red."), null, null, 5)
		return FALSE
	if(!bot.use_charge(RUV_SHOT_COST))
		return FALSE
	COOLDOWN_START(src, fire_cooldown, fire_delay)
	bot.setDir(get_dir(bot, target))
	playsound(bot.loc, firing_sound, 50, TRUE)
	fire_projectile(target, bot, burst)
	return TRUE

/obj/item/ruv_module/sentry/proc/fire_projectile(atom/target, mob/living/simple_animal/ruv/bot, shots_left)
	if(QDELETED(bot) || bot.module != src || QDELETED(target) || !magazine || magazine.current_rounds <= 0)
		return
	var/obj/projectile/projectile = new(bot, create_cause_data(initial(bot.name), bot.commander || bot, bot))
	projectile.generate_bullet(new magazine.default_ammo)
	GIVE_BULLET_TRAIT(projectile, /datum/element/bullet_trait_iff, bot.faction_group)
	projectile.fire_at(target, bot, bot, projectile.ammo.max_range, projectile.ammo.shell_speed)
	magazine.current_rounds--
	if(shots_left > 1)
		addtimer(CALLBACK(src, PROC_REF(fire_projectile), target, bot, shots_left - 1), burst_delay)
