extends Control

var current_level = {}
var grid_size = Vector2(6, 8)
var piece_types = ["blue", "red", "green", "yellow", "bomb", "color_bomb", "empty"]

func _ready():
	initialize_editor()

func initialize_editor():
	current_level = {
		"id": get_node("IdInput").text,
		"moves": int(get_node("MovesInput").text),
		"blue_goal": int(get_node("BlueGoalInput").text),
		"grid_size": {"width": grid_size.x, "height": grid_size.y},
		"empty_spaces": [],
		"special_pieces": [],
		"initial_layout": []
	}
	create_grid()

func create_grid():
	var grid = get_node("Grid")
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var button = Button.new()
			button.text = "blue"
			button.connect("pressed", Callable(self, "cycle_piece_type").bind(button))
			grid.add_child(button)

func cycle_piece_type(button):
	var current_index = piece_types.find(button.text)
	var next_index = (current_index + 1) % piece_types.size()
	button.text = piece_types[next_index]
	update_level_data()

func update_level_data():
	current_level.empty_spaces.clear()
	current_level.special_pieces.clear()
	current_level.initial_layout.clear()

	var grid = get_node("Grid")
	for y in range(grid_size.y):
		var row = []
		for x in range(grid_size.x):
			var button = grid.get_child(y * grid_size.x + x)
			var piece_type = button.text
			if piece_type == "empty":
				current_level.empty_spaces.append([x, y])
				row.append(null)
			elif piece_type in ["bomb", "color_bomb"]:
				current_level.special_pieces.append({"type": piece_type, "position": [x, y]})
				row.append(piece_type)
			else:
				row.append(piece_type)
		current_level.initial_layout.append(row)

func save_level():
	var file = FileAccess.open("user://levels.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(current_level))
	file.close()

# Add UI elements (inputs, buttons) and connect them to these functions
