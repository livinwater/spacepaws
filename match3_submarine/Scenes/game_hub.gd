extends Control

var total_points_counter: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add more icons as needed

	setup_icon("GameIcon", "Match-3: Earn points")
	setup_icon("MarketIcon", "Biomarket: Trade points for chests")

	total_points_counter = $TotalPointsCounter
	if total_points_counter:
		update_points_display()
	else:
		print("Error: TotalPointsCounter not found")

	# We can remove this part since we're using TotalPointsCounter now
	# points_label = Label.new()
	# points_label.text = "Total Points: " + str(Global.get_total_points())
	# points_label.set_position(Vector2(10, 10))  # Adjust position as needed
	# add_child(points_label)

func setup_icon(icon_name: String, tooltip_text: String):
	var icon = get_node_or_null(icon_name)
	if icon:
		icon.tooltip_text = tooltip_text
		icon.connect("gui_input", Callable(self, "_on_icon_input").bind(icon_name))
		print(icon_name, " connected successfully")
	else:
		print("Error: ", icon_name, " node not found")

func _on_icon_input(event, icon_name: String):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print(icon_name, " clicked!")
		match icon_name:
			"GameIcon":
				load_game()
			"MarketIcon":
				load_biomarket()
			# Add more cases as needed

func load_game():
	var game_window_path = "res://Scenes/game_window.tscn"
	if ResourceLoader.exists(game_window_path):
		print("Loading game scene")
		get_tree().change_scene_to_file(game_window_path)
	else:
		print("Error: game_window.tscn not found at ", game_window_path)

func load_biomarket():
	var biomarket_path = "res://Scenes/biomarket_inside.tscn"
	if ResourceLoader.exists(biomarket_path):
		print("Loading biomarket scene")
		get_tree().change_scene_to_file(biomarket_path)
	else:
		print("Error: biomarket_inside.tscn not found at ", biomarket_path)

# Add this function to update the display when returning from a game
func _enter_tree():
	update_points_display()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_points_display():
	if total_points_counter:
		total_points_counter.text = "Points: " + str(Global.get_total_points())
	else:
		print("Error: TotalPointsCounter is null")
