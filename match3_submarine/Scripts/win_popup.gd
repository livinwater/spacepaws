extends Control

@onready var color_rect = $ColorRect
@onready var score_label = $CenterContainer/PanelContainer/VBoxContainer/ScoreLabel
@onready var points_label = $CenterContainer/PanelContainer/VBoxContainer/PointsLabel
@onready var continue_button = $CenterContainer/PanelContainer/VBoxContainer/ContinueButton
@onready var home_button = $CenterContainer/PanelContainer/VBoxContainer/HomeButton

func _ready():
	print("WinPopup _ready called")
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	get_tree().root.connect("size_changed", Callable(self, "_on_viewport_size_changed"))
	_on_viewport_size_changed()
	
func _on_viewport_size_changed():
	size = get_viewport_rect().size

func print_node_structure(node, indent=""):
	print(indent + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		print_node_structure(child, indent + "  ")

func set_score(score: int):
	print("Setting score: ", score)
	score_label.text = "Score: " + str(score)
	points_label.text = "Points earned: " + str(score)

func _on_continue_button_pressed():
	print("Continue button pressed")
	queue_free()
	get_tree().paused = false
	get_parent().resume_game()

func _on_home_button_pressed():
	print("Home button pressed")
	get_tree().paused = false
	print("Current total points: ", Global.get_total_points())
	print("Attempting to change scene to GameHub")
	var gamehub_path = "res://Scenes/GameHub.tscn"
	if ResourceLoader.exists(gamehub_path):
		print("Loading GameHub scene")
		get_tree().change_scene_to_file(gamehub_path)
	else:
		print("Error: GameHub scene not found at ", gamehub_path)
