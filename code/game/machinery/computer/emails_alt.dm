// самый не ворованный код в истории
// максимально урезанная версия эмейл путера чтоб чисто показывал один выбранный датум хуйни

/obj/structure/machinery/computer/emails_alt
	name = "Personal Computer"
	desc = "A personal computer used to view emails"
	icon = 'icons/obj/structures/machinery/computer.dmi'
	icon_state = "terminal1"

	needs_power = FALSE

	var/email_datum = /datum/fluff_email/almayer/iwantout
	var/selected_email

/obj/structure/machinery/computer/emails_alt/Initialize(mapload, ...)
	. = ..()
	selected_email = new email_datum

	add_highlight()

/obj/structure/machinery/computer/emails_alt/Destroy()
	remove_highlight()
	QDEL_NULL(selected_email)
	. = ..()

/obj/structure/machinery/computer/emails_alt/attack_hand(mob/user)
	if(..())
		return

	var/dat

	var/datum/fluff_email/E = selected_email
	dat += "[E.entry_text]"

	show_browser(user, dat, "[src.name]", "email_alt", width = 600, height = 520)

/obj/structure/machinery/computer/emails_alt/Topic(href, href_list)
	if(..())
		return

	add_fingerprint(usr)
// updateUsrDialog()
	attack_hand(usr)

/obj/structure/machinery/computer/emails_alt/proc/add_highlight(color = LIGHT_COLOR_GREEN)
	add_filter("highlight", 2, list("type" = "outline", "color" = color, "size" = 1))

/obj/structure/machinery/computer/emails_alt/proc/remove_highlight()
	remove_filter("highlight")

/obj/structure/machinery/computer/emails_alt/hinkley_powerplant/enter_point
	name = "Office Terminal"
	email_datum = /datum/fluff_email/hinkley_powerplant/enter_point

/obj/structure/machinery/computer/emails_alt/hinkley_powerplant/head_researcher
	name = "Senior Professor's Terminal"
	desc = "Судя по всему, это личный компьютер старшего профессора Йозефа Хаммерсмана..."
	email_datum = /datum/fluff_email/hinkley_powerplant/achilles_project

/obj/structure/machinery/computer/emails_alt/hinkley_powerplant/reactor_info
	name = "Reactor Data Terminal"
	desc = "Терминал, используемый обслуживающим персоналом реактора для докладов и передачи важной информации между сменами."
	email_datum = /datum/fluff_email/hinkley_powerplant/reactor_info

/obj/structure/machinery/computer/emails_alt/hinkley_powerplant/security_report
	name = "Sec Office Terminal"
	email_datum = /datum/fluff_email/hinkley_powerplant/security_report

/datum/fluff_email/operation_xx121

/datum/fluff_email/operation_xx121/hangar
	entry_text = {"<html>
	<head>
	<style>
		body { font-family:'Consolas', 'Courier New', monospace; background:#0a0d12; color:#c7d6e0; font-size:12px; padding:10px; }
		.card { background:#0e1218; border:1px solid #1c2733; border-radius:4px; padding:10px; box-shadow:0 0 8px #0c141c inset; }
		h1 { color:#7fb3d5; font-size:14px; text-shadow:0 0 4px #2a5878; margin:0 0 6px 0; letter-spacing:0.5px; }
		.meta { font-size:10px; color:#5c7d94; margin-bottom:8px; border-bottom:1px dashed #1c2733; padding-bottom:6px; line-height:1.6; }
		.section { margin-top:8px; line-height:1.5; }
		.footer { font-size:10px; color:#4a6579; margin-top:12px; text-align:center; opacity:0.8; border-top:1px dashed #1c2733; padding-top:6px; }
	</style>
	</head>
	<body>
	<div class='card'>
		<h1>ВНУТРЕННЯЯ ПЕРЕПИСКА · АНГАР-1</h1>

		<div class='meta'>
			ОТ: █. █████, складской логист · КОМУ: █. █████ · ТЕМА: Усиление охраны
		</div>

		<div class='section'>
			Слушай, ты вообще в курсе, что тут творится последние недели?
			Я уже сбился со счёта, сколько раз меня тормозили на ███, хотя я здесь и так давно работаю.
		</div>

		<div class='section'>
			Камер налепили ещё в два раза больше, чем было — теперь и над стеллажами, и в ███████,
			где почти никогда ничего не происходит. Охраны тоже прибавилось.
			Причём новые лица не местные, между собой почти не разговаривают,
			а с нами тем более. Форма вроде ███████████, но у пары ребят нашивки,
			которых я раньше не видел ни разу.
		</div>

		<div class='section'>
			███ ввели дополнительные проверки на 'утечку данных'.
			Теперь перед сменой сдаём терминалы на сканирование, а на выходе ещё раз шмонают сумки,
			хотя раньше хватало одной проверки на входе.
			Кто-то из наших спросил у ██████████, с чем это связано, и получил в ответ только:
			'████████████ ██████, ████████ ██ ████████'.
		</div>

		<div class='section'>
			Ещё заметил, что сектор хранения 12-Б с позавчерашнего дня закрыт для всех,
			кроме сотрудников с допуском категории выше моего.
			Туда пару раз заезжал грузовой транспорт под усиленным конвоем.
			Разгружали всё в закрытом режиме, даже докеров из вечерней смены отправили на перерыв.
			Что там разгружали — понятия не имею. И, судя по лицам ребят, которые обычно всё знают,
			они тоже не в курсе.
		</div>

		<div class='section'>
			Устал я от этого всего, если честно. Дышать спокойно уже не получается —
			то ли из-за камер, то ли из-за того, что все вокруг стали дёргаными.
			Наверное, скоро уволюсь с этого предприятия и найду место поспокойнее.
			Хоть бы объяснили толком, чего вдруг такие меры.
			Я понимаю, ███████ ████████ туда-сюда, но когда не говорят вообще ничего,
			поневоле начинаешь себе всякое напридумывать.
		</div>

		<div class='footer'>
			СООБЩЕНИЕ ЛОКАЛЬНОЕ · ВНЕШНЯЯ ПЕРЕСЫЛКА НЕДОСТУПНА
		</div>
	</div>
	</body>
	</html>
	"}

/datum/fluff_email/operation_xx121/cave
	entry_text = {"<html>
	<head>
	<style>
		body { font-family:'Consolas', 'Courier New', monospace; background:#0a0d12; color:#c7d6e0; font-size:12px; padding:10px; }
		.card { background:#0e1218; border:1px solid #1c2733; border-radius:4px; padding:10px; box-shadow:0 0 8px #0c141c inset; }
		h1 { color:#7fb3d5; font-size:14px; text-shadow:0 0 4px #2a5878; margin:0 0 4px 0; letter-spacing:0.5px; }
		.stamp { display:inline-block; color:#c0392b; border:1px solid #c0392b; padding:1px 6px; font-size:10px; font-weight:bold; letter-spacing:1px; margin-bottom:6px; text-shadow:0 0 4px #7a1f16; }
		.meta { font-size:10px; color:#5c7d94; margin-bottom:8px; border-bottom:1px dashed #1c2733; padding-bottom:6px; line-height:1.6; }
		.meta b { color:#8fa8b8; }
		.section-title { color:#7fb3d5; font-size:11px; font-weight:bold; margin-top:10px; text-transform:uppercase; letter-spacing:0.5px; border-bottom:1px dashed #1c2733; padding-bottom:2px; }
		.section { margin-top:6px; line-height:1.5; }
		.redact { background:#111; color:#111; user-select:none; padding:0 2px; }
		.footer { font-size:10px; color:#4a6579; margin-top:12px; text-align:center; opacity:0.8; border-top:1px dashed #1c2733; padding-top:6px; }
		img { max-width:30%; border:1px solid #1c2733; border-radius:4px; }
	</style>
	</head>
	<body>
	<div class='card'>
		<div class='stamp'>CLASSIFIED</div>
		<h1>НАУЧНЫЙ ОТЧЁТ · ОБРАЗЦЫ КСЕНОСОВ</h1>

		<div class='meta'>
			СОСТАВИЛ: <b>Д-р <span class='redact'>██████</span></b>, отдел ксенобиологии<br>
			ОБЪЕКТ ИССЛЕДОВАНИЯ: <span class='redact'>████████</span><br>
			ГРИФ ДОСТУПА: УРОВЕНЬ — <span class='redact'>██</span> И ВЫШЕ
		</div>

		<div class='section-title'>Предварительные наблюдения</div>
		<div class='section'>
			Это удивительно, но данные образцы ксеносов сохранились на редкость хорошо, особенно если учитывать их предполагаемый возраст.
			Его удалось приблизительно определить по составу и слоистости ледника, в котором находились образцы.
			По предварительным оценкам, речь идёт о временном промежутке, значительно превышающем всё, с чем наш отдел сталкивался ранее на этой планете.
		</div>

		<div class='section-title'>Анализ структуры</div>
		<div class='section'>
			Проведённый анализ показывает, что клеточная и молекулярная структура образцов сохранилась практически в идеальном состоянии благодаря естественной заморозке.
			Судя по всему, процесс промерзания произошёл достаточно быстро и предотвратил сколько-нибудь значительную деградацию тканей.
			Подобная степень сохранности крайне редко встречается даже среди образцов куда меньшего возраста.
		</div>

		<div class='section'>
			На данном этапе затруднительно с уверенностью определить происхождение и первоначальное назначение образцов.
			Требуется более глубокий анализ в условиях полностью оборудованной лаборатории, поскольку текущее оснащение позволяет провести лишь поверхностную оценку.
		</div>

		<div class='section-title'>Рекомендации</div>
		<div class='section'>
			Рекомендуется как можно скорее организовать транспортировку минимум одного образца в лабораторный комплекс <span class='redact'>████████████</span> для проведения полного цикла исследований в контролируемых условиях.
			До момента транспортировки необходимо поддерживать текущий температурный режим хранения без отклонений, чтобы избежать необратимой утраты материала.
		</div>

		<div style='text-align:center; margin-top:10px;'>
			<img src='https://i.ibb.co/PZDYKFJr/Screenshot-2026-08-25-185157.png'>
		</div>

		<div class='footer'>
			Архивная копия · XX121/ice_freaks
		</div>
	</div>
	</body>
	</html>
	"}

/datum/fluff_email/operation_xx121/cave_hunter
	entry_text = {"<html>
	<head>
	<style>
		body { font-family:'Consolas', 'Courier New', monospace; background:#0a0d12; color:#c7d6e0; font-size:12px; padding:10px; }
		.card { background:#0e1218; border:1px solid #1c2733; border-radius:4px; padding:10px; box-shadow:0 0 8px #0c141c inset; }
		h1 { color:#7fb3d5; font-size:14px; text-shadow:0 0 4px #2a5878; margin:0 0 4px 0; letter-spacing:0.5px; }
		.stamp { display:inline-block; color:#c0392b; border:1px solid #c0392b; padding:1px 6px; font-size:10px; font-weight:bold; letter-spacing:1px; margin-bottom:6px; text-shadow:0 0 4px #7a1f16; }
		.meta { font-size:10px; color:#5c7d94; margin-bottom:8px; border-bottom:1px dashed #1c2733; padding-bottom:6px; line-height:1.6; }
		.meta b { color:#8fa8b8; }
		.section-title { color:#7fb3d5; font-size:11px; font-weight:bold; margin-top:10px; text-transform:uppercase; letter-spacing:0.5px; border-bottom:1px dashed #1c2733; padding-bottom:2px; }
		.section { margin-top:6px; line-height:1.5; }
		.quote { color:#9ebdce; border-left:2px solid #527991; padding-left:8px; margin-top:8px; font-style:italic; }
		.redact { background:#111; color:#111; user-select:none; padding:0 2px; }
		.footer { font-size:10px; color:#4a6579; margin-top:12px; text-align:center; opacity:0.8; border-top:1px dashed #1c2733; padding-top:6px; }
		img { max-width:100%; border:1px solid #1c2733; border-radius:4px; }
	</style>
	</head>
	<body>
	<div class='card'>
		<div class='stamp'>CLASSIFIED · FIELD NOTE</div>
		<h1>ПОЛЕВАЯ ЗАПИСЬ · НЕИЗВЕСТНАЯ ЦИВИЛИЗАЦИЯ</h1>

		<div class='meta'>
			АВТОР: <b>Д-р <span class='redact'>██████</span></b>, отдел ксеноархеологии<br>
			МЕСТО ОБНАРУЖЕНИЯ: ПЕЩЕРНЫЙ СЕГМЕНТ <span class='redact'>██████</span><br>
			ГРИФ ДОСТУПА: УРОВЕНЬ — <span class='redact'>█</span> И ВЫШЕ
		</div>

		<div class='section-title'>Личная заметка</div>
		<div class='section'>
			В этом сегменте пещер нам удалось обнаружить нечто похожее на заледеневшую гробницу искусственного происхождения.
			Возраст сооружения поражает: оно существовало задолго до прибытия нашей экспедиции.
			На стенах сохранились каменные таблички с письменностью неизвестной инопланетной расы.
		</div>

		<div class='section-title'>Анализ письменности</div>
		<div class='section'>
			Перевод символов и попытка определить их значение заняли значительно больше времени, чем я предполагал.
			Один и тот же знак может использоваться в нескольких смыслах в зависимости от контекста.
			По предварительным наблюдениям, их письменность гораздо сложнее, чем кажется на первый взгляд.
		</div>

		<div class='section'>
			На разных табличках одни и те же символы используются совершенно по-разному.
			Это может указывать на существование диалектов или нескольких народов внутри одной цивилизации.
			Пока это лишь гипотеза, но совпадений слишком много, чтобы считать их случайностью.
		</div>

		<div class='section-title'>Расшифрованный фрагмент</div>
		<div class='quote'>
			kv'var agaj'ya. yin'tekai dhi'ki-de.
		</div>

		<div class='section'>
			Предварительный перевод указывает на область охоты и смерть с честью.
			Ниже перечислены достижения этого 'охотника' — добыча, которую он сумел уничтожить за свою жизнь.
			Если перевод верен, перед нами не захоронение правителя, а памятник воину или выдающемуся охотнику.
		</div>

		<div style='text-align:center; margin-top:10px;'>
			<img src='https://i.ibb.co/NPDfsdc/d353gus-dcb323d3-c5e4-4d1d-bea3-6bf984a0a67b.jpg'>
		</div>

		<div class='footer'>
			Личная архивная запись · cave_temple/hunter
		</div>
	</div>
	</body>
	</html>
	"}

/datum/fluff_email/operation_xx121/archive
	entry_text = {"<html>
	<head>
	<style>
		body { font-family:'Consolas', 'Courier New', monospace; background:#0a0d12; color:#c7d6e0; font-size:12px; padding:10px; }
		.card { background:#0e1218; border:1px solid #c0392b; border-radius:4px; padding:10px; text-align: center; }
		h1 { color:#e74c3c; font-size:14px; margin:0; }
	</style>
	</head>
	<body>
	<div class='card'>
		<h1>ОБНАРУЖЕН СБОЙ В РАБОТЕ АРХИВА. СВЯЖИТЕСЬ С СИСТЕМНЫМ АДМИНИСТРАТОРОМ ДЛЯ РЕШЕНИЯ ЭТОЙ ПРОБЛЕМЫ.</h1>
	</div>
	</body>
	</html>
	"}

/datum/fluff_email/operation_xx121/game
	entry_text = {"<html>
	<head>
	<style>
		body { font-family:'Consolas', 'Courier New', monospace; background:#0a0d12; color:#c7d6e0; font-size:12px; padding:10px; }
		.card { background:#0e1218; border:1px solid #1c2733; border-radius:4px; padding:10px; box-shadow:0 0 8px #0c141c inset; }
		h1 { color:#7fb3d5; font-size:14px; text-shadow:0 0 4px #2a5878; margin:0 0 4px 0; letter-spacing:0.5px; }
		.stamp { display:inline-block; color:#c0392b; border:1px solid #c0392b; padding:1px 6px; font-size:10px; font-weight:bold; letter-spacing:1px; margin-bottom:6px; text-shadow:0 0 4px #7a1f16; }
		.meta { font-size:10px; color:#5c7d94; margin-bottom:8px; border-bottom:1px dashed #1c2733; padding-bottom:6px; line-height:1.6; }
		.meta b { color:#8fa8b8; }
		.section-title { color:#7fb3d5; font-size:11px; font-weight:bold; margin-top:10px; text-transform:uppercase; letter-spacing:0.5px; border-bottom:1px dashed #1c2733; padding-bottom:2px; }
		.section { margin-top:6px; line-height:1.5; }
		.redact { background:#111; color:#111; user-select:none; padding:0 2px; }
		.footer { font-size:10px; color:#4a6579; margin-top:12px; text-align:center; opacity:0.8; border-top:1px dashed #1c2733; padding-top:6px; }
	</style>
	</head>
	<body>

		<div style="text-align: center; margin-top: 10px;">
				<img src="https://cdn.discordapp.com/attachments/874254207958528000/1481689124854435900/1773322988770158.gif?ex=6a8f1307&is=6a8dc187&hm=17dda7633f9f335a196e6e5c1f0136617b95b95e6e31ce80a98c95fcda15280a&" style="max-width: 100%; border: 1px solid #1c2733; border-radius: 4px;">
			</div>

	</body>
	</html>
	"}

/datum/fluff_email/operation_xx121/admin_office
	entry_text = {"<html>
	<head>
	<style>
		body { font-family:'Consolas', 'Courier New', monospace; background:#0a0d12; color:#c7d6e0; font-size:12px; padding:10px; }
		.card { background:#0e1218; border:1px solid #1c2733; border-radius:4px; padding:10px; box-shadow:0 0 8px #0c141c inset; }
		.stamp { display:inline-block; color:#c0392b; border:1px solid #c0392b; padding:1px 6px; font-size:10px; font-weight:bold; letter-spacing:1px; margin-bottom:6px; }
		h1 { color:#7fb3d5; font-size:14px; text-shadow:0 0 4px #2a5878; margin:0 0 4px 0; letter-spacing:0.5px; }
		.meta { font-size:10px; color:#5c7d94; margin-bottom:8px; border-bottom:1px dashed #1c2733; padding-bottom:6px; line-height:1.6; }
		.meta b { color:#8fa8b8; }
		.section-title { color:#7fb3d5; font-size:11px; font-weight:bold; margin-top:10px; text-transform:uppercase; letter-spacing:0.5px; border-bottom:1px dashed #1c2733; padding-bottom:2px; }
		.section { margin-top:6px; line-height:1.5; }
		.redact { background:#111; color:#111; padding:0 2px; }
		.warning { color:#e07a6d; }
		.footer { font-size:10px; color:#4a6579; margin-top:12px; text-align:center; opacity:0.8; border-top:1px dashed #1c2733; padding-top:6px; }
		table { width:100%; border-collapse:collapse; margin-top:8px; font-size:11px; }
		td, th { border:1px solid #1c2733; padding:4px; text-align:left; }
		th { background:#111; color:#7fb3d5; }
	</style>
	</head>
	<body>
	<div class='card'>
		<div class='stamp'>CLASSIFIED</div>
		<h1>ВОЕННОЕ ПРИМЕНЕНИЕ</h1>

		<div class='meta'>
			СОСТАВИЛ: <b>Д-р <span class='redact'>██████</span></b>, отдел ксенобиологии<br>
			ОБЪЕКТ ИССЛЕДОВАНИЯ: <span class='redact'>██████</span><br>
			ГРИФ ДОСТУПА: УРОВЕНЬ - <span class='redact'>█</span> И ВЫШЕ
		</div>

		<div class='section-title'>Резюме</div>
		<div class='section'>
			Последние исследования этой инопланетной расы показали высокий потенциал
			для военного применения. Существа демонстрируют исключительную выносливость
			и агрессию, что делает их перспективным биологическим оружием против Ковенанта.
		</div>

		<div class='section-title'>Первичный анализ</div>
		<div class='section'>
			Военная сила этих существ поражает: скорость реакции, скрытность и способность
			к быстрой адаптации. При столкновении с различными препятствиями они способны
			изменять свою генную структуру, создавая подходящих 'солдат' для конкретной цели.
		</div>

		<div class='section-title'>Ключевые показатели</div>
		<table>
			<tr>
				<th>Параметр</th>
				<th>Значение</th>
				<th>Оценка</th>
			</tr>
			<tr>
				<td>Сила атаки</td>
				<td>Высокая</td>
				<td>█████</td>
			</tr>
			<tr>
				<td>Скрытность</td>
				<td>Исключительная</td>
				<td>██████</td>
			</tr>
			<tr>
				<td>Адаптивность</td>
				<td>Высокая</td>
				<td>████</td>
			</tr>
		</table>

		<div class='section-title'>Запланированные действия</div>
		<div class='section'>
			<span class='warning'>•</span> Провести полевые испытания на изолированных объектах.<br>
			<span class='warning'>•</span> Разработать систему контроля для предотвращения распространения.<br>
			<span class='warning'>•</span> Ограничить доступ к результатам текущего исследования.
		</div>

		<div class='footer'>
			Архивная копия · XX121/report_to_hc
		</div>
	</div>
	</body>
	</html>
	"}

/datum/fluff_email/operation_xx121/research
	entry_text = {"<html>
	<head>
	<style>
		body { font-family:'Consolas', 'Courier New', monospace; background:#0a0d12; color:#c7d6e0; font-size:12px; padding:10px; }
		.card { background:#0e1218; border:1px solid #1c2733; border-radius:4px; padding:10px; box-shadow:0 0 8px #0c141c inset; }
		.stamp { display:inline-block; color:#c0392b; border:1px solid #c0392b; padding:1px 6px; font-size:10px; font-weight:bold; letter-spacing:1px; margin-bottom:8px; }
		h1 { color:#7fb3d5; font-size:14px; font-weight:normal; margin:0 0 6px 0; }
		.meta { color:#5c7d94; font-size:10px; line-height:1.6; border-bottom:1px dashed #1c2733; padding-bottom:6px; }
		.meta b { color:#8fa8b8; }
		.entry { margin-top:10px; line-height:1.6; }
		.entry p { margin:0 0 10px 0; }
		.marker { color:#c0392b; font-weight:bold; }
		.warning { color:#e07a6d; }
		.footer { color:#4a6579; font-size:10px; text-align:center; margin-top:10px; }
	</style>
	</head>
	<body>
	<div class='card'>
		<div class='stamp'>ЛИЧНАЯ ЗАПИСЬ</div>
		<h1>ЛИЧНАЯ ЗАПИСЬ №13</h1>

		<div class='meta'>
			АВТОР: <b>████ ██████</b><br>
		</div>

		<div class='entry'>
			<p>
				<span class='marker'>&gt;</span> Я не понимаю, на что способны эти существа. Остальные словно ослеплены
				их мощью и совершенно не хотят отказываться от дальнейших исследований.
			</p>

			<p>
				Это безрассудство. От этих тварей будут одни беды. Я уже пытался
				предупредить руководство об их опасности и объяснить, что мы не сможем
				их контролировать, но меня никто не слушает.
			</p>

			<p>
				Вместо ответа мне пригрозили увольнением - только за то, что я отказался
				продолжать работу, которую считаю опасной.
			</p>

			<p class='warning'>
				Их одержимость этими существами однажды погубит нас всех.
			</p>
		</div>

		<div class='footer'>
			Архивная копия · XX121/thoughts
		</div>
	</div>
	</body>
	</html>
	"}

/datum/fluff_email/hinkley_powerplant/enter_point
	entry_text = {"<html>
	<head>
	<style>
		body { font-family:'Consolas', 'Courier New', monospace; background:#0a0d12; color:#c7d6e0; font-size:12px; padding:10px; }
		.card { background:#0e1218; border:1px solid #1c2733; border-radius:4px; padding:10px; box-shadow:0 0 8px #0c141c inset; }
		h1 { color:#7fb3d5; font-size:14px; text-shadow:0 0 4px #2a5878; margin:0 0 6px 0; letter-spacing:0.5px; }
		.meta { font-size:10px; color:#5c7d94; margin-bottom:8px; border-bottom:1px dashed #1c2733; padding-bottom:6px; line-height:1.6; }
		.section { margin-top:8px; line-height:1.5; }
		.footer { font-size:10px; color:#4a6579; margin-top:12px; text-align:center; opacity:0.8; border-top:1px dashed #1c2733; padding-top:6px; }
	</style>
	</head>
	<body>
	<div class='card'>
		<h1>ВНИМАНИЕ! НЕМЕДЛЕННАЯ ЭВАКУАЦИЯ!</h1>

		<div class='meta'>
			ОТ: АВТОМАТИЧЕСКАЯ РАССЫЛКА · КОМУ: ПЕРСОНАЛ · ТЕМА: ЭВАКУАЦИЯ
		</div>

		<div class='section'>
			<center><B>ВНИМАНИЕ! НЕМЕДЛЕННО ДОБЕРИТЕСЬ ДО БЛИЖАЙШЕГО ПУНКТА ЭВАКУАЦИИ. СЛЕДУЙТЕ ИНСТРУКЦИЯМ, ПОЛУЧЕННЫМ ОТ ОХРАННОГО ПЕРСОНАЛА И ПРИБЫВАЮЩИХ НА МЕСТО СИЛ ПОЖАРНОЙ И МЕДИЦИНСКОЙ СЛУЖБ.</B></center>
		</div>

		<div class='section'>
			Уровень угрозы на объекте повышен до "жёлтого". Стандартно протоколам безопасности были вызваны пожарная и медицинская службы.
			Выполняйте требования пожарных и парамедиков, прибывающих на объект.
		</div>

		<div class='section'>
		    Стандартная зона эвакуации от вашего местопложения: Монорельс Технического Обеспечения.
		</div>

		<div class='footer'>
			ЛОКАЛЬНОЕ СООБЩЕНИЕ · ВНЕШНЯЯ ПЕРЕСЫЛКА НЕДОСТУПНА
		</div>
	</div>
	</body>
	</html>"}

/datum/fluff_email/hinkley_powerplant/achilles_project
	entry_text = {"<html>
	<head>
	<style>
		body { font-family:'Consolas', 'Courier New', monospace; background:#0a0d12; color:#c7d6e0; font-size:12px; padding:10px; }
		.card { background:#0e1218; border:1px solid #1c2733; border-radius:4px; padding:10px; box-shadow:0 0 8px #0c141c inset; }
		h1 { color:#7fb3d5; font-size:14px; text-shadow:0 0 4px #2a5878; margin:0 0 4px 0; letter-spacing:0.5px; }
		.stamp { display:inline-block; color:#c0392b; border:1px solid #c0392b; padding:1px 6px; font-size:10px; font-weight:bold; letter-spacing:1px; margin-bottom:6px; text-shadow:0 0 4px #7a1f16; }
		.meta { font-size:10px; color:#5c7d94; margin-bottom:8px; border-bottom:1px dashed #1c2733; padding-bottom:6px; line-height:1.6; }
		.meta b { color:#8fa8b8; }
		.section-title { color:#7fb3d5; font-size:11px; font-weight:bold; margin-top:10px; text-transform:uppercase; letter-spacing:0.5px; border-bottom:1px dashed #1c2733; padding-bottom:2px; }
		.section { margin-top:6px; line-height:1.5; }
		.redact { background:#111; color:#111; user-select:none; padding:0 2px; }
		.footer { font-size:10px; color:#4a6579; margin-top:12px; text-align:center; opacity:0.8; border-top:1px dashed #1c2733; padding-top:6px; }
	</style>
	</head>
	<body>
	<div class='card'>
		<div class='stamp'>CLASSIFIED</div>
		<h1>НАУЧНЫЙ ОТЧЁТ · ПРОЕКТ «АХИЛЛЕС»</h1>

		<div class='meta'>
			СОСТАВИЛ: <b>Head Res. ███████</b>, крыло контроля распространения<br>
			ОБЪЕКТ ИССЛЕДОВАНИЯ: ПРОЕКТ «АХИЛЛЕС»<br>
			УРОВЕНЬ ДОСТУПА: Научно-Исследовательская Группа ██████ и ВЫШЕ.
		</div>

		<div class='section-title'>Предварительные данные</div>
		<div class='section'>
			В результате выяснения внешней разведкой данных о "█████████" на ████ «██████», принадлежащей Союзу Прогрессивных Народов, силами ███████████ █████████ были добыты образцы и копии отчётов по продвижению, включая уцелевшие записи экспериментов по некому проекту «███████ ██████».
		</div>
		<div class='section'>
		    Исходя из анализа боя гвардейского взвода РХБЗ СПН "████ ███████", было установлено, что так называемые "████████" обладают куда более высокими боевыми характеристиками, нежели ██-███. Потому, согласно решению комиссии во главе с генералом ████████████ и научным директором ██████ ██████, было принято начать проект «АХИЛЛЕС» на основе проекта Союза «███████ ██████».
		</div>

		<div class='section-title'>Характеристики <span class='redact'>███████</span></div>
		<div class='section'>
			████████, как и ████████, ████████████ █████ паразитизма, ███████ █████ █████ ███ ██████ ████, ██████████ █ ████████ ████████-█████████ █████. Однако, █ ██ █████ ███ ██ ███████████ █████ ██████████ ████ ████████████, ██ ████ ███████████ █████ ██████████ ████ ██████ ███ ████, ███ ███ █████ ███████████ █████ █████████ ██████ █████████ ██████ ████.</div>
			<div class='section'>
			█████ — ██████ ███████, █ ██████████ █ ███ ████████ ██████. █████ ████ ██████ ██ ███ ██, ██████ █ █████ ██ █ █. █████ ███████ ██████ ██████ ██ █████████ ███ ██, █████ █████ ████████ ███—███ ██. █████ ██████████ — █████ █████: █████ ████ ██████ ███████ ███████ ███—███ ██, ██████ █ █████ — ██-███ ██; █ ██ ██████ █ █████ ████ ██████ — ███—███ ██ ██████ █ █████ ██ ██ ██ ██ ██. ███ ███████, █████ ██████ █████ ██-███ ██, █ █████████ — ██-███ ██. ███████ █ ████████ ██████ █████████ ██████████ █████ ██████ ██████ ██ ███ ██, █ ████████ █ ████████ — ██ ███ ██ (███—███ ██). ██████████ █████████ ██████ █ █████ ██████, █████████ ██ █ ███ █████ █████, █ ██████ ██████ ██████ █████ █████████, ███ █ █████. █████ █████ ██████ ███████ ████████ ██-███ ██ (███████ ██████████ █ █ ███████ █ ███ ██ █ █████), █ █ █████ — ██-██ ██. █ ███████ ██████ ██████ ███████████.</div>
		</div>
		<div class='section-title'>Рекомендации</div>
		<div class='section'>
			Усилить охрану «Hinkley Point» силами 1-ой группы Королевских Вооружённых Космических Сил, базировав их в 20-ти минутной готовности прибытия.
			Установить усиленный режим охраны, переведя службу безопасности в режим "постоянная готовность".
		</div>
		<div class='section'>
		    Предоставить полный доступ к материалам исследования и разработки для Научно-Исследовательской Группы ██████, а также установить фильтрацию пропускаемой наружу информации.
		</div>
		<div class='footer'>
			Архивная копия · Prj_Achilles/(redacted)
		</div>
	</div>
	</body>
	</html>"}

/datum/fluff_email/hinkley_powerplant/reactor_info
	entry_text = {"<html>
	<head>
	<style>
		body { font-family:'Consolas', 'Courier New', monospace; background:#0a0d12; color:#c7d6e0; font-size:12px; padding:10px; }
		.card { background:#0e1218; border:1px solid #1c2733; border-radius:4px; padding:10px; box-shadow:0 0 8px #0c141c inset; }
		h1 { color:#7fb3d5; font-size:14px; text-shadow:0 0 4px #2a5878; margin:0 0 4px 0; letter-spacing:0.5px; }
		.stamp { display:inline-block; color:#ffcc00; border:1px solid #ffcc00; padding:1px 6px; font-size:10px; font-weight:bold; letter-spacing:1px; margin-bottom:6px; text-shadow:0 0 4px #7a1f16; }
		.meta { font-size:10px; color:#5c7d94; margin-bottom:8px; border-bottom:1px dashed #1c2733; padding-bottom:6px; line-height:1.6; }
		.meta b { color:#8fa8b8; }
		.section-title { color:#7fb3d5; font-size:11px; font-weight:bold; margin-top:10px; text-transform:uppercase; letter-spacing:0.5px; border-bottom:1px dashed #1c2733; padding-bottom:2px; }
		.section { margin-top:6px; line-height:1.5; }
		.marker { color:#c0392b; font-weight:bold; }
		.quote { color:#9ebdce; border-left:2px solid #527991; padding-left:8px; margin-top:8px; font-style:italic; }
		.redact { background:#111; color:#111; user-select:none; padding:0 2px; }
		.footer { font-size:10px; color:#4a6579; margin-top:12px; text-align:center; opacity:0.8; border-top:1px dashed #1c2733; padding-top:6px; }
		img { max-width:100%; border:1px solid #1c2733; border-radius:4px; }
	</style>
	</head>
	<body>
	<div class='card'>
		<div class='stamp'>REACTOR STATUS REPORT</div>
		<h1>СТАТУС РЕАКТОРА · ТРЕБУЕТСЯ ПОВЫШЕННЫЙ КОНТРОЛЬ</h1>

		<div class='meta'>
			АВТОР: <b>Ст. Инженер Джеймс Мичман</b>, Alpha-смена обслуживания реактора<br>
			СТАТУС РЕАКТОРА: УСИЛЕНИЕ ВНИМАНИЯ К ОБСЛУЖИВАНИЮ РЕАКТОРА<span class='redact'>██████</span><br>
			УРОВЕНЬ ДОСТУПА: ОБСЛУЖИВАЮЩИЙ ПЕРСОНАЛ РЕАКТОРА И ВЫШЕ
		</div>

		<div class='section-title'>Первичный осмотр</div>
		<div class='section'>
			01.09.2182<br>
			В ходе стандартной проверки реактора были замечены трещены на внешнем слое и нестандартно низкий уровень давления, выдающегося насосами.
			Настоятельно рекомендуется в кратчайшие сроки заменить насос и заделать трещины на внешнем корпусе реактор.
		</div>

		<div class='section-title'>Особые пометки</div>
		<div class='section'>
			Датчики консоли касательно давления на стенки реактора имеют слишком высокий уровень погрешности, превышающий норму в 1.5 раза.
			Помимо этого термометр также имеет высокий уровень погрешности, превышающий норму в 1.2 раза.
		</div>

		<div class='section'>
		    Инженерной команде второй смены настоятельно рекомендуется вывести реактор из работы к 14.09.2182 на неопределённое время
		    для ремонта реактора. Академичский городок необходимо перевести на генераторную энергию на время ремонта.
		</div>

		<div class='section-title'>Личная пометка</div>
		<div class='quote'>
			замечены трещены на внешнем слое
		</div>

		<div class='section'>
			<span class='marker'>&gt;</span> Эти трещины, согласно расчётам проектировщиков, должны были появиться лишь через три года.
			Я почти на все 100 уверен, что какая-то мразь сэкономила на материалах, что маловероятно, или саботирует работу реактора...
		</div>

		<div class='section'>
		    Так или иначе, я завтра же пойду к службе безопасности и передам им эту информацию.
		</div>

		<div class='footer'>
			Архивная запись · hinkley_point/reactor
		</div>
	</div>
	</body>
	</html>"}

/datum/fluff_email/hinkley_powerplant/security_report
	entry_text = {"<html>
	<head>
	<style>
		body { font-family:'Consolas', 'Courier New', monospace; background:#0a0d12; color:#c7d6e0; font-size:12px; padding:10px; }
		.card { background:#0e1218; border:1px solid #1c2733; border-radius:4px; padding:10px; box-shadow:0 0 8px #0c141c inset; }
		h1 { color:#7fb3d5; font-size:14px; text-shadow:0 0 4px #2a5878; margin:0 0 6px 0; letter-spacing:0.5px; }
		.meta { font-size:10px; color:#5c7d94; margin-bottom:8px; border-bottom:1px dashed #1c2733; padding-bottom:6px; line-height:1.6; }
		.section { margin-top:8px; line-height:1.5; }
		.footer { font-size:10px; color:#4a6579; margin-top:12px; text-align:center; opacity:0.8; border-top:1px dashed #1c2733; padding-top:6px; }
	</style>
	</head>
	<body>
	<div class='card'>
		<h1>ВНУТРЕННЯЯ ПЕРЕПИСКА · ОФИС СЛУЖБЫ БЕЗОПАСНОСТИ</h1>

		<div class='meta'>
			ОТ: █. █████, офицер безопасности · КОМУ: █. █████, командир Alpha-смены СБ · ТЕМА: Усиление внимания
		</div>

		<div class='section'>
			Шеф, тут движ какой-то намечается, либо у нас крышей поехал Мичман.<br>
			Сегодня утром ко мне заломился в офис, ещё даже смена не началась, а он уже ломится. Треплет, что какой-то утырок саботирует реактор, что, мол "трещины специфические, они должны были появиться лишь через 5 лет" и прочее-прочее.
		</div>

		<div class='section'>
		    Это я к чему, собственно. Может, всё же поставить на пару человек в наряд больше в реакторную?
		    Иначе этот имбецил так и будет ходить и мозги нам трещать вместо работы.
		    Да и мало ли, вдруг правду говорит.
		</div>

		<div class='section'>
			К тому же, вчера заходил старший профессор Хаммерсман, просил, чтобы им поскорей уже одобрили на таможне генератор.
			Говорит, что если будет какой-либо перебой питания - накроет всех медным тазом.
			Ну, ещё он передал, что на следующей неделе охрану третьего и частично второго секторов усилят частями IASF.<br>
			А это значит, что мы сможем разгрузить немного ребят с нашей смены.<br><br>Что думаете, шеф?
		</div>

		<div class='footer'>
			ЛОКАЛЬНОЕ СООБЩЕНИЕ · ВНЕШНЯЯ ПЕРЕСЫЛКА НЕДОСТУПНА
		</div>
	</div>
	</body>
	</html>"}
