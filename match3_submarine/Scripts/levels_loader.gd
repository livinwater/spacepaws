var levels = []

func load_levels():
	var file = FileAccess.open("user://levels.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			levels = json.get_data()
		file.close()
	else:
		print("Failed to open levels.json")

func save_levels():
	var file = FileAccess.open("user://levels.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(levels))
	file.close()
