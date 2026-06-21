//	ENTERING BYPASS and other shit. \\

/client
	var/enter_lock_bypass = 0
	var/total_enter_lock = 0

/client/proc/allow_to_join()
	set name = "Entering Lock Bypass"
	set category = "Game Master.Moderation"

	if(!check_rights())
		return
	var/client/player = tgui_input_list(usr, "Выберите игрока, что сможет обойти запрет на вход.", "Allow Bypass Entering Lock", GLOB.clients)
	if(!player.enter_lock_bypass)
		player.enter_lock_bypass = 1
		to_chat(player, FONT_SIZE_BIG(SPAN_NOTICE("Высшие силы даровали возможность тебе зайти!")))
		if(player.prefs.toggles_sound & SOUND_ADMINHELP)
			SEND_SOUND(player, sound('sound/effects/adminhelp_new.ogg'))
		message_admins("[usr] Игроку [player.ckey] дали возможность зайти в игру.")
	else
		player.enter_lock_bypass = 0
		to_chat(player, FONT_SIZE_BIG(SPAN_NOTICE("Высшие силы изъяли у тебя возможность зайти!")))
		message_admins("[usr] У игрока [player.ckey] забрали возможность зайти в игру.")

/*
* Прок блокирующий вход игроку на раунд
*/
/client/proc/disallow_to_join()
	set name = "Blacklist"
	set category = "Game Master.Moderation"

	if(!check_rights())
		return
	var/client/player = tgui_input_list(usr, "Выберите игрока, что будет исключен/включен.", "Blacklist", GLOB.clients)
	if(!player.total_enter_lock)
		player.total_enter_lock = 1
		to_chat(player, FONT_SIZE_BIG(SPAN_NOTICE("Ты исключен из игры на раунд. Ты можешь только наблюдать за ходом игры, но не сможешь зайти.")))
		if(player.prefs.toggles_sound & SOUND_ADMINHELP)
			SEND_SOUND(player, sound('sound/effects/adminhelp_new.ogg'))
		message_admins("[usr] исключил из игры [player.ckey].")
	else
		player.total_enter_lock = 0
		to_chat(player, FONT_SIZE_BIG(SPAN_NOTICE("Тебя вернули в игру. Теперь ты можешь попытаться зайти.")))
		if(player.prefs.toggles_sound & SOUND_ADMINHELP)
			SEND_SOUND(player, sound('sound/effects/adminhelp_new.ogg'))
		message_admins("[usr] вернул в игру [player.ckey]. Увы и ах!")
