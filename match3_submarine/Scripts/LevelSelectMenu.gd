extends Control

var level_button_scene = preload("res://Scenes/WinPopup.tscn")

func _ready():
	load_levels()
	populate_level_menu()

func load_levels():
	Global.load_levels()  # Assuming you've added this method to your Global script

func populate_level_menu():
	var grid = get_node("LevelGrid")
	for level in Global.levels:
		var button = level_button_scene.instantiate()
		button.text = str(level.id)
		button.connect("pressed", Callable(self, "on_level_selected").bind(level.id))
		grid.add_child(button)

func on_level_selected(level_id):
	Global.load_level(level_id - 1)  # Assuming level IDs start at 1
	get_tree().change_scene_to_file("res://Scenes/game_window.tscn")
