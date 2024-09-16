extends Control

@onready var popup = $Popup
@onready var score_label = $Popup/VBoxContainer/ScoreLabel
@onready var points_label = $Popup/VBoxContainer/PointsLabel
@onready var continue_button = $Popup/VBoxContainer/ContinueButton
@onready var home_button = $Popup/VBoxContainer/HomeButton

func _ready():
	print("WinPopup _ready called")
	process_mode = Node.PROCESS_MODE_ALWAYS
	continue_button.pressed.connect(_on_continue_button_pressed)
	home_button.pressed.connect(_on_home_button_pressed)
	print("Button connections set up")

func set_score(score: int):
	print("Setting score: ", score)
	score_label.text = "Score: " + str(score)
	points_label.text = "Points earned: " + str(score)

func _on_continue_button_pressed():
	print("Continue button pressed")
	popup.hide()
	get_tree().paused = false
	get_parent().resume_game()

func _on_home_button_pressed():
	print("Home button pressed")
	get_tree().paused = false
	print("Current total points: ", Global.get_total_points())  # Add this line
	print("Attempting to change scene to GameHub")
	var gamehub_path = "res://Scenes/GameHub.tscn"
	if ResourceLoader.exists(gamehub_path):
		print("Loading GameHub scene")
		get_tree().change_scene_to_file(gamehub_path)
	else:
		print("Error: GameHub scene not found at ", gamehub_path)

func _input(event):
	if popup.visible and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Mouse click detected on WinPopup")
		var click_pos = get_viewport().get_mouse_position()
		print("Click position: ", click_pos)
		var popup_rect = Rect2(popup.position, popup.size)
		print("Popup rect: ", popup_rect)
		if popup_rect.has_point(click_pos):
			print("Click inside popup")
			var local_click_pos = click_pos - popup.position
			if Rect2(continue_button.position, continue_button.size).has_point(local_click_pos):
				print("Click on continue button")
				_on_continue_button_pressed()
			elif Rect2(home_button.position, home_button.size).has_point(local_click_pos):
				print("Click on home button")
				_on_home_button_pressed()
			else:
				print("Click inside popup but not on a button")
		else:
			print("Click outside popup")
		get_viewport().set_input_as_handled()

func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_ENTER:
		print("Mouse entered WinPopup")
	elif what == NOTIFICATION_WM_MOUSE_EXIT:
		print("Mouse exited WinPopup")
