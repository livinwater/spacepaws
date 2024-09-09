extends "res://Scripts/piece.gd"


func _ready():
	is_bomb = true
	matched = false
	$Sprite.modulate = Color(1, 1, 1, 1)
	pass
