/// Objects can only have one particle emitter at a time, so these abstract effects hold extra emitters.
/obj/effect/abstract/particle_holder
	name = "particle holder"
	desc = "How are you reading this? Please make a bug report."
	appearance_flags = KEEP_APART|TILE_BOUND
	plane = GAME_PLANE
	layer = ABOVE_FLY_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	/// Holds info about how this particle emitter works. See modular/halo/code/__DEFINES/halo_particles.dm.
	var/particle_flags = NONE
	var/atom/parent

/obj/effect/abstract/particle_holder/Initialize(mapload, particle_path = null, particle_flags = NONE)
	. = ..()
	if(!loc)
		stack_trace("particle holder was created with no loc")
		return INITIALIZE_HINT_QDEL
	if(!particle_path)
		return INITIALIZE_HINT_QDEL

	parent = loc
	loc = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	src.particle_flags = particle_flags
	particles = new particle_path()

	var/atom/movable/vis_parent = parent
	vis_parent.vis_contents += src
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(parent_deleted))

	if(particle_flags & PARTICLE_ATTACH_MOB)
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	on_move(parent, null, NORTH)

/obj/effect/abstract/particle_holder/Destroy(force)
	QDEL_NULL(particles)
	parent = null
	return ..()

/// Non-movables do not delete contents on destroy, so this holder tracks the parent explicitly.
/obj/effect/abstract/particle_holder/proc/parent_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/// Signal called when a parent hooked into this holder moves.
/obj/effect/abstract/particle_holder/proc/on_move(atom/movable/attached, atom/oldloc, direction)
	SIGNAL_HANDLER
	if(!(particle_flags & PARTICLE_ATTACH_MOB))
		return

	if(ismob(oldloc))
		var/mob/particle_mob = oldloc
		particle_mob.vis_contents -= src

	if(ismob(attached.loc))
		var/mob/particle_mob = attached.loc
		particle_mob.vis_contents += src

/// Sets the particle emitter position to the passed coordinates.
/obj/effect/abstract/particle_holder/proc/set_particle_position(x = 0, y = 0, z = 0)
	particles.position = list(x, y, z)

/obj/effect/abstract/particle_holder/reset_transform
	appearance_flags = KEEP_APART|TILE_BOUND|RESET_TRANSFORM
