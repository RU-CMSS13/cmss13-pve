// SS220 EDIT - START: PR #1266 D66-44 — translated name/desc to Russian
/obj/item/hardpoint/primary/cannon/ridgeway
	name = "\improper 115-мм пушка M613"
	desc = "Основное орудие тяжёлого танка M40 Ridgeway. Высокоскоростная гладкоствольная 115-мм пушка со скорострельностью до 60 выстрелов в минуту. В сочетании с исключительной точностью она способна поражать практически любую цель: от вражеской брони до укреплённых бункеров. Похоже, автомат заряжания этой пушки повреждён или переделан, так что такого темпа огня она вряд ли достигнет. Не повезло."
// SS220 EDIT - END

	icon_state = "ridgeway_cannon"
	disp_icon = "ridgeway"
	disp_icon_state = "ridgeway_cannon"
	activation_sounds = list('sound/weapons/vehicles/cannon_fire1.ogg', 'sound/weapons/vehicles/cannon_fire2.ogg')

	health = 2000
	firing_arc = 75

	ammo = new /obj/item/ammo_magazine/hardpoint/ridgewaycannon
	max_clips = 6

	px_offsets = list(
		"1" = list(0, 46),
		"2" = list(0, -50),
		"4" = list(61, 0),
		"8" = list(-63, 0)
	)

	use_muzzle_flash = TRUE
	angle_muzzleflash = FALSE
	muzzleflash_icon_state = "muzzle_flash"

	muzzle_flash_pos = list(
		"1" = list(16, 100),
		"2" = list(16, -110),
		"4" = list(140, 4),
		"8" = list(-105, 4)
	)

	scatter = 0
	fire_delay = 3 SECONDS
