/datum/unarmed_attack/punch/sangheili
	attack_verb = list("pummel", "slamm", "punch")
	damage = 20

// PR #162: Elite Hero unarmed attacks
/datum/unarmed_attack/punch/sangheili/heroic
	damage = 30

/datum/unarmed_attack/punch/sangheili/heroic/legendary
	damage = 35

/datum/unarmed_attack/punch/sangheili/heroic/legendary/mythic
	damage = 40

/datum/unarmed_attack/punch/unggoy
	attack_verb = list("pummel", "slamm", "punch")
	damage = 40

/datum/unarmed_attack/punch/kigyar
	attack_verb = list("scratch", "claw", "slice")
	damage = 10
	attack_sound = 'sound/weapons/bladeslice.ogg'
	sharp = TRUE
	edge = TRUE

/datum/unarmed_attack/punch/spartan
	attack_verb = list("pummel", "slamm", "punch")
	damage = 50

/obj/item/clothing/glasses/sunglasses/big/unsc
	name = "\improper UNSC shooting shades"
	desc = "Пара штатных затемнённых очков. Некоторые модели оснащаются встроенной HUD-системой, но этот экземпляр явно без неё."
	icon = 'modular/halo/icons/halo/obj/items/clothing/glasses/glasses.dmi'
	icon_state = "hudglasses"
	item_state = "hudglasses"
	item_icons = list(
		WEAR_EYES = 'modular/halo/icons/halo/mob/humans/onmob/clothing/eyes.dmi',
		WEAR_FACE = 'modular/halo/icons/halo/mob/humans/onmob/clothing/eyes.dmi'
	)

/obj/item/clothing/head/cmcap/oni
	name = "\improper ONI security forces patrol cap"
	desc = "A black patrol cap, with the insignia of ONI in the center."
	icon = 'modular/halo/icons/halo/obj/items/clothing/hats/hats_by_faction/hat_unsc.dmi'
	item_icons = list(
		WEAR_HEAD = 'modular/halo/icons/halo/mob/humans/onmob/clothing/hats/hats_by_faction/hat_unsc.dmi'
	)
	icon_state = "oni_cap"

/obj/item/clothing/head/marine/peaked/service/ueg
	name = "\improper UEG police chief peaked cap"
	desc = "A peaked cap used within the UEG Police forces to denote rank and authority of some kind."

/obj/item/card/id/covenant
	name = "Covenant identity disk"
	desc = "An identitiy disk forged from nanolaminate. Four holoprojectors, two on each arm, display the personal identification readout of its owner."
	icon = 'modular/halo/icons/halo/obj/items/card.dmi'
	icon_state = "cov"
	item_state = "cov_id"
	item_icons = list(
		WEAR_ID = 'modular/halo/icons/halo/mob/humans/onmob/id.dmi'
	)

/obj/item/device/encryptionkey/oni
	name = "\improper ONI Security Forces Radio Encryption Key"
	icon_state = "stripped_key"
	channels = list(RADIO_CHANNEL_ONI_SEC = TRUE, RADIO_CHANNEL_COLONY = TRUE)
