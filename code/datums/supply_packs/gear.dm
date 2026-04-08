// add all the gear in this group.

/datum/supply_packs/binocs
	name = "Mixed Binoculars Crate ( x4 total)"
	cost = 20
	containertype = /obj/structure/closet/crate/green
	containername = "Mixed Binoculars Crate"
	group = "Gear"
	contains = list(
		/obj/item/device/binoculars/range/designator,
		/obj/item/device/binoculars/range,
		/obj/item/device/binoculars,
		/obj/item/device/binoculars,
	)

/datum/supply_packs/flares
	name = "flare packs crate (x20)"
	contains = list(
		/obj/item/ammo_box/magazine/misc/flares,
		/obj/item/ammo_box/magazine/misc/flares,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "flare pack crate"
	group = "Gear"


/datum/supply_packs/motiondetector
	name = "Motion Detector "
	contains = list(
		/obj/item/storage/box/guncase/heavy/motiondetectors
					)
	cost = 40
	containertype = /obj/structure/closet/crate/supply
	containername = "Motion Detector crate"
	group = "Gear"

/datum/supply_packs/signal_flares
	name = "signal flare packs crate (x4)"
	contains = list(
		/obj/item/storage/box/flare/signal,
		/obj/item/storage/box/flare/signal,
		/obj/item/storage/box/flare/signal,
		/obj/item/storage/box/flare/signal,
	)
	cost = 60
	containertype = /obj/structure/closet/crate/ammo
	containername = "signal flare pack crate"
	group = "Gear"
