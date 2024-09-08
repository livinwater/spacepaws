extends Control

func _ready():
	var home_button = $HomeButton
	if home_button:
		home_button.connect("pressed", Callable(self, "_on_home_button_pressed"))
	else:
		print("Error: HomeButton node not found in WinScreen")

func _on_home_button_pressed():
	var main_menu_path = "res://Scenes/MainMenu.tscn"
	if ResourceLoader.exists(main_menu_path):
		print("Changing to MainMenu scene")  # Debug print
		get_tree().change_scene_to_file(main_menu_path)
	else:
		print("Error: MainMenu scene not found at ", main_menu_path)
		 # Optionally, you can add a fallback here, such as quitting the game
		 # get_tree().quit()
