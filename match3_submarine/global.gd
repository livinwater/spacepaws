extends Node

var wallet_address: String = ""
var total_points: int = 0
var silica_count = 0
var metal_count = 0
var crystal_count = 0
var ticket_count = 0

# Add these new variables for level management
var current_level_id: int = 1
var levels = {}

var cumulative_points: int = 0

func set_wallet_address(address: String):
	wallet_address = address

func get_wallet_address() -> String:
	return wallet_address

func add_points(points: int):
	total_points += points
	if total_points < 0:
		total_points = 0

func get_total_points() -> int:
	return total_points

func add_resource(resource_type: String, amount: int):
	match resource_type:
		"Silica":
			silica_count += amount
		"Metal":
			metal_count += amount
		"Crystal":
			crystal_count += amount
		"Ticket":
			ticket_count += amount
 
func get_resource_count(resource_type: String) -> int:
	match resource_type:
		"Silica":
			return silica_count
		"Metal":
			return metal_count
		"Crystal":
			return crystal_count
		"Ticket":
			return ticket_count
	return 0

func add_cumulative_points(points: int):
	cumulative_points += points

func reset_cumulative_points():
	cumulative_points = 0

func get_cumulative_points() -> int:
	return cumulative_points

func load_level(id: int) -> void:
	print("Attempting to load level: ", id)
	current_level_id = id
	print("Current level ID set to: ", current_level_id)
	if str(id) in levels:
		var level_data = levels[str(id)]
		print("Loading level data: ", level_data)
		
		# Remove the existing game scene if it exists
		var existing_game_scene = get_tree().root.get_node_or_null("Control")
		if existing_game_scene:
			existing_game_scene.queue_free()
		
		# Instance and add the new game scene
		var game_scene = load("res://Scenes/game_window.tscn").instantiate()
		get_tree().root.add_child(game_scene)
		
		# Wait for the scene to be added to the tree
		await get_tree().process_frame
		
		var grid = game_scene.get_node("grid")
		if grid:
			print("Grid node found, setting level data")
			print("Level data being passed: ", level_data)
			grid.set_level_data(level_data)
			print("Level ", id, " loaded")
		else:
			print("Error: grid node not found in game_window scene")
	else:
		print("Level " + str(id) + " not found in levels data!")
		# If it's the last level, return to the game hub
		get_tree().change_scene_to_file("res://Scenes/GameHub.tscn")

func complete_level() -> void:
	var next_level_id = levels[str(current_level_id)].get("next_level_id")
	if next_level_id:
		load_level(next_level_id)
	else:
		print("All levels completed!")
		get_tree().change_scene_to_file("res://Scenes/GameHub.tscn")

# Add this function to load levels from a file (if you want to store levels externally)
func load_levels() -> bool:
	var file = FileAccess.open("res://levels.json", FileAccess.READ)
	if file:
		print("levels.json file opened successfully")
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			levels = json.get_data()
			print("Parsed levels data: ", levels)
			file.close()
			return true
		else:
			print("JSON parse error: ", json.get_error_message(), " at line ", json.get_error_line())
			file.close()
			return false
	else:
		print("Failed to open levels.json")
		return false
