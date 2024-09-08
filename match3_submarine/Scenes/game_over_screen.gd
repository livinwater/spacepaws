extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		$TryAgainButton.connect("pressed", _on_try_again_button_pressed)


func _on_try_again_button_pressed():
	var main_menu_path = "res://Scenes/MainMenu.tscn"
	if ResourceLoader.exists(main_menu_path):
		print("Changing to MainMenu scene")  # Debug print
		get_tree().change_scene_to_file(main_menu_path)
	else:
		print("Error: MainMenu scene not found at ", main_menu_path)
