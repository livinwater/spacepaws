extends Control

var chest_cost = 1000
var resources = ["Silica", "Metal", "Crystal"]
var raffle_ticket_chance = 0.05  # 5% chance to get a raffle ticket

func _ready():
	update_points_display()
	
	# Connect the chest button
	var chest_button = $Chest2
	if chest_button:
		chest_button.connect("pressed", Callable(self, "_on_chest_pressed"))
	else:
		print("Error: Chest button not found")
	
	# Add a back button
	var back_button = Button.new()
	back_button.text = "Back to Hub"
	back_button.position = Vector2(50, 50)
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	add_child(back_button)

func update_points_display():
	var total_points_counter = $TotalPointsCounter
	if total_points_counter:
		total_points_counter.text = "Points: " + str(Global.get_total_points())
	else:
		print("Error: TotalPointsCounter not found in BioMarketInside")

func _on_back_button_pressed():
	var game_hub_path = "res://Scenes/GameHub.tscn"
	if ResourceLoader.exists(game_hub_path):
		print("Returning to GameHub scene")
		get_tree().change_scene_to_file(game_hub_path)
	else:
		print("Error: GameHub scene not found at ", game_hub_path)

func _on_chest_pressed() -> void:
	print("Chest clicked!")
	if Global.get_total_points() >= chest_cost:
		var dialog = ConfirmationDialog.new()
		dialog.dialog_text = "Open chest for 1000 points?"
		dialog.get_ok_button().text = "Open"
		dialog.get_cancel_button().text = "Cancel"
		dialog.connect("confirmed", Callable(self, "_on_chest_open_confirmed"))
		add_child(dialog)
		dialog.popup_centered()
	else:
		var insufficient_points_dialog = AcceptDialog.new()
		insufficient_points_dialog.dialog_text = "Not enough points to open the chest."
		add_child(insufficient_points_dialog)
		insufficient_points_dialog.popup_centered()
		
func _on_chest_open_confirmed():
	Global.add_points(-chest_cost)
	update_points_display()
	   
	var max_resource_amount = 5  # Maximum amount of a single resource
	   
	var reward = ""
	if randf() < raffle_ticket_chance:
		reward = "1 Raffle Ticket"
	else:
		var resource = resources[randi() % resources.size()]
		var amount = randi() % max_resource_amount + 1  # Random amount between 1 and max_resource_amount
		reward = str(amount) + " " + resource
		Global.add_resource(resource, amount)  # Add this line to update the global resource count
	
	var reward_dialog = AcceptDialog.new()
	reward_dialog.dialog_text = "You received: " + reward
	add_child(reward_dialog)
	reward_dialog.popup_centered()
	   
	print("Player received: ", reward)
