/// A group of AI vehicles the game master commands together, listed in the human AI management panel
/datum/vehicle_ai_squad
	/// Number of the squad, unique for the round
	var/id
	/// Name game masters gave the squad, if any
	var/name
	/// Brains of the vehicles in the squad
	var/list/datum/vehicle_ai_brain/members = list()

/datum/vehicle_ai_squad/New()
	. = ..()
	id = ++SSvehicle_ai.last_squad_id
	SSvehicle_ai.squads += src

/datum/vehicle_ai_squad/Destroy(force, ...)
	SSvehicle_ai.squads -= src
	for(var/datum/vehicle_ai_brain/member as anything in members.Copy())
		remove_member(member)
	return ..()

/datum/vehicle_ai_squad/proc/get_name()
	return name || "Vehicle squad #[id]"

/datum/vehicle_ai_squad/proc/add_member(datum/vehicle_ai_brain/member)
	if(member.squad == src)
		return

	member.squad?.remove_member(member)
	member.squad = src
	members += member

/datum/vehicle_ai_squad/proc/remove_member(datum/vehicle_ai_brain/member)
	members -= member
	if(member.squad == src)
		member.squad = null

/datum/vehicle_ai_brain
	/// The squad of vehicles this one is commanded with, if any
	var/datum/vehicle_ai_squad/squad
