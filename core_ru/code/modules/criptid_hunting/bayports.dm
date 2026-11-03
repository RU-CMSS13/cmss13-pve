/// The atom's base transform scale for width.
/atom/var/tf_scale_x

/// The atom's base transform scale for height.
/atom/var/tf_scale_y

/// The atom's base transform scale for rotation.
/atom/var/tf_rotation

/// The atom's base transform scale for horizontal offset.
/atom/var/tf_offset_x

/// The atom's base transform scale for vertical offset.
/atom/var/tf_offset_y

/atom/proc/SetTransform(
	scale,
	scale_x = tf_scale_x,
	scale_y = tf_scale_y,
	rotation = tf_rotation,
	offset_x = tf_offset_x,
	offset_y = tf_offset_y,
	list/others
)
	if (!isnull(scale))
		tf_scale_x = scale
		tf_scale_y = scale
	else
		tf_scale_x = scale_x
		tf_scale_y = scale_y
	tf_rotation = rotation
	tf_offset_x = offset_x
	tf_offset_y = offset_y
	transform = matrix().Update(
		scale_x = tf_scale_x,
		scale_y = tf_scale_y,
		rotation = tf_rotation,
		offset_x = tf_offset_x,
		offset_y = tf_offset_y,
		others = others
	)

/image/proc/show_cluetext(message, scroll_down, text_alignment = "left", text_color = "#FFFFFF", speed = 1)
	set waitfor = 0

	var/style = "font-family: Fixedsys, monospace; -dm-text-outline: 1 black; font-size: 9px; text-align: [text_alignment]; color: [text_color];"
	var/list/linebreaks = list()

	var/linebreak = findtext(message, "\n")
	while(linebreak)
		linebreak++
		linebreaks += linebreak
		linebreak = findtext(message, "\n", linebreak)

	var/list/html_tags = list()
	var/html_tag = findtext(message, regex("<.>"))
	var/opener = TRUE
	while(html_tag)
		html_tag++
		if(opener)
			html_tags += list(html_tag, html_tag + 1, html_tag + 2)
			html_tag = findtext(message, regex("<.>"), html_tag + 2)
			if(!html_tag)
				opener = FALSE
				html_tag = findtext(message, regex("</.>"))
		else
			html_tags += list(html_tag, html_tag + 1, html_tag + 2, html_tag + 3)
			html_tag = findtext(message, regex("</.>"), html_tag + 3)

	switch(text_alignment)
		if("center")
			maptext_x = -(maptext_width * 0.5 - 16)
		if("right")
			maptext_x = -(maptext_width - 32)
	if(scroll_down)
		maptext_y = length(linebreaks) * 14

	for(var/i in 1 to length(message) + 1)
		if(i in linebreaks)
			if(scroll_down)
				maptext_y -= 14 //Move the object to keep lines in the same place.
			continue
		if(i in html_tags)
			continue
		maptext = "<span style=\"[style]\">[copytext_char(message,1,i)]</span>"
		sleep(speed)

/// Runs Scale, Turn, and Translate if supplied parameters, then multiplies by others if set.
/matrix/proc/Update(scale_x, scale_y, rotation, offset_x, offset_y, list/others)
	var/x_null = isnull(scale_x)
	var/y_null = isnull(scale_y)
	if (!x_null || !y_null)
		Scale(x_null ? 1 : scale_x, y_null ? 1 : scale_y)
	if (!isnull(rotation))
		Turn(rotation)
	if (offset_x || offset_y)
		Translate(offset_x || 0, offset_y || 0)
	if (islist(others))
		for (var/other in others)
			Multiply(other)
	else if (others)
		Multiply(others)
	return src
