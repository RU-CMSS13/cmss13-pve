/datum/human_ai_brain
	/// Lines potentially said when an AI enters combat
	var/list/enter_combat_lines = list(
		"КОНТАКТ!",
		"Контакт!",
		"Дерьмо! Контакт!",
		"Контакт спереди!",
		"У НАС КОНТАКТ!",
		"Будьте начеку!",
		"ПУШКИ К БОЮ!",
		"Здесь!",
		"На мне!",
		"ОТКРЫТЬ ОГОНЬ!",
		"Открыть огонь!",
		"В БОЙ!",
		"В бой!",
		"Оружие на изготовку!",
		"Сотрём их!",
		"Поджарим их!",
		"Покромсаем их!",
		"Разъебите их!",
		"В РАСХОД ЭТИХ УБЛЮДКОВ!",
		"Убейте этого ублюдка!",
		"Замочим этого ублюдка!",
		"Давайте крушить!",
		"Жрите дерьмо!",
		"Умри, сучий сын!",
		"Получай!",
		"ПОЛУЧАЙ!",
		"ПОЛУЧИ УБЛЮДОК!",
		"*warcry",
	)

	/// Lines potentially said when an AI exits combat
	var/list/exit_combat_lines = list(
		"ПРЕКРАТИТЬ ОГОНЬ!",
		"Прекратить огонь!",
		"Прекратите свой огонь!",
		"Остановить огонь!",
		"ОСТАНОВИТЕ ОГОНЬ!",
		"У НАС ЧИСТО!",
		"У нас чисто?",
		"Выглядит чисто!",
		"ЧИСТО!",
		"Держите уши востро!",
		"Могло быть больше- Держите уши востро.",
	)

	/// Lines potentially said when an AI's squadmate dies
	var/list/squad_member_death_lines = list(
		"БЛЯТЬ!",
		"ДЕРЬМО!",
		"СУКА!",
		"УБЛЮДОК!",
		"ЧЁРТ ПОДЕРИ!",
		"МЫ ПОД ОГНЁМ ЗДЕСЬ!",
		"ОНИ УБИЛИ ЕГО-- ВЕРНЁМ ИМ ВЕСТОЧКУ!",
		"ТЫ ЗАПЛАТИШЬ, УБЛЮДОК!",
		"ТЫ ЗАПЛАТИШЬ, МУДАК!",
		"ЕГО ПОДБИЛИ!",
		"ОН УБИТ!",
		"ОНИ УБИЛИ ЕГО!",
	)

	/// Lines potentially said when an AI throws a grenade
	var/list/grenade_thrown_lines = list(
		"ГРАНАТА!",
		"БРОСАЮ ГРАНАТУ!",
		"ГРАНАТА, ОСТОРОЖНЕЕ!",
		"СЪЕШЬ ЭТО, УБЬЛЮДОК!",
		"ВОЗВРАЩАЮ ОТПРАВИТЕЛЮ!",
		"ДОСТАВКА, УБЛЮДОК!",
	)

	/// Lines potentially said when an AI reloads a magazine-fed gun
	var/list/reload_lines = list(
		"ПЕРЕЗАРЯЖАЮСЬ!",
		"Перезаряжаюсь!",
		"МЕНЯЮ МАГАЗИН!",
		"Меняю магазин!",
		"МЕНЯЮ МАГАЗ!",
		"Меняю магаз!",
		"Прикройте меня, перезаряжаюсь!",
		"Нужен заградительный огонь!",
		"Прикрой меня!",
		"ПУСТ, ПУСТ, --ПОЛОН",
		"Я ПУСТ!",
		"ПУСТ!",
	)

	/// Lines potentially said when an AI reloads a tube-fed gun
	var/list/reload_internal_mag_lines = list(
		"ПЕРЕЗАРЯЖАЮСЬ!",
		"Перезаряжаюсь!",
		"Прикройте меня, перезаряжаюсь!",
		"Нужен заградительный огонь!",
		"Прикрой меня!",
		"ПУСТ, ПУСТ, --ПОЛОН",
		"Я ПУСТ!",
		"МНЕ НУЖЕН ЁБАННЫЙ БАРАБАН- ГОСПОДИ!",
		"ПУСТ!",
	)

	/// Currently unused
	var/list/need_healing_lines = list(
		"ЁБАННЫЙ!",
		"БЛЯТЬ!",
		"ДЕРЬМО!",
		"СУКА!",
		"УБЛЮДОК!",
		"ЧЁРТ ПОДЕРИ!",
		"ГОСПОДИ!",
		"КРОВОТЕЧЕНИЕ!",
		"МАТЕРЬ БОЖЬЯ-- НЕТ!",
		"Я ПОЛУЧИЛ ПУЛЮ ЗДЕСЬ!",
		"Я ПОЙМАЛ ПУЛЮ!",
		"Я РАНЕН!",
		"НУЖЕН ИНЖЕКТОР СЮДА!",
		"ИНЖЕКТОР МНЕ!",
		"НУЖЕН БИНТ!",
		"КТО НИБУДЬ, ПОДЛАТАЙТЕ МЕНЯ!",
		"НУЖЕН МОРФИН!",
	)

	/// Chance that an AI says a voiceline when entering combat
	var/in_combat_line_chance = 40
	/// Chance that an AI says a voiceline when exiting combat
	var/exit_combat_line_chance = 40
	/// Chance that an AI says a voiceline when a squadmember dies
	var/squad_member_death_line_chance = 20
	/// Chance that an AI says a voiceline when they throw a grenade
	var/grenade_thrown_line_chance = 60
	/// Chance that an AI says a voiceline when they reload a gun
	var/reload_line_chance = 40
	/// Currently unused
	var/need_healing_line_chance = 90

/datum/human_ai_brain/proc/say_in_combat_line(chance = in_combat_line_chance)
	if(!length(enter_combat_lines) || !prob(chance) || (tied_human.health < HEALTH_THRESHOLD_CRIT))
		return
	tied_human.say(pick(enter_combat_lines))

/datum/human_ai_brain/proc/say_exit_combat_line(chance = exit_combat_line_chance)
	if(!length(exit_combat_lines) || !prob(chance) || (tied_human.health < HEALTH_THRESHOLD_CRIT))
		return
	tied_human.say(pick(exit_combat_lines))

/datum/human_ai_brain/proc/on_squad_member_death(mob/living/carbon/human/dead_member)
	if(!length(squad_member_death_lines) || !prob(squad_member_death_line_chance) || (tied_human.health < HEALTH_THRESHOLD_CRIT))
		return
	tied_human.say(pick(squad_member_death_lines))

/datum/human_ai_brain/proc/say_grenade_thrown_line(chance = grenade_thrown_line_chance)
	if(!length(grenade_thrown_lines) || !prob(chance) || (tied_human.health < HEALTH_THRESHOLD_CRIT))
		return
	tied_human.say(pick(grenade_thrown_lines))

/datum/human_ai_brain/proc/say_reload_line(chance = reload_line_chance)
	if(!length(reload_lines) || !prob(chance) || (tied_human.health < HEALTH_THRESHOLD_CRIT) || !primary_weapon)
		return
	if(istype(primary_weapon.current_mag, /obj/item/ammo_magazine/internal))
		tied_human.say(pick(reload_internal_mag_lines))
	else
		tied_human.say(pick(reload_lines))

/datum/human_ai_brain/proc/say_need_healing_line(chance = need_healing_line_chance)
	if(!length(need_healing_lines) || !prob(chance) || (tied_human.health < HEALTH_THRESHOLD_CRIT))
		return
	tied_human.say(pick(need_healing_lines))
