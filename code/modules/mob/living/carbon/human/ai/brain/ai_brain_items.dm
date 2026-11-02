/datum/human_ai_brain
	/// If an AI takes out an item from their equipment_map, the place it was last stored is added to this dict
	var/list/equipped_items_original_loc = list()

	/// A list of items that the AI is trying to pick up
	var/list/obj/item/to_pickup = list()

	/// If TRUE, the AI won't try to pick up anything
	var/ignore_looting = FALSE

	/// list("object_type" = list(object_ref = "slot")
	var/list/equipment_map = list(
		HUMAN_AI_HEALTHITEMS = list(),
		HUMAN_AI_AMMUNITION = list(),
		HUMAN_AI_GRENADES = list(),
		HUMAN_AI_TOOLS = list(),
	)

	/// Dict of "storage type" : storage ref
	var/list/container_refs = list(
		"belt" = null,
		"backpack" = null,
		"left_pocket" = null,
		"right_pocket" = null,
		"armor" = null,
		"armor_webbing" = null,
		"uniform" = null,
	)

	/// Static list of storage slots that the AI pays attention to for inventory appraisal
	var/static/list/important_storage_slots = list(
		WEAR_BACK,
		WEAR_WAIST,
		WEAR_L_STORE,
		WEAR_R_STORE,
		WEAR_JACKET,
		WEAR_BODY,
	)

	/// Bitflag equivalent of important_storage_slots
	var/static/important_storage_slots_bitflag = SLOT_BACK | SLOT_WAIST | SLOT_STORE | SLOT_OCLOTHING | SLOT_ICLOTHING

	/// Slots where a gun is ready to be drawn without digging through storage
	var/static/list/weapon_slots = list(
		WEAR_L_HAND,
		WEAR_R_HAND,
		WEAR_J_STORE,
		WEAR_BACK,
		WEAR_WAIST,
	)

	/// If TRUE, the AI ignores darkness when it comes to determining vision
	var/has_nightvision = FALSE

	/// How often the AI looks around for items worth picking up
	var/item_search_delay = 0.6 SECONDS
	COOLDOWN_DECLARE(item_search_cooldown)

/// Given a "storage type", returns the storage item
/datum/human_ai_brain/proc/get_object_from_loc(object_loc)
	RETURN_TYPE(/obj/item/storage)

	var/obj/item/storage/storage_object
	switch(object_loc)
		if("belt")
			storage_object = tied_human.belt
		if("backpack")
			storage_object = tied_human.back
		if("left_pocket")
			storage_object = tied_human.l_store
		if("right_pocket")
			storage_object = tied_human.r_store
		if("armor")
			if(istype(tied_human.wear_suit, /obj/item/clothing/suit/storage))
				var/obj/item/clothing/suit/storage/storage_suit = tied_human.wear_suit
				storage_object = storage_suit.pockets
		if("armor_webbing")
			if(LAZYLEN(tied_human.wear_suit?.accessories))
				var/obj/item/clothing/accessory/storage/armor_webbing = locate() in tied_human.wear_suit.accessories
				storage_object = armor_webbing?.hold
		if("uniform")
			if(LAZYLEN(tied_human.w_uniform?.accessories))
				var/obj/item/clothing/accessory/storage/storage_accessory = locate() in tied_human.w_uniform.accessories
				storage_object = storage_accessory?.hold

	// Belts and backs can hold guns instead of storage
	if(istype(storage_object))
		return storage_object

/// Returns TRUE if the AI wears, holds or stores the thing, even in a box inside a backpack
/datum/human_ai_brain/proc/is_in_inventory(atom/movable/thing)
	var/atom/holder = thing?.loc
	for(var/depth in 1 to 4)
		if(holder == tied_human)
			return TRUE
		if(!holder || isturf(holder))
			return FALSE
		holder = holder.loc
	return FALSE

/// Given a location and a reference, puts a referenced object into the AI's hand if possible
/datum/human_ai_brain/proc/equip_item_from_equipment_map(object_type, obj/item/object_ref)
	if(!object_type || !object_ref)
		return

	if(tied_human.is_holding(object_ref))
		ensure_primary_hand(object_ref)
		return TRUE

	// The item can sit in a first-aid kit inside the container it is mapped to
	var/obj/item/storage/storage_object = object_ref.loc
	if(!istype(storage_object) || !is_in_inventory(object_ref))
		equipment_map[object_type] -= object_ref
		return FALSE

	if(tied_human.get_active_hand())
		return FALSE

	storage_object.remove_from_storage(object_ref, tied_human)
	if(!tied_human.put_in_active_hand(object_ref))
		storage_object.handle_item_insertion(object_ref, TRUE, tied_human)
		return FALSE

	equipped_items_original_loc[object_ref] = equipment_map[object_type][object_ref]
	RegisterSignal(object_ref, COMSIG_ITEM_DROPPED, PROC_REF(on_equipment_dropped), override = TRUE)
	return TRUE

/// Given an object path and where it may be stored, returns a ref to that object if it exists
/datum/human_ai_brain/proc/get_item_from_equipment_map_path(object_path, object_type)
	return (locate(object_path) in equipment_map[object_type])

/// Puts a held item back into storage, preferably where it was taken from. Returns TRUE on success
/datum/human_ai_brain/proc/store_item(obj/item/object_ref, object_loc, slot_type)
	if(object_ref.loc != tied_human)
		return FALSE

	if(object_ref in equipped_items_original_loc)
		var/original_loc = equipped_items_original_loc[object_ref]
		equipped_items_original_loc -= object_ref
		var/obj/item/storage/original_storage = get_object_from_loc(original_loc)
		if(original_storage?.can_be_inserted(object_ref, tied_human, TRUE))
			object_loc = original_loc

	var/obj/item/storage/storage_item = get_object_from_loc(object_loc) // we assume that we've already checked if something will fit or not
	if(!storage_item?.attempt_item_insertion(object_ref, FALSE, tied_human))
		return FALSE

	if(slot_type)
		equipment_map[slot_type][object_ref] = object_loc
	to_pickup -= object_ref
	return TRUE

/// Whenever an item is deleted, purge it from anywhere it may be stored in here
/datum/human_ai_brain/proc/on_item_delete(obj/item/source, force)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	to_pickup -= source
	equipped_items_original_loc -= source

	for(var/name in container_refs)
		if(source == container_refs[name])
			container_refs[name] = null
			return

	for(var/id in equipment_map)
		equipment_map[id] -= source

/datum/human_ai_brain/proc/on_item_equip(datum/source, obj/item/equipment, slot)
	SIGNAL_HANDLER
	to_pickup -= equipment

	if((slot in important_storage_slots) && istype(equipment, /obj/item/storage))
		appraise_inventory(slot == WEAR_WAIST, slot == WEAR_BACK, slot == WEAR_L_STORE, slot == WEAR_R_STORE, slot == WEAR_JACKET, slot == WEAR_BODY)

	if(isgun(equipment) && (slot in weapon_slots))
		appraise_weapons()

	if(istype(equipment, /obj/item/clothing/glasses/night) && (slot == WEAR_EYES))
		has_nightvision = TRUE

/datum/human_ai_brain/proc/on_item_unequip(datum/source, obj/item/equipment, slot)
	SIGNAL_HANDLER

	if((important_storage_slots_bitflag & slot) && istype(equipment, /obj/item/storage))
		appraise_inventory(slot == SLOT_WAIST, slot == SLOT_BACK, slot == SLOT_STORE, slot == SLOT_STORE, slot == SLOT_OCLOTHING, slot == SLOT_ICLOTHING)

	if(istype(equipment, /obj/item/clothing/glasses/night) && (slot == WEAR_EYES))
		has_nightvision = FALSE

/// Reappraises what storage items the AI has
/datum/human_ai_brain/proc/recalculate_containers()
	for(var/container_id in container_refs)
		container_refs[container_id] = get_object_from_loc(container_id)

/// Currently supports one level of nested storage, like a first-aid kit in a backpack
/// Used to determine what the AI has in their inventory
/datum/human_ai_brain/proc/appraise_inventory(belt = TRUE, back = TRUE, pocket_l = TRUE, pocket_r = TRUE, armor = TRUE, uniform = TRUE)
	if(previous_faction != tied_human.faction)
		previous_faction = tied_human.faction
		var/datum/human_ai_faction/our_faction = SShuman_ai.human_ai_factions[tied_human.faction]
		our_faction?.apply_faction_data(src)

	/*if(tied_human.shoes && !primary_melee) // snowflake bootknife check
		var/obj/item/weapon/knife = locate() in tied_human.shoes
		if(knife)
			set_primary_melee(knife)*/

	recalculate_containers()

	tried_reload = FALSE // We don't really need to do this in a smart way
	if(belt)
		appraise_belt()

	if(back)
		appraise_back()

	if(pocket_l)
		appraise_left_pocket()

	if(pocket_r)
		appraise_right_pocket()

	if(armor)
		appraise_armor()

	if(uniform)
		appraise_uniform()

	appraise_weapons()

/// Forgets every item mapped to the container, so that it can be looped through again
/datum/human_ai_brain/proc/clear_container_items(container_id)
	for(var/id in equipment_map)
		for(var/obj/item/item as anything in equipment_map[id])
			if(equipment_map[id][item] == container_id)
				equipment_map[id] -= item

/datum/human_ai_brain/proc/appraise_belt()
	clear_container_items("belt")

	var/obj/item/storage/belt_storage = container_refs["belt"] // belts can be backpacks, don't ask
	if(!belt_storage)
		return

	RegisterSignal(belt_storage, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
	item_slot_appraisal_loop(belt_storage, "belt")

/datum/human_ai_brain/proc/appraise_back()
	clear_container_items("backpack")

	// Scabbards and other holsters count, the guns inside them are found by the loop
	var/obj/item/storage/back_storage = container_refs["backpack"]
	if(!back_storage)
		return

	RegisterSignal(back_storage, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
	item_slot_appraisal_loop(back_storage, "backpack")

/datum/human_ai_brain/proc/appraise_left_pocket()
	clear_container_items("left_pocket")

	var/obj/item/storage/pocket_storage = container_refs["left_pocket"]
	if(!istype(pocket_storage, /obj/item/storage/pouch))
		return

	RegisterSignal(pocket_storage, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
	item_slot_appraisal_loop(pocket_storage, "left_pocket")

/datum/human_ai_brain/proc/appraise_right_pocket()
	clear_container_items("right_pocket")

	var/obj/item/storage/pocket_storage = container_refs["right_pocket"]
	if(!istype(pocket_storage, /obj/item/storage/pouch))
		return

	RegisterSignal(pocket_storage, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
	item_slot_appraisal_loop(pocket_storage, "right_pocket")

/datum/human_ai_brain/proc/appraise_armor()
	clear_container_items("armor")
	clear_container_items("armor_webbing")

	var/obj/item/clothing/suit/worn_armor = tied_human.wear_suit
	if(!istype(worn_armor))
		return

	if(worn_armor.has_light && !worn_armor.light_on && tied_human.loc) // being in nullspace makes lights play weirdly
		worn_armor.turn_light(tied_human, TRUE)

	for(var/container_id in list("armor", "armor_webbing"))
		var/obj/item/storage/armor_storage = container_refs[container_id]
		if(!armor_storage)
			continue

		RegisterSignal(armor_storage, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
		item_slot_appraisal_loop(armor_storage, container_id)

/datum/human_ai_brain/proc/appraise_uniform()
	clear_container_items("uniform")

	var/obj/item/storage/uniform_storage = container_refs["uniform"]
	if(!uniform_storage)
		return

	RegisterSignal(uniform_storage, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
	item_slot_appraisal_loop(uniform_storage, "uniform")

/// Returns the equipment_map category the item belongs to, if any
/datum/human_ai_brain/proc/get_equipment_map_type(obj/item/thing)
	if(thing.flags_human_ai & HEALING_ITEM)
		return HUMAN_AI_HEALTHITEMS
	if(thing.flags_human_ai & AMMUNITION_ITEM)
		return HUMAN_AI_AMMUNITION
	if(thing.flags_human_ai & GRENADE_ITEM)
		return HUMAN_AI_GRENADES
	if(thing.flags_human_ai & TOOL_ITEM)
		return HUMAN_AI_TOOLS

/datum/human_ai_brain/proc/item_slot_appraisal_loop(obj/item/container_to_loop, slot_to_assign, depth = 0)
	for(var/obj/item/inv_item as anything in container_to_loop)
		var/map_type = get_equipment_map_type(inv_item)
		if(map_type)
			equipment_map[map_type][inv_item] = slot_to_assign
		else if(isgun(inv_item))
			if(inv_item != primary_weapon)
				add_secondary_weapon(inv_item)
			continue
		else
			// First-aid kits, ammo boxes and the like
			if(isstorage(inv_item) && !depth)
				item_slot_appraisal_loop(inv_item, slot_to_assign, depth + 1)
			continue

		RegisterSignal(inv_item, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)

		//else if((inv_item.flags_human_ai & MELEE_WEAPON_ITEM) && !primary_melee)
		//	set_primary_melee(inv_item)

/// Registers the guns the AI holds or wears outside of storage, and picks a primary weapon if it has none
/datum/human_ai_brain/proc/appraise_weapons()
	var/list/obj/item/weapon/gun/held_guns = list()
	for(var/obj/item/weapon/gun/gun in list(tied_human.get_active_hand(), tied_human.get_inactive_hand()))
		held_guns += gun

	for(var/obj/item/weapon/gun/gun in held_guns + list(tied_human.s_store, tied_human.back, tied_human.belt))
		if(gun != primary_weapon)
			add_secondary_weapon(gun)

	for(var/obj/item/weapon/gun/secondary as anything in secondary_weapons)
		if(!is_in_inventory(secondary))
			remove_secondary_weapon(secondary)

	if(primary_weapon)
		return

	// A gun put into our hands is the one we are meant to fight with
	var/obj/item/weapon/gun/best_gun
	for(var/obj/item/weapon/gun/held_gun as anything in held_guns)
		if(held_gun.ai_can_use(tied_human, src))
			best_gun = held_gun
			break

	if(!best_gun)
		var/best_weight = -INFINITY
		for(var/obj/item/weapon/gun/secondary as anything in secondary_weapons)
			if(!secondary.ai_can_use(tied_human, src))
				continue

			var/datum/firearm_appraisal/appraisal = get_firearm_appraisal(secondary)
			var/weight = appraisal ? appraisal.primary_weight : 0
			if(weight > best_weight)
				best_gun = secondary
				best_weight = weight

	if(!best_gun)
		return

	remove_secondary_weapon(best_gun)
	set_primary_weapon(best_gun)

/// Frees the active hand: the held item is put away, or the hands are swapped if only the active one is busy
/datum/human_ai_brain/proc/clear_main_hand()
	var/obj/item/active_hand = tied_human.get_active_hand()
	if(!active_hand)
		return

	if(primary_weapon == active_hand)
		primary_weapon.unwield(tied_human)
		if(holster_primary())
			return

	else
		var/storage_id = storage_has_room(active_hand)
		if(storage_id && store_item(active_hand, storage_id, get_equipment_map_type(active_hand)))
			return

	if(!tied_human.get_inactive_hand())
		tied_human.swap_hand()
		return

	tied_human.drop_held_item(active_hand)

/datum/human_ai_brain/proc/storage_has_room(obj/item/inserting)
	for(var/container_id in container_refs)
		var/obj/item/storage/container = container_refs[container_id]
		if(container?.can_be_inserted(inserting, tied_human, TRUE))
			return container_id

/datum/human_ai_brain/proc/on_equipment_dropped(obj/item/source, mob/dropper)
	SIGNAL_HANDLER

	if(isturf(source.loc))
		equipped_items_original_loc -= source
		UnregisterSignal(source, COMSIG_ITEM_DROPPED)

/datum/human_ai_brain/proc/on_item_pickup(datum/source, obj/item/picked_up)
	SIGNAL_HANDLER

	if(!primary_weapon && isgun(picked_up))
		remove_secondary_weapon(picked_up)
		set_primary_weapon(picked_up)

	to_pickup -= picked_up

/datum/human_ai_brain/proc/on_item_drop(datum/source, obj/item/dropped)
	SIGNAL_HANDLER
	if(iszombie(tied_human))
		return

	if(dropped == primary_weapon)
		if(!(gun_data?.disposable && !primary_weapon.ai_can_use(tied_human, src)))
			to_pickup |= dropped
		set_primary_weapon(null)

	for(var/slot in container_refs)
		if(container_refs[slot] == dropped)
			appraise_inventory(slot == "belt", slot == "backpack", slot == "left_pocket", slot == "right_pocket", slot == "armor", slot == "uniform")
			break

	for(var/id in equipment_map)
		if(dropped in equipment_map[id])
			equipment_map[id] -= dropped
			return

/datum/human_ai_brain/proc/set_primary_weapon(obj/item/weapon/gun/new_gun)
	if(primary_weapon)
		UnregisterSignal(primary_weapon, COMSIG_PARENT_QDELETING)
		if(primary_weapon in secondary_weapons)
			RegisterSignal(primary_weapon, COMSIG_PARENT_QDELETING, PROC_REF(on_secondary_delete))
	primary_weapon = new_gun
	gun_data = null
	appraise_primary()
	if(primary_weapon)
		RegisterSignal(primary_weapon, COMSIG_PARENT_QDELETING, PROC_REF(on_primary_delete), TRUE)

/datum/human_ai_brain/proc/on_primary_delete(datum/source, force)
	SIGNAL_HANDLER

	set_primary_weapon(null)
	to_pickup -= source

/*datum/human_ai_brain/proc/set_primary_melee(obj/item/weapon/new_melee)
	if(primary_melee)
		UnregisterSignal(primary_melee, COMSIG_PARENT_QDELETING)
	primary_melee = new_melee
	appraise_primary()
	if(primary_melee)
		RegisterSignal(primary_melee, COMSIG_PARENT_QDELETING, PROC_REF(on_primary_melee_delete))

/datum/human_ai_brain/proc/on_primary_melee_delete(datum/source, force)
	SIGNAL_HANDLER

	set_primary_melee(null)*/

/datum/human_ai_brain/proc/appraise_primary()
	if(!primary_weapon)
		return
	var/static/datum/firearm_appraisal/default = new()
	gun_data = get_firearm_appraisal(primary_weapon) || default

/datum/human_ai_brain/proc/item_search(list/things_around)
	search_loop:
		for(var/obj/item/thing in things_around)
			if(!isturf(thing.loc))
				continue

			if(thing in to_pickup)
				continue

			if(thing.flags_human_ai & GRENADE_ITEM)
				var/obj/item/explosive/grenade/nade = thing
				if(nade.active && (nade.fuse_type == IMPACT_FUSE))
					return
				else if(nade.active && (nade.fuse_type == TIMED_FUSE))
					active_grenade_found = thing
					continue

			if(!primary_weapon && isgun(thing))
				var/obj/item/weapon/gun/thing_gun = thing
				for(var/item in to_pickup)
					if(isgun(item)) // One weapon at a time
						continue search_loop

				var/datum/firearm_appraisal/appraisal = get_firearm_appraisal(thing_gun)
				if(appraisal?.disposable && thing_gun.current_mag?.current_rounds <= 0)
					continue search_loop

				add_to_pickup(thing)

			if(istype(thing, /obj/item/storage/belt) && !container_refs["belt"])
				add_to_pickup(thing)

			if(istype(thing, /obj/item/storage/backpack) && !container_refs["backpack"])
				add_to_pickup(thing)

			if(istype(thing, /obj/item/storage/pouch) && (!container_refs["left_pocket"] || !container_refs["right_pocket"]))
				add_to_pickup(thing)

			if(!(thing.flags_human_ai & (HEALING_ITEM|AMMUNITION_ITEM|GRENADE_ITEM|TOOL_ITEM)))
				continue

			var/storage_spot = storage_has_room(thing)
			if(!storage_spot || !thing.ai_can_use(tied_human, src, tied_human))
				continue

			if(thing.flags_human_ai & HEALING_ITEM)
				add_to_pickup(thing)

			if((thing.flags_human_ai & AMMUNITION_ITEM) && primary_weapon)
				var/obj/item/ammo_magazine/mag = thing
				if(istype(primary_weapon, mag.gun_type))
					add_to_pickup(thing)

			if(thing.flags_human_ai & GRENADE_ITEM)
				add_to_pickup(thing)

			if(thing.flags_human_ai & TOOL_ITEM)
				add_to_pickup(thing)

/datum/human_ai_brain/proc/add_to_pickup(obj/item/thing)
	RegisterSignal(thing, COMSIG_PARENT_QDELETING, PROC_REF(on_item_delete), TRUE)
	to_pickup += thing

/datum/human_ai_brain/proc/get_tool_from_equipment_map(tool_trait)
	RETURN_TYPE(/obj/item)
	for(var/obj/item/maybe_tool as anything in equipment_map[HUMAN_AI_TOOLS])
		if(!HAS_TRAIT(maybe_tool, tool_trait))
			continue
		return maybe_tool

/datum/human_ai_brain/proc/add_secondary_weapon(obj/item/weapon/gun/secondary)
	if(!secondary || (secondary in secondary_weapons))
		return

	secondary_weapons += secondary
	RegisterSignal(secondary, COMSIG_PARENT_QDELETING, PROC_REF(on_secondary_delete), TRUE)

/datum/human_ai_brain/proc/remove_secondary_weapon(obj/item/weapon/gun/secondary)
	if(!(secondary in secondary_weapons))
		return

	UnregisterSignal(secondary, COMSIG_PARENT_QDELETING)
	secondary_weapons -= secondary

/datum/human_ai_brain/proc/on_secondary_delete(datum/source, force)
	SIGNAL_HANDLER

	remove_secondary_weapon(source)

/datum/human_ai_brain/proc/weapon_ammo_search(obj/item/weapon/gun/weapon)
	for(var/obj/item/ammo_magazine/mag as anything in equipment_map[HUMAN_AI_AMMUNITION])
		if(istype(weapon, mag.gun_type) && mag.ai_can_use(tied_human, src))
			return mag
