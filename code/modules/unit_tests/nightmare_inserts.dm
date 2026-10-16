/// Test that the admin Nightmare menu finds every insert of the loaded maps, and can preview them
/datum/unit_test/nightmare_inserts

/datum/unit_test/nightmare_inserts/Run()
	for(var/context_name in SSnightmare.contexts)
		var/list/inserts = SSnightmare.get_inserts(context_name)
		var/previewed = FALSE
		for(var/id in inserts)
			var/list/insert = inserts[id]
			if(!insert["landmark"])
				TEST_FAIL("Nightmare [context_name] insert [insert["file"]] has no landmark")
			if(!fexists(insert["path"]))
				TEST_FAIL("Nightmare [context_name] insert [insert["file"]] does not exist at [insert["path"]]")
				continue
			if(previewed)
				continue
			previewed = TRUE
			var/datum/parsed_map/nightmare_preview/preview = new(file(insert["path"]))
			preview.load(1, 1, 1, crop_map = TRUE, no_changeturf = TRUE)
			TEST_ASSERT(length(preview.images), "Preview of Nightmare [context_name] insert [insert["file"]] has no images")
