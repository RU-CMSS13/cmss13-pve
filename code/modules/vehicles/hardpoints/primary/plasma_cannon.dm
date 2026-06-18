// Plasma cannon for ridgeway tank
// SS220 EDIT - START: PR #1266 D66-44 — translated name/desc to Russian
/obj/item/hardpoint/primary/cannon/plasmacannon
	name = "\improper Boyars PARS 177 орудие точечной обороны"
	desc = "Boyars PARS 177 Point-Defence-Weapon - это фазированное плазменное энергетическое оружие мощностью 20 кВт, предназначенное для защиты M40 Ridgeway от авиации, ракет и, неофициально, видимой вражеской пехоты. Желанное улучшение по сравнению со старыми лазерными системами M22 Jackson и M34 Longstreet: комплекс способен жёстко перехватывать воздушные цели и мгновенно испарять пехоту."
// SS220 EDIT - END

	icon = 'icons/obj/vehicles/hardpoints/tank.dmi'
	icon_state = "plasma_cannon"
	disp_icon = "ridgeway"
	disp_icon_state = "plasma_cannon"
	activation_sounds = list('sound/weapons/gun_xm99.ogg')

	health = 2300
	firing_arc = 60

	ammo = new /obj/item/ammo_magazine/hardpoint/plasmacannon
	max_clips = 3

	px_offsets = list(
		"1" = list(0, 46),
		"2" = list(0, -43),
		"4" = list(35, 2),
		"8" = list(-35, 2)
	)

	use_muzzle_flash = FALSE
	muzzleflash_icon_state = "muzzle_flash_blue"

	muzzle_flash_pos = list(
		"1" = list(0, 67),
		"2" = list(-1, -88),
		"4" = list(86, -6),
		"8" = list(-86, -6)
	)

	scatter = 0
	fire_delay = 10.0 SECONDS

/obj/item/hardpoint/primary/cannon/plasmacannon/handle_fire(atom/target, mob/living/user, /obj/vehicle/multitile/owner, params)
	var/datum/beam/plasma_beam
	if(!ammo.current_rounds)
		click_empty(owner)
		return
	plasma_beam = target.beam(owner, "light_beam", 'icons/effects/beam.dmi', time = 0.7 SECONDS, maxdistance = 30, beam_type = /obj/effect/ebeam/laser/plasma, always_turn = TRUE)
	animate(plasma_beam.visuals, alpha = 255, time = 0.7 SECONDS, color = COLOR_PURPLE, luminosity = 3 , easing = SINE_EASING|EASE_OUT)
	. = ..()
