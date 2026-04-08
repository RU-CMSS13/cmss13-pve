//*******************************************************************************
//AMMO
//*******************************************************************************/

//------------------------Ammunition Boxes crates----------------

/datum/supply_packs/ammo_rounds_box_smg
	name = "SMG ammo box crate (10x20mm) (x600 rounds)"
	contains = list(/obj/item/ammo_box/rounds/smg)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper SMG ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_rounds_box_smg_ap
	name = "SMG AP ammo box crate (10x20mm AP) (x600 rounds)"
	contains = list(/obj/item/ammo_box/rounds/smg/ap)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper SMG AP ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_rounds_box_rifle
	name = "Rifle ammo box crate (10x24mm) (x600 rounds)"
	contains = list(/obj/item/ammo_box/rounds)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper rifle ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_rounds_box_rifle_ap
	name = "Rifle AP ammo box crate (10x24mm AP) (x600 rounds)"
	contains = list(/obj/item/ammo_box/rounds/ap)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper rifle AP ammo crate"
	group = "Ammo"
//------------------------Magazine Boxes crates----------------

//------------------------For M41A----------------

/datum/supply_packs/ammo_mag_box
	name = "Magazine box (M41A, 10x regular mags)"
	contains = list(
		/obj/item/ammo_box/magazine/mk1,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M41A magazines crate"
	group = "Ammo"

/datum/supply_packs/ammo_mag_box_ap
	name = "Magazine box (M41A, 10x AP mags)"
	contains = list(
		/obj/item/ammo_box/magazine/mk1/ap,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M41A AP magazines crate"
	group = "Ammo"
//------------------------For M49A----------------

/datum/supply_packs/ammo_dmr_mag_box
	name = "Magazine box (M49A, 16x regular mags)"
	contains = list(
		/obj/item/ammo_box/magazine/m49a,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M49A magazines crate"
	group = "Ammo"

/datum/supply_packs/ammo_dmr_mag_box_ap
	name = "Magazine box (M49A, 16x AP mags)"
	contains = list(
		/obj/item/ammo_box/magazine/m49a/ap,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M49A AP magazines crate"
	group = "Ammo"

//------------------------For M39----------------

/datum/supply_packs/ammo_smg_mag_box
	name = "Magazine box (M39, 12x regular mags)"
	contains = list(
		/obj/item/ammo_box/magazine/m39,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M39 HV magazines crate"
	group = "Ammo"

/datum/supply_packs/ammo_smg_mag_box_ap
	name = "Magazine box (M39, 12x AP mags)"
	contains = list(
		/obj/item/ammo_box/magazine/m39/ap,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M39 AP magazines crate"
	group = "Ammo"

//------------------------For M49A----------------

/datum/supply_packs/ammo_m49a_mag_box
	name = "Magazine box (M49A, 16x mags)"
	contains = list(
		/obj/item/ammo_box/magazine/m49a,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M49A magazines crate"
	group = "Ammo"

/datum/supply_packs/ammo_m49a_mag_box_ap
	name = "Magazine box (M49A, 16x AP mags)"
	contains = list(
		/obj/item/ammo_box/magazine/m49a/ap,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M49A AP magazines crate"
	group = "Ammo"

	name = "M49A/2 Mixed Magazine Crate (regular x2, incendiary x2, explosive x2)"
	contains = list(
		/obj/item/ammo_magazine/rifle/m49a/custom,
		/obj/item/ammo_magazine/rifle/m49a/custom,
		/obj/item/ammo_magazine/rifle/m49a/custom/incendiary,
		/obj/item/ammo_magazine/rifle/m49a/custom/incendiary,
		/obj/item/ammo_magazine/rifle/m49a/custom/explosive,
		/obj/item/ammo_magazine/rifle/m49a/custom/explosive,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "M49A/2 Mixed Magazine Crate"
	group = "Ammo"

//------------------------For  M44----------------

/datum/supply_packs/ammo_m44_mag_box
	name = "Speed loaders box (M44, 16x)"
	contains = list(
		/obj/item/ammo_box/magazine/m44,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M44 speed loaders crate"
	group = "Ammo"

/datum/supply_packs/ammo_m44_mag_box_ap
	name = "Speed loaders box (Marksman M44, 16x)"
	contains = list(
		/obj/item/ammo_box/magazine/m44/marksman,
	)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M44 Marksman speed loaders crate"
	group = "Ammo"

/datum/supply_packs/ammo_m44_mag_box_heavy
	name = "Speed loaders box (Heavy M44, 16x)"
	contains = list(
		/obj/item/ammo_box/magazine/m44/heavy,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M44 Heavy speed loaders crate"
	group = "Ammo"

//------------------------For  M4A3----------------

/datum/supply_packs/ammo_m4a3_mag_box
	name = "Magazine box (M4A3, 16x regular mags)"
	contains = list(
		/obj/item/ammo_box/magazine/m4a3,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M4A3 magazines crate"
	group = "Ammo"

/datum/supply_packs/ammo_m4a3_mag_box_ap
	name = "Magazine box (M4A3, 16x AP mags)"
	contains = list(
		/obj/item/ammo_box/magazine/m4a3/ap,
	)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M4A3 AP magazines crate"
	group = "Ammo"

/datum/supply_packs/ammo_m4a3_mag_box_hp
	name = "Magazine box (M4A3, 16x HP mags)"
	contains = list(
		/obj/item/ammo_box/magazine/m4a3/hp,
	)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M4A3 HP magazines crate"
	group = "Ammo"

//------------------------For  Shootgun ammo----------------

/datum/supply_packs/ammo_shell_box
	name = "Shell box (100x slug shells)"
	contains = list(
		/obj/item/ammo_box/magazine/shotgun,
	)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper shotgun slugs crate"
	group = "Ammo"

/datum/supply_packs/ammo_shell_box_buck
	name = "Shell box (100x buckshot shells)"
	contains = list(
		/obj/item/ammo_box/magazine/shotgun/buckshot,
	)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper shotgun buckshot crate"
	group = "Ammo"

/datum/supply_packs/ammo_shell_box_flechette
	name = "Shell box (100x flechette shells)"
	contains = list(
		/obj/item/ammo_box/magazine/shotgun/flechette,
	)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper shotgun flechette crate"
	group = "Ammo"
//------------------------For vp70 ----------------

/datum/supply_packs/ammo_vp70_mag_box_ap
	name = "Magazine box (VP70, 16x mags)"
	contains = list(
		/obj/item/ammo_box/magazine/vp70,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper VP70 magazines crate"
	group = "Ammo"

//------------------------Special or non common magazines----------------

/datum/supply_packs/ammo_vp78_mag_box
	name = "Magazine box (VP78, 16x mags)"
	contains = list(
		/obj/item/ammo_box/magazine/vp78,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper VP78 magazines crate"
	group = "Ammo"

/datum/supply_packs/ammo_su6_mag_box
	name = "Magazine box (SU-6, 16x mags)"
	contains = list(
		/obj/item/ammo_box/magazine/su6,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper SU-6 magazines crate"
	group = "Ammo"

/datum/supply_packs/ammo_hpr
	contains = list(
		/obj/item/ammo_magazine/hpr_box,
		/obj/item/ammo_magazine/hpr_box,
		/obj/item/ammo_magazine/hpr_box,
		/obj/item/ammo_magazine/hpr_box,
	)
	name = "M41AE2 magazine crate"
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M41AE2 magazine crate"
	group = "Ammo"

/datum/supply_packs/ammo_hpr_holo
	contains = list(
		/obj/item/ammo_magazine/hpr_box/holo_target,
		/obj/item/ammo_magazine/hpr_box/holo_target,
		/obj/item/ammo_magazine/hpr_box/holo_target,
		/obj/item/ammo_magazine/hpr_box/holo_target,
	)
	name = "M41AE2 magazine crate"
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M41AE2 holo-target magazine crate"
	group = "Ammo"

//------------------------Smartgunner stuff----------------

/datum/supply_packs/ammo_smartgun_battery_pack
	name = "M56 smartgun battery crate (x4)"
	contains = list(
		/obj/item/smartgun_battery,
		/obj/item/smartgun_battery,
		/obj/item/smartgun_battery,
		/obj/item/smartgun_battery,
	)
	cost = 60
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper smartgun battery crate"
	group = "Ammo"

/datum/supply_packs/ammo_smartgun
	name = "M56 smartgun drum crate (x2)"
	contains = list(
		/obj/item/ammo_magazine/smartgun,
		/obj/item/ammo_magazine/smartgun,
	)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper smartgun drums crate"
	group = "Ammo"

//------------------------Sentries Ammo----------------
/datum/supply_packs/ammo_sentry
	name = "UA 571-C sentry ammunition (x2)"
	contains = list(
		/obj/item/ammo_magazine/sentry,
		/obj/item/ammo_magazine/sentry,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper sentry ammo crate"
	group = "Ammo"

//------------------------M240 flamer tanks----------------

/datum/supply_packs/ammo_napalm
	name = "M240 UT-Napthal Fuel (x4)"
	contains = list(
		/obj/item/ammo_magazine/flamer_tank,
		/obj/item/ammo_magazine/flamer_tank,
		/obj/item/ammo_magazine/flamer_tank,
		/obj/item/ammo_magazine/flamer_tank,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo/alt/flame
	containername = "\improper napthal fuel crate"
	group = "Ammo"

/datum/supply_packs/ammo_napalm_gel
	name = "M240 Napalm B-Gel (x4)"
	contains = list(
		/obj/item/ammo_magazine/flamer_tank/gellied,
		/obj/item/ammo_magazine/flamer_tank/gellied,
		/obj/item/ammo_magazine/flamer_tank/gellied,
		/obj/item/ammo_magazine/flamer_tank/gellied,
	)
	cost = 60
	containertype = /obj/structure/closet/crate/ammo/alt/flame
	containername = "\improper napalm gel crate"
	group = "Ammo"

/datum/supply_packs/ammo_flamer_mixed
	name = "M240 Fuel Crate (x2 normal, x2 b-gel)"
	contains = list(
		/obj/item/ammo_magazine/flamer_tank,
		/obj/item/ammo_magazine/flamer_tank,
		/obj/item/ammo_magazine/flamer_tank/gellied,
		/obj/item/ammo_magazine/flamer_tank/gellied,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo/alt/flame
	group = "Ammo"

//------------------------Mounted guns ammo----------------
/datum/supply_packs/ammo_m2c
	name = "M2C ammunition crate (x2)"
	contains = list(
		/obj/item/ammo_magazine/m2c,
		/obj/item/ammo_magazine/m2c,
	)
	cost = 25
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper m2c ammunition crate"
	group = "Ammo"

/datum/supply_packs/ammo_m56d
	name = "M56D drum magazine crate (x1)"
	contains = list(
		/obj/item/ammo_magazine/m56d,
	)
	cost = 25
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper m56d drum magazine crate"
	group = "Ammo"

//This crate has a little bit of everything, mostly okay stuff, but it does have some really unique picks.
