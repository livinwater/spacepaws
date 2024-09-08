extends Control

func _ready():
	$StartButton.connect("pressed", _on_start_button_pressed)


func _on_start_button_pressed():
	var game_window_path = "res://Scenes/game_window.tscn"
	if ResourceLoader.exists(game_window_path):
		get_tree().change_scene_to_file(game_window_path)
	else:
		print("Error: GameWindow scene not found at ", game_window_path)
