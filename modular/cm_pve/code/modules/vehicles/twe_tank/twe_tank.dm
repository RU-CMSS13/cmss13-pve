/obj/vehicle/multitile/tank/twe_tank
	name = "FV150 «Hobelar» лёгкий кавалерийский танк"
	desc = "FV150 «Hobelar» Light Cavalry Tank — 6-метровая боевая машина поддержки Королевской морской пехоты. Изначально закупалась для Специальной авиационной службы как десантный танк, эта модель была переделана в машину поддержки благодаря смене символики и технологическому переоснащению. Вход сзади."
	desc_lore = "Неуклюжий столп арсенала TWE, FV150 начал свою жизнь в конце 2170-х как заявка дочерней компании Weyland-Yutani, Southfield Motors, на участие в Программе лёгких боевых машин — конкурсе, проводимом Специальной авиационной службой (SAS) Империи в поисках лёгкой машины для поддержки и усиления огневой мощи легковооружённых парашютистов. \n Несмотря на жёсткую конкуренцию с другими участниками финального этапа программы, наиболее заметными из которых были Lockmart Industries FV580 (танкетка на базе M577A3) и Alphatech Industries XV40 (усиленная броневерсия XT-37), именно FV150 был в конечном счёте выбран для закупки SAS. \n Такой выбор не обошёлся без последствий. Обвинения в коррупции и фаворитизме возникли почти сразу из-за необъяснимых связей TWE (и зависимости) от корпорации Weyland-Yutani. Последовавшая череда парламентских слушаний, политических отставок и медийной травли запомнилась как один из самых разрушительных политических скандалов, с которыми когда-либо сталкивалась Империя. \n Репутация FV150 в полевых условиях была столь же неоднозначной. Первая производственная партия была завершена незадолго до официального завершения Австралийских войн, и SAS FV150 быстро оказались втянуты во всё — от парашютных рейдов до повстанческих засад. \n Хотя боевая машина первоначально ценилась как лёгкий танк (благодаря 45-мм автоматической пушке), её полная неспособность противостоять атакам мощнее обычного винтовочного огня вынудила командование SAS перейти к более сдержанной тактике на фоне растущих потерь. В последние месяцы войны сожжённые остовы FV150 на основных дорогах и особо неспокойных районах австралийской глубинки были обычным свидетельством недавней активности SAS, а экипажи FV150, как говорят, были более склонны..."

	icon = 'icons/obj/vehicles/twe_tank.dmi'
	icon_state = "tank_base"

	pixel_x = -16
	pixel_y = -16

	bound_width = 64
	bound_height = 64

	bound_x = 0
	bound_y = 0

	health = 1400

	interior_map = /datum/map_template/interior/twe_tank

	passengers_slots = 3
	revivable_dead_slots = 1
	xenos_slots = 1

	entrances = list(
		"rear" = list(0, 2),
	)

	entrance_speed = 0.5 SECONDS

	required_skill = SKILL_VEHICLE_LARGE

	movement_sound = 'sound/vehicles/tank_driving.ogg'

	light_range = 7

	hardpoints_allowed = list(
		/obj/item/hardpoint/holder/tank_turret/twe_tank_turret,
		/obj/item/hardpoint/locomotion/treads,
		/obj/item/hardpoint/locomotion/treads/robust,
		/obj/item/hardpoint/secondary/m56cupola/twe_tank,
		/obj/item/hardpoint/support/smoke_launcher/twe_tank, // SS220 EDIT: trailing comma fix
	)


	seats = list(
		VEHICLE_DRIVER = null,
		VEHICLE_GUNNER = null,
	)

	active_hp = list(
		VEHICLE_DRIVER = null,
		VEHICLE_GUNNER = null,
	)

	vehicle_flags = VEHICLE_CLASS_LIGHT

	dmg_multipliers = list(
		"all" = 1,
		"acid" = 1.8,
		"slash" = 0.8,
		"bullet" = 0.5,
		"explosive" = 0.6,
		"blunt" = 0.5,
		"abstract" = 1,
	)

	explosive_resistance = 300
	wall_ram_damage = 150
	vehicle_ram_multiplier = VEHICLE_TRAMPLE_DAMAGE_APC_REDUCTION

	misc_multipliers = list(
		"move" = 0.8,
		"accuracy" = 1,
		"cooldown" = 1
	)

	move_max_momentum = 2.5 //Very light
	move_momentum_build_factor = 1.5
	move_turn_momentum_loss_factor = 0.8

/obj/vehicle/multitile/tank/twe_tank/initialize_cameras(change_tag = FALSE)
	if(!camera)
		camera = new /obj/structure/machinery/camera/vehicle(src)
	if(change_tag)
		camera.c_tag = "#[rand(1,100)] FV150 \"[nickname]\" танк" //this fluff allows it to be at the start of cams list
		if(camera_int)
			camera_int.c_tag = camera.c_tag + " интерьер" //this fluff allows it to be at the start of cams list
	else
		camera.c_tag = "#[rand(1,100)] FV150 танк"
		if(camera_int)
			camera_int.c_tag = camera.c_tag + " интерьер"


/obj/vehicle/multitile/tank/twe_tank/load_role_reserved_slots()
	var/datum/role_reserved_slots/RRS = new
	RRS.category_name = "Экипаж"
	RRS.roles = list(JOB_TANK_CREW, JOB_WO_CREWMAN, JOB_UPP_CREWMAN, JOB_PMC_CREWMAN)
	RRS.total = 2
	role_reserved_slots += RRS

/obj/vehicle/multitile/tank/twe_tank/load_hardpoints()
	add_hardpoint(new /obj/item/hardpoint/holder/tank_turret/twe_tank_turret)

/obj/vehicle/multitile/tank/twe_tank/add_seated_verbs(mob/living/M, seat)
	if(!M.client)
		return
	add_verb(M.client, list(
		/obj/vehicle/multitile/proc/switch_hardpoint,
		/obj/vehicle/multitile/proc/get_status_info,
		/obj/vehicle/multitile/proc/open_controls_guide,
		/obj/vehicle/multitile/proc/name_vehicle,
	))
	if(seat == VEHICLE_DRIVER)
		add_verb(M.client, list(
			/obj/vehicle/multitile/proc/toggle_door_lock,
			/obj/vehicle/multitile/proc/activate_horn,
			/obj/vehicle/multitile/proc/cycle_hardpoint,
		))
	else if(seat == VEHICLE_GUNNER)
		add_verb(M.client, list(
			/obj/vehicle/multitile/proc/cycle_hardpoint,
			/obj/vehicle/multitile/proc/toggle_gyrostabilizer,
		))

/obj/vehicle/multitile/tank/twe_tank/remove_seated_verbs(mob/living/M, seat)
	if(!M.client)
		return
	remove_verb(M.client, list(
		/obj/vehicle/multitile/proc/get_status_info,
		/obj/vehicle/multitile/proc/open_controls_guide,
	))
	SStgui.close_user_uis(M, src)
	if(seat == VEHICLE_DRIVER)
		remove_verb(M.client, list(
			/obj/vehicle/multitile/proc/toggle_door_lock,
			/obj/vehicle/multitile/proc/activate_horn,
			/obj/vehicle/multitile/proc/switch_hardpoint,
			/obj/vehicle/multitile/proc/name_vehicle,
			/obj/vehicle/multitile/proc/cycle_hardpoint,
		))
	else if(seat == VEHICLE_GUNNER)
		remove_verb(M.client, list(
			/obj/vehicle/multitile/proc/cycle_hardpoint,
			/obj/vehicle/multitile/proc/toggle_gyrostabilizer,
		))

//Called when players try to move vehicle
//Another wrapper for try_move()
/obj/vehicle/multitile/tank/twe_tank/relaymove(mob/user, direction)
	if(user == seats[VEHICLE_DRIVER])
		return ..()

	if(user != seats[VEHICLE_GUNNER])
		return FALSE

	var/obj/item/hardpoint/holder/tank_turret/twe_tank_turret/A = null
	for(var/obj/item/hardpoint/holder/tank_turret/twe_tank_turret/AT in hardpoints)
		A = AT
		break
	if(!A)
		return FALSE

	if(direction == GLOB.reverse_dir[A.dir] || direction == A.dir)
		return FALSE

	A.user_rotation(user, turning_angle(A.dir, direction))
	update_icon()

	return TRUE

/obj/vehicle/multitile/tank/twe_tank/MouseDrop_T(mob/dropped, mob/user)
	. = ..()
	if((dropped != user) || !isxeno(user))
		return

	if(health > 0)
		to_chat(user, SPAN_XENO("Мы не сможем перепрыгнуть через [src], пока он не будет уничтожен!"))
		return

	var/turf/current_turf = get_turf(user)
	var/dir_to_go = get_dir(current_turf, src)
	for(var/i in 1 to 3)
		current_turf = get_step(current_turf, dir_to_go)
		if(!(current_turf in locs))
			break

		if(current_turf.density)
			to_chat(user, SPAN_XENO("Путь через [src] перекрыт!"))
			return

/*
** PRESETS SPAWNERS
*/
/obj/effect/vehicle_spawner/twe_tank
	name = "спавнер танка"
	icon = 'icons/obj/vehicles/twe_tank.dmi'
	icon_state = "tank_base"
	pixel_x = -48
	pixel_y = -48

/obj/effect/vehicle_spawner/twe_tank/Initialize()
	. = ..()
	spawn_vehicle()
	qdel(src)

//PRESET: turret, no hardpoints
/obj/effect/vehicle_spawner/twe_tank/spawn_vehicle()
	var/obj/vehicle/multitile/tank/twe_tank/TANK = new (loc)

	load_misc(TANK)
	load_hardpoints(TANK)
	handle_direction(TANK)
	TANK.update_icon()

	return TANK

/obj/effect/vehicle_spawner/twe_tank/load_hardpoints(obj/vehicle/multitile/tank/V)
	V.add_hardpoint(new /obj/item/hardpoint/holder/tank_turret/twe_tank_turret)

//PRESET: turret, treads installed
/obj/effect/vehicle_spawner/twe_tank/plain/load_hardpoints(obj/vehicle/multitile/tank/V)
	V.add_hardpoint(new /obj/item/hardpoint/holder/tank_turret/twe_tank_turret)
	V.add_hardpoint(new /obj/item/hardpoint/locomotion/treads)

//PRESET: no hardpoints
/obj/effect/vehicle_spawner/twe_tank/hull/load_hardpoints(obj/vehicle/multitile/tank/V)
	return

//Just the hull and it's broken TOO, you get the full experience
/obj/effect/vehicle_spawner/twe_tank/hull/broken/spawn_vehicle()
	var/obj/vehicle/multitile/tank/tonk = ..()
	load_damage(tonk)
	tonk.update_icon()

//PRESET: default hardpoints, destroyed
/obj/effect/vehicle_spawner/twe_tank/decrepit/spawn_vehicle()
	var/obj/vehicle/multitile/tank/twe_tank/TANK = new (loc)

	load_misc(TANK)
	handle_direction(TANK)
	load_hardpoints(TANK)
	load_damage(TANK)
	TANK.update_icon()

/obj/effect/vehicle_spawner/twe_tank/decrepit/load_hardpoints(obj/vehicle/multitile/tank/V)
	V.add_hardpoint(new /obj/item/hardpoint/support/smoke_launcher/twe_tank)
	V.add_hardpoint(new /obj/item/hardpoint/secondary/m56cupola/twe_tank)
	V.add_hardpoint(new /obj/item/hardpoint/locomotion/treads)
	V.add_hardpoint(new /obj/item/hardpoint/holder/tank_turret/twe_tank_turret)
	for(var/obj/item/hardpoint/holder/tank_turret/twe_tank_turret/TT in V.hardpoints)
		TT.add_hardpoint(new /obj/item/hardpoint/primary/autocannon/twe_tank)
		break

//PRESET: default hardpoints
/obj/effect/vehicle_spawner/twe_tank/fixed/armed/load_hardpoints(obj/vehicle/multitile/tank/V)
	V.add_hardpoint(new /obj/item/hardpoint/support/smoke_launcher/twe_tank)
	V.add_hardpoint(new /obj/item/hardpoint/secondary/m56cupola/twe_tank)
	V.add_hardpoint(new /obj/item/hardpoint/locomotion/treads)
	V.add_hardpoint(new /obj/item/hardpoint/holder/tank_turret/twe_tank_turret)
	for(var/obj/item/hardpoint/holder/tank_turret/twe_tank_turret/TT in V.hardpoints)
		TT.add_hardpoint(new /obj/item/hardpoint/primary/autocannon/twe_tank)
		break
