extends Control # or whatever the base class is

@export var color: String
@export var piece_value: int = 10  # Default value of 10, can be changed in the inspector
@export var row_texture: Texture
@export var column_texture: Texture
@export var adjacent_texture: Texture

var matched = false
var is_bomb = false  # Add this line
var is_row_bomb = false
var is_column_bomb = false
var is_adjacent_bomb = false

signal bomb_moved(bomb_type, column, row)

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Piece created: ", color)
	# Make sure there's a Sprite or other visual node as a child
	var sprite = get_node("Sprite")
	

func move(target):
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", target, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func dim():
	var sprite = get_node("Sprite")
	sprite.modulate = Color(1,1,1, 0.5)
	

# You can add a function to get the piece value if needed
func get_value() -> int:
	return piece_value
	
func make_column_bomb():
	is_column_bomb = true
	is_bomb = true
	$Sprite.texture = column_texture
	$Sprite.modulate = Color(1,1,1)
	
func make_row_bomb():
	is_row_bomb = true
	is_bomb = true
	$Sprite.texture = row_texture
	$Sprite.modulate = Color(1,1,1)
	
func make_adjacent_bomb():
	is_adjacent_bomb = true
	is_bomb = true
	$Sprite.texture = adjacent_texture
	$Sprite.modulate = Color(1,1,1)
