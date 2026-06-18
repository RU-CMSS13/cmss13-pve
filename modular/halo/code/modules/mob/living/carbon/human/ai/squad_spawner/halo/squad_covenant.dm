/datum/human_ai_squad_preset/covenant
	faction = FACTION_COVENANT

/datum/human_ai_squad_preset/covenant/unggoy_levy
	name = "Unggoy Levy"
	desc = "Covenant levy with one major and two minor Unggoy."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/major = 1,
		/datum/equipment_preset/covenant/unggoy/minor = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_lance
	name = "Unggoy Lance"
	desc = "Covenant lance led by a Sangheili minor."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/minor = 1,
		/datum/equipment_preset/covenant/unggoy/major = 2,
		/datum/equipment_preset/covenant/unggoy/minor = 4,
	)

/datum/human_ai_squad_preset/covenant/unggoy_pair
	name = "Пара унггоев"
	desc = "Минимальная разведывательная пара Ковенанта из двух унггоев с плазменным оружием."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_needle_pair
	name = "Пара унггоев с игольниками"
	desc = "Легкая скирмиш-пара с игольниками и запасными кристаллами."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/minor_needler = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_fireteam
	name = "Огневая группа унггоев"
	desc = "Линейная огневая группа под командованием одного мажора и трех миноров с плазменным оружием."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/major_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 3,
	)

/datum/human_ai_squad_preset/covenant/unggoy_assault_team
	name = "Штурмовая группа унггоев"
	desc = "Штурмовая группа с мажором-игольником, поддержкой с плазменной винтовкой и линейными бойцами с плазмой."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/major_needler = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_heavy_team
	name = "Тяжелая группа унггоев"
	desc = "Ветеранская группа тяжелой поддержки под командованием ультры, с тяжеловесами с плазменной винтовкой и игольником."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/ultra = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_needler = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 1,
	)

/datum/human_ai_squad_preset/covenant/unggoy_support_team
	name = "Группа поддержки унггоев"
	desc = "Отряд поддержки унггоев с дьяконом-надзирателем и медицинским бойцом поддержки."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/deacon_command = 1,
		/datum/equipment_preset/covenant/unggoy/ai/support_medical = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_at_team
	name = "Прорывная группа унггоев"
	desc = "Ветеранская группа прорыва, собранная вокруг лидера-ультры, тяжелой поддержки и медицинского помощника."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/ultra = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/support_medical = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 1,
	)

/datum/human_ai_squad_preset/covenant/unggoy_specops_cell
	name = "Ячейка SpecOps унггоев"
	desc = "Скрытная ячейка с одной ультрой SpecOps, координирующей специалистов по плазме и игольникам."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/specops_ultra = 1,
		/datum/equipment_preset/covenant/unggoy/ai/specops_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/specops_needler = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_swarm
	name = "Рой унггоев"
	desc = "Плотная стая унггоев с двумя мажорами, несколькими минорами с плазмой и парой носителей игольников."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/major_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/major_needler = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 4,
		/datum/equipment_preset/covenant/unggoy/ai/minor_needler = 2,
	)

/datum/human_ai_squad_preset/covenant/covenant_lance
	name = "Копье Ковенанта"
	desc = "Смешанное копье Ковенанта под командованием сангхейли-минора при поддержке ветеранов-унггоев."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/minor_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/major_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 3,
		/datum/equipment_preset/covenant/unggoy/ai/minor_needler = 1,
	)

/datum/human_ai_squad_preset/covenant/covenant_heavy_lance
	name = "Тяжелое копье Ковенанта"
	desc = "Тяжелое смешанное копье под командованием сангхейли, с карабинным прикрытием и несколькими тяжелыми унггоями."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma = 1,
		/datum/equipment_preset/covenant/sangheili/ai/major_carbine = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_needler = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/covenant_at_lance
	name = "Прорывное копье Ковенанта"
	desc = "Смешанное копье прорыва с командиром-зилотом, ветеранской поддержкой ультры и тяжелыми плазменными заслонами."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/zealot_command = 1,
		/datum/equipment_preset/covenant/unggoy/ai/ultra = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/support_medical = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_suicide_pack
	name = "Стая унггоев-смертников"
	desc = "Специализированная стая унггоев-смертников, которая активирует парные плазменные гранаты и бросается на враждебные цели."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/suicide_bomber = 3,
	)

/datum/human_ai_squad_preset/covenant/sangheili_pair
	name = "Пара сангхейли"
	desc = "Легкий патруль из двух воинов-сангхейли, вооруженных плазменными винтовками."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/minor_plasma = 1,
		/datum/equipment_preset/covenant/sangheili/minor/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/sangheili_fireteam
	name = "Огневая группа сангхейли"
	desc = "Дисциплинированная огневая группа сангхейли под командованием мажора с двумя минорами с плазменным оружием."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/major/plasma_rifle = 1,
		/datum/equipment_preset/covenant/sangheili/ai/minor_plasma = 1,
		/datum/equipment_preset/covenant/sangheili/minor/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/sangheili_elite_team
	name = "Элитная группа сангхейли"
	desc = "Ветеранский отряд сангхейли, собранный вокруг ультры, мажора с карабином и поддерживающих миноров."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma = 1,
		/datum/equipment_preset/covenant/sangheili/ai/major_carbine = 1,
		/datum/equipment_preset/covenant/sangheili/ai/minor_plasma = 1,
		/datum/equipment_preset/covenant/sangheili/minor/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/sangheili_sword_pair
	name = "Пара сангхейли с мечами"
	desc = "Ударная пара ультр-сангхейли, вооруженных только энергетическими мечами."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/ultra_sword = 2,
	)

/datum/human_ai_squad_preset/covenant/sangheili_zealot_strike_cell
	name = "Ударная ячейка зилота-сангхейли"
	desc = "Ударная ячейка под командованием зилота с ультрами с мечами и плазменной поддержкой."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/zealot/cloaking = 1,
		/datum/equipment_preset/covenant/sangheili/ai/ultra_sword = 1,
		/datum/equipment_preset/covenant/sangheili/ultra/carbine = 1,
	)

/datum/human_ai_squad_preset/covenant/ruuhtian_pair
	name = "Kig-Yar Pair"
	desc = "A light Kig-Yar skirmisher pair armed with plasma pistols and shields."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/ruuhtian/ai/minor_plasma = 1,
		/datum/equipment_preset/covenant/ruuhtian/minor/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/ruuhtian_screen_team
	name = "Kig-Yar Screen Team"
	desc = "A screen team of shielded Kig-Yar raiders built to probe and harass the front line."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/ruuhtian/ai/major_needler = 1,
		/datum/equipment_preset/covenant/ruuhtian/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/ruuhtian_marksman_cell
	name = "Kig-Yar Marksman Cell"
	desc = "A ranged Kig-Yar cell with a marksman and shielded escorts."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/ruuhtian/ai/marksman_carbine = 1,
		/datum/equipment_preset/covenant/ruuhtian/ai/minor_plasma = 1,
		/datum/equipment_preset/covenant/ruuhtian/minor/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/ruuhtian_patrol_pair
	name = "Kig-Yar Patrol Pair"
	desc = "A light Kig-Yar patrol with a plasma rifle major and needler minor."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/ruuhtian/major/plasma_rifle = 1,
		/datum/equipment_preset/covenant/ruuhtian/minor/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/ruuhtian_marksman_overwatch
	name = "Kig-Yar Marksman Overwatch"
	desc = "A Kig-Yar marksman cell with carbine overwatch and shielded escorts."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/ruuhtian/ai/marksman_carbine = 1,
		/datum/equipment_preset/covenant/ruuhtian/major/plasma_rifle = 1,
		/datum/equipment_preset/covenant/ruuhtian/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/ruuhtian_sniper_cell
	name = "Kig-Yar Sniper Cell"
	desc = "A Kig-Yar sniper element with a carbine sniper and marksman support."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/ruuhtian/sniper/carbine = 1,
		/datum/equipment_preset/covenant/ruuhtian/ai/marksman_carbine = 1,
		/datum/equipment_preset/covenant/ruuhtian/ai/major_needler = 1,
	)

/datum/human_ai_squad_preset/covenant/covenant_skirmisher_lance
	name = "Covenant Skirmisher Lance"
	desc = "A lore-aligned mixed lance with an Elite leader, Kig-Yar skirmishers, and Unggoy line troops."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/minor_plasma = 1,
		/datum/equipment_preset/covenant/ruuhtian/ai/major_needler = 1,
		/datum/equipment_preset/covenant/ruuhtian/ai/minor_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/covenant_marksman_lance
	name = "Covenant Marksman Lance"
	desc = "A mixed Covenant lance led by an Elite with Kig-Yar marksmen and Unggoy escorts."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/major_carbine = 1,
		/datum/equipment_preset/covenant/ruuhtian/ai/marksman_carbine = 2,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/covenant_raider_lance
	name = "Covenant Raider Lance"
	desc = "A harder mixed raider lance with an Elite ultra, veteran Kig-Yar, and heavy Unggoy support."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma = 1,
		/datum/equipment_preset/covenant/ruuhtian/ai/major_needler = 1,
		/datum/equipment_preset/covenant/ruuhtian/ai/marksman_carbine = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/kigyar_unggoy_lance
	name = "Kig-Yar/Unggoy Lance"
	desc = "A mixed Covenant lance with Kig-Yar carbine support and Unggoy infantry."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/ruuhtian/ai/marksman_carbine = 1,
		/datum/equipment_preset/covenant/ruuhtian/major/plasma_rifle = 1,
		/datum/equipment_preset/covenant/unggoy/ai/major_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 3,
	)

/datum/human_ai_squad_preset/covenant/sangheili_command_lance
	name = "Sangheili Command Lance"
	desc = "A lore-led Sangheili command lance built around a zealot, veterans, and a line escort."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/zealot_command = 1,
		/datum/equipment_preset/covenant/sangheili/ultra/carbine = 1,
		/datum/equipment_preset/covenant/sangheili/major/needler = 1,
		/datum/equipment_preset/covenant/sangheili/ai/minor_plasma = 1,
	)

/datum/human_ai_squad_preset/covenant/sangheili_honor_guard_triad
	name = "Sangheili Honor Guard Triad"
	desc = "A ceremonial but lethal Sangheili honor detail with close escort and ranged support."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/honor_guard = 1,
		/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma = 1,
		/datum/equipment_preset/covenant/sangheili/minor/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/covenant_specops_strike_cell
	name = "Covenant SpecOps Strike Cell"
	desc = "A covert Covenant strike cell mixing Sangheili SpecOps command with stealth Unggoy support."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/specops/cloaking = 1,
		/datum/equipment_preset/covenant/sangheili/specops_ultra/carbine = 1,
		/datum/equipment_preset/covenant/unggoy/ai/specops_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/specops_needler = 1,
	)

/datum/human_ai_squad_preset/covenant/kigyar_raider_lance
	name = "Kig-Yar Raider Lance"
	desc = "A Kig-Yar-led raider lance with skirmish screens, marksman pressure, and Unggoy support."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/ruuhtian/major/plasma_rifle = 1,
		/datum/equipment_preset/covenant/ruuhtian/ai/marksman_carbine = 1,
		/datum/equipment_preset/covenant/ruuhtian/minor/needler = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

// =====================
// PR #170: New Covenant Squads
// =====================

/datum/human_ai_squad_preset/covenant/unggoy_levy_heavy
	name = "Unggoy Levy (Heavy)"
	desc = "One Major and Minor with plasma pistols, and a Heavy with a plasma rifle."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/major/plasma_pistol = 1,
		/datum/equipment_preset/covenant/unggoy/heavy/plasma_rifle = 1,
		/datum/equipment_preset/covenant/unggoy/minor/plasma_pistol = 1,
	)

/datum/human_ai_squad_preset/covenant/unggoy_levy_ultra
	name = "Unggoy Levy (Ultra)"
	desc = "An Ultra armed with a plasma rifle, accompanied by one Major with a needler and one Minor with a plasma pistol."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ultra/plasma_rifle = 1,
		/datum/equipment_preset/covenant/unggoy/major/needler = 1,
		/datum/equipment_preset/covenant/unggoy/minor/plasma_pistol = 1,
	)

/datum/human_ai_squad_preset/covenant/lance_leader
	name = "Lance Command Team"
	desc = "The command team of a Covenant Unggoy Lance, the equivalent of a squad in the Covenant military. One Sangheili armed with a plasma rifle accompanied by an Unggoy Ultra with a needler."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/minor/plasma_rifle = 1,
		/datum/equipment_preset/covenant/unggoy/ultra/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/sangheili_major_levy
	name = "Sangheili Major Team"
	desc = "Often put in charge of several lances of Sangheili or heavy pieces of equipment. One Sangheili Major with a plasma rifle accompanied by an Unggoy Ultra with a needler."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/major/plasma_rifle = 1,
		/datum/equipment_preset/covenant/unggoy/ultra/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/sangheili_ultra_levy
	name = "Sangheili Ultra Team"
	desc = "Typically serving as military advisors or operating on independent missions, Ultras are often found together. Sangheili Ultra and Unggoy Ultra equipped with plasma rifles, as well as an Unggoy Ultra with a needler."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ultra/plasma_rifle = 1,
		/datum/equipment_preset/covenant/unggoy/ultra/needler = 1,
		/datum/equipment_preset/covenant/unggoy/ultra/plasma_rifle = 1,
	)

// =====================
// SPECIAL OPERATIONS
// =====================

/datum/human_ai_squad_preset/covenant/specops_unggoy_pair
	name = "Special Operations Unggoy Pair"
	desc = "A duo of Special Operations Unggoy, both equipped with plasma rifles."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/specops/plasma_rifle = 2,
	)

/datum/human_ai_squad_preset/covenant/specops_unggoy_levy
	name = "Special Operations Unggoy Levy"
	desc = "A trio of Special Operations Unggoy, two equipped with plasma rifles and one with a needler."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/specops/needler = 1,
		/datum/equipment_preset/covenant/unggoy/specops/plasma_rifle = 2,
	)

/datum/human_ai_squad_preset/covenant/specops_unggoy_pair_cloaked
	name = "Special Operations Unggoy Pair !!CLOAKED!!"
	desc = "A duo of Special Operations Unggoy, both equipped with plasma rifles. Cloaked."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/specops/cloaking = 2,
	)

/datum/human_ai_squad_preset/covenant/specops_unggoy_pair_ultra
	name = "Special Operations Unggoy Pair (Ultra)"
	desc = "A duo of Special Operations Unggoy, one of which an Ultra, both equipped with plasma rifles."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/specops_ultra/plasma_rifle = 1,
		/datum/equipment_preset/covenant/unggoy/specops/plasma_rifle = 1,
	)

/datum/human_ai_squad_preset/covenant/specops_unggoy_pair_ultra_cloaked
	name = "Special Operations Unggoy Pair (Ultra) !!CLOAKED!!"
	desc = "A duo of Special Operations Unggoy, one of which an Ultra, both equipped with plasma rifles. Cloaked."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/specops_ultra/cloaking = 1,
		/datum/equipment_preset/covenant/unggoy/specops/cloaking = 1,
	)

/datum/human_ai_squad_preset/covenant/specops_elite_team
	name = "Special Operations Lance Command Team"
	desc = "A Special Operations Sangheili paired with a Special Operations Unggoy, with a plasma rifle and needler respectively. Typically found leading a Special Operations Lance."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/specops/plasma_rifle = 1,
		/datum/equipment_preset/covenant/unggoy/specops/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/specops_elite_team_cloaked
	name = "Special Operations Lance Command Team !!CLOAKED!!"
	desc = "A Special Operations Sangheili paired with a Special Operations Unggoy, both with plasma rifles. Typically found leading a Special Operations Lance. Cloaked."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/specops/cloaking = 1,
		/datum/equipment_preset/covenant/unggoy/specops/cloaking = 1,
	)

/datum/human_ai_squad_preset/covenant/specops_elite_ultra_team
	name = "Special Operations Ultra Taskforce"
	desc = "A Special Operations Sangheili paired with two Special Operations Unggoy Ultras."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/specops/plasma_rifle = 1,
		/datum/equipment_preset/covenant/unggoy/specops_ultra/plasma_rifle = 2,
	)

/datum/human_ai_squad_preset/covenant/specops_elite_ultra_team_cloaked
	name = "Special Operations Ultra Taskforce !!CLOAKED!!"
	desc = "A Special Operations Sangheili paired with two Special Operations Unggoy Ultras. Cloaked."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/specops_ultra/cloaking = 1,
		/datum/equipment_preset/covenant/unggoy/specops_ultra/cloaking = 2,
	)
