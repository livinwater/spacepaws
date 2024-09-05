extends Control

@export var color: String

var matched = false

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
	
