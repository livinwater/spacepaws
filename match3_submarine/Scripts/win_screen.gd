extends Control

func _ready():
	print("Win screen _ready called")  # Debug print
	
	# Make the win screen a dark overlay
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)  # Dark semi-transparent background
	overlay.anchor_right = 1
	overlay.anchor_bottom = 1
	add_child(overlay)
	
	# Create a popup-like container for content
	var popup = PanelContainer.new()
	popup.anchor_left = 0.5
	popup.anchor_top = 0.5
	popup.anchor_right = 0.5
	popup.anchor_bottom = 0.5
	popup.grow_horizontal = 2
	popup.grow_vertical = 2
	add_child(popup)
	
	var vbox = VBoxContainer.new()
	popup.add_child(vbox)
	
	# Add win message
	var win_label = Label.new()
	win_label.text = "Congratulations! You've won!"
	vbox.add_child(win_label)
	
	# Add score display
	var score_label = Label.new()
	score_label.text = "Score: " + str(Global.get_total_points())
	vbox.add_child(score_label)
	
	# Add buttons
	var home_button = Button.new()
	home_button.text = "Return to Hub"
	home_button.connect("pressed", Callable(self, "_on_home_button_pressed"))
	vbox.add_child(home_button)
	
	var continue_button = Button.new()
	continue_button.text = "Continue Playing"
	continue_button.connect("pressed", Callable(self, "_on_continue_button_pressed"))
	vbox.add_child(continue_button)
	
	print("Win screen setup complete")  # Debug print

func _on_home_button_pressed():
	print("Home button pressed")  # Debug print
	var game_hub_path = "res://Scenes/GameHub.tscn"
	if ResourceLoader.exists(game_hub_path):
		print("Changing to GameHub scene")
		get_tree().paused = false  # Unpause the game before changing scene
		get_tree().change_scene_to_file(game_hub_path)
	else:
		print("Error: GameHub scene not found at ", game_hub_path)

func _on_continue_button_pressed():
	print("Continue button pressed")  # Debug print
	# Remove the win screen overlay
	get_tree().paused = false  # Unpause the game
	get_parent().set_process_input(true)  # Re-enable input on the grid
	queue_free()

# Override _input function to handle input when the game is paused
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		print("Win screen received input")  # Debug print
		get_viewport().set_input_as_handled()
		if event.position.x >= 0 and event.position.x <= get_viewport().size.x and \
		   event.position.y >= 0 and event.position.y <= get_viewport().size.y:
			print("Input within win screen bounds")  # Debug print
			accept_event()
