extends Control

signal continue_pressed

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

func set_score(level_score: int, cumulative_score: int):
	print("Setting score: ", level_score, " cumulative: ", cumulative_score)
	score_label.text = "Level Score: " + str(level_score)
	points_label.text = "Total Points Earned: " + str(cumulative_score)

func _on_continue_button_pressed():
	print("Continue button pressed")
	emit_signal("continue_pressed")
	queue_free()
	get_tree().paused = false

func _on_home_button_pressed():
	print("Home button pressed")
	get_tree().paused = false
	Global.add_points(Global.get_cumulative_points())
	Global.reset_cumulative_points()
	print("Current total points: ", Global.get_total_points())
	print("Attempting to change scene to GameHub")
	var gamehub_path = "res://Scenes/GameHub.tscn"
	if ResourceLoader.exists(gamehub_path):
		print("Loading GameHub scene")
		get_tree().change_scene_to_file(gamehub_path)
	else:
		print("Error: GameHub scene not found at ", gamehub_path)
