/datum/ai_order/patrol
	name = "Patrol Waypoints"
	var/turf/current_waypoint
	var/list/waypoints = list()

	var/time_at_waypoint = 10 SECONDS
	var/current_waypoint_index = 1

	var/increment = 1
	var/waiting = FALSE

/datum/ai_order/patrol/New(list/arguments)
	. = ..()
	waypoints = arguments[1]
	current_waypoint = waypoints[1]

	time_at_waypoint = length(arguments) > 1 ? arguments[2] : 10 SECONDS

/datum/ai_order/patrol/tgui_data()
	return list(
		list(
			"waypoint_amount",
			"waiting",
			"desc",
		),
		list(
			length(waypoints),
			waiting,
			desc,
		)
	)

/datum/ai_order/patrol/proc/set_next_waypoint()
	var/patrol_length = length(waypoints)
	if(patrol_length == 1)
		increment = 0
	else if(current_waypoint_index <= 1)
		increment = 1
	else if(current_waypoint_index >= patrol_length)
		increment = -1
	current_waypoint_index += increment
	current_waypoint = waypoints[current_waypoint_index]
	waiting = FALSE
