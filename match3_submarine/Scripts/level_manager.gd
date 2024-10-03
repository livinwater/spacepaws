extends Node2D

# A simple array representing levels and their completion status.
var levels = [
	{"scene_path": "res://levels/level1.tscn", "completed": false},
	{"scene_path": "res://levels/level2.tscn", "completed": false},
	{"scene_path": "res://levels/level3.tscn", "completed": false}
]

var current_level_index = 0  # Tracks the current level the player is on
var current_scene = null     # Keeps a reference to the currently loaded level

# Load the current level
func load_level(index: int) -> void:
	if current_scene:
		remove_child(current_scene)  # Remove the previous level if one is loaded
		current_scene.queue_free()   # Free the memory of the previous level scene
	
	# Load the new level scene
	var level_data = levels[index]
	var level_scene = load(level_data["scene_path"])
	
	# Instance the scene and add it to the game
	current_scene = level_scene.instantiate()
	add_child(current_scene)
	
	# Update the current level index
	current_level_index = index

# Mark the current level as completed and move to the next one
func complete_level() -> void:
	levels[current_level_index]["completed"] = true  # Mark the current level as completed
	
	# Check if there are more levels
	if current_level_index + 1 < levels.size():
		load_level(current_level_index + 1)  # Load the next level
	else:
		print("Congratulations! All levels completed!")

# Restart the current level
func restart_level() -> void:
	load_level(current_level_index)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
