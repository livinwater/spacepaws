extends Control

@export var color: String
@export var piece_value: int = 10  # Default value of 10, can be changed in the inspector

var matched = false
var is_bomb = false  # Add this line

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func move(target):
	var tween: Tween = create_tween()
	tween.tween_property(self,"position",target,0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func dim():
	var sprite = get_node("Sprite")
	sprite.modulate = Color(1,1,1, 0.5)
	

# You can add a function to get the piece value if needed
func get_value() -> int:
	return piece_value
