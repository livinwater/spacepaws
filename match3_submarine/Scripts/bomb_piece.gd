extends "res://Scripts/piece.gd"

func _ready():
    color = "bomb"
    is_bomb = true
    matched = false
    $Sprite.texture = load("res://assets/bomb_sprite.png")
    $Sprite.modulate = Color(1, 1, 1, 1)  # Ensure full opacity