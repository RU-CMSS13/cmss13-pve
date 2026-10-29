/// Running costs sprint stamina per step taken, and running out of it drops the human to a walk until it regenerates.
/datum/component/sprint
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/current_sprint = SPRINT_MAX
	/// world.time after which sprint stamina starts to regenerate
	var/regen_after = 0
	/// world.time of the last step the human took on their own, running or walking
	var/last_step = 0

/datum/component/sprint/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/sprint/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(parent, COMSIG_LIVING_REJUVENATED, PROC_REF(on_rejuvenated))

/datum/component/sprint/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_REJUVENATED))
	STOP_PROCESSING(SSfastobj, src)

/datum/component/sprint/Destroy(force, silent)
	STOP_PROCESSING(SSfastobj, src)
	return ..()

/datum/component/sprint/proc/on_moved(mob/living/carbon/human/runner, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	// Only set by client/Move(), so pulls, throws, vehicles and human AI movement neither cost anything nor slow regeneration
	if(!runner.move_intentionally)
		return
	last_step = world.time
	if(runner.m_intent != MOVE_INTENT_RUN || runner.body_position == LYING_DOWN || !runner.stamina?.has_stamina)
		return

	regen_after = world.time + SPRINT_REGEN_DELAY
	adjust_sprint(-runner.calculate_sprint_cost())
	if(current_sprint <= 0)
		runner.set_movement_intent(MOVE_INTENT_WALK)
		to_chat(runner, SPAN_WARNING("You are out of breath and slow down to a walk."))
		INVOKE_ASYNC(runner, TYPE_PROC_REF(/mob, emote), "me", 1, "is out of breath.", FALSE)

/datum/component/sprint/proc/on_rejuvenated()
	SIGNAL_HANDLER
	adjust_sprint(SPRINT_MAX)

/datum/component/sprint/process(delta_time)
	if(world.time < regen_after)
		return
	var/mob/living/carbon/human/runner = parent
	var/regen = SPRINT_REGEN_RATE
	if(runner.body_position == LYING_DOWN || runner.buckled)
		regen *= SPRINT_REGEN_RESTING_MULT
	else if(world.time < last_step + SPRINT_MOVING_WINDOW)
		regen *= SPRINT_REGEN_MOVING_MULT
	adjust_sprint(regen * delta_time)

/datum/component/sprint/proc/adjust_sprint(amount)
	current_sprint = clamp(current_sprint + amount, 0, SPRINT_MAX)
	if(current_sprint < SPRINT_MAX)
		START_PROCESSING(SSfastobj, src)
	else
		STOP_PROCESSING(SSfastobj, src)
	update_hud()

/datum/component/sprint/proc/can_start_running()
	return current_sprint >= SPRINT_MIN_TO_RUN

/datum/component/sprint/proc/update_hud()
	var/mob/living/carbon/human/runner = parent
	runner.hud_used?.sprint_bar?.set_fraction(current_sprint / SPRINT_MAX, !can_start_running())
